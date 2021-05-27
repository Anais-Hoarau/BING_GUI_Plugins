function initMeta(trip_path,sujet,scenario,type_distraction,tic_id)
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_path, 0.04, true);
    
%    meta = trip.getMetaInformations();
    
%     metaParticipant = fr.lescot.bind.data.MetaParticipant();
%     metaParticipant.setAttribute('sujet',sujet);
%     trip.setParticipant(metaParticipant);
    if any(strcmp(scenario,{'1','6','8'}))
        type_route = 'autoroute';
    elseif any(strcmp(scenario,{'1','6','8'}))
        type_route = 'rural';
    else
        type_route = 'urbain';
    end

    trip.setAttribute('sujet',sujet);
    trip.setAttribute('scenario',scenario);
    trip.setAttribute('type_route',type_route);
    trip.setAttribute('type_distraction',type_distraction);
    
    trip.setAttribute('import_video','Non');
    trip.setAttribute('import_cardio','Non');
    trip.setAttribute('import_facelab','Non');
    trip.setAttribute('calcul_POI','Non');
    trip.setAttribute('complet','Non');
    trip.setAttribute('timecode_reference','heureGMT');
    converstion_time = toc(tic_id);
    trip.setAttribute('converstion_time',num2str(converstion_time));

    delete(trip);
end