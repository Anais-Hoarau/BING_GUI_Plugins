function batchImportAllAtlas()

    dir_root = 'Z:\ManipSimulateur_new\';
    subject_scenario_cell = buildAllAtlasSubjectScenarioCell(dir_root);
    BatchImportAtlas(dir_root,subject_scenario_cell);

end