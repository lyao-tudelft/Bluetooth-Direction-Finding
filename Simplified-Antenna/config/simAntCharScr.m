%% Simplified antenna platform data characteristic
simAntChar = struct();

M = highAccPosChar.numAntElm;  % Number of antennas
simAntChar.samePolar    = 1;   % same polarization
simAntChar.antPolar     = bi2de([1 0])*ones(M,1);   % linear polarization
simAntChar.polarAlpha   = 25*ones(M,1)*2;    % Polar Orientation alpha
simAntChar.polarBeta    = 25*ones(M,1)*2;
simAntChar.polarGamma   = 25*ones(M,1)*2;
simAntChar.swtDelay     = zeros(M,1)*0.0001875e-9;
simAntChar.antPosX      = (0:M-1)*1000/16000;
simAntChar.antPosY      = zeros(M,1)/16000;
simAntChar.antPosZ      = zeros(M,1)/16000;
simAntChar.ULA          = true;