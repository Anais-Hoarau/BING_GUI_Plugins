function out = safemove_conti2struct(trip,full_directory,sujet)
    out = '';
    data_file = [full_directory filesep sujet '_safemove.mat'];
    load(data_file);
%     [rem, tok] = strtok(sujet, 'E'); % parsing Sujets SafeEld
%     conti_file_name = [full_directory filesep tok '_conti.mat'];% pour Sujets SafeEld
    conti_file_name = [full_directory filesep sujet '_conti.mat'];% pour Sujets Reference
    load(conti_file_name);
    safemove.conti = conti;
    save([full_directory filesep sujet '_safemove_enriched.mat'],'safemove');
end