function Plot_ReactionTime_acc_frein(timecode,acc,acc_filt,frein,Essai,ReactionTime_acc,Reactiontime_frein,nFig,FILE_var, REP_fig,SCENARIO)
    
    [old,var_name,~]=fileparts(FILE_var);
    [old,NOM_SUJET,~]=fileparts(old);
    [~,SYSTEME,~]=fileparts(old);
    
    if ~ exist([REP_fig filesep SYSTEME filesep NOM_SUJET],'dir')
    mkdir([REP_fig filesep SYSTEME filesep NOM_SUJET])
    end
    fig_path = [REP_fig filesep SYSTEME filesep NOM_SUJET];
    
    N_essai = size(Essai,1);
    N_subplot = ceil( N_essai/nFig);
    i_plot= 1;
    i_fig=1;
    side_time = 0.2; %s
    n_col_plot =2;
    
    acc= acc*100/255;
    acc_filt = acc_filt*100/255;
    frein = frein*100/255;

    h1 = figure;

    for i_essai=1:1:N_essai

        if i_essai>(i_fig*N_subplot)
            %pause
            screen_size = get(0, 'ScreenSize');
            set(h1, 'Position', [0 0 screen_size(3) screen_size(4) ] );
            print(h1,[fig_path filesep NOM_SUJET '_' SCENARIO '_1.jpeg' ],'-djpeg','-r800')
            close(h1)
            h1 = figure;
            i_plot=1;
            i_fig=i_fig+1;
        end

        time_mask = ((timecode > Essai(i_essai,1) - side_time) &  (timecode < Essai(i_essai,2) + side_time));
        subplot(ceil(N_subplot/n_col_plot),n_col_plot,i_plot), 
        hold on
        if all(frein(time_mask)==0)
            plot(timecode(time_mask),acc(time_mask),'Color',[0 0 1]);
            AX1 = gca;
            set(AX1,'Fontsize',7)
            xlim([min(timecode(time_mask)) max(timecode(time_mask))])
            ylim([0 100])
            set(gca,'YTick',0:20:100)
        else
            [AX,H1,H2] = plotyy(timecode(time_mask),acc(time_mask),timecode(time_mask),frein(time_mask));
            xlim(AX(1),[ min(timecode(time_mask)) max(timecode(time_mask))])
            xlim(AX(2),[ min(timecode(time_mask)) max(timecode(time_mask))])
            ylim(AX(1),[0 100])
            ylim(AX(2),[0 100])
            
            set(AX(1),'YTick',0:20:100)
            set(AX(2),'YTick',0:20:100)
            
            set(H1,'Color',[0 0 1])
            set(H2,'Color',[0 121/255 8/255])
            set(AX(1),'Fontsize',7)
            set(AX(2),'Fontsize',7)
        end
        plot(timecode(time_mask),acc_filt(time_mask),'Color',[23/255 214/255 235/255])
        AX3 = gca;
        set(AX3,'Fontsize',7)
        xlim(AX3,[ min(timecode(time_mask)) max(timecode(time_mask))])
        ylim(AX3,[0 100])
        set(AX3,'YTick',0:20:100)
        hold off
        title(['Essai ' num2str(i_essai) ' - (type ' num2str(Essai(i_essai,3)) ')'])
        
        %ylim([-3 max(acc(time_mask))+0.1*max(acc(time_mask))])
        vline(Essai(i_essai,1),'k--','');
        vline(Essai(i_essai,2),'k--','');
        h_acc = vline(ReactionTime_acc(i_essai,2),'r','TR-acc');
        h_frein = vline(Reactiontime_frein(i_essai,2),'g','TR-frein');
        %vline(Reactiontime_frein(i_essai,5),'g','relachement frein');

        i_plot=i_plot+1;

    end
    screen_size = get(0,'ScreenSize');
    set(h1, 'Position', [0 0 screen_size(3) screen_size(4) ] );
    print(h1,[fig_path filesep NOM_SUJET '_' SCENARIO '_' num2str(i_fig) '.jpeg' ],'-djpeg','-r800')
    close(h1)

end