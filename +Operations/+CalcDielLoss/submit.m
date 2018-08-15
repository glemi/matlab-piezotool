function submit(info,result,repo)
    
    if length(unique({info.WaferID})) > 1
        error('All sample data must be from the same wafer');
    end
    
    pos  =  [info.Position]';
    D0   =  [result.D0   ]';
    D10k =  [result.D10k ]';
    D20k =  [result.D20k ]';
    D40k =  [result.D40k ]';
    GpA  =  [result.GpA  ]';
    Rs   =  [result.Rs   ]';
    
    wafer = info(1).WaferID; 
    node = repo.getNode(wafer, 'dloss');        
    
    node.add('DFit',   pos, D0);
    node.add('D10k',   pos, D10k);
    node.add('D20k',   pos, D20k);
    node.add('D40k',   pos, D40k);
    node.add('Gp',     pos, GpA);
    node.add('Rs',     pos, Rs);

    node.write();
end

