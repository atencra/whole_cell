function [time, response_signal, response_detrend, response_filtered] = wc_process_raw_signal(matfile, interval)
% wc_process_raw_signal Load and process raw abf recording stored in .mat file
%
% [time, response_signal, response_detrend, response_filtered] = ...
%       wc_process_raw_signal(matfile, interval) 
%
% loads the response_signal and trigger_signal variables stored in filename, 
% and processes them to remove noise, etc.
%
% The resulting signal is plotted over the time boundaries listed in interval.
% interval is a 1x2 vector = [lowval hival], where lowval and hival are in seconds.
%


%%%%%%%%%%%% need smooth function from matlab
%%%%%%%%%%%% need to adjust signal for extrema

narginchk(1,2);

if nargin == 1
    interval = [];
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


fsnew = 1000;

trigger = axon_findtrig(trigger_signal, -0.5);


% Resample signals from 10000 Hz to 1000 Hz
response_signal = resample(response_signal, fsnew, fs);
trigger = ceil( trigger * fsnew / fs );


time = (0:length(response_signal)-1) / fsnew;

% Get rid of fluctuating baseline
response_smooth = smooth(response_signal, 10000);
response_detrend = response_signal - response_smooth;

response_sd = std(response_detrend);
response_mean = std(response_detrend);
index = find(response_detrend > 3 * response_sd);
response_detrend(index) = response_mean;


f1 = 3;
f2 = 55;
tw = 5;
att = 30;
hlp = bandpass(f1, f2, tw, fsnew, att, 'n');

response_filtered = filtfilt(hlp, 1, response_detrend);


%response_3p = smooth3p(response_detrend);


wc_plot_process_abf_signal(time, response_signal, ...
                                 response_detrend, ...
                                 response_filtered, ...
                                 options.interval);

return;




library('strfbox');

[taxis, faxis, locator1, locator2, sta1, sta2, averate1, averate2, numspikes1, numspikes2, pp, spln] = ...
    locator_sta_from_spr_matrix(specfile, spet, trigger, fsad, spl, varargin)






