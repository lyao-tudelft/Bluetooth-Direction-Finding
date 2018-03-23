pathConfig

run('setParameter.m');

% parameter.digitalPara.fsT = 8;
fsT = parameter.digitalPara.fsT;

N = 1000;
t = (0:N-1)*T/fsT;
signal = complex([1;zeros(N-1,1)]);

% out = multipathChannel(parameter, signal);
% [out1, out] = cteGenerateMP( parameter );
out = nonCoherentMultipathChannel(parameter);

X = cell(4,1);
for i = 1:4
    X{i} = out(:,i).';
end
MUSIC(parameter,X);

to = 16;

figure
stem(t(1:to), angle(signal(1:to))/pi*180);
grid on;    hold on;
stem(t(1:to), angle(out(1:to,1))/pi*180);
stem(t(1:to), angle(out(1:to,2))/pi*180);
stem(t(1:to), angle(out(1:to,3))/pi*180);
stem(t(1:to), angle(out(1:to,4))/pi*180);
legend('Tx','Rx1','Rx2','Rx3','Rx4');

%%
run('setParameter.m');
parameter.digitalPara.fsT = 1000;

signal = [1; zeros(2*parameter.digitalPara.fsT-1,1)];
out = multipathChannel( parameter,signal );

t = (0:length(out)-1)*parameter.digitalPara.T/parameter.digitalPara.fsT;

figure
subplot(211)
stem(t(1:100)/1e-9, signal(1:100));
grid on;    hold on;
stem(t(1:100)/1e-9, abs(out(1:100,1)));
title('Channel Response');
xlabel('time/ns');
legend('Input Impulse','Response');
ylabel('Amplitude');

subplot(212)
stem(t(1:100)/1e-9, angle(signal(1:100)));
grid on;    hold on;
stem(t(1:100)/1e-9, angle(out(1:100,1))/pi*180);
xlabel('time/ns');
ylabel('Phase');
legend('Input Impulse','Response');