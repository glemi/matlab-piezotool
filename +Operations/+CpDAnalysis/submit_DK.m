function submit_DK(info,result,repo)
    
    if length(unique({info.WaferID})) > 1
        error('All sample data must be from the same wafer');
    end
    
    pos = mean([info.Position]);
    
    %rootdir = 'C:\Users\Nyffeler\switchdrive\AlScN_project\Analysis\Matlab\Repo';
    wafer = info(1).WaferID; 
    node = repo.getNode(wafer, 'diel');        
    
    node.add('eps10k', pos, result.eps10k);  
    node.add('c10k',   pos, result.c10k);
    node.add('D10k',   pos, result.D10k);
    node.add('dR',     pos, median(result.deltaR));

    node.write();
end

