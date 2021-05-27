%% Ce sript permet de reimport un srtucture conti dans un trip

WORKING_DIR = 'D:\LESCOT\TRAITEMENT DE DONNEES\RADAR_CALCUL TIV\';

[FileName,PathName] = uigetfile([WORKING_DIR '*.trip']);
TRIP_FILE = fullfile(PathName,FileName);
clear FileName PathName

[FileName,PathName] = uigetfile([WORKING_DIR '*.mat']);
MAT_FILE = fullfile(PathName,FileName);
load(MAT_FILE);
clear FileName PathName

if strncmp(TRIP_FILE,MAT_FILE,4)
    % on instancie le trip
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(TRIP_FILE,0.04,false);
    MetasInfos = trip.getMetaInformations;
    if MetasInfos.existData('conti')
        disp('un structure conti existe déjà dans le trip sélectionné')
        break
    else      
       % create a metaSituation
       newMetaData = fr.lescot.bind.data.MetaData;
       
       % newMetaSituation.setName(commentaire_filtre(1:(indice_Start-1)));
       newMetaData.setName('conti');
       
       % create metaSituationVariables      
       Names = fieldnames(conti.data);
       N_Names = length(Names);
       var = cell(1,N_Names);
       for i_Names=1:1:N_Names
           if strcmp(Names{i_Names}, 'time_sync')
               Names{i_Names} = 'timecode';
           end         
           var{i_Names} = fr.lescot.bind.data.MetaDataVariable();
           var{i_Names}.setName(Names{i_Names});
           var{i_Names}.setType('REAL');
       end
                 
    % set the metaSituationVariables in the metaSituation
       newMetaData.setVariables(var);
       
    % add the metaSituation to the trip
        trip.addData(newMetaData);
        trip.setIsBaseData('conti',false)
    end
    
    for ii_Names=1:1:N_Names
        if ~strcmp(Names{ii_Names},'timecode')
        trip.setBatchOfTimeDataVariablePairs('conti',Names{ii_Names},num2cell([conti.data.time_sync.values conti.data.(Names{ii_Names}).values]'))
        end
    end
        
    delete(trip)
else
    disp('Le fichier .mat conti ne correspond pas au trip sélectionnée')
end