function [tx, phi] = txaoa(parameter, PLOT)
% Transmitter in a AoA application
% It transmits GFSK modulated CTE 

% input argument check
narginchk(1,2);
if nargin == 1
    PLOT = false;
end

symbol = parameter.digitalPara.symbol;
h      = parameter.digitalPara.h;
DEBUG  = parameter.DEBUG;

% Shape the symbols
plotPulse   = false;
pulse       = pulseShape(parameter, symbol, plotPulse);
Tb          = 1e-6;

% Time series
t = (0:length(pulse)-1)*(1e-6)/8;
t = t.';

% Calculate the phase term of complex envelope of GFSK
phi = zeros(size(pulse));
for i = 2:length(pulse)
%     phi(i) = h*pi*Tb/fsT*trapz( pulse(1:i) );
    phi(i) = h*pi/Tb*trapz( t(1:i), pulse(1:i) );
end

% Frequency deviation
freqDev = diff(phi)./diff(t)/2/pi;

% TX signal
tx = exp(1j*phi);

% debug mode
% if PLOT
%     drawsignalin();
%     
%     if DEBUG
%         pause
%         close all
%     end
% end

end

