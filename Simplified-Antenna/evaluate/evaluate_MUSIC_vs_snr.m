%% Script for evaluating MUSIC against Noise
%
% This script is used to evaluate the performance of MUSIC algorithm in a
% Bluetooth AoA application againse Noise variance. The noise under
% consideration is Additive Gaussian White Noise. A single source is
% assumed.
%
% Last modified 11:00 AM, 06/03/2018

%%
clc
clear all

%%
run('setParameter.m');

%%
thetaRange = parameter.music.thetaRange;

Nrun = 2000;
SNR = -40:2:40;
% Nrun = 20;
% SNR = [-40 -38];
Nsnr = length(SNR);
name = cell(Nsnr,1);
aoaMUSIC = zeros(Nsnr, Nrun);
isOverlapped = true;
setAoA = 90;
RXLPF = parameter.digitalPara.RXLPF;

for io = 1:2
    
    if isOverlapped
        disp('Overlapped');
    else
        disp('Un-overlapped');
    end
    
    tstart_ = tic;
    for ieval = 1:Nsnr
        disp(['Evaluating SNR ', num2str(SNR(ieval)), 'dB']);
        parameter.channel.snr = SNR(ieval);
        
        tstart = tic;
        for neval = 1:Nrun
            run('simplified_overlapped_antenna1.m');
            close all
            aoaMUSIC(ieval, neval) = res.AoA;
        end
        
        telapsed = toc(tstart);
        disp(['Evaluation finished using ', num2str(telapsed), ' seconds']);
        
    end
    telapsed_ = toc(tstart_);
    disp(['Evaluation finished with ', num2str(Nrun), ' runs using ',...
        num2str(telapsed_), ' seconds (',num2str(telapsed_/60),' minutes)']);
    fprintf('\n');
    %%
    aoaMUSICave = sum(aoaMUSIC,2)/Nrun;
    aoaDiff = zeros(Nsnr, Nrun);
    for i = 1:Nsnr
        for j = 1:Nrun
            aoaDiff(i,j) = abs(aoaMUSIC(i,j)-90);
        end
    end
    aoaDiffave = sum(aoaDiff,2)/Nrun;
    
    %%
    ft = queryfilter(parameter);
    
    if isOverlapped
        resultMUSICoverlapped = struct('snr',SNR,...
            'aoaTrue', setAoA,...
            'aoaMUSIC', aoaMUSIC,...
            'aoaAverage',aoaMUSICave,...
            'aoaDifference',aoaDiff,...
            'aoaDifferenceAverage',aoaDiffave,...
            'nRun', Nrun,...
            'nSNR', Nsnr);
        
        resultMUSICoverlapped.filter = ft;
    else
        resultMUSIC = struct('snr',SNR,...
            'aoaTrue', setAoA,...
            'aoaMUSIC', aoaMUSIC,...
            'aoaAverage',aoaMUSICave,...
            'aoaDifference',aoaDiff,...
            'aoaDifferenceAverage',aoaDiffave,...
            'nRun', Nrun,...
            'nSNR', Nsnr);
        
        resultMUSIC.filter = ft;
    end
    
    isOverlapped = ~isOverlapped;
end

%%
save('data/MUSIC_result_agianst_snr_with_overlapping_array_filtered_MC.mat','resultMUSICoverlapped',...
    'resultMUSIC', '-v7.3','-append');
%%
% run('data/plot_MUSIC_result.m');
%%
% figure
% plot(SNR, aoaDiffave, 'linewidth', 1.25);
% hold on;    grid on;
% xlabel('SNR/dB');
% ylabel('error/degree');
% title('MUSIC error vs SNR');
% %%
% figure
% plot(SNR, resultMUSIC.aoaDifferenceAverage, 'linewidth', 1.25);
% hold on;    grid on;
% plot(SNR, resultMUSICoverlapped.aoaDifferenceAverage, 'linewidth', 1.25);
% xlabel('SNR/dB');
% ylabel('error/degree');
% title('MUSIC error vs SNR');
% legend('Un-overlapped','Overlapped');
% %%
% figure
% plot(SNR, resultMUSICoverlapped.aoaDifferenceAverage-resultMUSIC.aoaDifferenceAverage, 'linewidth', 1.25);
