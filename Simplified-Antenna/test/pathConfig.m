% configure working folder
path = {};

% main script folder
current_dir = pwd;
idcs = strfind(current_dir, '\');
last_dir = current_dir(1:idcs(end)-1);
path = [path last_dir];

% data folder
data_dir = [last_dir, '\data'];
path = [path data_dir];

% add al folders into search path
cellfun(@addpath, path);

% free memory
clear path current_dir idcs last_dir