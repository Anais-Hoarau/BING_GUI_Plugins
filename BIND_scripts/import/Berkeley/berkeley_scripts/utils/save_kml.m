% save_kml.m
% 
% Written by Christopher Nowakowski
% v.1 2/06/08
% 
% This function saves GPS coordinates to a KML file which can be viewed in 
% Google Earth.
% 
% The input can be a PATH Data Structure which has a data.gps field or it can 
% be lat, long, altitude.  You can also specify an output filename.
%
% If the input is a data structure, then lat and long will be converted to the
% correct formats automatically.
%
% If lat, long, and alt are provided as inputs directly, then they must in the
% format of ddd.dddddd and meters.
% 

function [filename] = save_kml(lat,long,alt,filename)

% ------------------------------------------------------------------------------
% Check Input Arguments
% ------------------------------------------------------------------------------

% Set Defaults
usage_msg = 'Usage: [SavedFileName] = save_kml([data_struct or lat,long,alt],[opt FileName]);';
data = [];
ask_user_for_filename = 1;

% Determine input argument types
if (nargin == 1 && ischar(lat) && strcmpi(lat,'?')),
    disp(usage_msg);
    disp('Notes: If lat and long are specifed directly, they should be in ddd.dddddd.');
    disp('Use convert_gps_2_deg() to convert raw gps data (ddd.mmmmmm) to decimal degrees.');
    disp('Altitude should be in meters.');
    return;
    
elseif (nargin == 1 && isstruct(lat)),
    % User only provided a data_struct as input
    data = lat;
    % ask_user_for_filename = 1;
    
elseif (nargin == 2 && isstruct(lat)),
    % User provided data_struct and filename
    data = lat;
    filename = long;
    ask_user_for_filename = 0;
    
elseif (nargin == 2 && isnumeric(lat) && isnumeric(long)),
    % User provided lat and long
    data.gps.lat = lat;
    data.gps.long = long;
    % ask_user_for_filename = 1;
    
elseif (nargin == 3 && isnumeric(lat) && isnumeric(long) && isnumeric(alt)),
    % User provided lat, long, alt
    data.gps.lat = lat;
    data.gps.long = long;
    data.gps.alt = alt;
    % ask_user_for_filename = 1;
    
elseif (nargin == 3 && isnumeric(lat) && isnumeric(long) && ischar(alt)),
    % User provided lat, long, filename
    data.gps.lat = lat;
    data.gps.long = long;
    filename = alt;
    ask_user_for_filename = 0;

elseif (nargin == 4 && isnumeric(lat) && isnumeric(long) && isnumeric(alt) && ischar(filename)),
    % User provided lat, long, alt, and filename
    data.gps.lat = lat;
    data.gps.long = long;
    data.gps.alt = alt;
    ask_user_for_filename = 0;
    
else,
    error(usage_msg);
end;
    
% Check for data.gps.alt and create it if it does not exist
if (~isfield(data.gps,'alt')),
    data.gps.alt = zeros(length(data.gps.lat),1);
end;


% ------------------------------------------------------------------------------
% Header Setup & Data Conversions
% ------------------------------------------------------------------------------
if (isfield(data,'meta')),
    % Title
    title = [data.meta.study ' Driver ' data.meta.driver ' ' data.meta.vehicle...
        ' Trip ' data.meta.tripid];
    
    % Description
    description = ['Trip Date: ' data.meta.date(3:4) '/' data.meta.date(5:6) '/' data.meta.date(1:2)];
    if (~isempty(data.ts.utc_ssm)),
        tripstart = convert_text_ts(data.ts.utc_ssm(1));
        tripend = convert_text_ts(data.ts.utc_ssm(length(data.ts.utc_ssm)));
        tripstart = ['UTC Start: ' tripstart];
        tripend = ['UTC End: ' tripend];
    else,
        tripstart = data.ts.text(1,:);
        tripend = data.ts.text(length(data.ts.text),:);
        tripstart = ['Clock Start: ' tripstart];
        tripend = ['Clock End: ' tripend];
    end;

    % Convert lat and long from dddmm.mmmmmm ddd.ddddddd
    data.gps.lat = convert_gps_2_deg(data.gps.lat);
    data.gps.long = convert_gps_2_deg(data.gps.long);
