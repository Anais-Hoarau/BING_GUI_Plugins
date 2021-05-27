function out = atlas_EventAndSituations_Creation_MindWandering(trip,mat_file)
out='';

%%  Creation de la table d'event
if ~(trip.getMetaInformations().existEvent('MindWandering'))
    newMetaEvent = fr.lescot.bind.data.MetaEvent;
    newMetaEvent.setName('MindWandering');
    
    var{1} =fr.lescot.bind.data.MetaEventVariable();
    var{1}.setName('Nom');
    var{1}.setType('TEXT');
    
    % set the metaSituationVariables in the metaSituation
    newMetaEvent.setVariables(var);
    % add the metaSituation to the trip
    trip.addEvent(newMetaEvent);
    trip.setIsBaseEvent('MindWandering',false)
end
clear var

%%  Creation de la table de Situation : MindWandering_avant
if ~(trip.getMetaInformations().existSituation('MindWandering_avant'))
    newMetaSituation = fr.lescot.bind.data.MetaSituation;
    newMetaSituation.setName('MindWandering_avant');
    
    Name_List ={'Nom','Vitesse_moy','Vitesse_stddev','AngleVolant_moy','AngleVolant_std','PositionVoie_moy','PositionVoie_stddev','N_LineChange','N_LineChange_D','N_LineChange_G'};
    Type_List = {'TEXT','REAL','REAL','REAL','REAL','REAL','REAL','REAL','REAL','REAL'};
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
    trip.setIsBaseSituation('MindWandering_avant',false)
end
clear var

%%  Creation de la table de Situation : MindWandering_apres
if ~(trip.getMetaInformations().existSituation('MindWandering_apres'))
    newMetaSituation = fr.lescot.bind.data.MetaSituation;
    newMetaSituation.setName('MindWandering_apres');
    
    Name_List ={'Nom','Vitesse_moy','Vitesse_stddev','AngleVolant_moy','AngleVolant_std','PositionVoie_moy','PositionVoie_stddev','N_LineChange','N_LineChange_D','N_LineChange_G'};
    Type_List = {'TEXT','REAL','REAL','REAL','REAL','REAL','REAL','REAL','REAL','REAL'};
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
    trip.setIsBaseSituation('MindWandering_apres',false)
end
clear var


%% Processing MindWandering data and extracting event 
metas = trip.getMetaInformations;
timecode_eventMindWander =[];
if metas.existSituation('double tache') && metas.existDataVariable('Mopad_SensorsMeasures','ContactMindWandering')   
    record_situation = trip.getAllSituationOccurences('double tache');
    Start_End_timecode = cell2mat(record_situation.buildCellArrayWithVariables({'startTimecode','endTimecode'}));
       
    for i_situation=1:1:size(Start_End_timecode,2)
        record = trip.getDataOccurencesInTimeInterval('Mopad_SensorsMeasures',Start_End_timecode(1,i_situation),Start_End_timecode(2,i_situation));
        
        timecode = cell2mat(record.getVariableValues('timecode'));
        MindWandering = abs(cell2mat(record.getVariableValues('ContactMindWandering')));
        

        if any(MindWandering>1)
        %Filtrage MindWandering    
        MindWandering(MindWandering>1) = 10;
        
        timecode_10 = extrat_debut_fin_situation_timecode(timecode,MindWandering,10);
        timecode_eventMindWander=[timecode_eventMindWander ; timecode_10(:,1)];
        end
    end 
elseif metas.existSituation('double tache')
    load(mat_file)
    participant=fieldnames(atlas);
    participant = participant{1};
    if isfield(atlas.(participant).MP150.data, 'DeclareMindWandering')
        timecode=atlas.(participant).MP150.data.time_sync.values;
        MindWandering = atlas.(participant).MP150.data.DeclareMindWandering.values;      
        if any(MindWandering>1)
            MindWandering(MindWandering>1) = 10;
            timecode_10 = extrat_debut_fin_situation_timecode(timecode,MindWandering,10);
            timecode_eventMindWander=[timecode_eventMindWander ; timecode_10(:,1)];
        end
    end
end

%% Remplissage Event MindWandering
if ~isempty(timecode_eventMindWander)
    Variables_Pairs=cell(2,length(timecode_eventMindWander));
    for i=1:1:length(timecode_eventMindWander)
        Variables_Pairs{1,i}=timecode_eventMindWander(i);
        Variables_Pairs{2,i}=['Declaration ' num2str(i)];
    end
    trip.setBatchOfTimeEventVariablePairs('MindWandering','Nom',Variables_Pairs)
end

%%Remplissage Nom situation
if ~isempty(timecode_eventMindWander)
    Variables_Triplets_avant=cell(3,length(timecode_eventMindWander));
    Variables_Triplets_apres=cell(3,length(timecode_eventMindWander));
    
    
    
    for i=1:1:length(timecode_eventMindWander)
        record = trip.getDataOccurenceNearTime('Mopad_SensorsMeasures',timecode_eventMindWander(i)-13); %13 secondes avant la déclaration du MW
        Variables_Triplets_avant{1,i} = cell2mat(record.getVariableValues('timecode'));
        
        record = trip.getDataOccurenceNearTime('Mopad_SensorsMeasures',timecode_eventMindWander(i)-4); % 4 secondes avant la déclaration du MW
        Variables_Triplets_avant{2,i} = cell2mat(record.getVariableValues('timecode'));
        
        Variables_Triplets_avant{3,i} = ['Pre_MW ' num2str(i)];
    end
    
    for i=1:1:length(timecode_eventMindWander)
        record = trip.getDataOccurenceNearTime('Mopad_SensorsMeasures',timecode_eventMindWander(i)+20); %20 secondes apres la déclaration du MW
        Variables_Triplets_apres{1,i}= cell2mat(record.getVariableValues('timecode'));
        
        record = trip.getDataOccurenceNearTime('Mopad_SensorsMeasures',timecode_eventMindWander(i)+29); %20 secondes apres la déclaration du MW
        Variables_Triplets_apres{2,i}= cell2mat(record.getVariableValues('timecode'));
        
        Variables_Triplets_apres{3,i}=['Post_MW ' num2str(i)];
    end
       
    trip.setBatchOfTimeSituationVariableTriplets('MindWandering_avant','Nom',Variables_Triplets_avant)
    trip.setBatchOfTimeSituationVariableTriplets('MindWandering_apres','Nom',Variables_Triplets_apres)
end




end