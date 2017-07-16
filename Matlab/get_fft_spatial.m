function [fft_out,k,l] = get_fft_spatial(run,diagn,copystring,variable,level,GD,hostname)
%
%% get_fft_spatial
% This function retrieves a CAM-DART diagnostic fields
% at some level and averaged over some block of time,
% and computes the 
% 2D FFT over latitude and longitude.
%
% Lisa Neef, 25 July 2012
%
% MODS:
%
% INPUTS:
%
% OUTPUTS:
%    fft_out: the 2d fft, by zonal and meridional wavenumber
%    k: zonal wavenumber (in km^-1)
%    l: zonal wavenumber (in km^-1)
%
%
%-----------------------------------------------------------------


%clear all;
%clc;
%run             = 'ERP1_2001_N64_UVPS';
%copystring      = 'ensemble mean';   % 'ensemble mean' or 'ensemble spread'
%diagn           =  'RMSE';           % Prior, Posterior, Innov, Truth
%level           = 300;               % desired vertical level in hPa (for 3d vars only)
%variable        = 'U';
% GD             = 146097;	     % start of averaging time
%hostname        = 'blizzard';

%% paths and other settings

% dart output file depends on host name
switch hostname
    case 'ig48'
        DART_output = '/dsk/nathan/lisa/DART/ex/';
    case 'blizzard'
        DART_output = '/work/scratch/b/b325004/DART_ex/';
        % true state files are found on group storage.
	    if strcmp(diagn,'Truth')
           DART_output = '/work/bb0519/b325004/DART/ex/';
        end
end


switch diagn
    case 'Truth'
        rundir = [DART_output,run,'/'];
        list = 'true_state_files';
        copystring = 'true state';
    case 'Prior'
        rundir = [DART_output,run,'/'];
        list = 'prior_state_files';
    case 'Posterior'
        rundir = [DART_output,run,'/'];
        list = 'posterior_state_files';
    case 'Innov'
        rundir = [DART_output,run,'/'];
        list = 'innov_state_files';
    case {'Po-Tr'}
        rundir = [DART_output,run,'/'];
        list = 'po_minus_tr_files';
        copystring = 'ensemble mean';
    case {'RMSE'}
        rundir = [DART_output,run,'/'];
        list = 'po_minus_tr_files';
        copystring = 'ensemble mean';
end



switch variable
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
nf = length(flist);

% load the first file to figure out the observation frequency
ff0 = [rundir,char(flist(1))];
tdum = nc_varget(ff0, 'time');
obs_per_day = length(tdum);
ndays = length(GD);
nt = ndays*obs_per_day;

%% set up arrays: a 2D average field, lat, and lon

ff0 = [rundir,char(flist(1))];

if strcmp(variable,'U')
    lat = nc_varget(ff0,'slat');
else
    lat = nc_varget(ff0,'lat');
end

lon = nc_varget(ff0,'lon');
lev = nc_varget(ff0,'lev');

nlat = length(lat);
nlon = length(lon);

VAR = zeros(nlat,nlon);

% select the desired level.  Nonexistent for 2d variables.
if strcmp(variable,'PS')
    ilev = 1;
else
    ilev = find(lev <= level, 1, 'last' );
end

%% Cycle through DART output files, pull out the 2D field,
% and add the desired days to the average.

k1 = 1;

