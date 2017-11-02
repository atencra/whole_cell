function wc_plot_sta_threshold(signal, trigger, fs)
%
% axon_abf_fra FRA from abf file using TMF FRA params
%
% Asks for an abf file, then estimates trigger values, gets multi-unit
% responses, and plots the FRA and PSTH.
%


library('strfbox');









% Different selectivity values

threshold = [-1 -2 -3 -4];
denom = 4:4:12;
sel = (max(zsigfiltered)-min(zsigfiltered)) ./ denom;

for ii = 1:length(threshold)

    thresh = threshold(ii);

    figure;
    
    for i = 1:length(sel)

        extrema = -1;
        [minLoc, minMag] = peakfinder(zsigfiltered, sel(i), thresh, extrema);
        
        [taxis, faxis, locator1, ~, sta1, ~, averate1, ~, numspikes1, ~, pp, spln] = ...
            wc_locator_sta_from_spr_matrix(specfile, spet, trigger, fsad, spl, varargin)
        
        [stim, resp] = stim_mat2obs(stimfile, iskfile, nf, nlags, x0)


        
        minLoc(1:10)
        pause

        subplot(length(sel),1,i);
        hold on;
        plot(time(index), zsigfiltered(index));
        plot([min(time(index)) max(time(index))], [thresh thresh], 'r-');
        plot(time(minLoc), minMag, 'rv');
        xlim([min(time(index)) max(time(index))]);

        title(sprintf('Denom = %.1f', denom(i)));

    end % (for i)

    suptitle(sprintf('Filtered signal; Threhsold = %.1f', thresh));

    set(gcf,'position', [500 150 1400 985]);
    
end % (for ii)




% Denom of 8 looks to work well.


% Now loop through and find events for thresholds = [-1 -2 -3 -4 -5] for
% denom = 8


dt = time(2) - time(1)
fs = 1 / dt

return;






