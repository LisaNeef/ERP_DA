function [VAR_out,t_out] = get_diagn_in_time(E,hostname)
% Compute the value of some DART diagnostic, averaged over a lat-long range,  in time.
% Then these can be plotted by the program plot_diagn_time.m
%
% Lisa Neef, 10 Feb 2012
%
% Mods:
%    16 Mar 2012: replace the diagnostic "ABSPO-Tr" with "RMSEtrue" = the rms
%    true error
%    14 Jun 2013: major overhaul, replacing all the experiment deets with the structure E
%    21 Jun 2013: fixed the if statement in the loop over all files --
%    previously we were not reading in files with multiple assimilation
%    times in correctly.
%    7 Feb 2014: fixed a bug in the above
%----------------------------------------------------------------------------------------------------------------

% temporary inputs if not running as a function:
%clear all; clf;
%clc;
%E_all = load_experiments;
%E = E_all(3);
%hostname = 'blizzard';
%E.day0 = 149021;
%E.dayf = E.day0+28+30;

%% paths and other settings

% dart output file depends on host name
switch hostname
    case 'blizzard'
        DART_output = '/work/scratch/b/b325004/DART_ex/';
end

% if the diagnostic is the truth, fetch the PMO run rather than the assimilation run
% in this case also reset copystring to be the truth
if strcmp(E.diagn,'Truth')
  rundir = [DART_output,E.truth,'/postprocess/'];
  E.copystring = 'true state';
else
  rundir = [DART_output,E.run_name,'/postprocess/'];
end

% find the list of files that we need to load
switch E.diagn
    case 'Truth'
        list = 'true_state_files';
    case 'Prior'
        list = 'prior_state_files';
    case 'Posterior'
        list = 'posterior_state_files';
    case 'Innov'
        list = 'innov_state_files';
    case {'RMSEtrue','RMSE'}
        list = 'po_minus_tr_files';
end

% these are the variables that we actually need to look for in DART-CAM output
switch E.variable
    case 'PS'
        var_key = 'PS';
    case 'U'
        var_key = 'US';
    case 'V'
        var_key = 'VS';
end


% read in the list of needed files
if ~exist([rundir,list],'file')
    disp(['Cant find the file list ',rundir,list])
    return
else
    flist = textread([rundir,list],'%s');
end

%% set up arrays

nf = length(flist);
ff0 = [rundir,char(flist(1))];

% select the desired level.  Nonexistent for 2d variables.
lev = nc_varget(ff0,'lev');
if strcmp(E.variable,'PS')
    ilev = 1;
else
    ilev = find(lev <= E.level, 1, 'last' );
end

tdum = nc_varget(ff0,'time');
obs_per_day = length(tdum);
nt = (E.dayf-E.day0)*obs_per_day+1;
t  = zeros(1,nt)+NaN;
VAR = zeros(1,nt)+NaN;

% select the desired latitude range
if strcmp(E.variable,'U')
    lat = nc_varget(ff0,'slat');
else
    lat = nc_varget(ff0,'lat');
end
lon = nc_varget(ff0,'lon');

j0 = find(lat >= E.latrange(1), 1 );
jf = find(lat <= E.latrange(2), 1, 'last' );
l0 = find(lon >= E.lonrange(1), 1 );
lf = find(lon <= E.lonrange(2), 1, 'last' );


%% Cycle through DART output files and retrieve desired field

% the loop goes to the smaller of (1) the dates considered, or (2) the
% dates available.

k1 = 1;

for ifile = 1:min([E.dayf-E.day0,nf])
   ff = [rundir,char(flist(ifile))];
   tdum = nc_varget(ff, 'time');
   t1 = round(min(tdum));	% bottom day boundary of this file
   t2 = round(max(tdum));	% top day boundary of this file
   if (t1 >= E.day0) + (t2  <= E.dayf)  + isfinite(tdum(1)) == 3
       k2 = k1+length(tdum)-1;
       t(k1:k2) = tdum';
       
       %  find the right "copy".  for RMSEtrue, it's just 1.
       var0 = nc_varget(ff,var_key);
       if strcmp(E.diagn,'RMSEtrue') || strcmp(E.diagn,'RMSE')
           copy = 1;
       else
           copy = get_copy_index(ff,E.copystring);
       end

       % choose the right copy and level.  The dimensions are different for 3D and
       % 2D variables, and for single versus multiple obs times in one
       % file.
       if (length(tdum) > 1)
           switch E.variable
               case {'U','V'}
                   if strcmp(E.diagn,'Truth') || strcmp(E.diagn,'RMSEtrue') || strcmp(E.diagn,'RMSE')
                       var1 = squeeze(var0(:,j0:jf,l0:lf,ilev));  
                   else
                       var1 = squeeze(var0(:,copy,j0:jf,l0:lf,ilev));                     
                   end
               case 'PS'
                   if strcmp(E.diagn,'Truth') || strcmp(E.diagn,'RMSEtrue') || strcmp(E.diagn,'RMSE') 
                       var1 = var0;  
                   else
                       var1 = squeeze(var0(:,copy,j0:jf,l0:lf));
                   end
           end           
       else
           switch E.variable
               case {'U','V'}
                   if strcmp(E.diagn,'Truth') || strcmp(E.diagn,'RMSEtrue') || strcmp(E.diagn,'RMSE')
                       var1 = squeeze(var0(j0:jf,l0:lf,ilev));  
                   else
                       var1 = squeeze(var0(copy,j0:jf,l0:lf,ilev));                     
                   end
               case 'PS'
                   if strcmp(E.diagn,'Truth') || strcmp(E.diagn,'RMSEtrue') || strcmp(E.diagn,'RMSE')
                       var1 = var0;  
                   else
                       var1 = squeeze(var0(copy,j0:jf,l0:lf));
                   end
           end
       end
       
       if strcmp(E.diagn,'RMSEtrue') || strcmp(E.diagn,'RMSE')
           var2 = var1.^2;
       else
           var2 = var1;
       end
       
       % average over the globe.
       if (length(tdum) > 1)
           switch E.variable
               case {'U','V'}
                   VAR(k1:k2) = nanmean(nanmean(var2,2),3);
               case {'PS'}
                   % (convert PS from Pa to hPa)
                   VAR(k1:k2) = nanmean(nanmean(var2,2),3)/100;
           end            
       else
           switch E.variable
               case {'U','V'}
                   VAR(k1:k2) = nanmean(nanmean(var2,2));
               case {'PS'}
                   % (convert PS from Pa to hPa)
                   VAR(k1:k2) = nanmean(nanmean(var2,2))/100;
           end 
       end


       k1 = k2+1;
   end
end


% for RMSE, still have to do the square root
if strcmp(E.diagn,'RMSEtrue') || strcmp(E.diagn,'RMSE')
    VAR2 = VAR*0;
    for ii = 1:length(VAR)
        VAR2(ii) = sqrt(VAR(ii));
    end
else
    VAR2 = VAR;
end


%% Output

VAR_out = VAR2;

t_out = t;
