function BatchGenerateExcel()
   % cd('C:\Documents and Settings\matlab\Bureau\T1_enrichi_260611');
   cd('C:\Users\sornette\Desktop\T2');
   %'./s14 rdv2/s14 natio2/train1.trip', 'natio2', 'noBV';
   %'./s18 rdv2/s18 auor2/train1.trip', 'autor2', 'noBV';
   %'s30 rdv2/s30 natio2/s30_rdv2_natio2/train1.trip', 'natio2', 'noBV';
   %'./s41 rdv1/s41 natio1 2/s41_rdv1_natio1 2/train1.trip', 'natio1', 'noBV';
    subjectsList = {...
        {'./s01 rdv1/s01 autor2/train1.trip', 'autor2', 'noBV';
        './s01 rdv1/s01 natio1/train1.trip', 'natio1', 'noBV';
        './s01 rdv1/s01 ville/train1.trip', 'ville1', 'BV'}
        
        {'./s01 rdv2/s01 autor1/train1.trip', 'autor1', 'noBV';
        './s01 rdv2/s01 natio2/train1.trip', 'natio2', 'noBV';
        './s01 rdv2/s01 ville2/train1.trip', 'ville2', 'noBV'}
        
        {'./s02 1/s02 natio1/s02_rdv1_natio1/train1.trip', 'natio1', 'noBV';
        './s02 1/s02 ville 1/train1.trip', 'ville1', 'BV'}
        
        {'./s02 rdv2/s02 natio2/s02_rdv2_natio2/train1.trip', 'natio2', 'noBV';
        './s02 rdv2/s02 autor1/train1.trip', 'autor1', 'noBV';
        './s02 rdv2/s02 ville2/train1.trip', 'ville2', 'BV';}
        
        {'./s03 rdv1/s03 autor2/train1.trip', 'autor2', 'noBV';
        './s03 rdv1/s03 natio1/train1.trip', 'natio1', 'noBV';
        './s03 rdv1/s03 ville1/train1.trip', 'ville1', 'noBV';}
        
        {'./s03 rdv2/s03 autor1/train1.trip', 'autor1', 'noBV';
        './s03 rdv2/s03 natio2/train1.trip', 'natio2', 'noBV';
        './s03 rdv2/s03 ville2/train1.trip', 'ville2', 'BV';}
        
        {'./s04 rdv1/s04 autor1/train1.trip', 'autor1', 'noBV';
        './s04 rdv1/s04 natio2/train1.trip', 'natio2', 'noBV';
        './s04 rdv1/s04 ville1/train1.trip', 'ville1', 'BV';}
        
        {'./s04 rdv2/s04 autor2/train1.trip', 'autor2', 'noBV';
        './s04 rdv2/s04 natio1/train1.trip', 'natio1', 'noBV';
        './s04 rdv2/s04 ville2/train1.trip', 'ville2', 'noBV';}
        
        {'./s05 rdv1/s05 natio1/train1.trip', 'natio1', 'noBV';
        './s05 rdv1/s05 ville1/train1.trip', 'ville1', 'BV';}
        
        {'./s05 rdv2/s05 autor1/train1.trip', 'autor1', 'noBV';
        './s05 rdv2/s05 natio2/train1.trip', 'natio2', 'noBV';
        './s05 rdv2/s05 ville2/train1.trip', 'ville2', 'BV';}
        
        {'./s06 rdv1/s06 autor2/train1.trip', 'autor2', 'noBV';
        './s06 rdv1/s06 natio1/train1.trip', 'natio1', 'noBV';
        './s06 rdv1/s06 ville1/train1.trip', 'ville1', 'BV';}
        
        {'./s06 rdv2/s06 autor1/train1.trip', 'autor1', 'noBV';
        './s06 rdv2/s06 ville2/train1.trip', 'ville2', 'BV';
        's06 rdv2/s06 natio2/s06_rdv2_natio2/train1.trip', 'natio2', 'noBV';}
        
        {'./s08 rdv1/s08 autor1/train1.trip', 'autor1', 'noBV';
        './s08 rdv1/s08 natio2/train1.trip', 'natio2', 'noBV';
        './s08 rdv1/s08 ville entier/train1.trip', 'ville1', 'BV';}
        
        {'./s08 rdv2/s08 autor2/train1.trip', 'autor2', 'noBV';
        './s08 rdv2/s08 natio1/train1.trip', 'natio1', 'noBV';
        './s08 rdv2/s08 ville2/train1.trip', 'ville2', 'BV';}
        
        {'./s09 rdv1/s09 autor1/train1.trip', 'autor1', 'noBV';
        './s09 rdv1/s09 nayio2/train1.trip', 'natio2', 'noBV';
        './s09 rdv1/s09 ville1/train1.trip', 'ville1', 'BV';}
        
        {'./s09 rdv2/s09 natio1/train1.trip', 'natio1', 'noBV';
        './s09 rdv2/s09 ville2/train1.trip', 'ville2', 'BV';}
        
        {'./s10 rdv1/s10 autor2/train1.trip', 'autor2', 'noBV';
        './s10 rdv1/s10 natio1/train1.trip', 'natio1', 'noBV';
        './s10 rdv1/s10 ville1/train1.trip', 'ville1', 'BV';}
        
        {'./s10 rdv2/s10 autor1/train1.trip', 'autor1', 'noBV';
        './s10 rdv2/s10 natio2/train1.trip', 'natio2', 'noBV';
        './s10 rdv2/s10 ville2/train1.trip', 'ville2', 'noBV';}
        
        {'./s11 rdv1/s11 autor1/train1.trip', 'autor1', 'noBV';
        './s11 rdv1/s11 natio2/train1.trip', 'natio2', 'noBV';
        './s11 rdv1/s11 ville1/train1.trip', 'ville1', 'BV';}
        
        {'./s11 rdv2/s11 auotr2/train1.trip', 'autor2', 'noBV';
        './s11 rdv2/s11 natio1/train1.trip', 'natio1', 'noBV';
        './s11 rdv2/s11 ville2/train1.trip', 'ville2', 'BV';}
        
        {'./s12 rdv1/s12 autor1/train1.trip', 'autor1', 'noBV';
        './s12 rdv1/s12 natio2/train1.trip', 'natio2', 'noBV';}
        
        {'./s12 rdv2/s12 autor2/train1.trip', 'autor2', 'noBV';
        './s12 rdv2/s12 natio1/train1.trip', 'natio1', 'noBV';}
        
        {'./s14 rdv1/s14 autor2/train1.trip', 'autor2', 'noBV';
        './s14 rdv1/s14 natio1/train1.trip', 'natio1', 'noBV';
        './s14 rdv1/s14 ville 1/train1.trip', 'ville1', 'noBV';}
        
        {'./s14 rdv2/s14 autor1/train1.trip', 'autor1', 'noBV';
        './s14 rdv2/s14 ville 2_/train1.trip', 'ville2', 'BV';}
        
        {'./s15 rdv1/s15 autor2/train1.trip', 'autor2', 'noBV';
        './s15 rdv1/s15 natio1/train1.trip', 'natio1', 'noBV';
        './s15 rdv1/s15 ville1/train1.trip', 'ville1', 'BV';}
        
        {'./s15 rdv2/s15 autor1/train1.trip', 'autor1', 'noBV';
        './s15 rdv2/s15 natio2/train1.trip', 'natio2', 'noBV';
        './s15 rdv2/s15 ville2/train1.trip', 'ville2', 'BV';}
        
        {'./s16 rdv1/s16 autor2/train1.trip', 'autor2', 'noBV';
        './s16 rdv1/s16 natio1/train1.trip', 'natio1', 'noBV';}
        
        {'./s16 rdv2/s16 autor1/train1.trip', 'autor1', 'noBV';
        './s16 rdv2/s16 natio2/train1.trip', 'natio2', 'noBV';
        './s16 rdv2/s16 ville2/train1.trip', 'ville2', 'BV';}
        
        {'./S17 rdv-1/autor2/train1.trip', 'autor2', 'noBV';
        './S17 rdv-1/Natio1/train1.trip', 'natio1', 'noBV';
        './S17 rdv-1/ville/train1.trip', 'ville1', 'noBV';}
        
        {'./s17 rdv-2/s17 autor1/train1.trip', 'autor1', 'noBV';
        './s17 rdv-2/s17 natio2/train1.trip', 'natio2', 'noBV';
        './s17 rdv-2/s17 ville2/train1.trip', 'ville2', 'BV';}
        
        {'./s18 rdv1/s18 autor1/train1.trip', 'autor1', 'noBV';
        './s18 rdv1/s18 natio2/train1.trip', 'natio2', 'noBV';
        './s18 rdv1/s18 ville1 sans dern flot/train1.trip', 'ville1', 'noBV';}
        
        {'./s18 rdv2/s18 autor2/train1.trip', 'autor2', 'noBV';
        './s18 rdv2/s18 natio1/train1.trip', 'natio1', 'noBV';}
        
        {'./s20 rdv-1/s20 autor2/train1.trip', 'autor2', 'noBV';
        './s20 rdv-1/s20 natio1/train1.trip', 'natio1', 'noBV';
        './s20 rdv-1/s20 ville/train1.trip', 'ville1', 'noBV';}
        
        {'./s20 rdv-2/s20 autor1/train1.trip', 'autor1', 'noBV';
        './s20 rdv-2/s20 natio2/train1.trip', 'natio2', 'noBV';
        './s20 rdv-2/s20 ville2/train1.trip', 'ville2', 'BV';}
        
        {'./s21 rdv1/s21 autor1/train1.trip', 'autor1', 'noBV';
        './s21 rdv1/s21 natio2/train1.trip', 'natio2', 'noBV';
        './s21 rdv1/s21 ville1/train1.trip', 'ville1', 'BV';}
        
        {'./s21 rdv2/s21 autor2/train1.trip', 'autor2', 'noBV';
        './s21 rdv2/s21 natio1/train1.trip', 'natio1', 'noBV';
        './s21 rdv2/s21 ville2/train1.trip', 'ville2', 'BV';}
        
        {'./s23 rdv1/s23 autor2/train1.trip', 'autor2', 'noBV';
        './s23 rdv1/s23 natio1/train1.trip', 'natio1', 'noBV';
        './s23 rdv1/s23 ville1/train1.trip', 'ville1', 'BV';}
        
        {'./s23 rdv2/s23 autor1/train1.trip', 'autor1', 'noBV';
        './s23 rdv2/s23 natio2/train1.trip', 'natio2', 'noBV';
        './s23 rdv2/s23 ville2/train1.trip', 'ville2', 'noBV';}
        
        {'./s24 rdv-2/s24 natio2/train1.trip', 'natio2', 'noBV';
        './s24 rdv-2/s24 ville2/train1.trip', 'ville2', 'BV';}
        
        {'./s24 rdv1/s24 autor2/train1.trip', 'autor2', 'noBV';
        './s24 rdv1/s24 natio1/train1.trip', 'natio1', 'noBV';
        './s24 rdv1/s24 ville1/train1.trip', 'ville1', 'noBV';}
        
        {'./s25 rdv1/s25 autor2/train1.trip', 'autor2', 'noBV';
        './s25 rdv1/s25 natio1/train1.trip', 'natio1', 'noBV';
        './s25 rdv1/s25 ville1/train1.trip', 'ville1', 'noBV';}
        
        {'./s25 rdv2/s25 autor1/train1.trip', 'autor1', 'noBV';
        './s25 rdv2/s25 natio2/train1.trip', 'natio2', 'noBV';
        './s25 rdv2/s25 ville2/train1.trip', 'ville2', 'BV';}
        
        {'./s26 2/s26 autor2/train1.trip', 'autor2', 'noBV';
        './s26 2/s26 natio1/train1.trip', 'natio1', 'noBV';
        './s26 2/s26 ville2/train1.trip', 'ville2', 'BV';}
        
        {'./s26 rdv1/s26 autor1/train1.trip', 'autor1', 'noBV';
        './s26 rdv1/s26 natio2/train1.trip', 'natio2', 'noBV';}
        
        {'./s27 rdv1/s27 autor2/train1.trip', 'autor2', 'noBV';
        './s27 rdv1/s27 natio1/train1.trip', 'natio1', 'noBV';
        './s27 rdv1/s27 ville1/train1.trip', 'ville1', 'BV';}
        
        {'./s27 rdv2/s27 autor1/train1.trip', 'autor1', 'noBV';
        './s27 rdv2/s27 natio2/train1.trip', 'natio2', 'noBV';
        './s27 rdv2/s27 ville2/train1.trip', 'ville2', 'BV';}
        
        {'./s28 rdv1/s28 autor2/train1.trip', 'autor2', 'noBV';
        './s28 rdv1/s28 natio1/train1.trip', 'natio1', 'noBV';
        './s28 rdv1/s28 ville1/train1.trip', 'ville1', 'noBV';}
        
        {'./s28 rdv2/s28 autor1/train1.trip', 'autor1', 'noBV';
        './s28 rdv2/s28 natio2/train1.trip', 'natio2', 'noBV';
        './s28 rdv2/s28 ville2/train1.trip', 'ville2', 'noBV';}
        
        {'./s29 rdv1/s29 autor1/train1.trip', 'autor1', 'noBV';
        './s29 rdv1/s29 natio2/train1.trip', 'natio2', 'noBV';
        './s29 rdv1/s29 ville1/train1.trip', 'ville1', 'BV';}
        
        {'./s29 rdv2/s29 autor2/train1.trip', 'autor2', 'noBV';
        './s29 rdv2/s29 natio1/train1.trip', 'natio1', 'noBV';
        './s29 rdv2/s29 ville2/train1.trip', 'ville2', 'BV';}
        
        {'./s30 rdv1/s30 autor2/train1.trip', 'autor2', 'noBV';
        './s30 rdv1/s30 natio1/train1.trip', 'natio1', 'noBV';
        './s30 rdv1/s30 ville1/train1.trip', 'ville1', 'BV';}
        
        {'./s30 rdv2/s30 autor1/train1.trip', 'autor1', 'noBV';
        './s30 rdv2/s30 ville2/train1.trip', 'ville2', 'BV';}
        
        {'./s32 rdv1/s32 autor2/train1.trip', 'autor2', 'noBV';
        './s32 rdv1/s32 natio1/train1.trip', 'natio1', 'noBV';
        './s32 rdv1/s32 ville1/train1.trip', 'ville1', 'noBV';}
        
        {'./s32 rdv2/s32 autor1/train1.trip', 'autor1', 'noBV';
        './s32 rdv2/s32 natio2/train1.trip', 'natio2', 'noBV';
        './s32 rdv2/s32 ville2/train1.trip', 'ville2', 'noBV';}
        
        {'./s33 rdv1/sA autor1/train1.trip', 'autor1', 'noBV';
        './s33 rdv1/sA natio2/train1.trip', 'natio2', 'noBV';
        './s33 rdv1/sA ville 1/train1.trip', 'ville1', 'BV';}
        
        {'./s33 rdv2/s33 autor2/train1.trip', 'autor2', 'noBV';
        './s33 rdv2/s33 natio1/train1.trip', 'natio1', 'noBV';
        './s33 rdv2/s33 ville2/train1.trip', 'ville2', 'BV';}
        
        {'./s34 rdv1/s34 autor1/train1.trip', 'autor1', 'noBV';
        './s34 rdv1/s34 natio2/train1.trip', 'natio2', 'noBV';
        './s34 rdv1/s34 ville1/train1.trip', 'ville1', 'BV';}
        
        {'./s34 rdv2/s34 autor2/train1.trip', 'autor2', 'noBV';
        './s34 rdv2/s34 natio1/train1.trip', 'natio1', 'noBV';
        './s34 rdv2/s34 ville2/train1.trip', 'ville2', 'BV';}
        
        {'./s35 rdv1/s35 autor2/train1.trip', 'autor2', 'noBV';
        './s35 rdv1/s35 natio1/train1.trip', 'natio1', 'noBV';
        './s35 rdv1/s35 ville1/train1.trip', 'ville1', 'BV';}
        
        {'./s35 rdv2/s35 ville2/train1.trip', 'ville2', 'BV';}
        
        {'./s36 rdv1/s36 autor1/train1.trip', 'autor1', 'noBV';
        './s36 rdv1/s36 natio2/train1.trip', 'natio2', 'noBV';}
        
        {'./s36 rdv2/s36 autor2/train1.trip', 'autor2', 'noBV';
        './s36 rdv2/s36 natio1/train1.trip', 'natio1', 'noBV';}
        
        {'./s37 rdv1/s37 autor1/train1.trip', 'autor1', 'noBV';
        './s37 rdv1/s37 natio2/train1.trip', 'natio2', 'noBV';
        './s37 rdv1/s37 ville1 sans dern flot/train1.trip', 'ville1', 'BV';}
        
        {'./s38 rdv1/s38 autor1/train1.trip', 'autor1', 'noBV';}
        
        {'./s38 rdv2_/s38 autor2/train1.trip', 'autor2', 'noBV';}
        
        {'./s40 rdv1/s40 autor1/train1.trip', 'autor1', 'noBV';
        './s40 rdv1/s40 natio2/train1.trip', 'natio2', 'noBV';
        './s40 rdv1/s40 ville1/train1.trip', 'ville1', 'BV';}
        
        {'./s40 rdv2/s40 autor2/train1.trip', 'autor2', 'noBV';
        './s40 rdv2/s40 natio1/train1.trip', 'natio1', 'noBV';
        './s40 rdv2/s40 ville2/train1.trip', 'ville2', 'BV';}
        
        {'./s41 rdv1/s41 autor2/train1.trip', 'autor2', 'noBV';}
        
        {'./s41 rdv2/s41 autor1/train1.trip', 'autor1', 'noBV';
        './s41 rdv2/s41 natio2/train1.trip', 'natio2', 'noBV';}
        
        {'./s43 rdv1/s43 natio1/train1.trip', 'natio1', 'noBV';
        './s43 rdv1/s43 ville1/train1.trip', 'ville1', 'noBV';}
        
        {'./s43 rdv2/s43 autor1/train1.trip', 'autor1', 'noBV';
        './s43 rdv2/s43 natio2/train1.trip', 'natio2', 'noBV';
        './s43 rdv2/s43 ville/train1.trip', 'ville2', 'noBV';}
        
        {'./s45 rdv1/s45 autor1/train1.trip', 'autor1', 'noBV';
        './s45 rdv1/s45 natio2/train1.trip', 'natio2', 'noBV';
        './s45 rdv1/s45 ville1/train1.trip', 'ville1', 'BV';}
        
        {'./s45 rdv2/s45 autor2/train1.trip', 'autor2', 'noBV';
        './s45 rdv2/s45 natio1/train1.trip', 'natio1', 'noBV';
        './s45 rdv2/s45 ville2/train1.trip', 'ville2', 'noBV'}
    };

    for i = 1:1:size(subjectsList, 1)
        tripsList = subjectsList{i};
        %Extraction du chemin racine du sujet, en se basant sur le chemin du
        %sujet 1
        [pathOfTrip, ~, ~] = fileparts(tripsList{1, 1} );
        %On enlève le dernier dossier du path pour savoir ou mettre l'excel
        filesepIndexes = strfind(pathOfTrip, '/');
        lastFilesepIndex = max(filesepIndexes);
        pathOfTrip(lastFilesepIndex:end) = [];
        pathOfSubject = pathOfTrip;
        %On extrait le nom du dossier de destination avec la même méthode pour
        %avoir un nom à donner au fichier excel
        filesepIndexes = strfind(pathOfSubject, '/');
        lastFilesepIndex = max(filesepIndexes);
        excelName = pathOfSubject(lastFilesepIndex+1:end);
        disp(['Subject : ' excelName]);
        excelContent = {};
        try
            %TODO : remplir header
            excelContent{1, 1} = 'Parcours'; %#ok<*AGROW>
            excelContent{1, 2} = 'Nom de la moto';        
            excelContent{1, 3} = '(autor, nat) car_speed_at_detection_kmh';
            excelContent{1, 4} = '(autor, nat) moto_speed_at_detection_kmh';
            excelContent{1, 5} = '(autor, nat) detection_distance_m';
            excelContent{1, 6} = '(autor, nat) car_speed_3sec_before_detection_kmh';
            excelContent{1, 7} = '(autor, nat) car_speed_3sec_after_detection_kmh';
            excelContent{1, 8} = '(autor, nat) car_lane_position_3sec_before_detection';
            excelContent{1, 9} = '(autor, nat) car_lane_position_3sec_after_detection';
            excelContent{1, 10} = '(autor, nat) is_break_used_within_3sec_of_detection';                     
            excelContent{1, 11} = '(ville) first_moto_gap_acceptance_m';
            excelContent{1, 12} = '(ville) second_moto_insertion_gap_m';
            excelContent{1, 13} = '(ville) second_moto_min_distance_m';

            globalExcelLineIndice = 2;
            for j = 1:1:size(tripsList, 1)
                tripToOpen = tripsList{j, 1};
                parcoursName = tripsList{j, 2};
                disp(['--> Trip : ' tripToOpen]);
                trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripToOpen, 0.04, false);
                occurences = trip.getAllSituationOccurences('motos');
                endTimes = occurences.getVariableValues('endTimecode');
                motoNames = occurences.getVariableValues('vehicle');
                switch(parcoursName)
                    case({'autor1' 'autor2' 'natio1' 'natio2'})
                        car_speed_at_detection_kmhList = occurences.getVariableValues('car_speed_at_detection_kmh');
                        moto_speed_at_detection_kmhList = occurences.getVariableValues('moto_speed_at_detection_kmh');
                        detection_distance_mList = occurences.getVariableValues('detection_distance_m');
                        car_speed_3sec_before_detection_kmhList = occurences.getVariableValues('car_speed_3sec_before_detection_kmh');
                        car_speed_3sec_after_detection_kmhList = occurences.getVariableValues('car_speed_3sec_after_detection_kmh');
                        car_lane_position_3sec_after_detectionList = occurences.getVariableValues('car_lane_position_3sec_after_detection');
                        car_lane_position_3sec_before_detectionList = occurences.getVariableValues('car_lane_position_3sec_before_detection');
                        is_break_used_within_3sec_of_detectionList = occurences.getVariableValues('is_break_used_within_3sec_of_detection');
                    case({'ville1' 'ville2'});
                        first_moto_gap_acceptance_mList = occurences.getVariableValues('first_moto_gap_acceptance_m');
                        second_moto_insertion_gap_mList = occurences.getVariableValues('second_moto_insertion_gap_m');
                        second_moto_min_distance_mList = occurences.getVariableValues('second_moto_min_distance_m');
                end
                for k = 1:1:size(endTimes, 2)
                    excelContent{globalExcelLineIndice, 1} = parcoursName;
                    excelContent{globalExcelLineIndice, 2} = motoNames{k};
                    switch(parcoursName)
                        case({'autor1' 'autor2' 'natio1' 'natio2'})
                            excelContent{globalExcelLineIndice, 3} = cleanNaN(car_speed_at_detection_kmhList{k});
                            excelContent{globalExcelLineIndice, 4} = cleanNaN(moto_speed_at_detection_kmhList{k});
                            excelContent{globalExcelLineIndice, 5} = cleanNaN(detection_distance_mList{k});
                            excelContent{globalExcelLineIndice, 6} = cleanNaN(car_speed_3sec_before_detection_kmhList{k});
                            excelContent{globalExcelLineIndice, 7} = cleanNaN(car_speed_3sec_after_detection_kmhList{k});
                            excelContent{globalExcelLineIndice, 8} = cleanNaN(car_lane_position_3sec_after_detectionList{k});
                            excelContent{globalExcelLineIndice, 9} = cleanNaN(car_lane_position_3sec_before_detectionList{k});
                            excelContent{globalExcelLineIndice, 10} = cleanNaN(is_break_used_within_3sec_of_detectionList{k});
                        case({'ville1' 'ville2'});
                            excelContent{globalExcelLineIndice, 11} = cleanNaN(first_moto_gap_acceptance_mList{k});
                            excelContent{globalExcelLineIndice, 12} = cleanNaN(second_moto_insertion_gap_mList{k});
                            excelContent{globalExcelLineIndice, 13} = cleanNaN(second_moto_min_distance_mList{k});
                    end
                    globalExcelLineIndice = globalExcelLineIndice + 1;
                end
                trip.delete();
            end
            excelDestination = [pathOfSubject filesep excelName '.xls'];
            if exist(excelDestination, 'file')
                delete(excelDestination);
            end
            xlswrite(excelDestination, excelContent);
            %ecrire le fichier excel d'un coup
        catch ME
            trip.delete();
            disp('Error caught, logging and skipping to next file');
            log = fopen('BatchGenerateExcel.log', 'a+');
            fprintf(log, '%s\n', [datestr(now) ' : Error with this trip : ' tripToOpen]);
            fprintf(log, '%s', ME.getReport('extended', 'hyperlinks', 'off'));
            fprintf(log, '%s\n', '---------------------------------------------------------------------------------');
            fclose(log);
        end
    end
end

function out  = cleanNaN(value)
    if isnan(value)
        out = 'NaN';
    else
        out = value;
    end
end