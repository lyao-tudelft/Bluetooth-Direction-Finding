fc = 2.4e9;
c = 3e8;
lambda = c/fc;

%% half-wavelength dipole antenna element
dl = lambda/2;
dd = dl/10;

d = dipole('Length', dl,...
    'Width', dd/2);

imp = impedance(d, fc);

%% antenna array with half-wavelength spacing
as = lambda/2;

a = linearArray('Element', d,...
    'NumElements', 4,...
    'ElementSpacing', as);

%% radiation pattern
az = -180:1:180;
el = -90:1:90;

[dp, daz, del] = pattern(d, fc, az, el);
dvolg = dirct2volg(dp);

patternEle = struct('p',dp, 'az', daz, 'el', del);
volgEle = struct('volG', dvolg, 'az', daz, 'el', del);

[ap1, aaz1, ael1] = pattern(a, fc, az, el, 'ElementNumber', 1);
[ap2, aaz2, ael2] = pattern(a, fc, az, el, 'ElementNumber', 2);
[ap3, aaz3, ael3] = pattern(a, fc, az, el, 'ElementNumber', 3);
[ap4, aaz4, ael4] = pattern(a, fc, az, el, 'ElementNumber', 4);
% [ap5, aaz5, ael5] = pattern(a, fc, az, el, 'ElementNumber', 5);

avolg1 = dirct2volg(ap1);
avolg2 = dirct2volg(ap2);
avolg3 = dirct2volg(ap3);
avolg4 = dirct2volg(ap4);
% avolg5 = dirct2volg(ap5);

patternArr = struct('p',{ap1;ap2;ap3;ap4},...
    'az', {aaz1;aaz2;aaz3;aaz4},...
    'el', {ael1;ael2;ael3;ael4});

volgArr = struct('volG',{avolg1;avolg2;avolg3;avolg4},...
    'az', {aaz1;aaz2;aaz3;aaz4},...
    'el', {ael1;ael2;ael3;ael4});

%% S parameter
% match the antenna impedance
S = sparameters(a, fc, real(imp));

%%
ant = struct('element', d,...
    'array', a,...
    'dirctElement', patternEle,...
    'dirctArray', patternArr,...
    'volgElement', volgEle,...
    'volgArray', volgArr,...
    'SPara', S);

%%
save('antenna','ant','-v7.3','-nocompression');

%%
% clearvars -except ant