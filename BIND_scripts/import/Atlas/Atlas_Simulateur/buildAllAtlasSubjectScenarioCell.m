% renvoie un subject_scenario_cell: cell array à n lignes et 5 colonnes.
% Chaque ligne correspond à un trip
% Les colonnes correspondend à :
% 1. Nom du dossier du sujet
% 2. Nom du sous-dossier du scenario
% 3. Numéro du sujet
% 4. Numéro du scénario
% 5. Type de distraction (C, DV, DVS)

function subject_scenario_cell = buildAllAtlasSubjectScenarioCell(dir_root)

    % On parcours l'arborescence de dossiers
    subject_dirs = dir(dir_root);
    subject_scenario_cell = {}; % dossier_sujet, dossier_sc, num_sujet, num_sc, type_distraction
    for i = 1:length(subject_dirs)
        if subject_dirs(i).isdir && ~any(strcmp(subject_dirs(i).name,{'.' '..' 'POI'})) 
            scenario_dirs = dir([dir_root filesep subject_dirs(i).name]);
            for j = 1:length(scenario_dirs)
                if scenario_dirs(j).isdir && ~any(strcmp(scenario_dirs(j).name,{'.' '..'}))
                    subject_scenario_cell{end+1,1} = subject_dirs(i).name;
                    subject_scenario_cell{end,2} = scenario_dirs(j).name;
                    num_sujet = regexp(subject_dirs(i).name,'[0-9]+','match','once');
                    subject_scenario_cell{end,3} = num_sujet;
                    num_scenario = regexp(scenario_dirs(j).name,'[0-9]+(?=_[CDVS]+)','match','once');
                    subject_scenario_cell{end,4} = num_scenario;
                    type_distraction = regexp(scenario_dirs(j).name,'[CDVS]+$','match','once');
                    subject_scenario_cell{end,5} = type_distraction;
                end
            end
        end
    end

end