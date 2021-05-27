premier_passation = 1;
dernier_passation = 20;

% mettre le bon repertoire
dirData = '\\vrlescot\MADISON\DATA2';

listeConditions = { 'DP1', 'DP2' , 'DP3', 'TAG1', 'TAG2', 'TAG3', 'Pieton', 'Vt'};

for i=premier_passation:dernier_passation
    
    nomdirREC = dir([dirData '\Passation_' num2str(i) '\rtmaps\Test' '\*REC']);
    
    if isempty(nomdirREC)~=1
        
        nomRecFile = nomdirREC.name;
        nomdirTrip = dir([dirData '\Passation_' num2str(i) '\rtmaps\Test\' nomRecFile '\*.trip']);
        nomRecFiletrip = nomdirTrip.name;
        tripname = [dirData '\Passation_' num2str(i) '\rtmaps\Test\' nomRecFile '\' nomRecFiletrip];
        trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripname, 0.04, false);
        metaInfos = trip.getMetaInformations();
        
        if metaInfos.existEvent('DR2_Commentaires')
            
            DR2events = trip.getAllEventOccurences('DR2_Commentaires');
            Events = DR2events.getVariableValues('commentaire0');
            DR2timecodeevent = DR2events.getVariableValues('timecode');
            CADISPevents = trip.getAllEventOccurences('CADISP');
            EventsScale = CADISPevents.getVariableValues('action');
            CADISPtimecodeevent = CADISPevents.getVariableValues('timecode');
            CADISPtimecodeevent = cell2mat (CADISPtimecodeevent);
            Inconfort_level = CADISPevents.getVariableValues('scale_level');
            
            temps_DEBUT = DR2timecodeevent(find(strcmp(Events,'DEB_SCENARIO')));
            temps_DEBUT = cell2mat (temps_DEBUT);
            
            temps_DEP_1 = DR2timecodeevent(find(strcmp(Events,'FIN_DEP_LEVEL_1')));
            temps_DEP_1 = cell2mat (temps_DEP_1);
            inconfort_DEP_1 = Inconfort_level(find(strcmp(EventsScale,'click')&(CADISPtimecodeevent>temps_DEP_1&CADISPtimecodeevent<(temps_DEP_1+60))));
            inconfort_DEP_1 = cell2mat (inconfort_DEP_1)
            
            temps_DEP_2 = DR2timecodeevent(find(strcmp(Events,'FIN_DEP_LEVEL_2')));
            temps_DEP_2 = cell2mat (temps_DEP_2);
            
            temps_DEP_3 = DR2timecodeevent(find(strcmp(Events,'FIN_DEP_LEVEL_3')));
            temps_DEP_3 = cell2mat (temps_DEP_3);
            
            temps_TAG_1 = DR2timecodeevent(find(strcmp(Events,'FIN_TAG_LEVEL_1')));
            temps_TAG_1 = cell2mat (temps_TAG_1);
            
            temps_TAG_2 = DR2timecodeevent(find(strcmp(Events,'FIN_TAG_LEVEL_2')));
            temps_TAG_2 = cell2mat (temps_TAG_2);
            
            temps_TAG_3 = DR2timecodeevent(find(strcmp(Events,'FIN_TAG_LEVEL_3')));
            temps_TAG_3 = cell2mat (temps_TAG_3);
            
            dataRecord = trip.getAllDataOccurences('BIOPAC_MP150');
            biopacTimecode = cell2mat(dataRecord.getVariableValues('timecode'));
            
            %% ECG DATA 
            
            ecgValues = cell2mat(dataRecord.getVariableValues('ecg'));
            [posPic, valRR, RR2, DRR2] = extractRRMadison(ecgValues);
            timecodePic = biopacTimecode(posPic(2:end-1));
            
            INDCardiaques_DEP_1(i,:) = CreerIndicateursECGMadison(temps_DEP_1,timecodePic,valRR,RR2,DRR2);
            INDCardiaques_DEP_2(i,:) = CreerIndicateursECGMadison(temps_DEP_2,timecodePic,valRR,RR2,DRR2);
            INDCardiaques_DEP_3(i,:) = CreerIndicateursECGMadison(temps_DEP_3,timecodePic,valRR,RR2,DRR2);
            INDCardiaques_TAG_1(i,:) = CreerIndicateursECGMadison(temps_TAG_1,timecodePic,valRR,RR2,DRR2);
            INDCardiaques_TAG_2(i,:) = CreerIndicateursECGMadison(temps_TAG_2,timecodePic,valRR,RR2,DRR2);
            INDCardiaques_TAG_3(i,:) = CreerIndicateursECGMadison(temps_TAG_3,timecodePic,valRR,RR2,DRR2);
      
            %% EDA DATA
            
            edaValues = cell2mat(dataRecord.getVariableValues('eda'));
            indexdebut=1;
            while (biopacTimecode(indexdebut)<temps_DEBUT)
                indexdebut = indexdebut+1;
            end
            temps_EDA = biopacTimecode (indexdebut:end);
            signal_EDA = edaValues (indexdebut:end);
            signal_temps_EDA = [temps_EDA ; signal_EDA'];
            nomSignal = ['EDA_P' num2str(i) '.csv'];
            save(nomSignal,'signal_temps_EDA', '-ascii')
           
            % Specifier dossier où l'on va chercher les données
            Ledalab('D:\hidalgo\Desktop\MADISON 2 Scripts 25042019\', 'open', 'text', 'downsample', 50, 'analyze', 'CDA', 'export_scrlist', [.01 3])
           
            
            INDDermale_DEP_1(i,:) = CreerIndicateursEDAMadison(temps_DEP_1,temps_DEBUT,i);
            INDDermale_DEP_2(i,:) = CreerIndicateursEDAMadison(temps_DEP_2,temps_DEBUT,i);
            INDDermale_DEP_3(i,:) = CreerIndicateursEDAMadison(temps_DEP_3,temps_DEBUT,i); 
            INDDermale_TAG_1(i,:) = CreerIndicateursEDAMadison(temps_TAG_1,temps_DEBUT,i);
            INDDermale_TAG_2(i,:) = CreerIndicateursEDAMadison(temps_TAG_2,temps_DEBUT,i);
            INDDermale_TAG_3(i,:) = CreerIndicateursEDAMadison(temps_TAG_3,temps_DEBUT,i);
          
            %% DRIVING DATA
            dataRecord = trip.getAllDataOccurences('DR2_Vehicule_VHS_vp');
            DR2Timecode = cell2mat(dataRecord.getVariableValues('timecode'));
            CabValues = cell2mat(dataRecord.getVariableValues('Cab.Volant'));
            VoieValues = cell2mat(dataRecord.getVariableValues('Voie'));
            
            dataRecord = trip.getAllDataOccurences('DR2_Simulateur');
            dtValues = cell2mat(dataRecord.getVariableValues('dt'));
            
            CabValues_timecode =[DR2Timecode;CabValues]';
            VoieValues_timecode =[DR2Timecode;VoieValues]';
            
            % trouver les index qui correspondent aux virages
            temps_DEB_VIRAGE_1 = DR2timecodeevent(find(strcmp(Events,'DEB_VIRAGE_1')));
            temps_DEB_VIRAGE_1 = cell2mat (temps_DEB_VIRAGE_1);
            temps_FIN_VIRAGE_1 = DR2timecodeevent(find(strcmp(Events,'FIN_VIRAGE_1')));
            temps_FIN_VIRAGE_1 = cell2mat (temps_FIN_VIRAGE_1);
            index_VIRAGES_1=[];
            for i=1:numel(temps_DEB_VIRAGE_1)
                Index=find(CabValues_timecode (:,1) > temps_DEB_VIRAGE_1(i) & CabValues_timecode(:,1) < temps_FIN_VIRAGE_1(i));
                Index=Index';
                index_VIRAGES_1=[index_VIRAGES_1 Index]
            end
            
            temps_DEB_VIRAGE_2 = DR2timecodeevent(find(strcmp(Events,'DEB_VIRAGE_2')));
            temps_DEB_VIRAGE_2 = cell2mat (temps_DEB_VIRAGE_2);
            temps_FIN_VIRAGE_2 = DR2timecodeevent(find(strcmp(Events,'FIN_VIRAGE_2')));
            temps_FIN_VIRAGE_2 = cell2mat (temps_FIN_VIRAGE_2);
            index_VIRAGES_2=[];
            for i=1:numel(temps_DEB_VIRAGE_2)
                Index=find(CabValues_timecode (:,1) > temps_DEB_VIRAGE_2(i) & CabValues_timecode(:,1) < temps_FIN_VIRAGE_2(i));
                Index=Index';
                index_VIRAGES_2=[index_VIRAGES_2 Index]
            end
            
            temps_DEB_VIRAGE_3 = DR2timecodeevent(find(strcmp(Events,'DEB_VIRAGE_3')));
            temps_DEB_VIRAGE_3 = cell2mat (temps_DEB_VIRAGE_3);
            temps_FIN_VIRAGE_3 = DR2timecodeevent(find(strcmp(Events,'FIN_VIRAGE_3')));
            temps_FIN_VIRAGE_3 = cell2mat (temps_FIN_VIRAGE_3);
            index_VIRAGES_3=[];
            for i=1:numel(temps_DEB_VIRAGE_3)
                Index=find(CabValues_timecode (:,1) > temps_DEB_VIRAGE_3(i) & CabValues_timecode(:,1) < temps_FIN_VIRAGE_3(i));
                Index=Index';
                index_VIRAGES_3=[index_VIRAGES_3 Index]
            end
            
            temps_DEB_VIRAGE_4 = DR2timecodeevent(find(strcmp(Events,'DEB_VIRAGE_4')));
            temps_DEB_VIRAGE_4 = cell2mat (temps_DEB_VIRAGE_4);
            temps_FIN_VIRAGE_4 = DR2timecodeevent(find(strcmp(Events,'FIN_VIRAGE_4')));
            temps_FIN_VIRAGE_4 = cell2mat (temps_FIN_VIRAGE_4);
            index_VIRAGES_4=[];
            for i=1:numel(temps_DEB_VIRAGE_4)
                Index=find(CabValues_timecode (:,1) > temps_DEB_VIRAGE_4(i) & CabValues_timecode(:,1) < temps_FIN_VIRAGE_4(i));
                Index=Index';
                index_VIRAGES_4=[index_VIRAGES_4 Index]
            end
            
            temps_DEB_VIRAGE_5 = DR2timecodeevent(find(strcmp(Events,'DEB_VIRAGE_5')));
            temps_DEB_VIRAGE_5 = cell2mat (temps_DEB_VIRAGE_5);
            temps_FIN_VIRAGE_5 = DR2timecodeevent(find(strcmp(Events,'FIN_VIRAGE_5')));
            temps_FIN_VIRAGE_5 = cell2mat (temps_FIN_VIRAGE_5);
            index_VIRAGES_5=[];
            for i=1:numel(temps_DEB_VIRAGE_5)
                Index=find(CabValues_timecode (:,1) > temps_DEB_VIRAGE_5(i) & CabValues_timecode(:,1) < temps_FIN_VIRAGE_5(i));
                Index=Index';
                index_VIRAGES_5=[index_VIRAGES_5 Index]
            end
         
            
            CabValues_sans_virages = CabValues_timecode;
            VoieValues_sans_virages = VoieValues_timecode;
            CabValues_sans_virages([index_VIRAGES_1 index_VIRAGES_2 index_VIRAGES_3 index_VIRAGES_4 index_VIRAGES_5],:)= [];
            VoieValues_sans_virages([index_VIRAGES_1 index_VIRAGES_2 index_VIRAGES_3 index_VIRAGES_4 index_VIRAGES_5],:)= [];
            dtValues_sans_virages = dtValues;
            dtValues_sans_virages([index_VIRAGES_1 index_VIRAGES_2 index_VIRAGES_3 index_VIRAGES_4 index_VIRAGES_5])= [];
             
            CabValues_virages = CabValues_timecode([index_VIRAGES_1 index_VIRAGES_2 index_VIRAGES_3 index_VIRAGES_4 index_VIRAGES_5],:); 
            VoieValues_virages = VoieValues_timecode([index_VIRAGES_1 index_VIRAGES_2 index_VIRAGES_3 index_VIRAGES_4 index_VIRAGES_5],:);
            
            INDDriving_DEP_1(i,:) = CreerIndicateursDriving(CabValues_sans_virages,VoieValues_sans_virages,dtValues_sans_virages,temps_DEP_1);
            INDDriving_DEP_2(i,:) = CreerIndicateursDriving(CabValues_sans_virages,VoieValues_sans_virages,dtValues_sans_virages,temps_DEP_2);
            INDDriving_DEP_3(i,:) = CreerIndicateursDriving(CabValues_sans_virages,VoieValues_sans_virages,dtValues_sans_virages,temps_DEP_3); 
            INDDriving_TAG_1(i,:) = CreerIndicateursDriving(CabValues_sans_virages,VoieValues_sans_virages,dtValues_sans_virages,temps_TAG_1);
            INDDriving_TAG_2(i,:) = CreerIndicateursDriving(CabValues_sans_virages,VoieValues_sans_virages,dtValues_sans_virages,temps_TAG_2);
            INDDriving_TAG_3(i,:) = CreerIndicateursDriving(CabValues_sans_virages,VoieValues_sans_virages,dtValues_sans_virages,temps_TAG_3);
            
            %% GAZE DATA
            
        end
        
    end
    
end

