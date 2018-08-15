function resultplot(info, result)
    
    ax1 = subplot(1,2,1); title 'Loss Factor [10^{-3}]';
    ax2 = subplot(1,2,2); title '\epsilon_r vs frequency'
    
    function Deff = Deff_model(f, C, D0, Gp, Rs)
        w = 2*pi*f;
        Deff = ((w*C*D0 + Gp).*(w*Rs*C*D0 + Rs*Gp + 1) + (w*Rs*C).^2/Rs)./(w*C);
    end
   
    axes(ax1);
    plot(result.f*1e-3, double(result.D));
    plot(result.f*1e-3, double(result.Dfit));
    xlabel 'f [kHz]';
    xscale log;

end

