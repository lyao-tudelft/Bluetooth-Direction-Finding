%% This script is used for evaluation the influence of Mutual Coupling
% with fixed aoa seperation, find the performance curve against SNR

%%
pathConfig

%%
run('setParameter.m');

isOverlapped = false;
musicType = 'Modified';

trueLOS = parameter.channel.aoa(1);
seperation = abs( diff(parameter.channel.aoa) );

SAVE = true;
PLOT = true;
%% check the validity of parameters
% in this evaluation, we want the existence of Multi-path, with FBSS in
% Music algorithm, 4 elements in the antenna array, 3 elements in the
% subarray, un-overlapping array, usage of external channel model
val = true;

if ~parameter.channel.MULTIPATH
    error('MP');
elseif parameter.highAccPosChar.numAntElm~=4
    error('numAntElm');
elseif parameter.music.subarraySize~=3
    error('subarraySize');
elseif isOverlapped
    error('isOverlapped');
elseif parameter.channel.external
    error('external');
end

%%
disp(['The save configuration is: ', mat2str(SAVE), ', plot configuration is: ', mat2str(PLOT), '...']);
yn = input('Is this what you want ? y/n:','s');

if strcmp(yn, 'n')
    error('terminating script');
end
fprintf('\n');

%%
yn = input('Did you disable plot in MUSIC ? y/n:','s');

if strcmp(yn, 'n')
    error('terminating script');
end
fprintf('\n');

%% evaluation
SNR = -40:2:40;
Nrun = 500;

parameter.antenna.MC = true;

LOS = {};
SNR_ = {};
ANT = {};
MUS = {};
SEP = {};
%%

% Tx of AoA enabled BLE
[tx,phi] = txaoa(parameter, false);

disp('Eval. starts...');
disp(['Will run ', num2str(Nrun), ' times each SNR, with true LOS ',num2str(trueLOS), ' degree']);
fprintf('\n');

for i = 1:2
    
    if parameter.antenna.MC
        disp('With MC');
    else
        disp('Without MC');
    end
    
    t_start_ = tic;
    
    for isnr = 1:length(SNR)
        
        t_start = tic;
        
        % set SNR
        snr = SNR(isnr);
        parameter.channel.snr = snr;
        
        for nrun = 1:Nrun
            % channel
            out = channelFunc( parameter,tx );
            
            % Rx
            IQcte = rxaoa(parameter, out, phi);
            
            % IQ sample
            IQsample = iqSample( parameter, IQcte );
            
            % IQ processing
            [X, antArray] = iqProcess(parameter, IQsample, isOverlapped);
            
            % AoA estimation
            res = MUSIC( parameter, X, isOverlapped, antArray, musicType);
            
            % store estimation result
            los(isnr, nrun) = res.LOS;
            
        end
        
        t_elp = toc(t_start);
        disp(['SNR = ', num2str(snr), 'dB...Eval. finishes after ', num2str(t_elp), ' seconds']);
        
    end
    
    parameter.music.Type = musicType;
    
    LOS = [LOS, los];
    SNR_ = [SNR_, SNR];
    ANT = [ANT, parameter.antenna];
    MUS = [MUS, parameter.music];
    SEP = [SEP, seperation];
    
    t_elp_ = toc(t_start_);
    disp(['Whole eval. finishes after ', num2str(t_elp_/60), ' minutes']);
    fprintf('\n');
    
    parameter.antenna.MC = ~parameter.antenna.MC;
    
    
end

result = struct('los', LOS, 'SNR', SNR_, 'antenna', ANT, 'music', MUS, ...
    'seperation', SEP);

%% processing result
for i = 1:2
    result(i).losErr = result(i).los-trueLOS;
    result(i).rmse = rms(result(i).losErr, 2);
    result(i).lpf = parameter.digitalPara.RXLPF;
end

%% save the result
if SAVE
    fname = ['data/LOS/los_MC_vs_SNR_sep_',num2str(seperation)];
    
    if parameter.digitalPara.RXLPF
        save(fname, 'result');
    else
        save(fname, 'result');
    end
    
end

%% visualize
if PLOT
    figure
    
    plot(result(1).SNR, result(1).rmse, 'LineWidth', 1.25);
    hold on;    grid on;
    plot(result(2).SNR, result(2).rmse, 'LineWidth', 1.25);
    xlabel('snr/dB');
    ylabel('rmse/degree');
    title(['LOS (sep = ', num2str(seperation),')']);
    legend('with MC', 'without MC');
end