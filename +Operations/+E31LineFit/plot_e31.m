function [hAx] = plot_e31(info, result)
    assignin('base', 'data', result);
    
    s = result.Displacement_measured;
    q = result.Charge_measured;
    
    s1 = result.Displacement_fit;
    q1 = result.Charge_fit;
    
    dualax left;
    plot(s, q);
    
    plot(s1, q1, '--');
    
    ylabel 'Charge';
    xlabel 'Displacement';
    yUnitTicks C;
    xUnitTicks m;
    
    crosshair;

    e31_matlab = result.e31_matlab;
    e31_aix    = result.e31_aix;
    
    labeltext1 = sprintf('aixAcct: $e_{31,f} = %0.3f$ C/m$^2$', e31_aix); 
    labeltext2 = sprintf('Matlab: $e_{31,f} = %0.3f$ C/m$^2$', e31_matlab); 
    label([0.5 0.85], labeltext1);
    label([0.5 0.77], labeltext2);
    
    
%     dualax right;
%     plot(data.f, data.D);
%     xscale log;
%     yscale log;
%     ylabel 'Dissipation Factor';
%     
%     xUnitTicks Hz;
    
    title([info.WaferID '_' info.SampleID], 'Interpreter', 'none');
    
    
%     adaptPaper;
%     pdffilename = [data.fullpath '.pdf'];
%     counter = 0;
%     while exist(pdffilename, 'file')
%         counter = counter + 1;
%         pdffilename = sprintf('%s%d%s', data.fullpath, counter, '.pdf');
%     end
%     print(gcf, '-dpdf', sprintf('-r%d', 300), pdffilename);
%     open([pdffilename]);
end
