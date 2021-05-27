% mainBerkeleyCaccAnalysis(tripSelectionMode)
% 
% This method do some data post-processing on a set of trips for BIND and
% Abstract.
% For each trip it will:
% 1- Create events and situations according to caccCreateEventsOnTrip()
% method.
% 2- Export some events and situations in a CSV file for Abstract.
%
% The set of trips on which to work is defined according to the
% tripSelectionMode parameter.
% tripSelectionMode (optional) - A string that can be:
% 'default':    Will load a set of predefined trips
% 'fromFile':   Will load a dirs.mat file containing the dirs Matlab
%               variable used to generate a set of trips. (see
%               mainBerkeley.m function.)
function mainBerkeleyCaccAnalysis(tripSelectionMode)

    tic;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % function call parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if nargin == 0
        % fix the default behavior
        tripSelectionMode = 'default';
    end
    % How to determine the trips to load?
    switch tripSelectionMode
        case 'default'
            % default behavior
            % a set of trips defined in hard. :p
            trip_files = { ...
                'C:\mathern\Driver98\Copper\Date080805\Trip0226\CACC-98-Copper-080805-0226.trip',...
                'C:\mathern\Driver98\Silver\Date080725\Trip0047\CACC-98-Silver-080725-0047.trip',...
                'C:\mathern\Driver98\Silver\Date080725\Trip0056\CACC-98-Silver-080725-0056.trip',...
                'C:\mathern\Driver98\Silver\Date080805\Trip0098\CACC-98-Silver-080805-0098.trip'...
                };
        case 'fromFile'
            % read the dirs value from a file
            if ~exist('dirs.mat','file')
                exception = MException('mainBerkeleyCaccAnalysis:undefinedFile', ...
                'the file "dirs.mat" was not found.');
                throw(exception);
            end
            load('dirs.mat', 'dirs');          
            [~,len] = size(dirs);
            trip_files = cell(1,len);
            for i=1:len
                drivers = regexp(dirs(1,:),'(?<=Driver)\d{2}','match');
                vehs    = regexp(dirs(1,:),'(?<=Driver\d{2}\\)\w*','match');
                dates   = regexp(dirs(1,:),'(?<=Date)\d{6}','match');
                trips   = regexp(dirs(1,:),'(?<=Trip)\d{4}','match');
                trip_files(i) = strcat(dirs{2,i},'CACC-',...
                                        drivers{i},'-',...
                                        vehs{i},'-',...
                                        dates{i},'-',...
                                        trips{i},'.trip');
            end
        otherwise
            exception = MException('mainBerkeleyCaccAnalysis:undefinedTripSelectionMode', ...
            'this trip selection mode does not exist.');
            throw(exception);
    end

% situations and events to export to Abstract
cellArrayOfMarkersToExport = { ...
    % {'event', 'event_table_name', 'variable_to_concatenate_to_event_name'}
    {'event', 'ACC_events', 'event'}, ...
    {'event', 'ACC_warning_event', 'event'}, ...
    {'situation', 'detection', 'situation'} ...
    };

% data for enrichment
DataVariableNameForEnrichment = { ...
    % {'dataName.variableName', 'outputName'}
    {'gps.lat' 'latitude'}, ...
    {'gps.long' 'longitude'}, ...
 };

numTrips = length(trip_files);
tripFail = cell(numTrips);    
for i=1:numTrips
    try
        trip_file = trip_files{i};
        message = sprintf('Processing file: %s...',trip_file);
        disp(message);
        trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file,0.04,false);
        % process events and situations
        caccCreateEventsOnTrip(trip);
        disp('Trip processed!');
        % export to Abstract
        csvFile = [ trip_file '4ABSTRACT.csv'];
        exportSituationsAndEvents2CSV( trip, csvFile, ';', DataVariableNameForEnrichment, cellArrayOfMarkersToExport);
        disp('CSV created for Abstract!');
        trip.delete;
    catch ME
        % log the error
        logFile = fopen('mainBerkeleyCaccAnalysis.log', 'a');
        fprintf(logFile, '%s\n', date);
        fprintf(logFile, 'Matlab exception: %s\n', ME.identifier);
        fprintf(logFile, 'occurred while converting trip: %s\n\n', trip_files{i});
        fclose(logFile);
        tripFail{i} = true;
 %       rethrow(ME);
    end
end

messageFail = '';
numFails = 0;
for i=1:numTrips
    if(tripFail{i})
        numFails = numFails + 1;
        messageFail = sprintf('%s%s\n',messageFail,trip_files{i});
    end
end
disp('========================');
message = sprintf('Post-processing done in %d min',floor(toc/60));
disp(message);
if numFails ~= 0
    disp('-----');
    disp('Errors has occured in trips:');
    disp(messageFail);
    disp('Problem reported in the log file mainBerkeleyCaccAnalysis.log.');
end

end