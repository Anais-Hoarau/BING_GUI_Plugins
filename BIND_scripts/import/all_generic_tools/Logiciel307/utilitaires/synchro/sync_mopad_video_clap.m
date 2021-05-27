%% sync_mopad_video_clap
% This function adds a new timecode column (called time_sync) that
% synchronises the mopad data to the video data through a clap.txt file.
% The clap file defines the timecode (hh:mm:ss:ii) of the video at 3
% moments:
% 1 - when the first synchronisation signal is given (through a LED signal)
% 2 - when the last synchronisation signal is given (through a LED signal)
% 3 - when the video starts
% 
% If the timecode column 'time_sync' already exists, then an exception is
% raised because it means the signal has already been synchronised with
% another source.
%
% In addition, the video file will be looked for and the informations about
% the offset, the file name, etc. will be added in the META field.
% 
% There are several synchronisation methods. By default, the method used to
% synchronise takes the first and the last trigger points related to the
% LED signal (threshold up).
% 
% input argument:
% mopad_struct:     a structure containing the UN-synchronised Mopad data.
%                   (typically, the output of import_mopad_struct funciton)
% full_directory:   location of the folder containing the clap file.
% sync_method:      a String describing the method used:
%                   'first-last':   takes the first LED signal of the trip
%                                   and the last LED signal of the trip.
%                   '3brakes':      takes the first series of 3 consecutive
%                                   brakes (within a short time) and the
%                                   last series of 3 consecutive brakes.
%                   'default':      the same as 'first-last'
% data_name_mopad:  name of the data source containing the synchronisation
%                   signal used for the synchronisation.
% variable_name_mopad : name of the variable (of the data data_name_mopad)
%                   that is the synchronisation signal.
%
% output argument:
% sync_mopad:       a structure containing the synchronised Mopad data.
%

function sync_mopad = sync_mopad_video_clap(mopad_struct,full_directory,sync_method,data_name_mopad,variable_name_mopad)
    

    % check if the META.synchronised field says that the data has been synchronised...
    % if so, there is a problem!
    if isfield(mopad_struct.META,'synchronised') && mopad_struct.META.synchronised
        exception = MException('SyncErr:SyncAlreadyExists', ...
                    ['The source META.synchronised field is set to true. Source is already synchronised.']);
        throw(exception);
    end

    sync_mopad = mopad_struct;

    %% VIDEO FILE
    
    %% Find video file and convert it if required
    % Baware that this function was not comprehensively tested
    sync_mopad = convertVideo2MJPEG(full_directory, sync_mopad);
    
    %% CLAP FILE
    % look for the top_clap_start and top_clap_end in the clap.txt file
    
    patternClap = fullfile(full_directory, 'clap.txt');
    listingClap = dir(patternClap);
    if isempty(listingClap)
        % if no clap.txt were found
        exception = MException('SyncErr:ClapFileMissing', ...
                    'No clap files (clap.txt) were found in the given directory.');
        throw(exception);
    else
        % on lit le fichier de clap
        fid = fopen(patternClap);
        tops = textscan(fid,'%s');
        fclose(fid);
        % read clap file : clap file MUST HAVE 3 lines... timecode du clap de début /
        % timecode du clap de fin / timecode de la premiere image
        if ~isempty(tops{1}{3})
            top_clap_start = video_time2seconds(tops{1}{1});
            top_clap_end = video_time2seconds(tops{1}{2});
            offset_video_file = video_time2seconds(tops{1}{3});
            sync_mopad.META.video_offset = - offset_video_file;
        else
            % Misformed clap.txt file
            exception = MException('SyncErr:ClapFileErr', ...
                        'The clap file is not valid.');
            throw(exception);
        end
    end
        
    %% DATA
    % look for the top_mopad_start and top_mopad_end in the Mopad data
    % according to the selected synchronisation method.
    record = getfield(sync_mopad,data_name_mopad);
    switch sync_method
        case {'first-last' 'default'}
            % find when the first and last moments where the LED signal was
            % triggered
