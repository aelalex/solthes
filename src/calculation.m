function [Vec, TST, TA, QL, DC, DL, QU, N_A, f] = calculation(A, Vst, rho, c, rlndia, tstart, ta_year, tend, qs_year, U, Tst, Vec, TST, TA, QL, tr, ttot, isp, Tb, Uhouse, Ahouse, idhw, ml_u, Treq, Tsup, ta_eff, Tstmax, Fr, ml, Tlmin, Ust, DC, DL, QU, N_A)
% [Vec, TST, TA, QL, DC, DL, QU, N_A, f] = calculation(A, Vst, rho, c, rlndia, tstart, ta_year, tend, qs_year, U, Tst, Vec, TST, TA, QL, tr, ttot, isp, Tb, Uhouse, Ahouse, idhw, ml_u, Treq, Tsup, ta_eff, Tstmax, Fr, ml, Tlmin, Ust, DC, DL, QU, N_A)
%   
%  Main calculation loop for the solar thermal system. Includes the
%  initialization of variables, the main calculation loop along with all
%  the control of the system and the store of generated data in arrays that
%  are used in output.
%  

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

f=sum_dl/sum_l;
end