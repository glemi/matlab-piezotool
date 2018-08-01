classdef WaferRepo < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        RootDir = '';
        WaferIds = {};
        NodeTable = table;
        MasterNode;
    end
    
    methods
        function this = WaferRepo(rootdir)
            if nargin > 0
                this.RootDir = rootdir;
                this.instance(this);
            end
        end
        function node = getNode(this, WaferId, NodeType)
            if nargin < 3 || strcmpi(NodeType, 'master') || strcmpi(NodeType, 'wafer')
                node = WaferMasterNode(this, WaferId);
            else
                i = strfind(NodeType, '.');
                if any(i)
                    NodeType = NodeType(1:i-1);
                end
                node = WaferDataNode(this, WaferId, NodeType);
            end
        end
        function data = getData(this, waferid, dataref, varname)
            if nargin < 4
                parts = strsplit(dataref, '.');
                noderef = parts{1};
                dataref = parts{2};
            else
                noderef = dataref;
                dataref = varname;
            end
            node = this.getNode(waferid, noderef);
            data = node.get(dataref);
        end
        function nodes = listNodes(this, WaferId)
            if nargin < 2
                nodes = this.NodeTable.Properties.VariableNames;
            else
                i = logical(this.NodeTable{WaferId,:});
                nodes = this.NodeTable.Properties.VariableNames(i);
            end
        end
        function wafers = listWafers(this, NodeType)
            if nargin < 2
                wafers = this.NodeTable.Properties.RowNames;
            else
                i = logical(this.NodeTable{:,NodeType});
                wafers = this.NodeTable.Properties.RowNames(i);
            end
        end
        function setRootDir(this, repodir)
            this.RootDir = repodir;
            this.update();
            this.instance(this);
        end
        function update(this)
            files = dir(this.RootDir);
            i = [files.isdir];
            folders = files(i);
            names = {folders.name};
            i = this.checkWaferId(names);
            this.WaferIds = names(i);

            n = sum(i);
            for k = 1:n
                waferid = this.WaferIds{k} ;
                filter = fullfile(this.RootDir, waferid, '*.node.csv');
                files = dir(filter);
                filenames = {files.name};
                nodes = strrep(filenames, '.node.csv', '');
                %Scstr = sprintf('%.1f%%', this.getData(waferid, 'master.ScContent'));
                %this.NodeTable{waferid, 'Sc'} = {Scstr};
                this.NodeTable{waferid, nodes} = true;
            end
        end
    end
    
    methods(Static)
        function tf = checkWaferId(WaferIds)
            expr = '[A-Z]+_(box)?(\d+|[A-Z])_(Si|Mo|Pt)?_?\d+';
            match = regexp(WaferIds, expr);
            tf = cellfun(@any, match);
        end
%         function repodir = repoDir(repodir)
%             % if you uncomment this you have to update this.setRepoDir
%             % also to update the static variable
%             persistent p_repodir;
%             if nargin == 1
%                 p_repodir = repodir;
%             end
%             repodir = p_repodir;
%         end
        function instance = instance(instance)
           persistent p_instance
           if nargin == 1
               p_instance = instance;
           end
           instance = p_instance;
        end
    end
end

