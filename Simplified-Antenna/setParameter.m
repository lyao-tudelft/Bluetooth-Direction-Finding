% Script for setting parameters of simulation

%%
% clear all
% close all
% clc

%%
addpath([pwd, '/config']);

%%
fc = 2.4e9;  % Carrier frequency
T = 1/fc;
lambda = 3e8/fc;

%%
run('highAccPosCharScr.m');
run('cteInfoScr.m');
run('simAntCharScr.m');
run('digitalParaScr.m');
run('channelScr.m');
run('musicScr.m');
run('antennaScr.m');

%% Debug Mode
DEBUG = false;

%%
parameter = struct('highAccPosChar', highAccPosChar,...
                   'simAntChar', simAntChar,...
                   'cteInfo', cteInfo,...
                   'digitalPara', digitalPara,...
                   'cteSlot', 2,...
                   'channel', channel,...
                   'music', music,...
                   'DEBUG', DEBUG,...
                   'antenna', antenna);
               
% clearvars -except parameter fc T lambda
%%
% run('simplified_overlapped_antenna1.m');