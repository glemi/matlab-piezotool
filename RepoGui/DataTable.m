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
        Selection
    end
    
    methods
        function this = DataTable(parent, repo)
            this.UiTable = uitable('Parent', parent);
            this.UiTable.CellEditCallback = @this.onEditCell;
            this.WaferRepo = repo;
            
            this.UiTable.Data = {'No Wafer Selected'};
            %this.UiTable.ColumnWidth = {350 80};
            this.Formatter = Formatter(repo);
            
            tablemenu = uicontextmenu;
            uimenu(tablemenu, 'Label', 'Copy Selected', 'Callback', @(~,~)this.onCopySelectedCells);
            uimenu(tablemenu, 'Label', 'Copy Entire Table', 'Callback', @(~,~)this.onCopyEntireTable);
            uimenu(tablemenu, 'Label', 'Delete Rows', 'Callback', @(~,~)this.onDeleteRows);
            this.UiTable.UIContextMenu = tablemenu;
            this.UiTable.CellSelectionCallback = @(~,e)this.onCellSelect(e.Indices);
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
            i = contains(names, {'_lo' '_hi'});
            dtable(:,i) = [];
            names(i) = [];
            
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
        function onEditCell(this,s,e)
            index = e.Indices(1);
            newState = logical(e.NewData);
            this.Node.DataTable{index,'Enabled'} = newState;
            this.Node.write;
        end
        function onCellSelect(this, indices)
            this.Selection = indices;
        end
        function onCopySelectedCells(this)
            indices = this.Selection;
            rows = unique(indices(:,1));
            cols = unique(indices(:,2));
            data = this.Node.DataTable(rows, cols);
            Auxilary.table2clip(data, 'withheaders');
        end
        function onCopyEntireTable(this)
            data = this.Node.DataTable;
            Auxilary.table2clip(data, 'withheaders');
        end
        function onDeleteRows(this)
            indices = this.Selection;
            rows = unique(indices(:,1));
            if isempty(rows)
                return;
            end
            
            msg = ['Delete Rows %d-%d: Are you sure? Note that this ' ...
                 'cannot be undone, other than recomputing the values ' ... 
                 'from the original measurement files. \n\nYou ' ...
                 'can also uncheck the "Enabled" box to exclude ' ... 
                 'data from any plots or computations.'];
            msg = sprintf(msg, min(indices(:,1)), max(indices(:,1)));
            title = 'Delete Rows';
            options.Default = 'Cancel';
            options.IconString = 'warn';
            answer = buttondlg(msg, title, 'Yes', 'Cancel', options);
            
            if strcmpi(answer, 'yes')
                this.Node.DataTable(rows,:) = [];
                this.Node.write;
                this.refresh;
            end
        end
    end
    
end

