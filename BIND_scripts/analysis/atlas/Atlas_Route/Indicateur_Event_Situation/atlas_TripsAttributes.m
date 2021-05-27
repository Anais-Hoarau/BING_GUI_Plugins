function out=atlas_TripsAttributes(trip,full_directory)
out='';


clap_start = str2double(trip.getAttribute('mopad_top_clap_start'));
clap_stop = str2double(trip.getAttribute('mopad_top_clap_stop'));

process =1;

metas = trip.getMetaInformations;
if metas.existData('Kvaser_ABR')
    
    record = trip.getDataOccurencesInTimeInterval('Kvaser_ABR',clap_start,clap_stop);
    
    timecode = cell2mat(record.getVariableValues('timecode'));
    duree = (timecode(end) - timecode(1))/60 ; % durée du trip en minutes
    
    vitesse = cell2mat(record.getVariableValues('VITESSE_VEH_ROUES'));
    vitesse_mean = mean (vitesse(vitesse > 5)); % vitesse Moyenne sur tout le trip supérieur à 5km/h
    vitesse_sdt = std (vitesse(vitesse > 5)); % vitesse Moyenne sur tout le trip supérieur à 5km/h
    
    record = trip.getDataOccurencesInTimeInterval('Kvaser_VOL',clap_start,clap_stop);
    angleVolant= cell2mat(record.getVariableValues('ANGLE_VOLANT'));
    steering_mean = mean (angleVolant);
    steering_std = std(angleVolant);
    
    
   
    
elseif metas.existData('Mopad_CAN')
    
    record = trip.getDataOccurencesInTimeInterval('Mopad_CAN',clap_start,clap_stop);
    
    timecode = cell2mat(record.getVariableValues('timecode'));
    duree = (timecode(end) - timecode(1))/60 ; % durée du trip en minutes
    
    vitesse = cell2mat(record.getVariableValues('VITESSE_VEHICULE_ROUES'));
    vitesse_mean = mean (vitesse(vitesse > 5)); % vitesse Moyenne sur tout le trip supérieur à 5km/h
    vitesse_sdt = std (vitesse(vitesse > 5)); % vitesse Moyenne sur tout le trip supérieur à 5km/h
    
    angleVolant= cell2mat(record.getVariableValues('ANGLE_VOLANT'));
    steering_mean = mean (angleVolant);
    steering_std = std(angleVolant);
    
else
  process =0;  
end
    
 %% Creation des attributs du trips
 if process==1   
    trip.setAttribute('duree_trip',num2str(duree))
    
    trip.setAttribute('v_moy_trip',num2str(vitesse_mean));
    trip.setAttribute('v_std_trip',num2str(vitesse_sdt));
    
    trip.setAttribute('steering_moy_trip',num2str(steering_mean));
    trip.setAttribute('steering_std_trip',num2str(steering_std));
    
 elseif process==0
     
    trip.setAttribute('duree_trip', 'data absente')
    
    trip.setAttribute('v_moy_trip','data absente');
    trip.setAttribute('v_std_trip','data absente');
    
    trip.setAttribute('steering_moy_trip','data absente');
    trip.setAttribute('steering_std_trip','data absente');
 end
 
end