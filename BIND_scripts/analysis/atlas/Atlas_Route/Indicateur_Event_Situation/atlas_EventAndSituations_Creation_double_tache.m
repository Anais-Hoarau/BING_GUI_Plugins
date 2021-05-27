
function out = atlas_EventAndSituations_Creation_double_tache(trip,mat_file_path)

out='';

    %% Mise en forme de TopCons : import dans le trip et sauvegarde structure

MEF_TopCons(trip,mat_file_path)

    %%  creation du record
    
clap_start =str2double( trip.getAttribute('mopad_top_clap_start'));
participant_name = trip.getAttribute('nomSujet');

record = trip.getAllDataOccurences('Mopad_Synchrovideo');
timecode = cell2mat(record.getVariableValues('timecode'));
TopConsigne = cell2mat(record.getVariableValues('TopConsigne'));

    %%  initialisation des arrays

    %%Creations des timecodes de débuts et de fins de situations  
valeur_situation=2;
Top_situation=extract_situation(timecode,TopConsigne,valeur_situation,5);
timecode_situation = extrat_debut_fin_situation_timecode(timecode,Top_situation,valeur_situation);

figure 
plot(timecode, TopConsigne , timecode , Top_situation)
legend('TopConsigne','TopSituation')
title(['Topconsigne & TopSituation_' participant_name])
hgsave(['Topconsigne & TopSituation_' participant_name])
close all

    %%Creations des timecodes de débuts et de fins de situations et creation des timecodes pour les deux type d'events
timecode_8 = extrat_debut_fin_situation_timecode(timecode,TopConsigne,8);
timecode_eventA=timecode_8(:,1);

timecode_10 = extrat_debut_fin_situation_timecode(timecode,TopConsigne,10);
timecode_eventB=timecode_10(:,1);

    %% Remplissage du trip : Creation des situations et des events
    
%Situation : test si la situation 'Double Tache' existe déjà, si ce n'est pas le cas, cette dernière est créée
    if ~(trip.getMetaInformations().existSituation('double tache')) 
    % create a metaSituation
       newMetaSituation = fr.lescot.bind.data.MetaSituation;
       newMetaSituation.setName('double tache');
       
       Name_List ={'Nom','Vitesse_moy','Vitesse_stddev','AngleVolant_moy','AngleVolant_std','PositionVoie_moy','PositionVoie_stddev','N_LineChange','N_LineChange_D','N_LineChange_G','NbreEvent1','NbreEvent2','Jerk','SteeringWheelReversalRate'};
       Type_List = {'TEXT','REAL','REAL','REAL','REAL','REAL','REAL','REAL','REAL','REAL','REAL','REAL','REAL','REAL','REAL'};
    % create metaSituationVariables
        
       var = cell(length(Name_List));
       for i=1:1:length(Name_List)
          var{i} = fr.lescot.bind.data.MetaSituationVariable();
          var{i}.setName(Name_List{i});
          var{i}.setType(Type_List{i});
       end

    % set the metaSituationVariables in the metaSituation
       newMetaSituation.setVariables(var);
    % add the metaSituation to the trip
  
        trip.addSituation(newMetaSituation);
        trip.setIsBaseSituation('double tache',false)   
    end
    clear var
    
%Event 1:
    if ~(trip.getMetaInformations().existEvent('Topage_A')) 
        newMetaEvent = fr.lescot.bind.data.MetaEvent;
        newMetaEvent.setName('Topage_A');
      
        var{1} =fr.lescot.bind.data.MetaEventVariable();
        var{1}.setName('Nom');
        var{1}.setType('TEXT');
        
        var{2} =fr.lescot.bind.data.MetaEventVariable();
        var{2}.setName('Num_Section');
        var{2}.setType('TEXT');
        
    % set the metaSituationVariables in the metaSituation
        newMetaEvent.setVariables(var);
    % add the metaSituation to the trip
        trip.addEvent(newMetaEvent);
        trip.setIsBaseEvent('Topage_A',false) 
    end
    clear var
%Event 2:
    
    if ~(trip.getMetaInformations().existEvent('Topage_B')) 
        newMetaEvent = fr.lescot.bind.data.MetaEvent;
        newMetaEvent.setName('Topage_B');
      
        var{1} =fr.lescot.bind.data.MetaEventVariable();
        var{1}.setName('Nom');
        var{1}.setType('TEXT');
        
        var{2} =fr.lescot.bind.data.MetaEventVariable();
        var{2}.setName('Num_Section');
        var{2}.setType('TEXT');
        
    % set the metaSituationVariables in the metaSituation
        newMetaEvent.setVariables(var);
    % add the metaSituation to the trip
        trip.addEvent(newMetaEvent);
        trip.setIsBaseEvent('Topage_B',false) 
    end
    clear var
    
    
    %%Remplissage Nom situations et Nom event
    if ~isempty(timecode_situation)
        Variables_Triplets=cell(3,size(timecode_situation,1));
        for i=1:1:size(timecode_situation,1)
        Variables_Triplets{1,i}=timecode_situation(i,1);
        Variables_Triplets{2,i}=timecode_situation(i,2);
        Variables_Triplets{3,i}=['Section ' num2str(i)];
        end
    trip.setBatchOfTimeSituationVariableTriplets('double tache','Nom',Variables_Triplets)
    end
    
    
    if ~isempty(timecode_eventA)
        Variables_Pairs_A_1=cell(2,length(timecode_eventA));
        Variables_Pairs_A_2=cell(2,length(timecode_eventA));
        
        for i=1:1:length(timecode_eventA)
        Variables_Pairs_A_1{1,i}=timecode_eventA(i);
        Variables_Pairs_A_1{2,i}=['marquage ' num2str(i)];
        
        num_sec_A = find(timecode_eventA(i)>timecode_situation(:,1) & timecode_eventA(i)<timecode_situation(:,2));
        Variables_Pairs_A_2{1,i}=timecode_eventA(i);
        Variables_Pairs_A_2{2,i}=['Section ' num2str(num_sec_A)];     
        
        end
        trip.setBatchOfTimeEventVariablePairs('Topage_A','Nom',Variables_Pairs_A_1)
        trip.setBatchOfTimeEventVariablePairs('Topage_A','Num_Section',Variables_Pairs_A_2)
    end
    
    if ~isempty(timecode_eventB)
        Variables_Pairs_B_1=cell(2,length(timecode_eventB));
        Variables_Pairs_B_2=cell(2,length(timecode_eventB));
        
        for i=1:1:length(timecode_eventB)
        Variables_Pairs_B_1{1,i}=timecode_eventB(i);
        Variables_Pairs_B_1{2,i}=['marquage ' num2str(i)];
        
        num_sec_B = find(timecode_eventB(i)>timecode_situation(:,1) & timecode_eventB(i)<timecode_situation(:,2));
        Variables_Pairs_B_2{1,i}=timecode_eventB(i);
        Variables_Pairs_B_2{2,i}=['Section ' num2str(num_sec_B)];
        
        end
        trip.setBatchOfTimeEventVariablePairs('Topage_B','Nom',Variables_Pairs_B_1)
        trip.setBatchOfTimeEventVariablePairs('Topage_B','Num_Section',Variables_Pairs_B_2)
    end

end