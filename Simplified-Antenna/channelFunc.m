function out = channelFunc( parameter,in )
% This function gives the multipath channel output signal with input in

channel  = parameter.channel;
antModel = parameter.simAntChar;
M        = parameter.highAccPosChar.numAntElm;
antenna  = parameter.antenna;
fc       = 2.4e9;
waveLength = 3e8/fc;
fsT      = parameter.digitalPara.fsT;
T        = parameter.digitalPara.T;
snr      = channel.snr;
MP       = channel.MULTIPATH;
nRays    = channel.nRays;

out = zeros(length(in), M);
%% use external channel model provided by Jac
if channel.external
    
    % channel model of M array elements
    extChnl = channel.extChnl;
    
    for m = 1:M
        % phase delay due to time delay tau
        tau = extChnl(m).tau;
        pt = exp(-1i*2*pi*fc*tau);
        
        % amplitude of multipath rays
        h = extChnl(m).h;
        
        % If not Multipath Channel, use the 1st ray only
        if ~MP
            pt = pt(1);
            h = h(1);
        end
        
        % multipath effect
        c = sum(h.*pt);
        
        % output signal of m-th antenna
        out(:, m) = c*in;
    end
    
else
%% use self-defined channel model
    for i = 1:nRays
        
        aoa = channel.aoa(i);
        for m = 1:M
            % Distance and phase shift due to physical spacing
            d = norm( [antModel.antPosX(1)-antModel.antPosX(m),...
                antModel.antPosY(1)-antModel.antPosY(m),...
                antModel.antPosZ(1)-antModel.antPosZ(m)] );
            phaseShift = 2*pi*d*cosd(aoa)/waveLength;
            
            % If the channel is narrow band?
            % If not, time delay on signal
            if ~channel.isNarrowBand
                delaySpacing = d*cosd(aoa)/3e8;
                nDelay = floor((channel.delay(i)+delaySpacing)/T*fsT);
                temp = [zeros(nDelay,1); in(1:end-nDelay)];
            else
                % If so, time delay neglectable
                temp = in;
            end
            
            % Superimpose the current ray
            out(:,m) = out(:,m)+channel.amp(i)*exp(-1i*2*pi*fc*channel.delay(i))...
                *temp*exp(1j*phaseShift);
        end
        
        % If not Multipath Channel, use the 1st ray only
        if ~MP
            break;
        end
    end
end

% mutual coupling
if antenna.MC
    out = out*antenna.coupMat.';
end

% awgn
for i = 1:M
    out(:,i) = awgn(out(:,i), channel.snr, 'measured');
end

end
