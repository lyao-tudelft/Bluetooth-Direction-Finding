function [IQcte, freqDev] = cteGenerate( parameter, PLOT )
% Generate received CTE with a certain AoA.
%
% Generate CTE at Tx first, then induce phase differences to generate
% reveiced signals at Rx. The phase differences between Rx elements depend
% on the desired AoA. The received CTE is generated according to the
% switching pattern. During switch slots, we currently assume nothing is
% received.

%%
narginchk(1,2);

if nargin == 1
    PLOT = false;
end

%%
Tb              = 1e-6;
M               = parameter.highAccPosChar.numAntElm;   % Number of Rx elements
fsT             = parameter.digitalPara.fsT;
cteSlot         = parameter.cteSlot;    % Duration of every CTE slot(smp/swt)
swtPattern      = parameter.highAccPosChar.swtID;
h               = parameter.digitalPara.h;
GaussCutOff     = parameter.digitalPara.GaussCutOff;
nGaussCutOff    = floor(GaussCutOff/Tb*fsT);
switchPosition  = cteSlot*fsT/2;
RXBASEBAND      = parameter.digitalPara.RXBASEBAND;
DEBUG           = parameter.DEBUG;
RXLPF           = parameter.digitalPara.RXLPF;

if DEBUG
    PLOT = true;
end

%% TX
cteSym = parameter.digitalPara.symbol;

% Shape the symbols
plotPulse   = false;
cte         = pulseShape(parameter, cteSym, plotPulse);

% Time series
t = (0:length(cte)-1)*(1e-6)/8;
t = t.';

% Calculate the phase term of complex envelope of GFSK
phi = zeros(size(cte));
for i = 2:length(cte)
%     phi(i) = h*pi*Tb/fsT*trapz( cte(1:i) );
    phi(i) = h*pi/Tb*trapz( t(1:i), cte(1:i) );
end

% Frequency deviation
freqDev = diff(phi)./diff(t)/2/pi;

% TX signal
cteTx = exp(1j*phi);

% debug mode
if PLOT
    drawsignalin();
    
    if DEBUG
        pause
        close all
    end
end

%% Channel
% Passing into the channel
cteRx = channelFunc(parameter, cteTx);

indx = 1:16*fsT;
t = (indx-1)*1e-6/fsT;

% drawsignal(parameter, indx, 'Rx', cteRx(indx));

%% RX
if parameter.antenna.MC
    temp = cteRx*parameter.antenna.coupMat.';
else
    temp = cteRx;
end
    
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
freqDev = [freqDev; freqDev(end)];
if RXBASEBAND
    IQcte = IQcte.*exp(-1j*phi);
end

%% Digital Filter
% compensate group delay
gdcomp = true;

% draw spectrum
draw = false;

% low pass filter
% if RXLPF
%     IQcte = lpf(parameter, IQcte, gdcomp, draw);
% end

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

%% Plot 
    function drawsignalin()
            % x and y axis index
            nx = -nGaussCutOff:16*fsT-1;
            ny = 1:length(nx);
            
            % x axis time in seconds
            tx = nx*Tb/fsT;
            
            % xaxis time in microseconds
            tx_us = tx/1e-6;
            
            % Create figure for visualizing signal
            figure
            subplot(411);
            plot(tx_us, cte(ny));
            grid on;
            title('Tx - Symbols');
            xlabel('time/us');
            
            subplot(412)
            plot(tx_us, real(cteTx(ny)));
            hold on;    grid on;
            plot(tx_us, imag(cteTx(ny)));
            xlabel('time/us');
            ylabel('Amplitude');
            title('Tx - Complex Envelope');
            legend('real','imaginary');
            
            subplot(413)
            plot(tx_us, phi(ny));
            grid on;
            xlabel('time/us');
            ylabel('Phase');
            
            subplot(414)
            plot(tx_us, freqDev(ny));
            grid on;
            xlabel('time/us');
            ylabel('Frequency Deviation');
            
            % Create figure for phase trajectory
            figure
            plot(real(cteTx), imag(cteTx));
            grid on;
            title('Phase Trajectory of Tx Signal');
            xlabel('real');
            ylabel('imag');
    end

end

