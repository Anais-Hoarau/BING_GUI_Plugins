%Requires LEPSIS import scripts in path
convertedTrips = LEPSIS2BIND_all_trips();
for i = 1:1:length(convertedTrips)
    generateSituationForIAVehicules(convertedTrips{i});
    addAttributesToTripFromPath(convertedTrips{i});
end