%             disp('WARNING: THIS NEEDS TO BE FIXED.... FIRST TIME THE LIGHT APPEARS')
%             index_mopad_start = find( record.TopCons.values > 0.02,1,'first');
%             index_mopad_end = find( record.TopCons.values > 0.02,1,'last');
%             % get the corresponding time
%             top_mopad_start = record.time.values(index_mopad_start)/1000;
%             top_mopad_end = record.time.values(index_mopad_end)/1000;
            data_struct = getfield(record,variable_name_mopad);
            tc_seuils = cherche_tc_franchissement_seuil(record.time.values,data_struct.values,0.5);
            top_mopad_start = tc_seuils(1,1);
            top_mopad_end = tc_seuils(end,1);
            
        case '3brakes'
            maximum_window_tc = 5000; % 5000 ms seems like a good value to 
                                      % detect the 3 pression on the brake.
            data_struct = getfield(record,variable_name_mopad);
            tops = extract_seuils_frein_intelligent(record.time.values,data_struct.values,maximum_window_tc);
            % begining of the first series of Brake
            top_mopad_start = tops(1).appuis(1,1);
            % begining of the last series of Brake
            top_mopad_end = tops(end).appuis(1,1);
            
        otherwise
            exception = MException('FuncParam:Unknown', ...
                        ['Unknown sync_method: ' sync_method]);
            throw(exception);
    end

    %% OFFSET AND TIME SHIFTING
    % calculate the offset and time shifting by comparing information about
    % the tops found in the clap file and in the mopad data (comparing
    % top_mopad_start and top_mopad_end to top_clap_start and
    % top_clap_end).
    offset_mopad = top_mopad_start/1000 - top_clap_start; %unité 's'
    delta_video = top_clap_end - top_clap_start;
    delta_mopad = (top_mopad_end - top_mopad_start)/1000;
    
    disp(['Temps video = ' num2str(delta_video) 's . Temps Mopad = ' num2str(delta_mopad) 's .']);
    
    if abs( delta_video - delta_mopad ) <= 0.08
        % if the time ellapsed between the two tops from the video
        % timecodes and from the mopad data is less than two images (80 ms)
        % then there is no time shifting (the difference is due to the
        % measurement imprecision)
        derive_mopad = 1;
    else
        % Otherwise, there is a time shifting
        disp('Warning: Time shifting of data detected.');
        disp(['video = ' num2str(delta_video) 's, ' ...
              'mopad = ' num2str(delta_mopad) 's.']);
        disp(['Difference of ' num2str(delta_video - delta_mopad) ...
              ' seconds during this trip.']);
        derive_mopad = delta_video / delta_mopad;
    end
    
    disp(['Offset and Derive between the Video and Mopad are : ' num2str(offset_mopad) ' s and ' num2str(derive_mopad)]);
    
    %% SYNCHRONISATION
    % for each data source (one per mopad .txt file)
    source_names = fieldnames(sync_mopad);
    for i = 1:length(source_names)
        % if it is a data field (not the 'META' field)
        if ~strcmp(source_names{i},'META')
            record = getfield(sync_mopad,source_names{i});
            subnames = fieldnames(record);
            
            % check if 'time_sync' already exists... if so, there is a
            % problem!
            if any(strcmp(subnames,'time_sync'))
                exception = MException('SyncErr:SyncAlreadyExists', ...
                            ['synchronised time already exists in data group ''' source_names{i} '''']);
                throw(exception);
            end
            
            % remove possible timecode = 0
            ind_tcNotEq0 = record.time.values~=0;
            for j = 1:length(subnames)
                data = getfield(record,subnames{j});
                data.values = data.values(ind_tcNotEq0);
                record = setfield(record,subnames{j},data);
            end
            
            %% Bloc formule Sync Sébastian
            
            offset_mopad_derive = (top_mopad_start/1000)*(derive_mopad-1)+offset_mopad; 
            record.time_sync.values =  (record.time.values /1000 * derive_mopad) - offset_mopad_derive ;
  
            record.time_sync.unit = 's';
            record.time_sync.comments = 'Timecode calculated relatively to the timecode of the video.';
            sync_mopad = setfield(sync_mopad,source_names{i},record);
            
            sync_mopad.META.mopad_top_clap_start = top_clap_start;
            sync_mopad.META.mopad_top_clap_stop = top_clap_end;
            sync_mopad.META.mopad_video_offset = offset_mopad;
            sync_mopad.META.mopad_video_shift  = derive_mopad;
            sync_mopad.META.mopad_video_sync_formula = '( (time/1000) * derive ) - top_mopad_start*(derive_mopad-1)+offset_mopad';
            sync_mopad.META.startTC_ref = top_clap_start;
            sync_mopad.META.stopTC_ref = top_clap_end;
            sync_mopad.META.deltaTC_ref = top_clap_end - top_clap_start;
      
            %% Bloc ancienne formule de time sync
            
%             record.time_sync.values = ( (record.time.values/1000) - offset_mopad ) * derive_mopad ;
%             record.time_sync.unit = 's';
%             record.time_sync.comments = 'Timecode calculated relatively to the timecode of the video.';
%             sync_mopad = setfield(sync_mopad,source_names{i},record);
%             
%             disp(['offset_mopad = ' num2str(offset_mopad)]);
%             disp(['derive = ' num2str(derive_mopad)]);
% 
%             disp(['premier timecode = ' num2str(record.time.values(1))]);
%             disp(['premier timecode_sync = ' num2str(record.time_sync.values(1))]);
% 
%             sync_mopad.META.mopad_video_offset = offset_mopad;
%             sync_mopad.META.mopad_video_shift  = derive_mopad;
%             sync_mopad.META.mopad_video_sync_formula = '( (time/1000) - mopad_video_offset ) * mopad_video_shift'; 
            
            
        end
    end
    
    
    sync_mopad.META.synchronised = true;
    
    end

%% video_time2seconds
% this function converts a HH:MM:SS:II video timecode string into the
% equivalent timecode expressed in seconds.
%
% input arguments:
% video_time_string: Video time string (HH:MM:SS:II).
%
% output arguments:
% time_sec:     Corresponding time in seconds

function time_sec = video_time2seconds(video_time_string)
    time = sscanf(video_time_string,'%2d:%2d:%2d:%2d');
    time_sec = time(1)*3600 + time(2)*60 + time(3) + time(4)*0.04;
end

