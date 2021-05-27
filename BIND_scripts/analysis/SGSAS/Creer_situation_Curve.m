% cette fonction creer les situation curve pour les sujets du groupe
% 'curve' � partir des commentaires/messages du simulateur. Elle renvoit
% une variable 4xn (route_pk) qui contient les num�ro de route est de pk de d�but et de fin de situation

function [route_pk_CURVE]=Creer_situation_Curve(chemin_trip)

trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(chemin_trip,0.04,false);
if trip.getMetaInformations().existSituation('stimulation_curve')
    trip.removeSituation('stimulation_curve')
end

%% Teste si la situation 'curve' existe d�j�, si ce n'est pas le cas, on cr�e une MetaSituation qui est ajout�e au trip
if ~(trip.getMetaInformations().existSituation('stimulation_curve'))
    
    % create a metaSituation
    newMetaSituation = fr.lescot.bind.data.MetaSituation;
    %newMetaSituation.setName(commentaire_filtre(1:(indice_Start-1)));
    newMetaSituation.setName('stimulation_curve');
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
    trip.setIsBaseSituation('stimulation_curve',false)
end

%% R�cup�rer les commentaires
record = trip.getAllDataOccurences('variables_simulateur');
cell_timecode=record.getVariableValues('timecode');
cell_commentaires=record.getVariableValues('commentaires');

indice_commentaire_nonzero=not(cellfun(@isempty, cell_commentaires));

cell_timecode_nonzero= cell_timecode(indice_commentaire_nonzero);
cell_commentaires_nonzero=cell_commentaires(indice_commentaire_nonzero);

%initialisation boucle
j=0;
situations_noms={};
for i=1:1:length(cell_commentaires_nonzero)-1
    
    commentaire_filtre=cell_commentaires_nonzero{i}(30:end); %prend les caract�res qui nous int�ressent dans la cha�ne des commentaires
    indice_Start = strfind(commentaire_filtre, 'Start'); %cherche dans cette cha�ne la cha�ne 'Start' est pr�sente et renvoie l'indice de d�but le cas �ch�ant
    
    if (indice_Start ~= 0) %dans chaque cas ou le mot start est pr�sent dans le commentaire "filtr�" on enregistre le nom de la situation ainsi que le timecode correspondant et le timecode suivant 'End'
        j=j+1;
        situations_noms{j,1} = ['Stimulation ' num2str(j)];
        situations_timecodes(j,1) = cell_timecode_nonzero{i}; %timecode 'Start'
        situations_timecodes(j,2) = cell_timecode_nonzero{i+1}; %timecode 'End'   - suppose que les commentaires simu sont bien faits 'Start' suivi de 'End', possibilit� de robustifier tout �a
        trip.setSituationAtTime('stimulation_curve',situations_timecodes(j,1),situations_timecodes(j,2));
    end
    
end

startTimecode_situation_liste = trip.getAllSituationOccurences('stimulation_curve').getVariableValues('startTimecode');
endTimecode_situation_liste = trip.getAllSituationOccurences('stimulation_curve').getVariableValues('endTimecode');

%% Ajoute les noms des diff�rentes variables � la table de situation 'curve'
if isempty(situations_noms)
else
    trip.setBatchOfTimeSituationVariableTriplets('stimulation_curve','Nom',[startTimecode_situation_liste ; endTimecode_situation_liste ; situations_noms'])
end


%% R�cup�ration du num�ro de route et du pk correspond au d�but et fin de situation
Situations=trip.getAllSituationOccurences('stimulation_curve');
Nom_situation=Situations.getVariableValues('Nom');
StartTC=Situations.getVariableValues('startTimecode');
EndTC=Situations.getVariableValues('endTimecode');

route_pk_CURVE=cell(length(Nom_situation),4);

for k=1:1:length(Nom_situation)
    
    %D�but situation :
    % - route et pk
    localisation = trip.getDataOccurenceAtTime('localisation', StartTC{k});
    route_pk_CURVE{k,1}=str2double(localisation.getVariableValues('route'));
    route_pk_CURVE{k,2}=cell2mat(localisation.getVariableValues('pk'));
    % - sens
    trajectoire = trip.getDataOccurenceAtTime('trajectoire', StartTC{k});
    route_pk_CURVE(k,3)=trajectoire.getVariableValues('sens');
    
    %Fin situation
    %- route et pk
    localisation = trip.getDataOccurenceAtTime('localisation', EndTC{k});
    route_pk_CURVE{k,4}=str2double(localisation.getVariableValues('route'));
    route_pk_CURVE{k,5}=cell2mat(localisation.getVariableValues('pk'));
    %- sens
    trajectoire = trip.getDataOccurenceAtTime('trajectoire', EndTC{k});
    route_pk_CURVE(k,6)=trajectoire.getVariableValues('sens');
end
% On ferme le trip (penser � bien fermer le trip syst�matiquement !!! pour
% �viter des messages d'erreur apr�s)
delete(trip);
end