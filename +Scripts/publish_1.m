% New User Script: Enter Title on next line
% #Title: "Various Plots for Publishing" 
% Description goes here
function publish_1(repo, selection)

    % kt2 vs Sc (need Sc% data for ASN_19_XX)!
    wafers = {'CTI_01_02' 'CTI_01_05' 'CTI_01_06'  ...
         'ASN_12_07' 'ASN_12_08' 'ASN_12_09' 'ASN_12_11' ...
         'CTI_01_PT_05' 'CTI_01_Pt_17' 'CTI_01_Pt_19' 'CTI_01_Pt_25'};
    
    fig 'publish:kt2~Sc';clf;
    generic_plot(repo, wafers, 'master.ScContent', 'coupling.kt2', @max);
    %legend show; legend location eastoutside;
    
    fig 'publish:c33D~Sc';clf;
    generic_plot(repo, wafers, 'master.ScContent', 'coupling.c33D', @max);
    
    wafers = {'CTI_01_02' 'CTI_01_06' ...
         'ASN_12_02' 'ASN_12_04' 'ASN_12_05' 'ASN_12_06' ...
         'CTI_01_PT_05' 'CTI_01_Pt_17' 'CTI_01_Pt_25'};
    
    fig 'publish:e31f~Sc';clf;
    generic_plot(repo, wafers, 'master.ScContent', 'e31.e31', @max);
    %legend show; legend location eastoutside;
    
    wafers = {'CTI_01_02' 'CTI_01_06' ...
         'ASN_12_06' 'ASN_12_07' 'ASN_12_08' 'ASN_12_09' ...
         'CTI_01_PT_05' 'CTI_01_Pt_17' 'CTI_01_Pt_19' 'CTI_01_Pt_25'};
    
    fig 'publish:eps~Sc';clf;
    generic_plot(repo, wafers, 'master.ScContent', 'diel.eps10k', @max);
    %legend show; legend location eastoutside;
    
    fig 'publish:D~Sc';clf;
    generic_plot(repo, wafers, 'master.ScContent', 'diel.D10k', @max);
    
%     fig 'publish:kt2~e31';clf;
%     generic_plot(repo, wafers, 'e31.e31', 'coupling.kt2', @max);
    
    
end

function generic_plot(repo, wafers, xvar, yvar, op)
    if nargin < 5; op = @(y)y; end

    n = length(wafers);
    for k = 1:n
        xdata = repo.getData(wafers{k}, xvar);
        ydata = repo.getData(wafers{k}, yvar);
        
        x(k,:) = xdata';
        y(k,:) = op(ydata');
    end
    
    for k = 1:n
        h = plot(x(k,:), y(k,:), '.');
        h.DisplayName = wafers{k};
        h.MarkerSize = 25;
        
        if ismatrix(y)
            fitline(x(k,:), y(k,:));
        end
    end
    
    if iscolumn(y)
        fitline(x, y);
    end
    
    fmt = Formatter(repo);
    fmt.formatAxes(xvar, yvar);
    
    legend show; legend location eastoutside;
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
