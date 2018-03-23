function [X, antArray] = iqProcess(parameter, IQsample, ov)

fc = 2.4e9;  % Carrier frequency
T = 1/fc;

highAccPosChar  = parameter.highAccPosChar;
simAntChar      = parameter.simAntChar;
digitalPara     = parameter.digitalPara;
cteSlot         = parameter.cteSlot;

swtDelayPhase   = simAntChar.swtDelay/T*2*pi;
fsT         = digitalPara.fsT;
Tb          = digitalPara.T;
h           = digitalPara.h;
M           = highAccPosChar.numAntElm;

Mv          = (M-1)*2;  % Virtual antenna number
Ts          = Tb/fsT;
Rb          = 1/Tb;      % Bit rate
fdev        = h*Rb/2;  % Frequency deviation

switch highAccPosChar.swtID
    
    % Return-to-first switching pattern
    case SwitchPattern.RETURNTOFIRST
        
        % Pattern of R2F
        pattern = zeros(Mv,1);
        pattern(1:2:end) = 1;
        pattern(2:2:end) = 2:M;
        
        % Sample, compensate switch delay and calibrate phase shift due to
        % sample slot if do not down convert Rx to baseband
        X = cell(Mv,1);
        for mv = 1:Mv
            if ~digitalPara.RXBASEBAND
                nshift = (mv-1)*2*cteSlot*fsT;
                tshift = nshift*Ts;
                pshift = tshift*fdev*2*pi;
            else
                pshift = 0;
            end
            [pattern(mv) pshift];
            X{mv} = IQsample(mv:Mv:end)*exp(-1j*swtDelayPhase(pattern(mv))*exp(-1i*pshift));
        end
        
        % Truncate data to have equal number of IQ samples from each
        % antenna
        sizeMin = min(cellfun('size', X, 1));
        for mv = 1:Mv
            X{mv}(sizeMin+1:end) = [];
        end
        
        temp = X;
        % Re-organize the row order of data
        if ov
            % 1 1 1 2 3 4
            X(1:M-1) = temp(1:2:end);
            X(M:Mv) = temp(2:2:end);
            
            antArray = [ones(1, M-1), 2:M];
        else
            % 1 2 3 4
            indexAnt1 = find(pattern==1);
            indexDesiredAnt1 = indexAnt1(1);
            
            X = [];
            X = [temp(indexDesiredAnt1); temp(2:2:end)];
            
            antArray = 1:M;
        end
        
    otherwise
        disp('Uncognised switching pattern');
end

end

