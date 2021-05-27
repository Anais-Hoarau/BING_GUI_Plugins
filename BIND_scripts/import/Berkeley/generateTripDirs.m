% generateTripDirs.m
%
% generateTripDirs(drivers,tripListFile,workingProjectDir,outputFile)
%
% This function generates a file that can be loaded by the script
% mainBerkeley.m. Basically, the output file contain a cell array of input
% and output directories for converting CACC raw files into BIND SQLiteTrip
% files.
%
% This function is inspired by generate_data_set.m function.
%
% driver:               An list of drivers to include in the data set. The
%                       list could be a single driver 9, or a set of driver
%                       [1 2 3].  To simply indicate all drivers, use
%                       driver = 0.
% tripListFile:         A string containing the full path to the
%                       TripList.dat file.
% workingProjectDir:    A string containing the full path to the CACC
%                       project files. The trips will be looked for from
%                       this root directory.
% outputFile:           A string containing the full path to the output
%                       file. The output file should be named "dirs.mat" in
%                       order to be detected by mainBerkeley.m function.
%
% example
% generateTripDirs(0,'C:\Documents and Settings\mathern\Bureau\CACC\TripList.dat',
% 'C:\CACC\','C:\Documents and Settings\mathern\Bureau\CACC\dirs.mat')
%
function generateTripDirs(drivers,tripListFile,workingProjectDir,outputFile)

    % ------------------------------------------------------------------------------
    % Load TripList.dat & Filter Trips
    % ------------------------------------------------------------------------------

    % Load TripList.dat file
    if exist(tripListFile,'file') ~= 2,
        error('%s\n%s',['Error: Could not find ' tripListFile],'Operation Aborted.');
    end;
    triplist = load_txt_datafile(get_file_input_format('triplist'),tripListFile);
%     log{length(log)+1} = ['Loaded: ' triplistfile];
%     disp(log{length(log)});
    clear tripListFile;

%     % Apply Trip Filter Function
%     cd('trip_filters');
%     if strcmpi(tripFilter,'none') || strcmpi(tripFilter,'-none'),
%         message = 'Filter TripList: No trip filter function specified or applied.';
% 
%     elseif exist(tripFilter,'file') == 2,
%         filter = str2func(tripFilter);
%         [triplist message] = filter(triplist); 
% 
%     else,
%         message = ['Filter TripList Failed: Unable to locate ' tripFilter '.m'];
% 
%     end;
%     log{length(log)+1} = message;
%     disp(log{length(log)});
%     cd('..');

    % Apply Driver Filter
    if (length(drivers) > 1 || drivers > 0)
%         message = 'Filtered Drivers: ';
        newlist = [];
        for i=1:length(drivers)
            newtrips = truncate_struct(triplist,'Driver',drivers(i),drivers(i));
            if ~isempty(newtrips)
                newlist = vertcat_simple_struct(newlist,newtrips);
%                 message = [message num2str(drivers(i),'%d') ' '];                   %#ok<AGROW>
            else
                disp(['Warning: No trips found for Driver ' num2str(drivers(i))]);
            end
        end
        triplist = newlist;
        clear newtrips newlist;
%     else
%         message = 'Filter Drivers: No driver filter specified or applied.';
    end
%     log{length(log)+1} = message;
%     disp(log{length(log)});


    % ------------------------------------------------------------------------------
    % Loop Through Each Trip in the TripList
    % ------------------------------------------------------------------------------

    % Initialize output Cell Array
    dirs = cell(2,length(triplist.Driver));

    % TripList Loop
    for trip=1:length(triplist.Driver)

        % --------------------------------------------------------------------------
        % Load Trip Into Memory
        % --------------------------------------------------------------------------

        % Set Trip Attributes to Easy to Read Local Variables
        driver = triplist.Driver(trip);
        vehicle = triplist.Vehicle(trip);
        tripdate = [num2str(triplist.Year(trip),'%02d') num2str(triplist.Month(trip),'%02d') num2str(triplist.Day(trip),'%02d')];
        tripid = triplist.TripID(trip);

        % Set Vehicle Directory (from load_trip.m)
        if isnumeric(vehicle) && vehicle == 1,
            vehicle = 'Silver';
        else % isnumeric(vehicle) && vehicle == 2,
            vehicle = 'Copper';
        end;
        
        % Convert TripID to string
        if isnumeric(tripid)
            tripid = num2str(tripid,'%04d');
        end;
    
        trip_path = [workingProjectDir 'Driver' num2str(driver,'%02d') filesep vehicle filesep 'Date' tripdate filesep 'Trip' tripid filesep];
        
        dirs{1,trip} = trip_path;
        dirs{2,trip} = trip_path;
        
%         % Load Trip
%         set_project('CACC');
%         log{length(log)+1} = ['Loading: Driver ' num2str(driver) ' Vehicle ' num2str(vehicle)...
%             ' TripDate ' tripdate ' TripID ' num2str(tripid) '...'];                %#ok<AGROW>
%         disp(log{length(log)});
%         [data data_index] = load_trip(driver,vehicle,tripdate,tripid);
% 
%         % Verify that a Trip was Loaded into Memory
%         if isempty(data)
%             log{length(log)+1} = ['  Error: Unable to load Driver ' num2str(driver)...
%                 ' Vehicle ' num2str(vehicle) ' TripDate ' tripdate ' TripID '...
%                 num2str(tripid) '.  Trip Skipped.'];                                %#ok<AGROW>
%             continue;
%         end;
% 
%         % --------------------------------------------------------------------------
%         % Run Analysis
%         % --------------------------------------------------------------------------
%         tripline = truncate_struct(triplist,'-index',trip);
%         cd('analyses');
%         [newoutput message] = analyze(tripline,data,data_index);
%         if ~isempty(message),
%             log{length(log)+1} = message;                                           %#ok<AGROW>
%         end;
%         output = vertcat_simple_struct(output,newoutput);

    end  % Trip Loop

    save(outputFile,'dirs');

end
