clear all
close all


folder_lists = {'D:\LESCOT\Projets\ATLAS\Atlas Route\preManip\Manip 25 avril 2013\Seb_130425_15h02'};
        %% On boucle sur les TRIPS
    for i = 1:length(folder_lists)
        
        full_directory = folder_lists{i};
        trip_file = [full_directory filesep 'magic_imported_trip.trip'];
        trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, true);
        
        %% Définition du trajet: Trajet Aller AutoRoute
         timecode_debut = 1689.75387810299;
        timecode_fin = 3754.06836548464;
         
         temps_total =(timecode_fin - timecode_debut)/60.0;
         disp(['Temps total : ' num2str(temps_total) ' min' sprintf('\n')]);
        
%         
%         %% Traitement Topage Clavier
%         
%         record = trip.getDataOccurencesInTimeInterval('Mopad_TopageClavier',timecode_debut,timecode_fin);
%                      
%         
%         timecode = cell2mat(record.getVariableValues('timecode'));
%         time = cell2mat(record.getVariableValues('time'));
%        
%         %ligne droite/courbe
%         F2=cell2mat(record.getVariableValues('F2'));
%         F3=cell2mat(record.getVariableValues('F3'));
%         
%         timecode_F2=filtrer_timecode(timecode(F2==1),1);
%         timecode_F3=filtrer_timecode(timecode(F3==1),1);
%         
%         %montée descente/plat
%         F5=cell2mat(record.getVariableValues('F5'));
%         F6=cell2mat(record.getVariableValues('F6'));
%         F7=cell2mat(record.getVariableValues('F7'));
%         
%         timecode_F5=filtrer_timecode(timecode(F5==1),1);
%         timecode_F6=filtrer_timecode(timecode(F6==1),1);
%         timecode_F7=filtrer_timecode(timecode(F7==1),1);
%         
%         
%         %début autouroute
%         F9=cell2mat(record.getVariableValues('F9'));
%         timecode_F9=filtrer_timecode(timecode(F9==1),1);
%   
%         F2_filtre= [timecode_F2' 2*ones(length(timecode_F2),1)];
%         F3_filtre= [timecode_F3' 3*ones(length(timecode_F3),1)];
%         F5_filtre= [timecode_F5' 5*ones(length(timecode_F5),1)];
%         F6_filtre= [timecode_F6' 6*ones(length(timecode_F6),1)];
%         F7_filtre= [timecode_F7' 7*ones(length(timecode_F7),1)];
%         F9_filtre= [timecode_F9' 9*ones(length(timecode_F9),1)];
%         
%         %tableau = sortrows([F2_filtre ; F3_filtre ; F5_filtre ; F6_filtre
%         %; F7_filtre]);
%         tableau = sortrows([F2_filtre ; F3_filtre ; F5_filtre ; F6_filtre ; F7_filtre ;  F9_filtre]);
%         
%         situation_lignedroite_courbe=[2 3];
%         nom_siutation={'ligne droite' , 'ligne courbe'};
%         [time_lignedroite,time_courbe,list_ld_lc]= decompter_temps(tableau,situation_lignedroite_courbe);
%         
%             %Affichage
%             disp(['Temps ligne droite : ' num2str(time_lignedroite) ' min' sprintf('\n') ...
%                   'Temps ligne courbe : ' num2str(time_courbe) ' min' sprintf('\n')]);
% 
%             for i=1:1:length(situation_lignedroite_courbe)
%                 for j=1:1:length(list_ld_lc{i})
%                     disp([nom_siutation{i} ' ' num2str(j) ' : ' num2str(list_ld_lc{i}(j) / 60.0 ) ' min']);
%                 end
%                 fprintf('\n');
%             end
%           
%         situation_plat_montee_descente=[5 6 7];
%         nom_siutation={'plat' , 'montée' , 'descente'};
%         [time_plat,time_montee,time_descente,list_p_m_d]= decompter_temps(tableau,situation_plat_montee_descente);
%         
%             %Affichage
%             disp(['Temps plat : ' num2str(time_plat) ' min' sprintf('\n') ...
%                   'Temps montee : ' num2str(time_montee) ' min' sprintf('\n') ...
%                   'Temps descente : ' num2str(time_descente) ' min' sprintf('\n') ...
%                  ]);
%         
%             for i=1:1:length(situation_plat_montee_descente)
%                 for j=1:1:length(list_p_m_d{i})
%                     disp([nom_siutation{i} ' ' num2str(j) ' : ' num2str(list_p_m_d{i}(j) / 60.0 ) ' min']);
%                 end
%                 fprintf('\n');
%             end
         
         %% Traitement Données GPS / Calcul Sinuosité
         
%         record = trip.getDataOccurencesInTimeInterval('Mopad_Synchrovideo',timecode_debut,timecode_fin);
% 
%         timecode = cell2mat(record.getVariableValues('timecode'));
%         time = cell2mat(record.getVariableValues('time'));
% 
%         TempsMagneto = (cell2mat(record.getVariableValues('TempsMagneto')))/60.0;  
%           
%         record = trip.getDataOccurencesInTimeInterval('Mopad_CAN',timecode_debut,timecode_fin);
%         angle_volant = cell2mat(record.getVariableValues('ANGLE_VOLANT'));
%         
%         record = trip.getDataOccurencesInTimeInterval('Mopad_GPS_5Hz',timecode_debut,timecode_fin);
%         cap = cell2mat(record.getVariableValues('Cap_5Hz'));
%         
%         record = trip.getDataOccurencesInTimeInterval('Mopad_CentraleInertielle_IGN500',timecode_debut,timecode_fin);
%         latitude = cell2mat(record.getVariableValues('GPSraw_latitude'));
%         longitude = cell2mat(record.getVariableValues('GPSraw_longitude'));
%         height = cell2mat(record.getVariableValues('GPSraw_height'));
%         
        
%         [timecode_filtre,latitude_filtre,longitude_filtre,height_filtre] = filtrer_donnees_GPS(timecode,latitude,longitude,height);
%        
%        %data =[latitude_filtre longitude_filtre height_filtre];
%        %save donnees_GPS.txt data -ASCII  
%        
%        %calcul d'un coefficient de sinuosité
%         j=1;
%         liste_index=(1:1:length(latitude_filtre));
%         ponderation=zeros(1,length(latitude_filtre));
%         one_array=ones(1,length(latitude_filtre));
%         sum_sinuosity=zeros(1,length(latitude_filtre));
%        
%         figure
%         hold on
%         for ordre=50:50:200
%             
%         sinuosity=calculer_sinuosite(latitude_filtre,longitude_filtre,ordre);
%         plot(sinuosity,'Color',[(1.0/j) 0 1-(1.0/j)], 'LineWidth',1.2);
%         
%         sum_sinuosity=sum_sinuosity+sinuosity;
%         ponderation = ponderation + 1*(sinuosity~=0);
%         
%         j=j+1;
%         end
%         
%         mean_sinuosity=sum_sinuosity./ponderation;
%         
%         ax1=gca;
%         fig1=get(ax1,'children');
%                 
%         figure
%         s1=subplot(3,1,1); plot(longitude_filtre,latitude_filtre)
%         title('longitude vs latitude')
%         s2=subplot(3,1,2); plot(mean_sinuosity);
%         title('Sinuosity')
%         s3=subplot(3,1,3); 
%         title('Sinuosity evolution (order)')
%         ylim([0.95 1.5])
%         copyobj(fig1,s3)
%         
%         
%         web('http://maps.google.com/maps?saddr=Bd+de+l%27Universit%C3%A9%2FD112&daddr=A43&hl=en&ie=UTF8&sll=45.570193,5.776234&sspn=0.097938,0.222988&geocode=FR61uQId5SNLAA%3BFWF6twIdHXhYAA&mra=dme&mrsp=1&sz=13&t=m&z=10')
        
        
          %% Traitement des data Dynamique du véhicule
          
        record = trip.getDataOccurencesInTimeInterval('Mopad_SensorsMeasures',timecode_debut,timecode_fin);
        
        timecode = cell2mat(record.getVariableValues('timecode'));
        time = cell2mat(record.getVariableValues('time'));
        
        DrivenDistance_L = cell2mat(record.getVariableValues('DistanceDriven_L'));
        DrivenDistance_R = cell2mat(record.getVariableValues('DistanceDriven'));
        DrivenDistance=(DrivenDistance_R+DrivenDistance_L) /2;
        
        Speed_L = cell2mat(record.getVariableValues('Speed_L'));
        Speed_R = cell2mat(record.getVariableValues('Speed'));
        Speed=(Speed_R+Speed_L) /2;
        
%         figure
%         subplot(2,1,1); plot(timecode,Speed)
%         title('Speed vs. Timecode')
%         subplot(2,1,2); plot(timecode,moving(Speed,100))
%         title('Speed average vs. Timecode')
        
        record = trip.getDataOccurencesInTimeInterval('Mopad_CentraleInertielle_IGN500',timecode_debut,timecode_fin);
        roll = cell2mat(record.getVariableValues('Roll'));
        pitch = cell2mat(record.getVariableValues('Pitch'));
        yaw = cell2mat(record.getVariableValues('Yaw'));
        
        
        [timecode_pitch,pitch_filtre] = filtrer_data_asynchrone(timecode,pitch);
        pitch_filtre=moving(pitch_filtre,30);
        
        seuil =1.8;
        inclinaison= -1*ones(1,length(pitch_filtre));
        
        inclinaison(pitch_filtre>=seuil) = 1;
        inclinaison(pitch_filtre<seuil & pitch_filtre>-seuil)=0;
        inclinaison(pitch_filtre<=-seuil)=-1;
        
%         figure
%         subplot(3,1,1); plot(timecode_pitch,pitch_filtre)
%         title('pitch vs. timecode')
%         
%         subplot(3,1,2); plot(timecode_pitch,inclinaison);
%         title(['pitch seuil.  Seuil = ' num2str(seuil) ' unité à vérifier'])
%         
%         
%         derive_pitch = diff(pitch_filtre')./ diff(timecode_pitch);
%         subplot(3,1,3); plot(timecode_pitch(1:end-1) , derive_pitch)
%         title('derivee pitch vs. time')

        %%
        
        record = trip.getDataOccurencesInTimeInterval('Kvaser_IS_DAT_BSI',timecode_debut,timecode_fin);
        timecode_bsi=cell2mat(record.getVariableValues('timecode'));
        contact_frein1=cell2mat(record.getVariableValues('CONTACT_FREIN1'));
        
        record = trip.getDataOccurencesInTimeInterval('Kvaser_IS_DYN_CMM',timecode_debut,timecode_fin);
        timecode_cmm=cell2mat(record.getVariableValues('timecode'));
        contact_frein2=cell2mat(record.getVariableValues('CONTACT_FREIN2'));
        regulation = cell2mat(record.getVariableValues('ETAT_RVV_LVV'));
        
        record = trip.getDataOccurencesInTimeInterval('Mopad_CAN',timecode_debut,timecode_fin);
        timecode_mopad=cell2mat(record.getVariableValues('timecode'));
        mopad_contact_frein1=cell2mat(record.getVariableValues('CONTACT_FREIN1'));
        mopad_contact_frein2=cell2mat(record.getVariableValues('CONTACT_FREIN2'));
        
        figure
        plot(timecode_bsi,contact_frein1,timecode_mopad,mopad_contact_frein1)
        
        figure
        plot(timecode_cmm,contact_frein2,timecode_mopad,mopad_contact_frein2)
        
        
%         figure
%         plotyy(timecode,Speed,timecode_can,regulation)
        
        %% toujours delete le trip, toujours !!
        delete(trip)
    end
    
    
    
    
    
    
    
    