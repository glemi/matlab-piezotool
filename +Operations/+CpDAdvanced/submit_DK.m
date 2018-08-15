function submit_DK(info,result,repo)
    
    if length(unique({info.WaferID})) > 1
        error('All sample data must be from the same wafer');
    end
    
    pos = mean([info.Position]);
    
    wafer = info(1).WaferID; 
    node = repo.getNode(wafer, 'diel2');        
    
    node.add('eps10k', pos, result.eps10k);  
    node.add('c10k',   pos, result.c10k);
    node.add('D10k',   pos, result.D10k);
    
    node.add('eps20k', pos, result.eps20k);  
    node.add('c20k',   pos, result.c20k);
    node.add('D20k',   pos, result.D20k);
    
    node.add('eps40k', pos, result.eps40k);  
    node.add('c40k',   pos, result.c40k);
    node.add('D40k',   pos, result.D40k);
    
    node.add('dR',     pos, median(result.deltaR));
    node.add('sC',     pos, median(result.slope));
    
    node.write();
end

