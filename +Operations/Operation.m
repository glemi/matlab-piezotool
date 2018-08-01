classdef Operation < handle
    %OPERATION Summary of this class goes here
    %   Detailed explanation goes here
    
    %
    % Implementation details:
    % https://stackoverflow.com/questions/1458088/matlab-polymorphism
    % https://ch.mathworks.com/help/matlab/ref/matlab.mixin.heterogeneous-class.html
    
    properties
        Name = '';
        Title = '';
        Description = '';
        
        FileType = '';
        DataFiles = DataFile.empty;
        
        Aggregatable = false;
        Cacheable = true;
        CacheEnable = true;
        
        Results;
        Graphics; % not used
        
        RawPlotFcn;             % Plot raw data without processing
        CalculateFcn;           % Process data and calculate result *
        ResultPlotFcn;          % Plot calculation result *
        MultiResultPlotFcn;     % Plot multiple results (aggregate)
        ExportFcn;              % Export (multiple) results to text file
        SubmitFcn;              % Submit (multiple) results to repository
        % * functions with a star (*) are sensitive to the [Aggregatable]
        % flag: If true, the Operation will invoke these functions once and
        % supply them with an array containing multiple datasets / results.
        % If false it will invoke the functions multiple times with a 
        % single dataset / result at each time.
    end
    
    methods
        function this = Operation(name)
            if nargin > 0
                this.Name = name;
            end
            this.DataFiles = DataFile.empty;
        end
        
        function setDataFiles(this, files)
            this.Results = struct([]);
            this.DataFiles = files;
        end
        
        function rawPlot(this)
            if isempty(this.RawPlotFcn)
                error 'RawPlotFcn has not been defined';
            end
            n = length(this.DataFiles);
            for k = 1:n
                data = this.getData(k);
                info = this.getInfo(k);
                this.createFigure(info, 'data');
                this.RawPlotFcn(info, data);
            end
        end
        function calculate(this)
            if isempty(this.CalculateFcn)
                error 'CalculateFcn has not been defined';
            end
            if this.Aggregatable
                result = this.getResult;
                if isempty(result)
                    data = this.getData;
                    info = this.getInfo;
                    this.Results = this.CalculateFcn(info, data);
                end
            else
                n = length(this.DataFiles);
                for k = 1:n
                    result = this.getResult(k);
                    if isempty(result)
                        data = this.getData(k);
                        info = this.getInfo(k);
                        this.Results{k} = this.CalculateFcn(info, data);
                    end
                end
            end
        end
        function recalculate(this)
            if isempty(this.CalculateFcn)
                error 'CalculateFcn has not been defined';
            end
            if this.Aggregatable
                data = this.getData;
                info = this.getInfo;
                this.Results = this.CalculateFcn(info, data);
            else
                n = length(this.DataFiles);
                for k = 1:n
                    data = this.getData(k);
                    info = this.getInfo(k);
                    this.Results{k} = this.CalculateFcn(info, data);
                end
            end
        end
        function resultPlot(this)
            if isempty(this.CalculateFcn)
                error 'CalculateFcn has not been defined';
            end
            if this.Aggregatable
                info = this.getInfo;
                result = this.getResult;
                this.createFigure(info, 'result');
                this.ResultPlotFcn(info, result);
            else
                n = length(this.DataFiles);
                for k = 1:n
                    info = this.getInfo(k);
                    result = this.getResult(k);
                    this.createFigure(info, 'result');
                    this.ResultPlotFcn(info, result);
                end
            end
        end
        function multiResultPlot(this)
            if isempty(this.MultiResultPlotFcn)
                error 'MultiResultPlotFcn has not been defined';
            end
            if this.Aggregatable
                error 'Plotting Multiple Results is only available for non-aggregatable Operatiosn';
            end
            results = this.getResults;
            info = this.getInfo;
            this.createFigure(info, 'multi');
            this.MultiResultPlotFcn(info, results);
        end
        function export(this)
            if isempty(this.ExportFcn)
                error 'ExportFcn has not been defined';
            end
            results = this.getResults;
            this.ExportFcn(results);
        end
        function submit(this)
            if isempty(this.SubmitFcn)
                error 'SubmitFcn has not been defined';
            end
            info = this.getInfo;
            results = this.getResults;
            repo = WaferRepo.instance;
            this.SubmitFcn(info, results, repo);
        end
              
        function hf = createFigure(this, info, action)
            if length(info) > 1
                samplename = FileTypes.SampleInfo.genRangeName(info);
            else 
                samplename = [info.WaferID '_' info.SampleID];
                if ~isempty(info.Electrode)
                    samplename = [samplename '_' info.Electrode];
                end
                if ~isempty(info.MIndex)
                    samplename = [samplename '_' info.MIndex];
                end
            end
            opname = this.Name;
            figname = [opname ':' samplename '.' action];
            hf = fig(figname); clf;
        end
        
        function data = getData(this, index)
            if nargin == 2
                if isempty(this.DataFiles(index).Data)
                    this.DataFiles(index).Load;
                end
                data = this.DataFiles(index).Data;
            else
                n = length(this.DataFiles);
                for k = 1:n
                    data(k) = this.getData(k);
                end
            end
        end
        function info = getInfo(this, index)
            if nargin == 2
                info = this.DataFiles(index).Info;
            else
                n = length(this.DataFiles);
                for k = 1:n
                    info(k) = this.DataFiles(k).Info;
                end
            end
        end
        function result = getResult(this, index)
            if this.Aggregatable
                if ~isempty(this.Results)
                    result = this.Results;
                elseif this.CacheEnable
                    result = this.loadCachedResult;
                else
                    result = [];
                end
            elseif nargin == 2
                if isempty(this.CalculateFcn)
                    result = this.getData(index);
                elseif length(this.Results) >= index && ~isempty(this.Results{index})
                    result = this.Results{index};
                elseif this.Cacheable && this.CacheEnable
                    result = this.loadCachedResult(index);
                else
                    result = [];
                end
            else
                n = length(this.DataFiles);
                for k = 1:n
                	result(k) = this.getResult(k);
                end
            end
        end
        function results = getResults(this)
            if this.Aggregatable
                results = this.getResult;
            else
                n = length(this.DataFiles);
                for k = 1:n
                    result = this.getResult(k);
                    if ~isempty(result)
                        results(k) = result;
                    else 
                        error 'Result missing';
                    end
                end
            end
        end
        function yes = resultAvailable(this, index)
             if this.Aggregatable
                if ~isempty(this.Results) || isempty(this.CalculateFcn)
                    yes = true;
                elseif this.Cacheable && this.CacheEnable
                    yes = this.cacheFileAvailable;
                else
                    yes = false;
                end
             elseif nargin == 2
                if isempty(this.CalculateFcn) 
                    yes = true; % data is the result
                elseif length(this.Results) >= index && ~isempty(this.Results{index})
                    yes = true;
                elseif this.Cacheable && this.CacheEnable
                    yes = this.cacheFileAvailable(index);
                else
                    yes = false;
                end
             else
                 n = length(this.DataFiles);
                 for k = 1:n
                     yes(k) = this.resultAvailable(k);
                 end
             end
        end
        function yes = cacheFileAvailable(this, index)
            if nargin == 2
                fpath = this.getCacheFilePath(index);
                yes = logical(exist(fpath, 'file'));
            else
                n = length(this.DataFiles);
                for k = 1:n
                    yes(k) = this.cacheFileAvailable(k);
                end
            end
        end
        function result = loadCachedResult(this, index)
            if nargin < 2
                index = 1;
            end
            if this.cacheFileAvailable(index)
                cachefile = this.getCacheFilePath(index);
                contents = load(cachefile);
                result = contents.result;
            else
                result = struct([]);
                %error 'No Cached Data Available';
            end 
        end
        function cachefile = getCacheFilePath(this, index)
            app = DataApp.instance;
            cachedir = app.CacheDir;
            
            if ~exist(cachedir, 'dir')
                mkdir(cachedir);
            end
           
            datafile = this.DataFiles(index);
            
            cachedir = fullfile(cachedir, datafile.Type.AltID);
            if ~exist(cachedir, 'dir')
                mkdir(cachedir);
            end
            
            cachefile = strrep(datafile.RelPath, '\', '__');
            cachefile = [cachefile '.mat'];
            cachefile = fullfile(cachedir, cachefile);
        end
    end
    
end

