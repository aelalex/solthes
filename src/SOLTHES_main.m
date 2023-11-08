clearvars
%% *******************INPUTS AND VARIABLES********************%
disp('SOLar THErmaL SySTEmS EducaTiOnaL Software')
%Check for a new file name for weather data.
[filename,change] = check_filename();
%If no new file is used, the default csv file is imported.
%Filename can also be changed from here.
if change=='N'
    filename=fullfile(pwd, '../data/data_Athens.csv');
    %For TMY2 file: Uncomment next line to use the default filename
    %filename=fullfile(pwd, '../data/US-NY-New-York-City-94728.tm2');
end
%Insert type of solar thermal system, idhw=1 for domestic how water, for anything else idhw=0
idhw=1;
%Insert type of load, for constant load sload=0, for time dependent load sload=1
sload=1;
%Insert isp=1 if it is a space heating system in order to calculate the degree hours
isp=1;
%Insert time of start in hours%
tstart = 1;
%Insert time of end in hours%
tend =24;
%Choose tstart and tend based on each month
%Month	Day	hour	hour
%JAN	1	1       744
%FEB	32	744     1416
%MAR	60	1416	2160
%APR	91	2160	2880
%MAY	121	2880	3624
%JUN	152	3624	4344
%JUL	182	4344	5088
%AUG	213	5088	5832
%SEP	244	5832	6552
%OCT	274	6552	7296
%NOV	305	7296	8016
%DEC	335	8016	8760
%Characteristic day for each month
char_day=[17 47 75 105 135 162 198 228 258 288 318 344];
%Insert collector slope in degrees
bi=40;
%Insert Surface azimuth angle
gam=0;
%Insert effective ground reflectance, pr=0.2 for ground NOT covered by now,%pr=0.7 for snow covered ground
pr=0.2;
%Load solar radation on sloped surface and temperature from Solar_data function
[qs_year,ta_year]=solar_data(filename,bi,gam,pr);
%COLLECTOR DATA INPUT%
%Insert collector surface A [m^2]. Add more values of collector surface for
%parametric analysis
A_m=[20];
%Insert collector property ta_eff
ta_eff =0.822 ;
%Insert collector heat removal parameter FR
Fr =0.9 ;
%Insert collector heat transfer coefficient U [W/mA2*K] or collector value b can be inserted and then U is computed
U=5.33;
%Insert specific heat of working fluid [J/kg*K]%
c = 4200;   
%Insert density of the fluid [kg/m3]
rho=1000;   
%STORAGE DATA INPUT%
%Insert storage surface Ast [mA2] otherwise insert volume storage [m3] and length-diameter ratio of tank [m]
%Ast=3
Vst_th=[0.5];
rlndia=3;
%Uncomment next line and insert storage capacity mst*cp {J/K} if the volume of storage is not known
%mst =1294*1000;
%Insert storage heat transfer coefficient Ust [W/m^2*K]
Ust =0.35;
%Insert initial storage temperature Tst,initial [K]
Tst =300;
%Insert maximum storage temperature Tstmax allowed [K]
Tstmax =373;
%LOAD DATA INPUT%
%Insert load Ql [W] if the system is not a space heating or dhw system
if isp~=1 && idhw~=1
    Ql=2000;	
end
%Insert load minimum temperature Tl,min [K]
Tlmin =300;
%Insert load mass flow rate ml [Kg/s]
ml=1/60;
%Space heating
%Insert balance temperature in [K]
Tb=18.3+273;
%Insert total area of the house
Ahouse=320;
%Insert house heat transfer coefficient U [W/mA2*K] 
Uhouse=0.55;
%Domestic hot water
%Load input, sload=1 for time dependent load otherwise sload=0 for contant load
if idhw==1
    %Insert required temperature Treq [K]
    Treq=273+45;
    %Insert water main supply temperature Tsup [K]
    Tsup=273+10;
    %Insert number of residents
    residents=8;
    ml_max=residents*100; %Liters per day per person * persons=Liters per day=Kg per day 
    if (sload==1)   
        %Insert load time in minutes, 24 points, usually the domestic hot
        %water is a 24-hour profile
        %hr = [60,120,180,240,300, 360, 420, 480, 540, 600,660,720,780,840,900,960,1020,1080,1140,1200,1260,1320,1380,1440];
        %Insert load time in hours, 24 points
        hr = linspace(1,24,24);
        %Insert load in kg/h, 24 points if it is DHW system
        ml_u=[0,0,0,0,0,0,0.2*ml_max,0.2*ml_max,0,0,0,0.1*ml_max,0.1*ml_max,0,0,0,0,0.2*ml_max,0.2*ml_max,0,0,0,0,0];
        %ml_u=[5.9,14.4,20.0,23.8,20.3,12.5,10.6,13.8,8.4,6.3,6.0,10.0,20.2,32.0,26.4,20.7,14.5,14.2,0.3,5.9,0.0,0.0,0.0,0.0];
        %Hours of the RAND profile
        hr_load=24;  
    end
end
%Insert time between output in minutes%
tr =60;
%Create vectors   
Vec=[];
f=[];
TST(1,tend-tstart)=Tst;QU=zeros(1,tend-tstart);N_A=zeros(1,tend-tstart);
DL=zeros(1,tend-tstart);DC=zeros(1,tend-tstart);TA(1,tend-tstart)=mean(ta_year(tstart:tend));
QL=zeros(1,tend-tstart);
x=linspace(tstart,tend,tend+1-tstart);
ttot=linspace(1,8760,8760); %All the hours of the year
%% *******************Calculation********************%
%Double for loop for doing a parametric analysis and find the optimal
%collector area [m2] and volume storage [m3]
for ka=1:size(A_m,2)
    A=A_m(ka);
    for kv=1:size(Vst_th,2)
        Vst=Vst_th(kv);
        [Vec, TST, TA, QL, DC, DL, QU, N_A, fsingle] = calculation(A, Vst, rho, c, rlndia, tstart, ta_year, tend, qs_year, U, Tst, Vec, TST, TA, QL, tr, ttot, isp, Tb, Uhouse, Ahouse, idhw, ml_u, Treq, Tsup, ta_eff, Tstmax, Fr, ml, Tlmin, Ust, DC, DL, QU, N_A);
        f(ka,kv)=fsingle;
    end
end
%% *******************Output data********************%
% Plot or print the quantities of interest
output(f,A_m,Vst_th,Vec,x,tstart,tend,TST,TA,DC,DL,QU,N_A,QL)
disp('Simulation is complete.')