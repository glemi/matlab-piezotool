function submit_stress(info, data, repo)
    
    data = data.stress;
    wafers = data.Properties.VariableNames(3:end);
    i_int = ~strncmpi('Var', wafers, 3);
    wafers = wafers(i_int);
    
    angle  = data{:,'Angle'};
    radius = data{:,'R'};
    
    range = max(radius) - min(radius);
    if length(radius) > 10*range
        i_int = (round(radius) == radius);
        i_int = diff([0; i_int]) > 0;
    else 
        i_int = ones(size(radius));
    end
    
    n = length(wafers);
    for k = 1:n
        wafer = wafers{k};
        i_CE = (angle == 0) & (radius > 0) & i_int;
        i_CW = (angle == 0) & (radius < 0) & i_int;
        i_CN = (angle == 90) & (radius > 0) & i_int;
        i_CS = (angle == 90) & (radius <= 0) & i_int;
        
        pos = radius(i_CE);
        stress_CE =        data{i_CE, wafer};
        stress_CW = flipud(data{i_CW, wafer});
        stress_CN =        data{i_CN, wafer};
        stress_CS = flipud(data{i_CS, wafer});
        stress_avg = mean([stress_CE stress_CW stress_CN stress_CS],2);

        node = repo.getNode(wafer, 'stress');
        node.add('stress_CE',  pos, stress_CE);  
		node.add('stress_CW',  pos, stress_CW);     
		node.add('stress_CN',  pos, stress_CN);    
		node.add('stress_CS',  pos, stress_CS);    
		node.add('stress_avg', pos, stress_avg); 
        
        node.write();
    end
    
end