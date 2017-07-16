%function [VAR_out,t_out,lat_out] = get_lat_time_DART_CAM(E,hostname)
%% get_lat_time_dart_cam
%
% Compute the evolution of state variables in CAM prior,
% posterior, and truth states, as a function of latitude and time.
%
% When AAM_weighting is set to an AEF (X1, X2, X3), then the output is in
% mas (for X1 & X2) or microseconds (for X3)
%
% Then these can be plotted by the program plot_lat_time.m
%
% Lisa Neef, 30 Nov 2011
%
% INPUTS:
%  E: a structure holding all the experiment details and what we want to show.
%   these are the field names
%    run_name:
%    truth:
%    copystring:
	%    variable:
	%    level:
	%    AAM_weighting:
	%    diagn:
	%    day0:
	%    dayf:
	%  hostname: currently only supporting 'blizzard'
	%
	% Mods:
	%   8 Dec 2011: add ability to read Prior, Posterior, and Innovation from
	%   DART runs (in addition to the true state).
	%   8 Dec 2011: also adding ability to shuffle through separate files for
	%   different days.
	%   30 Jan 2012: added start and finish date, to make it easier to plot just
	%   a part of the original data.
	%   2  Feb 2012: add the option of Po-Tr as a diagnostic.  In this
	%   case, copystring is automatically selected to be _______
	%   3 Feb 2012: also add abs(Po-Tr) as a diagnostic, or RMSE
	%   27 Feb 2012: make the code able to handle multiple obs times in one file.
	%   20 Mar 2012: instead of plotting option 'ABSPo-Tr', do RMSE (where the
	%   mean is over longitude in this case.)
	%   25 Apr 2013: changes to file paths and inputs to accomodate my new experiments.
	%   10 Jun 2013: make the input encapsulated in a simple structure array
	%   22 Jun 2013: updating the path to the true state files to suit my new expt framework
	%   26 Jul 2013: allowing the selection of a longitude sector

% temporary inputs if not running as a function:
clear all; clf;
E_all = load_experiments;
E = E_all(3);
E.diagn  = 'Innov';
hostname = 'blizzard';
[variable,level,latrange,lonrange] = diagnostic_quantities('U300');
E.variable = variable;
E.level = level;
E.latrange = latrange;
E.longrange = lonrange;
E.dayf = E.day0+10;

%%% paths and other settings

%% dart output file depends on host name
switch hostname
    case 'blizzard'
        DART_output = '/work/scratch/b/b325004/DART_ex/';
end


rundir = [DART_output,E.run_name,'/postprocess/'];

switch E.diagn
    case 'Truth'
        list = 'true_state_files';
        copystring = 'true state';
    case 'Prior'
        list = 'prior_state_files';
    case 'Posterior'
        list = 'posterior_state_files';
    case 'Innov'
        list = 'innov_state_files';
    case 'RMSE'
        list = 'po_minus_tr_files';
        copystring = 'ensemble mean';
end



switch E.variable
    case 'PS'
        var_key = 'PS';
    case 'U'
        var_key = 'US';
    case 'V'
        var_key = 'VS';
    case 'T'
        var_key = 'T';
    case 'Q'
        var_key = 'Q';
    case 'CLDIQ'
        var_key = 'CLDIQ';
    case 'CLDICE'
        var_key = 'CLDICE';
end


% read in the list of needed files
list_with_path = [rundir,list];
if ~exist(list_with_path,'file')
    disp(['Cant find the file list ',list_with_path])
    return
else
    flist = textread(list_with_path,'%s');
end


%% set up arrays

nt = E.dayf-E.day0;
t  = zeros(1,2*nt)+NaN;
nf = length(flist);

if strcmp(E.diagn,'Truth')
  ff0 = char(flist(1));
else
  ff0 = [rundir,char(flist(1))];
end

% pick out the lat/lon ranges we want
if strcmp(E.variable,'U')
    lat2 = nc_varget(ff0,'slat');
else
    lat2 = nc_varget(ff0,'lat');
end
lon2 = nc_varget(ff0,'lon');

y1 = find(lat2 >= E.latrange(1),1,'first');
y2 = find(lat2 <= E.latrange(2),1,'last');
x1 = find(lon2 >= E.lonrange(1),1,'first');
x2 = find(lon2 <= E.lonrange(2),1,'last');

lat = lat2(y1:y2);
nlat = length(lat);
lon = lon2(x1:x2);
rlon = lon*pi/180;

lev = nc_varget(ff0,'lev');

VAR = zeros(nlat,nt*2)+NaN;

