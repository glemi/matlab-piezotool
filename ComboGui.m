classdef ComboGui < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        App
        DataGui
        RepoGui
        Figure
    end
    
    methods
        function this = ComboGui(app)
            this.App = app;
            this.DataGui = DataGui(app);
            this.RepoGui = RepoGui(app);
        end
        
        function setup(this)
            this.Figure = fig('Combo GUI'); clf;
            this.Figure.ToolBar = 'none';
            this.Figure.MenuBar = 'none';
            
            mnuFile = uimenu(this.Figure, 'Label', 'File');
            uimenu(mnuFile, 'Label', 'Change Input Directory...', 'Callback', @(~,~)this.onChangeInputDir);
            uimenu(mnuFile, 'Label', 'Change Working Directory...', 'Callback', @(~,~)this.onChangeWorkingDir);
            
            uimenu(mnuFile, 'Label', 'Open Input Directory...', 'Callback', @(~,~)winopen(this.App.InputDir), 'Separator', 'on');
            uimenu(mnuFile, 'Label', 'Open Working Directory...', 'Callback', @(~,~)winopen(this.App.WorkingDir));
            uimenu(mnuFile, 'Label', 'Refresh', 'Callback', @(~,~)this.onRefresh, 'Separator', 'on');
            uimenu(mnuFile, 'Label', 'Restart', 'Callback', @(~,~)this.onRestart);

            tbgMain = uitabgroup(this.Figure, 'Position', [0 0 1 1]);
            tabData = uitab(tbgMain, 'Title', 'Data Evaluation');
            tabRepo = uitab(tbgMain, 'Title', 'Repository');
            
            this.DataGui.setup(tabData);
            this.RepoGui.setup(tabRepo);
        end
        
        function onChangeInputDir(this)
            currentdir = this.DataGui.FileBrowser.RootDir;
            newdir = uigetdir(currentdir, 'Select Input Directory');
            if ~isnumeric(newdir)
                this.App.setInputDir(newdir);
                this.DataGui.update;
            end
        end
        function onChangeWorkingDir(this)
            currentdir = this.DataGui.FileBrowser.RootDir;
            newdir = uigetdir(currentdir, 'Select Working Directory');
            if ~isnumeric(newdir)
                this.App.setWorkingDir(newdir);
                this.RepoGui.update;
            end
        end
        function onRestart(this)
            clf(this.Figure);
            main;
        end
        function onRefresh(this)
            this.DataGui.update;
            this.RepoGui.update;
        end
    end
    
end

