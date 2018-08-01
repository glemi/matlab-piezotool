% New User Script: Enter Title on next line
% #Title: "kt2 Plot" 
% Description goes here
function kt2_plot(repo, wafers)

    fig 'kt2:eins';clf;
    
    warning off MATLAB:handle_graphics:exceptions:SceneNode;
    
    ax1 = subplot(3,2,1);
    ax2 = subplot(3,2,2);
    ax3 = subplot(3,2,3);
    ax4 = subplot(3,2,4);
    ax5 = subplot(3,2,5);
    ax6 = subplot(3,2,6);
    
    n = length(wafers);
    for k = 1:n
        cnode = repo.getNode(wafers{k}, 'coupling');
        snode = repo.getNode(wafers{k}, 'stress');

        if isempty(cnode.DataTable) || isempty(snode.DataTable)
            continue;
        end
        
        
        axes(ax1); posPlot(cnode, 'kt2', 100, 'Coupling $k_t^2$ [\%]');
        axes(ax3); posPlot(cnode, 'e33', 1, 'Piezo-Const $e_{33}$');
        axes(ax5); posPlot(cnode, 'c33E', 1e-9, 'Stiffness $c_{33}^E$ [GPa]');
        
        axes(ax2); stressPlot(cnode, snode, 'kt2', 100, 'Coupling $k_t^2$ [\%]');
        axes(ax4); stressPlot(cnode, snode, 'e33', 1, 'Piezo-Const $e_{33}$');
        axes(ax6); stressPlot(cnode, snode, 'c33E', 1e-9, 'Stiffness $c_{33}^E$ [GPa]');
        
        %plot(pos, kt2, 'o', 'DisplayName', wafers{k});
%         fitline(pos, kt2);
%         getValueNearX(pos, kt2, 15, 10);
%         getValueNearX(pos, kt2, 45, 10);
%         getValueNearX(pos, kt2, 80, 10);
        
    end
    
    axes(ax1);
    legend show; legend location best;
%     fillmarkers;
%     
%     ax1 = gca;
%     ax1.Title.Interpreter = 'latex';
%     ax1.Title.FontSize = 12;
%     ax1.Title.FontWeight = 'bold';
%     title '$k_t^2$ [\%] vs Local Stress';
%     xlabel 'Stress [MPa]';
%     crosshair;
    
%     axes(ax2);
%     fillmarkers;
%     xlabel 'Radial Position on Wafer [mm]';
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
    X = [min(x); max(x)];
    %X = X + abs(X/100).*[25 -6]';
    
    warning off curvefit:fit:iterationLimitReached;
    [linfit, gof] = fit(x(:), y(:), 'poly1', 'Robust', 'LAR');
    %linfit = fit(x(:), y(:), 'poly1');
    
    if gof.rmse < 0.6
        skipcolor;
        Y = feval(linfit, X);
        plot(X, Y, '--');
        skiplegend;
    end
end

function y0 = getValueNearX(x, y, x0, tol)
    i = abs(x-x0) < tol;
    y0 = median(y(i));
    
    if any(abs(x-x0) < 2*tol)
        [linfit, gof] = fit(x(:), y(:), 'poly1', 'Robust', 'LAR');
        if gof.rsquare > 0.9
            y0 = feval(linfit, x0);
        end
    end
        
    skipcolor;
    plot(x0, y0, 'x', 'MarkerSize', 12, 'LineWidth', 4);
    skiplegend;
end
