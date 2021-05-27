function out=atlas_DecoupageDataCardiaque(trip,mat_file)
out='';

record_situation = trip.getAllSituationOccurences('double tache');
situation_start_tc = cell2mat(record_situation.getVariableValues('startTimecode'));
situation_end_tc = cell2mat(record_situation.getVariableValues('endTimecode'));

load(mat_file)
[struct_dir,struct_name,struct_ext]=fileparts(mat_file);
participant_name=fieldnames(atlas);
participant_name=participant_name{1};


if  exist(fullfile(struct_dir,'MP150_Situation'),'dir')==0
mkdir(fullfile(struct_dir,'MP150_Situation'))
MP150_stituation_dir = fullfile(struct_dir,'MP150_Situation');
for i_situation=1:1:length(situation_start_tc)
   
data(:,1) = atlas.(participant_name).MP150.data.Cardiaque_filtre.values ...
       (atlas.(participant_name).MP150.data.time_sync.values > situation_start_tc(i_situation) & atlas.(participant_name).MP150.data.time_sync.values < situation_end_tc(i_situation));
units(1,:) = atlas.(participant_name).MP150.data.Cardiaque_filtre.unit; 
labels(1,:) = atlas.(participant_name).MP150.data.Cardiaque_filtre.comments;

data(:,2) = atlas.(participant_name).MP150.data.Topconsigne.values ...
       (atlas.(participant_name).MP150.data.time_sync.values > situation_start_tc(i_situation) & atlas.(participant_name).MP150.data.time_sync.values < situation_end_tc(i_situation));
units(2,:) = 'Volts'; 
labels(2,:) = 'Topage   MEF';

isi = 1;
isi_units = 's';
start_sample = situation_start_tc(i_situation) ;


save(fullfile(MP150_stituation_dir,['MP150_Situation_' num2str(i_situation) '.mat']),'data','units','isi','isi_units','labels','start_sample','-v6')

clear data units isi isi_units labels start_sample
end

end

%% Allégement de la structure Atlas

fields=fieldnames(atlas.(participant_name).MP150.data);
for i=1:1:length(fields)
    
    if strcmp(fields{i},'Topconsigne') || strcmp(fields{i},'TopCons') || strcmp(fields{i},'time') || strcmp(fields{i},'Cardiaque') || strcmp(fields{i},'DeclareMindWandering')    
        atlas.(participant_name).MP150.data = rmfield(atlas.(participant_name).MP150.data , fields{i});
    end
end

save(mat_file,'atlas'); 

end