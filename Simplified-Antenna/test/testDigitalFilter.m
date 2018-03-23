%%
pathConfig

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

Rb = 1/Tb;      % Bit rate
fdev = h*Rb/2;  % Frequency deviation

%% Antenna model
% IQ samples from a Supplemental Packet
[IQcte, freqDev] = cteGenerate( parameter );

%%
rp = 3;
rs = 15;
fs = 1/Ts;
fp = 0.1e6;
fst = 0.3e6;
a = [1 0];
f = [fp fst];

dev = [(10^(rp/20)-1)/(10^(rp/20)+1)  10^(-rs/20)];
[n,fo,ao,w] = firpmord(f,a,dev,fs);
h = firpm(n,fo,ao,w);
n = length(h);

figure
freqz(h,1,1024,fs);
title('P-M Digital Filter Response');
% close

% figure
% stem((0:length(h)-1)*Ts, h);

%%
y = filter(h,1,IQcte);
nGroupDelay = ceil((n-1)/2);
y_comp = y(nGroupDelay+1:end);
% y = filtfilt(h,1,IQcte);

%%
sig2plot = y_comp;
name2plot = {'Filtered','Un-filtered'};
for i = 1:2
    
    fs = 1/Ts;
    drawspectrum(sig2plot, fs);
%     L = length(sig2plot);
%     
%     NFFT = 2^nextpow2(L);
%     IQCTE = fft(sig2plot, NFFT);
%     f = fs/2*linspace(0,1,NFFT/2+1);
%     
%     figure
%     plot(f/1e6,2/NFFT*abs(IQCTE(1:NFFT/2+1)));
%     grid on;
%     title(['Single-Sided Amplitude Spectrum (',name2plot{i},')']);
%     xlabel('Frequency (MHz)');
%     ylabel('|X(f)|');
    
%     close
    
    sig2plot = IQcte;
end

%%
sig2plot = y_comp;

nt = 32;
t = (0:nt*fsT-1)*1e-6/fsT;

t_swt = {};
temp = t;
temp(1:12*fsT) = [];
while ~isempty(temp)
    if length(temp) >= cteSlot*fsT
        t_swt = [t_swt temp(1:cteSlot*fsT)];
        temp(1:cteSlot*fsT) = [];
    else
        t_swt = [t_swt, temp];
        temp = [];
        
        break;
    end
    
    if length(temp) >= cteSlot*fsT
        temp(1:cteSlot*fsT) = [];
    else
        temp = [];
    end
end

name2plot = {'Filtered (With Delay Comp.)','Un-filtered'};
for i = 1:2

    figure
    subplot(311)
    plot(t/1e-6, abs(sig2plot(1:nt*fsT)));
    grid on; hold on;
    title(name2plot{i});
    ylim([0,2]);
    xlabel('time/us');
    ylabel('Magnitude');
    yl = ylim;
    for is = 1:length(t_swt)
        area(t_swt{is}/1e-6, yl(2)*ones(size(t_swt{is})),...
            yl(1),...
            'EdgeAlpha', 0,...
            'FaceAlpha', 0.3,...
            'FaceColor', [0.1 0.1 0.1]);
    end
    
    subplot(312)
    plot(t/1e-6, real(sig2plot(1:nt*fsT)));
    hold on;    grid on;
    plot(t/1e-6, imag(sig2plot(1:nt*fsT)));
    xlabel('time/us');
    ylabel('real/imag');
    yl = ylim;
    for is = 1:length(t_swt)
        area(t_swt{is}/1e-6, yl(2)*ones(size(t_swt{is})),...
            yl(1),...
            'EdgeAlpha', 0,...
            'FaceAlpha', 0.3,...
            'FaceColor', [0.1 0.1 0.1]);
    end
    legend('real','imaginary','Switch Slot');
    
    subplot(313)
    plot(t/1e-6, findPhase(sig2plot(1:nt*fsT), false));
    grid on;    hold on;
    xlabel('time/us');
    ylabel('phase/radian');
    yl = ylim;
    for is = 1:length(t_swt)
        area(t_swt{is}/1e-6, yl(2)*ones(size(t_swt{is})),...
            yl(1),...
            'EdgeAlpha', 0,...
            'FaceAlpha', 0.3,...
            'FaceColor', [0.1 0.1 0.1]);
    end
    
%     close
    
    sig2plot = IQcte;
end

% close all