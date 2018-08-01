% New User Script: Enter Title on next line
% #Title: "e31 Plot" 
% Description goes here
function e31_plot(repo, wafers)
    
    %wafers = repo.listWafers('e31');
    
    fig 'e31:eins';clf;
    
    n = length(wafers);
    for k = 1:n
        node = repo.getNode(wafers{k}, 'e31');
        snode = repo.getNode(wafers{k}, 'stress');
        [e31, e31_pm] = node.get('e31');
        pos = node.get('Position');
        stress = snode.interp('stress_avg', pos);
        
        plus  =  e31_pm(:,2) - e31;
        minus = -e31_pm(:,1) + e31;
        
        h = errorbar(stress, e31, minus, plus, '.');
        h.DisplayName = wafers{k};
        h.MarkerSize = 25;
        
        fitline(stress, e31);
    end
    legend show; legend location best;
    
    %fillmarkers;
    
end

function fitline(x, y)
    i = ~isnan(x) & ~isnan(y);
    x = x(i); y = y(i);
    X = [min(x); max(x)];
    %X = X + abs(X/100).*[25 -6]';
    
    skipcolor;
    linfit = fit(x(:), y(:), 'poly1', 'Robust', 'LAR');
    %linfit = fit(x(:), y(:), 'poly1');
    Y = feval(linfit, X);
    plot(X, Y, '--');
    skiplegend;
end