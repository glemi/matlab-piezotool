function aggr_DK(info, data)

    epsilon0 = 8.854e-12;
    frequencies = [1000 2000 10000];
    
    ax1 = subplot(2, 2, 1); title 'Areal Capacitance [pF/mm^2] and \epsilon_r';
    ax2 = subplot(2, 2, 2); title 'Loss Factor [10^{-3}]';
    ax3 = subplot(2, 2, 3); title '\epsilon_r vs frequency'
    ax4 = subplot(2, 2, 4); title 'Loss Factor [10^{-3}]';
    
    for f0 = frequencies
    
        n = length(data);
        for k = 1:n
            this = data(k);
            C_avg(k) = average_neighborhood(f0, this.f, this.Cp, 1.05);
            D_avg(k) = average_neighborhood(f0, this.f, this.D, 1.05);
            esize(k) = info(k).ElSize;
            area(k) = ((esize(k))*0.5e-3)^2*pi;
            thickness(k) = get_thickness(info(k));
        end
        sizes = sort(unique(esize));
        
        fname = sprintf('f = %s', siPrefix(f0, 'Hz'));

        axes(ax1);
        dualax left;
        line(k) = plot(esize, C_avg./area*1e12, '.', 'DisplayName', fname);
        ax1.XTick = sizes;
        ax1.XGrid = 'on';
        xlabel 'Electrode Diameter [\mu{}m]';
        ylabel 'C/A'
        
        [C0, delta, func] = delta_fit(esize/2, C_avg./area*1e12);
        r = 550:10:1200;
        
        fprintf('C0 = %.2f pF  delta_R = %.1f um   (%s)\n', C0, delta, fname);
        ax1.ColorOrderIndex = ax1.ColorOrderIndex -1;
        plot(r, func(r/2), '--'); skiplegend;
        
        ax1.ColorOrderIndex = ax1.ColorOrderIndex -1;
        plot([550 1150], [C0 C0], '-'); skiplegend;
        
        legend show; legend location best;
        
        ylim_left = ylim;
        
        dualax right; ax = gca;
        ylim(ylim_left*1e-6*thickness(k)/epsilon0);
        ax.YTick = unique(round(ax.YTick*10)/10);
        reduceTicks([], 5);
        ylabel '\epsilon_r'
        
        dualax left;

        axes(ax2);
        plot(esize, D_avg*1000, '.');
        ax2.XTick = sizes;
        ax2.XGrid = 'on';
        xlabel 'Electrode Diameter [\mu{}m]';
    end
    
    f0 = round(logspace(3,5, 21), -1);
    m = length(f0);
    
    for i = 1:m
        
        n = length(data);
        for k = 1:n
            this = data(k);
            C_avg(k) = average_neighborhood(f0(i), this.f, this.Cp, 1.05);
            D_avg(k) = average_neighborhood(f0(i), this.f, this.D, 1.05);
            esize(k) = info(k).ElSize;
            area(k) = ((esize(k))*0.5e-3)^2*pi;
            thickness(k) = get_thickness(info(k));
        end
        [Cfit(i), delta(i)] = delta_fit(esize/2, C_avg./area*1e12);
        Cavg(i) = mean(C_avg./area*1e12);
        Davg(i) = mean(D_avg);
    end
    
    axes(ax3);
    epsr_fit = Cfit*1e-6*thickness(k)/epsilon0;
    epsr_avg = Cavg*1e-6*thickness(k)/epsilon0;
    plot(f0, epsr_fit);
    plot(f0, epsr_avg);
    ax.YTick = unique(round(ax.YTick*10)/10);
    xscale log;
    xUnitTicks Hz;
    xlabel f;
    
    
    Cfit_median = median(Cfit);
    Cavg_median = median(Cavg);
    epsrfit_median = median(epsr_fit);
    epsravg_median = median(epsr_avg);
    
    label([.25 .7], sprintf('median$(\\epsilon_r)$ = %.2f (average)', epsravg_median));
    label([.25 .3], sprintf('median$(\\epsilon_r)$ = %.2f (fit)', epsrfit_median));
    
    axes(ax4);
    plot(f0*1e-3, Davg);
    xscale log;
    xlabel 'f [kHz]';
    
    name = FileTypes.SampleInfo.genRangeName(info); 
    pattern = 'Impedance / DK Analysis: %s (t = %.0f nm)';
    stitle = sprintf(pattern, name, thickness(k)*1e9);
    h = suptitle(stitle);
    h.Interpreter = 'none';
end


function [C0, delta, func] = delta_fit(R, C)
    initial = [min(C) 1];
    final = nlinfit(R, C, @model, initial);
    
    C0 = final(1);
    delta = final(2);
    func = @(r)model(final,r);
    
    function c = model(coeffs, r)
        c0 = coeffs(1);
        d = coeffs(2);
        
        c = c0*(1 + 2*d./r + d^2./r.^2);
    end    
end

function y_avg = average_neighborhood(f0, f, y, range_factor)
    fmin = f0/range_factor;
    fmax = f0*range_factor;
    indices = f >= fmin & f <= fmax;
    y_avg = median(y(indices));
end

function t = get_thickness(sampledata)
    if ~isempty(sampledata.Config)
        layers = sampledata.Config.layers;
        player = structFind(layers, 'type', 'PL');
        t = player.thickness;
    else
        error 'Config Data needed for this operation.';
    end
end


function text = cursor_text(event, samples)
    xy = event.Position;
    position = event.Position(1);
    e31value = event.Position(2);
    
    index = find([samples.Stress] == position);
    
    if length(index) == 1
        sample = samples(index);

        pattern = '%s:%s\nPosition: %d\ne31: %.2f';
        args{1} = strtrim(sample.WaferID);
        args{2} = strtrim(sample.SampleID);
        args{3} = position;
        args{4} = e31value;

        text = sprintf(pattern, args{:});
    else
        text = 'hello';
    end
    
%     set(0,'ShowHiddenHandles','on');                       % Show hidden handles
%     hText = findobj('Type','text','Tag','DataTipMarker');  % Find the data tip text
%     set(0,'ShowHiddenHandles','off');                      % Hide handles again
%     set(hText,'Interpreter','tex');                        % Change the interpreter
end