else,
    title = 'Add title here.';
    description = 'Add trip description here.';
    tripstart = 'This is where the trip data starts.';
    tripend = 'This is where the trip data ends.';
end;

% ------------------------------------------------------------------------------
% Ask User For Filename & Filename Checking
% ------------------------------------------------------------------------------
if (ask_user_for_filename),
    filename = ui_get_save_as_filename('-kml');
    if (isempty(filename)),
        return;
    end;
end;

if exist(filename,'file') == 0,
    progress_bar_msg = ['Saving ' filename];
elseif exist(filename,'file') == 2,
    progress_bar_msg = ['Overwriting ' filename];
else,
    error('%s%s\n%s', 'Attempted to save ',filename,'However, the specified filename is invalid.');
end;
progress_bar_msg = strrep(progress_bar_msg,'\','\\');
progress_bar_msg = strrep(progress_bar_msg,'_','\_');
progress_bar = waitbar(0,progress_bar_msg);


% ------------------------------------------------------------------------------
% Filter Down the GPS Points to Remove Duplicates
%
% KML files appear to have a limit on the number of points allowed in a path
% definition, resulting in the path line not being drawn.
% ------------------------------------------------------------------------------

% Initialize The Difference Matrix
len = length(data.gps.lat);
diff = zeros(len,1);

% Include the first value in the final filter 
diff(1,1) = 1;

% Subtract the previous values from the current values
% If neither lat nor long changed, the result should be 0
diff(2:len,1) = (data.gps.lat(2:len) - data.gps.lat(1:len-1)) + ...
                (data.gps.long(2:len) - data.gps.long(1:len-1));

% Include the last value in the final filter even if it's repeated
diff(len,1) = 1;

% The final filter should include only non-zero entries
filter = find(diff ~= 0);
clear len diff;

% ------------------------------------------------------------------------------
% Write Data to File
% ------------------------------------------------------------------------------
[fid message] = fopen(filename,'w');
if ~isempty(message),
    disp(['Warning: Attempted to save ' filename]);
    disp('Encountered the following error:');
    disp(message);
    disp('Save Data Operation Aborted!');
    filename = [];
    fclose(fid);
    return;
end;

% Write Headers & Opening Tags
fprintf(fid,'%s\n','<?xml version="1.0" encoding="UTF-8"?>');
fprintf(fid,'%s\n','<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">');
fprintf(fid,'%s\n','<Document>');

% Overall Trip Title & Description
fprintf(fid,'\t%s\n',['<name>' title '</name>']);
fprintf(fid,'\t%s\n','<open>1</open>');
fprintf(fid,'\t%s%s%s\n\n','<description>',description,'</description>');

% Trip Route Style
fprintf(fid,'\t%s\n\t\t%s\n\t\t\t%s\n\t\t\t%s\n\t\t%s\n\t%s\n\n',...
    '<Style id="TripRoute">','<LineStyle>','<color>ffff7114</color>',...
	'<width>10</width>','</LineStyle>','</Style>');

% Trip Start Point Style
fprintf(fid,'\t%s\n\t\t%s\n\t\t\t%s\n\t\t\t%s\n\t\t\t%s\n\t\t%s\n\t\t%s\n\t\t\t%s\n\t\t\t%s\n\t\t%s\n\t%s\n\n',...
    '<Style id="TripStart">','<IconStyle>','<scale>1.1</scale>',...
    '<Icon><href>http://maps.google.com/mapfiles/kml/paddle/ylw-diamond.png</href></Icon>',...
	'<hotSpot x=".5" y="1" xunits="fraction" yunits="pixels"/>','</IconStyle>',...
	'<LabelStyle>','<scale>1.1</scale>','<color>ff00ffff</color>','</LabelStyle>','</Style>');

% Trip End Point Style
fprintf(fid,'\t%s\n\t\t%s\n\t\t\t%s\n\t\t\t%s\n\t\t\t%s\n\t\t%s\n\t\t%s\n\t\t\t%s\n\t\t\t%s\n\t\t%s\n\t%s\n\n',...
    '<Style id="TripEnd">','<IconStyle>','<scale>1.1</scale>',...
    '<Icon><href>http://maps.google.com/mapfiles/kml/paddle/ylw-stars.png</href></Icon>',...
	'<hotSpot x=".5" y="1" xunits="fraction" yunits="pixels"/>','</IconStyle>',...
	'<LabelStyle>','<scale>1.1</scale>','<color>ff00ffff</color>','</LabelStyle>','</Style>');

% Mark Trip Start
fprintf(fid,'\t%s\n\t\t%s\n','<Placemark>','<name>Trip Start</name>');
fprintf(fid,'\t\t%s%s%s\n\t\t%s\n','<description>',tripstart,'</description>','<LookAt>');
fprintf(fid,'\t\t\t%s%012.7f%s\n','<longitude>',data.gps.long(1),'</longitude>');
fprintf(fid,'\t\t\t%s%012.7f%s\n','<latitude>',data.gps.lat(1),'</latitude>');
fprintf(fid,'\t\t\t%s%d%s\n','<altitude>',0,'</altitude>');
fprintf(fid,'\t\t\t%s%d%s\n','<range>',3000,'</range>');
fprintf(fid,'\t\t%s\n \t\t%s\n \t\t%s\n \t\t\t%s\n','</LookAt>',...
    '<styleUrl>#TripStart</styleUrl>','<Point>','<coordinates>');
fprintf(fid,'\t\t\t\t%012.7f%s%012.7f\n',data.gps.long(1),',',data.gps.lat(1));
fprintf(fid,'\t\t\t%s\n\t\t%s\n\t%s\n\n','</coordinates>','</Point>','</Placemark>');

% Mark Trip Route
fprintf(fid,'\t%s\n\t\t%s\n','<Placemark>','<name>Trip Route</name>');
fprintf(fid,'\t\t%s%s%s\n\t\t%s\n\t\t%s\n','<description>','This is the route taken by the driver.',...
    '</description>','<styleUrl>#TripRoute</styleUrl>','<LineString>');
fprintf(fid,'\t\t\t%s\n\t\t\t%s\n\t\t\t%s\n\t\t\t%s\n','<extrude>0</extrude>',...
		'<tessellate>1</tessellate>','<altitudeMode>clampToGround</altitudeMode>',...
		'<coordinates>');

% Loop Through All GPS Data Points
total_progress = length(filter);
for i=1:total_progress,
    row = filter(i);
    fprintf(fid,'\t\t\t\t%012.7f%s%012.7f%s%06.1f\n',data.gps.long(row),',',...
        data.gps.lat(row),',',data.gps.alt(row));
    if (mod(i,1000) == 0),
        waitbar(i/total_progress,progress_bar);
    end;
end;
fprintf(fid,'\t\t\t%s\n\t\t%s\n\t%s\n\n','</coordinates>','</LineString>','</Placemark>');

% Mark Trip End
fprintf(fid,'\t%s\n\t\t%s\n','<Placemark>','<name>Trip End</name>');
fprintf(fid,'\t\t%s%s%s\n\t\t%s\n','<description>',tripend,'</description>','<LookAt>');
fprintf(fid,'\t\t\t%s%012.7f%s\n','<longitude>',...
    data.gps.long(length(data.gps.long)),'</longitude>');
fprintf(fid,'\t\t\t%s%012.7f%s\n','<latitude>',data.gps.lat(length(data.gps.lat)),'</latitude>');
fprintf(fid,'\t\t\t%s%d%s\n','<altitude>',0,'</altitude>');
fprintf(fid,'\t\t\t%s%d%s\n','<range>',3000,'</range>');
fprintf(fid,'\t\t%s\n \t\t%s\n \t\t%s\n \t\t\t%s\n','</LookAt>',...
    '<styleUrl>#TripEnd</styleUrl>','<Point>','<coordinates>');
fprintf(fid,'\t\t\t\t%012.7f%s%012.7f\n',data.gps.long(length(data.gps.long)),...
    ',',data.gps.lat(length(data.gps.lat)));
fprintf(fid,'\t\t\t%s\n\t\t%s\n\t%s\n\n','</coordinates>','</Point>','</Placemark>');

% Closing Tags
fprintf(fid,'%s\n','</Document>');
fprintf(fid,'%s','</kml>');

% ------------------------------------------------------------------------------
% Close Open File
% ------------------------------------------------------------------------------
fclose(fid);
waitbar(1,progress_bar);
close(progress_bar);
pause(0.1);
end