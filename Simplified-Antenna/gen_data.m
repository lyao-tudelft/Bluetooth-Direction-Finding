function [X, S, sigmasq_n] = gen_data( M, N, Delta, theta, SNR )
% Generate a data matrix 'X' as function of directions, number of
% antennas, number of samples, and signal-to-noise ratio.
%
% M: number of antennas
% N: number of samples
% Delta: element spacing
% theta: angles of arrival in degree
% SNR: signal-to-noise ratio in dB
%
% X: data matrix

gain = 1;

d = length(theta);  % Number of sources
QPSKmap = [exp(1j*pi/4) exp(1j*3*pi/4)...
            exp(1j*5*pi/4) exp(1j*7*pi/4)];     % QPSK symbols
temp = randi(4,d,N);    % Randomly choose a QPSK symbol
S = QPSKmap(temp);      % QPSK signal with unit power

SNR_ls = 10^(SNR/10);        % Convert decibel into linear scale
sigma_n = 1/sqrt(SNR_ls);    % Standard deviation of noise
sigmasq_n = sigma_n^2;

N_real = normrnd(0, sigma_n/sqrt(2), M, N);
N_imag = normrnd(0, sigma_n/sqrt(2), M, N);

N = N_real + 1j*N_imag;     % Generate noise

% Compute array response matrix
A = zeros(M, d);
for i = 1:d
    A(:,i) = gen_a(M, Delta, theta(i)).*gain;
end

% Compute data matrix
X = A*S + N;

end

