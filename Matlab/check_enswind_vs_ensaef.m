%% check_enswind_vs_ensaef.m
%
% Compare the ensemble of wind fields at some time in a DART run
% to the observed X3 AEF for that time.  
% What is the correlation between winds and the global AEF?  
% Is the integral performed correctly by DART?  
%
% Lisa Neef, 18 Oct 2013  
%--------------------------------------------------------------

%% basic inputs
clc;
clear all;
hostname = 'blizzard';
EE = load_experiments;
E = EE(1);
E.diff = 'none';
E.day0 = 149040;
E.dayf = E.day0;
E.diagn = 'Posterior';

%% load the entire ensemble of wind fields for the chosen day  

E.variable = 'U';
[EWIND,t,lat,lon,lev] = get_ensemble_in_time(E,hostname,0);
wind = squeeze(EWIND(1,:,:,:,:));
V1.variable = 'U';
V1.lat = lat;
V1.lon = lon;
lev_Pa = 100*lev;
V1.lev = lev_Pa;

E.variable = 'PS';
[EMASS,t,lat,lon,lev] = get_ensemble_in_time(E,hostname,0);
mass = squeeze(EMASS(1,:,:,:));
V2.variable = 'PS';
V2.lat = lat;
V2.lon = lon;

N = size(wind,1);


%% roll through the ensemble members and compute X3 excitation for each one

XW= zeros(1,N)+NaN;
XM= zeros(1,N)+NaN;

for iens = 1:N
  V1.array = squeeze(wind(iens,:,:,:));
  V2.array = squeeze(mass(iens,:,:));
  XW(iens) = aef(V1,'X3',hostname);
  XM(iens) = aef(V2,'X3',hostname);
end

AEF = XW+XM;

%% load the AEF observations implied by the ensemble for this day

% choose observation sequence file
switch hostname
    case 'blizzard'
        datadir = '/work/scratch/b/b325004/DART_ex/';
end
obs_seq_no = E.day0-E.start+1;
if obs_seq_no < 10, buff = '00'; end
if (obs_seq_no < 100) && (obs_seq_no >= 10), buff = '0'; end
if (obs_seq_no >= 100), buff = ''; end
ffobs = [datadir,E.run_name,'/postprocess/obs_epoch_',buff,num2str(obs_seq_no),'.nc'];

% other inputs to observation reading utility
region        = [0 360 -90 90 -Inf Inf];
QCString      = 'Quality Control';
verbose       = 1;   % anything > 0 == 'true'
obs_string = 'ERP_LOD';


AEF_obs = zeros(1,N);

for iens = 1:N
  copystring_pri = ['prior ensemble member     ',num2str(iens)];
  dum = read_obs_netcdf(ffobs, obs_string, region,copystring_pri, QCString, verbose);
  AEF_obs(iens) = dum.obs(1);;
end

% transform AAM into equivalent LOD changes
LOD0_ms = double(86164*1e3);
AEF_obs2 = LOD0_ms*AEF_obs;

%% comparison between my integral and that performed in DART 

figure(1),clf
plot(AEF,AEF_obs2,'o','LineWidth',2)
hold on
plot(AEF,AEF,'k')
xlabel('Integrated \chi_3 (ms)')
ylabel('\chi_3 from observation operator')
fig_name = 'check_enswind_vs_ensaef1.eps';
pw = 10;
ph = 10;
fs = 1.5;

exportfig(gcf,fig_name,'width',pw,'height',ph,'format','eps','color','cmyk','FontSize',fs,'LineWidth',0.5)

%% compute the correlation between the wind field and the  AEFs on this day 



%% plot the correlation of the wind field and the AEFs  



