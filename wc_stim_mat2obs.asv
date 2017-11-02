function [stim] = wc_stim_mat2obs(stimfile, nlags)
% wc_stim_mat2obs  Frequency-time stimulus to MNE stimulus matrix and spike train from files
% 
%    Make a new stimulus matrix that can be used in the MNE analysis. The 
%    new matrix takes into account the stimulus dimensionality that
%    is used in the receptive field analysis.
% 
%    [stim] = wc_stim_mat2obs(stimfile, nlags)
%    ----------------------------------------------------------------------
%
%    stimfile : Name of .mat file holding stimulus matrix. Usually something
%    like 'dmr-500flo-20000fhi-4SM-40TM-40db-44khz-10DF-15min_DFt22_DFf7-matrix.mat'
%
%    Alternatively, stimfile may be a stimulus matrix that was contained in
%    a *.mat file such as the one mentioned above.
% 
% 
%    nlags : number of time bins of memory for the MNE stimulus. Default is 20.
% 
% 
%    stim : stimulus matrix where each row corresponds to one trial. One trial
%    is nf x nlags. stim will have dimensions (nf*nlags) X (Nsamples - (nlags-1))
%    where Nsamples is the number of time bins in the original stimulus matrix
% 
% 
%    To check the outputs, you can quickly estimate the STA from stim
%    and resp:
%
%        sta = stim' * resp;
%        imagesc(reshape(sta, nf, nlags));
% 



% Process input arguments

narginchk(1,2);


% Assign missing input args. We assign x0 later, since we need to
% know the number of frequencies in the stimulus if we want to give
% it a default value.
if ( nargin == 1 )
   nlags   = 20; % use 20 time bins for memory of receptive field
end



% If stimfile is a string, load the file. If a matrix, reassign to new
% variable
if ( isstr(stimfile) ) % Load stimulus matrix from file
   stimulus = load(stimfile);
   stimulus = stimulus.stimulus;
else
   stimulus = stimfile;
   clear('stimfile');
end

[nf, nsamples] = size(stimulus); % dimension of stimulus matrix

Nsamples = nsamples - (nlags-1);
Ndimtotal = nf*nlags; % total stimulus dimensions = #freq's by #time lags

stim = zeros(Nsamples,Ndimtotal);

for i = 1:Nsamples
    chunk = stimulus(:,i:i+nlags-1);
    stim(i,:) = chunk(:)'; % make a row vector and assign to stim
end



return;















