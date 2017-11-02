function whole_cell_sta_analysis
%
% axon_abf_fra FRA from abf file using TMF FRA params
%
% Asks for an abf file, then estimates trigger values, gets multi-unit
% responses, and plots the FRA and PSTH.
%



% To explore the thresholding and peakfinding:

library('whole_cell');
file = '17914009.abf';
datapath = 'c:\users\craig\desktop\20171028_to_Craig_to_test_Weight\17914009_rn1_-80mV\'
abfile = fullfile(datapath, file);

[time, sig, sigd, sigf] = wc_process_abf_signal('abfile', abfile);

ca; wc_plot_process_abf_signal(time,sig,sigd,sigf,[3 6]);



% To get the signal and trigger for STA processing

[signal, trigger, fs] = wc_abf_signal_trigger(abfile);


% To plot STAs at different thresholds

wc_plot_sta_threshold(signal, trigger, fs)

% What's left: 
1. make stimulus-observation matrix
2. make multiple response signals for the different thresholds
3. each response signal has to take into account the matrix size
4. estimate STA using only events (0/1s)
5. estimate STA using event values (real numbers)


return;






