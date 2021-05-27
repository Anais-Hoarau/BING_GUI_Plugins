function lanceTraitement (trip_file)

message=sprintf('Processing file: %s...',trip_file);
disp(message);
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file,0.04,false);

% % Création du KML correspondant au tracé 
% % du sujet sur le  parcours
createKML_Parcours(trip_file);
disp('KML for whole trip created !');

% Création des events de Topages réalisés durant l'experimentation
Part_FindTop(trip_file);
disp('Top Events created !');

% % Création du KML correspondant a ces Top
createKML_Top(trip_file);
disp('KML for Top location created !');

% Création des events de passage à proximité des POI 
% d'entrée/sortie de virages
Part_FindPOI(trip_file);
disp('POI reaching Events  created!');

% % Création du KML correspondant aux POI 
createKML_POIFound(trip_file);
disp('KML for POI Found created!');

% % Creation des situations Virages
Part1_CreateSituationsVirages(trip);
disp('Situations Virages created!');

% % Creations des situations Commandes
Part2_CreateSituationsCommandes(trip);
disp('Situations Commandes created!');

%% Créations des events
Part3_CreateEventsOnTrip(trip)
disp('Events created!');

%guess gearbox position
guess_gearbox_position(trip);

%create gearbox situation
create_gearbox_situations(trip);

% % clotûre du trip
delete(trip);
disp('whole post-treatment done in');
toc

end





