% New User Script: Enter Title on next line
% #Title: "Plot Dielectric Constant (Advanced)" 
% Description goes here
function dk_plot(repo, wafers)

    fig 'diel:eins';clf;

    n = length(wafers);
    for k = 1:n
        dnode = repo.getNode(wafers{k}, 'diel2');
        snode = repo.getNode(wafers{k}, 'stress');
        
        if isempty(dnode.DataTable)
            continue;
        end
        
        eps = dnode.get('eps10k');
        D   = dnode.get('D40k');
        pos = dnode.get('Position');
        
        subplot(3,2,1); posPlot(dnode, 'eps10k', 1, '$\varepsilon_{33,f}$');
        subplot(3,2,3); posPlot(dnode, 'D10k', 1e3, '$tan(\delta)$ [mU]');
        subplot(3,2,5); posPlot(dnode, 'dR', 1, '$\Delta R~[\rm \mu m]$');
        
        subplot(3,2,2); stressPlot(dnode, snode, 'eps10k', 1, '$\varepsilon_{33,f}$');
        subplot(3,2,4); stressPlot(dnode, snode, 'D10k', 1e3, '$tan(\delta)$ [mU]');
        subplot(3,2,6); stressPlot(dnode, snode, 'dR', 1e3, '$\Delta R~[\rm \mu m]$ ');
        
%         plot(pos, eps, 'o', 'DisplayName', wafers{k});
%         fitline(pos, eps);
%         
%         subplot(3,2,2);
%         plot(pos, D, 'o');
        
    end
    
%     subplot(2,2,1); fillmarkers;
%     subplot(2,2,2); fillmarkers;
end

function posPlot(node, varname, scale, label)
    var = node.get(varname);
    pos = node.get('Position');
    plot(pos, var*scale, 'o', 'DisplayName', node.WaferId);
    fitline(pos, var*scale);
    xlabel 'Radial Position [mm]';
    title(label, 'Interpreter', 'latex');
    fillmarkers;
end

function stressPlot(varnode, stressnode, varname, scale, label)
    var = varnode.get(varname);
    pos = varnode.get('Position');
    T = stressnode.interp('stress_avg', pos);
    plot(T, var*scale, 'o', 'DisplayName', varnode.WaferId);
    fitline(T, var*scale);
    xlabel 'Local Stress [MPa]';
    title(label, 'Interpreter', 'latex');
    fillmarkers;
end

function fitline(x, y)
    i = ~isnan(x) & ~isnan(y);
    x = x(i); y = y(i);
    X = x([1 end]);
    %X = X + abs(X/100).*[25 -6]';
    
    skipcolor;
    linfit = fit(x(:), y(:), 'poly1', 'Robust', 'LAR');
    %linfit = fit(x(:), y(:), 'poly1');
    Y = feval(linfit, X);
    plot(X, Y, '--');
    skiplegend;
end