%% Digital signal parameters
digitalPara = struct();

digitalPara.fsT             = 8;
digitalPara.T               = 1e-6;
digitalPara.nSym            = cteInfo.cteTime/1e-6;

cteSym = zeros(digitalPara.nSym*digitalPara.fsT,1);
cteSym(1:digitalPara.fsT:(digitalPara.nSym-1)*digitalPara.fsT) = 1;     % CTE symbols
digitalPara.symbol          = cteSym;

digitalPara.h               = 0.5;    % Modulation index between 0.28 and 0.35
digitalPara.BT              = 0.5;   % Bandwith symbol period product
digitalPara.GaussBW         = digitalPara.BT/digitalPara.T;
digitalPara.GaussSigma      = sqrt(log(2))/(2*pi*digitalPara.GaussBW);
digitalPara.GaussCutOff     = 5*digitalPara.GaussSigma;
digitalPara.doGaussFilter   = true;
digitalPara.RXBASEBAND      = true;
digitalPara.RXLPF           = true;