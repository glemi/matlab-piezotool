classdef DataGui < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        FileStash;
        Operations;
        FileBrowser;
        
        Figure;
        FileTable;
        InputTree;
        OpsGui;
        App;
    end
    
    methods
        function this = DataGui(app)
            this.App = app;
            this.FileStash = FileStash(app.InputDir);
            this.FileBrowser = FileBrowser(app.InputDir);
            this.Operations = Operations.Store;
        end
        function delete(this)
            %Destructor
            %save datagui this;
        end
        
        function setup(this, parent)
            if nargin < 2
                this.Figure = fig('Data GUI'); clf;
                this.Figure.ToolBar = 'none';
                this.Figure.MenuBar = 'none';
                parent = this.Figure;
            end
                 
            pnlMain   = uiextras.HBoxFlex('Parent', parent, 'Spacing', 4, 'Padding', 3);
            
            pnlLeft   = uiextras.VBox('Parent', pnlMain);
            pnlCenter = uiextras.VBox('Parent', pnlMain);
            pnlRight  = uiextras.VBox('Parent', pnlMain);
            
            pnlMain.Widths = [-3 -6 250];
            
            this.InputTree = InputTree(pnlLeft, this.FileBrowser); %#ok<*CPROP>
            this.FileTable = FileTable(pnlCenter, this.FileStash);
            this.OpsGui    = OpsGui(pnlRight, this.Operations);
            
            this.InputTree.AddFilesFcn = @this.onAddFiles;
            this.InputTree.OpenExplorerFcn = @this.onOpenExplorer;
            this.InputTree.OpenExternalFcn = @this.onOpenExternal;
            this.InputTree.OpenNotepadFcn = @this.onOpenNotepad;
            this.InputTree.ConcatenateS1pFcn = @this.onConcatenate;
            
            this.FileTable.SelectionChangeFcn = @this.onFileSelection;
            
            this.update();
        end
        
        function update(this)
            if ~strcmp(this.FileBrowser.RootDir, this.App.InputDir)
                this.FileBrowser.RootDir = this.App.InputDir;
                this.FileStash.RootDir = this.App.InputDir;
                this.InputTree.refresh;
                this.FileStash.clear();
            end
            this.Operations.update();
            this.FileTable.refresh();
            this.OpsGui.update;
        end
        
        function onFileSelection(this, files)
           	%disp(files);
            info = [files.Info];%clc;
            %disp({info.FileName}');
            %disp({info.MIndex});
            this.OpsGui.setFiles(files);
            this.OpsGui.update();
        end
        
        function onAddFiles(this, files)
            this.FileStash.add(files);
            this.FileTable.refresh();
        end
        function onOpenExplorer(this, file)
            file = Auxilary.file2str(file);
            if isdir(file)
                Auxilary.sysopen(file);
            else
                folder = fileparts(file);
                Auxilary.sysopen(folder);
            end
        end
        function onOpenNotepad(this, file)
            Auxilary.sysopen(file, 'notepad++');
        end
        function onOpenExternal(this, file)
            Auxilary.sysopen(file);
        end
        function onConcatenate(this, file)
        
        end
    end
    
end

