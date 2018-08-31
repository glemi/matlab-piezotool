classdef WaferMasterNode < handle
    %WAFERMASTERNODE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        WaferRepo
        WaferId
        DataTable
    end
    
    methods
        
        function this = WaferMasterNode(Repo, WaferId)
            this.WaferRepo = Repo;
            this.WaferId = WaferId;
            this.load();
        end
        
        function add(this, name, value, interv)
            this.DataTable(this.WaferId, name) = value;
            
            if nargin > 4
                this.add([name '_lo'], interv(:,1));
                this.add([name '_hi'], interv(:,2));
            end
        end
        
        function [value, interv] = get(this, name)
            if isempty(this.WaferId)
                value = this.DataTable{:, name};
            elseif any(strcmp(this.WaferId, this.DataTable.Properties.RowNames))
                value = this.DataTable{this.WaferId, name};
            else
                value = NaN;
            end
            
            if nargout == 2
                plus = this.get([name '_lo'], pos);
                minus = this.get([name '_hi'], pos);
                interv = [plus minus];
            end
        end
        function uv = uget(this, name)
            value = this.get(name);
            
            if this.has([name '_lo']) && this.has([name '_hi'])
                lo = this.get([name '_lo']);
                hi = this.get([name '_hi']);
                uv = uval(value, [lo hi], 'interval');
            elseif this.has([name '_plus']) && this.has([name '_minus'])
                pl = this.get([name '_plus']);
                mn = this.get([name '_minus']);
                uv = uval(value, [pl mn], 'delta');
            elseif this.has([name '_delta'])
                dt = this.get([name '_delta']);
                uv = uval(value, dt, 'delta');
            else
                uv = uval(value);
            end
        end
        function [file, path] = getDataFile(this)
            rootdir = this.WaferRepo.RootDir;
            filename = 'master.node.csv';
            if nargout == 1
                file = fullfile(rootdir, filename);
            elseif nargout == 2
                path = rootdir;
                file = filename;
            end
        end
        
        function load(this)
            filepath = this.getDataFile;
            if exist(filepath, 'file')
                this.DataTable = readtable(filepath, 'ReadRowNames', true);
            else
                this.DataTable = table;
                this.DataTable.Position = zeros(0,1);
            end
        end
        
        function write(this)
            [filename, path] = this.getDataFile;
            warning off MATLAB:MKDIR:DirectoryExists;
            mkdir(path);
            filepath = fullfile(path, filename);
            
            this.DataTable = sortrows(this.DataTable, 'Position');
            writetable(this.DataTable, filepath, 'Delimiter', ';');
        end
        
        function yes = has(this, name)
            names = this.DataTable.Properties.VariableNames;
            yes = ismember(name, names);
        end
    end
end

