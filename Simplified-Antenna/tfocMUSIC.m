function response = tfocMUSIC( parameter, X )
% Improved MUSIC based on Toplietz and 4th order cumulants

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
Xmat = zeros(m, size(X{1},2));
for i = 1:m
    Xmat(i,:) = X{i};
end

% Step a
Rx = 1/size(Xmat,2)*Xmat*Xmat';
[~, Sx, ~] = svd(Rx);
s_mean = mean(diag(Sx));

% Step b
r_positive = [];
r_negative = [];
for i = 1:m-1
    r_positive = [r_positive, mean(diag(Rx,i))];
    r_negative = [r_negative, mean(diag(Rx,-i))];
end

% Step c
Rt = diag(ones(m,1)*s_mean);
for i = 1:m-1
    Rt = Rt+diag(ones(m-i,1)*r_positive(i), i);
    Rt = Rt+diag(ones(m-i,1)*r_negative(i), -i);
end

% Step d
R4 = -kron( Rt*Rt' , conj(Rt*Rt') );

% Step e
[T, Lambda] = eig(R4);
[Q, Rtt] = qr(T);
R = Rtt*Lambda*inv(Rtt);
[~,i] = sort(diag(R),'descend');
U = Q(:,i);
Un = U(:, 3:end);

theta_range=parameter.music.thetaRange;
a=exp((0:m-1).'*1i*2*pi*d/lambda*cosd(theta_range));
b = [];
for i = 1:size(a,2)
    b = [b, kron(a(:,i), a(:,i))];
end

% Step f
response = -db(abs(diag(b'*(Un*Un')*b)./(diag(b'*b))), 'power');
response = response-max(response)*ones(size(response));

figure
plot(theta_range, response, 'linewidth', 1.25);
grid on;
title('MUSIC AoA Estimation');
xlabel('angle/degree');
ylabel('Output Power/dB');
end

