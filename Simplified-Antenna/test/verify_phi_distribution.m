% n = n_i+jn_i
% phi(n) = atan(n_q/n_i);
% u = n_q/n_i

% pdf of u
u = linspace(-1000,1000,1000000);
f_u = 1/pi./(u.^2+1);

figure
plot(u, f_u);
grid on;
title('pdf of u = n_q/n_i');
xlabel('u');
ylabel('p(u)');
close

% pdf of phase phi = atan(u)
phi = linspace(-pi, pi, 100);
tan_phi = tan(phi);
[~, iu] = arrayfun(@(x) min(abs(u-x)), tan_phi);
f_phi = abs(1./(cos(phi)).^2).*f_u(iu);

figure
plot(phi/pi*180, f_phi);
grid on;
axis([-inf inf 0 1]);
title('pdf of \phi');
xlabel('phi/degree');
ylabel('p(\phi)');