function axon_plot_tms_fra(f,a,resp)
% TMS style FRA plot

if ( max(f) > 1000 )
    f = f / 1000;
end

uf = unique(f);
ua = unique(a);

xtick = round(uf(1:4:end)*10)/10; 
doct = log2(uf(2)/uf(1));
fmin = min(f) .* 2.^ (-doct);
fmax = max(f) .* 2.^ (doct);


hold on;
patch([fmin fmin fmax fmax], [-80 10 10 -80], 'k');
for i = 1:length(f)
    spiketimes = resp{i};
    good_times = find(spiketimes<55);
    nspks = length(good_times);
    if nspks > 0
        plot([f(i) f(i)], [a(i)-nspks/5 a(i)+nspks/5], '-', 'color', 'y');
    end
end

set(gca, 'xtick', xtick, 'xticklabel', xtick);
set(gca,'xscale', 'log');

xlim([fmin fmax]);


set(gca, 'ytick', ua, 'yticklabel', ua);
ylim([-80 10]);
%ylim([min(ua)-max(resp) max(ua)+max(resp)]);


set(gca,'tickdir', 'out');
set(gca, 'ticklength', [0.025 0.025]);


return;

