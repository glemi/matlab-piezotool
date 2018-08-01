classdef WaferTable < handle
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = private)
        UiTable
        WaferRepo
    end
    
    properties
        Selection
        SelectedWafer
        SelectedNode
    end
    
    events
        SelectionChanged
    end
    
    methods
        function this = WaferTable(parent, repo)
            this.UiTable = uitable('Parent', parent);
            this.WaferRepo = repo;
            
            this.UiTable.Data = {''};
            %this.UiTable.ColumnWidth = {this.UiTable.InnerPosition(3)-40};
            this.UiTable.CellSelectionCallback = @(~,e)this.onCellSelect(e);
        end
        function refresh(this)
            this.WaferRepo.update;
            wafers = this.WaferRepo.NodeTable.Properties.RowNames(:);
            nodes  = table2cell(this.WaferRepo.NodeTable);
            
            for k = 1:length(wafers)
                sc = this.WaferRepo.getData(wafers{k}, 'master.ScContent');
                if isnan(sc)
                    scstr{k,1} = '';
                else
                    scstr{k,1} = sprintf('%.1f%%', sc);
                end
            end
            
            function chk = setchk(x)
                if x; chk = {'&#10003;'}; else; chk = {' '}; end
            end
            html = '<html><tr><td align=center width=999>';
            nodes = cellfun(@setchk, nodes);
            nodes = strcat(html, nodes);
            scstr = strcat(html, scstr);
            
            header = this.WaferRepo.NodeTable.Properties.VariableNames;
            header = [{'Sc'} header];
            
            this.UiTable.Data = [wafers scstr nodes];
            this.UiTable.ColumnName = [{'wafer'} header];
            this.UiTable.ColumnWidth = [{'auto' 'auto'}  num2cell(40*ones(1,size(nodes,2)))];
        end
        function onCellSelect(this, eventdata)
            if length(eventdata.Indices) < 2
                return;
            end
            row  = eventdata.Indices(1,1);
            col  = eventdata.Indices(1,2);
            rows = unique(eventdata.Indices(:,1));
            
            this.Selection = this.UiTable.Data(rows, 1);
            
            this.SelectedNode = this.UiTable.ColumnName{col};
            this.SelectedWafer = this.UiTable.Data{row, 1};
            
            notify(this, 'SelectionChanged');
        end
    end
    
end

