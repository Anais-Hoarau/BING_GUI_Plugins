function atlas_route_xls_log()

    %% répertoires de travail
    trips_folder= 'D:\LESCOT\Projets\ATLAS\Atlas Route\DONNEES\MANIPS';
    cd (trips_folder); 
    trips_list = dirrec(trips_folder ,'.trip');

    %% constantes
    
    nom_columns = {'n° sujet','nom sujet','Aller/Retour','duree_trip (min)','vitesse_moy_trip (km/h)', 'AngleVolant_mean' ...
        'Sections','timecodeStart','timecodeEnd', 'durée_section (s)','Vitesse Moy','Vitesse StdDev','AngleVolant Moy','AngleVolant StdDev', ...
        'Pos Voie Moy','Pos Voie StdDev','Nbre Changement Voie','Changement Voie Droite','Changement Voie Gauche','Nbre Event 1','Nbre Event 2'};
    
    xls_column = 1;
    xls_ligne =1;
    num_sujet=1;
    range=length(nom_columns);
    
    xls_filename =(['Atlas_Route_agregated_data_log_' date '.xlsx']);
    
    
    %% Creation de la date dans le fichier de log et de l'entête des données aggrégées 
    xlswrite(xls_filename, {'Data log date : '},xls_range(1,1,1,1));
    xlswrite(xls_filename,{date},xls_range(2,1,1,1));
    xls_ligne =xls_ligne + 3;
    
    xlswrite(xls_filename,nom_columns,xls_range(1,xls_ligne,range,1));
    xls_ligne =xls_ligne + 1;
    
    for indice_trip=1:1:length(trips_list)
        trip_file = trips_list{indice_trip};
        disp(['Le trip ' trips_list{indice_trip} ' est en cours de traitement ...']);
        trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, true);
        
        %% Nom du sujet - Aller/retour
        Attribut_nom_sujet=trip.getAttribute('nomSujet');
        if ~isempty(regexpi(Attribut_nom_sujet , 'aller'))
            
            nom_sujet = Attribut_nom_sujet(1:(regexpi(Attribut_nom_sujet , 'aller')-2));
            A_R = 'aller';
        
        elseif ~isempty(regexpi(Attribut_nom_sujet , 'retour'))
            nom_sujet = Attribut_nom_sujet(1:(regexpi(Attribut_nom_sujet , 'retour')-2));
            A_R = 'retour';
            
        else           
            nom_sujet = Attribut_nom_sujet;
            A_R = 'non specifie';
        end
        
        %% Trips Atrributes

        try    
            duree_trip = str2double(trip.getAttribute('duree_trip'));
            vitesse_moy_trip =str2double(trip.getAttribute('v_moy_trip'));
            steering_moy_trip =str2double(trip.getAttribute('steering_moy_trip'));
        catch ME
            duree_trip = 'Non renseigné dans le trip ';
            vitesse_moy_trip = 'Non renseigné dans le trip ';
            steering_moy_trip = 'Non renseigné dans le trip ';
            
            warndlg(['Certains attributs du trip  '' ' Attribut_nom_sujet '_' A_R ' '' ne sont pas renseignés'])
            
        end
        
        %% Sections
        
        record_situation=trip.getAllSituationOccurences('double tache');
        section_list = record_situation.getVariableValues('Nom');
        vitesse_moy= record_situation.getVariableValues('Vitesse_moy');
        vitesse_stddev= record_situation.getVariableValues('Vitesse_stddev');
        
        angle_volant_moy = record_situation.getVariableValues('AngleVolant_moy');
        angle_volant_sdt = record_situation.getVariableValues('AngleVolant_std');
        PosVoie_moy = record_situation.getVariableValues('PositionVoie_moy');
        PosVoie_std = record_situation.getVariableValues('PositionVoie_stddev');
        N_laneChange = record_situation.getVariableValues('N_LineChange');  
        N_laneChange_r = record_situation.getVariableValues('N_LineChange_D');
        N_LaneChange_l = record_situation.getVariableValues('N_LineChange_G');
        
        NbreEvent1= record_situation.getVariableValues('NbreEvent1');
        NbreEvent2= record_situation.getVariableValues('NbreEvent2');
        
        timecode_debut = record_situation.getVariableValues('startTimecode');
        timecode_fin = record_situation.getVariableValues('endTimecode');
        duree =num2cell( (cell2mat(timecode_fin) - cell2mat(timecode_debut)));
            
        
        
            nbre_ligne = length(timecode_debut);           
            n_sujet_cell=cell(1,nbre_ligne);
            nom_sujet_cell=cell(1,nbre_ligne);
            A_R_cell=cell(1,nbre_ligne);
            duree_trip_cell =cell(1,nbre_ligne);
            vitesse_moy_trip_cell =cell(1,nbre_ligne);
            steering_moy_trip_cell =cell(1,nbre_ligne);
            for jj=1:1:nbre_ligne 
                % formatage timecode
                timecode_debut{jj} = video_seconds2time(timecode_debut{jj});
                timecode_fin{jj} = video_seconds2time(timecode_fin{jj});
                
                %creation des autres cell array
                n_sujet_cell{jj} = num_sujet;
                nom_sujet_cell{jj} = nom_sujet;
                A_R_cell{jj} = A_R;
                
                duree_trip_cell{jj} = duree_trip;
                vitesse_moy_trip_cell{jj} = vitesse_moy_trip;
                steering_moy_trip_cell{jj} = steering_moy_trip;
                
            end
  
        data2write=[n_sujet_cell ; nom_sujet_cell ; A_R_cell ; duree_trip_cell ; vitesse_moy_trip_cell ; steering_moy_trip_cell; ...
            section_list ; timecode_debut ; timecode_fin ; duree ; vitesse_moy ; vitesse_stddev ; ...
            angle_volant_moy ; angle_volant_sdt ; PosVoie_moy ; PosVoie_std ; N_laneChange ; N_laneChange_r ; N_LaneChange_l ; ...
            NbreEvent1 ; NbreEvent2 ]';
        
        %% Formatage des données à écrire de le xls
        Precision =3; % nbre de chiffre après la virgule pour les numériques
        for kk=1:1:length(data2write)
            if isnumeric(data2write{1,kk})
                 A=num2cell(round(10^(Precision)*[data2write{:,kk}])/10^(Precision));
                 data2write(:,kk) =A';
            end
        end
        
        xlswrite(xls_filename,data2write,xls_range(1,xls_ligne,range,nbre_ligne));
  
        delete(trip)
        
        % Réinitialisation/Incrément des compteurs
        num_situation=1;
        xls_ligne = xls_ligne + nbre_ligne;
        
        if strcmp(A_R,'retour')
        num_sujet=num_sujet+1;
        end
        
    end

