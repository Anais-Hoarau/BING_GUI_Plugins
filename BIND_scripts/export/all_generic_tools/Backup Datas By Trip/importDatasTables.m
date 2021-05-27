%% import_EventandSituationTables
%
% This fonction allows to recreated the Event and Situation tables that
% have been saved with the export "export_EventandSituationTables" function.
% This script checks if the table already exist, in this case nothing
% is done, if not it creates the tables and import the data of the
% corresponding text file.
%
% Inputs :
%
% full_directory, path where the trip and the text files are located
%
% Outputs :
%
% no outputs, it updates the trip contained in the folder if necessary

function import_EventandSituationTables(full_directory)



%% Recherches des fichiers .txt et .trip
% Cherche les fichiers textes issus d'un export (contenant 'table_Event' ou
% 'table_Situation' et le trip

listing_files =dir(full_directory);
i_Event=1;
i_Situation=1;
i_Trip=1;
for i=1:1:length(listing_files)
    if listing_files(i).isdir
        if ~isempty(strfind(listing_files(i).name, 'Backup_EventandSituationTables'))
            saved_dir_name = listing_files(i).name;
            saved_dir = fullfile(full_directory,listing_files(i).name);
            
        end
    else
        files_dir = fullfile(full_directory,listing_files(i).name);
        [~,file_name,file_ext] = fileparts(files_dir);
        if strcmp(file_ext,'.trip')
            trip_name{i_Trip} = file_name; %#ok
            trip_file{i_Trip} = files_dir ; %#ok
            i_Trip=i_Trip+1;
        end       
    end
end

listing_savedfiles =dir(saved_dir);

%% Vérification présence trip & correspondance entre trip et fichier de backup
% Vérifie si on a bien trouver un trip et un seul trip
if isempty(trip_file)
    errordlg('There is no .trip file in the currently processed folder','File Error')
    return
elseif  length(trip_file)>1
    errordlg('There are several trip files in the currently processed folder','File Error')
    return
