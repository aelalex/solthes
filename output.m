function output(f,Vec,x,tstart,tend,TST,TA,DC,DL,QU,N_A,QL)
%Export quantities of interest in visual and text form
%   Detailed explanation goes here

%Do you want to plot?
prompt='Plot some quantity of interest or end the program? plot or end:  ';
txt = input(prompt,'s');
while not (isequal(txt,'plot') || isequal(txt,'end'))
    prompt='Please enter plot or end:  ';
    txt = input(prompt,'s');
end
while (isequal(txt,'plot'))
    %what to plot?
    prompt='Plot the fraction of load (f) or the transient quantities (q)?  f or q:  ';
    txt = input(prompt,'s');
    while not (isequal(txt,'f') || isequal(txt,'q'))
        prompt='Please enter f or q:  ';
        txt = input(prompt,'s');
    end
    if txt=='f'
        %If f is a single value, then dont plot results
        if (size(f)>1)
            figure(1)
            plot(Vst_th,f(:,:),'LineWidth',2)
            grid
            title('Fraction of load (f)','FontSize',24,'FontWeight','bold')
            xlabel('V_{st} [m^{3}]','FontSize',20,'FontWeight','bold')
            set(gca,'FontSize',15)
            ylabel('f','FontSize',24,'FontWeight','bold')
            legendCell = cellstr(num2str(A_m'));
            legend(legendCell,'Location','southeast','FontSize',20)
        else
            disp('Not enough values of f to make a plot!')
        end
    else
        %Which quantity to plot?
        prompt='Which quantity do you want to plot? Storage temperature: TST, Ambient temperature: TA, Collector switch: DC, Load switch: DL, Useful energy gain: QU, efficiency: N_A, thermal load: QL ';
        txt = input(prompt,'s');
        while not (isequal(txt,'TST') || isequal(txt,'TA')|| isequal(txt,'DC') || isequal(txt,'DL') || isequal(txt,'QU') || isequal(txt,'N_A') || isequal(txt,'QL'))
            prompt='Please enter TST or TA or DC or DL or QU or N_A or QL:  ';
            txt = input(prompt,'s');
        end
        if isequal(txt,'TST') 
            %Uncomment to plot Tst, Ta, Qu, Ql, n, dc,dl
            figure ('Name','Tstorage [K]')
            plot(x,TST);
            axis([tstart, tend, 300, 340]);
            xlabel('t (hours)','FontSize',20,'FontWeight','bold');
            set(gca,'FontSize',15)
            ylabel('Tst(K)','FontSize',20,'FontWeight','bold');
            grid('on');
        elseif  isequal(txt,'TA')
            figure ('Name','Ta [K]')
            plot(x,TA);
            axis([tstart, tend, min(TA), max(TA)]);
            xlabel('t (hours)','FontSize',20,'FontWeight','bold');
            set(gca,'FontSize',15)
            ylabel('Ta(K)','FontSize',24,'FontWeight','bold');
            grid('on');
        elseif isequal(txt,'DC')
            figure ('Name','Switch collector: dc')
            plot(x,DC);
            axis([tstart, tend, 0, 1]);
            xlabel('t (hours)','FontSize',20,'FontWeight','bold');
            ylabel('dc','FontSize',24,'FontWeight','bold');
            set(gca,'FontSize',15)
            grid('on');       
        elseif isequal(txt,'DL')
            figure ('Name','Switch load: dl')
            plot(x,DL);
            axis([tstart, tend, 0, 1]);
            xlabel('t (hours)','FontSize',20,'FontWeight','bold');
            ylabel('dl','FontSize',24,'FontWeight','bold');
            set(gca,'FontSize',15)
            grid('on');      
        elseif isequal(txt,'QU')
            figure ('Name','Quseful(kW)')
            plot(x,QU);
            axis([tstart, tend, 0, max(QU)]);
            xlabel('t (hours)','FontSize',20,'FontWeight','bold');
            ylabel('Qu(kW)','FontSize',24,'FontWeight','bold');
            set(gca,'FontSize',15)
            grid('on');
        elseif isequal(txt,'N_A')
            figure ('Name','Efficiency(%)')
            plot(x,N_A);
            axis([tstart, tend, 0, 100]);
            xlabel('t (hours)','FontSize',20,'FontWeight','bold');
            ylabel('n(%)','FontSize',24,'FontWeight','bold');
            set(gca,'FontSize',15)
            grid('on');
        elseif isequal(txt,'QL')
            figure ('Name','Qload(kW)')
            plot(x,QL);
            axis([tstart, tend, min(QL), max(QL)]);
            xlabel('t (hours)','FontSize',20,'FontWeight','bold');
            ylabel('Ql(kW)','FontSize',24,'FontWeight','bold');
            set(gca,'FontSize',15)
            grid('on');       
        end
    end
    prompt='Plot some other quantity or end the program? plot or end:  ';
    txt = input(prompt,'s');
    while  not (isequal(txt,'plot') || isequal(txt,'end'))
        prompt='Please enter plot or end:  ';
        txt = input(prompt,'s');
    end
end

%Ask if the output file is needed in xls form
prompt = 'Do you want to save the output file? Y or N:  ';
txt = input(prompt,'s');
while (txt~='Y' && txt~="N")
    prompt='Please enter Y or N:  ';
    txt = input(prompt,'s');
end
if txt=='Y'
    disp('Writing file to xls format may take some time depending on the simulation hours')
    col_header={'Hour','Tfin','Tfout','Tst','Tlin','Tlout','Ta','dc','dl','Qs','Qu','Ql','Qdhw','Qst','n'};     %Row cell array (for column labels)
    xlswrite ('SOLTHES_output',Vec,'Results','B2');
    xlswrite('SOLTHES_output',col_header,'Results','B1');     %Write column header
end
end

