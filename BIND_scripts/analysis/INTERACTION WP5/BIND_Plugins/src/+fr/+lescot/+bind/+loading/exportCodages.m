
[filename1, pathname] = uigetfile('*.*','select the coded trip to build the Excel file');
tripFilename = fullfile(pathname,filename1);

[filename2, pathname] = uiputfile('*.xls','output excel file name');
xlsFileName = fullfile(pathname,filename2);

if isequal(filename1,0) || isequal(filename2,0)
     disp('User selected Cancel')
     return;
end   
    
theTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFilename,0.04,false);
targetFusionTable = 'WP5_Codages';

metas = theTrip.getMetaInformations();

listes = metas.getEventsNamesList();

[selection,ok] = listdlg('PromptString','Select tables to merge:',...
                'SelectionMode','multiple',...
                'ListString',listes);
if ok 
    TableToMerge = listes(selection);
else
    return;
end
            
%prepare structure for backup
%metas = theTrip.getMetaInformations();
% if ~metas.existEvent(targetFusionTable)
%     targetEvent = fr.lescot.bind.data.MetaEvent();
%     targetEvent.setIsBase(false);
%     targetEvent.setName(targetFusionTable);
%     theTrip.addEvent(targetEvent);
% end

tripLength = theTrip.getMaxTimeInDatas();

prompt={'Enter the value of the expected output periodicity for timecode (for example 1 for 1 line per second, 0.5 for 2 lines per second :'};
name='Input for output period';
numlines=1;
defaultanswer={'1'};
answer=inputdlg(prompt,name,numlines,defaultanswer);

if length(answer)>0
    period = str2num(answer{1});
    if isnumeric(period)
        targetTimeStep = period;
    else
        disp('user must set a numeric value! Quitting...');
        return;
    end
else
    disp('user must set a period! Quitting...');
    return;
end

% browse all the events, get the values and set to the trip
for i=1:length(TableToMerge)
    % verify in the table if 'textualValue' variable is present : it means
    % that the table was created by the event_coding plugin.
    if metas.existEventVariable(TableToMerge{i},'textualValue')
        
        record = theTrip.getAllEventOccurences(TableToMerge{i});
        timeValueCellArray = record.buildCellArrayWithVariables({'timecode' 'textualValue'});
        
        % prepare variable for storing
%         if ~metas.existEventVariable(targetFusionTable,TableToMerge{i})
%             targetEventVariable = fr.lescot.bind.data.MetaEventVariable();
%             targetEventVariable.setName(TableToMerge{i});
%             targetEventVariable.setType(fr.lescot.bind.data.MetaEventVariable.TYPE_TEXT);
%             theTrip.addEventVariable(targetFusionTable,targetEventVariable);
%         end
        
        timeCodeIndex = 1;
        codageIndex = 1;
        defaultValue = '-';
        lastEventValue = defaultValue;
        targetValue = {};
        legalSpeed = {};
        nbCodages = size(timeValueCellArray,2);
        
        for j=0:targetTimeStep:tripLength
            % get the value of speed and legal speed at first table :
            % for all the remaining tables, the reference timecode will be the
            % same
            if i == 1
                targetTimecode{timeCodeIndex}=j;
                record = theTrip.getDataOccurenceNearTime('GPSpos',j);
                targetSpeed{timeCodeIndex} =  cell2mat(record.getVariableValues('speed'));
                record = theTrip.getDataOccurenceNearTime('MatchedPos',j);
                legalSpeed{timeCodeIndex} =  cell2mat(record.getVariableValues('wayLegalSpeedLimit'));
            end
            timeCodeIndex = timeCodeIndex +1;
            % test if there are some remaining event coded in the data
            if codageIndex <= nbCodages
                timeOfEvent = timeValueCellArray{1,codageIndex}; 
                % if the target timecode is > to the time code of an event, it
                % mean that the event must change of value
                if j > timeOfEvent
                    % Test the new value of the event
                    eventValue = timeValueCellArray{2,codageIndex};
                    
                    % coding with deb and fin have special treatments : if
                    % it is not the case, the value from the data can be
                    % used
                    if strncmpi(eventValue,'Deb',3) || strncmpi(eventValue,'Fin',3)
                        % if it is a DEB (deb CC, deb SL, deb Auto...), the
                        % following in the data must be CC, SL, Auto...
                        if strncmpi(eventValue,'Deb',3)
                            lastEventValue = eventValue(5:length(eventValue));
                        end
                        % if it is a FIN (fin CC, fin SL, fin Auto...), the
                        % following in the data must be the default value
                        if strncmpi(eventValue,'Fin',3)
                            lastEventValue = defaultValue;
                        end
                    else
                        lastEventValue = eventValue;
                    end
                    
                    % go to next event
                    codageIndex = codageIndex + 1;
                end
            end
            targetValue{timeCodeIndex} = lastEventValue;           
        end
        
        alphabet = ['A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z'];
        % first run, save time code and speed
        if i == 1
           % write first column with generated time codes
           range = [alphabet(i) '1:' alphabet(i) num2str(length(targetTimecode))];
           xlswrite(xlsFileName,targetTimecode','Feuil1',range);
           % write second column with vehicule speed
           range = [alphabet(2) '1:' alphabet(2) num2str(length(targetTimecode))];
           xlswrite(xlsFileName,targetSpeed','Feuil1',range);   
           %  write third column with legal speed
           range = [alphabet(3) '1:' alphabet(3) num2str(length(targetTimecode))];
           xlswrite(xlsFileName,legalSpeed','Feuil1',range);
        end
        
        range = [alphabet(i+3) '1:' alphabet(i+3) num2str(length(targetValue))];
        xlswrite(xlsFileName,targetValue','Feuil1',range)
        % back up line in case of backup of the data
        %myTrip.setBatchOfTimeDataVariablePairs('capteurs', 'frein', [timecodes_cell(:)';break_pedal_cell(:)']);
        %theTrip.setBatchOfTimeEventVariablePairs(targetFusionTable,TableToMerge{i},timeValueCellArray);
        % at last, write the first line with the column names.
        range = [alphabet(1) '1:' alphabet(3+length(TableToMerge)) '1'];
        xlswrite(xlsFileName, {'timecode' 'speed' 'legalSpeed' TableToMerge{:}},'Feuil1',range)
    else
        disp(['The table ' TableToMerge{i} ' does not contain a variable called ''textualValue''. This means that it was not created by event coding plugin, but rather directly collected : it will not be used for export. ']);
    end
end
