% This script is used for estmating the angle of arrival using received
% signal vector snapshots stored in X, which is generated from 'simplified_antenna_model.m'

%%
run('simplified_antenna_model.m');

%%
musicSpectrum = struct();
musicSpectrum.MUSIC = MUSIC(parameter, X);
musicSpectrum.ssMUSIC = ssMUSIC(parameter, X);
musicSpectrum.tfocMUSIC = tfocMUSIC(parameter, X);
musicSpectrum.mssMUSIC = mssMUSIC(parameter, X);
musicSpectrum.fbssMUSIC = fbssMUSIC( parameter,X );
        
%%
close all;

figure
theta_range=parameter.music.thetaRange;
plot(theta_range, musicSpectrum.MUSIC, 'linewidth', 1.25);
grid on;    hold on;
plot(theta_range, musicSpectrum.ssMUSIC, 'linewidth', 1.25);
plot(theta_range, musicSpectrum.mssMUSIC, 'linewidth', 1.25);
plot(theta_range, musicSpectrum.fbssMUSIC, 'linewidth', 1.25);

title('MUSIC-like AoA Estimation');
xlabel('angle/degree');
ylabel('Output Power/dB');
legend('Classical','Spatial Smoothing (SS)','Modified SS','Forward/Backward SS');
text(0.2, 0.9, ['AoA = [', num2str(parameter.channel.aoa), ']'],...
    'Units', 'normalized', 'HorizontalAlignment', 'center');
text(0.2, 0.85, ['q = ',num2str(parameter.channel.nRays)],...
    'Units', 'normalized', 'HorizontalAlignment', 'center');