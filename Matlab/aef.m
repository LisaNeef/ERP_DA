function aef_out = aef(V,component,hostname)
%% aef.m
%  this function takes an input wind or surface pressure field and computes 
%  the AAM excitation function (AEF), specifically, a given component (X1, X2, or X3)
%
%  INPUTS:
%   V: structure holding the variable field, the variable name, and
%   the associate lat, lon, and pressure arrays that go with it.
%   The angular momentum component we are interested in ('X1','X2', or 'X3')
%   hostname: currently only supporting blizzard 
%
%  TODO:
%   - make it possible to do the IB approximation
%---------------------------------------------------------------------------------------------


%% inputs for running manually
%clear all;
%clc;
%V.variable 	= 'PS';
%V.lat		= -90:1:90;
%V.lon		= 1:1:360;
%V.lev		= [100, 200, 300, 500, 700, 1000, 2000, 3000, 5000, 7000, 10000, 15000,... 
%    20000, 25000, 30000, 40000, 50000, 60000, 70000, 77500, 85000, 92500,... 
%    100000];
%%V.array    	= randn(length(V.lat),length(V.lon),length(V.lev));
%V.array    	= randn(length(V.lat),length(V.lon));
%component	= 'X1';
%hostname	= 'blizzard';
%-----------------------------------


%% load the weights for this variable  
w = eam_weights(V.lat,V.lon,component,V.variable);

%% the prefactors that nondimensionalize the excitation functions
fac = eam_prefactors(component,V.variable);

%% sidereal LOD in milliseconds.
LOD0_ms = double(86164*1e3);     

%% convert latitude and longitude to radians
rlat=V.lat*pi/180;
rlon=V.lon*pi/180;

%% abbreviate the array, and reshape it so that it's lev-lat-lon
nlat = length(V.lat);
nlon = length(V.lon);
if strcmp(V.variable,'PS')
  as = [nlat,nlon];
else
  nlev = length(V.lev);
  as = [nlev,nlat,nlon];
end
X = reshape(V.array,as);

switch V.variable
  case 'PS'
    %% uncomment the next block in order to apply the IB approximation to the pressure term
    %% this requires putting in a landmask file, specified in V.landmask
    %ps = zeros(nt,nlat,nlon);
    %LM = nc_varget(V.landmask,'lsm');	 % land mask
    %SM = double(LM*0);
    %SM(LM == 0) = 1;                 % sea mask
    %dxyp = gridcellarea(nlat,nlon);
    %dxyp2 = dxyp*ones(1,nlon);
    %sea_area = sum(sum(dxyp2.*SM));
    %for ii=1:nt
    %  pstemp = double(squeeze(X(ii,:,:)));
    %  ps_sea_ave = sum(sum(pstemp.*SM.*dxyp2))/sea_area;
    %  ps_ave = pstemp.*LM+ps_sea_ave*SM;
    %  ps(ii,:,:) = ps_ave(lat0:latf,:);
    %end

    % weight the surface pressure field
    pp=X.*w';
       
    % integrate over lon
    pp2 = trapz(rlon,pp,2);
     
    % integrate over lat
    % add a negative sign here if the lat array is defined
    % North-South but the integral is defined the other way.
    if V.lat(1)>V.lat(nlat)
      signfac = -1;
    else
      signfac = 1;
    end
    pp3 = signfac*trapz(rlat,pp2);
    pp4 = pp3;

     
  case {'U','V'}
                  
    % Set up the array pp, which represents the weighted variables.
    pp = zeros(nlev,nlat,nlon);
    for i=1:nlev
        pp(i,:,:)=squeeze(X(i,:,:)).*w';
    end
      
        
    % integrate over lon
    pp2=trapz(rlon,pp,3);   
       
    % integrate over lat
    % add a negative sign here if the lat array is defined
    % North-South but the integral is defined the other way.
    if V.lat(1)>V.lat(nlat)
      signfac = -1;
    else
      signfac = 1;
    end
    pp3 = signfac*trapz(rlat,pp2,2);
       
     
    % Integrate over vertical levels.
    % the vertical levels here need to be in Pascal
    % add a negative sign here if the vertical levels go from from the surface to the top
    if V.lev(1)>V.lev(nlev)
      signfac = -1;
    else
      signfac = 1;
    end
    pp4 = signfac*trapz(V.lev,pp3);
    

end  %switching variables


%% multiply by the appropriate prefactors to get the units in equivalent ERPs.
switch component
  case {'X1','X2'}
    pp5=pp4*fac*360*3600*1000/(2*pi);
  case 'X3'
    pp5=pp4*fac*LOD0_ms;
end        

%% prepare output
aef_out = pp5;


