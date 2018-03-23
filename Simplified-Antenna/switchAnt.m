function doBreak = switchAnt(antNum)
% Switch Slot
% If shorter than a slot, sample then halt
nRemSwt = cteSlot*fsT-switchPosition;
if (length(temp)<=nRemSwt)
    IQcte = [IQcte; temp(1:end, antNum)];
    temp(1:end, :) = [];
    
    doBreak = true;
    return
end

% If not, just sample
IQcte = [IQcte; temp(1:nRemSwt, antNum)];
temp(1:nRemSwt, :) = [];

% Sample Slot
% number of samples in the next switching slot
nExtSmp = cteSlot*fsT+switchPosition;
if (length(temp)<=nExtSmp)
    IQcte = [IQcte; temp(1:end, antNum)];
    temp(1:end, :) = [];
    
    doBreak = true;
    return
end

IQcte = [IQcte; temp(1:nExtSmp, antNum)];
temp(1:nExtSmp, :) = [];

doBreak = false;
end

%% Plot
function drawsignal()
% x and y axis index
nx = -nGaussCutOff:16*fsT-1;
ny = 1:length(nx);

% x axis time in seconds
tx = nx*Tb/fsT;

% xaxis time in microseconds
tx_us = tx/1e-6;

% Create figure for visualizing signal
figure
subplot(411);
plot(tx_us, cte(ny));
grid on;
title('Tx - Symbols');
xlabel('time/us');

subplot(412)
plot(tx_us, real(cteTx(ny)));
hold on;    grid on;
plot(tx_us, imag(cteTx(ny)));
xlabel('time/us');
ylabel('Amplitude');
title('Tx - Complex Envelope');
legend('real','imaginary');

subplot(413)
plot(tx_us, phi(ny));
grid on;
xlabel('time/us');
ylabel('Phase');

subplot(414)
plot(tx_us, freqDev(ny));
grid on;
xlabel('time/us');
ylabel('Frequency Deviation');

% Create figure for phase trajectory
figure
plot(real(cteTx), imag(cteTx));
grid on;
title('Phase Trajectory of Tx Signal');
xlabel('real');
ylabel('imag');
end