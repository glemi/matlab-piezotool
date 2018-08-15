function cpd_plot(info, data)
    hf = gcf;
    function Zs = Zmodel(f, D, Gp, Rs)
        Yc = 2i*pi*f.*data.Cp.*(1-1i*D);
        Yp = Yc + Gp;
        Zs = 1./Yp + Rs;
    end

    function D = Dwrapper(c, f)
        persistent hplot
        c = abs(c);
        Z = Zmodel(f, c(1), c(2), c(3));
        Y = 1./Z;
        Cp = imag(Y)./(2*pi*f);
        D  = real(Y)./imag(Y);

%         try delete(hplot); end
%         fig cpdfit; 
%         subplot(2,2,1); hplot(1) = plot(f, Cp);
%         subplot(2,2,2); hplot(2) = plot(f, D);
%         drawnow;
    end  

%     fig cpdfit; clf;
%     subplot(2,2,1); plot(data.f, data.Cp); 
%     subplot(2,2,2); plot(data.f, data.D); xscale log;

    options = statset;
    options.Robust = 'on';
    options.MaxIter = 20;
    initl = [2e-3, 1e-6, 0, 0];
    final = nlinfit(data.f, smooth(data.D, 200, 'lowess'), @Dwrapper, initl);
    final = abs(final);
    
    
    figure(hf);
    
    %fprintf('Cp = %.1fpF\n', final(1)*1e12);
    fprintf('D  = %.1fm\n', final(1)*1e3);
    fprintf('Gp = %.1fnS\n', final(2)*1e9);
    fprintf('Rs = %g Ohm\n', final(3));
    
    DFit = Dwrapper(final, data.f);
    
    subplot(2,2,1);
    plot(data.f, data.Cp);
    %plot(data.f, CpFit);
    xscale log;
    yscale log;
    ylabel 'Capacitance C_p (\Omega)';
    
    subplot(2,2,2);
    plot(data.f, data.D);
    plot(data.f, smooth(data.D, 200, 'lowess'));
    plot(data.f, DFit);
    ylabel 'Dielectric Loss Factor D';
    xscale log;
    
    
    i = data.f > 8e3 & data.f < 12e3; 
    plot(data.f(i), data.D(i), 'r', 'linewidth', 2);
    D10k = mean(data.D(i));
    
    txtD = sprintf('$D~ = %.1f\\,\\rm mU$', final(1)*1e3);
    txtG = sprintf('$G_p = %.1f\\,\\rm nS$', final(2)*1e9);
    txtR = sprintf('$R_s = %s\\Omega$', uprefix(final(3), '', 'latex'));
    txtD10k = sprintf('$D~ = %.1f\\,\\rm mU$', D10k*1e3);
    label([0.5, 0.8], txtD); 
    label([0.5, 0.7], txtG);
    label([0.5, 0.6], txtR);
    label([0.5, 0.2], txtD10k);
end




