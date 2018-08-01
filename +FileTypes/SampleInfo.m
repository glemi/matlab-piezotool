classdef SampleInfo < handle
    %SAMPLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        WaferID = '';
        SampleID = '';
        SampleIndex = [];
        Position = [];
        Electrode = '';
        ElSize = [];
        MIndex = [];
        Comment = '';
        
        Mask = '';
        Params = struct([]);
        Config = struct([]);
    end
    
    methods
        function config = get.Config(this)
            if isempty(this.Config)
                this.loadConfig;
            end
            config = this.Config;
        end
        function params = get.Params(this)
            if ischar(this.Params)
                this.loadParams(this.Params);
            end
            params = this.Params;
        end
    end    
    
    methods(Static)
        function range = genRangeName(info, options)
            if nargin < 2
                options = {'lazy'};
            end
            
            n = length(info);
            wafers  = {info.WaferID};
            samples = {info.SampleID};
            
            if n == 1
                wrange = wafers{1};
                srange = samples{1};
            elseif ismember('lazy', options)
                wrange = strjoin(unique(wafers),'/');
                srange = [samples{1} '-' samples{end}];
            elseif ismember('precise', options)
                wrange = strjoin(unique(wafers),'/');
                srange = strjoin(samples, '-');
            end
            
            range = [wrange ' ' srange];
        end
        function indices = sort(info)
            t = table;
            t{:,1} = {info.WaferID}';
            t{:,2} = [info.SampleIndex]';
            t{:,3} = [info.ElSize]';
            t{:,4} = [info.MIndex]';
            
            [~, indices] = sortrows(t,[1 3 2 4]);
        end
    end
    
    methods(Access = private)
        function loadConfig(this)
            app = DataApp.instance;
            paramdir = app.ParamDir;
            filename = sprintf('%s.config', this.WaferID);
            file = fullfile(paramdir, filename);
            
            if exist(file, 'file')                
                this.Config = HBAR_loadconfig(file);
            end
        end
        function loadParams(this, parfile)
            app = DataApp.instance;
            paramdir = app.ParamDir;
            filename = sprintf('%s.par', parfile);
            file = fullfile(paramdir, filename);
            
            if exist(file, 'file')                
                this.Params = FileTypes.read_pars(file);
            end
        end
    end
end

