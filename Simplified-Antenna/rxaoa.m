function IQcte = rxaoa(parameter,in, phi)
% Receiver of a AoA application
% It simulates the effect of reception in antenna array, switch, switching
% imperfection, mixer, and low pass filter.

Tb = 1e-6;
fsT     = parameter.digitalPara.fsT;
cteSlot         = parameter.cteSlot;
switchPosition  = cteSlot*fsT/2;
swtPattern      = parameter.highAccPosChar.swtID;
M               = parameter.highAccPosChar.numAntElm;   % Number of Rx elements
RXBASEBAND      = parameter.digitalPara.RXBASEBAND;
DEBUG           = parameter.DEBUG;
RXLPF           = parameter.digitalPara.RXLPF;

%% RX
temp = in;

% Reference & guard period are listened by Ant1.
IQcte = temp(1:12*fsT, 1); 
temp(1:12*fsT, :) = []; 

% Before the switching moment samples are listened by Ant1.
IQcte = [IQcte; temp(1:switchPosition, 1)];
temp(1:switchPosition, :) = [];

%% Switch
switch swtPattern
    case SwitchPattern.ROUNDROBIN
        antNum = 2;
        while(~isempty(temp))
            doBreak = switchAnt(antNum);
            if doBreak
                break;
            end
            
            antNum = mod(antNum,M)+1;
        end
    case SwitchPattern.RETURNTOFIRST
        antNum = 2;
        while(~isempty(temp))
            doBreak = switchAnt(antNum);
            if doBreak
                break;
            end
            
            doBreak = switchAnt(1);
            if doBreak
                break;
            end
            
            antNum = mod(antNum-1,M-1)+2;
        end
    otherwise
        disp('cteGenerate Error: Un-recognized switching pattern');
end

%% Mixer
if RXBASEBAND
    IQcte = IQcte.*exp(-1j*phi);
end

%% Digital Filter
% compensate group delay
gdcomp = true;

% draw spectrum
draw = false;

% low pass filter
if RXLPF
    IQcte = lpf(parameter, IQcte, gdcomp, draw);
end

% drawsignalin( IQcte );

%%
    function doBreak = switchAnt(antNum)
        % Switch Slot
        % If shorter than a slot, sample then halt
        nRemSwt = cteSlot*fsT-switchPosition;
        if (length(temp)<=nRemSwt)
            IQcte = [IQcte; temp(1:end, antNum)];
            temp(1:end, :) = [];
            
            doBreak = true;
            return
        end
        
        % If not, just sample
        IQcte = [IQcte; temp(1:nRemSwt, antNum)];
        temp(1:nRemSwt, :) = [];
        
        % Sample Slot
        % number of samples in the next switching slot
        nExtSmp = cteSlot*fsT+switchPosition;
        if (length(temp)<=nExtSmp)
            IQcte = [IQcte; temp(1:end, antNum)];
            temp(1:end, :) = [];
            
            doBreak = true;
            return
        end
        
        IQcte = [IQcte; temp(1:nExtSmp, antNum)];
        temp(1:nExtSmp, :) = [];
        
        doBreak = false;
    end

    function drawsignalin( sig )
        
        sig = IQcte;
        
        nGaussCutOff = 0;
        
        % x and y axis index
        nx = -nGaussCutOff:32*fsT-1;
        ny = 1:length(nx);
        
        % x axis time in seconds
        tx = nx*Tb/fsT;
        
        % xaxis time in microseconds
        tx_us = tx/1e-6;
        
        % Create figure for visualizing signal
        figure
%         subplot(411);
%         plot(tx_us, sig(ny));
%         grid on;
%         title('Tx - Symbols');
%         xlabel('time/us');
        
%         subplot(412)
        plot(tx_us, real(sig(ny)));
        hold on;    grid on;
        plot(tx_us, imag(sig(ny)));
        xlabel('time/us');
        ylabel('Amplitude');
        title('Tx - Complex Envelope');
        legend('real','imaginary');
        
        %             subplot(413)
        %             plot(tx_us, phi(ny));
        %             grid on;
        %             xlabel('time/us');
        %             ylabel('Phase');
        %
        %             subplot(414)
        %             plot(tx_us, freqDev(ny));
        %             grid on;
        %             xlabel('time/us');
        %             ylabel('Frequency Deviation');
        
        % Create figure for phase trajectory
        %             figure
        %             plot(real(cteTx), imag(cteTx));
        %             grid on;
        %             title('Phase Trajectory of Tx Signal');
        %             xlabel('real');
        %             ylabel('imag');
    end

end

