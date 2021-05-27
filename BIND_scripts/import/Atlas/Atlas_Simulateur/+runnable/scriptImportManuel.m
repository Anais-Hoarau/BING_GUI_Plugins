%dir_root = 'Z:\ManipSimulateur_new\';
dir_root = 'C:\Documents and Settings\mathern\Bureau\dev-atlas\test_subject\20121108_test1\';
subject_scenario_cell = buildAllAtlasSubjectScenarioCell(dir_root);

% trouve sujet 05
ind_subject_scenario_cell = strcmp(subject_scenario_cell(:,3),'05');

% trouve sujet 18
%ind_subject_scenario_cell = strcmp(subject_scenario_cell(:,3),'18');

% Import prioritaire
% ind_subject_scenario_cell = strcmp(subject_scenario_cell(:,3),'01');
% ind_subject_scenario_cell = ind_subject_scenario_cell | strcmp(subject_scenario_cell(:,3),'04');
% ind_subject_scenario_cell = ind_subject_scenario_cell | strcmp(subject_scenario_cell(:,3),'05');
% ind_subject_scenario_cell = ind_subject_scenario_cell | strcmp(subject_scenario_cell(:,3),'07');
% ind_subject_scenario_cell = ind_subject_scenario_cell | strcmp(subject_scenario_cell(:,3),'08');
% ind_subject_scenario_cell = ind_subject_scenario_cell | strcmp(subject_scenario_cell(:,3),'10');
% ind_subject_scenario_cell = ind_subject_scenario_cell | strcmp(subject_scenario_cell(:,3),'11');
% ind_subject_scenario_cell = ind_subject_scenario_cell | strcmp(subject_scenario_cell(:,3),'12');
% ind_subject_scenario_cell = ind_subject_scenario_cell | strcmp(subject_scenario_cell(:,3),'14');
% ind_subject_scenario_cell = ind_subject_scenario_cell | strcmp(subject_scenario_cell(:,3),'15');
% ind_subject_scenario_cell = ind_subject_scenario_cell | strcmp(subject_scenario_cell(:,3),'16');
% ind_subject_scenario_cell = ind_subject_scenario_cell | strcmp(subject_scenario_cell(:,3),'18');
% ind_subject_scenario_cell = ind_subject_scenario_cell | strcmp(subject_scenario_cell(:,3),'22');
% ind_subject_scenario_cell = ind_subject_scenario_cell | strcmp(subject_scenario_cell(:,3),'24');
% ind_subject_scenario_cell = ind_subject_scenario_cell | strcmp(subject_scenario_cell(:,3),'26');
% ind_subject_scenario_cell = ind_subject_scenario_cell | strcmp(subject_scenario_cell(:,3),'30');
% ind_subject_scenario_cell = ind_subject_scenario_cell | strcmp(subject_scenario_cell(:,3),'31');
% ind_subject_scenario_cell = ind_subject_scenario_cell | strcmp(subject_scenario_cell(:,3),'36');

%batchParseCardioEvents(dir_root,subject_scenario_cell(ind_subject_scenario_cell,:));
MagicBatchImportAtlas(dir_root,subject_scenario_cell(ind_subject_scenario_cell,:));