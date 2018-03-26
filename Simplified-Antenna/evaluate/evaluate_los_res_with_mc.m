%% This script is used for evaluation the influence of Mutual Coupling

%%
pathConfig

%%
run('setParameter.m');

isOverlapped = false;
musicType = 'Modified';
trueLOS = 90;
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
elseif ~parameter.channel.external
    error('external');
end

%% evaluation
SNR = -40:2:40;
Nrun = 2000;

parameter.antenna.MC = true;

LOS = {};
MC = {};
SNR_ = {};
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
    
    LOS = [LOS, los];
    MC = [MC, parameter.antenna.MC];
    SNR_ = [SNR_, SNR];
    
    t_elp_ = toc(t_start_);
    disp(['Whole eval. finishes after ', num2str(t_elp_/60), ' minutes']);
    fprintf('\n');
    
    parameter.antenna.MC = ~parameter.antenna.MC;
    
end

result = struct('los', LOS, 'MC', MC, 'SNR', SNR_);

%% processing result
for i = 1:2
    result(i).losErr = result(i).los-trueLOS;
    
    for n = 1:length(SNR)
        result(i).rmse = rms(result(i).losErr, 2);
    end
end