MAIN_FOLDER = '\\vrlescot\THESE_GUILLAUME\VORTEX\Data\TESTS';
CONFIG_FOLDER = [MAIN_FOLDER '\~FICHIERS_CONFIG'];

folders_list = dir([MAIN_FOLDER '/**/*.acq']);

for i = 2
    % check folder and create full directory by group
    if ~contains(folders_list(i).folder, '~')
        full_directory = folders_list(i).folder;
        groupe_id = '';
    else
        disp(['"' folders_list(i).folder '" ne sera pas pris en compte : dossier ignoré.'])
        continue
    end
    
    trip_name = [folders_list(i).name(1:end-4) '.trip'];
    trip_file = [full_directory filesep trip_name];
    
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    
    record_triggerStop = cell2mat(trip.getAllDataOccurences('MP150_data').getVariableValues('triggerStop'));
    record_triggerStop_timecode = cell2mat(trip.getAllDataOccurences('MP150_data').getVariableValues('timecode'));
    record_comments = trip.getAllDataOccurences('variables_simulateur').getVariableValues('commentaires');
    record_comments_timecode = cell2mat(trip.getAllDataOccurences('variables_simulateur').getVariableValues('timecode'));
    comments_bool = contains(record_comments, 'feu_stop_on');
        
    plot(record_comments_timecode, comments_bool, record_triggerStop_timecode, record_triggerStop)
    legend('comments', 'trigger'); 
    legend('show');
    
end