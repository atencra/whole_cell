
[filename, pathname, filterindex] = uigetfile('*.abf', 'Pick an abf file');
abspath = fullfile(pathname, filename);

[d, si, h] = abfload(abspath);
trigger_signal = d(:,3);
response_signal = d(:,1);

sampling_interval = si*10^(-6); % usec -> sec (ex) si=100usec here
fs = 1/sampling_interval;

Threshold = -0.6;
[trigger] = axon_findtrig(trigger_signal, Threshold);
%trigger=(trigger*(10^(-4)))'; % multiply the sampling interval 100usec; this came from the abfload function
save 17925016_raw response_signal trigger_signal fs

