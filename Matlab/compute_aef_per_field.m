function aef_out = compute_aef_per_field(varfield,lat,lon,lev,variable,aef)
%
% compute_aef_per_field.m
%
% Given a certain variable field, compute the part of the AEF resulting from that field 
% by integrating over the entire field.
%
% INPUTS;
% varfield = variable field, can be 3D or 2D, but the dimensions
%     have to be lat, lon, lev (or lat,lon)
% lat, lon = the lat and lon and lev arrays that go with the above
% variable = name of the variable
% aef = name of the desidred AEF.


%% temporary inputs
%variable = 'U';
%aef = 'X1';
%lat = -90:2:90;
%lon = -180:2:180;
%lev = 1:30;
%varfield = rand(nlat,nlon,nlev);


% define dimensions
nlat = length(lat);
nlon = length(lon);
nlev = length(lev);

%% also set up lon and lat arrays in radians
rlon=lon*pi/180;
rlat=lat*pi/180;

%% load some other stuff that's needed for the integration

%  the weights for this variable
w = eam_weights(lat,lon,aef,variable);

% the prefactors that nondimensionalize the excitation functions
fac = eam_prefactors(aef,variable);

% sidereal LOD in milliseconds.
LOD0_ms = double(86164*1e3);


%% integrate over lat, lon, and lev.

switch variable
  case 'PS'

        % Set an array that represents the weighted variables.
        var_weighted = w'.*varfield;


        % Integrate over lon
        var_intlon = zeros(1,nlat);
            for j=1:nlat
                var_intlon(j)=trapz(rlon,squeeze(var_weighted(j,:)));
            end


        % Integrate over lat
            %a negative sign enters here because latitude array is defined
            %in opposite direction of the integral.
         var_intlatlon = -trapz(rlat,var_intlon);

        % Apply prefactors
        switch aef
            case 'X1'
                aef_out =var_intlatlon*fac*360*3600*1000/(2*pi);
            case 'X2'
                aef_out=var_intlatlon*fac*360*3600*1000/(2*pi);
            case 'X3'
                aef_out=var_intlatlon*fac*LOD0_ms;
        end

    case {'U','V'}

        % Set an array that represents the weighted variables.
        var_weighted = zeros(nlat,nlon,nlev);
        for k=1:nlev
              var_weighted(:,:,k)=squeeze(varfield(:,:,k)).*w';
        end

     
       
       % Integrate over lon
       var_intlon = zeros(nlev,nlat);
       for k=1:nlev   % i over levels
           for j=1:nlat  % j over lat
               var_intlon(j,k)=trapz(rlon,var_weighted(j,:,k),2);
           end
       end

       % Integrate over lat
       % add a negative sign here because the lat array is defined
       % North-South but the integral is defined the other way.
       var_intlatlon=zeros(1,nlev);
       for i=1:nlev  % i over levels
           var_intlatlon(i)=-trapz(rlat,var_intlon(:,i),1);
       end


       % Integrate over lev
       var_intlatlonlev = -trapz(lev,var_intlatlon);

       % prefactors
       switch aef
           case 'X1'
               aef_out=var_intlatlonlev*fac*360*3600*1000/(2*pi);
           case 'X2'
               aef_out=var_intlatlonlev*fac*360*3600*1000/(2*pi);
           case 'X3'
               aef_out=var_intlatlonlev*fac*LOD0_ms;
       end


end 






