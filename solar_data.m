function [qs_year,ta_year]=solar_data(iw,bi,gam,pr)
%Function for reading solar data and then calculate the solar irradiation
%on an inclined plane

%Check for the validity of the filename
[filename,change] = check_filename();
%Check if the PVGIS tmy or the tmy2 data type is used 
if iw==0
    %TMY DATA FILE READER FROM PVGSIS
    %Change file name. Example filename 'data_Athens.csv'. 
    %Uncomment next line to use the default filename without input from command line
    if change=='N'
        filename=fullfile(pwd, 'data/data_Athens.csv');
    end
    Loca=latitude(filename,1, 2);
    lat=Loca(1); %Latitude
    long=Loca(2); %Longtitude
    %Change file name
    [timeUTC,T2m,RH,Gh,Gbn,Gdh,IRh,WS10m,WD10m,SP] = importfile(filename,18, 8777);
    h=Gh.'; %Wh/m^2
    hb=Gbn.'; %Wh/m^2
    hd=Gdh.'; %Wh/m^2
    ta_year=T2m.'+273; %Convert to K   
elseif iw==1
    %TMY2 DATA FILE READER
    %Change file name. Example filename 'US-NY-New-York-City-94728.tm2'. 
    %Uncomment next line to use the default filename without input from command line
    %filename='US-NY-New-York-City-94728.tm2';
    if change=='N'
        filename=fullfile(pwd, 'data/US-NY-New-York-City-94728.tm2');
    end
    TMYData = pvl_readtmy2(filename);
    h=TMYData.GHI; %Wh/m^2
    hb=TMYData.DNI; %Wh/m^2
    hd=TMYData.DHI; %Wh/m^2
    ta_year=TMYData.DryBulb/10+273; %Convert to K
    lat=TMYData.SiteLatitude;
    long=TMYData.SiteLongitude;
end
%%
%Calculations for solar declination and  
Julian_Day=(1:1:365);
FYI_R=23.45;
lk=360/365;
ap=(2*pi)/360;
S0=1368;        %Solar constant
decl(1:365)=FYI_R*cos(ap*(lk*(Julian_Day(1:365)-173)));
omegass(1:365)=acosd(-tand(lat)*tand(decl(1:365)));
%For south hemisphere
%omegass(1:365)=acosd(-tand(lat-bi)*tand(decl(1:365)));
%%
% Hourly qs calculation
ii=0;
for i=1:365
    for j=1:24
        ii=ii+1;
        td(i)=60*omegass(i)*2/15;
        om=15*(j-12);
        costh(ii)=sind(decl(i))*sind(lat)*cosd(bi)-sind(decl(i))*cosd(lat)*sind(bi)*cosd(gam)+cosd(decl(i))*cosd(lat)*cosd(bi)*cosd(om)+cosd(decl(i))*sind(lat)*sind(bi)*cosd(gam)*cosd(om)+cosd(decl(i))*sind(bi)*sind(gam)*sind(om);
        %The next expression is applied only for gam=0, collectors facing equator!
        %costh(ii)=sind(decl(i))*sind(lat-bi)+cosd(decl(i))*cosd(lat-bi)*cosd(om);
        qs(ii)=hb(ii)*costh(ii)+hd(ii)*cosd(bi/2)^2+ h(ii)*sind(bi/2)^2*pr; % The outcome is in Whr/(m2)
        %The diffuse terms and reflected terms are equivalent with the next one
        %qs(ii)=hb(ii)*costh(ii) +hd(ii)*cosd((1+bi)/2)+ h(ii)*cosd((1-bi)/2)*pr;
    end
end

qs(isnan(qs))=0;
qs=max(qs,0);
qs_year=qs;
end
