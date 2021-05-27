% Import RTMAPS rec file to trip file
function SERA_REC2BIND(trip,rec_file)
    RecFile = importRecFile(rec_file);
    luxmeter_datas = [];
    for i_row = 1:length(RecFile)
        if strfind(RecFile{i_row,3},'Data_Luxmeter.outputAscii#')
            str = RecFile{i_row,3};
            expression = '\d+@(\d+:\d+\.\d+)=\W+(\d+)\W+';
            luxmeter_data = regexp(str,expression,'tokens');
            if ~isempty(luxmeter_data)
                luxmeter_datas = [luxmeter_datas, luxmeter_data{:}'];
            end
        end
    end
    timecodes = tempsToTimecode(luxmeter_datas(1,:)');
    values = luxmeter_datas(2,:)';
    
    addDataTable2Trip(trip,'luxmeter','type','REAL','frequency','1Hz','comment','illumination_data')
    addDataVariable2Trip(trip,'luxmeter','illumination','REAL','unit','lux')
    trip.setBatchOfTimeDataVariablePairs('luxmeter', 'illumination', [timecodes, values]');
    
end

function out = tempsToTimecode(heureTemps)
heureTempsNonInterpolatedTimecodes = cell(length(heureTemps), 1);
%Convert gtm time to seconds
for i = 1:1:length(heureTemps)
    gmtString = strrep(heureTemps{i}, '.', ',');
    scanned = textscan(gmtString, '%f:%f,%f');
    [min, sec, ms] = scanned{:};
    newTimeCode = (min * 60) + sec + ms/1000000;
    heureTempsNonInterpolatedTimecodes{i, 1} = newTimeCode;
end
out = heureTempsNonInterpolatedTimecodes;
end