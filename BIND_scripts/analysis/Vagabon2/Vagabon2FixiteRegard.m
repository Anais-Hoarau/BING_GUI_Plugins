function Vagabon2FixiteRegard(trip_file)
tic
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
metaInfo = trip.getMetaInformations();
if metaInfo.existData('tobii')
    bindDataName = 'tobii';
    bindVariableName_1 = 'fixite_regard_36';
    bindVariableName_2 = 'fixite_regard_60';
    trip.setIsBaseData(bindDataName,0);
    addDataVariables(trip,bindDataName,bindVariableName_1)
    addDataVariables(trip,bindDataName,bindVariableName_2)
    
    tobii_occurences = trip.getAllDataOccurences(bindDataName);
    timecodes = cell2mat(tobii_occurences.getVariableValues('timecode'));
    GPRX = tobii_occurences.getVariableValues('axeRegard_X')';
    GPRY = tobii_occurences.getVariableValues('axeRegard_Y')';
    
    DMO_1000ms_byLine = zeros(30,2);
    fixite_regard = num2cell(zeros(length(timecodes),2));
    
    DMO_threshold_1 = 36;
    DMO_threshold_2 = 60;
    empty_lines_threshold = 5;
    DMO_1000ms_out_threshold = 0;
    for i_line = 1:1:length(timecodes)-30
        empty_lines = 0;
        for i_timestamp = 1:1:30
            if all([~isempty(GPRX{i_line+i_timestamp}), ~isempty(GPRX{i_line})])
                DMO_1000ms_byLine(i_timestamp,1) = timecodes(i_line+i_timestamp);
                DMO_1000ms_byLine(i_timestamp,2) = sqrt((GPRX{i_line+i_timestamp}-GPRX{i_line})^2+(GPRY{i_line+i_timestamp}-GPRY{i_line})^2);
            else
                DMO_1000ms_byLine(i_timestamp,1) = timecodes(i_line+i_timestamp);
                DMO_1000ms_byLine(i_timestamp,2) = NaN;
                empty_lines = empty_lines + 1;
            end
        end
        
        if and(empty_lines<=empty_lines_threshold , sum(DMO_1000ms_byLine(:,2)>DMO_threshold_1)<=DMO_1000ms_out_threshold) %, ((DMO_1000ms_byLine(30,1)-DMO_1000ms_byLine(1,1))<=1000))
                fixite_regard(i_line:i_line+30-1,1) = num2cell(timecodes(i_line:i_line+30-1));
                fixite_regard(i_line:i_line+30-1,2) = num2cell(1);
                trip.setBatchOfTimeDataVariablePairs(bindDataName,bindVariableName_1,[fixite_regard(i_line:i_line+30-1,1),fixite_regard(i_line:i_line+30-1,2)]');
        else
                fixite_regard(i_line:i_line+30-1,1) = num2cell(timecodes(i_line:i_line+30-1));
                fixite_regard(i_line:i_line+30-1,2) = num2cell(0);
                trip.setBatchOfTimeDataVariablePairs(bindDataName,bindVariableName_1,[fixite_regard(i_line:i_line+30-1,1),fixite_regard(i_line:i_line+30-1,2)]');
        end
        if and(empty_lines<=empty_lines_threshold , sum(DMO_1000ms_byLine(:,2)>DMO_threshold_2)<=DMO_1000ms_out_threshold) %, ((DMO_1000ms_byLine(30,1)-DMO_1000ms_byLine(1,1))<=1000))
                fixite_regard(i_line:i_line+30-1,1) = num2cell(timecodes(i_line:i_line+30-1));
                fixite_regard(i_line:i_line+30-1,2) = num2cell(1);
                trip.setBatchOfTimeDataVariablePairs(bindDataName,bindVariableName_2,[fixite_regard(i_line:i_line+30-1,1),fixite_regard(i_line:i_line+30-1,2)]');
        else
                fixite_regard(i_line:i_line+30-1,1) = num2cell(timecodes(i_line:i_line+30-1));
                fixite_regard(i_line:i_line+30-1,2) = num2cell(0);
                trip.setBatchOfTimeDataVariablePairs(bindDataName,bindVariableName_2,[fixite_regard(i_line:i_line+30-1,1),fixite_regard(i_line:i_line+30-1,2)]');
        end
    end
    trip.setIsBaseData(bindDataName,1);
    trip.setAttribute('calculate_fixite_regard', 'OK');
end
toc
end

%% SUBFUNCTIONS
% add stim Data variable
function addDataVariables(trip,bindDataName,bindVariableName)
MetaInformations = trip.getMetaInformations;
if ~MetaInformations.existDataVariable(bindDataName,bindVariableName)
    bindVariable = fr.lescot.bind.data.MetaDataVariable();
    bindVariable.setName(bindVariableName);
    bindVariable.setType('REAL');
    bindVariable.setUnit('');
    bindVariable.setComments('');
    trip.addDataVariable(bindDataName,bindVariable);
end
end