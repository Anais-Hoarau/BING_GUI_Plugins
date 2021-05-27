function top_offset = decodeCardioEventTime(evenTimeString)
    % decode scenario_top_offset
    [time, unit] = strtok(evenTimeString,' ');
    if strcmp(unit,' hrs')
        top_offset = str2double(time)*3600.;
    elseif strcmp(unit,' min')
        top_offset = str2double(time)*60.;
    elseif strcmp(unit,' sec')
        top_offset = str2double(time);
    elseif strcmp(unit,' ms')
        top_offset = str2double(time)/1000.;
    end
end