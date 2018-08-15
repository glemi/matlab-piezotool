function plot_DK(info, result)

    i = FileTypes.SampleInfo.sort(info);
    info = info(i);
    
	ax1 = subplot(3,2,1); title 'Areal Capacitance [pF/mm^2] and \epsilon_r';
    ax2 = subplot(3,2,2); title 'Loss Factor [10^{-3}]';
    ax3 = subplot(3,2,3); title '\epsilon_r vs frequency'
    ax4 = subplot(3,2,4); title 'Loss Factor [10^{-3}]';
    ax6 = subplot(3,2,6); title 'Delta R';
    
    name = FileTypes.SampleInfo.genRangeName(info); 
    pattern = 'Impedance / DK Analysis: %s (t = %.0f nm)';
    stitle = sprintf(pattern, name, result.Thick*1e9);
    h = suptitle(stitle);
    h.Interpreter = 'none';
    
    epsilon0 = 8.854e-12;
    frequencies = [1000 2000 10000];
    
    axes(ax1);
    dualax left;
    ax1.XTick = unique(result.ElSizes);
    ax1.XGrid = 'on';
    xlabel 'Electrode Diameter [\mu{}m]';
    ylabel 'C/A'
    fitplot(result, frequencies);

    legend show; legend location best;
    
    ylim_left = ylim;
    dualax right; ax = gca;
    ylim(ylim_left*1e-6*result.Thick/epsilon0);
    ax.YTick = unique(round(ax.YTick, 1));
    %reduceTicks([], 5);
    ylabel '\epsilon_r' 
    
    dualax left;
    
    axes(ax2);
    ax2.XTick = unique(result.ElSizes);
    ax2.XGrid = 'on';
    xlabel 'Electrode Diameter [\mu{}m]';
    
    for f0 = frequencies
        i = (result.f == f0);
        plot(result.ElSizes, result.Dlocal(i,:)*1000, 'o');
    end
    fillmarkers;
        
    axes(ax3);
    plot(result.f, result.epsFit);
    plot(result.f, result.epsAvg);
    
    ax3.YTick = unique(round(ax.YTick, -1));
    ax3.XScale = 'log';
    xUnitTicks Hz;
    xlabel frequency;
    
    i10k = (result.f == 10e3);
    label([.25 .7], sprintf('$\\varepsilon_r$(10kHz) = %.2f (average)', result.epsAvg(i10k)));
    label([.25 .3], sprintf('$\\varepsilon_r$(10kHz) = %.2f (fit)', result.epsFit(i10k)));
    
    axes(ax4);
    plot(result.f*1e-3, result.Davg);
    xlabel 'f [kHz]';
    
    axes(ax6);
    plot(result.f, result.deltaR);
    deltaR_med = median(result.deltaR);
    plot(result.f, deltaR_med*ones(size(result.f)), 'k--');
    xlabel frequency;
    xscale log; xUnitTicks Hz;
end

function fitplot(result, frequencies)
    
    function c = cmodel(r, i)
        c0 = result.cFit(i);
        d  = result.deltaR(i);
        c = c0*(1 + 2*d./r + d^2./r.^2);
    end 

     for f0 = frequencies
        fname = sprintf('f = %s', siPrefix(f0, 'Hz'));
        
        i = (result.f == f0);
        h1 = plot(result.ElSizes, result.clocal(i,:), '.');
        h1.DisplayName = fname;
        h1.MarkerSize = 25;
        
        R1 = min(result.ElSizes)-50;
        R2 = max(result.ElSizes)+50;
        
        R = R1:50:R2;
        skipcolor;
        h2 = plot(R, cmodel(R/2,i), '--'); 
        skiplegend;
        
        cfit = result.cFit(i);
        skipcolor;
        h3 = plot([R1 R2], [cfit cfit], '-');
        skiplegend;
     end
end
