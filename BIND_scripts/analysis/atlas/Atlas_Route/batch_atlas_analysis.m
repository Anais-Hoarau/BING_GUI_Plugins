function batch_atlas_analysis()

   folder_list = {'E:\PROJETS ACTUELS\ATLAS\Manip Route\DONNEES\MANIPS\S015\ALLER'};
               
% folder_list = {  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S001\ALLER',...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S001\RETOUR',...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S002\ALLER', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S002\RETOUR', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S003\ALLER', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S003\RETOUR',...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S004\ALLER', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S004\RETOUR',...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S005\ALLER', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S005\RETOUR', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S006\ALLER', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S006\RETOUR', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S007\ALLER', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S007\RETOUR',...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S008\ALLER', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S008\RETOUR', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S009\ALLER', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S009\RETOUR', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S010\ALLER', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S010\RETOUR', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S011\ALLER', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S011\RETOUR', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S012\ALLER', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S012\RETOUR', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S013\ALLER', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S013\RETOUR', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S014\ALLER', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S014\RETOUR',...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S015\ALLER', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S015\RETOUR', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S016\ALLER', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S016\RETOUR', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S017\ALLER', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S017\RETOUR', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S018\ALLER', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S018\RETOUR', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S019\ALLER', ...
%                  'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\S019\RETOUR'};
                
    for i = 1:length(folder_list)
   
        files_list = dir(folder_list{i}); 
        
        for ii=1:1:length(files_list)
            if ~files_list(ii).isdir            
                file_path =fullfile(folder_list{i},files_list(ii).name);
                [~,file_name,file_ext]=fileparts(file_path);
                if strcmp(file_ext,'.trip')
                    trip_file= file_path;
                    trip_name = file_name;
                end
                if strcmp(file_ext,'.mat')&& ~isempty(strfind(file_name,'atlas_structure'))
                    mat_file= file_path;
                    mat_name = file_name;
                end
                
            end        
        end
        
        disp(['Le trip ' trip_name ' est en cours de traitement ...']);
        
        trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, true);
        %%Trip processing
        % open the trip (create the trip if it doesn't exist)
         disp('Executing : atlas_TripsAttributes ...'   )    
        [proc_TripsAttributes,  ~, ~]  = magic_process('atlas_TripsAttributes',trip);
        
        disp('Executing : atlas_EventAndSituations_Creation ...')  
        %%Cr?ation des Events et situations
        [proc_Event_and_Situation_Creation_double_tache,  ~, ~]  = magic_process('atlas_EventAndSituations_Creation_double_tache',trip,mat_file);
        [proc_Event_and_Situation_Creation_MindWandering,  ~, ~]  = magic_process('atlas_EventAndSituations_Creation_MindWandering',trip,mat_file);
        
        disp('Executing : atlas_EventAndSituations_Remplissage ...')
        [proc_Event_and_Situation_Remplissage_double_tache,  ~, ~]  = magic_process('atlas_EventAndSituations_Remplissage',trip);
        

        disp('Executing : atlas_DecoupageDataCardiaque ...')
        [proc_DecoupageDataCardiaque,~,~]  = magic_process('atlas_DecoupageDataCardiaque',trip,mat_file);
        
        % clap d?but de manip
        %clap_start =str2double( trip.getAttribute('mopad_top_clap_start'));
        
        delete(trip)
        
        %% Cardiaque data Processing
 
        
        
        
    end
end