% select the desired level.  Nonexistent for 2d variables.
if strcmp(E.variable,'PS')
    ilev = 1;
else
    ilev = find(lev <= E.level, 1, 'last' );
end

%% Cycle through DART output files and retrieve desired field

% the loop goes to the smaller of (1) the dates considered, or (2) the
% dates available.

k1 = 1;

break

for ifile = 1:min([nt,nf])
   if strcmp(E.diagn,'Truth')
     ff = char(flist(ifile));
   else
     ff = [rundir,char(flist(ifile))];
   end
   disp(ff)
   tdum = nc_varget(ff, 'time');
   if isempty(tdum), tdum = 0; end   % how to handle corrupted files
   if ((tdum(1) >= E.day0) && (max(tdum) <= E.dayf)) 
       k2 = k1+length(tdum)-1;
       t(k1:k2) = tdum';
       
       %  find the right "copy".  for Po-Tr, it's just 1.
       var0 = nc_varget(ff,var_key);
       if strcmp(E.diagn,'Po-Tr') || strcmp(E.diagn,'RMSE')
           copy = 1;
       else
           copy = get_copy_index(ff,E.copystring);
       end

       % choose the right "copy".  The dimensions are different for 3D and
       % 2D variables, and for single versus multiple obs times in one
       % file.
       if (length(tdum) > 1)
           switch E.variable  
               case {'U','V','T','Q','CLDIQ','CLDICE'}
                   if strcmp(E.diagn,'Truth') || strcmp(E.diagn,'Po-Tr')|| strcmp(E.diagn,'RMSE')
                       var1 = squeeze(var0(:,y1:y2,x1:x2,ilev));  
                   else
                       var1 = squeeze(var0(:,copy,y1:y2,x1:x2,ilev));                     
                   end
               case 'PS'
                   if strcmp(E.diagn,'Truth') || strcmp(E.diagn,'Po-Tr') || strcmp(E.diagn,'RMSE')
                       var1 = var0(:,y1:y2,x1:x2);  
                   else
                       var1 = squeeze(var0(:,copy,y1:y2,x1:x2));
                   end
           end           
       else
           switch E.variable
               case {'U','V','T','Q','CLDIQ','CLDICE'}
                   if strcmp(E.diagn,'Truth') || strcmp(E.diagn,'Po-Tr')|| strcmp(E.diagn,'RMSE')
                       var1 = squeeze(var0(y1:y2,x1:x2,ilev));  
                   else
                       var1 = squeeze(var0(copy,y1:y2,x1:x2,ilev));                     
                   end
               case 'PS'
                   if strcmp(E.diagn,'Truth') || strcmp(E.diagn,'Po-Tr') || strcmp(E.diagn,'RMSE')
                       var1 = var0(y1:y2,x1:x2);  
                   else
                       var1 = squeeze(var0(copy,y1:y2,x1:x2));
                   end
           end
       end
       
       if strcmp(E.diagn,'RMSE')
           var2 = var1.^2;
       else
           var2 = var1;
       end
         
       
       % choose whether to integrate zonally, or just average.
       if (length(tdum) > 1)
           switch E.AAM_weighting
               case {'X1','X2','X3'}
                   VAR(:,k1:k2) = squeeze(trapz(rlon,var2,3))';
               case 'none'
                   switch E.variable
                       case {'U','V','T','Q','CLDIQ','CLDICE'}
                           VAR(:,k1:k2) = squeeze(nanmean(var2,3))';
                       case {'PS'}
                            % (convert PS from Pa to hPa)
                            VAR(:,k1:k2) = nanmean(var2,3)'/100;
                   end
           end
       else
           switch E.AAM_weighting
               case {'X1','X2','X3'}
                   VAR(:,ifile) = squeeze(trapz(rlon,var1,2))';
               case 'none'
                   switch E.variable
                       case {'U','V','T','Q','CLDIQ','CLDICE'}
                           VAR(:,k1:k2) = nanmean(var2,2);
                       case {'PS'}
                            % (convert PS from Pa to hPa)
                            VAR(:,k1:k2) = nanmean(var2,2)/100;
                   end
           end
       end
   else	% loop over whether file is part of times that we want
      k2 = k1;
   end
   k1 = k2+1;
end

% take out the empty space on 29 Feb, if it exists
dum = VAR(1,:);
good = find(isfinite(dum) == 1);
VAR2 = VAR(:,good);


%% if computing RMSE, still need to take the square root
if strcmp(E.diagn,'RMSE')
    VAR3 = sqrt(VAR2);
else
    VAR3 = VAR2;
end



%% Output

VAR_out = VAR3;
t_out = t(good);
lat_out = lat;
