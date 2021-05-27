dir_root = 'Z:\ManipSimulateur_new\';
subject_scenario_cell = buildAllAtlasSubjectScenarioCell(dir_root);

% trouve sujet 18
ind_subject_scenario_cell = strcmp(subject_scenario_cell(:,3),'18');

deleteAtlasTrips(dir_root,subject_scenario_cell(ind_subject_scenario_cell,:));