  [xlsName,xlsPath]= uigetfile('*.xls', 'Selectionnez le fichier .xls contenant les POI');
  [tripName, tripPath] = uigetfile('*.trip', 'Selectionnez le fichier .trip à enrichir');
  
  tripFullFile =fullfile(tripPath,tripName); 
  xlsFullFile = fullfile(xlsPath,xlsName);
  
  addPOI(tripFullFile,xlsFullFile);
  enrichSections(tripFullFile);