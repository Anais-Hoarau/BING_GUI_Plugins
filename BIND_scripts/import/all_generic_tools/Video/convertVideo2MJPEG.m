%% This function is used to find and convert the video files (it keeps only the sequence around the start and stop clap) to be used with the trip. 
% It therefore updates the clap.txt file. It uses the ffmpeg and ffprobe programs. Please make sure that the ffmpeg folder was added to window path
% (environement variable). It also updates the synchronized structure.

% Additiponnal remark : the 'calculate_MJPEG_FrameOffset function' is used to
% calculate the offset due to MJPEG conversion.  

% input arguments:
% full directory : current working folder
% sync_mopad : synchronized structure

% output arguments:
% updated_sync_mopad : updated synchronized structure

function updated_sync_mopad = convertVideo2MJPEG(full_directory , sync_mopad)

updated_sync_mopad = sync_mopad;
find_video = false;

%% ffmpeg options
%startCommand = 'start ffmpeg -v info -y';
startCommand = 'start ffmpeg -v info -y';
input_options = '-i ';
% output_options = '-vcodec mjpeg -q:v 0 -acodec ac3 -b:a 128k';
output_options = '-vcodec: mjpeg -q:v 0 -acodec ac3 -q:a 256k';

%% Look for Video files
    %full_directory = uigetdir(pwd, 'Choisissez le dossier de projet depuis lequel convertir les vid?os');
    avi_pattern = fullfile(full_directory, '*.avi');
    avi_video = dir(avi_pattern);
    mpg_pattern = fullfile(full_directory, '*.mpg');
    mpg_video = dir(mpg_pattern);
    
    if isempty(avi_video) && isempty(mpg_video)
        % if no video were found
        exception = MException('SyncErr:VideoFileMissing', ...
                    'No video files (*.avi) were found in the given directory.');
        throw(exception);  
    elseif ~isempty(avi_video)
        find_video = true;
        avi_video = fullfile(full_directory , avi_video.name );
        video_infos = mmfileinfo(avi_video);
        if strcmp(video_infos.Video.Format , 'MJPG')
            need_conversion = false;
            trip_video_file = avi_video;
        else
            need_conversion = true;
            full_input_file = avi_video;
        end
        
    elseif ~isempty(mpg_video)
        find_video = true;
        need_conversion = true;
        mpg_video = fullfile(full_directory , mpg_video.name );
        full_input_file = mpg_video;
    end

if find_video && need_conversion   
    %% Video files output names
    [folder,file_name,~] = fileparts(full_input_file);
    full_outputfile = [folder filesep file_name '_MJPEG.avi'];
    
    full_input_file = ['"' full_input_file '"'];
    full_outputfile = ['"' full_outputfile '"'];
    
    %% Look for clap file
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
        
        MJPEGconversion_offset = calculate_MJPEG_FrameOffset(full_input_file);
        
        top_clap_start = video_time2seconds(tops{1}{1});
        top_clap_end = video_time2seconds(tops{1}{2});
        offset_video_file = video_time2seconds(tops{1}{3});
        
        start_time = video_time2timecode(max(0 , top_clap_start - offset_video_file + MJPEGconversion_offset - 1),'ffmpeg'); % 1 seconde suppl?mentaire
        total_time = video_time2timecode(top_clap_end - offset_video_file + MJPEGconversion_offset + 6,'ffmpeg'); % 5 secondes pour la dur?e des appuis et 1 seconde suppl?mentaire
        
        % update ffmpeg options
        %input_options = [input_options];
        output_options = [output_options ' -ss ' start_time ' -to ' total_time];
        
        %%Update clap file    
        %copyfile(patternClap,fullfile(full_directory,'clap_beforeMPJEGconversion.txt'))
        fid = fopen(fullfile(full_directory,'clap.txt'),'w');
        tops{1}{3} = video_time2timecode(max(0 , top_clap_start - 5),'bind');
        for i=1:1:length(tops{1})
            fprintf(fid,'%s\n',tops{1}{i});
        end
        fclose(fid);
    end
    
    %% Creating command line
    ffmpeg_command_line = buildCommandLine(startCommand, input_options, full_input_file, output_options, full_outputfile);
    trip_video_file = full_outputfile;
    system(ffmpeg_command_line);
end
%% Filling-up synchro struct
if find_video
        [~,file_name,ext] = fileparts(trip_video_file);
        trip_video_file = [file_name filesep ext];
        updated_sync_mopad.META.video_description = 'quadravision';
        updated_sync_mopad.META.video_path = ['.\' trip_video_file];
end
end


%% calculate_MJPEG_FrameOffset
% This function calculates an offset that used to crop the converted video
% file correctly
%
% input arguments:
% input_video_file: path to the cideo file to convert and crop.
%
% output arguments:
% time_offset: time offset in seconds. Time corresponding to the number of frame reconstructed by ffmpeg before the
% first keyframes (I)
function [time_offset] = calculate_MJPEG_FrameOffset(input_video_file)
ffprobe_command = ['ffprobe -v quiet -read_intervals %+#50 -show_entries frame=media_type,pkt_pts_time,pict_type ' input_video_file];

[~,output]=system(ffprobe_command);
output = strsplit(strtrim(output),'[FRAME]');

find_first_video_frame = false;
find_first_I_frame = false;
i=1;
while ~(find_first_video_frame && find_first_I_frame) && i<length(output)
    % Case of empty output
    if isempty(output{i})
        i=i+1;
        continue
    end
    
    % Split and Reshape the frame attributes
    frame_attributes = strsplit(strtrim(output{i}),{'\n','='});
    frame_attributes = reshape(frame_attributes(1:end-1),2,[])';

    if any(strcmp(frame_attributes(:,2),'video'))
        if ~find_first_video_frame
            first_frame_tc = str2double(frame_attributes(strcmp(frame_attributes(:,1),'pkt_pts_time'),2));
            find_first_video_frame = true;
        end
        
        if any(strcmp(frame_attributes(:,2),'I')) && ~find_first_I_frame
            first_Iframe_tc = str2double(frame_attributes(strcmp(frame_attributes(:,1),'pkt_pts_time'),2));
            break
        end
    end
    i=i+1;
end
time_offset = first_Iframe_tc - first_frame_tc;
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

%% video_time2seconds
% this function converts a time in seconds to a timecode string HH:MM:SS.mmm 
% used for ffmpeg file croping
%
% input arguments:
% time: float (time in seconds).
% option  : 'ffmpeg' or 'bind'
% output arguments:
% timecode_string:     Corresponding timecode (format HH:MM:SS.mmm) for the
% ffmpeg option and (format HH:MM:SS.II) for the bind option
function timecode_string = video_time2timecode(time, option)
mmm = round((time-floor(time))*1000);
II = floor(25 * (mmm/1000));
time = floor(time);

HH = floor(time/3600);
time = time - HH*3600;

MM = floor(time/60);
time = time - MM*60;

SS = time;

    switch option
        case 'ffmpeg'
            timecode_string = sprintf('%02d:%02d:%02d.%03d',HH,MM,SS,mmm);
        case 'bind'
            timecode_string = sprintf('%02d:%02d:%02d:%02d',HH,MM,SS,II);
    end
end



%% buildCommandLine
% this function creates the command line to be used with the system
% function. It formats and separates all input arguments with white spaces
%
% input arguments:
% varargin: variable number of input argument (strings).
%
% output arguments:
% commandLine:     formatted command line

function commandLine = buildCommandLine(varargin)
commandLine = '';    
    for i=1:1:length(varargin)
        tmp = strtrim(varargin{i});
        commandLine = [commandLine tmp ' '];%#ok
    end
end

