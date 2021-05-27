function video_time_string = video_seconds2time(time_sec)
sec = floor(time_sec);

millisec =time_sec-sec;
frame = floor((millisec)/0.04);

hours = floor(sec / 3600);
minutes = floor((sec - 3600 * hours)/60);
seconds = sec - 3600 * hours - 60 * minutes ;

video_time_string = sprintf('%02d:%02d:%02d:%02d',hours,minutes,seconds,frame);
end