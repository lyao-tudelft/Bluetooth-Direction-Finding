% map phi to aoa(theta)
phi = linspace(-pi, pi, 1000);
theta = acos(phi/pi);

figure
plot(phi, theta);
close

% pdf of aoa
aoa = linspace(0,pi,1000);
p = abs(pi*sin(aoa))/2/pi;

figure
plot(aoa/pi*180, p);
close

% mean of aoa
half = floor(length(phi)/2);
first = 1:half;
second = half+1:length(phi);
all = 1:length(phi);

choose = second;
aoam = trapz( phi(choose), acos(phi(choose)/pi)/2/pi )/pi*180;
% aoam = trapz(aoa(choose), aoa(choose).*p(choose))/pi*180;

errorm = trapz(phi, abs(acos(phi/pi)-pi/2)/2/pi)/pi*180;