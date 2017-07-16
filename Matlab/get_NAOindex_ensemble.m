%function [NAO,t] = get_NAOindex_ensemble(E,hostname)
% This code retrieves a DART analysis ensemble for a given 
% experimenti, and then computes the difference in surface pressure
% at Lisbon and Reyjkavik, which gives us a proxy for the NAO indexs
% 
% Lisa Neef, 10 October 2013
%
%---------------------------------------------------------------------

%---temp inputs-----------
%clear all; clf;
EE = load_experiments;
E = EE(3);
E.variable = 'PS';
hostname = 'blizzard';
E.diagn = 'Posterior';
%---temp inputs-----------

%% define experiment settings that we have to have
E.variable = 'PS';
E.levrange = [0,0];

%% define the lat ranges for Lisbon and Reykjavik
EL = E;
  EL.latrange = [38,39];
  EL.lonrange = [9,10];
ER = E;
  ER.latrange = [65,66];
  ER.lonrange = [22,24];

[ENS_L,t] = get_ensemble_in_time(EL,hostname,1);
[ENS_R,t] = get_ensemble_in_time(ER,hostname,1);

%% take the diff between the two and  normalize it -- this is our index
NAO = (ENS_L - ENS_R)./ENS_L;
