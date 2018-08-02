classdef Formatter < handle
    %VARFORMAT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        WaferRepo
        FormatTable
    end
    
    methods
        function this = Formatter(repo)
            this.WaferRepo = repo;
            if isempty(this.FormatTable)
                this.load;
            end
        end
        function format = getFormat(this, varname)
            parts = strsplit(varname, '.');
            parts = strsplit(parts{end}, '_');
            varname = parts{1};
            
            if ismember(varname, this.FormatTable.Properties.RowNames)
                row = this.FormatTable(varname, :);
                format = table2struct(row);
            else
                format = struct([]);
            end
        end
        function h = posPlot(wafer, dataref)
            node = this.WaferRepo.getNode(dataref);
            var = this.WaferRepo.getData(wafer, var_ref);
            pos = node.get('Position');
            
            h = this.xyPlot(pos, var, 'Position', var_ref);
        end
        function outtable = formatTable(this, intable)            
            varnames = intable.Properties.VariableNames;
            [m, n] = size(intable);
            %outtable = table('Size', [m n], 'VariableTypes', repmat({'string'}, 1, n));
            outtable = table;
            html = '<html><tr><td align=right width=999>';
            for j = 1:n
                varname = varnames{j};
                format = this.getFormat(varname);
                if ~isempty(format)
                    for k = 1:m
                        if isnan(intable{k,j})
                            text = '';
                        else
                            text = [html this.val2str(format, intable{k,j})];
                        end
                        outtable{k,j} = {text};
                    end
                else
                    for k = 1:m
                        if isnan(intable{k,j})
                            text = '';
                        else
                            text = [html siPrefix(intable{k,j}, '')];% sprintf('%s%.3g', html, intable{k,j});
                        end
                        outtable{k,j} = {text};
                    end
                end
            end
            if ~isempty(outtable)
                outtable.Properties.VariableNames = varnames;
            end
        end
        function formatAxes(this, xname, yname, ax)
            if nargin < 4
                ax = gca;
            end
            xfmt = this.getFormat(xname);
            yfmt = this.getFormat(yname);
            if ~isempty(xfmt)
                xtext = [xfmt.Name ' [$\rm ' xfmt.LatexUnit '$]'];
                xlabel(xtext, 'Interpreter', 'Latex');
                objs = findobj(ax, '-property', 'XData');
                for obj = each(objs)
                    obj.XData = obj.XData/xfmt.Scale;
                end
            end
            if ~isempty(yfmt)
                ytext = [yfmt.Name ' [$\rm ' yfmt.LatexUnit '$]'];
                title(ytext, 'Interpreter', 'Latex');
                objs = findobj(ax, '-property', 'XData');
                for obj = each(objs)
                    obj.YData = obj.YData/yfmt.Scale;
                end
            end
        end
    end
    
    
    methods (Access = private)
        function h = xyPlot(this, x, y, xname, yname, varargin)
            xfmt = this.getFormat(xname);
            yfmt = this.getFormat(yname);
            x = x/xfmt.Scale;
            y = y/yfmt.Scale;
            h = plot(x, y, varargin{:});
            
            xtext = sprintf('%s [%s]', xfmt.Name, xfmt.LatexUnit);
            ytext = sprintf('%s [%s]', yfmt.Name, yfmt.LatexUnit);
            xlabel(xtext);
            title(ytext);
        end
        function load(this)
            filepath = this.getFormatFile;
            if exist(filepath, 'file')
                this.FormatTable = readtable(filepath, 'ReadRowNames', true);
            else
                this.FormatTable = table;
                this.FormatTable.Position = zeros(0,1);
            end
        end
        function [file, path] = getFormatFile(this)
            rootdir = this.WaferRepo.RootDir;
            filename = 'format.xlsx';
            if nargout == 1
                file = fullfile(rootdir, filename);
            elseif nargout == 2
                path = rootdir;
                file = filename;
            end
        end
    end
    methods (Static, Access = private)
        function table = formattable(table)
            persistent p_table;
            if nargin == 1
                p_table = table;
            end
            table = p_table;
        end
        function str = val2str(format, value)
            str = sprintf(format.Format, value/format.Scale);
        end
    end
end

