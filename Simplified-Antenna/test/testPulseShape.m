%% Test script for function pulseShape
pathConfig

%%
symbol = [1 0 0 0 0 0 0 0, -1 0 0 0 0 0 0 0];
fsT = 8;

rect = ones(fsT,1);
pulse = conv(rect, symbol);

figure(1);
plot(pulse,'x');
hold on;    grid on;
plot(symbol,'o');