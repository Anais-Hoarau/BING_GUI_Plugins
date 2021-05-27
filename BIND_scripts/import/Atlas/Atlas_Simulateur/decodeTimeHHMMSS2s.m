function timeS = decodeTimeHHMMSS2s(timeHHMMSS)
    time = strrep(timeHHMMSS,',','.');
    time_vector = textscan(time,'%f:%f:%f');
    h = time_vector{1};
    m = time_vector{2};
    s = time_vector{3};
%    [hours, remain] = strtok(timeHHMMSS,':');
%    [minutes, remain] = strtok(remain,':');
%    [seconds, remain] = strtok(remain,':');
%    h = str2num(hours);
%    m = str2num(minutes);
%    seconds = strrep(seconds,',','.');
%    s = str2num(seconds);
    timeS = h*3600. + m*60. + s;
end