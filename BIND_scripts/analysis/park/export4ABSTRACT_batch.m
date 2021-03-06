

addpath(genpath('../transverse'));

% process_data4ABSTRACT true if we want to execute the script
% to create obsels from data.
process_data4ABSTRACT = true;

% initialise cellArrayOfMarkersToExport
cellArrayOfMarkersToExport = {};

% events
cellArrayOfMarkersToExport = { ...
    cellArrayOfMarkersToExport{:}, ...
    {'event', 'POI', 'Type'}, ...
    };

% situations
cellArrayOfMarkersToExport = { ...
    cellArrayOfMarkersToExport{:}, ...
     {'situation', 'Intersection', 'Label'}, ...
     {'situation', 'BetweenTheIntersections', ''}, ...
     {'situation', 'ConsignePoudrette', ''}, ...
     {'situation', 'ContextePoudrette', 'Label'}, ...
     {'situation', 'ZonesPoudrette', 'Label'}, ...
     {'situation', 'RegardPoudrette', 'Label'}, ...
    };


% situations et events calcul?s pour Abstract
if process_data4ABSTRACT
    cellArrayOfMarkersToExport = { ...
        cellArrayOfMarkersToExport{:}, ...
        {'situation', 'Observe', 'OIType'}, ...
        };
end

% data for enrichment
DataVariableNameForEnrichment = { ...
%    {'GPS5Hz.Latitude_5Hz' 'latitude'}, ...
%    {'GPS5Hz.Longitude_5Hz' 'longitude'}, ...
%    {'SensorsMeasures.DistanceDriven' 'position'}, ...
%    {'SensorsMeasures.Speed' 'speed'}, ...
%    {'SensorsMeasures.SteeringwheelAngle' 'steering'}, ...
                                 };
                             
                 
% find the correct directory and file
% [FileName,PathName] = uigetfile('*.trip','Select the trip file');
% tripFile = fullfile(PathName, FileName);    

% Folders containing files to process
Folders = { ...
     'park01_100607_10h07', ...
     'park02_100608_10h02', ...
     'park03_100610_10h03', ...
     'park04_100614_10h10', ...
     'park05_100615_10h09', ...
     'park06_100621_09h59', ...
     'park07_100622_10h13', ...
     'park08_100624_10h17', ...
     'park09_100628_10h23', ...
     'park10_100629_10h06', ...
     'park11_100701_10h31', ...
     'park12_100705_10h04', ...
     'park13_100706_10h34', ...
     'park14_100708_10h17', ...
    };

for i = 1:length(Folders)

    splittedName = regexp(Folders{i}, '_', 'split');
    tripName = splittedName{1};
    
    tripFile = ['Z:\307\PARK\' Folders{i} '\trip_' tripName '.trip']
 %   tripFile = 'C:\documents\Developpements\307\PARK\park01_100607_10h07\trip_park01.trip';
    theTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFile,0.04,false);
    
    csvFile = [ tripFile '4ABSTRACT.csv'];
    
    % this can be disactivated easily if temporary tables are not necessary
    if process_data4ABSTRACT
        % create new temporary situations for export
        createABSTRACTSituationsAndEvents(theTrip);
    end
    
    exportSituationsAndEvents2CSV( theTrip, csvFile, ';', DataVariableNameForEnrichment, cellArrayOfMarkersToExport);

    theTrip.delete;
    
    % Copy the generated files in the appropriate folder to easily get all 
    % of them at once
    copyfile(csvFile, ['Z:\307\PARK\exportsCSV4ABSTRACT\trip_' tripName '.db4ABSTRACT.csv']);
    
end
