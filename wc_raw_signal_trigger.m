function [signal, trigger, fs, sig, sigdetrend] = wc_raw_signal_trigger(matfile, extrema)
% wc_raw_signal_trigger Load and process raw abf recording stored in .mat file
%
% [signal, trigger, fs, sigraw, sigdetrend] = wc_raw_signal_trigger(matfile) 
%
% matfile : absolute path to matfile holding data.
%
% extrema : 1 if peaks are positive (inhibitory currents or current clamp)
%          -1 if peaks are negative (excitatory currents). 
%           Default = -1.
%
% signal : processed signal to be used in STA analysis. Events will be
%   extracted from this signal. signal is downsampled to a sampling rate of
%   1000 Hz.
%
% sigraw : original signal, just downsampled to 1000 Hz.
%
% sigdetrend : sigraw with fluctuating trend removed.
%
% trigger : trigger times, in sample number. Also relative to a sampling 
%   rate of 1000 Hz.
%
% fs : sampling rate of signal. The recording usually occurs
%   at 10000 Hz. This signal is downsampled to 1000 Hz. Thus, fs = 1000.
%

pkg load signal
libmonty;


narginchk(1,2);

if nargin == 1
    extrema = -1;
end

if nargin == 2
    if isempty(extrema)
        extrema = -1;
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

sig_sd = std(sigdetrend);
sig_mean = mean(sigdetrend);
index = find(sigdetrend < (sig_mean - 3 * sig_sd));
sigdetrend(index) = sig_mean;


f1 = 3;
f2 = 55;
tw = 5;
att = 30;
hlp = bandpass(f1, f2, tw, fsnew, att, 'n');

sigfilt = filtfilt(hlp, 1, sigdetrend);

signal = sigfilt;
fs = fsnew;

if nargout == 1
    varargout{1} = sig;
end

if nargout == 2
    varargout{1} = sig;
    varargout{2} = sigdetrend;
end


return;








