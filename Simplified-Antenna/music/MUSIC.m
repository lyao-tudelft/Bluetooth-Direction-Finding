function res = MUSIC( parameter, X, ov, p, type)
% MUSIC algorithm for angle estimation
% Uniform linear array is required here in this implementation
%
% ov: flag of overlapping array
% p: data matrix antenna pattern
% type: MUSIC algorithm type

% check input number
narginchk(2,5);

% by default, use unoverlapping array and conventional music
if nargin == 2
    ov = false;
    type = 'Conventional';
end

% the third input could be 'ov' or 'type'
% if ov is true, p must be set
if nargin == 3
    if islogical(ov)
        if ov
            disp('music error -- pattern is not specified');
            return;
        end
        
        type = 'Conventional';
    elseif isnumeric(ov)
        disp('music error -- music type required');
        return;
    else
        type = ov;
        ov = false;
    end
end

% the fourth input coould be 'p' or 'type'
% if ov is true, the fourth input must be 'p'
if nargin == 4
    if ov && ~isnumeric(p)
        disp('music error -- pattern is not specified');
        return;
    elseif ~ov && ischar(p)
        type = p;
    else
        type = 'Conventional';
    end
end

% if ov is true, cannot use spatial smoothing
if ov && ~strcmp(type, 'Conventional')
    disp('music warning -- Spatial Smoothing is not applicable to overlapping array');
    type = 'Conventional';
end

% Check X dimension
for i = 1:length(X)
    [r, c] = size(X{i});
    if r>c
        X{i} = X{i}.';
    end
end

lambda = 3e8/(2.4e9);
simAntChar = parameter.simAntChar;

% element spacing of ULA
d = norm( [simAntChar.antPosX(1)-simAntChar.antPosX(2),...
           simAntChar.antPosY(1)-simAntChar.antPosY(2),...
           simAntChar.antPosZ(1)-simAntChar.antPosZ(2)] );

% physical array element number
m = parameter.highAccPosChar.numAntElm;

% virtual array element number
if ov
    m = length(p);
end

% convert input cell into matrix
Xmat = zeros(m, length(X{1}));
for i = 1:m
    Xmat(i,:) = X{i};
end

% steering vector of physical array
theta_range = parameter.music.thetaRange;
a = exp((0:m-1).'*1i*2*pi*d/lambda*cosd(theta_range));

% steering vector of virtual array
if ov
    a = a(p,:);
end

% covariance matrix
switch type
    case 'Conventional'
        name = 'MUSIC';
        
        Rx = 1/size(Xmat,2)*(Xmat*Xmat');
    case 'SpatialSmoothing'
        name = 'SS-MUSIC';
        
        ms = parameter.music.subarraySize;
        L = m-ms+1;
        
        for l = 1:L
            Rxsub(:,:,l) = 1/size(Xmat,2)*Xmat(l:ms+l-1,:)*Xmat(l:ms+l-1,:)';
        end
        Rx = sum(Rxsub,3)/L;
        
        % subarray size reduces to ms
        a = a(1:ms, :);
    case 'Modified'
        name = 'FBSS-MUSIC';
        
        ms = parameter.music.subarraySize;
        L = m-ms+1;
        
        % Forward Spatial Smoothing
        for l = 1:L
            Rxsub_f(:,:,l) = 1/size(Xmat,2)*Xmat(l:ms+l-1,:)*Xmat(l:ms+l-1,:)';
        end
        Rx_f = sum(Rxsub_f,3)/L;
        
        % Backward Spatial Smoothing
        Xmat_b = conj(flipud(Xmat));
        Rx = [];
        for l = 1:L
            Rxsub_b(:,:,l) = 1/size(Xmat_b,2)*Xmat_b(l:ms+l-1,:)*Xmat_b(l:ms+l-1,:)';
        end
        Rx_b = sum(Rxsub_b,3)/L;
        
        % covariance matrix
        Rx = (Rx_f+Rx_b)/2;
        
        % subarray size reduces to ms
        a = a(1:ms,:);
    otherwise
        disp('MUSIC error -- unknown algorithm type');
        return;
end

% eigenvalue decomposition
[T, Lambda] = eig(Rx);
[Q, Rt] = qr(T);
% eva = diag(Lambda);

% eigenvalue matrix
R = Rt*Lambda*inv(Rt);

% sort eigenvalues in descending order
% [~,i] = sort(diag(Lambda),'descend');
[~,i] = sort(diag(R),'descend');

% order eigenvalue & eigenvectors accordingly
% Lambda = diag( eva(i) );
% U = T(:,i);
U = Q(:,i);

% number of source
ds = parameter.channel.nRays;

% only one source when do not consider multipath
MULTIPATH = parameter.channel.MULTIPATH;
if ~MULTIPATH
    ds = 1;
end

% ds = 1;

% noise space
% make sure source number doesn't exceed Rx dimension
[~,ncol] = size(U);
if ds>=ncol
    ds = ncol;
    Un = U(:, ds:end);
else
    Un = U(:, ds+1:end);
end

% signal space
Us = U(:,1:ds);

% normalized MUSIC spectrum
spec = -db(abs(diag(a'*(Un*Un')*a)./(diag(a'*a))), 'power');
spec = spec-max(spec)*ones(size(spec));

% find peaks
[~, est] = findpeaks(spec, theta_range, 'Npeaks', ds);

% find the direction of max power
% steering vector of estimated angles
me = size(Rx, 1);
Ae = exp((0:me-1).'*1i*2*pi*d/lambda*cosd(est));

% correlate with max eigenvector, then normalize
cov = abs(Ae'*Us(:,1));

% find the direction of max power
[~, nlos] = max(cov);
los = est(nlos);

% reusult structure
res.scan.start = 0;
res.scan.stop = 180;
res.scan.step = theta_range(2)-theta_range(1);
res.spectrum = spec;
res.specNorm = true;
res.EVD.U = T;
res.EVD.V = Lambda;
res.AoA = est;
res.LOS = los;

% plot the spectrum
% figure
% plot(theta_range, spec, 'linewidth', 1.25);
% grid on;    hold on;
% title(name);
% xlabel('angle/degree');
% ylabel('Output Power/dB');
% 
% scatter(los, spec(theta_range==los), 'filled', 'v');
% 
% aoa = parameter.channel.aoa;
% snr = parameter.channel.snr;
% txt = {[num2str(m), ' antennas'], ['snr = ', num2str(snr), 'dB'],...
%     ['aoa = [', num2str(aoa), ']']};
% 
% if parameter.antenna.MC
%     txt = ['with MC', txt];
% else
%     txt = ['without MC', txt];
% end
% 
% len = length(txt);
% 
% x = ones(1,len)*0.8;
% y = 0.9-(0:len-1)*0.05;
% 
% text(x, y, txt, 'HorizontalAlignment', 'center', 'Units', 'normalized');

end

