function SgsasNewIndicators()

path_ALL = 'W:\PROJETS ACTUELS\2013- SGSAS\DATA_MARION\ALL';
path_CURVE = 'W:\PROJETS ACTUELS\2013- SGSAS\DATA_MARION\CURVE';
path_NEUTRAL = 'W:\PROJETS ACTUELS\2013- SGSAS\DATA_MARION\NEUTRAL';

path_list = [ {path_CURVE} ; {path_ALL} ; {path_NEUTRAL}];

for i_path=1:1:length(path_list)
    listing_trips = dir([path_list{i_path} '\*.trip']);
    
    for i=1:1:length(listing_trips)
        
        disp(['le trip  ' listing_trips(i).name  ' est en cours de traitement'])
        trip_name = listing_trips(i).name;
        trip_file = [path_list{i_path} filesep trip_name];
        participant_name = strsplit(trip_name, '.');
        corrected_var_file = [path_list{i_path} filesep 'var' filesep participant_name{1} '.tsv'];
        
        trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
        addVoieCorrigee(trip, corrected_var_file);
    end
end

end

% Ajout voie corrigée dans table 'trajectoire'
function addVoieCorrigee(trip, corrected_var_file)

% get values
variableSimuVPAllOccurences = trip.getAllDataOccurences('variables_simulateur');
variableSimuTimecodes = variableSimuVPAllOccurences.getVariableValues('timecode');
variableSimuPas = variableSimuVPAllOccurences.getVariableValues('pas');

fileID = fopen(corrected_var_file, 'r');
delimiter = '\t';
startRow = 2;
formatSpec = '%f%f%f%f%f%f%f%[^\n\r]';
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);

pas = dataArray{1, 1};
routeCorrigee = dataArray{1, 2};
voieCorrigee = dataArray{1, 3};

trip.setIsBaseData('trajectoire', 0);
trip.setIsBaseData('localisation', 0);

% create 'voieCorrigee' & 'routeCorrigee' column
MetaInformations = trip.getMetaInformations;
if ~MetaInformations.existDataVariable('trajectoire', 'voieCorrigee')
    bindVariable = fr.lescot.bind.data.MetaDataVariable();
    bindVariable.setName('voieCorrigee');
    bindVariable.setType('REAL');
    bindVariable.setUnit('');
    bindVariable.setComments('voieCorrigee selon algo de Fabrice Vienne');
    trip.addDataVariable('trajectoire', bindVariable);
end
if ~MetaInformations.existDataVariable('localisation', 'routeCorrigee')
    bindVariable = fr.lescot.bind.data.MetaDataVariable();
    bindVariable.setName('routeCorrigee');
    bindVariable.setType('TEXT');
    bindVariable.setUnit('');
    bindVariable.setComments('routeCorrigee selon algo de Fabrice Vienne');
    trip.addDataVariable('localisation', bindVariable);
end

% add DIV values
disp('Adding corrected data...');
i_occurence = 1;
for i_pas = 1:length(pas)-2
    if pas(i_pas) == variableSimuPas{i_occurence}
        trip.setDataVariableAtTime('trajectoire', 'voieCorrigee', variableSimuTimecodes{i_occurence}, voieCorrigee(i_pas));
        trip.setDataVariableAtTime('localisation', 'routeCorrigee', variableSimuTimecodes{i_occurence}, num2str(routeCorrigee(i_pas)));
        i_occurence = i_occurence + 1;
    end
end

trip.setIsBaseData('trajectoire', 1);
trip.setIsBaseData('localisation', 1);

end