%{
Function:
This function opens a BIND trip file that contains UTC timecode data (collected from lowcost GPS)
and a TrajRef file coming from a high end RMT GPS in order to synchronise the RMT data to the trip file.

Parameters:

%}
%function importTrajRef()
clear all;
[MRTFile,PathName,~] = uigetfile('C:\','Select MRT File. Should be TrajRef_xxxx.txt','*.txt');
if MRTFile == 0
    disp('Abandon car aucune selection');
    return;
else
    MRTFile = fullfile(PathName,MRTFile);
end

[tripFile,PathName,~] = uigetfile('C:\','Select Trip File. Should be xxxx.trip','*.trip');
if tripFile == 0
    disp('Abandon car aucune selection','Select Trip file');
    return;
else
    tripFile = fullfile(PathName,tripFile);
end

[pathstr, name, ext] =  fileparts(MRTFile);

s2 = regexp(name, '_', 'split');
idFile = s2{1};
dateMRT = s2{2};

if ~strcmp(idFile,'TrajRef')
    disp('This is not a MRT file!');
    return;
else
    rmtFileHandler = fopen(MRTFile);
end

try
    theTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFile,0.04,false);
catch ME
    %do proper error reporting
    disp('cannot open trip');
    return;
end

metaInfos = theTrip.getMetaInformations();
if ~metaInfos.existDataVariable('GPS5Hz','UTC_5Hz')
    disp('Trip file does not contain UTC time information : synchro will not be possible');
    % TO ACTIVATE :
    %return;
end

% at this stage, the files are ok and we can proceed

% we drop the first line
fgetl(rmtFileHandler);

% THESE ARE THE COLUMNS : Todo, add a description
%time_sec
%UTC_time_sec	: UTC time code
%Latitude_deg
%std_dev_Latitude_meter
%Longitude_deg
%std_dev_Longitude_meter
%std_dev_LatLong_meter
%Altitude_meter
%std_dev_Altitude_meter
%Speed_north_m_per_s
%std_dev_Speed_north_m_per_s
%Speed_east_m_per_s
%std_dev_Speed_east_m_per_s
%Speed_up_m_per_s
%std_dev_Speed_up_m_per_s
%Heading_deg
%std_dev_Heading_deg
%Roll_deg
%std_dev_Roll_deg
%Pitch_deg
%std_dev_Pitch_deg
%heave
%status1
%status2
%status3
%GPS_time_validity_sec
%GPS_UTC_time_validity_sec
%GPS_Quality
%GPS_Latitude_deg
%GPS_Longitude_deg
%GPS_Altitude_meter
% std_dev_GPS_Latitude_meter
% std_dev_GPS_Longitude_meter
% std_dev_GPS_Altitude_meter
% latitude_LeverArm_2_deg
% longitude_LeverArm_2_deg
% altitude_LeverArm_2_meter
% latitude_LeverArm_3_deg
% longitude_LeverArm_3_deg
% altitude_LeverArm_3_meter
% latitude_LeverArm_4_deg
% longitude_LeverArm_4_deg
% altitude_LeverArm_4_meter
% GyroX_deg_per_hour
% GyroY_deg_per_hour
% GyroZ_deg_per_hour
% AccX_meter_per_square_second
% AccY_meter_per_square_second
% AccZ_meter_per_square_second

pattern = '';
for i=1:49
    pattern = [pattern '%f '];
end

% in A, we record all the variables from the MRT.
A = textscan(rmtFileHandler,pattern);

% get relevant column for the synchronisation process from MRT
MRT_UTC_times = A{2};
MRT_GyroZ_deg_per_hour = A{46};

% get relevant columns for synchro from Trip
gpsRecord = theTrip.getAllDataOccurences('GPS5Hz');
trip_timecodes = cell2mat(gpsRecord.getVariableValues('timecode'));
trip_UTC_times = gpsRecord.getVariableValues('UTC_5Hz');

trip_UTC_times_in_second = cell(1,length(trip_UTC_times));

% trip UTC times are recorded in HHMMSS.S and must be converted to second
for i=1:length(trip_UTC_times)
    utc_str = sprintf('%.2f',trip_UTC_times{i});
    dot_position = strfind(utc_str,'.');
    str_length = length(utc_str);
    if dot_position == 6 && str_length == 8
        % it is before 10 am... HMMSS.SS
        trip_utc_hour = utc_str(1);
        trip_utc_minute = utc_str(2:3);
        trip_utc_second = utc_str(4:5);
        trip_utc_ms = utc_str(7:8);
    else
        if dot_position == 7 && str_length == 9
            % it is after 10 am ... HHMMSS.SS
            trip_utc_hour = utc_str(1:2);
            trip_utc_minute = utc_str(3:4);
            trip_utc_second = utc_str(5:6);
            trip_utc_ms = utc_str(8:9);
        else
            disp('pb : utc time not matching with expected format. Using old values..');
        end
    end
    utc_time_in_second = str2num(trip_utc_hour) * 3600 + str2num(trip_utc_minute) * 60 + str2num(trip_utc_second) + str2num(trip_utc_ms)*0.01;
    trip_UTC_times_in_second{i} = utc_time_in_second;
end

trip_UTC_times = cell2mat(trip_UTC_times_in_second);


% detection of UTC change to build a reference table for synchro
lastTimecode = 0;
lastUTC_Time = 0;
changeId = 1;
referenceTimecode = {};
referenceUTC_Time = {};

for i=1:length(trip_UTC_times)
    if trip_UTC_times(i) ~= lastUTC_Time;
        % new GPS 5Hz UTC timecode detected
        referenceUTC_Time{changeId} = trip_UTC_times(i);
        referenceTimecode{changeId} = trip_timecodes(i);
        changeId = changeId+1;
        % update
        lastTimecode = trip_timecodes(i);
        lastUTC_Time = trip_UTC_times(i);
    end
end

% interpolating the reference table (timecode of change / new UTC time) to
% obtain a 100Hz timecode vector associated to a 100Hz UTC vector
% The interpolated vectors will be used as a lookup table to find the best
% matching in MRT data
firstTimecode = trip_timecodes(1);
lastTimecode = trip_timecodes(end);
step = 0.01; % expected data period of RMT sensor
x = cell2mat(referenceTimecode);
y = cell2mat(referenceUTC_Time);
xi = firstTimecode:step:lastTimecode;
yi = interp1(x,y,xi);

interpolatedTimecodes = xi;
interpolatedUTC_times = yi;

% use the reference columns as a lookup table to find out the best timecode
% for each MRT line
tripTimecodeForMRT = cell(1,length(MRT_UTC_times));
indexRMTFound = 1;
endFound = false;
indexMRTOfTripDataStart = 1;
indexMRTOfTripDataEnd = 1;

for i=1:length(MRT_UTC_times)
    
    % show progress report every 10 000 lines
    if mod(i,100)
        report = sprintf('%.2f % done',(i /length(MRT_UTC_times)) * 100 );
        disp(report);
    end
    
    MRTTimeToLookup = MRT_UTC_times(i);
    timeDifference = abs(interpolatedUTC_times - MRTTimeToLookup);
    if min(timeDifference) > 0.03
        %disp('time gap too important, pb in the data ?');
    end
    % this MRT UTC sample is the closest to which UTC reference ?
    indexOfBestSolution = find(timeDifference == min(timeDifference));
    if ~isnan(interpolatedTimecodes(indexOfBestSolution))
        % select the timecode associated to the selected sample
        tripTimecodeForMRT{i} = interpolatedTimecodes(indexOfBestSolution);
    else
        tripTimecodeForMRT{i} = 0;
        disp('No interpolated data (Nan Found): setting data timecode to 0...');
    end
    if indexOfBestSolution == 1
       % these samples are before the trip start, the best solution is the
       % first UTC of the trip
       indexMRTOfTripDataStart = i; 
    end
    if indexOfBestSolution == length(interpolatedTimecodes) && endFound == false;
        % these samples are after the trips ends, the best solution is
        % the last UTC of the trip
        indexMRTOfTripDataEnd = i; 
        endFound = true;
    end
end

% if the MRT was stopped before the trip, the end was not found : we use
% the last MRT value for this
if ~endFound
    indexMRTOfTripDataEnd = length(MRT_UTC_times);
    disp('MRT did not record more than trip data');
end

% everything ok ? at this stage, all the MRT data should have been
% associated to timecode data from the trip

% TODO : add proper data insertion to trip

% prepare trip for backup
% prepare BIND meta data 
newData = fr.lescot.bind.data.MetaData();
newData.setName('MRTSynchro');
newData.setFrequency(100);
listeVariables = {'timecode' 'MRT_UTC_time' 'MRT_GyroZ_deg_per_hour' }; % timecode is system : mandatory
variables = cell(1,length(listeVariables));
for i=1:length(listeVariables)
    uneVariable = fr.lescot.bind.data.MetaDataVariable();
    uneVariable.setName(listeVariables{i});
    variables{1,i} = uneVariable;
end
newData.setVariables(variables);
newData.setComments(['These data comes from MACS9-Geoloc MRT ']);
try 
    theTrip.addData(newData);
catch ME
    % if there was an error, it is likely that the data and data variable
    % were already existing. Proper coding would have required testing
    % before creating instead of using Exception ^^
    disp('Error while creating Metadata... already existing ?');
end

timeValueCellArray = [tripTimecodeForMRT(indexMRTOfTripDataStart:indexMRTOfTripDataEnd)' num2cell(MRT_GyroZ_deg_per_hour(indexMRTOfTripDataStart:indexMRTOfTripDataEnd))]';
theTrip.setBatchOfTimeDataVariablePairs('MRTSynchro','MRT_GyroZ_deg_per_hour',timeValueCellArray);

timeValueCellArray = [tripTimecodeForMRT(indexMRTOfTripDataStart:indexMRTOfTripDataEnd)' num2cell(MRT_UTC_times(indexMRTOfTripDataStart:indexMRTOfTripDataEnd))]';
theTrip.setBatchOfTimeDataVariablePairs('MRTSynchro','MRT_UTC_time',timeValueCellArray);

delete(theTrip);