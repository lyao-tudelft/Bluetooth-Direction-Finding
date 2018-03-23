function response = fbssMUSIC( parameter,X )
% MUSIC algorithm with spatial smoothing of both forward and backward array 
% for angle estimation of coherent signals
%
% Uniform linear array is required here in this implementation

% Check X dimension
for i = 1:length(X)
    [r, c] = size(X{i});
    if r>c
        X{i} = X{i}.';
    end
end

lambda = 3e8/(2.4e9);
simAntChar = parameter.simAntChar;
d = norm( [simAntChar.antPosX(1)-simAntChar.antPosX(2),...
           simAntChar.antPosY(1)-simAntChar.antPosY(2),...
           simAntChar.antPosZ(1)-simAntChar.antPosZ(2)] );
m = parameter.highAccPosChar.numAntElm;
mSub = parameter.music.subarraySize;
L = m-mSub+1;

Xmat = zeros(m, size(X{1},2));
for i = 1:m
    Xmat(i,:) = X{i};
end

% Forward Spatial Smoothing
for l = 1:L
    Rx(:,:,l) = 1/size(Xmat,2)*Xmat(l:mSub+l-1,:)*Xmat(l:mSub+l-1,:)';
end
Rx_smoothed_f = sum(Rx,3)/L;

% Backward Spatial Smoothing
Xmat_b = conj(flipud(Xmat));
Rx = [];
for l = 1:L
    Rx(:,:,l) = 1/size(Xmat_b,2)*Xmat_b(l:mSub+l-1,:)*Xmat_b(l:mSub+l-1,:)';
end
Rx_smoothed_b = sum(Rx,3)/L;

Rx_smoothed = (Rx_smoothed_f+Rx_smoothed_b)/2;
% Rx_smoothed = Rx_smoothed_b;

theta_range=parameter.music.thetaRange;
av=exp((0:mSub-1).'*1i*2*pi*d/lambda*cosd(theta_range));

[T, Lambda] = eig(Rx_smoothed);
[Q, Rt] = qr(T);
R = Rt*Lambda*inv(Rt);
[~,i] = sort(diag(R),'descend');
U = Q(:,i);

% number of source
ds = parameter.channel.nRays;

% only one source when do not consider multipath
MULTIPATH = parameter.channel.MULTIPATH;
if ~MULTIPATH
    ds = 1;
end

% noise space
% make sure source number doesn't exceed Rx dimension
[~,ncol] = size(U);
if ds>=ncol
    ds = ncol;
    Un = U(:, ds:end);
else
    Un = U(:, ds+1:end);
end

response = -db(abs(diag(av'*(Un*Un')*av)./(diag(av'*av))), 'power');
response = response-max(response)*ones(size(response));

figure
plot(theta_range, response, 'linewidth', 1.25);
grid on;
title('FBSS-MUSIC AoA Estimation');
xlabel('angle/degree');
ylabel('Output Power/dB');
end

