function [fra] = axon_freq_resp_area(spk, trigger, frequency, attenuation)
%freq_resp_area   Calculate tuning curve from multi-unit data
%   Uses spike times and trigger values computed from other functions
%   to calculate the tuning curves.
%
%   [fra] = freq_resp_area(spk, trigger, frequency, attenuation)
%
%   spk : struct array holding the spike times.
%
%   trigger : array holding tone burst trigger times. 
% 
%   frequency : value for each tone trial.
%
%   attenuation : value for each tone trial.
%




% Apply the offset to the trigger times; change to number
% of samples from number of ms

fs = spk(1).fs;
trigger = trigger / fs * 1000;  % trig is now in ms
deltatrig = trigger(2) - trigger(1);


% Compute appropriate amplitude values, assuming the 
% normal 105 dB SPL sound output level
amp = 80 + attenuation;


if ( length(trigger) ~= length(frequency) || length(trigger) ~= length(attenuation) || ...
    length(frequency) ~= length(attenuation) )
    error('trigger and parameters  do not match.');
end

len = length(spk);

for i = 1:len

   spet = spk(i).spiketimes;
   resp = cell(length(frequency), 1);  % make the cell array

   for ii = 1:length(trigger)

      if ( ii ~= length(trigger) )
         index = find( spet >= trigger(ii) & spet < trigger(ii+1) );
         if ( ~isempty(index) )
            resp{ii} = spet(index) - trigger(ii);
         end
      else % for the last tone presentation only
         index = find( spet >= trigger(ii) & spet < trigger(ii)+deltatrig );
         if ( ~isempty(index) )
            resp{ii} = spet(index) - trigger(ii);
         end
      end
   
   end % (for ii)


%   fra(i).exp = spk(i).exp;
%   fra(i).site = spk(i).site;
%   fra(i).chan = spk(i).chan;
%   fra(i).model = spk(i).model;
%   fra(i).depth = spk(i).depth;
%   fra(i).position = spk(i).position;
%   fra(i).stim = spk(i).stim;
%   fra(i).atten = spk(i).atten;
   fra(i).freq = frequency;
   fra(i).amp = amp;
   fra(i).resp = resp;

end % (for i) 


return;

