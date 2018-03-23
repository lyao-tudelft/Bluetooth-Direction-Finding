pathConfig

close all
clear

run('setParameter.m');

fsT = parameter.digitalPara.fsT;
h = parameter.digitalPara.h;
Tb = parameter.digitalPara.T;
Rb = 1/Tb;
f = h*Rb/2;
T = 1/f;
Ts = Tb/fsT;
%% MUSIC using switching reception
IQ = cteGenerate( parameter, 60);
IQcte = IQ';

M = parameter.highAccPosChar.numAntElm;
cteSlot = parameter.cteSlot;

X = cell(M,1);
IQcte(1:fsT*4) = [];
IQcte(1:(8-2*cteSlot)*fsT) = [];

antNum = 2;
while ~isempty(IQcte)
    
    % SwtSlot of Ant 1
    if length(IQcte)>=cteSlot*fsT
        IQcte(1:cteSlot*fsT) = [];
    else
        IQcte(1:end) = [];
        break;
    end
    
    % SmpSlot of Ant 1
    if length(IQcte)>=cteSlot*fsT
        X{1} = [X{1}, IQcte(1:cteSlot*fsT)];
        IQcte(1:cteSlot*fsT) = [];
    else
        IQcte(1:end) = [];
        break;
    end
    
    % SwtSlot of Ant antNum
    if length(IQcte)>=cteSlot*fsT
        IQcte(1:cteSlot*fsT) = [];
    else
        IQcte(1:end) = [];
        break;
    end
    
    % SmpSlot of Ant antNum
    if length(IQcte)>=cteSlot*fsT
        nshift = (2*cteSlot+(antNum-2)*4*cteSlot)*fsT;
        tshift = nshift*Ts;
        pshift = tshift*f*2*pi;
        X{antNum} = [X{antNum}, IQcte(1:cteSlot*fsT)*exp(1i*pshift)];
        IQcte(1:cteSlot*fsT) = [];
    else
        IQcte(1:end) = [];
        break;
    end
    
    antNum = mod(antNum-1,M-1)+2;
end

Xtemp = X{1};
X{1} = [];
while ~isempty(Xtemp)
    X{1} = [X{1}, Xtemp(1:cteSlot*fsT)];
    if length(Xtemp)>=(M-1)*cteSlot*fsT
        Xtemp(1:(M-1)*cteSlot*fsT) = [];
    else
        Xtemp(1:end) = [];
        break;
    end
end
% Xtemp = X{1};
% X{1} = X{3};
% X{3} = Xtemp;

sizeMin = min(cellfun('size', X, 2));
for i = 1:size(X,1)
    X{i}(sizeMin+1:end) = [];
    temp = X{i};
    X{i} = [];
    X{i} = temp(floor(fsT/2):cteSlot*fsT:end);
end

% X{1}(cteSlot*fsT+1:end) = [];
% X{2}(cteSlot*fsT+1:end) = [];
% X{3}(cteSlot*fsT+1:end) = [];

out1 = MUSIC(parameter, X);

% figure
% plot(imag(X{1}));
% hold on;    grid on;
% plot(imag(X{2}));
% plot(imag(X{3}));
% legend('1','2','3');
% 
% figure
% plot((0:length(IQ)-1)*Ts,imag(IQ));

%% MUSIC using simultaneous reception
X2 = cteGenerate2( parameter, 60 );
% out2 = MUSIC(parameter, X);

%%
nshift = 2*cteSlot*fsT;
tshift = (nshift)*Ts;
pshift = tshift*f*2*pi;

sample1 = X2{1}(1000:1000+nshift-1);
sample2 = X2{1}(1000+nshift:1000+2*nshift-1)*exp(1i*pshift);

% figure
% plot(findPhase(sample1));

%%
M = 4;
N = 100;
Delta = 1/2;
theta = [90 80];
SNR = inf;
[X, ~, ~] = gen_data( M, N, Delta, theta, SNR );

Xc = cell(M,1);
for i = 1:M
    Xc{i} = X(i,:);
end
MUSIC(parameter,Xc);