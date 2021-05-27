%{
Function:
This function opens a BIND trip file that contains UTC timecode data (collected from lowcost GPS)
and a TrajRef file coming from a high end RMT GPS in order to synchronise the RMT data to the trip file.

Parameters:

%}
%function importTrajRef()
clear all;

% specify dataname for output
dataName = 'MRT_TrajRef';
step = 0.02; % expected data period of RMT sensor


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

columnNumber = 49 - 2; % WARNING : to adapt according

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
for i=1:columnNumber
    pattern = [pattern '%f '];
end

disp('Scanning MRT file');
% in A, we record all the variables from the MRT.
A = textscan(rmtFileHandler,pattern);

% get relevant column for the synchronisation process from MRT
MRT_UTC_times = A{2};
MRT_GyroZ_deg_per_hour = A{44}; % WARNING : to change 
Latitude_deg = A{3};
Longitude_deg = A{5};
Altitude = A{7}; % WARNING : to change 

disp('Reading trip data');
% get relevant columns for synchro from Trip
gpsRecord = theTrip.getAllDataOccurences('GPS5Hz');
trip_timecodes = cell2mat(gpsRecord.getVariableValues('timecode'));
trip_UTC_times = gpsRecord.getVariableValues('UTC_5Hz');

trip_UTC_times_in_second = zeros(1,length(trip_UTC_times));

disp('Decoding GPS UTC time to seconds');
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
    utc_time_in_second = sscanf(trip_utc_hour,'%f') * 3600 + sscanf(trip_utc_minute,'%f') * 60 + sscanf(trip_utc_second,'%f') + sscanf(trip_utc_ms,'%f')*0.01;
    trip_UTC_times_in_second(i) = utc_time_in_second;
end

%trip_UTC_times = cell2mat(trip_UTC_times_in_second);
trip_UTC_times = trip_UTC_times_in_second;


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

pause(0.5);

MRT_Gyro_interpolated=interp1(MRT_UTC_times,MRT_GyroZ_deg_per_hour,interpolatedUTC_times);

MRT_Latitude_interpolated =interp1(MRT_UTC_times,Latitude_deg,interpolatedUTC_times);
MRT_Longitude_interpolated=interp1(MRT_UTC_times,Longitude_deg,interpolatedUTC_times); 

% everything ok ? at this stage, all the MRT data should have been
% associated to timecode data from the trip

% TODO : add proper data insertion to trip

% prepare trip for backup
% prepare BIND meta data 
newData = fr.lescot.bind.data.MetaData();
% dataname is set in the beginning of the script
newData.setName(dataName);
newData.setFrequency(50);
listeVariables = {'timecode' 'MRT_GyroZ_deg_per_hour' 'MRT_Latitude' 'MRT_Longitude' }; % timecode is system : mandatory
typesOfVariables = {fr.lescot.bind.data.MetaEventVariable.TYPE_REAL...,
        fr.lescot.bind.data.MetaEventVariable.TYPE_REAL...,
        fr.lescot.bind.data.MetaEventVariable.TYPE_REAL...,
        fr.lescot.bind.data.MetaEventVariable.TYPE_REAL...,
        };
    
variables = cell(1,length(listeVariables));

for i=1:length(listeVariables)
    uneVariable = fr.lescot.bind.data.MetaDataVariable();
    uneVariable.setName(listeVariables{i});
    uneVariable.setType(typesOfVariables{i});
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

tripTimecodeForMRT2save = num2cell(interpolatedTimecodes);

disp('Saving MRT Gyro');
MRT_GyroZ_deg_per_hour2save = num2cell(MRT_Gyro_interpolated);
timeValueCellArray = [ tripTimecodeForMRT2save' MRT_GyroZ_deg_per_hour2save']';
%theTrip.setBatchOfTimeDataVariablePairs(dataName,'MRT_GyroZ_deg_per_hour',timeValueCellArray);

disp('Saving MRT Latitude');
MRT_Latitude2save = num2cell(MRT_Latitude_interpolated);
timeValueCellArray = [ tripTimecodeForMRT2save' MRT_Latitude2save']';
numberOfLineToAdd = 10000;
nbSets = floor(length(timeValueCellArray) / numberOfLineToAdd);
for i=0:(nbSets-1)
    message = ['Inserting Latitude : ' num2str(i*numberOfLineToAdd) ' lines / ' num2str(length(timeValueCellArray)) ' lines'];
    disp(message);
    partialTimeValueCellArray = timeValueCellArray(:,(i*numberOfLineToAdd + 1 : (i+1)* numberOfLineToAdd));
    theTrip.setBatchOfTimeDataVariablePairs(dataName,'MRT_Latitude',partialTimeValueCellArray);
end
lastPartialTimeValueCellArray = timeValueCellArray(:,(nbSets*numberOfLineToAdd + 1 : length(timeValueCellArray)));
theTrip.setBatchOfTimeDataVariablePairs(dataName,'MRT_Latitude',lastPartialTimeValueCellArray);

disp('Saving MRT Longitude');
MRT_Longitude2save = num2cell(MRT_Longitude_interpolated);
timeValueCellArray = [ tripTimecodeForMRT2save' MRT_Longitude2save']';

numberOfLineToAdd = 10000;
nbSets = floor(length(timeValueCellArray) / numberOfLineToAdd);
for i=0:(nbSets-1)
    message = ['Inserting Longitude : ' num2str(i*numberOfLineToAdd) ' lines / ' num2str(length(timeValueCellArray)) ' lines'];
    disp(message);
    partialTimeValueCellArray = timeValueCellArray(:,(i*numberOfLineToAdd + 1 : (i+1)* numberOfLineToAdd));
    theTrip.setBatchOfTimeDataVariablePairs(dataName,'MRT_Longitude',partialTimeValueCellArray);
end
lastPartialTimeValueCellArray = timeValueCellArray(:,(nbSets*numberOfLineToAdd + 1 : length(timeValueCellArray)));
theTrip.setBatchOfTimeDataVariablePairs(dataName,'MRT_Longitude',lastPartialTimeValueCellArray);

delete(theTrip);