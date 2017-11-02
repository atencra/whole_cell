function [time, response_signal, response_detrend, response_filtered] = wc_process_abf_signal(varargin)
% axon_abf_fra FRA from abf file using TMF FRA params
%
% Asks for an abf file, then estimates trigger values, gets multi-unit
% responses, and plots the FRA and PSTH.
%

options = struct('abfile', [], ...
                 'interval', []);


options = input_options(options, varargin);


if ( isempty(options.interval) )
    tmin = -inf;
    tmax = inf;
else
    if length(options.interval) == 1
        tmin = -inf;
        tmax = options.interval;
    else
        tmin = min(options.interval);
        tmax = max(options.interval);
    end
end



if ( isempty(options.abfile) )
    [filename, pathname, filterindex] = uigetfile('*.abf', 'Pick an abf file');
    abspath = fullfile(pathname, filename);
else
    abspath = options.abfile;
end

[d, si, h] = abfload(abspath);

sampling_interval = si * 10^(-6);
fs = 1/sampling_interval;

fsnew = 1000;

trigger_signal = d(:,3);
response_signal = d(:,1);


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






