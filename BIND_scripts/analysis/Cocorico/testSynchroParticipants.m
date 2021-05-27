function testSynchroParticipants()
MAIN_FOLDER = 'E:\PROJETS ACTUELS\COCORICO\DONNEES_PARTICIPANTS';
trip_files = dirrec(MAIN_FOLDER, '.trip');

%% LOOP ON FOLDERS
i_tripValide = 1;
i_badTrip = 1;
for i_trip = 1:length(trip_files)
    trip_file = trip_files{i_trip};
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    try
        ratio{i_tripValide, 1} = trip_file;
        ratio{i_tripValide, 2} = str2double(trip.getAttribute('ratio_deltaTC (=deltaRef/deltaSimu)'));
        if ratio{i_tripValide, 2} > 1.0005 || ratio{i_tripValide, 2} < 0.9998
            badRatio{i_badTrip, 1} = ratio{i_tripValide, 1};
            badRatio{i_badTrip, 2} = ratio{i_tripValide, 2};
            ratio{i_tripValide, 1} = NaN;
            ratio{i_tripValide, 2} = NaN;
            i_badTrip = i_badTrip + 1;
        end
        i_tripValide = i_tripValide + 1;
    catch
        disp(['error with : ' trip_file]);
    end
    delete(trip)
end
ratioNum = cell2mat(ratio(:,2));
for i=1:length(ratioNum)
    if strcmp(num2str(ratioNum(i)), 'NaN')
        ratioNum(i)=1;
    end
end
meanRatio = mean(ratioNum);
disp(meanRatio);
disp(badRatio);