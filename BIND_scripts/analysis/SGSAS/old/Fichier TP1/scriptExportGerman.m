% get the directory
data_dir = uigetdir;
% set the selected directory as the current directory (and save the current
% dir)
previous_path = pwd;
cd(data_dir);
listing_trips = dir('*.trip');

% open a file
output_file = fopen('ExportGerman.csv', 'a+');
% write the headers
fprintf(output_file, '%s\t%s\n', 'Sujet', 'Vitesse moyenne (m/s)');
 
% for all trips in this directory
for i=1:length(listing_trips)
    chemin_trip = listing_trips(i).name;
    % on ouvre un fichier trip
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(chemin_trip,0.04,false);

    % On enregistre la valeur de la vitesse en m/s dans une variable globale du
    % trip
    str_vitesse_moyenne = trip.getAttribute('VitesseMoyenne');
    
    % write the info
    fprintf(output_file, '%s\t%s\n', chemin_trip, str_vitesse_moyenne);

    % On ferme le trip (penser à bien fermer le trip systématiquement !!! pour
    % éviter des messages d'erreur après)
    delete(trip);
end

% close the file
fclose(output_file);

% go back to previous path
cd(previous_path);