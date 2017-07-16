function Eout = experiment_structure
%% initialize a structure to hold the metadata for a certain experiment
%
% 13 june 2013
%
% MODS:
%  18 Jul 2013: add ensemble size as a component

f1 = 'run_name';
f2 = 'truth';
f3 = 'copystring';
f4 = 'variable';
f5 = 'level';
f6 = 'AAM_weighting';
f7 = 'diagn';
f8 = 'day0';
f9 = 'dayf';
f10 = 'latrange';
f11 = 'exp_name';
f12 = 'start';
f13 = 'ens_size';

Eout = struct(f1,'',f2,'',f3,'',f4,'',f5,'',f6,'',f7,'',f8,0,f9,0,f10,[-90,90],f11,'',f12,0,f13,0);