end 



%% video_time_string
% reverse fonction of "video_time2secdonds"

% function video_time_string = video_seconds2time(time_sec)
% sec = floor(time_sec);
% 
% millisec =time_sec-sec;
% frame = floor((millisec)/0.04);
% 
% hours = floor(sec / 3600);
% minutes = floor((sec - 3600 * hours)/60);
% seconds = sec - 3600 * hours - 60 * minutes ;
% 
% video_time_string = sprintf('%02d:%02d:%02d:%02d',hours,minutes,seconds,frame);
% end


%% Returns an xls range string 
function xls_range_str = xls_range(column_start,ligne,nbre_column,nbre_ligne)

xls_column_list={'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z' ...
    'AA' 'AB' 'AC' 'AD' 'AE' 'AF' 'AG' 'AH' 'AI' 'AJ' 'AK' 'AL' 'AM' 'AN' 'AO' 'AP' 'AQ' 'AR' 'AS' 'AT' 'AU' 'AV' 'AW' 'AX' 'AY' 'AZ' ...
    'BA' 'BB' 'BC' 'BD' 'BE' 'BF' 'BG' 'BH' 'BI' 'BJ' 'BK' 'BL' 'BM' 'BN' 'BO' 'BP' 'BQ' 'BR' 'BS' 'BT' 'BU' 'BV' 'BW' 'BX' 'BY' 'BZ' ...
    'CA' 'CB' 'CC' 'CD' 'CE' 'CF' 'CG' 'CH' 'CI' 'CJ' 'CK' 'CL' 'CM' 'CN' 'CO' 'CP' 'CQ' 'CR' 'CS' 'CT' 'CU' 'CV' 'CW' 'CX' 'CY' 'CZ' ...
    'DA' 'DB' 'DC' 'DD' 'DE' 'DF' 'DG' 'DH' 'DI' 'DJ' 'DK' 'DL' 'DM' 'DN' 'DO' 'DP' 'DQ' 'DR' 'DS' 'DT' 'DU' 'DV' 'DW' 'DX' 'DY' 'DZ' ...
    'EA' 'EB' 'EC' 'ED' 'EE' 'EF' 'EG' 'EH' 'EI' 'EJ' 'EK' 'EL' 'EM' 'EN' 'EO' 'EP' 'EQ' 'ER' 'ES' 'ET' 'EU' 'EV' 'EW' 'EX' 'EY' 'EZ' ...
    'FA' 'FB' 'FC' 'FD' 'FE' 'FF' 'FG' 'FH' 'FI' 'FJ' 'FK' 'FL' 'FM' 'FN' 'FO' 'FP' 'FQ' 'FR' 'FS' 'FT' 'FU' 'FV' 'FW' 'FX' 'FY' 'FZ' ...
    'GA' 'GB' 'GC' 'GD' 'GE' 'GF' 'GG' 'GH' 'GI' 'GJ' 'GK' 'GL' 'GM' 'GN' 'GO' 'GP' 'GQ' 'GR' 'GS' 'GT' 'GU' 'GV' 'GW' 'GX' 'GY' 'GZ'};

xls_range_str = [ xls_column_list{column_start} num2str(ligne)  ':'  xls_column_list{column_start+nbre_column-1}  num2str(ligne+nbre_ligne-1)];

end

