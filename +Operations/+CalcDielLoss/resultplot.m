function resultplot(info, result)
    
    %ax1 = subplot(1,2,1); title 'Loss Factor [10^{-3}]';
    %ax2 = subplot(1,2,2); title '\epsilon_r vs frequency'
    
    function Deff = Deff_model(f, C, D0, Gp, Rs)
        w = 2*pi*f;
        Deff = D0 + Gp./(w.*C) + w*Rs.*C;
    end
   
    title 'Loss Factor [10^{-3}]';
    plot(result.f*1e-3, double(result.D));
    plot(result.f*1e-3, double(result.Dfit));
    xlabel 'f [kHz]';
    xscale log;
    yscale log;
    ylim([1e-3 1e-2]);
    grid on;
end

