classdef FileTable < handle
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = private)
        UiTable
        JTable
        FileStash
    end
    
    properties
        SelectedFiles
        SelectedRows
        SelectionChangeFcn
    end
    
    methods
        function this = FileTable(parent, stash)
            this.UiTable = uitable('Parent', parent);
            this.FileStash = stash;
            this.adjustJTableProperties;
            
            this.UiTable.ColumnName = {'File Name' 'Wafer ID' 'Sample ID' 'Position'};
            this.UiTable.Data = {'' '' ''};
            %this.UiTable.ColumnWidth = {this.UiTable.InnerPosition(3)-40};
            this.UiTable.CellSelectionCallback = @(~,e)this.onCellSelect(e);
            
            
            tablemenu = uicontextmenu;
            uimenu(tablemenu, 'Label', 'Remove', 'Callback', @(~,~)this.onRemoveFiles);
            uimenu(tablemenu, 'Label', 'Clear', 'Callback', @(~,~)this.onClearFiles);
            uimenu(tablemenu, 'Label', 'Open Config File', 'Callback', @(~,~)this.onOpenConfigFile);
            set(this.UiTable, 'UiContextMenu', tablemenu);
        end
        function refresh(this)
            n = length(this.FileStash.Files);
            data = cell(n,3);
            for k = 1:n
                file = this.FileStash.Files(k);
                data{k,1} = file.FileName;
                data{k,2} = file.Info.WaferID;
                data{k,3} = file.Info.SampleID;
                data{k,4} = file.Info.Position;
            end
            
            this.UiTable.Data = data;
            this.SelectedFiles = DataFile.empty;
            this.SelectedRows = [];
            this.UiTable.ColumnWidth = {200 100 80};
            %this.UiTable.ColumnName = [{'wafer'} header];
            %this.UiTable.ColumnWidth = {this.UiTable.InnerPosition(3)-40};
        end
    end
    
    
    methods(Access = private)
        function adjustJTableProperties(this)
            %Obtain JTable Object
            jscrollpane = findjobj(this.UiTable, 'class', 'UIScrollPane');
            jtable = jscrollpane.getViewport.getView;
            
            this.JTable = jtable;

            %Fix Selection Problem
            set(jtable, 'MousePressedCallback', @this.onTableClick);
            
            %Enable Sorting
            jtable.setSortable(true);
            jtable.setAutoResort(true);
            jtable.setMultiColumnSortable(true);
            jtable.setPreserveSelectionsAfterSorting(true);
        end
        function onTableClick(this, table, event)
            point = event.getPoint;
            jtable = event.getSource;
            row = jtable.rowAtPoint(point);
            col = jtable.columnAtPoint(point);
            
            if bitand(event.CTRL_MASK, event.getModifiers)
                return;
            end
            
            if jtable.isCellSelected(row, col)
                jtable.changeSelection(row, col, false, true);
            else
                jtable.changeSelection(row, col, false, false);
            end
        end
        function onCellSelect(this, eventdata)
            if length(eventdata.Indices) < 2
                return;
            end
            rows_sorted = unique(eventdata.Indices(:,1))-1;
            
            n = length(rows_sorted);
            for k = 1:n
                rows_actual(k) = this.JTable.getActualRowAt(rows_sorted(k));
            end
            rows = rows_actual + 1;
            
            files = this.FileStash.Files(rows);
            this.SelectedFiles = files;
            this.SelectedRows = rows;
            this.SelectionChangeFcn(files);
        end
        function onRemoveFiles(this)
            this.FileStash.remove(this.SelectedRows)
            this.refresh;
        end
        function onClearFiles(this)
            this.FileStash.clear;
            this.refresh;
        end
        function onOpenConfigFile(this)
            file = this.SelectedFiles(1).Info.Config.filepath;
            Auxilary.sysopen(file, 'notepad++');
        end
    end
    
end

