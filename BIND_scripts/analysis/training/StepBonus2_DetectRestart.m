[tripFile tripPath] = uigetfile('*.trip');
tic;
pathToTrip = [tripPath tripFile];
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(pathToTrip, 0.04, false);

allOcc = trip.getAllDataOccurences('vehicule');

timecodes  = cell2mat(allOcc.getVariableValues('timecode'));
vitesseMS = allOcc.getVariableValues('vitesse');
vitesseKMH = cell2mat(vitesseMS).*3.6;

aberrantPointsIndices = find(vitesseKMH == 0);
vitesseKMH(aberrantPointsIndices) = [];
timecodes(aberrantPointsIndices) = [];

smoothedSignal = fr.lescot.bind.processing.signalProcessors.MovingAverageSmoothing.process(num2cell([timecodes; vitesseKMH]), {'31'});

smoothedSpeed = smoothedSignal(2, :);

%crazy classifier of doom !
for i = 1:1:length(smoothedSpeed)
    speed = smoothedSpeed{i};
    classSize = 5;
    smoothedSpeed{i} = round(speed/classSize)*classSize + classSize/2;
end
smoothedTimecodes = smoothedSignal(1, :);

%Dectecting restart : 
%speed @ t < threshold
%speed @t+1 >= threshold
threshold = 10;
indexRestarts = [];
for i = 1:1:length(smoothedSpeed)-1
    if smoothedSpeed{i} < threshold && smoothedSpeed {i+1} >= threshold
        indexRestarts(end + 1) = i;
    end
end

plot(timecodes, cell2mat(smoothedSpeed));
set(gca, 'YLim', [-5 70]);
hold on;
stem(cell2mat(smoothedTimecodes(indexRestarts)), cell2mat(smoothedSpeed(indexRestarts)), 'color', 'r');

