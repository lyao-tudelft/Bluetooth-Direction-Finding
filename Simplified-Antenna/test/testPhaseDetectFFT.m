pathConfig

n = 0:1000;
Ts = 1e-2;
t = n*Ts;
fs = 1/Ts;
fn = fs/2;
L = length(t);

f = 1;
c1 = cos(2*pi*f*t);
c2 = cos(2*pi*f*t+pi/4);

figure(1)
subplot(221);
plot(t, c1);
subplot(222);
plot(t, c2);

C1 = fft(c1)/L;
C2 = fft(c2)/L;
f = linspace(0,1,fix(L/2)+1)*fn;
index = 1:length(f);

subplot(223)
plot(f, angle(C1(index))/pi*180);
subplot(224)
plot(f, angle(C2(index))/pi*180);

figure(2)
subplot(211)
plot(f, abs(C1(index)));
subplot(212)
plot(f, abs(C2(index)));