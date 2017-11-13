function wc_plot_process_abf_signal(time, sigraw, sigdetrend, sigfilt, interval)
%
% axon_abf_fra FRA from abf file using TMF FRA params
%
% Asks for an abf file, then estimates trigger values, gets multi-unit
% responses, and plots the FRA and PSTH.
%



if ( nargin == 4 )
    tmin = -inf;
    tmax = inf;
else
    if (length(interval) == 0)
        tmin = -inf;
        tmax = inf;
    elseif (length(interval) == 1)
        tmin = -inf;
        tmax = interval;
    else
        tmin = min(interval);
        tmax = max(interval);
    end
end


index = find(time>tmin & time<tmax);

figure;
subplot(3,4,[1 3]);
plot(time(index), sigraw(index));
title('Raw signal');
yax1 = get(gca,'ylim');

subplot(3,4,[5 7]);
plot(time(index), sigdetrend(index));
title('De-trended signal');
yax2 = get(gca,'ylim');


subplot(3,4,[9 11]);
plot(time(index), sigfilt(index));
title('Filtered signal');
yax3 = get(gca,'ylim');


subplot(3,4,4);
hist(sigraw,50);
title('Raw Amp Dist');

subplot(3,4,8);
hist(sigdetrend,50);
title('De-trended signal Amp Dist');
xlim(yax2);

subplot(3,4,12);
hist(sigfilt,50);
title('Filtered signal Amp Dist');
xlim([yax3]);

set(gcf,'position', 0.75*[150 314 2001 985]);



% Different threshold levels

threshold = 1:4;
zsigfilt = zscore(sigfilt);
denom = 8;
sel = (max(zsigfilt)-min(zsigfilt)) ./ denom;
extrema = 1;


figure;

for i = 1:length(threshold)

    thresh = threshold(i);
    

    [minLoc, minMag] = peakfinder(zsigfilt, sel, thresh, extrema);

    
    subplot(length(threshold),4, (i-1)*4+1);
    hold on;
    
    edges = linspace(-10,10,51);
    [count, bin] = histc(zsigfilt, edges);
    prob = count ./ sum(count);
    bar(edges, prob, 'histc');
    
    title(sprintf('Threshold = %.1f', thresh));
    xlim([-10 10]);
    yax = [0 1.1*max(prob)];
    plot([threshold(i) threshold(i)], yax, 'r-');
    ylim(yax);
    
    subplot(length(threshold),4,[(i-1)*4+2 (i-1)*4+4]);
    hold on;
    plot(time(index), zsigfilt(index));
    plot([min(time(index)) max(time(index))], [thresh thresh], 'r-');
    plot(time(minLoc), minMag, 'rv');
    xlim([min(time(index)) max(time(index))]);

    title(sprintf('Threhsold = %.1f', thresh));
    
end % (for i)

suptitle(sprintf('Filtered signal; Denom = %.1f', denom));

set(gcf,'position', 0.75*[500 150 2001 985]);



% Different selectivity values

denom = 4:4:12;
sel = (max(zsigfilt)-min(zsigfilt)) ./ denom;

for ii = 1:length(threshold)

    thresh = threshold(ii);

    figure;
    
    for i = 1:length(sel)

        [minLoc, minMag] = peakfinder(zsigfilt, sel(i), thresh, extrema);
        
        subplot(length(sel),1,i);
        hold on;
        plot(time(index), zsigfilt(index));
        plot([min(time(index)) max(time(index))], [thresh thresh], 'r-');
        plot(time(minLoc), minMag, 'rv');
        xlim([min(time(index)) max(time(index))]);

        title(sprintf('Denom = %.1f', denom(i)));

    end % (for i)

    suptitle(sprintf('Filtered signal; Threhsold = %.1f', thresh));

    set(gcf,'position', 0.75*[500 150 1400 985]);
    
end % (for ii)




% Denom of 8 looks to work well.


% Now loop through and find events for thresholds = [-1 -2 -3 -4 -5] for
% denom = 8


%dt = time(2) - time(1)
%fs = 1 / dt

return;






