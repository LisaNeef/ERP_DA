function E = load_experiments
%
% This function loads the metadata for the various DART assimilation experiments 
% that we want to compare
% Note that these structure include some default diagnostics that can be changed.
%
% Lisa Neef, 21 June 2013
%
% MODS:
%  3 Jul 2013: make more compact by outputting a single structure with all experiments
%  26 Jul 2013: make even more compact by defining all the defaults in one loop
%  26 Jul 2013: add longtidue-range as one of the structure components.
%------------------------------------------------------------


% E1: No Assimilation
E1              	= experiment_structure;
E1.run_name     	= 'NODA_2009_N80/Exp3';
E1.truth        	= 'PMO_ERPRS_2009/PMO3';
E1.exp_name     	= 'No DA';

% E2: Radiosondes
E2              	= experiment_structure;
E2.run_name     	= 'RADIOSONDE_SYNTHETIC_2009/Exp3';
E2.truth        	= 'PMO_ERPRS_2009/PMO3';
E2.exp_name     	= 'Radiosondes';

% E3: All ERPs
E3              	= experiment_structure;
E3.run_name     	= 'ERPALL_2009_N80/Exp3';
E3.truth        	= 'PMO_ERPRS_2009/PMO3';
E3.exp_name     	= 'All ERPs';

% E4: PM1 only
E4              	= experiment_structure;
E4.run_name     	= 'ERP1_2009_N80/Exp2';
E4.truth        	= 'PMO_ERPRS_2009/PMO3';
E4.exp_name     	= 'p_1 only';

% E5: PM2 only
E5              	= experiment_structure;
E5.run_name     	= 'ERP2_2009_N80/Exp2';
E5.truth        	= 'PMO_ERPRS_2009/PMO3';
E5.exp_name     	= 'p_2 only';

% E6: LOD only
E6              	= experiment_structure;
E6.run_name     	= 'ERP3_2009_N80/Exp2';
E6.truth        	= 'PMO_ERPRS_2009/PMO3';
E6.exp_name     	= 'LOD only';

% E7: Radiosondes + ERPs
E7			= experiment_structure;
E7.run_name     	= 'ERPRS_2009_N80/Exp2';
E7.truth        	= 'PMO_ERPRS_2009/PMO3';
E7.exp_name     	= 'Radiosondes + ERPs';

% E8: Radiosondes with only Temp
E8              	= experiment_structure;
E8.run_name     	= 'RS_TEMPS_2009_N80/Exp3';
E8.truth        	= 'PMO_ERPRS_2009/PMO3';
E8.exp_name     	= 'Radiosondes Temp Only';

% E9: ERPs but analyzing U only
E9              	= experiment_structure;
E9.run_name     	= 'ERPALL_2009_N80_Uonly/Exp2';
E9.truth        	= 'PMO_ERPRS_2009/PMO3';
E9.exp_name     	= 'All ERPs U only';

% E10: ERPs but localizing the analysis increment below 50 hPa
E10              	= experiment_structure;
E10.run_name     	= 'ERPALL_2009_N80_loc50hPa/Exp3';
E10.truth        	= 'PMO_ERPRS_2009/PMO3';
E10.exp_name     	= 'All ERPs, localize below 50hPa'; 

% E11: ERPs, testing horizontal localization of the analysis increment
E11              	= experiment_structure;
E11.run_name     	= 'ERPALL_2009_N80_test_horiz_loc/Exp5';
E11.truth        	= 'PMO_ERPRS_2009/PMO3';
E11.exp_name     	= 'test horizontal localization';

% E12: ERPs, testing horizontal localization of the analysis increment
E12              	= experiment_structure;
E12.run_name     	= 'ERPALL_2009_N80_24H/Exp3';
E12.truth        	= 'PMO_ERPRS_2009/PMO3';
E12.exp_name     	= 'All ERPs tobs = 24H';

% E13: Radiosondes with only zonal wind observations
E13              	= experiment_structure;
E13.run_name     	= 'RS_U_2009_N80/Exp1';
E13.truth        	= 'PMO_ERPRS_2009/PMO3';
E13.exp_name     	= 'Radiosondes U Only';

%% put them all together into one big structure
E = [E1,E2,E3,E4,E5,E6,E7,E8,E9,E10,E11,E12,E13];


%% set the defaults that they all have in common
nX = length(E);
for iX = 1:nX
  E(iX).copystring 	= 'ensemble mean';
  E(iX).AAM_weighting 	= 'none';
  E(iX).diagn        	= 'RMSE';
  E(iX).latrange        = [-90,90];
  E(iX).lonrange        = [0,360];
  E(iX).levrange	= [1000,1];
  E(iX).day0		= 149020;
  E(iX).dayf		= 149100;
  E(iX).variable	= 'U';
  E(iX).level		= 300;
  E(iX).start		= 149019;
  E(iX).ens_size	= 80;
  E(iX).diff		= 1;
end






