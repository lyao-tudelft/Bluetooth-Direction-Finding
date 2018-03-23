function drawspectrum(s, fs)

L = length(s);

NFFT = 2^nextpow2(L);
S = fft(s, NFFT);
f = fs/2*linspace(0,1,NFFT/2+1);

figure
plot(f/1e6,2/NFFT*abs(S(1:NFFT/2+1)));
grid on;
title('Single-Sided Amplitude Spectrum');
xlabel('Frequency (MHz)');
ylabel('|X(f)|');

end

