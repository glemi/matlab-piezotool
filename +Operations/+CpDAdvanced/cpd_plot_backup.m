function cpd_plot(info, data)

    function Zs = model(f, C, D, Gp, Rs, x)
        Yc = 2i*pi*f.*data.Cp.*(1-1i*D);
        Yp = Yc +Gp;
        Zs = 1./Yp + Rs;
    end
    
    function M = wrapper(c, f)
        persistent hplot
        c = abs(c);
        Z = model(f, c(1), c(2), c(3), c(4), c(5));
        Y = 1./Z;
        Cp = imag(Y)./(2*pi*f);
        D  = real(Y)./imag(Y);
        M  = [Cp(:) D(:)];
        
%         try delete(hplot); end
%         fig cpdfit; 
%         subplot(2,2,1); hplot(1) = plot(f, Cp);
%         subplot(2,2,2); hplot(2) = plot(f, D);
%         drawnow;
    end    

%     fig cpdfit; clf;
%     subplot(2,2,1); plot(data.f, data.Cp); 
%     subplot(2,2,2); plot(data.f, data.D); 

    M = [data.Cp(:) data.D(:)];
    initl = [430e-12, 2e-3, 1e-6, 1, 1e-15];
    final = nlinmatrixfit(data.f, M, @wrapper, initl);
    final = abs(final);
    clc;
    fprintf('Cp = %.1fpF\n', final(1)*1e12);
    fprintf('D  = %.1fm\n', final(2)*1e3);
    fprintf('Gp = %.1fnS\n', final(3)*1e9);
    fprintf('Rs = %g Ohm\n', final(4));
    
    
    Mfit = wrapper(final, data.f);
    CpFit = Mfit(:,1);
    DFit = Mfit(:,2);
    
    subplot(2,2,1);
    plot(data.f, data.Cp);
    plot(data.f, CpFit);
    xscale log;
    yscale log;
    ylabel 'Capacitance C_p (\Omega)';
    
    subplot(2,2,2);
    plot(data.f, data.D);
    plot(data.f, DFit);
    ylabel 'Dielectric Loss Factor D';
    xscale log;
end

