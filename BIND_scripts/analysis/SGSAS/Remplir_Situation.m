function Remplir_Situation(chemin_trip)

% on ouvre un fichier trip
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(chemin_trip,0.04,false);

metas=trip.getMetaInformations;
Situation_List = metas.getSituationsNamesList;

for i_situation=1:length(Situation_List)
    
    Record_Situation = trip.getAllSituationOccurences(Situation_List{i_situation});
    Timecodes = Record_Situation.buildCellArrayWithVariables({'startTimecode' 'endTimecode'});
    
    if strcmp(Situation_List(i_situation), 'stimulation_all') && size(Timecodes,2) >= 17
        Timecodes = Timecodes(:,1:16);
    end
    
    % Initialisation des variables
    Duree = zeros(1,size(Timecodes,2));
    vitesse_moy = zeros(1,size(Timecodes,2));
    vitesse_std = zeros(1,size(Timecodes,2));
    pedal_acc = zeros(1,size(Timecodes,2));
    pedal_frein = zeros(1,size(Timecodes,2));
    pedal_embr = zeros(1,size(Timecodes,2));
    
    pedal_acc_duree = zeros(1,size(Timecodes,2));
    pedal_frein_duree = zeros(1,size(Timecodes,2));
    pedal_embr_duree = zeros(1,size(Timecodes,2));
    
    PositionVoie_std = zeros(1,size(Timecodes,2));
    AngleVolant_std = zeros(1,size(Timecodes,2));
    
    sens = cell(1,size(Timecodes,2));
    route = zeros(1,size(Timecodes,2));
    pk = zeros(1,size(Timecodes,2));
    
    %% Calcul des indicateurs par section
    for i_section=1:1:size(Timecodes,2)
        
        record_vitesse = trip.getDataOccurencesInTimeInterval('vitesse',Timecodes{1,i_section},Timecodes{2,i_section});
        duree = (Timecodes{2,i_section}-Timecodes{1,i_section});
        Duree(i_section) = duree;
        
        vitesse_moy(i_section) = mean(3.6 * cell2mat(record_vitesse.getVariableValues('vitesse')));
        vitesse_std(i_section) = std(3.6 * cell2mat(record_vitesse.getVariableValues('vitesse')));
        
        try
            mat_acc = (100/255) * cell2mat(record_vitesse.getVariableValues('accelerateur'));
        catch
            mat_acc = (100/255) * cell2mat(record_vitesse.getVariableValues('accélérateur'));
        end
        
        mat_frein = (100/255)* cell2mat(record_vitesse.getVariableValues('frein'));
        mat_embr = (100/255) * cell2mat(record_vitesse.getVariableValues('embrayage'));
        
        pedal_acc(i_section) = mean( mat_acc);
        pedal_frein(i_section) = mean( mat_frein);
        pedal_embr(i_section) = mean(mat_embr);
        
        %% Calcul et mise en forme des appuis frein
        seuil_appui_pedal = 5 ; % seuil de l'appui pédale fixé à 10 à de l'enfeoncement
        pedal_acc_duree(i_section) =  100*mean(mat_acc > seuil_appui_pedal);
        pedal_frein_duree(i_section) =  100*mean(mat_frein > seuil_appui_pedal);
        pedal_embr_duree(i_section) =  100*mean(mat_embr > seuil_appui_pedal);
        
        record_localisation = trip.getDataOccurencesInTimeInterval('localisation',Timecodes{1,i_section},Timecodes{2,i_section});
        route_temp = str2double(record_localisation.getVariableValues('route'));
        pk_temp =cell2mat(record_localisation.getVariableValues('pk'));
        route(i_section)=route_temp(1);
        pk(i_section)=pk_temp(1);
        
        record_trajectoire = trip.getDataOccurencesInTimeInterval('trajectoire',Timecodes{1,i_section},Timecodes{2,i_section});
        
        %timecode_trajectoire = cell2mat(record_trajectoire.getVariableValues('timecode'));
        PositionVoie = cell2mat (record_trajectoire.getVariableValues('voie'));
        AngleVolant = cell2mat (record_trajectoire.getVariableValues('angleVolant')); % 7500 unité du compteur incrématal par tour
        AngleVolant_deg = 360/7500*AngleVolant;
        
        %% Filtrage de la position sur la voie
        %PositionVoie = filtrage_postionVoie(timecode_trajectoire,PositionVoie,route_temp);
        
        PositionVoie_std(i_section) = std(PositionVoie);
        AngleVolant_std(i_section) = std(AngleVolant_deg);
        
        %plotyy(timecode_trajectoire,AngleVolant,timecode_trajectoire,AngleVolant_deg)
        
        record_sens = trip.getDataVariableOccurencesInTimeInterval('trajectoire','sens',Timecodes{1,i_section},Timecodes{2,i_section});
        sens_temp = record_sens.getVariableValues('sens');
        sens{i_section} =  sens_temp{1};
        
        
        
    end
    
    % Variables à remplir
    %     Names = {'Nom';'Duree';'Vitesse_moy';'Vitesse_moy';'%AppuiAcc_moy';'%AppuiFrein_moy';'%AppuiEmbr_moy';'AppuiAcc_%duree';'AppuiFrein_%duree';'AppuiEmbr_%duree'; ...
    %                 'PositionVoie_std';'AngleVolant_std';'pk';'route';'sens'};
    
    if ~isempty(Timecodes)
        trip.setBatchOfTimeSituationVariableTriplets(Situation_List{i_situation},'Duree',[Timecodes ; num2cell(Duree)])
        
        trip.setBatchOfTimeSituationVariableTriplets(Situation_List{i_situation},'Vitesse_moy',[Timecodes ; num2cell(vitesse_moy)])
        trip.setBatchOfTimeSituationVariableTriplets(Situation_List{i_situation},'Vitesse_std',[Timecodes ; num2cell(vitesse_std)])
        
        trip.setBatchOfTimeSituationVariableTriplets(Situation_List{i_situation}, '%AppuiAcc_moy', [Timecodes ; num2cell(pedal_acc)])
        trip.setBatchOfTimeSituationVariableTriplets(Situation_List{i_situation}, '%AppuiFrein_moy',[Timecodes ; num2cell(pedal_frein)])
        trip.setBatchOfTimeSituationVariableTriplets(Situation_List{i_situation}, '%AppuiEmbr_moy',[Timecodes ; num2cell(pedal_embr)])
        
        trip.setBatchOfTimeSituationVariableTriplets(Situation_List{i_situation}, 'AppuiAcc_%duree', [Timecodes ; num2cell(pedal_acc_duree)])
        trip.setBatchOfTimeSituationVariableTriplets(Situation_List{i_situation}, 'AppuiFrein_%duree',[Timecodes ; num2cell(pedal_frein_duree)])
        trip.setBatchOfTimeSituationVariableTriplets(Situation_List{i_situation}, 'AppuiEmbr_%duree',[Timecodes ; num2cell(pedal_embr_duree)])
        
        
        trip.setBatchOfTimeSituationVariableTriplets(Situation_List{i_situation}, 'PositionVoie_std',[Timecodes ; num2cell(PositionVoie_std)])
        trip.setBatchOfTimeSituationVariableTriplets(Situation_List{i_situation}, 'AngleVolant_std',[Timecodes ; num2cell(AngleVolant_std)])
        
        trip.setBatchOfTimeSituationVariableTriplets(Situation_List{i_situation}, 'sens',[Timecodes ; sens])
        trip.setBatchOfTimeSituationVariableTriplets(Situation_List{i_situation}, 'route',[Timecodes ; num2cell(route)])
        trip.setBatchOfTimeSituationVariableTriplets(Situation_List{i_situation}, 'pk',[Timecodes ; num2cell(pk)])
    end
    
    
    Duree_Stim_total = sum(Duree);
    trip.setAttribute('Duree_stimulation_totale',num2str(Duree_Stim_total));
    
end

% On ferme le trip (penser à bien fermer le trip systématiquement !!! pour éviter des messages d'erreur après)
delete(trip);

end