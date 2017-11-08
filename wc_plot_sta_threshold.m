function wc_plot_sta_threshold(signal, trigger, fs, extrema, sprfile)
%
% wc_plot_sta_threshold STAs for different current threshold crossing
%
% wc_plot_sta_threshold(signal, trigger, fs, specfile)
%
% The STA from voltage clamp recordings is estimated for different
% threshold values.
%
% At each threshold value, the STA is estimated using a event-like model,
% where the response is 0 or 1, and by a response magnitude model, where
% the response is the magnitude of the peak value.
%
% signal : processed whole cell recording signal.
%
% trigger : trigger times for ripple stimulus, in sample number.
%
% fs : sampling rate of signal and trigger.
%
% extrema : 1 for positive peaks
%           0 for negative "peaks"
%           Default = 0
%
% specfile : absolute path to the the spr file
%
% signal, trigger, and fs may be obtained from 
%       [signal, trigger, fs] = wc_abf_signal_trigger(abfile);
%
%


if isempty(sprfile)

    stimfolder = 'c:\stimuli';
    file = 'rn1-500flo-40000fhi-4SM-40TM-40db-96khz-48DF-10min_DFt5_DFf5.spr';
    sprfile = fullfile(stimfolder, sprfile);
end



library('whole_cell');
library('strfbox');
library('stimbox');

narginchk(3,5);

if nargin == 3
    extrema = -1;
end



if extrema == -1
    signal = -1 * signal;
    extrema = 1;
end



% Different threshold levels

threshold = 1:4;
zsig = zscore(signal);
denom = 8;
selectivity = (max(zsig)-min(zsig)) ./ denom;
spl = 60;

paramfile = strrep(stimfile, '.spr', '_param.mat');
params = load(paramfile, 'NT', 'NF');
nlags = ceil(0.2/params.NT);
[stim] = wc_stim_mat2obs(stimfile, nlags)


for ii = 1:length(threshold)

    thresh = threshold(ii);

    figure;
    
    for i = 1:length(selectivity)

        [spet, spetval] = peakfinder(zsig, selectivity(i), thresh, extrema);
        
        [locator, locatorval, pp, spln, rmsp] = ...
            wc_locator_from_spet_spr(specfile, spet, spetval, trigger, fs, spl);
        


        
        size(locator)
        size(locatorval)
        pause

        subplot(length(selectivity),1,i);
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






