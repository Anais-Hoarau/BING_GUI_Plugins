    tripDir = uigetdir(pwd, 'Select the folder containing all the ".trip" files (including sub-folders)');
    toProcessFiles = dirrec(tripDir, '.trip');
    log = fopen([tripDir filesep 'failedProcesses.log'], 'w+');
    for i = 1:1:length(toProcessFiles)
        pathToTrip = toProcessFiles{i};
        [~, filename, ~] = fileparts(pathToTrip);
        version = filename(3);
        disp(['Processing ' pathToTrip]);
        try
            S0cleanSpeed(pathToTrip);
            S1createSituationsFromComments(pathToTrip);
            S2AcalculateTrafficLightIndicators(pathToTrip);
            S2BcalculateLeadVehicleIndicators(pathToTrip);
            S2CcalculateGapAcceptanceIndicators(pathToTrip, version);
            S2DcalculateAllTripIndicators(pathToTrip);
            S2EcalculateDistractionIndicators(pathToTrip);
        catch ME
           disp(ME.getReport());
           fprintf(log, '%s', ['######## ' pathToTrip ' ########' char(10)]);
           fprintf(log, '%s', ME.getReport('extended', 'hyperlinks', 'off'));
        end
    end
    fclose(log);
