function axon_abf_fra(varargin)
% axon_abf_fra FRA from abf file using TMF FRA params
%
% Asks for an abf file, then estimates trigger values, gets multi-unit
% responses, and plots the FRA and PSTH.
%

options = struct('abfile', [], ...
                 'paramdir', 'C:\Users\craig\OneDrive\Matlab\whole_cell', ...
                 'paramfile', 'freq_resp_area_stimulus_parameters_flo4000Hz_fhi40000Hz_nfreq45_natten8_nreps1_fs96000.mat');


options = input_options(options, varargin);


fra_param_file = fullfile(options.paramdir, options.paramfile);
load(fra_param_file, 'params');
frequency = params.stimulus_presentation_order(:,3);
attenuation = params.stimulus_presentation_order(:,4);

if max(attenuation) > 0
    attenuation = -attenuation;
end


if ( isempty(options.abfile) )
    [filename, pathname, filterindex] = uigetfile('*.abf', 'Pick an abf file');
    abspath = fullfile(pathname, filename);
else
    abspath = options.abfile;
end

[d, si, h] = abfload(abspath);

trigger_signal = d(:,3);
response_signal = d(:,1);

% Get rid of fluctuating baseline
response_smooth = smooth(response_signal, 10000);
response_signal = response_signal - response_smooth;


sampling_interval = si * 10^(-6);
fs = 1/sampling_interval;


% Get threshold crossings from response signal
nstd = 4;
spiketimes = axon_get_threshold_crossings(response_signal,nstd,fs);


% Assign response times to struct
thresh.spiketimes = spiketimes;
thresh.fs = fs;


% Get triggers
Threshold = -0.6;
[trigger] = axon_findtrig(trigger_signal, Threshold);


% Check to make sure correct number of triggers were found
if ( length(trigger) == length(frequency)+2 )
	trigger = [trigger(1) trigger(4:end)];
end

if length(trigger) ~= length(frequency)
    error('Wrong number of triggers.');
end




% Get frequency response area
fra = axon_freq_resp_area(thresh, trigger, frequency, attenuation);


% Get duration between triggers
dtrig = round((trigger(2)-trigger(1))/fs*1000);

% Plot fra and psth
hf = figure;

% Plot TMS style FRA
subplot(4,1,[1 2]);
axon_plot_tms_fra(frequency, attenuation, fra.resp);


% Plot imagesc style FRA
subplot(4,1,3);
axon_plot_freq_resp_area(fra);


% Plot PSTH
subplot(4,1,4);

spiketimes = [];
for i = 1:length(fra(1).resp)
    spiketimes = [spiketimes; fra(1).resp{i}];
end
edges = 0:5:dtrig;
count = histc(spiketimes,edges);
hb = bar(edges, count, 'histc');
xlim([0 300]);
set(hb, 'facecolor', 'b');
set(gca,'tickdir', 'out');
xlabel('Time (ms)');
ylabel('Number of Spikes');


ss = get(0,'screensize');
set(hf, 'position', [0.7*ss(3) 0.1*ss(4) 0.25*ss(3) 0.8*ss(4)]);



return









