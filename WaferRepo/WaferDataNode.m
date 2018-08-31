classdef WaferDataNode < handle
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        WaferRepo
        WaferId
        Type
        DataTable;
    end
    
    methods(Access = public)
        function this = WaferDataNode(Repo, WaferId, Type)
            this.WaferRepo = Repo;
            this.WaferId = WaferId;
            this.Type = Type;
            this.load();
        end
        function add(this, name, pos, value, interv)
            if isa(value, 'uval')
                this.add(name, pos, double(value), vertcat(value.Interval));
                return;
            end
            
            tadd = table;
            tadd.Position = pos(:);          
            tadd.(name) = value(:);
            
            if length(pos) > length(unique(pos))
                error 'Cannot have more than one entry at the same position';
            end
            
            [tnew, i]= outerjoin(tadd, this.DataTable, 'Keys', 'Position', 'MergeKeys', true, 'LeftVariables', 'Position');
            j = logical(i);
            tnew(j, name) = tadd(i(j), name);
            tnew{j, 'Enabled'} = true(sum(j),1);
            this.DataTable = tnew;
            this.DataTable.Properties.UserData = datestr(now);
            
            if nargin > 4
                if size(interv,2) == 1
                    this.add([name '_lo'], pos, value - interv);
                    this.add([name '_hi'], pos, value + interv);
                elseif size(interv,2) == 2
                    this.add([name '_lo'], pos, interv(:,1));
                    this.add([name '_hi'], pos, interv(:,2));
                else
                    error 'Error Interval dimensions inconsistent';
                end
            end
        end
        function setEnabled(this, pos, value)
            i = (this.DataTable{:,'Position'} == pos);
            if any(i)
                this.dataTable{i,'Enabled'} = logical(value);
            end
        end
        function value = get(this, name, pos)
            if isempty(this.DataTable)
                value = NaN; interv = NaN; return;
            end
            if nargin < 3
                pos = this.DataTable.Position;
            end
            value1 = this.DataTable.(name);
            [i,j] = ismember(pos, this.DataTable.Position);
            value( i, 1) = value1(j(i),:);
            value(~i, 1) = nan(sum(~i), size(value,2));
            
            i = this.DataTable.Enabled;
            value(~i,1) = NaN;
        end
        function uv = uget(this, name, pos)
            if nargin < 3
                pos = this.DataTable.Position;
            end
            
            value = this.get(name, pos);
            
            if this.has([name '_lo']) && this.has([name '_hi'])
                lo = this.get([name '_lo'], pos);
                hi = this.get([name '_hi'], pos);
                uv = uval(value, [lo hi], 'interval');
            elseif this.has([name '_plus']) && this.has([name '_minus'])
                pl = this.get([name '_plus'], pos);
                mn = this.get([name '_minus'], pos);
                uv = uval(value, [pl mn], 'delta');
            elseif this.has([name '_delta'])
                dt = this.get([name '_delta'], pos);
                uv = uval(value, dt, 'delta');
            else
                uv = uval(value);
            end
        end
        function value = interp(this, name, pos)
            if isempty(this.DataTable)
                value = []; return;
            end
            value = this.DataTable.(name);
            pdata = this.DataTable.Position;
            value = interp1(pdata, value, pos);
        end
        function [value] = getFitline(this, name)
            
        end
        function [file, path] = getDataFile(this)
            rootdir = this.WaferRepo.RootDir;
            waferdir = this.WaferId;
            filename = [this.Type '.node.csv'];
            if nargout == 1
                file = fullfile(rootdir, waferdir, filename);
            elseif nargout == 2
                path = fullfile(rootdir, waferdir);
                file = filename;
            end
        end
        function load(this)
            filepath = this.getDataFile;
            if exist(filepath, 'file')
                this.DataTable = readtable(filepath);
                if ~ismember('Enabled', this.DataTable.Properties.VariableNames)
                    n = size(this.DataTable, 1);
                    Enabled = true(n,1);
                    ten = table(Enabled);
                    this.DataTable = [ten this.DataTable];
                end
                this.DataTable.Enabled = logical(this.DataTable.Enabled);
                this.reorderColumns;
            else
                this.DataTable = table;
                this.DataTable.Enabled = true(0,1);
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
    end
    
    methods(Access = private)
        function addEnabledColumn(this)
            if ~ismember('Enabled', this.DataTable.Properties.VariableNames)
                n = size(this.DataTable, 1);
                this.DataTable{:,'Enabled'} = true(n,1);
            else
                i = isnan(this.DataTable{:,'Enabled'});
                this.DataTable(i,'Enabled') = true(sum(i), 1);
            end
        end
        function reorderColumns(this)
            t_enb = this.DataTable(:,'Enabled');
            t_pos = this.DataTable(:,'Position');
            [~,i_oth] = ismember(this.DataTable.Properties.VariableNames, {'Enabled' 'Position'});
            t_oth = this.DataTable(:,~i_oth);
            this.DataTable = [t_enb t_pos t_oth];
        end
        function yes = has(this, name)
            names = this.DataTable.Properties.VariableNames;
            yes = ismember(name, names);
        end
        function interv = getUncert(this, name)
            
                
        end
    end
end

