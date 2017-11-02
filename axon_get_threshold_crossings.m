function crossings = axon_get_threshold_crossings(response_signal, nstd, fs)
% Get threshold crossing times. Equivalent to multi-unit data
%


%Number of data values to read in each iteration
blockSize = 10*1024;


thresh = nstd * std(response_signal(:));

init_value = 0;
nblocks = 0;
crossings = [];


blockData = [init_value; response_signal];

    
    %Finding threshold crossings in the current block
    ind_supra = find(blockData(2:end) > thresh);
    ind_cross = ind_supra(find(blockData(ind_supra) <= thresh));
    crosstimes = (nblocks*blockSize + ind_cross - 1)/fs*1000; %converting samples into msec
    crossings = [crossings; crosstimes];
    
    %Updating value to append to beginning of next block
    init_value = blockData(end);
    
    %Updating number of blocks
    nblocks = nblocks + 1;
    
%     plot(blockData), hold on;
%     plot(xlim,thresh*[1 1],'k--');
%     scatter(ind_cross,blockData(ind_cross+1),'rx'), hold off;
%     pause;

return;

