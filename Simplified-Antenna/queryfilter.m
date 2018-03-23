function ft = queryfilter(parameter)

% flag of lpf
RXLPF = parameter.digitalPara.RXLPF;

% query the filter info
if RXLPF
    ft = lpf(parameter, 0, 0, false, true);
else
    ft = 'none';
end

end
