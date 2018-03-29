sep = 40;
fname = ['los_MC_vs_SNR_sep_', num2str(sep)];

load(fname);

%%
figure

plot(result(1).SNR, result(1).rmse, 'LineWidth', 1.25);
hold on;    grid on;
plot(result(2).SNR, result(2).rmse, 'LineWidth', 1.25);
xlabel('snr/dB');
ylabel('rmse/degree');
title(['LOS (sep = ', num2str(sep), ')']);
legend('with MC', 'without MC');