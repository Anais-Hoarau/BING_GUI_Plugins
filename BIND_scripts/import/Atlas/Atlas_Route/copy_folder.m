function copy_folder(old_dir,new_dir,old_name,new_name)

    listing_filesandfolders = dir(old_dir);
    % Boucle sur les fichiers et les dossiers
    for i=3:1:length(listing_filesandfolders)
        if listing_filesandfolders(i).isdir
            copyfile(fullfile(old_dir,listing_filesandfolders(i).name) , ...
                     fullfile(new_dir,replace_name(listing_filesandfolders(i).name,old_name,new_name)));

        else
            file_name_old = listing_filesandfolders(i).name;
            file_old = fullfile(old_dir,file_name_old);
            
            file_name_new = replace_name(file_name_old,old_name,new_name);
            
            copyfile(file_old,fullfile(new_dir,file_name_new));
        end
    end
    
end

function new_str = replace_name(old_str, old_name , new_name)
 new_str= regexprep(old_str,old_name,new_name, 'ignorecase');
end