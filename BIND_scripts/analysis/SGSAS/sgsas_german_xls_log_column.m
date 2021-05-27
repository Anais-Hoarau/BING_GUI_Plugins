function sgsas_german_xls_log_column()

    %% répertoires de travail
    
    groupe='NEUTRAL';
    trips_folder= ['D:\LESCOT\PROJETS\SGSAS\DATA_GERMAN\' groupe];

    trips_list = dir( [trips_folder '\*.trip']);
    
  

    %% constantes
    
    nom_columns_base = {'n° sujet'};
    nom_sections = {'Stim1','Stim2','Stim3','Stim4','Stim5','Stim6','Stim7','Stim8','Stim9','Stim10','Stim11','Stim12','Stim13','Stim14','Stim15','Stim16','Stim17','Stim18'};
    nom_variables = {'Nom';'Duree (s)';'Vitesse_moy (km/h)';'%AppuiAcc_moy';'%AppuiFrein_moy';'%AppuiEmbr_moy';'AppuiAcc_%duree';'AppuiFrein_%duree';'AppuiEmbr_%duree'; ...
                     'PositionVoie_std';'AngleVolant_std';'pk';'route';'sens'};
    
    
    % Variables à remplir
%     Names = {'Nom';'Duree';'Vitesse_moy';'%AppuiAcc_moy';'%AppuiFrein_moy';'%AppuiEmbr_moy';'AppuiAcc_%duree';'AppuiFrein_%duree';'AppuiEmbr_%duree'; ...
%                 'PositionVoie_std';'AngleVolant_std';'pk';'route';'sens'};
    
    nom_mix=cell(1,length(nom_sections)*length(nom_variables));
    compteur =1;
    for i_sec =1:1:length(nom_sections) 
        for i_variables =1:1:length(nom_variables)      
            nom_mix{compteur} = [nom_sections{i_sec} '_' nom_variables{i_variables}];
            compteur =compteur+1;
        end
    end  
   clear i_sec
    
    nom_columns = [nom_columns_base nom_mix];
    
    xls_column = 1;
    xls_ligne =1;
    
    range=length(nom_columns);
    
    xls_filename =(['SGSAS_' groupe '_agregated_data_log_GERMAN_' date '.xlsx']);
    
    
    %% Creation de la date dans le fichier de log et de l'entête des données aggrégées 
    xlswrite(xls_filename, {'Data log SGSAS German  '},xls_range(1,1,1,1));
    xlswrite(xls_filename,{[' date : ' date]},xls_range(2,1,1,1));
    xls_ligne =xls_ligne + 3;
    
    xlswrite(xls_filename,nom_columns,1,xls_range(1,xls_ligne,range,1));
    xlswrite(xls_filename,nom_columns,2,xls_range(1,xls_ligne,range,1));
    xls_ligne =xls_ligne + 1;
    
    for indice_trip=1:1:length(trips_list)
        
        nbre_ligne = 1; % nbre de ligne à écrire par trip  
        
        trip_path = fullfile (trips_folder , trips_list(indice_trip).name);
        nom_sujet_temp = trips_list(indice_trip).name;
        nom_sujet = nom_sujet_temp (1:end-5);
        
        disp(['le trip ' nom_sujet ' est en cours de de traitement']);
        
        trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_path, 0.04, true);
                
    
        metas=trip.getMetaInformations;
        Situations_List = metas.getSituationsNamesList;
        
        size_data_situation =zeros(1,2);
        for i_situation=1:1:length(Situations_List)
        record_situation = trip.getAllSituationOccurences(Situations_List{i_situation});
        data = record_situation.buildCellArrayWithVariables(record_situation.getVariableNames);
        data = data(3:end,:);
        
        size_data_situation_temp = size(data);
        
        size_data_situation(1,2) = max(size_data_situation(1,2) , size_data_situation_temp(1,2));
        size_data_situation(1,1) = size_data_situation(1,1) + size_data_situation_temp(1,1);
   
        end    

        
        for i_situation=1:1:length(Situations_List)
            data_situation =cell(0,0);
            record_situation = trip.getAllSituationOccurences(Situations_List{i_situation});
            
            data = record_situation.buildCellArrayWithVariables(record_situation.getVariableNames);
            data = data(3:end,:);
            
            data_situation = [data_situation  data]; %#ok
            
            
            %nom_variables = {'name','vitesse_moy','%PedaleAcc','%PedaleFrein','VarVoie','pk','route','sens'};
            data2write_column ={};
            for i_sec=1:1:size(data_situation,2)
                data2write_column = [data2write_column data_situation(:,i_sec)' ];
            end
            
            data2write=[nom_sujet data2write_column];
            
            %% Formatage des données à écrire de le xls
            Precision =3; % nbre de chiffre après la virgule pour les numériques
            for kk=1:1:length(data2write)
                if isnumeric(data2write{1,kk})
                    A=num2cell(round(10^(Precision)*[data2write{:,kk}])/10^(Precision));
                    data2write(:,kk) =A';
                end
            end
            
            range = size(data2write,2);
            xlswrite(xls_filename,data2write,i_situation,xls_range(1,xls_ligne,range,nbre_ligne));
            
            
        end
        
        delete(trip)

        
        % Réinitialisation/Incrément des compteurs

        xls_ligne = xls_ligne + nbre_ligne;  
        

        
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
alphabet ={'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z'};

xls_column_list_simple = alphabet;
xls_column_list_double = cell(length(alphabet)^2,1);
i_tot=1;
for i_l=1:1:length(alphabet)
    for i_c=1:1:length(alphabet)
    xls_column_list_double{i_tot} = [alphabet{i_l} alphabet{i_c}];
    i_tot =i_tot+1;
    end
end

xls_column_list_double = cell(length(alphabet)^2,1);
i_tot=1;
for i_l=1:1:length(alphabet)
    for i_c=1:1:length(alphabet)
    xls_column_list_double{i_tot} = [alphabet{i_l} alphabet{i_c}];
    i_tot =i_tot+1;
    end
end

xls_column_list_triple = cell(length(alphabet)^3,1);
i_tot=1;
for i_1=1:1:length(alphabet)
    for i_2=1:1:length(alphabet)
        for i_3=1:1:length(alphabet)
            xls_column_list_triple{i_tot} = [alphabet{i_1} alphabet{i_2} alphabet{i_3}];
            i_tot =i_tot+1;
        end
    end
end

%xls_column_list = [xls_column_list_simple' ; xls_column_list_double];
xls_column_list = [xls_column_list_simple' ;  xls_column_list_double ; xls_column_list_triple];

xls_range_str = [ xls_column_list{column_start} num2str(ligne)  ':'  xls_column_list{column_start+nbre_column-1}  num2str(ligne+nbre_ligne-1)];

end


