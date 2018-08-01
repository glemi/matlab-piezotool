function plot_d33(info, data)
    
    sorted = sort(data.d33);
    n = length(sorted);
    percent = 100*(1:n)/n;
    m = median(sorted);
    [~, i_med] = closest(sorted, m);
    
    phase_thres = 0.5;
    i = logical(abs(data.Phase) < phase_thres);
    d33_bad = data.d33;
    d33_bad(i) = NaN;
    
    subplot(1,2,1); xscale log;
    plot(data.Freq, data.d33);  
    plot(data.Freq, d33_bad);
    plot(xlim, [m m], 'k--');
    
    
    pc = diff(prctile(sorted, [25 75]))/2;
    qt = quantile(sorted, [.25 .75]);
    
%     subplot(1,2,3);% xscale log;
%     f = data.Freq;
%     x1 = min(f);        x2 = max(f);      w = x2-x1;
%     y1 = -phase_thres;  y2 = phase_thres; h = y2-y1;
%     rectangle('Position', [x1 y1 w h], 'FaceColor', [1 1 1]*0.95, 'LineStyle', 'none');
%     
%     ph_good   = data.Phase; ph_good(~i) = NaN;
%     ph_bad    = data.Phase; ph_bad(i) = NaN;
%     
%     plot(data.Freq, data.Phase);
%     plot(data.Freq, ph_bad);
    
    subplot(1,2,2);
    plot(percent, sorted);
    errorbar(percent(i_med), m, std(data.d33(i)));
    plot(percent(i_med), m, 'k.', 'MarkerSize', 15);
   
    
    title(sprintf('Median = %.2d', m));
    xlabel('% of population');
    
end