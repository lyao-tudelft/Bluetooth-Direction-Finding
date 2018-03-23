%% High accuracy positioning data characteristic
highAccPosChar = struct();

highAccPosChar.antPlatform  = bi2de([0 1 0 0 0 0]);  % Simplified antenna platform
highAccPosChar.arrayHeight  = 30;      % in cm
highAccPosChar.numAntElm    = 5;       % Number of antenna elements
highAccPosChar.swtID        = SwitchPattern.RETURNTOFIRST;    % Return-to-1st pattern