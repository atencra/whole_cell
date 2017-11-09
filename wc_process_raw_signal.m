function [time, sig, sigdetrend, sigfilt, trigger] = wc_process_raw_signal(matfile, extrema, interval)
% wc_process_raw_signal Load and process raw abf recording stored in .mat file
%
% [time, sig, sigdetrend, sigfilt, trigger] = wc_process_raw_signal(matfile, extrema, interval) 
%
% loads the response_signal and trigger_signal variables stored in matfile, 
% and processes them to remove noise, etc.
%
% extrema : 1 if peaks are positive (inhibitory currents or current clamp)
%          -1 if peaks are negative (excitatory currents). 
%           Default = -1.
%
% The resulting signal is plotted over the time boundaries listed in interval.
% interval is a 1x2 vector = [lowval hival], where lowval and hival are in seconds.
%

pkg load signal
libmonty;

%%%%%%%%%%%% need to adjust signal for extrema

narginchk(1,3);

if nargin == 1
    interval = [];
    extrema = -1;
end

if nargin == 2
    interval = [];
    if isempty(extrema)
        extrema = -1;
    end
end     

if ( isempty(interval) )
    tmin = -inf;
    tmax = inf;
else
    if length(interval) == 1
        tmin = -inf;
        tmax = interval;
    else
        tmin = min(interval);
        tmax = max(interval);
    end
end


load(matfile, 'response_signal', 'trigger_signal', 'fs');
response_signal = extrema * response_signal;

fsnew = 1000;

trigger = axon_findtrig(trigger_signal, -0.5);


% Resample signals from 10000 Hz to 1000 Hz
sig = resample(response_signal, fsnew, fs);
trigger = ceil( trigger * fsnew / fs );


time = (0:length(sig)-1) / fsnew;

% Get rid of fluctuating baseline
sigsmooth = smoothsig(sig, 10000);
sigdetrend = sig - sigsmooth;

signal_sd = std(sigdetrend);
signal_mean = mean(sigdetrend);
index = find(sigdetrend < (signal_mean - 3 * signal_sd));
sigdetrend(index) = signal_mean;


f1 = 3;
f2 = 55;
tw = 5;
att = 30;
hlp = bandpass(f1, f2, tw, fsnew, att, 'n');

sigfilt = filtfilt(hlp, 1, sigdetrend);

wc_plot_process_abf_signal(time, sig, sigdetrend, sigfilt, interval);

return;




library('strfbox');

[taxis, faxis, locator1, locator2, sta1, sta2, averate1, averate2, numspikes1, numspikes2, pp, spln] = ...
    locator_sta_from_spr_matrix(specfile, spet, trigger, fsad, spl, varargin)






