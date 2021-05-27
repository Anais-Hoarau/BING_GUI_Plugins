function test_shift_Safemove()
%MAIN_FOLDER = 'H:\SAFEMOVE SP2\DATA route';
MAIN_FOLDER = uigetdir();
trip_files = dirrec(MAIN_FOLDER, '.trip');

%% LOOP ON FOLDERS
i_tripValide = 1;
i_badTrip = 1;
for i_trip = 1:length(trip_files)
    trip_file = trip_files{i_trip};
    try
        trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
        ratio{i_tripValide, 1} = trip_file;
        ratio{i_tripValide, 2} = str2double(trip.getAttribute('mopad_video_shift'));
        if ratio{i_tripValide, 2} > 1.001 || ratio{i_tripValide, 2} < 0.9990
            badRatio{i_badTrip, 1} = ratio{i_tripValide, 1};
            badRatio{i_badTrip, 2} = ratio{i_tripValide, 2};
            i_badTrip = i_badTrip + 1;
        end
        i_tripValide = i_tripValide + 1;
        delete(trip)
        
    catch
        disp(['error with : ' trip_file]);
    end
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