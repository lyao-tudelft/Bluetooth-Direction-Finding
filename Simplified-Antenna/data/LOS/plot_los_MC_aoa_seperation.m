load('los_MC_aoa_seperation.mat');
result = result_lpf;
%% visualize
name = {};

colors = hsv(length(result));

snr = [result.snr];
[~,idx] = sort(snr);
result = result(idx);

figure
for i = 1:2:length(result)
    plot(result(i).seperation, result(i).rmse, 'LineWidth', 1.25, 'Color', colors(i,:));
    grid on; hold on;
    plot(result(i+1).seperation, result(i+1).rmse,'--', 'LineWidth', 1.25, 'Color', colors(i,:));
    
    if result(i).antenna.MC
        name = [name, ['SNR = ', num2str(result(i).snr), 'dB, with MC']];
    else
        name = [name, ['SNR = ', num2str(result(i).snr), 'dB, without MC']];
    end
    
    if result(i+1).antenna.MC
        name = [name, ['SNR = ', num2str(result(i+1).snr), 'dB, with MC']];
    else
        name = [name, ['SNR = ', num2str(result(i+1).snr), 'dB, without MC']];
    end
    
end

xlabel('seperation/degree');
ylabel('rmse/degree');
title('LOS');
legend(name);

