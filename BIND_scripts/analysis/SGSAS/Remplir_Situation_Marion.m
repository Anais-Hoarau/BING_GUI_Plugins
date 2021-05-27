function Remplir_Situation_Marion(chemin_trip)

% on ouvre un fichier trip
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(chemin_trip,0.04,false);

metas=trip.getMetaInformations;
Situation_List = metas.getSituationsNamesList;

for i_situation=1:1:length(Situation_List)
    
Record_Situation = trip.getAllSituationOccurences(Situation_List{i_situation});
Timecodes = Record_Situation.buildCellArrayWithVariables({'startTimecode' 'endTimecode'});

% Initialisation des variables
vitesse_moy = zeros(1,size(Timecodes,2));
pedal_acc = zeros(1,size(Timecodes,2));
pedal_frein = zeros(1,size(Timecodes,2));
VarVoie = zeros(1,size(Timecodes,2));
sens = cell(1,size(Timecodes,2));
route = zeros(1,size(Timecodes,2));
pk = zeros(1,size(Timecodes,2));

for i_section=1:1:size(Timecodes,2)  
record_vitesse = trip.getDataOccurencesInTimeInterval('vitesse',Timecodes{1,i_section},Timecodes{2,i_section});
vitesse_moy(i_section) = mean(3.6 * cell2mat(record_vitesse.getVariableValues('vitesse')));
pedal_acc(i_section) = mean((100/255)*cell2mat(record_vitesse.getVariableValues('accelerateur')));
pedal_frein(i_section) = mean((100/255)*cell2mat(record_vitesse.getVariableValues('frein')));

record_Varvoie = trip.getDataVariableOccurencesInTimeInterval('trajectoire','voie',Timecodes{1,i_section},Timecodes{2,i_section});
VarVoie(i_section) = std(cell2mat(record_Varvoie.getVariableValues('voie')));

record_sens = trip.getDataVariableOccurencesInTimeInterval('trajectoire','sens',Timecodes{1,i_section},Timecodes{2,i_section});
sens_temp = record_sens.getVariableValues('sens');
sens{i_section} =  sens_temp{1};

record_localisation = trip.getDataOccurencesInTimeInterval('localisation',Timecodes{1,i_section},Timecodes{2,i_section});
route_temp = str2double(record_localisation.getVariableValues('route'));
pk_temp =cell2mat(record_localisation.getVariableValues('pk'));
route(i_section)=route_temp(1);
pk(i_section)=pk_temp(1);

end

if ~isempty(Timecodes)
trip.setBatchOfTimeSituationVariableTriplets(Situation_List{i_situation},'vitesse_moy',[Timecodes ; num2cell(vitesse_moy)])
trip.setBatchOfTimeSituationVariableTriplets(Situation_List{i_situation}, '%PedaleAcc', [Timecodes ; num2cell(pedal_acc)])
trip.setBatchOfTimeSituationVariableTriplets(Situation_List{i_situation}, '%PedaleFrein',[Timecodes ; num2cell(pedal_frein)])
trip.setBatchOfTimeSituationVariableTriplets(Situation_List{i_situation}, 'VarVoie',[Timecodes ; num2cell(VarVoie)])
trip.setBatchOfTimeSituationVariableTriplets(Situation_List{i_situation}, 'sens',[Timecodes ; sens])
trip.setBatchOfTimeSituationVariableTriplets(Situation_List{i_situation}, 'route',[Timecodes ; num2cell(route)])
trip.setBatchOfTimeSituationVariableTriplets(Situation_List{i_situation}, 'pk',[Timecodes ; num2cell(pk)])
end






end

% On ferme le trip (penser à bien fermer le trip systématiquement !!! pour éviter des messages d'erreur après)  
delete(trip);

end