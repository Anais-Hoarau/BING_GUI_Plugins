function autoTrack(hObject, eventdata, handles) %#ok<INUSL>

% This file is part of MoTrack.
% 
% MoTrack is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% MoTrack is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with MoTrack.  If not, see <http://www.gnu.org/licenses/>.

% Copyright (c) Josef Christian


data = getappdata(handles.hMain,'data');
frameNum = str2double(get(handles.frameNum,'String')) - 1;

I = data.I; %get(handles.hImage,'CData');
threshold = str2double(get(handles.threshold,'String'));
searchRadius = str2double(get(handles.searchRadius,'String'));
maxArea = str2double(get(handles.maxArea,'String'));
minArea = str2double(get(handles.minArea,'String'));
minSolidity = str2double(get(handles.minSolidity,'String'));
maxEccentricity = str2double(get(handles.maxEccentricity,'String'));

selectedMarkersInd = get(handles.markerListBox,'Value');

%% -------------
xStart = data.xMeasured(frameNum, selectedMarkersInd)';
yStart = data.yMeasured(frameNum, selectedMarkersInd)';

xMeasured = xStart;
yMeasured = yStart;


%% define main variables for kalman filter
dt = 1;  %sampling rate
acceleration = 0; % define acceleration magnitude to start
prosessNoise = 1; %process noise: the variability in how fast the Hexbug is speeding up (stdv of acceleration: meters/sec^2)
measurementNoise_x = 0.1;  %measurement noise in the horizontal direction (x axis).
measurementNoise_y = 0.1;  %measurement noise in the horizontal direction (y axis).
Ez = [measurementNoise_x 0; 0 measurementNoise_y];
Ex = [dt^4/4 0 dt^3/2 0; ...
    0 dt^4/4 0 dt^3/2; ...
    dt^3/2 0 dt^2 0; ...
    0 dt^3/2 0 dt^2].* prosessNoise^2; % Ex convert the process noise (stdv) into covariance matrix


%% mechanical model for calman filter
A = [1 0 dt 0; 0 1 0 dt; 0 0 1 0; 0 0 0 1]; %state update matrice
B = [(dt^2/2); (dt^2/2); dt; dt];
C = [1 0 0 0; 0 1 0 0];  %measurement function C


%% initize estimation variables for two dimensions
nTracks = length(selectedMarkersInd);

if  ~any(data.estimatedState(3,selectedMarkersInd,frameNum)) %data.estimatedState(3,:,frameNum) ~= 0
    estimatedState = zeros(4,data.nMarkers);
    initialState = [xMeasured, yMeasured, zeros(length(xMeasured),1) zeros(length(xMeasured),1)]';
    estimatedState(:,selectedMarkersInd) = initialState;
    P = Ex; % estimate of initial Hexbug position variance (covariance matrix)
else
    estimatedState = data.estimatedState(:,:,frameNum);
    P = data.P{frameNum};
    if isempty(P)
        P = Ex;
    end
end
    

%% do the kalman filter
% Predict next marker state (position and velocity)
for T = 1:nTracks
    estimatedState(:,selectedMarkersInd(T)) = A * estimatedState(:,selectedMarkersInd(T)) + B * acceleration;
end

%predict next covariance
P = A * P* A' + Ex;
% Kalman Gain
K = P*C'*inv(C*P*C'+Ez); %#ok<MINV>

%% image processing and blob detection
%threshold image and calcualte regionproporties
Ithresh = I > threshold;
propertySelectionIndex(1) = maxArea > 0 | minArea > 0;
propertySelectionIndex(2) = maxEccentricity < 1;
propertySelectionIndex(3) = minSolidity > 0;
properties = {'Area', 'Eccentricity','Solidity'};
regions = regionprops(double(Ithresh),I,'Centroid', properties{propertySelectionIndex});
centroids = cell2mat({regions.Centroid}');
if propertySelectionIndex(1)
area = [regions.Area]; %#ok<NASGU>
end
if propertySelectionIndex(2)
eccentricity = [regions.Eccentricity]; %#ok<NASGU>
end
if propertySelectionIndex(3)
   solidity = [regions.Solidity]; %#ok<NASGU>
end
comparisons = {'1 ', '& area > minArea', '& area < maxArea', '& eccentricity < maxEccentricity', '& solidity > minSolidity'};
comparisonIndex(1) = 1;
comparisonIndex(2) = minArea > 0;
comparisonIndex(3) = maxArea > 0;
comparisonIndex(4) = maxEccentricity < 1;
comparisonIndex(5) = minSolidity > 0;
%reduce detected regions to regions of interest
selectedRegions = eval([comparisons{1,logical(comparisonIndex)}]);
selectedCentroids = centroids(selectedRegions,:);
nDetections = size(selectedCentroids,1);
%first remove detections that are farther than search radius from any estimation
distances_1 = pdist([selectedCentroids; [estimatedState(1,selectedMarkersInd)', estimatedState(2,selectedMarkersInd)']]);
distances_1 = squareform(distances_1);
distances_1 = distances_1(1:nDetections,nDetections+1:end);
checkDistancesInd_1 = any(distances_1 < searchRadius,2);
rejectMarkerInd = ~any(distances_1 < searchRadius,1);
selectedCentroids = selectedCentroids(checkDistancesInd_1,:);
nDetections = size(selectedCentroids,1);

% assign detections to estimations and check if assignments are within search radius
searchRadiusCheck = 1;
while searchRadiusCheck 

    %create cost (=distance) matrix
    distances = pdist([selectedCentroids; [estimatedState(1,selectedMarkersInd)', estimatedState(2,selectedMarkersInd)']]);
    distances = squareform(distances);
    distances = distances(1:nDetections,nDetections+1:end);

    % assignment with hungarian algo
    [matching_temp, ~] = Hungarian(distances(:,~rejectMarkerInd));
    matching = zeros(nDetections,nTracks);
    matching(:,~rejectMarkerInd) = matching_temp;
    [detectionsIndex, estimationsIndex] = find(matching);

    %check if assignements are within searchRadius, reject if not
    checkDistances = distances;
    checkDistances(~logical(matching)) = nan;
    [checkDistancesInd, ~] = find(checkDistances > searchRadius);

    if ~isempty(checkDistancesInd)
        selectedCentroids(checkDistancesInd,:) = [];
        nDetections = size(selectedCentroids,1);
    else
        searchRadiusCheck = 0;
    end
end

if ~isempty(matching)
    xMeasured(logical(sum(matching,1))) = selectedCentroids(detectionsIndex,1);
    yMeasured(logical(sum(matching,1))) = selectedCentroids(detectionsIndex,2);
    xMeasured(~logical(sum(matching,1))) = 0;
    yMeasured(~logical(sum(matching,1))) = 0;
else
    xMeasured = zeros(nTracks,1);
    yMeasured = zeros(nTracks,1);
end

data.xMeasured(frameNum + 1,selectedMarkersInd) = xMeasured;
data.yMeasured(frameNum + 1,selectedMarkersInd) = yMeasured;


 %apply the assingment to the update
for T = 1:length(detectionsIndex)
    estimatedState(:,selectedMarkersInd(estimationsIndex(T))) = estimatedState(:,selectedMarkersInd(estimationsIndex(T))) + K * (selectedCentroids(detectionsIndex(T),:)' - C * estimatedState(:,selectedMarkersInd(estimationsIndex(T))));
end

% update covariance estimation.
P =  (eye(4)-K*C)*P;

data.P{frameNum + 1} = P;
data.estimatedState(:,:,frameNum + 1) = estimatedState;
setappdata(handles.hMain,'data',data)
