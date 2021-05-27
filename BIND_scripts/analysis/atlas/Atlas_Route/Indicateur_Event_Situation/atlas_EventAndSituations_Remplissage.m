function out=atlas_EventAndSituations_Remplissage(trip)
    out='';
    
    metas = trip.getMetaInformations;
    
    Situation_List = trip.getMetaInformations().getSituationsNamesList;
    Event_List = trip.getMetaInformations().getEventsNamesList;
    
    
    
    Events=cell(1,length(Event_List));
    for i=1:1:length(Event_List)
    record=trip.getAllEventOccurences(Event_List{i});
    Events{i}= cell2mat( record.getVariableValues('timecode'));
    end
    
    for i=1:1:length(Situation_List)
        Situation_Name=Situation_List{i};      
            
            %% Case Double Tache
            if strcmp(Situation_Name,'double tache')
                
                record_situation =trip.getAllSituationOccurences(Situation_Name);
                sections = record_situation.buildCellArrayWithVariables({'Nom';'startTimecode';'endTimecode'});
                
                N=size(sections,2);
                for j=1:1:N
                    situation_startTimecode = sections{2,j};
                    situation_endTimecode = sections{3,j};
                    
                    % Calcul des indicateurs
                    
                    NbreEvent = ComptageEvent(Events,situation_startTimecode,situation_endTimecode);
                    
                    if metas.existData('Kvaser_ABR')
                        
                        %timecode=cell2mat(trip.getDataVariableOccurencesInTimeInterval('Mopad_SensorsMeasures','Speed',sections{2,j},sections{3,j}).getVariableValues('timecode'));
                        Speed=cell2mat(trip.getDataVariableOccurencesInTimeInterval('Kvaser_ABR','VITESSE_VEH_ROUES', situation_startTimecode , situation_endTimecode ).getVariableValues('VITESSE_VEH_ROUES'));
                        Speed_moy= mean(Speed(Speed>5)); %on prend les vitesses supérieures à 5km/h
                        Speed_stddev= std(Speed);
                        
                        
                        % Angle Volant
                        Angle_Volant=cell2mat(trip.getDataVariableOccurencesInTimeInterval('Kvaser_VOL','ANGLE_VOLANT', situation_startTimecode, ...
                            situation_endTimecode ).getVariableValues('ANGLE_VOLANT'));
                        Angle_Volant_moy = mean(Angle_Volant);
                        Angle_Volant_std = std(Angle_Volant);
                        
                        
                        %Position sur la voie
                        
                        PosVoie=cell2mat(trip.getDataVariableOccurencesInTimeInterval('Kvaser_LDW1','ALDW_LaneLtrlDist', situation_startTimecode, ...
                            situation_endTimecode ).getVariableValues('ALDW_LaneLtrlDist'));
                        
                        PosVoie_moy =mean(PosVoie);
                        PosVoie_std =std(PosVoie);
                        
                        LaneChange_stat=cell2mat(trip.getDataVariableOccurencesInTimeInterval('Kvaser_LDW1','ALDW_LaneChg_Stat', situation_startTimecode, ...
                            situation_endTimecode ).getVariableValues('ALDW_LaneChg_Stat'));
                        
                        N_LaneChange_droite = nnz(LaneChange_stat==1);
                        N_LaneChange_gauche = nnz(LaneChange_stat==2);
                        N_LaneChange =N_LaneChange_droite+N_LaneChange_gauche;
                        
                        %Ajouter les changements de voies : 'N_LineChange','N_LineChange_L','N_LineChange_G'
                        
                    elseif metas.existData('Mopad_CAN')
                        
                        record = trip.getDataOccurencesInTimeInterval('Mopad_CAN',situation_startTimecode,situation_endTimecode);
                        
                        Speed = cell2mat(record.getVariableValues('VITESSE_VEHICULE_ROUES'));
                        Speed_moy = mean (Speed(Speed > 5)); % vitesse Moyenne sur tout le trip supérieur à 5km/h
                        Speed_stddev = std (Speed(Speed > 5)); % vitesse Moyenne sur tout le trip supérieur à 5km/h
                        
                        Angle_Volant= cell2mat(record.getVariableValues('ANGLE_VOLANT'));
                        Angle_Volant_moy = mean (Angle_Volant);
                        Angle_Volant_std = std(Angle_Volant);
                        PosVoie_moy = nan ;
                        PosVoie_std = nan ;
                        N_LaneChange_droite = nan ;
                        N_LaneChange_gauche = nan ;
                        N_LaneChange = nan ;
                        
                    end
                    
                    % Remplissage des situations
                    trip.setSituationVariableAtTime('double tache','Vitesse_moy',situation_startTimecode,situation_endTimecode,Speed_moy);
                    trip.setSituationVariableAtTime('double tache','Vitesse_stddev',situation_startTimecode,situation_endTimecode,Speed_stddev);
                    
                    trip.setSituationVariableAtTime('double tache','AngleVolant_moy',situation_startTimecode,situation_endTimecode,Angle_Volant_moy);
                    trip.setSituationVariableAtTime('double tache','AngleVolant_std',situation_startTimecode,situation_endTimecode,Angle_Volant_std);
                    
                    trip.setSituationVariableAtTime('double tache','PositionVoie_moy',situation_startTimecode,situation_endTimecode,PosVoie_moy);
                    trip.setSituationVariableAtTime('double tache','PositionVoie_stddev',situation_startTimecode,situation_endTimecode,PosVoie_std);
                    trip.setSituationVariableAtTime('double tache','N_LineChange',situation_startTimecode,situation_endTimecode,N_LaneChange);
                    trip.setSituationVariableAtTime('double tache','N_LineChange_D',situation_startTimecode,situation_endTimecode,N_LaneChange_gauche);
                    trip.setSituationVariableAtTime('double tache','N_LineChange_G',situation_startTimecode,situation_endTimecode,N_LaneChange_droite);
                    
                    trip.setSituationVariableAtTime('double tache','NbreEvent1',situation_startTimecode,situation_endTimecode,NbreEvent(1,1));
                    trip.setSituationVariableAtTime('double tache','NbreEvent2',situation_startTimecode,situation_endTimecode,NbreEvent(1,2));
                end
                
                
                %% Case MindWandering
            elseif strcmp(Situation_Name,'MindWandering_avant') || strcmp(Situation_Name,'MindWandering_apres')
                
                record_situation =trip.getAllSituationOccurences(Situation_Name);
                sections = record_situation.buildCellArrayWithVariables({'Nom';'startTimecode';'endTimecode'});
                
                N=size(sections,2);
                for j=1:1:N
                    situation_startTimecode = sections{2,j};
                    situation_endTimecode = sections{3,j};
                    
                    % Calcul des indicateurs
                    
                    if metas.existData('Kvaser_ABR')
                        
                        %timecode=cell2mat(trip.getDataVariableOccurencesInTimeInterval('Mopad_SensorsMeasures','Speed',sections{2,j},sections{3,j}).getVariableValues('timecode'));
                        Speed=cell2mat(trip.getDataVariableOccurencesInTimeInterval('Kvaser_ABR','VITESSE_VEH_ROUES', situation_startTimecode , situation_endTimecode ).getVariableValues('VITESSE_VEH_ROUES'));
                        Speed_moy= mean(Speed(Speed>5)); %on prend les vitesses supérieures à 5km/h
                        Speed_stddev= std(Speed);
                        
                        % Angle Volant
                        Angle_Volant=cell2mat(trip.getDataVariableOccurencesInTimeInterval('Kvaser_VOL','ANGLE_VOLANT', situation_startTimecode, ...
                            situation_endTimecode ).getVariableValues('ANGLE_VOLANT'));
                        Angle_Volant_moy = mean(Angle_Volant);
                        Angle_Volant_std = std(Angle_Volant);
                        
                        %Position sur la voie
                        PosVoie=cell2mat(trip.getDataVariableOccurencesInTimeInterval('Kvaser_LDW1','ALDW_LaneLtrlDist', situation_startTimecode, ...
                            situation_endTimecode ).getVariableValues('ALDW_LaneLtrlDist'));
                        PosVoie_moy =mean(PosVoie);
                        PosVoie_std =std(PosVoie);
                        
                        LaneChange_stat=cell2mat(trip.getDataVariableOccurencesInTimeInterval('Kvaser_LDW1','ALDW_LaneChg_Stat', situation_startTimecode, ...
                            situation_endTimecode ).getVariableValues('ALDW_LaneChg_Stat'));
                        
                        N_LaneChange_droite = nnz(LaneChange_stat==1);
                        N_LaneChange_gauche = nnz(LaneChange_stat==2);
                        N_LaneChange =N_LaneChange_droite+N_LaneChange_gauche;
                        
                        
                    elseif metas.existData('Mopad_CAN')
                        
                        record = trip.getDataOccurencesInTimeInterval('Mopad_CAN',situation_startTimecode,situation_endTimecode);
                        
                        Speed = cell2mat(record.getVariableValues('VITESSE_VEHICULE_ROUES'));
                        Speed_moy = mean (Speed(Speed > 5)); % vitesse Moyenne sur tout le trip supérieur à 5km/h
                        Speed_stddev = std (Speed(Speed > 5)); % vitesse Moyenne sur tout le trip supérieur à 5km/h
                        
                        Angle_Volant= cell2mat(record.getVariableValues('ANGLE_VOLANT'));
                        Angle_Volant_moy = mean (Angle_Volant);
                        Angle_Volant_std = std(Angle_Volant);
                        PosVoie_moy = nan ;
                        PosVoie_std = nan ;
                        N_LaneChange_droite = nan ;
                        N_LaneChange_gauche = nan ;
                        N_LaneChange = nan ;
                        
                    end
                    
                    % Remplissage des situations
                    trip.setSituationVariableAtTime(Situation_Name,'Vitesse_moy',situation_startTimecode,situation_endTimecode,Speed_moy);
                    trip.setSituationVariableAtTime(Situation_Name,'Vitesse_stddev',situation_startTimecode,situation_endTimecode,Speed_stddev);
                    
                    trip.setSituationVariableAtTime(Situation_Name,'AngleVolant_moy',situation_startTimecode,situation_endTimecode,Angle_Volant_moy);
                    trip.setSituationVariableAtTime(Situation_Name,'AngleVolant_std',situation_startTimecode,situation_endTimecode,Angle_Volant_std);
                    
                    trip.setSituationVariableAtTime(Situation_Name,'PositionVoie_moy',situation_startTimecode,situation_endTimecode,PosVoie_moy);
                    trip.setSituationVariableAtTime(Situation_Name,'PositionVoie_stddev',situation_startTimecode,situation_endTimecode,PosVoie_std);
                    trip.setSituationVariableAtTime(Situation_Name,'N_LineChange',situation_startTimecode,situation_endTimecode,N_LaneChange);
                    trip.setSituationVariableAtTime(Situation_Name,'N_LineChange_D',situation_startTimecode,situation_endTimecode,N_LaneChange_gauche);
                    trip.setSituationVariableAtTime(Situation_Name,'N_LineChange_G',situation_startTimecode,situation_endTimecode,N_LaneChange_droite);
                    
                end
                
                
            else
                warndlg('Il n y a pas de table de situation dans le trip ou la table demandée n existe pas');
                
            end
    end
    
end