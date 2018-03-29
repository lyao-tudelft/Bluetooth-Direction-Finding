fs = 100;
Ts = 1/fs;

T = 10;
t = 0:Ts:T;

f = 1;

s = sin(2*pi*f*t);

snr = 10;
p_s = 0.5;
p_n = 0.5/db2pow(snr);

s_awgn = awgn(s, snr, 'measured');
s_add = s+randn(size(s))*sqrt(p_n);

figure
plot(t, s_awgn);
hold on;    grid on;
plot(t, s_add);
plot(t, s);

legend('awgn','add','original');