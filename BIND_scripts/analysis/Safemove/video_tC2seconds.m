function time_sec = video_tC2seconds(video_time_string)
    time = sscanf(video_time_string,'%2d:%2d:%2d:%2d');
    time_sec = time(1)*3600 + time(2)*60 + time(3) + time(4)*0.04;
end

