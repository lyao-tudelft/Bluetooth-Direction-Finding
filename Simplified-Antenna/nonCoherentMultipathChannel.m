function out = nonCoherentMultipathChannel(parameter)

Tb          = 1e-6;
channel = parameter.channel;
antModel = parameter.simAntChar;
M = parameter.highAccPosChar.numAntElm;
fc       = 2.4e9;
waveLength = 3e8/fc;
fsT =    parameter.digitalPara.fsT;
T =      parameter.digitalPara.T;
h           = parameter.digitalPara.h;

Nsymbol = parameter.digitalPara.nSym;
N = Nsymbol*8;
bits0 = randi(2, Nsymbol/2,2)*2-3*ones(Nsymbol/2,2);
kronn = ones(2,1);
bits = kron(bits0,kronn);
symbol = upsample(bits,8);

cte = pulseShape(parameter,symbol(:,1));
cte = [cte, pulseShape(parameter,symbol(:,2))];

phi = [];
t = (0:size(cte,1)-1)*(1e-6)/8;
for i = 1:size(cte,1)
    phi = [phi; h*pi*Tb/fsT*trapz( cte(1:i,1) )];
end
phi1 = phi;
complexEnvelope = exp(1j*phi);      % Complex envelope
freqDev = diff(phi)./diff(t')/2/pi;
freqDev1 = freqDev;
cteTx = complexEnvelope;

phi = [];
for i = 1:size(cte,1)
    phi = [phi; h*pi*Tb/fsT*trapz( cte(1:i,2) )];
end
phi2 = phi;
complexEnvelope = exp(1j*phi);      % Complex envelope
freqDev = diff(phi)./diff(t')/2/pi;
freqDev2 = freqDev;
cteTx = [cteTx,complexEnvelope];

% figure
% subplot(511)
% plot((0:16*fsT-1)*Tb/fsT/1e-6, cte(1:16*fsT,1));
% grid on;    hold on;
% plot((0:16*fsT-1)*Tb/fsT/1e-6, cte(1:16*fsT,2));
% xlabel('time/us');
% ylabel('Symbol');
% 
% subplot(512)
% plot((0:16*fsT-1)*Tb/fsT/1e-6, real(cteTx(1:16*fsT,1)));
% hold on;    grid on;
% plot((0:16*fsT-1)*Tb/fsT/1e-6, imag(cteTx(1:16*fsT,1)));
% xlabel('time/us');
% ylabel('Amplitude');
% title('Complex Envelope');
% legend('real','imaginary');
% 
% subplot(513)
% plot((0:16*fsT-1)*Tb/fsT/1e-6, real(cteTx(1:16*fsT,2)));
% hold on;    grid on;
% plot((0:16*fsT-1)*Tb/fsT/1e-6, imag(cteTx(1:16*fsT,2)));
% xlabel('time/us');
% ylabel('Amplitude');
% title('Complex Envelope');
% legend('real','imaginary');
% % findPhase(cteTx(1:16*fsT))
% 
% subplot(514)
% plot((0:16*fsT-1)*Tb/fsT/1e-6, phi1(1:16*fsT));
% grid on;    hold on;
% plot((0:16*fsT-1)*Tb/fsT/1e-6, phi2(1:16*fsT));
% xlabel('time/us');
% ylabel('Phase');
% 
% subplot(515)
% plot((0:16*fsT-1)*Tb/fsT/1e-6, freqDev1(1:16*fsT));
% grid on;    hold on;
% plot((0:16*fsT-1)*Tb/fsT/1e-6, freqDev2(1:16*fsT));
% xlabel('time/us');
% ylabel('Frequency Deviation');

cor = corrcoef(cteTx);
out = zeros(size(cte,1), M);
for i = 1:channel.nRays
    
    aoa = channel.aoa(i);
    for j = 1:M
        d = norm( [antModel.antPosX(1)-antModel.antPosX(j),...
            antModel.antPosY(1)-antModel.antPosY(j),...
            antModel.antPosZ(1)-antModel.antPosZ(j)] );
        phaseShift = 2*pi*d*cosd(aoa)/waveLength;
        
        if ~channel.isNarrowBand
            delaySpacing = d*cosd(aoa)/3e8;
            nDelay = floor((channel.delay(i)+delaySpacing)/T*fsT);
            temp = [zeros(nDelay,1); cteTx(1:end-nDelay,i)];
        else
            temp = cteTx(:,i);
        end
        out(:,j) = out(:,j)+channel.amp(i)*exp(1i*2*pi*fc*channel.delay(i))*temp*exp(1i*phaseShift);
    end
end

end

