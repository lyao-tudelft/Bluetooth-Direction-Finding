function a = gen_a( M, Delta, theta )
% Generate the array response 'a' of a uniform linear array with 'M'
% elements and spacing 'Delta' wavelengths to a source coming from
% direction 'theta' degrees. Suppose isotropic radiator - gain pattern
% a(theta) = 1;
%
% M: number of array elements
% Delta: element spacing
% theta: direction of arrival in degree
%
% a: array response

gain = 1;   % Isotropic radiators
theta_rad = theta/180*pi;   % Convert degree into radian
phi = exp(1j*2*pi*Delta*cos(theta_rad));

a = zeros(M,1);
for i = 1:length(a)
    a(i) = phi^(i-1);
end

a = a.*gain;

end

