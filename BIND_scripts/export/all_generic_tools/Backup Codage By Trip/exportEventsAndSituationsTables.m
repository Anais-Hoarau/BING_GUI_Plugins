%% exportEventsAndSituationsTables
%
%This function exports the Event and Situation tables of a trip to text files. This
%gives the possibility to backup the coding work done on each trip. This
%function goes together with the function 'importEventAndSituationTables'
%which recreates the SQLite tables in the trip with the backup text files. The export
%function has a batch behavior whereas the import function is specific to a
%folder
%
% Inputs :
% directory in which the trips are located. The scripts search recursively all trips in folder and subfolders.
% The text files will be created in the folder containing the trip.
%
% Outputs :
% no output, it creates however the text files
% the fulldirectory containing the processed trip


function exportEventsAndSituationsTables(fulldirectory)

if ~exist('fulldirectory', 'var')
    fulldirectory = uigetdir;
end

trip_list = dirrec(fulldirectory,'.trip');

for i_trip=1:1:length(trip_list)
    
    [trip_dir,trip_name,~]=fileparts(trip_list{i_trip});
    
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_list{i_trip}, 0.04, true);
    
    disp(['Processing trip : ' trip_name])
    
    mkdir(trip_dir,['Backup_EventandSituationTables_' trip_name '_' date])
    save_dir = fullfile(trip_dir,['Backup_EventandSituationTables_' trip_name '_' date]);
    
    
    Metas = trip.getMetaInformations;
    
    Event_list = Metas.getEventsNamesList;
    N_Event = length(Event_list);
    
    Situation_list =  Metas.getSituationsNamesList;
    N_situation = length(Situation_list);
    
    % Export des tables Events
    
    for i=1:1:N_Event
        record = trip.getAllEventOccurences(Event_list{i});
        
        if ~record.isEmpty
            
            filename = fullfile(save_dir,[trip_name '_table_Event_' Event_list{i} '.txt']);
            fid = fopen(filename, 'w');
            
            % Creation du tableau de nom de variable
            meta_Event_variables =Metas.getMetaEvent(Event_list{i}).getVariablesAndFrameworkVariables;
            Variables_Names = cell(length(meta_Event_variables),1);
            
            for ii=1:1:length(meta_Event_variables)
                Variables_Names{ii} = meta_Event_variables{ii}.getName;
            end
            
            % Creation de data2write
            N_columns = length(Variables_Names);
            N_rows = length(record.getVariableValues(Variables_Names{1}));
            data2write = cell(N_rows,N_columns);
            format ='';
            format_title = '';
            
            for columns=1:1:N_columns
                % Creation du format
                format_title = [format_title  '%s \t']; %#ok
                data = record.getVariableValues(Variables_Names{columns});
                if all(ischar(data{1}))
                    format =[format '%s \t']; %#ok
                    
                elseif all(cell2mat(data) == floor(cell2mat(data)))
                    format =[format '%d \t']; %#ok
                    
                else
                    format =[format '%f \t']; %#ok
                    
                end
                
                data2write(:,columns) = record.getVariableValues(Variables_Names{columns});
            end
            format_title =[format_title '\r\n']; %#ok
            format =[format '\r\n']; %#ok
            
            
            % Creation ligne de titre & Remplissage du fichier
            fprintf(fid, format_title, Variables_Names{:});
            
            for rows=1:1:N_rows
                fprintf(fid, format, data2write{rows,:});
            end
            fclose(fid);       
        end
    end
    
    
    
    % Export des tables situations
    for i=1:1:N_situation
        record = trip.getAllSituationOccurences(Situation_list{i});
        
        if ~record.isEmpty
            
            filename = fullfile(save_dir,[trip_name '_table_Situation_' Situation_list{i} '.txt']);
            fid = fopen(filename, 'w');
            
            % Creation du tableau de titre
            meta_Situation_variables =Metas.getMetaSituation(Situation_list{i}).getVariablesAndFrameworkVariables;
            Variables_Names = cell(size(meta_Situation_variables));
            
            for ii=1:1:length(meta_Situation_variables)
                Variables_Names{ii} = meta_Situation_variables{ii}.getName ;
            end
            
            % Remplissage table
            N_columns = length(Variables_Names);
            N_rows = length(record.getVariableValues(Variables_Names{1}));
            data2write = cell(N_rows,N_columns);
            format ='';
            format_title = '';
            
            for columns=1:1:N_columns
                % Creation du format
                format_title = [format_title  '%s \t']; %#ok
                data = record.getVariableValues(Variables_Names{columns});
                if iscellstr(data)
                    format =[format '%s \t']; %#ok
                    
                elseif all(cell2mat(data) == floor(cell2mat(data)))
                    format =[format '%d \t']; %#ok
                    
                else
                    format =[format '%f \t']; %#ok
                    
                end
                
                data2write(:,columns) = record.getVariableValues(Variables_Names{columns});
            end
            format_title =[format_title '\r\n']; %#ok
            format =[format '\r\n']; %#ok
            
            % Creation ligne de titre & Remplissage du fichier
            fprintf(fid, format_title, Variables_Names{:});
            for rows=1:1:N_rows
                fprintf(fid, format, data2write{rows,:});
            end
            fclose(fid);     
        end
    end
    delete(trip)
end

end