classdef OpsGui < handle
    %OPSGUI Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        OpsStore
        CurrentFiles
        CurrentOperation
    end
    
    properties(Dependent)
        CurrentType
        AvailableOperations
    end
    
    properties(Access = private)
        UiParent
        UiOpsList
        UiRawPlotBtn
        UiResultPlotBtn
        UiMultiPlotBtn
        UiStatusTxt
        UiCalcBtn
        UiExportBtn
        UiSubmitBtn
        UiFcnList
        UiFcnEditBtn
    end
    
    methods
        function this = OpsGui(parent, ops)
            this.UiParent = parent;
            this.OpsStore = ops;
            this.setup;
            this.update;
        end    
        function setup(this)
            parent = uiextras.VBox('Parent', this.UiParent, 'Spacing', 4, 'Padding', 10);
            
            hbxTitle   = uiextras.HBox('Parent', parent);
            hbxList    = uiextras.HBox('Parent', parent);
            hbxBtns1   = uiextras.HBox('Parent', parent);
            hbxBtns2   = uiextras.HBox('Parent', parent);
            pnlStatus  = uipanel(parent, 'Title', 'Status');
            hbxBtns3   = uiextras.HBox('Parent', parent);
                         uiextras.Empty('Parent', parent);
            hbxEdit    = uiextras.HBox('Parent', parent);
                         uiextras.Empty('Parent', parent);
            
            txtTitle       = uicontrol('Parent', hbxTitle, 'Style', 'text', 'FontSize', 11, 'HorizontalAlignment', 'left');
            
            this.UiOpsList          = uicontrol('Parent', hbxList, 'Style', 'popupmenu', 'String', 'blah');
            this.UiRawPlotBtn       = uicontrol('Parent', hbxBtns1, 'Style', 'pushbutton', 'String', 'Plot Data');
            this.UiResultPlotBtn    = uicontrol('Parent', hbxBtns1, 'Style', 'pushbutton', 'String', 'Plot Result');
            this.UiMultiPlotBtn     = uicontrol('Parent', hbxBtns2, 'Style', 'pushbutton', 'String', 'Plot Combined Results');
            %uiextras.Empty('Parent', hbxBtns2);
            %hbxBtns2.Widths = [160, -1];
            
            vbxStatus = uiextras.VBox('Parent', pnlStatus);
            vbxStatus.Padding = 8;
            uiextras.Empty('Parent', vbxStatus);
            this.UiStatusTxt        = uicontrol('Parent', vbxStatus, 'Style', 'text', 'String', 'Nothing Selected', 'FontSize', 10, 'HorizontalAlignment', 'left');
            hbxRecalc = uiextras.HBox('Parent', vbxStatus);
            uiextras.Empty('Parent', hbxRecalc);
            this.UiCalcBtn          = uicontrol('Parent', hbxRecalc, 'Style', 'pushbutton', 'String', 'Re-calculate');
            vbxStatus.Heights = [7 -1 25];
            hbxRecalc.Widths = [-1 100];
            
            this.UiExportBtn        = uicontrol('Parent', hbxBtns3, 'Style', 'pushbutton', 'String', 'Export to File ...');
            this.UiSubmitBtn        = uicontrol('Parent', hbxBtns3, 'Style', 'pushbutton', 'String', 'Export to Repository');

            this.UiFcnList          = uicontrol('Parent', hbxEdit, 'Style', 'popupmenu', 'String', 'blah');
            this.UiFcnEditBtn       = uicontrol('Parent', hbxEdit, 'Style', 'pushbutton', 'String', 'Edit...');
            
            this.UiRawPlotBtn.Callback  	= @(~,~)this.onPlotData();
            this.UiResultPlotBtn.Callback   = @(~,~)this.onPlotResult();
            this.UiMultiPlotBtn.Callback    = @(~,~)this.onMultiPlot();
            this.UiCalcBtn.Callback         = @(~,~)this.onRecalc();
            this.UiExportBtn.Callback       = @(~,~)this.onExportFile();
            this.UiSubmitBtn.Callback       = @(~,~)this.onExportRepo();
            this.UiFcnEditBtn.Callback      = @(~,~)this.onEditFcn();
            this.UiOpsList.Callback         = @(~,~)this.onSelectOperation();
            
            parent.Heights   = [20 25 25 25 90 25 25 23 -1];
            parent.Spacing   = 10;
            hbxBtns1.Spacing = 4;
            hbxBtns3.Spacing = 4;
            hbxEdit.Spacing  = 4;
            hbxStatus.Padding = 10;
            hbxEdit.Widths   = [-1 40];
            
            txtTitle.String = 'Operations';
        end  
        function update(this)
            op = this.CurrentOperation;
            ops = this.OpsStore.getByFileType(this.CurrentType);
            this.setListOperations(ops);
            this.setSelectedOperation(op);
            this.CurrentOperation = this.getSelectedOperation;
            
            if isempty(this.CurrentOperation)
                this.UiRawPlotBtn.Enable = 'off';
                this.UiCalcBtn.Enable = 'off';
                this.UiResultPlotBtn.Enable = 'off';
                this.UiMultiPlotBtn.Enable = 'off';
                this.UiExportBtn.Enable = 'off';
                this.UiSubmitBtn.Enable = 'off';
                this.UiStatusTxt.String = '-';
                this.UiFcnList.String = ' ';
                this.UiFcnList.UserData = '';
                this.UiFcnEditBtn.Enable = 'off';
            else
                op = this.CurrentOperation;
                op.setDataFiles(this.CurrentFiles);
                this.UiRawPlotBtn.Enable = onoff(~isempty(op.RawPlotFcn));
                this.UiCalcBtn.Enable = onoff(~isempty(op.CalculateFcn));
                this.UiResultPlotBtn.Enable = onoff(~isempty(op.ResultPlotFcn));
                this.UiMultiPlotBtn.Enable = onoff(~isempty(op.MultiResultPlotFcn));
                this.UiExportBtn.Enable = onoff(~isempty(op.ExportFcn));
                this.UiSubmitBtn.Enable = onoff(~isempty(op.SubmitFcn));
                this.UiFcnEditBtn.Enable = 'on';
                this.setListFunctions;
                
                if isempty(this.CurrentFiles)
                    this.UiStatusTxt.String = 'Nothing Selected';
                elseif all(this.CurrentOperation.resultAvailable)
                    this.UiStatusTxt.String = 'Result Available';
                elseif all(this.CurrentOperation.cacheFileAvailable)
                    this.UiStatusTxt.String = 'Result Available (Cached)';
                else
                    this.UiStatusTxt.String = 'Data Available';
                end
            end
        end
        
        function setFiles(this, files)
            this.CurrentFiles = files;
            if ~isempty(this.CurrentOperation)
                this.CurrentOperation.setDataFiles(files);
            end
        end        
        function type = get.CurrentType(this)
            if ~isempty(this.CurrentFiles)
                type = this.CurrentFiles(1).Type.ID;
            else
                type = '';
            end
        end
    end
    
    methods(Access = private)
        function onPlotData(this)
            this.CurrentOperation.rawPlot;
        end
        function onPlotResult(this)
            if ~all(this.CurrentOperation.resultAvailable)
                this.UiStatusTxt.String = 'Working... please wait';
                this.CurrentOperation.calculate;
                this.UiStatusTxt.String = 'Result Available';
            end
            this.CurrentOperation.resultPlot;
        end
        function onMultiPlot(this)
            if ~all(this.CurrentOperation.resultAvailable)
                this.UiStatusTxt.String = 'Working... please wait';
                this.CurrentOperation.calculate;
                this.UiStatusTxt.String = 'Result Available';
            end
            this.CurrentOperation.multiResultPlot;
        end
        function onRecalc(this)
            this.UiStatusTxt.String = 'Working... pleas wait';
            this.CurrentOperation.recalculate;
            this.UiStatusTxt.String = 'Result Available';
        end
        function onExportFile(this)
            this.CurrentOperation.export;
        end
        function onExportRepo(this)
            this.CurrentOperation.submit;
            msgbox('Data Exported to Wafer Repository.', 'Exportd', 'modal');
        end
        function onEditFcn(this)
            fcnname = this.getSelectedFunction;
            op = this.CurrentOperation;
            if ~isempty(op)
                fcn = op.(fcnname);
                
                if ~isempty(fcn)
                    fcnstr = func2str(fcn);
                    edit(fcnstr);
                else
                    msg = 'No %s has been defined for %s.';
                    msg = sprintf(msg, fcnname, op.Name);
                    msgbox(msg, 'Edit Function', 'modal');
                end
            end
        end
        
        function onSelectOperation(this)
            op = this.getSelectedOperation;
            this.CurrentOperation = op; %should not trigger ui update;
            this.update;
        end
        function op = getSelectedOperation(this)
            index = this.UiOpsList.Value;
            opnames = this.UiOpsList.UserData;
            if index < 1 || index > length(opnames)
                op = Operations.Operation.empty;
            else
                opname = opnames(index);
                op = this.OpsStore.getByName(opname);
                op.setDataFiles(this.CurrentFiles);
            end
        end
        function setSelectedOperation(this, op)
            if isempty(op)
                this.UiOpsList.Value = 1;
            else
                opnames = this.UiOpsList.UserData;
                i = strcmp(op.Name, opnames);
                if any(i)
                    this.UiOpsList.Value = find(i,1);
                else
                    this.UiOpsList.Value = 1;
                end
            end
        end
        function setListOperations(this, ops)
            if ~isempty(ops)
                opnames = {ops.Name};
                optitles = {ops.Title};
                this.UiOpsList.String = optitles;
                this.UiOpsList.UserData = opnames;
            else
                this.UiOpsList.String = '<no operations available>';
                this.UiOpsList.UserData = '';
            end
        end
        
        function setListFunctions(this)
            op = this.CurrentOperation;
            
            fcns = {'RawPlotFcn' 'CalculateFcn' 'ResultPlotFcn' ...
                'MultiResultPlotFcn' 'ExportFcn' 'SubmitFcn'};
            n = length(fcns);
            
            items = {};
            for k = 1:n
                items{k} = fcns{k};
            end
            this.UiFcnList.String = items;
            this.UiFcnList.UserData = fcns;
        end
        function fcn = getSelectedFunction(this)
            index = this.UiFcnList.Value;
            fcnnames = this.UiFcnList.UserData;
            if index > 0 || index <= length(fcnnames)
                fcn = fcnnames{index};
            else
                fcn = '';
            end
        end
    end
end

