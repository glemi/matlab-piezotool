function submit_e31(info, results, repo)
    [~, i] = sort([info.Position]);
    results = results(i);
    info    = info(i);
    
    e31 = -[results.e31_matlab];
    De31 = [results.e31_error];
   
    pos    = [info.Position]';
    e31    =-[results.e31_matlab]';
    delta  = [e31-De31' e31+De31'];
    slope  = [results.slope]';
    
    if length(unique({info.WaferID})) > 1
        error('All sample data must be from the same wafer');
    end

    wafer = info(1).WaferID;
    node = repo.getNode(wafer, 'e31');
    
    node.add('e31', pos, e31, delta);
    node.add('slope', pos, slope);
    node.write();
end
