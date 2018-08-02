% New User Script: Enter Title on next line
% #Title: "kt2 vs Sc Content" 
% Description goes here
function kt2_vs_Sc(repo, wafers)
    
    fig 'kt2:eins';clf;

    warning off MATLAB:handle_graphics:exceptions:SceneNode;
    
    n = length(wafers);
    for k = 1:n
        cnode = repo.getNode(wafers{k}, 'coupling');
        %snode = repo.getNode(wafers{k}, 'stress');

        kt2data = cnode.get('kt2').*100;
        %pos = cnode.get('Position');
        %stress = snode.get('stress_avg', pos);
        
        kt2max(k) = max(kt2data);
        kt2avg(k) = mean(kt2data);
        pcSc(k) = repo.getData(wafers{k}, 'master.ScContent');        
        
        h = plot(pcSc(k), kt2max(k), '.');
        h.DisplayName = wafers{k};
        h.MarkerSize = 25;
    end
    
    fitline(pcSc', kt2max');
    
    ylim([0 25]);
    
    legend show; legend location best;
    fillmarkers;
    
    ax = gca;
    ax.Title.Interpreter = 'latex';
    ax.Title.FontSize = 12;
    ax.Title.FontWeight = 'bold';
    title '$k_t^2$ [\%] vs Sc Content';
    xlabel 'Scandium Content [at%]';
    crosshair;
end


function fitline(x, y)
    if length(x) < 2
        return;
    end

    i = ~isnan(x) & ~isnan(y);
    x = x(i); y = y(i);
    X = [min(x) max(x)];
    %X = X + abs(X/100).*[25 -6]';
    
    skipcolor;
    %linfit = fit(x(:), y(:), 'poly1', 'Robust', 'LAR');
    linfit = fit(x(:), y(:), 'poly1');
    Y = feval(linfit, X);
    plot(X, Y, 'k--');
    skiplegend;
end