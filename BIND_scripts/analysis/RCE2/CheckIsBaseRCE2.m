function CheckIsBaseRCE2(MAIN_FOLDER)
MAIN_FOLDER = 'E:\PROJETS ACTUELS\RCE2\DONNEES_PARTICIPANTS\TESTS';
trip_list = dirrec(MAIN_FOLDER, '.trip');

%% CHECK

trip_file = trip_list{1};
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
meta_info = trip.getMetaInformations;
meta_data_names = meta_info.getDatasNamesList';
meta_events_names = meta_info.getEventsNamesList';
meta_situations_names = meta_info.getSituationsNamesList';
meta_names_all = {meta_data_names{:}, meta_events_names{:}, meta_situations_names{:}};
delete(trip);

for i_names = 8:9 %1:1:length(meta_names_all)
    disp([meta_names_all(i_names) 'est en cours de process'])
    for i_trip = 1:length(trip_list)
        disp([trip_list{i_trip} 'est en cours de process'])
        trip_file = trip_list{i_trip};
        reg_file = regexp(trip_file, '\');
        trip_name = trip_file(reg_file(end)+1:end);
        trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
        meta_info = trip.getMetaInformations;
        isBaseInfo.(meta_names_all{i_names}).(trip_name(1:end-14)) = [];
        if  meta_info.existData(meta_names_all{i_names})
            isBaseInfo.(meta_names_all{i_names}).(trip_name(1:end-14)) = [isBaseInfo.(meta_names_all{i_names}).(trip_name(1:end-14)), isBase(meta_info.getMetaData(meta_names_all{i_names}))];
        elseif meta_info.existEvent(meta_names_all{i_names})
            isBaseInfo.(meta_names_all{i_names}).(trip_name(1:end-14)) = [isBaseInfo.(meta_names_all{i_names}).(trip_name(1:end-14)), isBase(meta_info.getMetaEvent(meta_names_all{i_names}))];
        elseif meta_info.existSituation(meta_names_all{i_names})
            isBaseInfo.(meta_names_all{i_names}).(trip_name(1:end-14)) = [isBaseInfo.(meta_names_all{i_names}).(trip_name(1:end-14)), isBase(meta_info.getMetaSituation(meta_names_all{i_names}))];
        end
        delete(trip);
    end
end
end