function varargout = plot_strf_single(strf,trigger,flim,tlim)
% plot_strf_single Show STRF for one neuron
% 
%     plot_strf_single(strf,trigger,flim,tlim) displays the significant STRF, 
%     for a p-value of 0.01.
% 
%     strf : single element from an strf struct array.
%     trigger : vector of trigger times, in sample number.
%     flim : optional frequency limits for STRF. Default is entire range.
%     tlim : optional temporal limits for STRF. Default is entire range.
% 
%     rfsig = plot_strf_single(strf,trigger,flim,tlim) Returns the significant
%     STRF that was plotted. rfsig is a matrix.


if ( nargin < 0 || nargin > 4 )
   error('You need 2 to 4 input args.');
end

if ( nargin == 2 )
   flim = [];
   tlim = [];
end

if ( nargin == 3 )
   tlim = [];
end


% Sort the frequency-respose data according to actual depth position.
% To do this we first make a matrix having the first column as 
% channel number and the second column as the depth.

pos = [strf.position];
if ( ~isempty(pos) )
    [dummy, indpos] = sort(pos);
    strf = strf(indpos);
end

time = 1000 .* strf(1).taxis; % change to ms
freq = strf(1).faxis;
depth = strf(1).depth;
site = strf(1).site;
exp = strf(1).exp;
stim = strf(1).stim;


% Now get some time tick marks
if ( isempty(tlim) )
   t = round(min(time)):abs(round(min(time))):max(time);
   ttick = [];
   for i = round(min(time)):abs(round(min(time))):max(time)
      temp = abs(i+0.01-time);
      ttick = [ttick find(temp == min(temp))];
   end
else

   dttick = ( abs(tlim(1)) + abs(tlim(2)) ) / 5;
   t = round(tlim(1)):dttick:round(tlim(2));

   index_tlim_min = find( time >= tlim(1) );
   index_tlim_min = min(index_tlim_min);

   index_tlim_max = find( time <= tlim(2) );
   index_tlim_max = max(index_tlim_max);

   ttick = [];
   for i = round(tlim(1)):dttick:round(tlim(2))
      temp = abs(i+0.01-time);
      ttick = [ttick find(temp == min(temp))];
   end
   ttick = ttick - (index_tlim_min - 1);
end


% Now we get some frequency tick marks
if ( isempty(flim) )
    ftick = [1 round(length(freq)/2) length(freq)];
    noct = log2(max(freq)/min(freq));
    f = [100*round(min(freq)/100) 100*round(min(freq).*2^(noct/2)/100) 100*round(max(freq)/100)];

    % Note: I multiply and divide by 100 so that the highest resolution is
    % hundreds, i.e. 510 will be shown as 500, and 1120 will be 1100.

% -------------------------
% Old Code
% -------------------------
%   nocts = floor(log2(max(freq)/min(freq)));
%   f = round(min(freq).*2.^(0:2:nocts));
%   ftick = [];
%   for i = 0:2:nocts
%      temp = abs(i+0.001-log2(freq/min(freq)));
%      ftick = [ftick find(temp == min(temp))];
%   end

else

   index_flim_min = find( freq >= flim(1) );
   index_flim_max = find( freq <= flim(2) );
   index_flim_min = min(index_flim_min);
   index_flim_max = max(index_flim_max);
   index_flim_mid = round( mean([index_flim_max index_flim_min]));
   ftick = [index_flim_min index_flim_mid index_flim_max];
   ftick = ftick - (index_flim_min - 1);
   noct = log2(flim(2)/flim(1));
   f = [100*round(flim(1)/100) 100*round(flim(1).*2^(noct/2)/100) 100*round(flim(2)/100)];

% -------------------------
% Old Code
% -------------------------
%   nocts = floor(log2(max(flim(2))/min(flim(1))));
%   f = round(min(flim(1)).*2.^(0:1:nocts));
%   ftick = [];
%   for i = 0:1:nocts
%      temp = abs(i+0.001-log2(freq/min(flim(1))));
%      ftick = [ftick find(temp == min(temp))];
%   end
%   index_flim_min = find( freq >= flim(1) );
%   index_flim_max = find( freq <= flim(2) );
%   index_flim_min = min(index_flim_min);
%   index_flim_max = max(index_flim_max);
%   ftick = ftick - (index_flim_min - 1);
end



