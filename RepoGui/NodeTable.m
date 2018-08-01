classdef NodeTable < handle
    %UNTITLED7 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        UiTable
        WaferRepo
        CurrentWaferId
    end
    
    methods
        function this = NodeTable(parent, repo)
            this.UiTable = uitable('Parent', parent);
            this.WaferRepo = repo;
            
            this.UiTable.Data = {'' ''};
            this.UiTable.ColumnWidth = {350 80};
        end
        
        function refresh(this)
            this.WaferRepo.getNode(this.CurrentWaferId, NodeType)
        end
    end
    
end

