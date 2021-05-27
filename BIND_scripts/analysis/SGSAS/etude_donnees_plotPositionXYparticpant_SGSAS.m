close all
clear all
%%
CHERCHEUR ='GERMAN';

trips_folder= ['D:\LESCOT\PROJETS\SGSAS\DATA_' CHERCHEUR '\'];
fig_folder = ['D:\LESCOT\PROJETS\SGSAS\Plots\' CHERCHEUR '\PostitionXY_paticipant'];

trips_list = dirrec(trips_folder, '.trip');

X_all = cell(21,1);
Y_all = cell(21,1);

X_curve = cell(21,1);
Y_curve = cell(21,1);

X_neutral = cell(21,1);
Y_neutral = cell(21,1);


for i_trip=1:1:length(trips_list)
    
    trip_path = trips_list{i_trip}
    
    [file_path,participant,ext]=fileparts(trip_path);
    
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_path, 0.04, true);
    
    
    i_particpant = regexp(participant,'[0-9]*','match');
    participant_number{i_trip} = ['participant' i_particpant{1}];
    i_particpant = str2double(i_particpant{1});
    
    type_participant= regexp(participant,'[a-z]*','match');
    type_participant = (type_participant{1});
    participant_name{i_trip} = participant;
    
    record_trajectoire = trip.getAllDataOccurences('trajectoire');
    n_situation_stim =0;
    
    
    
    switch type_participant
        case 'all'
            X_all{i_particpant,1}= cell2mat(record_trajectoire.getVariableValues('X'))/1e6;
            Y_all{i_particpant,1}= cell2mat(record_trajectoire.getVariableValues('Y'))/1e6;
            situation_stimulation = trip.getAllSituationOccurences('Stimulation_ALL');
            n_situation_stim =1;
            
            startTC = cell2mat( situation_stimulation.getVariableValues('startTimecode'));
            endTC = cell2mat( situation_stimulation.getVariableValues('endTimecode'));
            
        case 'curve'
            X_curve{i_particpant,1}= cell2mat(record_trajectoire.getVariableValues('X'))/1e6;
            Y_curve{i_particpant,1}= cell2mat(record_trajectoire.getVariableValues('Y'))/1e6;
            situation_stimulation = trip.getAllSituationOccurences('Stimulation_CURVE');
            n_situation_stim =1;
            
            startTC = cell2mat( situation_stimulation.getVariableValues('startTimecode'));
            endTC = cell2mat( situation_stimulation.getVariableValues('endTimecode'));
            
        case 'neutral'
            X_neutral{i_particpant}= cell2mat(record_trajectoire.getVariableValues('X'))/1e6;
            Y_neutral{i_particpant,1}= cell2mat(record_trajectoire.getVariableValues('Y'))/1e6;
            situation_stimulation_CURVE = trip.getAllSituationOccurences('Stimulation_CURVE');
            situation_stimulation_ALL = trip.getAllSituationOccurences('Stimulation_ALL');
            n_situation_stim =2;
            
            startTC_CURVE = cell2mat( situation_stimulation_CURVE.getVariableValues('startTimecode'));
            endTC_CURVE = cell2mat( situation_stimulation_CURVE.getVariableValues('endTimecode'));
            
            startTC_ALL = cell2mat( situation_stimulation_ALL.getVariableValues('startTimecode'));
            endTC_ALL = cell2mat( situation_stimulation_ALL.getVariableValues('endTimecode'));
    end
    
    if n_situation_stim ==1
        
        for i_stim=1:1:length(startTC)
            record_trajectoire=trip.getDataOccurencesInTimeInterval('trajectoire',startTC(i_stim),endTC(i_stim));
            switch type_participant
                case 'all'
                    Xstim_all{i_particpant,i_stim}= cell2mat(record_trajectoire.getVariableValues('X'))/1e6;
                    Ystim_all{i_particpant,i_stim}= cell2mat(record_trajectoire.getVariableValues('Y'))/1e6;
                case 'curve'
                    Xstim_curve{i_particpant,i_stim}= cell2mat(record_trajectoire.getVariableValues('X'))/1e6;
                    Ystim_curve{i_particpant,i_stim}= cell2mat(record_trajectoire.getVariableValues('Y'))/1e6;
            end
        end
        
    elseif  n_situation_stim ==2
        for i_stim=1:1:length(startTC_CURVE)
            record_trajectoire_CURVE=trip.getDataOccurencesInTimeInterval('trajectoire',startTC_CURVE(i_stim),endTC_CURVE(i_stim));
            
            Xstim_neutral_curve{i_particpant,i_stim}= cell2mat(record_trajectoire_CURVE.getVariableValues('X'))/1e6;
            Ystim_neutral_curve{i_particpant,i_stim}= cell2mat(record_trajectoire_CURVE.getVariableValues('Y'))/1e6;
        end
        
        for i_stim=1:1:length(startTC_ALL)
            record_trajectoire_ALL=trip.getDataOccurencesInTimeInterval('trajectoire',startTC_ALL(i_stim),endTC_ALL(i_stim));
            Xstim_neutral_all{i_particpant,i_stim}= cell2mat(record_trajectoire_ALL.getVariableValues('X'))/1e6;
            Ystim_neutral_all{i_particpant,i_stim}= cell2mat(record_trajectoire_ALL.getVariableValues('Y'))/1e6;
        end
    else
        disp('there is a ball !!')
    end
    
    clear record_trajectoire record_trajectoire_ALL record_trajectoire_CURVE startTC startTC_CURVE startTC_ALL endTC endTC_CURVE endTC_ALL
    
    delete(trip)
    
end

%%
for ii=1:1:size(X_curve,1)
    
    h1=figure; % comparaison CURVE/NEUTRAL
    for jj=1:1:size(Xstim_curve(ii,:),2)
        if ~(isempty(Xstim_curve{ii,jj}) || isempty(Xstim_neutral_curve{ii,jj}))
        subplot(6,3,jj), plot(Xstim_curve{ii,jj},Ystim_curve{ii,jj}, Xstim_neutral_curve{ii,jj},Ystim_neutral_curve{ii,jj});
        xlim([min(min(Xstim_curve{ii,jj}),min(Xstim_neutral_curve{ii,jj})),max(max(Xstim_curve{ii,jj}),max(Xstim_neutral_curve{ii,jj}))])
        ylim(([min(min(Ystim_curve{ii,jj}),min(Ystim_neutral_curve{ii,jj})),max(max(Ystim_curve{ii,jj}),max(Ystim_neutral_curve{ii,jj}))]))
        title(['\fontsize{7}' 'Participant ' num2str(ii) ' - CURVE/NEUTRAL -' num2str(jj)])
        set(gca,'Fontsize',6)
        if jj==1
            legend('curve','neutral')
        end
        end
    end
    
    screen_size = get(0, 'ScreenSize');
    set(h1, 'Position', [0 0 screen_size(3) screen_size(4) ] );
    
    %hgsave(h1, [fig_folder '\' participant_name{ii} '_CURVEvsNEUTRAL.fig'])
    print(h1,[fig_folder '\' 'Participant ' num2str(ii) '_CURVEvsNEUTRAL'],'-djpeg','-r800')
    
    
    h2=figure; % comparaison ALL/NEUTRAL
    for jj=1:1:size(Xstim_all(ii,:),2)
        if ~(isempty(Xstim_all{ii,jj}) || isempty(Xstim_neutral_all{ii,jj}))
        subplot(6,3,jj), plot(Xstim_all{ii,jj},Ystim_all{ii,jj}, Xstim_neutral_all{ii,jj},Ystim_neutral_all{ii,jj});        
        xlim([min(min(Xstim_all{ii,jj}),min(Xstim_neutral_all{ii,jj})),max(max(Xstim_all{ii,jj}),max(Xstim_neutral_all{ii,jj}))])
        ylim(([min(min(Ystim_all{ii,jj}),min(Ystim_neutral_all{ii,jj})),max(max(Ystim_all{ii,jj}),max(Ystim_neutral_all{ii,jj}))]))
        title(['\fontsize{7}' 'Participant' num2str(ii) ' - ALL/NEUTRAL -' num2str(jj)])
        set(gca,'Fontsize',6)
        if jj==1
            legend('all','neutral')
        end
        end
    end
    
    screen_size = get(0, 'ScreenSize');
    set(h2, 'Position', [0 0 screen_size(3) screen_size(4) ] );
    
    %hgsave(h2, [fig_folder '\' participant_name{ii} '_ALLvsNEUTRAL.fig'])
    print(h2,[fig_folder '\Participant' num2str(ii) '_ALLvsNEUTRAL'],'-djpeg','-r800')
    
    
    
    h3=figure;
    plot(X_all{ii,1},Y_all{ii,1}, X_curve{ii,1},Y_curve{ii,1},X_neutral{ii,1},Y_neutral{ii,1});
    title(['Participant ' num2str(ii)])
    legend('all','curve','neutral')
    set(gca,'Fontsize',7)
    
    screen_size = get(0, 'ScreenSize');
    set(h3, 'Position', [0 0 screen_size(3) screen_size(4) ] );
    
    hgsave(h3, [fig_folder '\Participant' num2str(ii)  '_ParcoursXY'])
    print(h3,[fig_folder '\Parcours_Participant' num2str(ii)],'-djpeg','-r800')
    
    close all
end
