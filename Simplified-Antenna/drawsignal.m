function drawsignal(varargin)
% usage
% drawsignal(parameter, ind, signame, sig)

if mod(nargin,2)
    disp('drawsignal error -- input argument number mismatch');
    return;
end

if nargin <= 2
    disp('drawsignal error -- input argument number too few');
    return;
end

% prameter
parameter = varargin{1};

fsT = parameter.digitalPara.fsT;
Tb   = parameter.digitalPara.T;

% index of the signal
ind = varargin{2};

% signal name
name = varargin(3:2:end);

% signal
s = varargin(4:2:end);

% number of signal to plot
ns = length(s);

% x axis time in seconds
tx = ind*Tb/fsT;

% xaxis time in microseconds
tx_us = tx/1e-6;

for i = 1:ns
    figure
    
    subplot(311)
    plot(tx_us, abs(s{i}));
    grid
    title(name{i});
    xlabel('time/us');
    ylabel('magnitude');
    axis([-inf inf 0 1.5]);
    
    subplot(312)
    plot(tx_us, real(s{i}));
    hold on; grid on;
    plot(tx_us, imag(s{i}));
    xlabel('time/us');
    ylabel('magnitude');
    legend('real','imag');
    
    subplot(313)
    plot(tx_us, findPhase(s{i}, true));
    grid
    xlabel('time/us');
    ylabel('phase/rad');
    
end


end