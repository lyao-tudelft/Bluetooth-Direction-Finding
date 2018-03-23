pathConfig

run('setParameter.m');

rect = 1e6*ones(8,1);
rect = [rect; -1e6*ones(8,1)];
out = gaussianSmoothen(parameter, rect);

