function phi = findPhase( c, rf )
% Find the phase of complex value c (the positive angle of complex vector 
% w.r.t positive real axis)
%
% rf: the flag indicating whether phase roll-off should be compensated

narginchk(1,2);
if nargin == 1
    rf = false;
end

phi = angle(c);
phi(logical(phi<0)) = phi(logical(phi<0))+2*pi;

if rf
    phiDiff= diff(phi);
    rolloffPhi = find(phiDiff<-1.7*pi)+1;
    
    for i = 1:length(rolloffPhi)
        if i == length(rolloffPhi)
            phi(rolloffPhi(i):end) = phi(rolloffPhi(i):end)+2*i*pi;
        else
            phi(rolloffPhi(i):rolloffPhi(i+1)-1) = phi(rolloffPhi(i):rolloffPhi(i+1)-1)+2*i*pi;
        end
    end
end

end
