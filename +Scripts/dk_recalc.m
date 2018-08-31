% New User Script: Enter Title on next line
% #Title: "Plot Dielectric Constant (Recalc)" 
% Description goes here
function dk_recalc(repo, wafers)
    fig 'diel:recalc';clf;

    n = length(wafers);
    for k = 1:n
        dnode = repo.getNode(wafers{k}, 'diel2');
        snode = repo.getNode(wafers{k}, 'stress');
        wnode = repo.getNode(wafers{k}, 'master');
        
        if isempty(dnode.DataTable)
            continue;
        end
        
        % Plot original values
        subplot(2,2,1); uposPlot(dnode, 'eps10k', 1, 'o', '$\varepsilon_{33,f}$'); skipcolor;
        subplot(2,2,2); stressPlot(dnode, snode, 'eps10k', 1, 'o', '$\varepsilon_{33,f}$'); skipcolor;

        % Recalc Epsilon
        eps = recalc_eps(dnode, wnode);
        pos = dnode.get('Position');
        
        % Update value in the node; note that the node is not written, back
        % so changes aren't permanent
        dnode.add('eps10k_recalc', pos, eps);
        dnode.write;
        
        % Plot updated values 
        subplot(2,2,1); uposPlot(dnode, 'eps10k_recalc', 1, 'd', '$\varepsilon_{33,f}$');
        subplot(2,2,2); stressPlot(dnode, snode, 'eps10k_recalc', 1, 'd', '$\varepsilon_{33,f}$');
    end
end


function epsPiezo = recalc_eps(dnode, wnode)
    cap = dnode.uget('c10k');
    epsilon0 = 8.854e-12;
    
    tPiezo   = wnode.uget('PiezoThick')*1e-9;
    tSeed    = wnode.uget('SeedThick')*1e-9;
    epsSeed  = uval(10.1, 0.2);
    
    n = length(cap);
    epsPiezo = uval(NaN(n,1));
    for k = 1:n
        cMeas = cap(k)*1e-6; % corrected areal capacitance (pF/mm^2)
        if isnan(tSeed.Value)
            epsPiezo(k) = cMeas*tPiezo/epsilon0;
        else
            epsPiezo(k) = tPiezo./(1./cMeas - tSeed/epsSeed)/epsilon0;
        end
    end
end


function posPlot(node, varname, scale, style, label)
    var = node.get(varname);
    pos = node.get('Position');
    plot(pos, var*scale, style, 'DisplayName', node.WaferId);
    %fitline(pos, var*scale);
    xlabel 'Radial Position [mm]';
    title(label, 'Interpreter', 'latex');
    fillmarkers;
end

function uposPlot(node, varname, scale, style, label)
    var = node.uget(varname);
    pos = node.get('Position');
    uplot(pos, var*scale, style, 'DisplayName', node.WaferId);
    %fitline(pos, var*scale);
    xlabel 'Radial Position [mm]';
    title(label, 'Interpreter', 'latex');
    fillmarkers;
end

function stressPlot(varnode, stressnode, varname, scale, style, label)
    var = varnode.uget(varname);
    pos = varnode.get('Position');
    T = stressnode.interp('stress_avg', pos);
    uplot(T, var*scale, style, 'DisplayName', varnode.WaferId);
    %fitline(T, var*scale);
    xlabel 'Local Stress [MPa]';
    title(label, 'Interpreter', 'latex');
    fillmarkers;
end
