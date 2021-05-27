% Route_Pk_Situation_Curve  est array 4xn contenant le numéro de route et de pk du début et de fin du situation pour les sujets du groupe curve
% TC_Situation_All est array  de taille 2xn contenant le temps de début (1,:) et de fin (2,:) des
% stimulations définies par le scénario du simulateur de conduite. Le temps de la première
% stimulation est donné à partir de l'instant ou la vitesse dépasse 1m/s

function Creer_situation_Neutral(chemin_trip,Table_Neutral_particpant)

Route_Pk_Sens_Situation_Curve = Table_Neutral_particpant{1};
Route_Pk_Sens_Situation_All = Table_Neutral_particpant{2};

trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(chemin_trip,0.04,false);
if trip.getMetaInformations().existSituation('stimulation_all')
    trip.removeSituation('stimulation_all')
end
if trip.getMetaInformations().existSituation('stimulation_curve')
    trip.removeSituation('stimulation_curve')
end
%% Creation de la situation : 'Stimulation_All'
if ~(trip.getMetaInformations().existSituation('stimulation_all'))
    % create a metaSituation
    newMetaSituation = fr.lescot.bind.data.MetaSituation;
    %newMetaSituation.setName(commentaire_filtre(1:(indice_Start-1)));
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

%% Creation de la Meta situation : 'stimulation_curve'
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

%% Récupération des TC pour Neutral_Stimulation_Curve

TC_debut_fin_Curve = cherche_TC_situation(trip,Route_Pk_Sens_Situation_Curve);

situations_noms=cell(1,size(TC_debut_fin_Curve,1));
for i=1:1:length(TC_debut_fin_Curve)
    situations_noms{1,i} = ['stimulation_curve ' num2str(i)];
end

variable_triplets = [ num2cell( TC_debut_fin_Curve)  situations_noms']';

if ~isempty(TC_debut_fin_Curve)
    trip.setBatchOfTimeSituationVariableTriplets('stimulation_curve','Nom',variable_triplets)
end

%% Récupération des TC pour Neutral_Stimulation_All

TC_debut_fin_All = cherche_TC_situation(trip,Route_Pk_Sens_Situation_All);

situations_noms=cell(1,size(TC_debut_fin_All,1));
for i=1:1:length(TC_debut_fin_All)
    situations_noms{1,i} = ['stimulation_all ' num2str(i)];
end

variable_triplets = [ num2cell(TC_debut_fin_All)  situations_noms']';

if ~isempty(TC_debut_fin_Curve)
    trip.setBatchOfTimeSituationVariableTriplets('stimulation_all','Nom',variable_triplets)
end

% On ferme le trip (penser à bien fermer le trip systématiquement !!! pour éviter des messages d'erreur après)
delete(trip);
end