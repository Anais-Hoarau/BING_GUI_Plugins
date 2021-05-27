%% This function is used to find and convert the video files (it keeps only the sequence around the start and stop clap) to be used with the trip.
% It therefore updates the clap.txt file. It uses the ffmpeg and ffprobe programs. Please make sure that the ffmpeg folder was added to windows path
% (environement variable). It also updates the synchronized structure.

% Additionnal remark : the 'calculate_MJPEG_FrameOffset function' is used to
% calculate the offset due to MJPEG conversion.

% input arguments:
% full directory : current working folder
% sync_mopad : synchronized structure

% output arguments:
% updated_sync_mopad : updated synchronized structure

function convertVideo2MJPEG_alone_withoutClap_withPath(video_file_path, startTime, endTime, output_file_path)

%updated_sync_mopad = sync_mopad;
find_video = false;
% startTime_formated = ['00:' startTime]; %(1:end-4) '.000'
% endTime_formated = ['00:' endTime]; %(1:end-4) '.000'

%% startTime and endTime for PROSPECT without conflicts
startTime_formated = ['00:' startTime ':000']; %(1:end-4) '.000'
endTime_formated = ['00:' endTime ':000']; %(1:end-4) '.000'
startTime_sec = video_time2seconds(startTime_formated)-10; %add 10 seconds before situation
endTime_sec = video_time2seconds(endTime_formated)+10; %add 10 seconds after situation
startTime_formated = video_time2timecode(max(startTime_sec,0), 'ffmpeg');
endTime_formated = video_time2timecode(endTime_sec, 'ffmpeg');

%% ffmpeg options
startCommand = 'ffmpeg -v info -y';
input_options = ' -i';
cut_options = ['-ss ' startTime_formated ' -to ' endTime_formated];

%% resolution_options = '';

% resolution_options without crop
resolution_options = '-vf scale=1280:720';
% resolution_options = '-vf scale=1920:1080';
% resolution_options = '-vf scale=3840:2160';

% resolution_options with crop
% resolution_options = '-vf "crop=2/3*in_w:2/3*in_h,scale=1280:720"'; % Crop the central input area with size 2/3 of the input video
% resolution_options = '-vf "crop=1/4*in_w:1/4*in_h:600:1050,scale=1280:720"'; % Crop area with size XXXxYYY at position (XXX,YYY)
% resolution_options = '-vf "crop=in_w/2:in_h/2:in_w/2:in_h/2,scale=1280:720"'; % Keep only the bottom right quarter of the input image
% resolution_options = '-vf "crop=in_w/2:in_h/2:in_w/2:0,scale=1280:720"'; % Keep only the bottom right quarter of the input image

%% output_options = '';
output_options = '-vcodec: mjpeg -q:v 0 -acodec ac3 -q:a 256k';

%% Look for Video files
%full_directory = uigetdir(pwd, 'Choisissez le dossier de projet depuis lequel convertir les vidéos');
video_file_path_split = strsplit(video_file_path, '.');
extension = video_file_path_split(end);

if strcmp(extension, 'avi') && ~exist([output_file_path '_MJPEG.avi'], 'file')
    find_video = true;
    avi_video_path = video_file_path;
    video_infos = mmfileinfo(avi_video_path);
    if strcmp(video_infos.Video.Format , 'MJPG')
        need_conversion = false;
        trip_video_file = 'No video conversion needeed';
    else
        need_conversion = true;
        full_input_file = avi_video_path;
    end
    
elseif strcmp(extension, 'mkv') && ~exist([output_file_path '_MJPEG.avi'], 'file')
% elseif strcmp(extension, 'mkv') && ~exist([output_file_path '_CROPED_CENTER_MJPEG.avi'], 'file')
    find_video = true;
    mkv_video_path = video_file_path;
    video_infos = mmfileinfo(mkv_video_path);
    if strcmp(video_infos.Video.Format , 'MJPG')
        need_conversion = false;
        trip_video_file = 'No video conversion needeed';
    else
        need_conversion = true;
        full_input_file = mkv_video_path;
    end
    
elseif strcmp(extension, 'mp4') && ~exist([output_file_path '_MJPEG.avi'], 'file')
    find_video = true;
    mp4_video_path = video_file_path;
    video_infos = mmfileinfo(mp4_video_path);
    if strcmp(video_infos.Video.Format , 'MJPG')
        need_conversion = false;
        trip_video_file = 'No video conversion needeed';
    else
        need_conversion = true;
        full_input_file = mp4_video_path;
    end
    
elseif strcmp(extension, 'mpg') && ~exist([output_file_path '_MJPEG.avi'], 'file')
    find_video = true;
    need_conversion = true;
    mpg_video = video_file_path;
    full_input_file = mpg_video;
end

if find_video && need_conversion
    %% Video files output names
    [folder,file_name,~] = fileparts(output_file_path);
    full_outputfile = [folder filesep file_name '_MJPEG.avi'];
%     full_outputfile = [folder filesep file_name '_CROPED_CENTER_MJPEG.avi'];
    
    full_input_file = ['"' full_input_file '"'];
    full_outputfile = ['"' full_outputfile '"'];
    
    %% Creating command line
    ffmpeg_command_line = buildCommandLine(startCommand, input_options, full_input_file, cut_options, resolution_options, output_options, full_outputfile);
    trip_video_file = full_outputfile;
    system(ffmpeg_command_line);
end
%% Filling-up synchro struct
if find_video
    [~,file_name,ext] = fileparts(trip_video_file);
    trip_video_file = [file_name filesep ext];
    disp(trip_video_file);
    %sync_mopad.META.video_description = 'quadravision';
    %sync_mopad.META.video_path = ['.\' trip_video_file];
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
% change current folder to ffmpeg folder where to find ffprobe command
MPath = path;
a = strfind(MPath, 'ffmpeg\bin');
RegPath = regexp(MPath, ';');
for i_path = 1:length(RegPath)
    if a > RegPath(i_path) && a < RegPath(i_path+1)
        newFolder = MPath(RegPath(i_path)+1:RegPath(i_path+1)-1);
        break
    end
end
oldFolder = cd(newFolder);

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
cd(oldFolder);
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
if length(sscanf(video_time_string,'%2d:%2d:%2d:%2d')) > 4                  % case of the timecode in milliseconds
    disp('Precision of the timecode is one millisecond');
    time = sscanf(video_time_string,'%2d:%2d:%2d:%3d');
    time_sec = time(1)*3600 + time(2)*60 + time(3) + time(4)*0.001;
else                                                                        % case of the timecode in number of frames
    disp('Precision of the timecode is one image (40ms)');
    time = sscanf(video_time_string,'%2d:%2d:%2d:%2d');
    time_sec = time(1)*3600 + time(2)*60 + time(3) + time(4)*0.04;
end
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

