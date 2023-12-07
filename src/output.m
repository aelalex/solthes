function output(f,A_m,Vst_th,Vec,x,tstart,tend,TST,TA,DC,DL,QU,N_A,QL)
%   Export quantities of interest in visual and text form.
%   The data are plotted after user input since this is an educational
%   software and the user may want to check a single plot or plot each
%   value at a certain time. 

%Do you want to plot?
prompt='Plot some quantity of interest or end the program? plot or end:  ';
answer = input(prompt,'s');
while not (isequal(answer,'plot') || isequal(answer,'end'))
    prompt='Please enter plot or end:  ';
    answer = input(prompt,'s');
end
while (isequal(answer,'plot'))
    %what to plot?
    prompt='Plot the fraction of load (f) or the transient quantities (q)?  f or q:  ';
    answer = input(prompt,'s');
    while not (isequal(answer,'f') || isequal(answer,'q'))
        prompt='Please enter f or q:  ';
        answer = input(prompt,'s');
    end
    if answer=='f'
        %If f is a single value, then don't plot results.
        if (size(f)>1)
            figure(1)
            plot(Vst_th,f(:,:),'LineWidth',2)
            grid
            title('Fraction of load (f)','FontSize',24,'FontWeight','bold')
            xlabel('V_{st} [m^{3}]','FontSize',20,'FontWeight','bold')
            set(gca,'FontSize',15)
            ylabel('f','FontSize',24,'FontWeight','bold')
            legendCell = cellstr(num2str(A_m'));
            %add to each cell element the unit
            legend_with_unit=strcat(legendCell,' [m^2]');
            legend(legend_with_unit,'Location','southeast','FontSize',20)
        else
            disp('Not enough values of f to make a plot!')
        end
    else
        %Which quantity to plot?
        prompt='Which quantity do you want to plot? Storage temperature: TST, Ambient temperature: TA, Collector switch: DC, Load switch: DL, Useful energy gain: QU, efficiency: N_A, thermal load: QL ';
        answer = input(prompt,'s');
        while not (isequal(answer,'TST') || isequal(answer,'TA')|| isequal(answer,'DC') || isequal(answer,'DL') || isequal(answer,'QU') || isequal(answer,'N_A') || isequal(answer,'QL'))
            prompt='Please enter TST or TA or DC or DL or QU or N_A or QL:  ';
            answer = input(prompt,'s');
        end
        if isequal(answer,'TST') 
            figure ('Name','Tstorage [K]')
            plot(x,TST);
            axis([tstart, tend, 300, 340]);
            xlabel('t (hours)','FontSize',20,'FontWeight','bold');
            set(gca,'FontSize',15)
            ylabel('Tst(K)','FontSize',20,'FontWeight','bold');
            grid('on');
        elseif  isequal(answer,'TA')
            figure ('Name','Ta [K]')
            plot(x,TA);
            axis([tstart, tend, min(TA), max(TA)]);
            xlabel('t (hours)','FontSize',20,'FontWeight','bold');
            set(gca,'FontSize',15)
            ylabel('Ta(K)','FontSize',24,'FontWeight','bold');
            grid('on');
        elseif isequal(answer,'DC')
            figure ('Name','Switch collector: dc')
            plot(x,DC);
            axis([tstart, tend, 0, 1]);
            xlabel('t (hours)','FontSize',20,'FontWeight','bold');
            ylabel('dc','FontSize',24,'FontWeight','bold');
            set(gca,'FontSize',15)
            grid('on');       
        elseif isequal(answer,'DL')
            figure ('Name','Switch load: dl')
            plot(x,DL);
            axis([tstart, tend, 0, 1]);
            xlabel('t (hours)','FontSize',20,'FontWeight','bold');
            ylabel('dl','FontSize',24,'FontWeight','bold');
            set(gca,'FontSize',15)
            grid('on');      
        elseif isequal(answer,'QU')
            figure ('Name','Quseful(kW)')
            plot(x,QU);
            axis([tstart, tend, 0, max(QU)]);
            xlabel('t (hours)','FontSize',20,'FontWeight','bold');
            ylabel('Qu(kW)','FontSize',24,'FontWeight','bold');
            set(gca,'FontSize',15)
            grid('on');
        elseif isequal(answer,'N_A')
            figure ('Name','Efficiency(%)')
            plot(x,N_A);
            axis([tstart, tend, 0, 100]);
            xlabel('t (hours)','FontSize',20,'FontWeight','bold');
            ylabel('n(%)','FontSize',24,'FontWeight','bold');
            set(gca,'FontSize',15)
            grid('on');
        elseif isequal(answer,'QL')
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
    answer = input(prompt,'s');
    while  not (isequal(answer,'plot') || isequal(answer,'end'))
        prompt='Please enter plot or end:  ';
        answer = input(prompt,'s');
    end
end

%Ask if the output file is needed in xls form
prompt = 'Do you want to save the output file? Y or N:  ';
answer=check_response(prompt);
if answer=='Y'
    disp('Writing file to xls format may take some time depending on the simulation hours')
    col_header={'Hour','Tfin','Tfout','Tst','Tlin','Tlout','Ta','dc','dl','Qs','Qu','Ql','Qdhw','Qst','n'};     %Row cell array (for column labels)
    xlswrite ('../SOLTHES_output',Vec,'Results','B2');
    xlswrite('../SOLTHES_output',col_header,'Results','B1');     %Write column header
end
end

