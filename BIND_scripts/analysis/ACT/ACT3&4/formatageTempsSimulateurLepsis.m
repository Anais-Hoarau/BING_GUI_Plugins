function timecode = formatageTempsSimulateurLepsis(temps)
        timecode = (str2double(temps(1:2))*3600 + str2double(temps(4:5))*60 + str2double(temps(7:8))) + (str2double(temps(10:end))/100)/1000;
end