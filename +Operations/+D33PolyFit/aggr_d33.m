function aggr_d33(info, result)
    
    dEl_meas = result.dEl_meas;
    dEl_var = min(dEl_meas)-50:10:max(dEl_meas)+50;
    d33_fit = polyval(result.poly_coeffs, dEl_var);

    plot(dEl_meas, result.d33_med, '.', 'MarkerSize', 15);
    plot(dEl_var, d33_fit);
    
    errorbar(result.dEl_ref, result.d33, result.d33_error.tot);
    plot(result.dEl_ref, result.d33, 'kx', 'LineWidth', 3, 'MarkerSize', 10);
    
    
    txt = '$p(x)$ = %.2f + %.2f$x$ + %.2f$x^2$';
    txt = sprintf(txt, result.poly_coeffs);
    label([20 15]/100, txt, 'Times13', 'BackgroundColor', 'w');
    
    d33text = sprintf('$d_{33,f} = %.1f$ pm/V', result.d33);
    label([5 80]/100, genPlotName(info), 'Helvetica11n', 'Interpreter', 'none', 'BackgroundColor', 'w');
    label([5 70]/100, d33text, 'Times13', 'Interpreter', 'Latex', 'BackgroundColor', 'w');
    
    eticks = unique(result.dEl_meas);
    ax = gca;
    ax.XTick = eticks;
    ax.XGrid = 'on';
    
    xlabel 'Electrode Size [\mu{}m]';
    title 'd_{33} Values [pm]';
    
    xlim([min(dEl_var) max(dEl_var)]);
%     dcm = datacursormode(gcf);
%     dcm.UpdateFcn = @(~,event)cursor_text(event, samples);
end

function plotName = genPlotName(samples)
    
    wafers = unique({samples.WaferID});
    samples = unique({samples.SampleID});
    
    if length(wafers) == 1
        wname = wafers{1};
        snames = strjoin(samples, '-');
        plotName = sprintf('%s %s', wname, snames);
    end
  
end


function text = cursor_text(event, samples)
    xy = event.Position;
    position = event.Position(1);
    d33value = event.Position(2);
    
    index = find(event.Target.YData == d33value);
    
    if length(index) == 1
        sample = samples(index);

        pattern = '%s_%s (m%d):\nd33 = %.3f';
        args{1} = sample.WaferID;
        args{2} = sample.SampleID;
        args{3} = sample.mIndex;
        args{4} = d33value;

        text = sprintf(pattern, args{:});
    else
        text = 'hello';
    end
    
%     set(0,'ShowHiddenHandles','on');                       % Show hidden handles
%     hText = findobj('Type','text','Tag','DataTipMarker');  % Find the data tip text
%     set(0,'ShowHiddenHandles','off');                      % Hide handles again
%     set(hText,'Interpreter','tex');                        % Change the interpreter
end