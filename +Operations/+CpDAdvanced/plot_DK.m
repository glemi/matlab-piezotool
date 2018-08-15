function plot_DK(info, result)

    i = FileTypes.SampleInfo.sort(info);
    info = info(i);
    
	ax1 = subplot(3,2,1); title 'Areal Capacitance [pF/mm^2] and \epsilon_r';
    ax2 = subplot(3,2,2); title 'Loss Factor [10^{-3}]';
    ax3 = subplot(3,2,3); title '\epsilon_r vs frequency'
    ax4 = subplot(3,2,4); title 'Loss Factor [10^{-3}]';
    ax5 = subplot(3,2,5); title 'Local Gradient [pF/mm^2 / mm]';
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
    cfitplot(result, frequencies);

    legend show; legend location best;
    
    ylim_left = ylim;
    dualax right; ax = gca;
    t = double(result.Thick)';
    ylim(ylim_left*1e-6*t/epsilon0);
    ax.YTick = unique(round(ax.YTick, 1));
    %reduceTicks([], 5);
    ylabel '\epsilon_r' 
    
    dualax left;
    
    axes(ax2);
    ax2.XTick = unique(result.ElSizes);
    ax2.XGrid = 'on';
    xlabel 'Electrode Diameter [\mu{}m]';    
    dfitplot(result, frequencies);

        
    axes(ax3);
    plot(result.f, double(result.epsFit));
    plot(result.f, double(result.epsAvg));
    plot(result.f, double(result.epsCorr));
    
    ax3.YTick = unique(round(ax.YTick, -1));
    ax3.XScale = 'log';
    xUnitTicks Hz;
    xlabel frequency;
    
    i10k = (result.f == 10e3);
    textAvg = '$\\varepsilon_r$(10kHz) = %.2f $\\pm %.2f$ (average)';
    textFit = '$\\varepsilon_r$(10kHz) = %.2f $\\pm %.2f$ (fit)';
    textAvg = sprintf(textAvg, result.epsAvg(i10k).Value, result.epsAvg(i10k).Delta);
    textFit = sprintf(textFit, result.epsFit(i10k).Value, result.epsFit(i10k).Delta);
    label([.25 .7], textAvg);
    label([.25 .3], textFit);
    
    axes(ax4);
    %plot(result.f*1e-3, double(result.Davg));
    plot(result.f*1e-3, double(result.Dlocal));
    xlabel 'f [kHz]';
    xscale log;
    
    axes(ax6);
    plot(result.f, double(result.deltaR));
    deltaR_med = median(double(result.deltaR));
    plot(result.f, deltaR_med*ones(size(result.f)), 'k--');
    xlabel frequency;
    xscale log; xUnitTicks Hz;
    
    axes(ax5);
    plot(result.f, double(result.cslope));
    slope_med = median(double(result.cslope));
    plot(result.f, slope_med*ones(size(result.f)), 'k--');
    xlabel frequency;
    xscale log; xUnitTicks Hz;
end

function dfitplot(result, frequencies)
    
    function d = dmodel(r, i)
        D0 = double(result.D0Fit(i));
        Rs = double(result.Rs(i));
        C  = double(result.Clocal(i));
        sgma = double(result.sigma(i));
        
        A = (r.^2)*pi*1e-6;
        w = 2*pi*result.f(i); 
        G = sgma*A;
        d = D0 + G./(w.*C) + w*Rs.*C;
    end 

     for f0 = frequencies
        fname = sprintf('f = %s', siPrefix(f0, 'Hz'));
        
        i = (result.f == f0);
        
        d_slope = result.dslope(i,:);
        d_original = result.Dlocal(i,:);
        d_corrected = d_original - d_slope.*result.relpos;
        h1 = plot(result.ElSizes, d_corrected, 'o'); fillmarkers('last'); skipcolor;
        plot(result.ElSizes, d_original, 'o'); skiplegend;
        
        h1.DisplayName = fname;
        
        R1 = min(result.ElSizes)-50;
        R2 = max(result.ElSizes)+50;
        
        R = R1:50:R2;
        skipcolor;
        h2 = plot(R, dmodel(R/2,i), '--'); 
        skiplegend;
        
        D0fit = result.D0Fit(i);
        skipcolor;
        h3 = plot([R1 R2], [D0fit D0fit], '-');
        skiplegend;
        
     end
end


function cfitplot(result, frequencies)
    
    function c = cmodel(r, i)
        c0 = double(result.cFit(i));
        d  = double(result.deltaR(i));
        c = c0*(1 + 2*d./r + d^2./r.^2);
    end 

     for f0 = frequencies
        fname = sprintf('f = %s', siPrefix(f0, 'Hz'));
        
        i = (result.f == f0);
        
        c_slope = result.cslope(i,:);
        c_original = result.clocal(i,:);
        c_corrected = c_original - c_slope.*result.relpos;
        h1 = plot(result.ElSizes, c_corrected, 'o'); fillmarkers('last'); skipcolor;
        plot(result.ElSizes, c_original, 'o'); skiplegend;
        
        h1.DisplayName = fname;
        
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
