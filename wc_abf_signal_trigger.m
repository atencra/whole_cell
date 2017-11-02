function [signal, trigger, fsnew] = wc_abf_signal_trigger(abfile)
% [signal, trigger, fs] = wc_abf_signal_trigger(abfile)
%
%
% [signal, trigger, fs] = wc_abf_signal_trigger(abfile)
%
% abfile : absolute path to abfile holding data.
%
% signal : processed signal to be used in STA analysis. Events will be
%   extracted from this signal.
%
% trigger : trigger times, in sample number.
%
% fs : sampling rate of signal. The recording in the abfile usually occurs
%   at 10000 Hz. This signal is downsampled to 1000 Hz. Thus, fs = 1000.
%
%
%


if nargin == 0
    abfile = [];
end


if ( isempty(abfile) )
    [filename, pathname, filterindex] = uigetfile('*.abf', 'Pick an abf file');
    abspath = fullfile(pathname, filename);
else
    abspath = abfile;
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

signal = filtfilt(hlp, 1, response_detrend);


return;










