%% Antenna model for purpose of AoA detection 
%
% This model is used to generate simulated received signal based on
% simulation setups in 'setParameter.m'
%
% What we have in this model are antenna polarization type, polarization
% orientation(alpha, beta, gamma), switch delays, and antenna positions.
%
% Last modified 5:09 PM, 29/01/2018

%% Do not use this. Use 'simplified_overlapepd_antenna1.m' instead

%%
% clc
% clear all
% close all

%%
run('setParameter.m');

swtDelayPhase   = parameter.simAntChar.swtDelay/T*2*pi;
cteSlot     = parameter.cteSlot;
fsT         = parameter.digitalPara.fsT;
Tb          = parameter.digitalPara.T;
Ts          = Tb/fsT;
h           = parameter.digitalPara.h;
highAccPosChar = parameter.highAccPosChar;
simAntChar  = parameter.simAntChar;

Rb = 1/Tb;      % Bit rate
fdev = h*Rb/2;  % Frequency deviation

%% Antenna model
% IQ samples from a Supplemental Packet
[IQcte, freqDev] = cteGenerate( parameter, false );
% IQcte = cteGenerateMP( parameter );
IQsample = iqSample( parameter, IQcte );

nIQ = length(IQsample);
X = cell(highAccPosChar.numAntElm,1);

switch highAccPosChar.swtID
    
    % Return-to-first switching pattern
    case SwitchPattern.RETURNTOFIRST
        nAntPair = highAccPosChar.numAntElm-1;
        aoa = cell(nAntPair,1);
        
        temp = 0;
        for i = 1:2:nIQ
            
            if i == nIQ
                break;
            end
            
            ant = mod(temp,highAccPosChar.numAntElm-1)+2;    % The antenna number paired with antenna 1
            d = norm( [simAntChar.antPosX(1)-simAntChar.antPosX(ant),...
                       simAntChar.antPosY(1)-simAntChar.antPosY(ant),...
                       simAntChar.antPosZ(1)-simAntChar.antPosZ(ant)] );
            
            IQ = IQsample(i:i+1);
            IQ(1) = IQ(1)*exp(-1j*swtDelayPhase(1));    % compensate switch delay
            IQ(2) = IQ(2)*exp(-1j*swtDelayPhase(ant));
            
            X{1} = [X{1}, IQ(1)];
            
            nshift = (2*cteSlot+(ant-2)*4*cteSlot)*fsT;
            tshift = nshift*Ts;
            pshift = tshift*fdev*2*pi;
            X{ant} = [X{ant}, IQ(2)*exp(-1i*pshift)];
%             X{ant} = [X{ant}, IQ(2)];

            phaDiff = findPhase(IQ(2))-findPhase(IQ(1));        % Phase difference
            theta = acos(phaDiff*lambda/(2*pi*d))/pi*180;
            aoa{ant-1} = [aoa{ant-1},theta];
            
            temp = temp+1;
        end

        Xraw = X;
        Xtemp = X{1}(1:highAccPosChar.numAntElm-1:end);
        X{1} = [];
        X{1} = Xtemp;
        sizeMin = min(cellfun('size', X, 2));
        for i = 1:size(X,1)
            X{i}(sizeMin+1:end) = [];
        end
        
        response = MUSIC(parameter, X);
    case SwitchPattern.ROUNDROBIN
        
        
    otherwise
        disp('Uncognised switching pattern');
end
X1 = X;
%%
% fs = 1/Ts;
% L = length(IQcte);
% 
% NFFT = 2^nextpow2(L);
% IQCTE = fft(IQcte, NFFT);
% f = fs/2*linspace(0,1,NFFT/2+1);
% 
% figure
% plot(f/1e6,2*abs(IQCTE(1:NFFT/2+1)));
% grid on;
% title('Single-Sided Amplitude Spectrum of IQcte');
% xlabel('Frequency (MHz)');
% ylabel('|IQCTE(f)|');

%%
% IQcte_hilbert = imag(hilbert(real(IQcte(1:12*fsT))));
% 
% figure
% plot(real(IQcte(1:12*fsT)));
% hold on;    grid on;
% plot(imag(IQcte(1:12*fsT)));
% plot(IQcte_hilbert);
% legend('original real','original imag','hilbert real');