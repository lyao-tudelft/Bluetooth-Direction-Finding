function [IQcte,cteRx] = cteGenerateMP( parameter )
% Generate received CTE with a certain AoA.
%
% Generate CTE at Tx first, then induce phase differences to generate
% reveiced signals at Rx. The phase differences between Rx elements depend
% on the desired AoA. The received CTE is generated according to the
% switching pattern. During switch slots, we currently assume nothing is
% received.
%
% The antenna array here is not necessarily uniform

Tb          = 1e-6;
M           = parameter.highAccPosChar.numAntElm;   % Number of Rx elements
nSym        = parameter.digitalPara.nSym;
fsT         = parameter.digitalPara.fsT;
cteSlot     = parameter.cteSlot;    % Duration of every CTE slot(smp/swt)
swtPattern  = parameter.highAccPosChar.swtID;
antModel    = parameter.simAntChar;
h           = parameter.digitalPara.h;
waveLength  = 3e8/(2.4e9);
snr         = parameter.channel.snr;
GaussCutOff = parameter.digitalPara.GaussCutOff;

% Calculate phase difference
% d = [];             % Distance w.r.t the 1st element
% phaseShift = [];    % Phase shift w.r.t. the 1st element
% for i = 1:M
%     d = [ d; norm( [antModel.antPosX(1)-antModel.antPosX(i),...
%                     antModel.antPosY(1)-antModel.antPosY(i),...
%                     antModel.antPosZ(1)-antModel.antPosZ(i)] )];
%     phaseShift = [phaseShift; 2*pi*d(i)*cos(thetaRadian)/waveLength];
% end

% Generate CTE to transmit
cteSym = parameter.digitalPara.symbol;
cte = pulseShape(parameter,cteSym); % Gaussian filtered CTE pulse  
length(cte);

phi = [];
t = (0:length(cte)-1)*(1e-6)/8;
for i = 1:length(cte)
    phi = [phi; h*pi*Tb/fsT*trapz( cte(1:i) )];
end
complexEnvelope = exp(1j*phi);      % Complex envelope
freqDev = diff(phi)./diff(t')/2/pi;
cteTx = complexEnvelope;

% figure
% subplot(311)
% plot((0:16*fsT-1)*Tb/fsT/1e-6, real(cteTx(1:16*fsT)));
% hold on;    grid on;
% plot((0:16*fsT-1)*Tb/fsT/1e-6, imag(cteTx(1:16*fsT)));
% xlabel('time/us');
% ylabel('Amplitude');
% title('Complex Envelope');
% legend('real','imaginary');
% 
% % findPhase(cteTx(1:16*fsT))
% 
% subplot(312)
% plot((0:16*fsT-1)*Tb/fsT/1e-6, phi(1:16*fsT));
% grid on;
% xlabel('time/us');
% ylabel('Phase');
% 
% subplot(313)
% plot((0:16*fsT-1)*Tb/fsT/1e-6, freqDev(1:16*fsT));
% grid on;
% xlabel('time/us');
% ylabel('Frequency Deviation');

% Passing into the channel
cteRx = multipathChannel( parameter,cteTx );

% cteRx = nonCoherentMultipathChannel(parameter,cteTx);

% After receive CTE at Rx
temp = cteRx;
IQcte = temp(1:12*fsT, 1);
temp(1:12*fsT,:) = [];
switch swtPattern
    case SwitchPattern.RETURNTOFIRST
        antNum = 2;
        while ~(isempty(temp))
            
            doBreak = takeSlot(antNum);
            if doBreak
                break;
            end
            
            doBreak = takeSlot(1);
            if doBreak
                break;
            end
            
            antNum = mod(antNum-1,M-1)+2;
        end
    otherwise
        disp('cteGenerateMP Error: Un-recognized switching pattern');
end

    function doBreak = takeSlot(antNum)
        if size(temp,1)<=cteSlot*fsT
            IQcte = [IQcte; zeros(size(temp,1),1)];
            temp = [];
            
            doBreak = true;
            return;
        end
        IQcte = [IQcte; zeros(cteSlot*fsT,1)];
        temp(1:cteSlot*fsT,:) = [];
        
        if size(temp,1)<=cteSlot*fsT
            IQcte = [IQcte; temp(1:end,antNum)];
            temp = [];
            
            doBreak = true;
            return;
        end
        IQcte = [IQcte; temp(1:cteSlot*fsT,antNum)];
        temp(1:cteSlot*fsT, :) = [];
        
        doBreak = false;
        
    end
end

