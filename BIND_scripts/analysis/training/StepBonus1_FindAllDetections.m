[tripFile tripPath] = uigetfile('*.trip');
tic;
pathToTrip = [tripPath tripFile];
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(pathToTrip, 0.04, false);

allOcc = trip.getAllDataOccurences('vehicule');
indics = allOcc.getVariableValues('indics');
tcs = allOcc.getVariableValues('timecode');
for i = 1:1:length(indics)
    if isHeadlights(indics{i})
        disp(['--> Detection detected at ' num2str(tcs{i}) 's (binIndic : ' binIndic ')']);
    end
end
