t = 0:0.01:1;

x = ones(length(t),1);
xx = conv(x,x);

figure(3)
plot(xx);