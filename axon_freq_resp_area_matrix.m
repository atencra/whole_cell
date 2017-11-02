function [frequnique, ampunique, tc] = axon_freq_resp_area_matrix(data, win)
% Frequency vs Level matrix for FRA responses

freq = data.freq;
amp = data.amp;

frequnique = unique(freq);
ampunique = unique(amp);

tc = zeros(length(ampunique), length(frequnique));

for i = 1:length(freq)

   resp = data.resp{i};
   spetindex = find( resp>=win(1) & resp<=win(2) );

   if ( ~isempty(spetindex) )

      numspikes = length(spetindex);

      inda = find( amp(i) == ampunique); 
      indf = find( freq(i) == frequnique);

      tc(inda, indf) = tc(inda, indf) + numspikes;

   end

end % (for i)

return


