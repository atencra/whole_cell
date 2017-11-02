function [trigger, trigger_signal] = axon_view_trigger(varargin)
% axon_view_trigger  Examine abf file and plot triggers
%
%   axon view_trigger() asks for an abf file, extracts the trigger
%   trace, finds the trigger times from the trace, and plots the 
%   trace and the trigger.
%
%   [trigger, trigger_signal] = axon_view_trigger() returns the 
%   trigger values and the trigger trace.
%
%   axon_view_trigger(trigger, trigger_signal) uses the previously 
%   obtained trigger and trace and plots the values.
%
%   All other input arguments cause an error.
%



if nargin ~= 2
    [filename, pathname, filterindex] = uigetfile('*.abf', 'Pick an abf file');
    abspath = fullfile(pathname, filename);
    
    [d, si, h] = abfload(abspath);
    trigger_signal = d(:,1);
    response_signal = d(:,2);
    
    sampling_interval = si * 10^(-6);
    fs = 1/sampling_interval;
    
    % Get triggers
    Threshold = -0.6;
    [trigger, trigger_signal] = axon_findtrig(trigger_signal, Threshold);
elseif nargin == 2
    trigger = varargin{1};
    trigger_signal = varargin{2};
else
    error('Input arguments are not correct.');
end



if length(trigger) == 677
	trigger = [trigger(1) trigger(4:end)];
end

if length(trigger) ~= 675
    error(sprintf('Wrong number of triggers. Should be 675, instead it is %.0f', ...
        length(trigger)));
end




hf = figure;

index = 1:length(trigger_signal);
plot(index, trigger_signal);
j = find(trigger<=max(index) & trigger >= min(index));
it = index(j);
t = trigger(j);

if ( ~isempty(j) )

    hold on;

    plot(t, 1.2, 'r^');
    for k = 1:length(t)
        plot([t(k) t(k)], max(trigger_signal)*[-1.2 1.2], 'r-');
    end

else
    error('No triggers found.');
end


axis([min(index) max(index) -1.25 1.25]);

ss = get(0,'screensize');
set(hf, 'position', [0.1*ss(3) 0.3*ss(4) 0.8*ss(3) 0.5*ss(4)]);



return


