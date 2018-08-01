function plot_s1p(info, data)
    
    y = s2y(data.s, 50);
    z = s2z(data.s, 50);
    f = data.f;
    fGHz = f/1e9;
    
    y11 = squeeze(y(1, 1, :));
    z11 = squeeze(z(1, 1, :));
    
    addpath 'E:\Workspaces\Matlab\coupling';
    
    %suptitle(data.name, 'interpreter', 'none');
    subplot(2, 2, 1);
    dualax left;
    plot(data.f/1e9, abs(z11));
    title(data.name, 'interpreter', 'none');
    %ylabel('$|Z_{in}|  [\Omega] $', 'Interpreter', 'latex', 'FontSize', 16);
    label([-0.2 0.6], '$|Z_{in}|  [\Omega]$', 'Color', 'blue');
    xscale log; yscale log;
    axis tight;
    ylim(ylim .* [0.3 1]);
    yUnitTicks ''
    xlabel '$f~[\rm GHz]$' Interpreter latex;
    axmenu;
    title 'Phase / Magnitude Plot';
    
    dualax right;
    yscale lin; xscale log;
    plot(data.f, 180/pi*angle(z11));
    axis tight;
    ylim(ylim + [0 1.5*diff(ylim)]);
    angleticks;
    label([1.05 0.3], '$\angle Z_{in} [{}^\circ]$', 'Color', 'blue');
    
    
    subplot(2,2,2);
    smithaxes;
    smithplot(z11);
    title 'Smith Chart';
    
    subplot(2, 2, 3);
    plot(data.f/1e9, abs(z11));
    title(data.name, 'interpreter', 'none');
    label([.1 0.1], '$|Z_{in}|  [\Omega]$', 'Color', 'blue');
    xscale log; yscale log;
    xlabel '$f~[\rm GHz]$' Interpreter latex;
    ylim([10 100]);
    axmenu;
    
    subplot(2, 2, 4);
    plot(data.f/1e9, 180/pi*angle(z11));
    title Angle;
    label([.1 0.8], '$\angle Z_{in} [{}^\circ]$');
    xscale log;
    ylim([-90 0]);
    xlabel '$f~[\rm GHz]$' Interpreter latex;
    axmenu;
end
