% Cette fonction renvoie un array 2xn avec les timecode de d�but et de fin
% des stimulations. Ces temps sont d�termin�es dans le sc�nario de
% simulateur de conduite et donn� � partir de l'instant ou la vitesse
% d�passe 1m/s

function [route_pk_ALL]=Creer_situation_All(chemin_trip)

trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(chemin_trip,0.04,false);

if trip.getMetaInformations().existSituation('stimulation_all')
    trip.removeSituation('stimulation_all')
end
%% filtrer les commentaires et les apparier 2 par 2 / r�cup�rer les timecodes de d�but et de fin

%test si la situation 'ALL' existe d�j�, si ce pas le cas, cette derni�re est cr��e
if ~(trip.getMetaInformations().existSituation('stimulation_all'))
    
    % create a metaSituation
    newMetaSituation = fr.lescot.bind.data.MetaSituation;
    newMetaSituation.setName('stimulation_all');
    
    % create metaSituationVariables
    Names = {'Nom';'Duree';'Vitesse_moy';'Vitesse_std';'%AppuiAcc_moy';'%AppuiFrein_moy';'%AppuiEmbr_moy';'AppuiAcc_%duree';'AppuiFrein_%duree';'AppuiEmbr_%duree'; ...
        'PositionVoie_std';'AngleVolant_std';'pk';'route';'sens'};
    Types = {'TEXT';'REAL';'REAL';'REAL';'REAL';'REAL';'REAL';'REAL';'REAL';'REAL';'REAL';'REAL';'REAL';'REAL';'TEXT'};
    
    var = cell(length(Names));
    
    for i_var = 1:1:length(Names)
        var{i_var} = fr.lescot.bind.data.MetaSituationVariable();
        var{i_var}.setName(Names{i_var});
        var{i_var}.setType(Types{i_var});
    end
    
    % set the metaSituationVariables in the metaSituation
    newMetaSituation.setVariables(var);
    % add the metaSituation to the trip
    
    trip.addSituation(newMetaSituation);
    trip.setIsBaseSituation('stimulation_all',false)
end

%% R�cup�rer les commentaires
record = trip.getAllDataOccurences('variables_simulateur');
cell_timecode=record.getVariableValues('timecode');
cell_commentaires=record.getVariableValues('commentaires');

indice_commentaire_nonzero=not(cellfun(@isempty, cell_commentaires));

cell_timecode_nonzero= cell_timecode(indice_commentaire_nonzero);
cell_commentaires_nonzero=cell_commentaires(indice_commentaire_nonzero);

%initialisation boucle
j=1;
situations_noms={};
for i=1:length(cell_commentaires_nonzero)-1
    
    commentaire_filtre=cell_commentaires_nonzero{i}(30:end); %prend les caract�res qui nous int�ressent dans la cha�ne des commentaires
    indice_Start = strfind(commentaire_filtre, 'STIMULATION'); %cherche dans cette cha�ne le cha�ne 'Start' est pr�sente et renvoie l'indice de d�but le cas �ch�ant
    
    if ~isempty(indice_Start) && logical(j<17) %dans chaque cas ou le mot start est pr�sent dans le commentaire "filtr�" on enregistre le nom de la situation ainsi que le timecode correspondant et le timecode suivant 'End'
        situations_noms{j,1} = ['Stimulation ' num2str(j)];
        situations_timecodes(j,1) = cell_timecode_nonzero{i}; %timecode 'Start'
        situations_timecodes(j,2) = cell_timecode_nonzero{i+1}; %timecode 'End'   - suppose que les commentaires simu sont bien faites 'Start' suivi de 'End', possibilit� de robustifier tout �a
        
        trip.setSituationAtTime('stimulation_all',situations_timecodes(j,1),situations_timecodes(j,2));
        j=j+1;
    end
end
startTimecode_situation_liste = trip.getAllSituationOccurences('stimulation_all').getVariableValues('startTimecode');
endTimecode_situation_liste = trip.getAllSituationOccurences('stimulation_all').getVariableValues('endTimecode');

%Ajoute les noms des diff�rentes variables � la table de situation 'curve'

if ~isempty(situations_noms)
    trip.setBatchOfTimeSituationVariableTriplets('stimulation_all','Nom',[startTimecode_situation_liste ; endTimecode_situation_liste ; situations_noms'])
end

%% R�cup�ration du num�ro de route et du pk correspond au d�but et fin de situation
Situations=trip.getAllSituationOccurences('stimulation_all');
Nom_situation=Situations.getVariableValues('Nom');
StartTC=Situations.getVariableValues('startTimecode');
EndTC=Situations.getVariableValues('endTimecode');

route_pk_ALL=cell(length(Nom_situation),6);

for k=1:1:length(Nom_situation)
    
    %D�but situation :
    % - route et pk
    localisation = trip.getDataOccurenceAtTime('localisation', StartTC{k});
    route_pk_ALL{k,1}=str2double(localisation.getVariableValues('route'));
    route_pk_ALL{k,2}=cell2mat(localisation.getVariableValues('pk'));
    % - sens
    trajectoire = trip.getDataOccurenceAtTime('trajectoire', StartTC{k});
    route_pk_ALL(k,3)=trajectoire.getVariableValues('sens');
    
    %Fin situation
    %- route et pk
    localisation = trip.getDataOccurenceAtTime('localisation', EndTC{k});
    route_pk_ALL{k,4}=str2double(localisation.getVariableValues('route'));
    route_pk_ALL{k,5}=cell2mat(localisation.getVariableValues('pk'));
    %- sens
    trajectoire = trip.getDataOccurenceAtTime('trajectoire', EndTC{k});
    route_pk_ALL(k,6)=trajectoire.getVariableValues('sens');
end


% %% On cherche le timecode de d�but scenario  -> vitesse sup�rieure � 1m/s
% record = trip.getAllDataOccurences('vitesse');
% timecode=cell2mat(record.getVariableValues('timecode'));
% vitesse=cell2mat(record.getVariableValues('vitesse'));
% TC_vitesse_sup_1ms=timecode(vitesse>3.6);
% StartScenarioTC=TC_vitesse_sup_1ms(1);
%
% TC_debut_fin=[cell2mat(startTimecode_situation_liste) - StartScenarioTC ; cell2mat(endTimecode_situation_liste) - StartScenarioTC];
% TC_debut_fin =TC_debut_fin';


%% Fermeture trip
delete(trip);

end



















