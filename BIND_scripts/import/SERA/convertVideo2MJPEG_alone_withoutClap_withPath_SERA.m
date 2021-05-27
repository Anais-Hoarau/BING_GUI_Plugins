function convertVideo2MJPEG_alone_withoutClap_withPath_SERA(video_file_folder, output_file)
    if exist(output_file, 'file')
        return
    end
    
    %% Creating command line
    input_videos = find_file_with_extension([video_file_folder '\'], '.mp4');
    inputs = '';
    filters = '';
    for i_video = 1:1:length(input_videos)
        inputs = [inputs ' -i "' input_videos{i_video} '"'];
        filters = [filters ' [' num2str(i_video-1) ':v]'];
    end
    ffmpeg_command_line = buildCommandLine('ffmpeg', ...
        inputs, ...
        '-filter_complex', ...
        '"', ...
        filters,...
        ['concat=n=' num2str(length(input_videos)) ':v=1'],...
        '[v];[v]scale=1280:720',...
        '"',...
        '-vcodec:', 'mjpeg',...
        '-q:v', '0',...
        output_file);
    system(ffmpeg_command_line);
end

function commandLine = buildCommandLine(varargin)
commandLine = '';
for i=1:1:length(varargin)
    tmp = strtrim(varargin{i});
    commandLine = [commandLine tmp ' '];%#ok
end
end
