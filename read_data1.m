
[filename, pathname, filterindex] = uigetfile('*.abf', 'Pick an abf file');
abspath = fullfile(pathname, filename);

[d, si, h] = abfload(abspath);
% trigger_signal = d(:,3);
% response_signal = d(:,1);

response_smooth = smooth(response_signal, 80000);
response = response_signal - response_smooth;

sampling_interval = si*10^(-6); % usec -> sec (ex) si=100usec here
fs = 1/sampling_interval;

% Threshold = -0.6;
% [trigger] = axon_findtrig(trigger_signal, Threshold);
%trigger=(trigger*(10^(-4)))'; % multiply the sampling interval 100usec; this came from the abfload function
plot(trigger_signal); % this is for ginput
[trig1, y1] = ginput(1);
[trig2, y2] = ginput(1);
trigger = linspace(trig1, trig2, 1795); % 1795 is # of triggers for rn1
% 1799 is for rn4, 8, 16

spet = spet_sampling';
response_msec_unit = spet/10; % the msec unit

spk.exp = '17914019'; % change the file name for each experiment
spk.depth = 410; % change the depth for each experiment
spk.spiketimes = response_msec_unit;
spk.site = 1;
spk.chan = 1;
spk.model = 0;
spk.atten = 0;
spk.fs = 10000; % only 03/29 data used fs=20000
spk.stim = 'dmr'; % 'dmr' for dynamic,  'rn' for ripple
spk.position = 1; 
spk.amplitude = Amp_dist; 

save 17914019 spk trigger


% plot(response_signal);
% save 17531015_processed response trigger_signal trigger fs


min_amp=min(spk.amplitude);
max_amp=max(spk.amplitude);
edges = min_amp:0.5:max_amp;
count = histc(spk.amplitude,edges);
hb = bar(edges, count, 'histc');
xlim([min_amp max_amp]);
set(hb, 'facecolor', 'black');
set(gca,'tickdir', 'out');
xlabel('EPSC amplitude (pA)');
ylabel('Number of events');

