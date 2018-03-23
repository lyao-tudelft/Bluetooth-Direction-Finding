function out = lpf(parameter, in, gdcomp, draw, fq)
% fq: filter info query flag

narginchk(3,5);
if nargin == 3
    draw = false;
    fq = false;
end

if nargin == 4
    fq = false;
end

% debug mode
DEBUG = parameter.DEBUG;
if DEBUG
    draw = true;
end

% filter info struct
filter = struct();

% filter type
filter.type = 'FIR';

digitalPara = parameter.digitalPara;
fsT     = digitalPara.fsT;
Tb      = digitalPara.T;
Ts      = Tb/fsT;

% passband ripple in dB
rp = 3;
filter.rp = rp;

% stopband ripple
rs = 15;
filter.rs = rs;

% sample rate
fs = 1/Ts;
filter.fs = fs;

% passband frequency in Hz
fp = 0.1e6;
filter.fp = fp;

% stopband frequency
fst = 0.3e6;
filter.fst = fst;

f = [fp fst];

% pass/stop-band amplitude
a = [1 0];
filter.a = a;

% pass/stop-band deviation
dev = [(10^(rp/20)-1)/(10^(rp/20)+1)  10^(-rs/20)];

% Parks-McClellan filter design
% order estimate
[n,fo,ao,w] = firpmord(f,a,dev,fs);

% design the filter
h = firpm(n,fo,ao,w);

% filter order
n = length(h);
filter.order = n;

if fq
    out = filter;
    return
end

% filter the input signal
% out = filter(h,1,in);
out = conv(h, in);

% group delay
gd = ceil((n-1)/2);

% compensate group delay if flag 'gdcomp' is set
if gdcomp
    out = out(gd+1:end);
else
    out = out(1:end-gd);
end

% draw spectrum of filtered signal
if draw
    drawspectrum(out, fs);
    legend('LPF output');
    
    drawspectrum(in, fs);
    legend('LPF input');
    
    if DEBUG
        pause
        close all
    end
end

end

