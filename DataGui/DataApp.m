classdef DataApp < handle
    %DATAAPP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        WaferRepo
        FileStash
    end
    
    properties(SetAccess = private)
        WorkingDir = '';
        InputDir = '';
        OutputDir = '';
        ParamDir = '';
        CacheDir = '';
        RepoDir = '';
    end
    
    methods
        function this = DataApp()
            this.WaferRepo = WaferRepo;
            this.loadState;
            DataApp.instance(this);
        end
        
        function setWorkingDir(this, workingdir)
            if this.setworkingdir(workingdir)
                this.saveState;
            end
        end
        function setInputDir(this, inputdir)
            if this.setinputdir(inputdir)
                this.saveState;
            end
        end
        
        function loadState(this)
             try 
                load datagui;
                this.setworkingdir(workingdir);
                this.setinputdir(inputdir);
             catch err
                 msgtxt = 'Please select the data and work directories (Menu File...)';
                 waitfor(msgbox(msgtxt, 'Configure Directories', 'modal'));
             end
        end
        function saveState(this)
            workingdir = this.WorkingDir;
            inputdir = this.InputDir;
            save datagui workingdir inputdir;
        end
    end
    
    methods(Access = private)
        function ok = setworkingdir(this, workingdir)
            this.WorkingDir = workingdir;
            this.OutputDir = fullfile(workingdir, 'Output');
            this.ParamDir = fullfile(workingdir, 'Parameters');
            this.CacheDir = fullfile(workingdir, 'Cache');
            this.RepoDir = fullfile(workingdir, 'Repository');
            this.WaferRepo.setRootDir(this.RepoDir);
            if exist(workingdir, 'file')
                warning off MATLAB:MKDIR:DirectoryExists;
                mkdir(this.OutputDir);
                mkdir(this.ParamDir);
                mkdir(this.CacheDir);
                mkdir(this.RepoDir);
                ok = true;
            else
                ok = false;
            end
        end
        function ok = setinputdir(this, inputdir)
            this.InputDir = inputdir;
            ok = exist(inputdir, 'file');
        end
    end
    
    methods(Static)
        function instance = instance(instance)
           persistent p_instance
           if nargin == 1
               p_instance = instance;
           end
           instance = p_instance;
        end
    end
end

