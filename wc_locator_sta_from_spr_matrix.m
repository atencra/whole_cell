function [taxis, faxis,locator, locatorval, sta, averate, numspikes, pp, spln] = ...
wc_locator_sta_from_spr_matrix(specfile, spet, spetval, trigger, fsad, spl, varargin)
%
% Spike train and strfs for ripple stimulation
%
% [taxis,faxis,locator1, locator2, sta1,sta2,averate1,averate2,numspikes1,numspikes2,pp,spln] = ...
%       locator_sta_from_spr_matrix(specfile, spet, trigger, fsad, spl, varargin)
%
% Required inputs 
%
%	specfile : Spectral Profile File
%	spet : Array of spike event times in sample number
%	trigger : Array of Trigger Times
%	fsad : Sampling Rate for A/D system (for spet and trigger)
%	spl : Signal RMS Sound Pressure Level
%
%
% Optional name/value pair inputs:
%
%	't1' and 't2' : Evaluation delay interval for WSTRF(T,F), in sec
%               T E [- T1 , T2 ], Note that T1 >= 0, T2 > 0
%               Default : t1 = 0.1, t2 = 0.2
%
%       'mdb' : Signal Modulation Index in dB. Default = 40
%       'modtype' : Kernel modulation type : 'lin' or 'dB'. Default = 'dB'
%       'sound' : Sound Type. Default = 'MR'
%       'sprtype' : SPR File Type : 'float' or 'int16'. Default = 'float'
%
% Outputs:
%
%	taxis: Time Axis
%	faxis: Frequency Axis (Hz)
%	sta: Spectro-Temporal Receptive Field
%	averate: Zeroth-Order Kernels ( Average Number of Spikes / Sec )
%	numspikes: Number of Spikes
%	pp: Power Level
%	spln: Sound Pressure Level per Frequency Band
%	

narginchk(6,18);

options = struct('t1', 0.1, 't2', 0.2, 'mdb', 40, 'modtype', 'dB', 'sound', 'MR', 'sprtype', 'float');
options = input_options(options, varargin);



% Loading Parameter Data
paramfile = strrep(specfile, '.spr', '_param.mat');
load(paramfile);


% Clear possible useless variables in the param file
clear App MaxFM XMax Axis MaxRD RD f phase Block Mn RP f1 
clear f2 Mnfft FM N fFM fRD NB NS LL filename M X fphase Fsn


if ~strcmp(options.sprtype,'float')
    error('spr file must be float');
end


mintime = min([trigger(:)' spet(:)']);
spet = spet - mintime + 1;
trigger = trigger - mintime + 1;


Ntrials = NT*length(trigger);
locator = zeros(Ntrials,1);
locatorval = zeros(Ntrials,1);

% Reading Spectral Profile File
stimulus = zeros(NF, Ntrials);
fid = fopen(specfile);
frewind(fid);

for trigcount = 1:length(trigger)
    segment = fread(fid,NT*NF,'float');
    segment = reshape(segment,NF,NT);
    offset = (trigcount-1)*NT;
    stimulus(1:NF, (1:NT) + offset) = segment;
end

fclose(fid);


for trigcount = 2:length(trigger)-1 

    % Finding SPET between triggers. Resampling spet relative to the %    Spectral Profile samples
    index = find( spet>=trigger(trigcount) & spet<trigger(trigcount+1) );
    spet_segment = spet(index);
    values_segment = spetval(index_spet_segment);

    for k = 1:length(spet_segment)
        index_ripple = ceil( (spet_segment(k)-trigger(trigcount)+1) * Fs / fsad / DF );      
        locator(index_ripple+(trigcount-1)*NT) = locator(index_ripple+(trigcount-1)*NT) + 1;
        locatorval(index_ripple+(trigcount-1)*NT) = locatorval(index_ripple+(trigcount-1)*NT) + values_segment(k);
    end

end



[n, nt, nf] = ripple_stim_length(specfile);

index_min = min( [length(locator) n/nf] );
locator = locator1( 1:index_min );




% Converting Temporal Delays to Sample Numbers
n1 = round( options.t1 * Fs / DF);
n2 = round( options.t2 * Fs / DF);


sta = zeros(size(stimulus,1), n1+n2+1);
numspikes = 0;
for i = (n2+1):(length(locator1)-n1)
   if ( locator(i) )
      sta = sta + locator(i) * stimulus(:, (i-n2):(i+n1));
      numspikes = numspikes + locator(i);
   end
end





stim_duration = ( max(trigger) - min(trigger) ) / fsad;

averate = numspikes / stim_duration;

% get time and frequency axes for the receptive field
taxis = (-n2:n1) / (Fs/DF);


if strcmp(modType,'dB')

    %Finding Mean Spectral Profile and RMS Power
    spln = spl - 10*log10(NF); % Normalized SPL per frequency band

    if strcmp(Sound,'RN')
        rmsp = -MdB/2; % RMS value of normalized Spectral Profile
        pp = MdB^2/12; % Modulation Depth Variance 
    elseif strcmp(Sound,'MR')
        rmsp = -MdB/2; % RMS value of normalized Spectral Profile
        pp = MdB^2/8; % Modulation Depth Variance 
    end
    
    % How to scale the 'dB' STRFs
    %STRF1=STRF1+ MdB*[S1(:,M-(N2-L-1):M) S2(:,1:L+N1)] - RMSP;
    %o1=No1+1;
    %TRF1=Wo1/PP*fliplr(STRF1)/No1;
    %TRF2=Wo2/PP*STRF2/No2;
    %axis=(-N1:N2-1)/(Fs/DF);

end



return;










