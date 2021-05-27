function routine_namechange()
dir_manip = 'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS';
cd(dir_manip);


filename = 'D:\LESCOT\PROJETS\ATLAS\Atlas Route\DONNEES\MANIPS\atlas_route.xlsx';
sheet = 1;

nbre_participant =18;

xlRange = ['A2:C' num2str(nbre_participant+1)];
[~, xls_file, ~] = xlsread(filename, sheet, xlRange);



files = dir(dir_manip);

for i_dir=1:1:length(files)
    
    if files(i_dir).isdir
        
        if any(strcmp(xls_file(:,1),files(i_dir).name))
            
            %creation des nouveaux répertoires
            old_name = files(i_dir).name;
            disp(['Traitement du dossier ' old_name ' en cours ...'])
            old_dir = fullfile(dir_manip , old_name);
            old_dir_ALLER = fullfile(old_dir ,'ALLER');
            old_dir_RETOUR = fullfile(old_dir,'RETOUR');
            
            new_name = xls_file(strcmp(xls_file(:,1),old_name),2);
            new_dir = fullfile(dir_manip , new_name);
            mkdir(new_dir{1})
            new_dir_ALLER = fullfile(new_dir{1},'ALLER');
            new_dir_RETOUR = fullfile(new_dir{1},'RETOUR');
            mkdir(new_dir_ALLER)
            mkdir(new_dir_RETOUR)
            
            copy_folder(old_dir_ALLER,new_dir_ALLER,old_name,new_name)
            copy_folder(old_dir_RETOUR,new_dir_RETOUR,old_name,new_name)

        end
    end
end

end





