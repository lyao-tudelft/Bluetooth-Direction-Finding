%% change the working folder into the last folder

current_dir = pwd;
idcs = strfind(pwd, 'Simplified-Antenna');
last_dir = current_dir(1:idcs(end)+18);

cd(last_dir);

% clearvars current_dir idcs last_dir