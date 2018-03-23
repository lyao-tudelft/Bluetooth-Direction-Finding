% close all;
%%
file = 'MUSIC_result_agianst_snr_with_overlapping_array_filtered_MC.mat';

load(file);
close

SAVE = true;

%%
% aoaDifferenceAverage
% aoaDifferenceRms
% aoaDifferenceVar
% aoaRMS
% aoaVar
% aoaAverage

% toPlot = {sqrt(resultMUSIC.aoaVar),...
%             sqrt(resultMUSICoverlapped.aoaVar)};

toPlot = {resultMUSIC.aoaDifferenceAverage,...
            resultMUSICoverlapped.aoaDifferenceAverage};

f1 = figure;
plot(resultMUSIC.snr, toPlot{1}, 'linewidth', 1.25);
hold on;    grid on;
plot(resultMUSIC.snr, toPlot{2}, 'linewidth', 1.25);
plot(resultMUSIC.snr, toPlot{2}-toPlot{1}, 'linewidth', 1.25);
xlabel('SNR/dB');
ylabel('error/degree');
title('Mean Absolute Error');
legend('Un-overlapping','Overlapping','Un-overlapping-Overlapping');

%%
% figure
% plot(resultMUSIC.snr, toPlot{1}-toPlot{2}, 'linewidth', 1.25);
% grid on;
% xlabel('SNR/dB');
% ylabel('difference/degree');
% title('Difference between Overlapping and Un-overlapping Array');

%%
% close all
%% Histogram

snr = -32;
iSNR = find(resultMUSIC.snr==snr);
aoa = resultMUSIC.aoaTrue;

figure
h1 = histogram(resultMUSIC.aoaDifference(iSNR,:), 20, 'Normalization', 'cdf');
grid on;    hold on;
h2 = histogram(resultMUSICoverlapped.aoaDifference(iSNR,:), 20, 'Normalization', 'cdf');

ang = linspace(0,180,10000);
p = abs(pi*sind(ang))/360;
pnorm = [];
for i = 1:length(h1.BinEdges)-1
    [~,i1] = min(abs(ang-h1.BinEdges(i)));
    [~,i2] = min(abs(ang-h1.BinEdges(i+1)));
    pnorm = [pnorm, trapz(ang(i1:i2), p(i1:i2))];
end
plot(h1.BinEdges(1:end-1)+h1.BinWidth/2, pnorm, 'LineWidth', 1.5);
yl = ylim;
line([aoa aoa], yl,'LineStyle', '--', 'Color', 'black', 'LineWidth', 1.25);

xlabel('angle/degree');
title('Histogram');
legend('un-overlapping','overlapping','True AoA');
text(0.8, 0.75, ['snr = ', num2str(snr), ' dB'], 'HorizontalAlignment', 'center',...
    'unit', 'normalized');

close 
%% RMS Eror
re1 = rms(resultMUSIC.aoaDifference, 2);
resultMUSIC.aoaDifferenceRms = re1;

re2 = rms(resultMUSICoverlapped.aoaDifference, 2);
resultMUSICoverlapped.aoaDifferenceRms = re2;

%% RMS estimate
res1 = rms(resultMUSIC.aoaMUSIC, 2);
resultMUSIC.aoaRMS = res1;

res2 = rms(resultMUSICoverlapped.aoaMUSIC, 2);
resultMUSICoverlapped.aoaRMS = res2;
%% Variance Error
ve1 = var(resultMUSIC.aoaDifference, 1, 2);
resultMUSIC.aoaDifferenceVar = ve1;

ve2 = var(resultMUSICoverlapped.aoaDifference, 1, 2);
resultMUSICoverlapped.aoaDifferenceVar = ve2;

%% Variance estimate
ves1 = var(resultMUSIC.aoaMUSIC, 1, 2);
resultMUSIC.aoaVar = ves1;

ves2 = var(resultMUSICoverlapped.aoaMUSIC, 1, 2);
resultMUSICoverlapped.aoaVar = ves2;

%%
clearvars -except resultMUSICoverlapped resultMUSIC f1 SAVE file

if SAVE
    save(file,'resultMUSICoverlapped', 'resultMUSIC','f1', '-v7.3');
end
% close