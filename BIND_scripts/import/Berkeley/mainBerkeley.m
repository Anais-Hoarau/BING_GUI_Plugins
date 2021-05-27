% mainBerkeley function
% tripSelectionMode is an optional string argument. It specifies the
% behavior of the function.
% The possible values of tripSelectionMode are:
% 'askInputAskOuput' (default): ask both for an input directory and 
%                       for an output directory
% 'askInputSameOutput': ask for an input directory, use the same directory
%                       as output.
% 'fromFile':           look for a 'dirs.mat' file that contains the dirs 
%                       var and load it.
% 'fromFileOrAskInputSameOutput':  try to load from file (see 'fromFile').
%                       If the file does not exist, behave like
%                       'askInputSameOutput'.
%
% This method can raise 'mainBerkeley:undefinedTripSelectionMode' or mainBerkeley:undefinedFile
% exeptions.
%
function mainBerkeley(tripSelectionMode)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % function call parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if nargin == 0
        % fix the default behavior
        tripSelectionMode = 'askInputAskOutput';
    end
    % How to determine the input and output directories?
    switch tripSelectionMode
        case 'askInputAskOutput'
            % default behavior
            % ask for a tripDirectory and an output directory
            dirs = cell(2,1);
            dirs{1,1} = [uigetdir('','Choose a trip directory') filesep];
            dirs{2,1} = [uigetdir('','Choose an output directory') filesep];
        case 'askInputSameOutput'
            % ask for a tripDirectory and use it also as output directory
            dirs = cell(2,1);
            dirs{1,1} = [uigetdir('','Choose a trip directory (trip and video files will be generated on the same directory).') filesep];
            dirs{2,1} = dirs{1,1};
        case 'fromFile'
            % read the dirs value from a file
            if ~exist('dirs.mat','file')
                exception = MException('mainBerkeley:undefinedFile', ...
                'the file "dirs.mat" was not found.');
                throw(exception);
            end
            load('dirs.mat', 'dirs');
        case 'fromFileOrAskInputSameOutput'
            % read the dirs value from a file
            if exist('dirs.mat','file')
                load('dirs.mat', 'dirs');
            else
                % ask for a tripDirectory and use it also as output directory
                dirs = cell(2,1);
                dirs{1,1} = [uigetdir('','Choose a trip directory (trip and video files will be generated on the same directory).') filesep];
                dirs{2,1} = dirs{1,1};
            end
        otherwise
            exception = MException('mainBerkeley:undefinedTripSelectionMode', ...
            'this trip selection mode does not exist.');
            throw(exception);
    end
 
    globalTic = tic;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % the actual trip and video conversion
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [~,len] = size(dirs);
    errors = cell(len);
    tripTocs = cell(len);
    tripNames = cell(len);
    tripFail = cell(len);
    for i=1:len
        tripTic = tic;
        try
            tripDirectory = dirs{1,i};
            outDirectory = dirs{2,i};
            % Load Berkeley data and create a .trip BIND file.
            videoBaseName = berkeleyFolder2sqlite(tripDirectory, outDirectory);
            tripNames{i} = videoBaseName;
            % Process video files
            errors{i} = berkeleyVideoConversion(tripDirectory, outDirectory, videoBaseName);
            tripTocs{i} = toc(tripTic);
            tripFail{i} = false;
        catch ME
            % log the error
            logFileName = fullfile(dirs{2,i},['log_conversion_' date '.txt']);
            logFile = fopen(logFileName, 'a');
            fprintf(logFile, 'Matlab exception: %s\n', ME.identifier);
            fprintf(logFile, 'occurred while converting trip: %s\n\n', dirs{1,i});
            fclose(logFile);
            tripFail{i} = true;
        end
    end
 
    % Generate the summaries
    numFails = 0;
    existErrors = false;
    numTrips = len;
    
    disp('');
    disp('====================');
    disp('= Per trip summary =');
    disp('====================');
    for i=1:numTrips
        disp(dirs{1,i});
        if(tripFail{i})
            numFails = numFails + 1;
            message = sprintf('Trip %s''s conversion failed! :(',tripNames{i});
            disp(message);
        else
            message = sprintf('Trip %s converted in %dh%dmin.',tripNames{i}, floor(tripTocs{i}/3600), floor(mod(tripTocs{i}/60,60)) );
            disp(message);
            if errors{i} ~= 0  
                existErrors = true;
                message = sprintf('%d exceptions were triggered during the video conversion. See the log file in %s directory for more information.',...
                                    errors{i}, dirs{2,i});
                disp(message);
            end
        end
    end
    disp('');
    disp('====================');
    disp('=  Global summary  =');
    disp('====================');
    message = sprintf('%d trip(s) were generated.',numTrips - numFails);
    disp(message);
    if numFails ~= 0
        message = sprintf('%d trips'' conversion has failed.', numFails);
        disp(message);
    end
    if existErrors
        disp('Exceptions has occured during some video conversions.');
    end

    message = sprintf('The total conversion took %ihour(s) %dminutes.',...
                floor(toc(globalTic)/3600), floor(mod(toc(globalTic)/60,60)) );
    disp(message);

end