fs = strf(1).fs; % sampling rate of A/D system
mdb = strf(1).mdb;
sigma2 = (mdb)^2 / 8; % variance of dynamic moving ripple
sigma = sqrt(sigma2); % std of dynamic moving ripple
dur = ( trigger(end)-trigger(1) ) / fs; % total duration of ripple, in sec

%PLOT STRF
chan = strf.chan(1);

if ( isempty(strf.model) )
    model = 0;
else
    model = strf.model(1);
end

if ( isempty(strf.position) )
    position = 0;
else
    position = strf.position;
end

rf = strf.rfcontra;
p = 0.005;
n0 = strf.n0contra;
w0 = strf.w0contra;
%[rfsig] = significant_strf(rf, p, n0, mdb, dur);
rfsig = rf;

if ( ~isempty(strf.rfipsi) )
    rfIpsi = strf.rfipsi;
    n0_ipsi = strf.n0ipsi;
    w0_ipsi = strf.w0ipsi;
    [rfsigIpsi] = significant_strf(rfIpsi, p, n0_ipsi, mdb, dur);
end





if ( ~isempty(flim) )
    rfsig = rfsig(index_flim_min:index_flim_max, :);
    if ( ~isempty(strf.rfipsi) )
        rfsigIpsi = rfsigIpsi(index_flim_min:index_flim_max, :);
    end
end

if ( ~isempty(tlim) )
    rfsig = rfsig(:, index_tlim_min:index_tlim_max);
    if ( ~isempty(strf.rfipsi) )
        rfsigIpsi = rfsigIpsi(index_flim_min:index_flim_max, :);
    end

end


figure;

if ( ~isempty(strf.rfipsi) )
    subplot(2,1,1);
end

imagesc(single(rfsig));
cmap = brewmaps('rdbu', 21);
cmap = cmap([1:8 11 14:end],:);
colormap(cmap);
set(gca,'ydir', 'normal');
set(gca, 'tickdir', 'out', 'ticklength', [0.025 0.025]);
minmin = min(min(rfsig));
maxmax = max(max(rfsig));
boundary = max([abs(minmin) abs(maxmax)]);
set(gca, 'clim', [-1.05*boundary-eps 1.05*boundary+eps]);
set(gca,'xtick', ttick, 'xticklabel',t);
xlabel('Time Before Spike (ms)');

if ( max(freq) > 40 )
   f = f ./ 1000;
end
set(gca,'ytick', ftick, 'yticklabel',f);
ylabel(sprintf('Frequency (kHz)'));

if ( ~isempty(strf.rfipsi) )
    title(sprintf('Contra: %.0f-%.0f %.0fum n0=%.0f w0=%.2f', chan, model, position, n0, w0));
else
    title(sprintf('%.0f-%.0f %.0fum n0=%.0f w0=%.2f', chan, model, position, n0, w0));
end





if ( ~isempty(strf.rfipsi) )
    subplot(2,1,2);
    imagesc(single(rfsigIpsi));
    cmap = brewmaps('rdbu', 21);
    cmap = cmap([1:8 11 14:end],:);
    colormap(cmap);
    set(gca,'ydir', 'normal');
    set(gca, 'tickdir', 'out', 'ticklength', [0.025 0.025]);
    minmin = min(min(rfsigIpsi));
    maxmax = max(max(rfsigIpsi));
    boundary = max([abs(minmin) abs(maxmax)]);
    set(gca, 'clim', [-1.05*boundary-eps 1.05*boundary+eps]);
    set(gca,'xtick', ttick, 'xticklabel',t);
    xlabel('Time Before Spike (ms)');

    set(gca,'ytick', ftick, 'yticklabel',f);
    ylabel(sprintf('Frequency (kHz)'));

    title(sprintf('Ipsi: %.0f-%.0f %.0fum n0=%.0f w0=%.2f', ...
        chan, model, position, n0_ipsi, w0_ipsi));
end % (if)


if(nargout == 1)
    varargout{1} = rfsig;
end

return;





