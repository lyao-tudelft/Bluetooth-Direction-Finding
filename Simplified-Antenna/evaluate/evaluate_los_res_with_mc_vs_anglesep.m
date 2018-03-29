%% Description
% This script is used for evaluation the influence of Mutual Coupling
% against angle seperation

%%
pathConfig

%%
run('setParameter.m');

isOverlapped = false;
musicType = 'Modified';
trueLOS = 90;

SAVE = false;
PLOT = true;
%% check the validity of parameters
% in this evaluation, we want the existence of Multi-path, with FBSS in
% Music algorithm, 4 elements in the antenna array, 3 elements in the
% subarray, un-overlapping array, usage of internal channel model
val = true;

if ~parameter.channel.MULTIPATH
    error('MP');
elseif parameter.highAccPosChar.numAntElm~=5
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
SNR = [10 -10 0];
Nrun = 1000;
aoaSep = 2:2:90;
isMC = [true false];

LOS = {};
SEP_ = {};
ANT = {};
MUS = {};
SNR_ = {};
%%

% Tx of AoA enabled BLE
[tx,phi] = txaoa(parameter, false);

disp('Eval. starts...');
disp(['Will run ', num2str(Nrun), ' times each SNR, with true LOS ',num2str(trueLOS), ' degree']);
fprintf('\n');

for i = 1:length(isMC)
    % with MC/without MC
    parameter.antenna.MC = isMC(i);
    
    for isnr = 1:length(SNR)
        % SNRs
        parameter.channel.snr = SNR(isnr);
        
        if parameter.antenna.MC
            disp('With MC');
        else
            disp('Without MC');
        end
        
        % outer timer start
        t_start_ = tic;
        
        for isep = 1:length(aoaSep)
            % aoa seperation
            
            % inner timer start
            t_start = tic;
            
            % set AoA sepetation
            aoa = [parameter.channel.aoa(1),...
                parameter.channel.aoa(1)+aoaSep(isep)];
            parameter.channel.aoa = aoa;
            
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
                los(isep, nrun) = res.LOS;
                
            end
            
            
            t_elp = toc(t_start);
            disp(['AoA = [', num2str(parameter.channel.aoa), '] degree...Eval. finishes after ', num2str(t_elp), ' seconds']);
            
        end
        
        parameter.music.Type = musicType;
        
        LOS = [LOS, los];
        SEP_ = [SEP_, aoaSep];
        ANT = [ANT, parameter.antenna];
        MUS = [MUS, parameter.music];
        SNR_ = [SNR_, parameter.channel.snr];
        
        t_elp_ = toc(t_start_);
        disp(['Whole eval. finishes after ', num2str(t_elp_/60), ' minutes']);
        fprintf('\n');
        
    end
end

result = struct('los', LOS, 'seperation', SEP_, 'antenna', ANT,...
    'music', MUS, 'snr', SNR_);

%% processing result
for i = 1:length(result)
    result(i).losErr = result(i).los-trueLOS;
    result(i).rmse = rms(result(i).losErr, 2);
    result(i).lpf = parameter.digitalPara.RXLPF;
end

%% save the result
if SAVE
    if parameter.digitalPara.RXLPF
        result_lpf = result;
        save('data/LOS/los_MC_aoa_seperation.mat', 'result_lpf', '-append');
    else
        result_nolpf = result;
        save('data/LOS/los_MC_aoa_seperation.mat', 'result_nolpf', '-append');
    end
    
end

%% visualize
name = {};

colors = hsv(length(result));
if PLOT
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
    
end