function plot_stress(info, data)
    
    data = data.stress;
    wafers = data.Properties.VariableNames(3:end);
    i = ~strncmpi('Var', wafers, 3);
    wafers = wafers(i);
    
    angle  = data{:,'Angle'};
    radius = data{:,'R'};
    
    n = length(wafers);
    for k = 1:n
        wname = wafers{k};
        i = (angle == 0);
        line = plot(radius(i), data{i,wname});
        line.DisplayName = wname;
    end
    
    legend show; 
    legend location best;
end

