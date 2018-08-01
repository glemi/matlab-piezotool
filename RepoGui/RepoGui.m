classdef RepoGui < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Figure;
        WaferRepo;
        WaferTable;
        ScriptingGui;
        DataTable;
        App;
    end
    
    methods
        function this = RepoGui(app)
            this.WaferRepo = app.WaferRepo;
            this.App = app;
        end
        
        function setup(this, parent)
            if nargin < 2
                this.Figure = fig('WaferRepo GUI'); clf;
                this.Figure.ToolBar = 'none';
                this.Figure.MenuBar = 'none';
                
                mnuFile = uimenu(this.Figure, 'Label', 'File');
                uimenu(mnuFile, 'Label', 'Change Root Directory...', 'Callback', @(~,~)onChangeRootDir, 'Separator', 'on');
                uimenu(mnuFile, 'Label', 'Open Root Directory...', 'Callback', @(~,~)winopen(this.WaferRepo.RootDir));
                uimenu(mnuFile, 'Label', 'Refresh', 'Callback', @(~,~)this.update(), 'Separator', 'on');
                uimenu(mnuFile, 'Label', 'Restart', 'Callback', @(~,~)RepoMain, 'Separator', 'on');
                
                parent = this.Figure;
            end

            pnlMain   = uiextras.HBoxFlex('Parent', parent, 'Spacing', 4, 'Padding', 3);
            pnlLeft   = uiextras.VBox('Parent', pnlMain);
            pnlCenter = uiextras.VBox('Parent', pnlMain);
            pnlRight  = uiextras.VBox('Parent', pnlMain);
            
            pnlMain.Widths = [-3 -6 250];
            
            this.WaferTable = WaferTable(pnlLeft, this.WaferRepo); %#ok<*CPROP>
            this.DataTable = DataTable(pnlCenter, this.WaferRepo);
            this.ScriptingGui = ScriptingGui(pnlRight, this.WaferRepo);
            
            addlistener(this.WaferTable, 'SelectionChanged', @(~,~)this.onWaferSlectionChange);
            
            this.update();
        end
        
        function update(this)
            this.WaferRepo = this.App.WaferRepo;
            this.WaferTable.refresh();
            this.DataTable.clear();
            this.ScriptingGui.update();
        end
        
        function highlight(this, waferid, nodetype)
            this.DataTable.WaferId = waferid;
            this.DataTable.NodeType = nodetype;
            this.DataTable.refresh();
        end
        
        function onWaferSlectionChange(this)
            this.DataTable.WaferId = this.WaferTable.SelectedWafer;
            this.DataTable.NodeType = this.WaferTable.SelectedNode;
            this.DataTable.refresh();
            this.ScriptingGui.setSelection(this.WaferTable.Selection);
        end
    end
    
end

