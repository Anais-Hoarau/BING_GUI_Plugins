% Ce script import les donn�es Kvaser-ARS fourni par les capteurs Continental dans le trip. Ces donn�es sont filtr�es avant importation gr�ce au script : "filtrage_struct_kvaser_ARS"
% Dans le trip, chacune des variables est une chaine de caract�re contenant N valeurs (s�prar�es par des espaces), N �tant le nombre de cible conserv�es apr�s filtrage.
%
% La structure projet (atlas, safemove, ... g�n�r�e lors de l'import des donn�es dans le trip) contenant les donn�es CAN doit se trouver dans le
% m�me dossier que le trip pour l'import de type batch.

% inputs : 
%  trips_folder : dossier de t�te dans lequel se trouve tous les trips. L'ensemble des trips contenus dans les sous-dossiers seront trait�s.
%  
%  import_type ('batch'|'selection'|'other') : est un string qui permet de configurer le type d'import
%  - 'batch' : va chercher les fichiers .mat dans le m�me dossier que le trip et cherche si il existe un champ kvaser dans l'une d'elle et l'importe le cas �ch�ant. 
%  - 'selection' : ouvre une boite de dialogue qui permet de s�lectionner la structure projet. Trouve automatique le champ kvaser et importe la structure
%  - 'other' : permet � l'utilisateur avanc� d'ajouter son propore code (pour optimiser le temps de traitement par exemple)

function import_data_radar_batch(trips_folder,import_type)

trips_list = dirrec(trips_folder, '.trip');
N_trips = length(trips_list);

for i_trips= 1:1:N_trips

   trip_file = trips_list{i_trips};
   [folder,trip_name,~]=fileparts(trip_file);
   
   if ~strcmp(import_type,'batch') && ~strcmp(import_type,'selection') && ~strcmp(import_type,'other')
       import_type = 'selection';
   end
   
   struct_kvaser_found =false;
   %% Recherche et Chargement de la structure qui a servi � l'import des donn�es dans le trip
   current_folder = pwd;
   cd(folder);
       switch import_type
           case 'batch'
               listing = dir('*.mat');
               for i_listing=1:1:length(listing)
                   S=load(listing(i_listing).name);
                   [struct_kvaser_found,struct_kvaser]=SearchKvaserStruct(S);
                   if struct_kvaser_found
                       mat_file = fullfile(folder,listing(i_listing).name);
                       break;
                   elseif i_listing == length(listing)
                       warndlg('Aucun des fichiers .mat pr�sents dans le dossier du trip ne correspondent � la structure projet attentue. Fin de l''import.')
                   end
               end
           case 'selection'
               mat_file = uigetfile('*.mat',['S�lectionner la structure projet contenant les donn�es CAN relatives au trip : ' trip_name]);
               if mat_file == 0
                   warndlg('Aucun fichier s�lectionn�. Fin de la proc�dure d''import.')
                   return;
               end
               mat_file =fullfile(folder,mat_file);
               S=load(mat_file);
               [struct_kvaser_found,struct_kvaser]=SearchKvaserStruct(S);
               if ~struct_kvaser_found
                   warndlg('La structure s�lectionn�e n''est pas la structure projet attendue. Fin de l''import.')
                   return;
               end
           case 'other'
               % Int�grer ici le code utilisateur permettant de s�lection la structure projet
       end
   
   if ~struct_kvaser_found
       return;
   end
       
   cd(current_folder);
   clear S
   
   display(['La structure ' mat_file ' va �tre import� dans le trip.'])
   
   %% Processing de la structure  
   [struct_kvaser_filtree] = filtrage_struct_kvaser_ARS(struct_kvaser);
   
   %% Import des donn�es dans le trip. L'import a lieu seulement si aucune table ARS n'est pr�sente dans le trip
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, true);

    Metas = trip.getMetaInformations;
    if ~Metas.existData('Kvaser_ARS')
        import_data_struct_in_bind_trip(struct_kvaser_filtree,trip,'Kvaser');
    else
        display('Une table Kvaser_ARS est d�j� pr�sente dans le trip. Import des donn�es interrompu.')
    end
    
    %% Toujours effacer le trip, toujours ... 
    delete(trip)
end

end


function [struct_kvaser_found,struct_kvaser]=SearchKvaserStruct(S)
    struct_kvaser_found =false;
    struct_kvaser =struct;
    N_fields =1;
    
    while ~struct_kvaser_found && N_fields==1
        structure_fields=fieldnames(S);
        N_fields = length(structure_fields);
        for i=1:1:N_fields
            if strcmp(structure_fields{i},'kvaser')
                struct_kvaser_found =true;
                struct_kvaser = S.kvaser;
                return;
            end
        end
        structure_name = structure_fields{1};
        S = S.(structure_name);
        if ~isstruct(S)
            return;
        end
    end


end