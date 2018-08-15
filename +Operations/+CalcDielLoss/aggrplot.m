function [outputArg1,outputArg2] = aggrplot(info,results)
    
    ax1 = subplot(2,2,1); title 'Loss Factor D [10^{-3}]';
    ax2 = subplot(2,2,2); title 'Series Resistance R_s';
    ax3 = subplot(2,2,3); title 'Leakage Conductance G_p [pS/mm^2]';
    ax4 = subplot(2,2,4); title 'Correlation: D vs Electrode Diameter ';
    
    pos = [info.Position];
    elsize = [info.ElSize];
    elarea = elsize.^2*pi*1e-6; %in mm^2
    
    D0 =  hnan([results.D0]);
    Rs =  hnan([results.Rs]);
    Gp =  hnan([results.GpA]);

    D10k = hnan([results.D10k]);
    D20k = hnan([results.D20k]);
    D40k = hnan([results.D40k]);
        
    axes(ax1);
    plot(pos, double(D0)*1e3, 'o', 'DisplayName', 'Fit Result');fillmarkers;
    plot(pos, double(D10k)*1e3, 'o', 'DisplayName', 'Value at 10kHz');
    plot(pos, double(D20k)*1e3, 'o', 'DisplayName', 'Value at 20kHz');
    plot(pos, double(D40k)*1e3, 'o', 'DisplayName', 'Value at 40kHz');
    xlabel 'Position on Wafer [mm]';
    
    legend show; legend location best;
    
    axes(ax2);
    plot(pos, double(Rs), 'o');
    xlabel 'Position on Wafer [mm]';
    fillmarkers;
    yscale log;
    
    axes(ax3);
    plot(pos, double(Gp)*1e12, '-o');
    xlabel 'Position on Wafer [mm]';
    fillmarkers;
    
    axes(ax4);
    plot(elsize, D0);
end

function x = hnan(x)
    [~, i] = hampel(double(x));
    x(i) = NaN;
end


