classdef DataTable < handle
    %UNTITLED7 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        UiTable
        WaferRepo
        WaferId
        NodeType
        Node
        Formatter
    end
    
    methods
        function this = DataTable(parent, repo)
            this.UiTable = uitable('Parent', parent);
            this.UiTable.CellEditCallback = @this.onEditCell;
            this.WaferRepo = repo;
            
            this.UiTable.Data = {'No Wafer Selected'};
            %this.UiTable.ColumnWidth = {350 80};
            this.Formatter = Formatter(repo);
        end
        
        function clear(this)
            this.WaferId = '';
            this.NodeType = '';
            this.UiTable.Data = {'No Wafer Selected'};
        end
        function refresh(this)
            this.Node = this.WaferRepo.getNode(this.WaferId, this.NodeType);
            dtable = this.Node.DataTable;
            names = dtable.Properties.VariableNames;
            this.UiTable.CellEditCallback = @this.onEditCell;
            try
                switch this.NodeType 
                    case 'wafer'
                        this.UiTable.Data = table2cell(dtable(this.WaferId,:))';
                        this.UiTable.RowName = names;
                        this.UiTable.ColumnName = 'Value';
                    otherwise
                        ftable = this.Formatter.formatTable(dtable);
                        ftable = [dtable(:,1) ftable(:,2:end)];
                        this.UiTable.Data = table2cell(ftable);
                        this.UiTable.ColumnName = names;
                        this.UiTable.RowName = 'numbered';
                end
                this.UiTable.ColumnEditable = [true false(1,length(names)-1)];
                
                %this.UiTable.Data = cellfun(@(x)sprintf('%.1f',x), this.UiTable.Data, 'UniformOutput', false);
            catch err
                errdisp(err);
                this.UiTable.Data = {};
            end
        end
    end
    
    methods(Access = private)
        function onEditCell(this, s,e)
            index = e.Indices(1);
            newState = logical(e.NewData);
            this.Node.DataTable{index,'Enabled'} = newState;
            this.Node.write;
        end
    end
    
end

