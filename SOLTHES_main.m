clearvars
%*******************INPUTS AND VARIABLES********************%
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
[qs_year,ta_year]=solar_data(iw,bi,gam,pr);
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
TST(1,tend-tstart)=Tst;QU=zeros(1,tend-tstart);N_A=zeros(1,tend-tstart);
DL=zeros(1,tend-tstart);DC=zeros(1,tend-tstart);TA(1,tend-tstart)=mean(ta_year(tstart:tend));
QL=zeros(1,tend-tstart);
x=linspace(tstart,tend,tend+1-tstart);
ttot=linspace(1,8760,8760); %All the hours of the year

%Double for loop for doing a parametric analysis and find the optimal
%collector area [m2] and volume storage [m3]
for ka=1:size(A_m,2)
    A=A_m(ka);
    for kv=1:size(Vst_th,2)
        Vst=Vst_th(kv);
        %% Calculations section
        %Insert collector mass flow rate mc [Kg/s] otherwise use rule of
        %thumb A/60 [kg/s]
        mc = A/(60);       
        %Storage area calculation if Ast is not given and the volume storage Vst is given
        if (Vst>0)      
            mst=Vst*(rho*c);
            lst=(4.*Vst*(rlndia^2)/pi)^0.333;
            dst=lst/rlndia;
            Ast=pi*(dst/2+lst);
        end 
        
        %Initial values
        dc=0; 
        dl=0;
        thour=0;
        t_month=0;
        t=tstart*60;
        Tam=mean(ta_year(tstart:tend));
        qsmax=max(qs_year(tstart:tend));
        g=mc*c*Tam/qsmax/A;
        
        %Calculate b or U
        if (U>0) 
            b=U*Tam/qsmax;      % Collector value b based on U
        else
            U=b*qsmax/Tam ;      % Collector value U based on b
        end 
    
        %Initial values
        Tlin=Tst;Tfin=Tst;Tfout=Tst;Tlout=Tst;
        sum_us=0;sum_l=0;sum_s=0;sum_dl=0;sum_dh=0;
        Qu=0;Qst=0;n=0;Ql=0;Ql_dhw=0;ml_dhw=0;Ql_sp=0; %Uncomment if it is constant load

        t_tmp=1;
        Vec(t_tmp,1)=tstart;Vec(t_tmp,2)=Tfin;Vec(t_tmp,3)=Tfout;Vec(t_tmp,4)=Tst;
        Vec(t_tmp,5)=Tlin;Vec(t_tmp,6)=Tlout;Vec(t_tmp,7)=ta_year(t/60);Vec(t_tmp,8)=dc;
        Vec(t_tmp,9)=dc; Vec(t_tmp,10)=qs_year(t/60);Vec(t_tmp,11)=Qu;Vec(t_tmp,12)=Ql;
        Vec(t_tmp,13)=Ql_dhw;Vec(t_tmp,14)=Qst;Vec(t_tmp,15)=n;
        
        TST(t_tmp)=Tst;TA(t_tmp)=ta_year(t/60);QL(t_tmp)=Ql;

        %Main computation loop, the time step is 1 min
        while (t<60*tend)
            t=t+1;
            daycount=t/60/24+1;
            daycount=floor(daycount);
            if (mod(t,1440)==0) %Change of day
                thour=0;
            end
            if (mod(t,tr)==0)
                thour=thour+1;
                t_tmp=t_tmp+1;
            end
            %Find solar radiation and ambient temperature
            qs=interp1(ttot,qs_year,t/60);
            Ta=interp1(ttot,ta_year,t/60);

            %Degree hours calculation
            if (isp==1) 
                if (mod(t,tr)==0 ) 
                    if (Tb>Ta) 
                        dh=(Tb-Ta); 
                    else
                        dh=0;
                    end 
                    Ql_sp=dh*Uhouse*Ahouse; % Load in Watt hours            
                    sum_dh=sum_dh+dh;
                end 
            end 
            %Domestic hot water calculation
            if (idhw==1) 
                if (mod(t,tr)==0)
                    qload=ml_u(thour)*(Treq-Tsup)*c/3600;
                    ml_dhw=qload/((Tlin-Tsup)*c);
                    Ql_dhw=ml_dhw*(Tlin-Tsup)*c;
                end 
            end   
            
            Tfin=Tst;
            Tstag=Ta+ta_eff*qs/b/qsmax*Tam;
            
            %Control of the solar thermal system based on Howell's book 
            %"Solar-Thermal Energy Systems: Analysis and Design"
            if (Tstag-Tfin>6)
                if (Tst>Tstmax) 
                    dc=0;
                else
                    Tfout=Tfin*(1-Fr*b/g)+Fr*Tam/g*(ta_eff*qs/qsmax+b*Ta/Tam);
                    if (Tfout-Tfin>2)
                        dc=1;
                    else
                        dc=0;
                    end
                end
            else 
                dc=0;
            end
            %Calculate total load 
            if (idhw==1)
               Ql=Ql_sp+Ql_dhw;
               if (isp==0) 
                   ml=0;
               end
               ml_all=ml+ml_dhw;
               DTl=Ql/ml_all/c;
            else
               Ql=Ql_sp;
               DTl=Ql/ml/c;
            end
            %Control of the solar thermal system 
            if (DTl>2)
                if (Tst<Tlmin)  
                    dl=0;
                else 
                    dl=1;
                end 
            else 
                dl=0;
            end 
            
            Qu=dc*mc*c*(Tfout-Tfin);
            Qst=dc*Qu-dl*Ql-Ust*Ast*(Tst-Ta);
            Tst=Tst+Qst*60/mst;
            Tlin=Tst;
            
            if (dl==1)
                Tlout=Tlin-DTl;
            end
            %efficiency calculation
            if (qs>0) 
                n=Qu/(qs*A);
            else
                n=0;
            end
            %Sum all the quantities for the whole simulation time
            sum_l=sum_l+Ql*tr;
            sum_us=sum_us+Qu*tr;
            sum_dl=sum_dl+dl*Ql*tr; 
            sum_s=sum_s+qs*A*tr;
            
            %Keep the hourly values of the quantities
            if mod(t,tr)==0 
                TST(1,t_tmp)=Tst;
                TA(1,t_tmp)=Ta;
                DC(1,t_tmp)=dc;
                DL(1,t_tmp)=dl;
                QU(1,t_tmp)=Qu/1000;
                N_A(1,t_tmp)=n*100;
                QL(1,t_tmp)=Ql/1000;
                
                Vec(t_tmp,1)=t/60;
                Vec(t_tmp,2)=Tfin;
                Vec(t_tmp,3)=Tfout;
                Vec(t_tmp,4)=Tst;
                Vec(t_tmp,5)=Tlin;
                Vec(t_tmp,6)=Tlout;
                Vec(t_tmp,7)=Ta;
                Vec(t_tmp,8)=dc;
                Vec(t_tmp,9)=dl;
                Vec(t_tmp,10)=qs;
                Vec(t_tmp,11)=Qu;
                Vec(t_tmp,12)=Ql;
                Vec(t_tmp,13)=Ql_dhw;
                Vec(t_tmp,14)=Qst;
                Vec(t_tmp,15)=n;
            end
        end
        %Display key metrics for the solar thermal system
        fdisp = ['Fraction of load= ',num2str(sum_dl/sum_l)];
        ndisp = ['Daily average efficiency=',num2str(sum_us/sum_s)];
        disp(fdisp)
        disp(ndisp)

        f(kv,ka)=sum_dl/sum_l;
    end 
end
%Plot or print the quantities of interest
output(f,Vec,x,tstart,tend,TST,TA,DC,DL,QU,N_A,QL)
disp('Simulation is complete.')