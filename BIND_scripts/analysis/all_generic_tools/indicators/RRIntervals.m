% calculate cardiac RRintervals
function RRIntervals(trip, dataName2Get, variablesNames2Get, dataName2Set, variablesNames2Set)
    
    if trip.getMetaInformations.existData(dataName2Get)
        %% Set findpeaks input parameters
        MPH = -inf;
        MPD = 0.5;
        MPP = 1.4;
        
        %% get data
        timecodes = cell2mat(trip.getAllDataOccurences(dataName2Get).getVariableValues('timecode'));
        ecg = cell2mat(trip.getAllDataOccurences(dataName2Get).getVariableValues(variablesNames2Get{1}));
        
        %% find RR intervals
        findpeaks(ecg,'MinPeakHeight',MPH,'MinPeakDistance',MPD,'MinPeakProminence',MPP);
        [~,LOCS] = findpeaks(ecg,'MinPeakHeight',MPH,'MinPeakDistance',MPD,'MinPeakProminence',MPP);
        timecodesPKS = timecodes(LOCS);
        RRintervals = diff(timecodesPKS);
        
        %% add indicators to the trip
        addDataVariable2Trip(trip,dataName2Set,variablesNames2Set{1},'REAL','unit','s','comment','Cardiac_RRintervals_calculated');
        for i_pks = 2:length(timecodesPKS)
            trip.setDataVariableAtTime(dataName2Set, variablesNames2Set{1}, timecodesPKS(i_pks), RRintervals(i_pks-1))
        end
    end
end