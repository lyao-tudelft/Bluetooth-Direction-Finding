function volg = dirct2volg(dirct)
% convert directivity of an antenna into the voltage gain

% db to linear
dirct = 10.^(dirct/10);

% power ratio of radited intensity to radiation power
powg = dirct/(4*pi);

% voltage ratio
volg = sqrt(powg);
volg = db(volg, 'voltage');

end