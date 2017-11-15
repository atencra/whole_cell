function wc_plot_sta_threshold(signal, trigger, fs, sprfile, thresh)
%
% wc_plot_sta_threshold STAs for different current threshold crossing
%
% wc_plot_sta_threshold(signal, trigger, fs, sprfile, thresh)
%
% The STA from voltage clamp recordings is estimated for different
% threshold values.
%
% At each threshold value, the STA is estimated using a event-like model,
% where the response is 0 or 1, and by a response magnitude model, where
% the response is the magnitude of the peak value.
%
% signal : processed whole cell recording signal. Peaks are assumed to be positive.
%
% trigger : trigger times for ripple stimulus, in sample number.
%
% fs : sampling rate of signal and trigger.
%
%
% sprfile : absolute path to the the spr file
%
% thresh : value to use for finding events. Can be visually determined by looking
%   at wc_plot_process_abf_signal.m
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

stimfile = strrep(sprfile, '.spr', '-matrix.mat');

load(stimfile, 'stimulus');

if ( isempty(thresh) )
    thresh = 1;
end


library('whole_cell');
library('strfbox');
library('stimbox');
library('midbox');

narginchk(3,5);

extrema = 1;



% Different threshold levels

threshold = thresh + (0:3);

zsig = zscore(signal);
denom = 8;
selectivity = (max(zsig)-min(zsig)) ./ denom;
spl = 60;

paramfile = strrep(sprfile, '.spr', '_param.mat');
params = load(paramfile, 'NT', 'NF', 'taxis');
dt = diff(params.taxis(1:2));
nlags = ceil(0.2/dt);


figure;

for i = 1:length(threshold)

    thr = threshold(i);
  
    [spet, spetval] = peakfinder(zsig, selectivity, thr, extrema);
    
    [locator, locatorval, pp, spln, rmsp] = ...
        wc_locator_from_spet_spr(sprfile, spet, spetval, trigger, fs, spl);
        
    sta = wc_locator_stimulus_to_sta(locator, stimulus, nlags);
    sta_val = wc_locator_stimulus_to_sta(locatorval, stimulus, nlags);
    
    nspks = sum(locator);

    subplot(length(threshold), 3, (i-1)*3+1);
    imagesc(sta);
    
    minmin = min(min(sta));
    maxmax = max(max(sta));
    boundary = max([abs(minmin) abs(maxmax)]);

    cmap = brewmaps('rdbu', 21);
    cmap = cmap([1:9 11 13:end],:); % get more contrast in STRF
    colormap(cmap);
    
    set(gca,'ydir', 'normal');
    set(gca, 'tickdir', 'out', 'ticklength', [0.025 0.025]);
    set(gca, 'clim', [-1.05*boundary-eps 1.05*boundary+eps]);
    
    title(sprintf('Threshold = %.1f, N = %.0f\nEvents', thr, nspks));
       
    subplot(length(threshold), 3, (i-1)*3+2);
    imagesc(sta_val);
    
    minmin = min(min(sta_val));
    maxmax = max(max(sta_val));
    boundary = max([abs(minmin) abs(maxmax)]);

    cmap = brewmaps('rdbu', 21);
    cmap = cmap([1:9 11 13:end],:); % get more contrast in STRF
    colormap(cmap);
    
    set(gca,'ydir', 'normal');
    set(gca, 'tickdir', 'out', 'ticklength', [0.025 0.025]);
    set(gca, 'clim', [-1.05*boundary-eps 1.05*boundary+eps]);
    
    title('Value');
    
    
%    edges = linspace(-10,10,51);
%    [count, bin] = histc(zsigfilt, edges);
%    prob = count ./ sum(count);
%    bar(edges, prob, 'histc');
    
    subplot(length(threshold), 3, i*3);
    hist(locatorval(locatorval>0), 50)
    xlim([0 20]);
    title('Event Values');

end % (for i)











figure;

[spet, spetval] = peakfinder(zsig, selectivity, thresh, extrema);

[locator, locatorval, pp, spln, rmsp] = ...
    wc_locator_from_spet_spr(sprfile, spet, spetval, trigger, fs, spl);
    
percent = 0:20:100;
prc = prctile(locatorval(locatorval>0), percent);

for i = 1:(length(prc)-1)


    lowval = prc(i);
    highval = prc(i+1);

    index = find(locatorval >= lowval & locatorval < highval);
    
    locator_range = zeros(size(locator));
    locatorval_range = zeros(size(locatorval));
    
    locator_range(index) = locator(index);
    locatorval_range(index) = locatorval(index);
    
    sta = wc_locator_stimulus_to_sta(locator_range, stimulus, nlags);
    sta_val = wc_locator_stimulus_to_sta(locatorval_range, stimulus, nlags);
    
    nspks = sum(locator_range);

    subplot(length(prc)-1, 3, (i-1)*3+1);
    imagesc(sta);
    
    minmin = min(min(sta));
    maxmax = max(max(sta));
    boundary = max([abs(minmin) abs(maxmax)]);

    cmap = brewmaps('rdbu', 21);
    cmap = cmap([1:9 11 13:end],:); % get more contrast in STRF
    colormap(cmap);
    
    set(gca,'ydir', 'normal');
    set(gca, 'tickdir', 'out', 'ticklength', [0.025 0.025]);
    set(gca, 'clim', [-1.05*boundary-eps 1.05*boundary+eps]);
    
    title(sprintf('[%.0f, %.0f] percent = [%.1f, %.1f], N = %.0f\nEvents', ...
        percent(i), percent(i+1), lowval, highval, nspks));
       
    
    subplot(length(prc)-1, 3, (i-1)*3+2);
    imagesc(sta_val);
    
    minmin = min(min(sta_val));
    maxmax = max(max(sta_val));
    boundary = max([abs(minmin) abs(maxmax)]);

    cmap = brewmaps('rdbu', 21);
    cmap = cmap([1:9 11 13:end],:); % get more contrast in STRF
    colormap(cmap);
    
    set(gca,'ydir', 'normal');
    set(gca, 'tickdir', 'out', 'ticklength', [0.025 0.025]);
    set(gca, 'clim', [-1.05*boundary-eps 1.05*boundary+eps]);
    
    title(sprintf('N = %.0f\nValue', nspks));
    
    
%    edges = linspace(-10,10,51);
%    [count, bin] = histc(zsigfilt, edges);
%    prob = count ./ sum(count);
%    bar(edges, prob, 'histc');
    
    subplot(length(prc)-1, 3, i*3);
    hist(locatorval_range(locatorval_range>0), 50)
    xlim([0 20]);
    title('Event Values');

end % (for i)



return;






