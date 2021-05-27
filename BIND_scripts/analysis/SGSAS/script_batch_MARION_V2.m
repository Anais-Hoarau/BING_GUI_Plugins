%path_ALL = 'D:\LESCOT\PROJETS\SGSAS\DATA_MARION\ALL';
%path_CURVE = 'D:\LESCOT\PROJETS\SGSAS\DATA_MARION\CURVE';
%path_NEUTRAL = 'D:\LESCOT\PROJETS\SGSAS\DATA_MARION\NEUTRAL';
path_ALL = 'W:\PROJETS ACTUELS\2013- SGSAS\DATA_MARION\ALL';
path_CURVE = 'W:\PROJETS ACTUELS\2013- SGSAS\DATA_MARION\CURVE';
path_NEUTRAL = 'W:\PROJETS ACTUELS\2013- SGSAS\DATA_MARION\NEUTRAL';
%
path_list = [ {path_CURVE} ; {path_ALL} ; {path_NEUTRAL}];

%table NEUTRAL : cette table permet la creation des situations
%Stimulation_All et Stimulation_Curve pour le groupe Neutre
table_Neutral =cell(21,2); % numéro de colonne correspond à n° de particpant || 1ère colonne : TC_debut_fin_all ||2ème colonne : route_pk

for i_path=1:1:length(path_list)
    tic
    listing_trips = dir([path_list{i_path} '\*.trip']);
    
    for i=1:1 %length(listing_trips)
        
        % Fichier traité
        disp(['le trip  ' listing_trips(i).name  ' est en cours de traitement'])
        
        trip_name =listing_trips(i).name;
        res_regexp =regexp(trip_name ,'[0-9]');
        participant_number = str2num(trip_name(1:res_regexp(end)));
        trip_path = fullfile(path_list{i_path} ,listing_trips(i).name);     
        
        %Calcul d'indicateur sur tout le trip
        disp('Calcul des indicateurs globaux')
        Calcul_IndicateursGlobaux(trip_path)
        
        %creer les situations dans le trips
            switch path_list{i_path}
                
                case path_CURVE
                    
                    disp('Case : Curve')
                    disp('Création des situations dans le trip')
                    table_Neutral{participant_number,1} = Creer_situation_Curve(trip_path);
                    
                    
                    
                case path_ALL
                    disp('Case : All')
                    disp('Création des situations dans le trip')
                    table_Neutral{participant_number,2} = Creer_situation_All(trip_path);
                    
                    
                    
               case path_NEUTRAL % cette condition doit s'executer en dernier
                    disp('Case : Neutral')
                    disp('Création des situations dans le trip')
                    Creer_situation_Neutral(trip_path,table_Neutral(participant_number,:));
                    
            end      

        %Enrichir les situations précédement creer
        disp(['Remplissage des situations dans le trip' trip_name]) 
        
        Remplir_Situation(trip_path)
        
        fprintf('\n')
        
    end
    dureeprocess=toc;
    disp(['Fin process - Durée = ' num2str(dureeprocess) 's'])
    
    
end