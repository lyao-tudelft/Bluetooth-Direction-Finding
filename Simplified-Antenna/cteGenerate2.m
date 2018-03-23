function X = cteGenerate2( parameter, thetaDegree )
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
thetaRadian = thetaDegree/180*pi;
M           = parameter.highAccPosChar.numAntElm;   % Number of Rx elements
nSym        = parameter.digitalPara.nSym;
fsT         = parameter.digitalPara.fsT;
cteSlot     = parameter.cteSlot;    % CTE slot is 1us (1 symbol)
swtPattern  = parameter.highAccPosChar.swtID;
antModel    = parameter.simAntChar;
h           = parameter.digitalPara.h;

waveLength = 3e8/(2.4e9);
d = [];     % Distance w.r.t the 1st element
phaseShift = [];    % Phase shift w.r.t. the 1st element
for i = 1:M
    d = [ d; norm( [antModel.antPosX(1)-antModel.antPosX(i),...
                    antModel.antPosY(1)-antModel.antPosY(i),...
                    antModel.antPosZ(1)-antModel.antPosZ(i)] )];
    phaseShift = [phaseShift; 2*pi*d(i)*cos(thetaRadian)/waveLength];
end

% Generate CTE to transmit
cteSym = zeros(nSym*fsT,1);
cteSym(1:fsT:(nSym-1)*fsT) = 1;
cte = pulseShape(cteSym,fsT);

phi = [];
for i = 1:length(cte)
    phi = [phi; h*pi*Tb/fsT*trapz( cte(1:i) )];
end
complexEnvelope = exp(1j*phi);
cteTx = complexEnvelope;

% Passing into the channel
cteRx = awgn(cteTx, snr, 'measured');

% After receive CTE at Rx
X = cell(M,1);
temp = cteRx';
for i = 1:M
    X{i} = temp*exp(1i*phaseShift(i));
end

end