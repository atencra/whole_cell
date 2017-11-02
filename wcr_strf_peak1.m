
data_folder = 'C:\Users\Kim\Desktop';
excfile = fullfile(data_folder, '17914019.mat');
load(excfile, 'spk', 'trigger');
sprfile = 'rn1-500flo-40000fhi-4SM-40TM-40db-96khz-48DF-10min.spr';

strf = calculate_strf(spk, trigger, 0, sprfile); 

plot_strf_single(strf,trigger);
% plot_strf_single(strf,trigger, [4000 40000]);
% MTF
% mtf_plot_strf_rtf_mtf_method(strf,trigger);

