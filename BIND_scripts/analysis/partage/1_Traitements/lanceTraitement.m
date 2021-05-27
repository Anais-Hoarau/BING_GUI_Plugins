function lanceTraitement (trip_file)

message=sprintf('Processing file: %s...',trip_file);
disp(message);
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file,0.04,false);

% % Cr�ation du KML correspondant au trac� 
% % du sujet sur le  parcours
createKML_Parcours(trip_file);
disp('KML for whole trip created !');

% Cr�ation des events de Topages r�alis�s durant l'experimentation
Part_FindTop(trip_file);
disp('Top Events created !');

% % Cr�ation du KML correspondant a ces Top
createKML_Top(trip_file);
disp('KML for Top location created !');

% Cr�ation des events de passage � proximit� des POI 
% d'entr�e/sortie de virages
Part_FindPOI(trip_file);
disp('POI reaching Events  created!');

% % Cr�ation du KML correspondant aux POI 
createKML_POIFound(trip_file);
disp('KML for POI Found created!');

% % Creation des situations Virages
Part1_CreateSituationsVirages(trip);
disp('Situations Virages created!');

% % Creations des situations Commandes
Part2_CreateSituationsCommandes(trip);
disp('Situations Commandes created!');

%% Cr�ations des events
Part3_CreateEventsOnTrip(trip)
disp('Events created!');

%guess gearbox position
guess_gearbox_position(trip);

%create gearbox situation
create_gearbox_situations(trip);

% % clot�re du trip
delete(trip);
disp('whole post-treatment done in');
toc

end





