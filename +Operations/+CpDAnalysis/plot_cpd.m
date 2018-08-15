function [hAx] = plot_cpd(info, data)
    
    subplot(2,2,1);

    dualax left;
    plot(data.f, data.Cp);
    xscale log;
    yscale log;
    ylabel 'Capacitance C_p (\Omega)';
    yUnitTicks F '%0.2f';
    
    drawnow;
    dualax right;
    plot(data.f, data.D);
    xscale log;
    yscale log;
    ylabel 'Dissipation Factor';
    
    xUnitTicks Hz;
    
    subplot(2,2,2);
    
    
    fitmodel = @(c,f)model(f,c(1), c(2), c(3), c(4));
    function model(f, C, D, Rp, Rs)
        Yc = 2i*pi*f*C(1+D);
        Yp = Yc + 1/Rp;
        Zs = 1./Yp + Rs;
    end
    
    
    
    samplename = [info.WaferID ' ' info.SampleID];
    title(samplename, 'Interpreter', 'none');
end



