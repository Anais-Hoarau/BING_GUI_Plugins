function BatchFormatDataCapadyn

MAIN_FOLDER = 'E:\PROJETS ACTUELS\THESE_CAROLINE\CAPADYN\DONNEES_PARTICIPANTS\TESTS';

folders_list_ages = dir([MAIN_FOLDER '\GROUPE_AGES']);
folders_list_prec = dir([MAIN_FOLDER '\GROUPE_PREC']);
folders_list_tard = dir([MAIN_FOLDER '\GROUPE_TARD']);
folders_list = {folders_list_ages(3:end).name, folders_list_prec(3:end).name, folders_list_tard(3:end).name};

for i = 1:1:length(folders_list)
    if isdir([MAIN_FOLDER '\GROUPE_AGES\' folders_list{i}]) || isdir([MAIN_FOLDER '\GROUPE_PREC\' folders_list{i}]) || isdir([MAIN_FOLDER '\GROUPE_TARD\' folders_list{i}]) && isempty(strfind(folders_list{i}, '@'))
        
        
        
        
    end
end


end