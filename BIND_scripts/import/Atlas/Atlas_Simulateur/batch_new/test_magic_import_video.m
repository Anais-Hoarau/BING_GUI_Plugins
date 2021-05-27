function out = test_magic_import_video(trip,path_trip_dir)

    disp('Looking for the video file...');
    video_files = find_file_with_extension(path_trip_dir,'.mpg');
    if length(video_files) < 1
        % Pas de fichier VAR
        out = 'No file';
        disp('No var file found');
    elseif length(video_files) > 1
        % Plusieurs fichiers VAR
        out = [num2str(length(video_files)) ' files'];
        disp([num2str(length(video_files))  'var files found']);
    else
        % Si un seul VAR, converti le TRIP
        video_path = video_files{1};
        disp('video file found');

        disp('adding the video to the trip file');
        [~, video_name, video_ext] = fileparts(video_path);
        video_file = ['.' filesep video_name video_ext];
        metaVideo = fr.lescot.bind.data.MetaVideoFile(video_file,0,'quadra');
        trip.addVideoFile(metaVideo);

        % LOG: trip OK
        out = 'Ok';
        disp('video added to the trip!');
                        
end