function [out,symbolRect] = pulseShape( parameter, symbol, PLOT )
% Pulse shaping on symbol sequence.

narginchk(2,3);
if nargin == 2
    PLOT = false;
end

% debug mode
DEBUG = parameter.DEBUG;
if DEBUG
    PLOT = true;
end

digitalPara     = parameter.digitalPara;
Ts              = digitalPara.T;
fsT             = digitalPara.fsT;

% rectangular pulse
rect = ones(fsT,1);
symbolRect = conv(symbol, rect);

% smooth the rectangular pulse if required
if parameter.digitalPara.doGaussFilter
    out = gaussianSmoothen(parameter, symbolRect);
else
    out = symbolRect;
end

if PLOT
    figure
    plot((0:16*fsT-1)*Ts/fsT/1e-6, out(1:16*fsT));
    grid on;
    title('TX - Pulse');
    xlabel('Time/us');
    ylabel('Amplitude');
    
    pause
    close all
end

end

