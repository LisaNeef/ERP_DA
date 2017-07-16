% function plot_fft_statial(run,copystring,diagn,dim,variable,level,GD,hostname)   
%% plot_fft_spatial
%
% Make a plot of the spatial spectrum of some DART diagnostic as a function
% of either meridional or zonal wavenumber.
%
% Lisa Neef, 9 Aug 2012
%
% INPUTS:
%   run: the run that we are interested in.
%   copystring: % 'ensemble mean' or 'ensemble spread', or a specific ens. member
%   dimension: choose which horizontal wavenumber to plot - "merid" or "zonal"
%   variable
%   level: a nearby pressure level on which to compute the spectrum (in hPa)
%   GD: array of Gregorian dates over which to average the spectrum
%   hostname
%
% OUTPUTS:
%
% MODS:
%
%------------------------------------------------------

%---temp inputs-------

clear all;
clc;

run             = 'ERP1_2001_N64_UVPS';
copystring      = 'ensemble mean';   % 'ensemble mean' or 'ensemble spread'
diagn           =  'RMSE';           % Prior, Posterior, Innov, Truth
dim 		= 'zonal';
variable        = 'U';
level           = 300;               % desired vertical level in hPa (for 3d vars only)
GD              = 146097:1:146104;
hostname        = 'blizzard';

%---temp inputs-------


%% retrieve the 2d fft of the desired field.

[fft_2d,k,l] = get_fft_spatial(run,diagn,copystring,variable,level,GD,hostname);


% select the desired dimension

switch dim
  case 'merid'
    wavenr = l;
    fft_slice = mean(abs(fft_2d),1);
    XL = 'meridional wavenumber (1/km)';
  case 'zonal'
    wavenr = k;
    fft_slice = mean(abs(fft_2d),1);
    XL = 'zonal wavenumber (1/km)';
end

%---temp
fig_name = 'temp_fft_averaged.png';
figH = figure('visible','off') ;
ph = 20;
pw = 20;
%---temp


% make the plots

semilogy(wavenr,fft_slice);
set(gca,'XLim',[0,max(k)]);

xlabel(XL)


%---temp plot export
exportfig(figH,fig_name,'width',pw,'height',ph,'format','png','color','cmyk')
close(figH)
%---temp plot export






