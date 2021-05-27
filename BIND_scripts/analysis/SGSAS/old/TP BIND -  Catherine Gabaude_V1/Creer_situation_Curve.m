function Creer_situation_Curve(chemin_trip)

trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(chemin_trip,0.04,false);
    
    %% R�cup�rer les commentaires
record = trip.getAllDataOccurences('variables_simulateur');    
cell_timecode=record.getVariableValues('timecode');
cell_commentaires=record.getVariableValues('commentaires');

cell_timecode_nonzero= cell_timecode(not(strcmp(cell_commentaires, '0')));
cell_commentaires_nonzero=cell_commentaires(not(strcmp(cell_commentaires, '0')));

%% filtrer les commentaires et les apparier 2 par 2 / r�cup�rer les timecodes de d�but et de fin
    % create a metaSituation
       newMetaSituation = fr.lescot.bind.data.MetaSituation;
       %newMetaSituation.setName(commentaire_filtre(1:(indice_Start-1)));
       newMetaSituation.setName('curve');
    % create metaSituationVariables
       var = cell(5);
       var{1} = fr.lescot.bind.data.MetaSituationVariable();
       var{1}.setName('Nom');
       var{1}.setType('TEXT');
       
       var{2} = fr.lescot.bind.data.MetaSituationVariable();
       var{2}.setName('vitesse_moy');
       var{2}.setType('REAL');
       
       var{3} = fr.lescot.bind.data.MetaSituationVariable();
       var{3}.setName('%PedaleAcc');
       var{3}.setType('REAL');
       
       var{4} = fr.lescot.bind.data.MetaSituationVariable();
       var{4}.setName('%PedaleFrein');
       var{4}.setType('REAL');
       
       var{5} = fr.lescot.bind.data.MetaSituationVariable();
       var{5}.setName('VarVoie');
       var{5}.setType('REAL');
       
       
       
    % set the metaSituationVariables in the metaSituation
       newMetaSituation.setVariables(var);
    % add the metaSituation to the trip
  
%test si la situation 'curve' existe d�j�, si ce pas le cas, cette derni�re est cr��e
if (trip.getMetaInformations().existSituation('curve')) 
else
    trip.addSituation(newMetaSituation);
    trip.setIsBaseSituation('curve',false)   
end
 
%initialisation boucle 
i=0;
j=0;
situations_noms={};
for i=1:1:length(cell_commentaires_nonzero)-1 % Question : y'a t il un moyen d'�viter une boucle ??? 

    commentaire_filtre=cell_commentaires_nonzero{i}(30:end); %prend les caract�res qui nous int�ressent dans la cha�ne des commentaires
    indice_Start = strfind(commentaire_filtre, 'Start'); %cherche dans cette cha�ne le cha^ne 'Start' est pr�sente et renvoie l'indice de d�but le cas �ch�ant
 
    if (indice_Start ~= 0) %dans chaque cas ou le mot start est pr�sent dans le commentaire "filtr�" on enregistre le nom de la situation ainsi que le timecode correspondant et le timecode suivant 'End'
       j=j+1;  
       situations_noms{j,1} = commentaire_filtre(1:(indice_Start-1));
       situations_timecodes(j,1) = cell_timecode_nonzero{i}; %timecode 'Start'
       situations_timecodes(j,2) = cell_timecode_nonzero{i+1}; %timecode 'End'   - suppose que les commentaires simu sont bien faites 'Start' suivi de 'End', possibilit� de robustifier tout �a 
    
       trip.setSituationAtTime('curve',situations_timecodes(j,1),situations_timecodes(j,2));
     end     
end

startTimecode_situation_liste = trip.getAllSituationOccurences('curve').getVariableValues('startTimecode');
endTimecode_situation_liste = trip.getAllSituationOccurences('curve').getVariableValues('endTimecode');



%Nomme les situatio situations avec le vitesse moyenne calcul�e
if isempty(situations_noms)
else
trip.setBatchOfTimeSituationVariableTriplets('curve','Nom',[startTimecode_situation_liste ; endTimecode_situation_liste ; situations_noms' ])
end
    %% Appel le routine qui calcule et peuple les instances de situation
       
%calcule_vitesse_moyenne_situation    
    
    % On ferme le trip (penser � bien fermer le trip syst�matiquement !!! pour
    % �viter des messages d'erreur apr�s)
delete(trip);


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    