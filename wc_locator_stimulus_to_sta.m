function sta = wc_locator_stimulus_to_sta(locator, stimulus, numtbins)
% wc_locator_stimulus_to_sta - STA from spike train locator and stimulus matrix
%
% sta = wc_locator_stimulus_to_sta(locator, stimulus, numtbins)
% -------------------------------------------------------------
%
% locator : vector of integers, where values greater
%           than one imply a spike, and values of 0
%           imply no spike
%
% stimulus : the entire ripple stimulus envelope file
%            as one matrix. Is contained in a .mat
%            file such as:
%
%           dmr-50flo-40000fhi-4SM-500TM-40db-48DF-21min_DFt2_DFf8-matrix.mat
%
% sta : spike triggered average. The sta has the
%       same number of frequencies as the stimulus
%       matrix while the number of time bins is 20.
%
% numtbins : how much memory to include in the sta. Default is 20.
% 


if ( nargin == 2 )
   numtbins = 20;
end

sta = zeros(size(stimulus,1), numtbins);


for i = numtbins:length(locator)
   if ( locator(i) )
      sta = sta + locator(i) * stimulus(:,i-numtbins+1:i);
   end
end


return;





