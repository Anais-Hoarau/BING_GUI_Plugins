MAIN_FOLDER = '\\vrlescot\THESE_GUILLAUME\RCE2\DONNEES_PARTICIPANTS\TESTS';

sujets = {'P01', 'P02', 'P03', 'P04', 'P05', 'P06', 'P07', 'P08', 'P09', 'P10', 'P11', 'P12', 'P13', 'P14', 'P15', 'P16', 'P17', 'P18'};
conditions = {'ADNP', 'ADP', 'ASNP', 'ASP', 'VDNP', 'VDP', 'VSNP', 'VSP'};
trip_list = dirrec(MAIN_FOLDER, '.trip')';
max_duration = 260000;
RCE2_heart_data = NaN(8,max_duration/2,18);
RCE2_heart_data_filt = NaN(8,max_duration/2,18);
RCE2_breath_data = NaN(8,max_duration/2,18);

for i = 1:length(sujets)
    sujet = sujets{i};
    for j = 1:length(conditions)
        condition = conditions{j};
        for k = 1:length(trip_list)
            trip_file = trip_list{k};
            if contains(trip_file, sujet) && contains(trip_file, condition)
                disp(['exporting : ' trip_file])
            	trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
                if existData(trip.getMetaInformations(),'MP150_data')
                    MP150_data = trip.getAllDataOccurences('MP150_data');
                    heart_data = cell2mat(MP150_data.getVariableValues('Cardiaque'));
                    heart_data_filt = cell2mat(MP150_data.getVariableValues('Cardiaque_filtre'));
                    breath_data = cell2mat(MP150_data.getVariableValues('Respiration'));
                    RCE2_heart_data(j,:,i) = heart_data(1:2:max_duration);
                    RCE2_heart_data_filt(j,:,i) = heart_data_filt(1:2:max_duration);
                    RCE2_breath_data(j,:,i) = breath_data(1:2:max_duration);
                    delete(trip)
                    clearvars MP150_data heart_data breath_data
                    break
                end
            end
        end 
    end
end

% save('\\vrlescot\THESE_GUILLAUME\RCE2\STAGE_M1\MP150_DATA\RCE2_ECG.mat', 'RCE2_heart_data')
save('\\vrlescot\THESE_GUILLAUME\RCE2\STAGE_M1\MP150_DATA\RCE2_ECGfilt.mat', 'RCE2_heart_data_filt')
% save('\\vrlescot\THESE_GUILLAUME\RCE2\STAGE_M1\MP150_DATA\RCE2_RESP.mat', 'RCE2_breath_data')