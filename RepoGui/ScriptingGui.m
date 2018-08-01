classdef ScriptingGui < handle
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        WaferRepo
        ScriptsDir = '+Scripts';
        Scripts
    end
    
    properties(Access = private)
        SelectedWafers
        UiParent
        UiList
    end
    
    methods
        function this = ScriptingGui(parent, repo)
            this.UiParent = parent;
            this.WaferRepo = repo;
            this.ScriptsDir = fullfile(pwd,'+Scripts');
            this.setup;
            this.update;
        end
        function script = getCurrentScript(this)
            index = this.UiList.Value;
            script = this.Scripts(index);
        end
        function setSelection(this, wafers)
            this.SelectedWafers = wafers;
        end
        function setup(this)
            parent = uiextras.VBox('Parent', this.UiParent, 'Spacing', 4, 'Padding', 10);
            
            hbxTitle = uiextras.HBox('Parent', parent);
            hbxList  = uiextras.HBox('Parent', parent);
            hbxBttns = uiextras.HBox('Parent', parent);
            uiextras.Empty('Parent', parent);
            
            txtTitle      = uicontrol('Parent', hbxTitle, 'Style', 'text', 'FontSize', 10, 'HorizontalAlignment', 'left');
            lstScripts    = uicontrol('Parent', hbxList, 'Style', 'popupmenu', 'String', 'blah');
            btnRunScript  = uicontrol('Parent', hbxBttns, 'Style', 'pushbutton', 'String', 'run');
            btnAddScript  = uicontrol('Parent', hbxBttns, 'Style', 'pushbutton', 'String', 'add...'); 
            btnEdtScript  = uicontrol('Parent', hbxBttns, 'Style', 'pushbutton', 'String', 'edit...');
            %btnRefScr = uicontrol('Parent', hbxBttns, 'Style', 'pushbutton', 'String', 'refresh');

            % Script Controls *****************************************************
            set(parent, 'Heights', [20 25 25 -1]);

            btnRunScript.Callback = @(~,~)this.onRunScipt;
            btnAddScript.Callback = @(~,~)this.onAddScript;
            btnEdtScript.Callback = @(~,~)this.onEditScript;
            %btnUpdate.Callback = @(~,~)this.update();
            
            txtTitle.String = 'Scripts:';
            
            lstScripts.String = 'Select Function';
            this.UiList = lstScripts;
        end
        function update(this)
            this.collect;
            this.UiList.String = {this.Scripts.title};
        end
        function collect(this)
            pack = meta.package.fromName('Scripts');
            names = {pack.FunctionList.Name};
            n = length(names);
            for k = 1:n
                scripts(k) = this.getScriptInfo(names{k});
            end
            this.Scripts = scripts;
        end
    end
    
    methods(Access =  private)
        function script = getScriptInfo(this, scriptname)
            script.name = scriptname;
            script.fullname = ['Scripts.' scriptname];
            script.handle = str2func(script.fullname);
            script.title = scriptname;
            
            helptext = help(script.fullname);
            helplines = strsplit(helptext, '\n');
            n = length(helplines);
            for k = 1:n
                line = helplines{k};
                title = regexpi(line, '#Title: "(.+)"', 'tokens', 'once');
                if ~isempty(title)
                    script.title = title{:};
                    break;
                end
            end
        end
        function onRunScipt(this)
            script = this.getCurrentScript;
            script.handle(this.WaferRepo, this.SelectedWafers);
        end
        function onAddScript(this)
            fcnName = inputsdlg('Name of new custom function:', 'Add Script');
            fcnName = fcnName{:};

            if ~isempty(fcnName)
                file = fullfile(this.ScriptsDir, [fcnName '.m']);

                hFile = fopen(file, 'w');
                fprintf(hFile, '%% New User Script: Enter Title on next line\n');
                fprintf(hFile, '%% #Title: "%s" \n', fcnName);
                fprintf(hFile, '%% Description goes here\n');
                fprintf(hFile, 'function %s(repo, selection)\n\nend', fcnName);
                fclose(hFile);

                edit(file);
                this.update;
            end
        end
        function onEditScript(this)
            script = this.getCurrentScript;
            edit(script.fullname);
        end
    end
    
end

% function collectClasses(this)
%     pkga = meta.package.fromName('Instruments.Analyzers');
%     pkgp = meta.package.fromName('Instruments.Probers');
% 
%     anames = setdiff({pkga.ClassList.Name}, this.analyzers.keys);
%     pnames = setdiff({pkgp.ClassList.Name}, this.probers.keys);
% 
%     for aname = each(anames)
%         wrapper = InstrWrapper('analyzer');
%         wrapper.setClassname(aname);
%         this.analyzers(aname) = wrapper;
%     end
% 
%     for pname = each(pnames)
%         wrapper = InstrWrapper('prober');
%         wrapper.setClassname(pname);
%         this.probers(pname) = wrapper;
%     end
% end