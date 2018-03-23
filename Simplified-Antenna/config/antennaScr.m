%% antenna array model
load('antenna.mat');

% antenna model
antenna = ant;

%
antenna.MC = true;

% compute coupling matrix from S parameter
if antenna.MC
    S = ant.SPara.Parameters;
    coupMat = eye(size(S))-S;
    antenna.coupMat = coupMat;
end