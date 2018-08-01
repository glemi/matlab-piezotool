function [hAx] = plot_cpd(info, data)
    
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
    
    samplename = [info.WaferID ' ' info.SampleID];
    title(samplename, 'Interpreter', 'none');
end
