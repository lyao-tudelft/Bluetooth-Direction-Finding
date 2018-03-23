T = 1e-6;
N = 1000;
n = 0:N;
dt = T/N;
t = n*dt;

B = 0.5/T;
sigma = sqrt(log(2))/(2*pi*B);
gaussian = 1/(sqrt(2*pi)*sigma)*exp(-1/2*((t-t(end)/2)/sigma).^2);

G = fft(gaussian);
f = n/T;
ind = logical(f<=1e7);

figure
subplot(121)
plot(t, gaussian);
grid on;

subplot(122)
plot(f(ind), abs(G(ind)));

%%
T = 10;
N = 100;
n = 0:N;
dt = T/N;
t = n*dt;

B = 1;
sigma = sqrt(log(2))/(2*pi*B);
gaussian = 1/(sqrt(2*pi)*sigma)*exp(-1/2*((t-t(end)/2)/sigma).^2);

G = fft(gaussian);
% G = fftshift(G);
f = n/T;
ind = logical(f<=1e7);

figure
subplot(121)
plot(t, gaussian);
grid on;

subplot(122)
plot(f(ind), abs(G(ind)));

%%
close all

T = 1e-6;
N = 8;
n = 0:N-1;
dt = T/N;
t = n*dt;
fs = 1/(T/N);

B = 0.5/T;
sigma = sqrt(log(2))/(2*pi*B);
gaussian = 1/(sqrt(2*pi)*sigma)*exp(-1/2*((t-t(end)/2)/sigma).^2);

rect = ones(length(t),1);
out = gaussianSmoothen( fs, rect );

% out = conv(rect, gaussian, 'same');

figure
% subplot(121)
plot(out);
grid on;

% subplot(122)
% plot(f(ind), abs(G(ind)));