else
    trip_name=trip_name{1};
    trip_file=trip_file{1};
    if isempty(strfind(saved_dir_name,trip_name))
        errordlg(['There is a mismatch between the saved folder name : ''' saved_dir_name ''' and the processed trip name ''' trip_name '''. Verify different files before processing'],'File Error')
    else
        disp(['Processing trip : ' trip_name '.trip'])
    end
    
end

for i=1:1:length(listing_savedfiles)
   
    if ~listing_savedfiles(i).isdir   
        files_saveddir = fullfile(saved_dir,listing_savedfiles(i).name);
        [~,file_name,file_ext] = fileparts(files_saveddir);

        if strcmp(file_ext,'.txt')
            if  ~isempty(strfind(file_name,'table_Event'))
                Event_files_list{i_Event} = files_saveddir; %#ok
                Event_name_list{i_Event} = file_name ; %#ok
                i_Event=i_Event+1;

            elseif ~isempty(strfind(file_name,'table_Situation'))
                Situation_files_list{i_Situation} = files_saveddir; %#ok
                Situation_name_list{i_Situation} = file_name ; %#ok
                i_Situation=i_Situation+1;
            else
            end
        end
    end
end



% Verifie que les préfixes de fichiers .txt correspondent au trip présent
% dans le dossier
Event_tables=cell(1,length(Event_files_list));
for i=1:1:length(Event_files_list)
    idx = strfind(Event_name_list{i},'table_Event');
    Event_trip = Event_name_list{i}(1:idx-2);
    Event_tables{i}=Event_name_list{i}(idx+length('table_Event')+1:end);
    
    if ~strcmp(Event_trip,trip_name)
        errordlg(['The ''trip_name'' of the .txt backup file : ''' Event_name_list{i} ...
            ''' is not matching the trip found the processing folder : ' trip_name '.trip'])
        return
    end
    
end

Situation_tables=cell(1,length(Situation_files_list));
for i=1:1:length(Situation_files_list)
    idx = strfind(Situation_name_list{i},'table_Situation');
    Situation_trip =Situation_name_list{i}(1:idx-2);
    Situation_tables{i}=Situation_name_list{i}(idx+length('table_Situation')+1:end);
    if ~strcmp(Situation_trip,trip_name)
        errordlg(['The ''trip_name'' of the .txt backup file : ''' Situation_name_list{i} ...
            ''' is not matching the trip found the processing folder : ' trip_name '.trip'])
        return
    end
end

%% Traitement des fichiers

trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, true);

% Recupération des metas informations
    Metas = trip.getMetaInformations;
    
% Création des tables d'Event
for i=1:1:length(Event_tables)

    if ~Metas.existEvent(Event_tables{i})
     
        fileID = fopen(Event_files_list{i});
        [Variable_names,format,BIND_format]=getHeaderandFormat(fileID);
        fclose(fileID);
        
        fileID = fopen(Event_files_list{i});
        data2write = textscan(fileID,format,'delimiter','\t','HeaderLines',1);
        fclose(fileID);
        
        
        newMetaEvent = fr.lescot.bind.data.MetaEvent;
        newMetaEvent.setName(Event_tables{i});
        
        var=cell(1,length(Variable_names));
        for ii=1:1:length(Variable_names)
        var{ii} =fr.lescot.bind.data.MetaEventVariable();
        var{ii}.setName(Variable_names{ii});
        var{ii}.setType(BIND_format{ii});    
        end       
        % set the metaSituationVariables in the metaSituation
        newMetaEvent.setVariables(var);
        % add the metaSituation to the trip
        trip.addEvent(newMetaEvent);
         
        
        
        for iii=1:1:(length(data2write)-1)            
            if strcmp(BIND_format(iii+1),'REAL')
                EventDataPair = num2cell(data2write{iii+1});
            elseif strcmp(BIND_format(iii+1),'TEXT')
                EventDataPair = data2write{iii+1};
            end
        trip.setBatchOfTimeEventVariablePairs(Event_tables{i},Variable_names{iii+1},[num2cell(data2write{1})  EventDataPair]');
        end
        trip.setIsBaseEvent(Event_tables{i},false);
        
    end

end


% Creations des tables de situations
for i=1:1:length(Situation_tables)

    if ~Metas.existSituation(Situation_tables{i})
     
        fileID = fopen(Situation_files_list{i});
        [Variable_names,format,BIND_format]=getHeaderandFormat(fileID);
        fclose(fileID);
        
        fileID = fopen(Situation_files_list{i});
        data2write = textscan(fileID,format,'delimiter','\t','HeaderLines',1);
        fclose(fileID);
        
        
        newMetaSituation = fr.lescot.bind.data.MetaSituation;
        newMetaSituation.setName(Situation_tables{i});
        
        var=cell(1,length(Variable_names));
        for ii=1:1:length(Variable_names)
        var{ii} =fr.lescot.bind.data.MetaSituationVariable();
        var{ii}.setName(Variable_names{ii});
        var{ii}.setType(BIND_format{ii});    
        end       
        % set the metaSituationVariables in the metaSituation
        newMetaSituation.setVariables(var);
        % add the metaSituation to the trip
        trip.addSituation(newMetaSituation);
        
        for iii=1:1:(length(data2write)-2)
            
            if strcmp(BIND_format(iii+2),'REAL')
                SituationDataTriplet = num2cell(data2write{iii+2});
            elseif strcmp(BIND_format(iii+2),'TEXT')
                SituationDataTriplet = data2write{iii+2};          
            end
            
        trip.setBatchOfTimeSituationVariableTriplets(Situation_tables{i},Variable_names{iii+2},[num2cell(data2write{1}) num2cell(data2write{2})  SituationDataTriplet]');
        end
        
        trip.setIsBaseSituation(Situation_tables{i},false);
        
    end

end

delete(trip)


end


%% Sous fonction qui permet de récupérer les headers des fichiers texte de sauvergarde
% Elle retourne : 1. le nom des variables ; 2. un chaine de caractère de
% format utilisée pour le texscan ; 3. un cell ray de format pour
% l'écriture des données dans BIND

function [Variables_names,format,BIND_format]=getHeaderandFormat(fileID)
title_line = fgetl(fileID);
first_line = fgetl(fileID);

Variables = textscan(title_line,'%s ','delimiter','\t','MultipleDelimsAsOne',0);
Variables_names =strtok(Variables{1}); %FIXME permet de suprimer l'espace de fin // A vérifier 

Variables = textscan(first_line,'%s','delimiter','\t');
Variables_format =Variables{1};
format='';
BIND_format=cell(1,length(Variables_format));

    for ii=1:1:length(Variables_format)
        if isempty(str2num(Variables_format{ii})) %#ok<ST2NM>
            format = [format '%s '];%#ok
            BIND_format{ii}='TEXT';
        else
            num=str2num(Variables_format{ii}); %#ok<ST2NM>
            if (num == floor(num))
                format = [format '%d '];%#ok
            else
                format = [format '%f '];%#ok
            end
            BIND_format{ii}='REAL';
        end
    end
end


