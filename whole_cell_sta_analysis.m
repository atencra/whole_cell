function whole_cell_sta_analysis
%
% axon_abf_fra FRA from abf file using TMF FRA params
%
% Asks for an abf file, then estimates trigger values, gets multi-unit
% responses, and plots the FRA and PSTH.
%

pkg load signal;
libmonty;

stimfolder = 'c:\stimuli';
sprfile = 'rn1-500flo-40000fhi-4SM-40TM-40db-96khz-48DF-10min_DFt5_DFf5.spr';
sprfile = fullfile(stimfolder, sprfile);


matfile = 'C:/Users/craig/Desktop/20171028_to_Craig_to_test_Weight/17914009_rn1_-80mV/17914009_raw.mat'

extrema = -1;


% To explore the thresholding and peakfinding:
%
%[time, sig, sigdetrend, sigfilt, trigger] = wc_process_raw_signal(matfile, extrema, interval)
%
%wc_plot_process_abf_signal(time, sig, sigdetrend, sigfilt, interval);




%[time, sig, sigd, sigf] = wc_process_abf_signal('abfile', abfile);
%
%ca; wc_plot_process_abf_signal(time,sig,sigd,sigf,[3 6]);



% To get the signal and trigger for STA processing
%
%[signal, trigger, fs] = wc_abf_signal_trigger(abfile);

[signal, trigger, fs, sigraw, sigdetrend] = wc_raw_signal_trigger(matfile, extrema);

time = (0:length(signal)-1) / fs;
wc_plot_process_abf_signal(time, sigraw, sigdetrend, signal, [0 10]);

return;


% To plot STAs at different thresholds

wc_plot_sta_threshold(signal, trigger, fs, sprfile);

% What's left: 
% 1. make stimulus-observation matrix
% 2. make multiple response signals for the different thresholds
% 3. each response signal has to take into account the matrix size
% 4. estimate STA using only events (0/1s)
% 5. estimate STA using event values (real numbers)


return;






