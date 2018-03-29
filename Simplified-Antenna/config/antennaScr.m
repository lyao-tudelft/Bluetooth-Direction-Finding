%% antenna array model
if highAccPosChar.numAntElm == 4
    load('antenna.mat');
elseif highAccPosChar.numAntElm == 5
    load('antenna_5.mat');
end

% antenna model
antenna = ant;

%
antenna.MC = false;

% compute coupling matrix from S parameter
S = ant.SPara.Parameters;
coupMat = eye(size(S))-S;
antenna.coupMat = coupMat;