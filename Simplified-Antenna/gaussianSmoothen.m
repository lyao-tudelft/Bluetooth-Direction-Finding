function out = gaussianSmoothen( parameter, in )
%% Gaussian filter for pulse smoothing
% Smoothen the signal in with Gaussian filter

digitalPara = parameter.digitalPara;

fsT     = digitalPara.fsT;
T       = 1e-6;
fs      = fsT/T;
dt      = 1/fs;
sigma   = digitalPara.GaussSigma;
cutOff  = digitalPara.GaussCutOff;

%% Truncate the Gaussian impulse at 5*sigma away from mean
t = -floor(cutOff/dt)*dt:dt:floor(cutOff/dt)*dt;
gaussian = 1/(sqrt(2*pi)*sigma)*exp(-1/2*(t/sigma).^2);

%% Convolve the Gaussian Pulse with the rectangular symbol
out = dt*conv(in, gaussian, 'same');

%% Plot
% figure
% plot((0:(length(out)-1))*dt/1e-6, out, 'linewidth', 1.25);
% grid on;
% xlabel('Time/us');
% ylabel('Pulse');
% title('Gaussian Filtered CTE Pulse');

end

