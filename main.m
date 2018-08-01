function main 
    init;
    
    addpath DataGui RepoGui WaferRepo
    warning off;
    
    app = DataApp();
    gui = ComboGui(app);
    gui.setup();
end