for ifile = 1:nt
   ff = [rundir,char(flist(ifile))];
   tdum = nc_varget(ff, 'time');
   disp(tdum')
   if (tdum >= GD(1)) + (tdum <= max(GD))  + isfinite(tdum) == 3
       k2 = k1+length(tdum)-1;
       t(k1:k2) = tdum';
   
     
       %  find the right "copy".  for Po-Tr or Pr-Tr, it's just 1.
       var0 = nc_varget(ff,var_key);
       if strcmp(diagn,'Po-Tr') || strcmp(diagn,'RMSE') || strcmp(diagn,'Pr-Tr')
           copy = 1;
       else
           copy = get_copy_index(ff,copystring);
       end


       % choose the right "copy".  The dimensions are different for 3D and
       % 2D variables, and for single versus multiple obs times in one
       % file.
       if (length(tdum) > 1)
           switch variable
               case {'U','V'}
                   if strcmp(diagn,'Truth') || strcmp(diagn,'Po-Tr')|| strcmp(diagn,'RMSE')
                       var1 = squeeze(var0(:,:,:,ilev));  
                   else
                       var1 = squeeze(var0(:,copy,:,:,ilev));                     
                   end
               case 'PS'
                   if strcmp(diagn,'Truth') || strcmp(diagn,'Po-Tr') || strcmp(diagn,'RMSE')
                       var1 = var0;  
                   else
                       var1 = squeeze(var0(:,copy,:,:));
                   end
           end           
       else
           switch variable
               case {'U','V'}
                   if strcmp(diagn,'Truth') || strcmp(diagn,'Po-Tr')|| strcmp(diagn,'RMSE')
                       var1 = squeeze(var0(:,:,ilev));  
                   else
                       var1 = squeeze(var0(copy,:,:,ilev));                     
                   end
               case 'PS'
                   if strcmp(diagn,'Truth') || strcmp(diagn,'Po-Tr') || strcmp(diagn,'RMSE')
                       var1 = var0;  
                   else
                       var1 = squeeze(var0(copy,:,:));
                   end
           end
       end
       
       if strcmp(diagn,'RMSE')
           var2 = var1.^2;
       else
           var2 = var1;
       end
       
       if length(size(var2)) == 3
         for nn = 1:size(var2,1)
           VAR = VAR + (1/nt)*squeeze(var2(nn,:,:));
         end
       else
         VAR = VAR + (1/nt)*var2;
       end
       
       k1 = k2+1;
   end
end


%% if computing RMSE, still need to take the square root
if strcmp(diagn,'RMSE')
    VAR2 = sqrt(VAR);
else
    VAR2 = VAR;
end

%% TEMP: plot and export the variable field.
%[X,Y] = meshgrid(lon,lat);
%fig_name = 'temp_varfield.png';
%pw = 10;
%ph = 6;
%figH = figure('visible','off') ;
%contourf(X,Y,VAR2)
%exportfig(figH,fig_name,'width',pw,'height',ph,'format','png','color','cmyk')
%close(figH)

%% apply the fft to the 2D field:

% Sampling and increments:

d2r = pi/180;
rlon = d2r*lon;
rlat = d2r*lat;

Nx 	= nlon;    % number of samples collected along this dimension
Ny 	= nlat;
Re      = 6371.0;              % radius of earth (km)
dlon	= rlon(2)-rlon(1);
dlat	= rlat(2)-rlat(1);
dx      = Re*dlon;   % zonal distance increment
dy      = Re*dlat;    % meridional distance increment

%  Nyquist frequencies (1/km)
Nyq_k = 1/(2*dx);
Nyq_l = 1/(2*dy);

% increments in wavenumber space
dk = 1/(Nx*dx);
dl  = 1/(Ny*dy);

% now this is the range of each wavenumber
k = -Nyq_k:dk:Nyq_k - dk;
l = -Nyq_l:dl:Nyq_l - dl;

% this is what we want to plot (?)
fft_out = fftshift(fft2(VAR2))*dx*dy;

% this is simply the 2d discrete Fourier transform
%fft_out = zeros(size(VAR2));
%for i1 = 1:Nx
%  for j1 = 1:Ny
%    for i2 = 1:Nx
%      for j2 = 1:Ny
%        fft_out(j1,i1) = fft_out(j1,i1) + VAR2(j2,i2)*exp(-1i*(2*pi)*(k(i1)*x(i2)+l(j1)*y(j2)))*dx*dt;
%      end
%    end
%  end
%end



%---temp--------
%fig_name = 'temp_fft.png';
%figH = figure('visible','off') ;

%contourf(k,l,real(fft_out))
%subplot(1,2,1)
%  semilogy(k,mean(abs(fft_out),1));
%  set(gca,'XLim',[0,max(k)]);
%  xlabel('meridional wavenumber')
%subplot(1,2,2)
%  semilogy(l,mean(abs(fft_out),2));
%  set(gca,'XLim',[0,max(l)]);
%  xlabel('meridional wavenumber')

%exportfig(figH,fig_name,'width',pw,'height',ph,'format','png','color','cmyk')
%close(figH)
%---temp--------

