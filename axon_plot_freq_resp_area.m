function axon_plot_freq_resp_area(fra, win)
%plot_freq_resp_area  Plot FRA using TMS form
%
%   fra is a struct array holding the tuning curve calculations
%   obtained using axon_freq_resp_area.m
%
%   win specifies ms over which the tuning curve should be calculated.
%      The default is 0 to 50, [0 50], ms
%

if ( nargin < 1 || nargin > 3 )
   error('You need 1 or 3 input args.');
end

if ( nargin == 1 )
   win = [0 50];
end


% Get some preliminary data.

amp = fra(1).amp; % max sound amplitude
freq = fra(1).freq; % vector of frequencies
%depth = fra(1).depth; % depth of probe tip
%exp = fra(1).exp; % experiment
%site = fra(1).site; % penetration number
%stim = fra(1).stim; % type of stimulus


% Data for nice tick labels for the plots.

atick = 1:4:length(unique(amp));
temp = unique(amp);
alabel = temp(atick);

ftick = [1:5:45];
temp = unique(freq);
temp = temp/1000;
flabel = round(10*temp(ftick))/10;


% Plot the data.
% h = figure;
% ss = get(0, 'screensize');
% set(h, 'position', [0.5*ss(3) 0.5*ss(4) 0.25*ss(3) 0.25*ss(4)]);

for i = 1:length(fra)

   [f, a, tc] = axon_freq_resp_area_matrix(fra(i), win);

   imagesc(tc);
   grid on;
   axis xy;
   set(gca, 'tickdir', 'out');
   colormap(flipud(colormap(gray)));

   flabel = round(flabel*10)/10; 
   set(gca,'xtick', ftick, 'xticklabel', flabel);
   xlabel('Freq (kHz)');

   set(gca,'ytick', atick, 'yticklabel', alabel);
   ylabel('dB SPL');

   nspikes = sum(sum(tc));

end

return;


