%% Antenna model for purpose of AoA detection 
%
% What we have in this model are antenna polarization type, polarization
% orientation(alpha, beta, gamma), switch delays, and antenna positions.
% First we assume vertical linear polarization, and return-to-1st switching
% pattern.
%
% We consider a special case here to try to explore the information of
% extra samples from Ant1 in Return-to-First pattern. We assume each sample
% from Ant1 within a pattern period is from a different antenna but
% virtually located in the same physical position of Ant1.
%
% Last modified 3:22 PM, 05/03/2018
%
% Use this, rather than 'simplified_antenna_model.m'

%%
% clc
% clear all
% close all

%%
% run('setParameter.m');

isOverlapped = false;

%% Tx of AoA enabled BLE
[tx,phi] = txaoa(parameter, false);

%% channel
out = channelFunc( parameter,tx );

%% Rx
IQcte = rxaoa(parameter, out, phi);

%% IQ sample
IQsample = iqSample( parameter, IQcte );

%% IQ processing
[X, antArray] = iqProcess(parameter, IQsample, isOverlapped);

%% AoA estimation
res = MUSIC( parameter, X, isOverlapped, antArray, 'Modified');
