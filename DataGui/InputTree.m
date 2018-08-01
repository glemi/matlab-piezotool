classdef InputTree < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Parent
        RootNode
        FileBrowser
        
        AddFilesFcn
        OpenExplorerFcn
        OpenExternalFcn
        OpenNotepadFcn
        ConcatenateS1pFcn
    end
    
    properties(Access = private)
        Tree
        Container
        Panel
    end
    
    methods
        function this = InputTree(parent, filebrowser)
            this.FileBrowser = filebrowser;
            rootdir = filebrowser.RootDir;
            if ~isdir(rootdir)
                rootdir = 'Plese select an Input Directory';                
            end
            
            [tree, container] = uitree('v0', 'Root', rootdir, ...
                'SelectionChangeFcn', @this.onTreeSelection, ...
                'ExpandFcn', @(~,p)this.onNodeExpand(p));
            
            this.Tree = tree;
            this.Container = container;
         
            rootnode = tree.getRoot;
            [~,name] = fileparts(rootnode.getValue);
            rootnode.setName(name);
            rootnode.setAllowsChildren(true);
            rootnode.setLeafNode(false);
            tree.expand(rootnode);
            
            uiTreeContextMenu(tree, @this.onCreateContextMenu);

            this.Panel = uipanel('Parent', parent, 'BorderType', 'line', 'BorderWidth', 0);
            container.Parent = this.Panel;
            container.Units = 'normalized';
            container.Position = [0 0 1 1];
            container.ButtonDownFcn = @(~,~)set(gcf,'Pointer','arrow');
        end
        
        function refresh(this, node)
            %https://ch.mathworks.com/matlabcentral/answers/56201-dynamic-uitree-from-database

            if nargin < 2
                node = this.Tree.getRoot;
                path = this.FileBrowser.RootDir;
            else
                path = node.getValue;
            end
            
            node.removeAllChildren;
            nodes = this.onNodeExpand(path);

            n = length(nodes);
            for k = 1:n
                node.add(nodes(k));
            end
            this.Tree.reloadNode(node);
            this.Tree.expand(node);
        end
        
        function reset(this)
            
        end
    end
    
    methods(Access = private)
        function nodes = onNodeExpand(this, path)
            
            files = this.FileBrowser.getFiles(path);
            folders = this.FileBrowser.getSubfolders(path);
            
            items = [files; folders];
            [items.folder] = deal(path);
            
            n = length(items);
            for k = 1:n
                nodes(k) = this.createNode(items(k));
                schema.prop(nodes(k), 'UserData', 'MATLAB array');
            end
            
            if (n == 0)
                nodes = [];
            end
        end
        
        function node = createNode(this, file)
            import com.mathworks.hg.peer.UITreeNode;
            % file is a struct as returned by dir()
            filepath = fullfile(file.folder, file.name);
            iconpath = this.getIconPath(filepath);
            isleaf = ~file.isdir;

            node = handle(UITreeNode(filepath, file.name, iconpath, isleaf));
        end
        
        function onTreeSelection(this, ~, value)
            node = getCurrentNode(value);
            parent = getParent(node);
            
            file = node.getValue;
            type = this.FileBrowser.TypeStore.classify(file);
            file = DataFile(file, type);
            %file.Info
            
            set(gcf,'Pointer','arrow');
        end
        
        function [labels, callbk] = onCreateContextMenu(this, tree, node, menu)
            file = node.getValue();
            files = this.FileBrowser.getFiles(file);

            if isdir(file)
                folder = file;
                
                callbk{1} = @()this.onMenuClick('add_stash', files);
                labels{1} = 'Add all Files in Folder';
                
                callbk{2} = @()this.onMenuClick('open_explorer', folder); 
                labels{2} = 'Open Folder in Explorer';
                
                callbk{3} = @()this.onMenuClick('concatenate', folder);
                labels{3} = 'Concatenate s1p Files';
                
                callbk{4} = 0;
                labels{4} = '-';
                
                callbk{5} = @()this.refresh(node);
                labels{5} = 'Refresh';
                
            else
                callbk{1} = @()this.onMenuClick('add_stash', files);
                labels{1} = 'Add File to Stash';
                
                callbk{2} = @()this.onMenuClick('open_external', files);
                labels{2} = 'Open with External Viewer';
                
                callbk{3} = @()this.onMenuClick('open_notepad', files);
                labels{3} = 'Open in Notepad';
                
                callbk{4} = @()this.onMenuClick('open_explorer', files);
                labels{4} = 'Show in Explorer';
                
                callbk{5} = 0;
                labels{5} = '-';
                
                callbk{6} = @()this.refresh(node);
                labels{6} = 'Refresh';
            end
        end
        
        function onMenuClick(this, command, files)
            switch command
                case 'add_stash',       this.AddFilesFcn(files);
                case 'open_explorer',   this.OpenExplorerFcn(files);
                case 'open_external',   this.OpenExternalFcn(files);
                case 'open_notepad',    this.OpenNotepadFcn(files);
            end
        end
        
        function iconpath = getIconPath(this, file)
            icondir = [matlabroot, '/toolbox/matlab/icons/'];
            
            [~,~,ext] = fileparts(file);
            
            if isdir(file)
                iconfile = 'foldericon.gif';
            else
                switch ext
                    case 'bdl', iconfile = 'HDF_VGroup.gif';
                    case 'pdf', iconfile = 'pdficon.gif';
                    otherwise,  iconfile = 'pageicon.gif';
                end
            end
            iconpath = [icondir, iconfile];
        end
    end
       
end

