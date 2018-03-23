function IQsample = iqSample( parameter, IQcte )
% Get IQ samples from received CTE

fsT = parameter.digitalPara.fsT;
cteSlot = parameter.cteSlot;

% Sample position in reference period and sample slot
samplePositionRef = floor(fsT/2);
samplePositionSlot = (cteSlot-1)*fsT+floor(fsT/2);

temp = IQcte;
temp(1:4*fsT) = [];     % No samples are taken in guard period

cteRefSample = temp(samplePositionRef:fsT:7*fsT+samplePositionRef);    % Sample reference period every 1us
temp(1:8*fsT) = [];
IQsample = cteRefSample(end);   % Take the last one as the IQ sample of Ant1

IQsample = [IQsample; temp(cteSlot*fsT+samplePositionSlot:2*cteSlot*fsT:end)];

end

