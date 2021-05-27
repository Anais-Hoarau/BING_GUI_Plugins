%{
This script will build an XML description file from the content of a TRIP

An example XML file can be found on the redmine of the project
http://redmine.inrets.fr/projects/import/wiki

In a second step, the aim is then to update the XML if necessary (i.e. by adding comments, units...) and to use it to update
the trip meta information.

%}

function main()

% Select trip file
[tripFile, tripPath] = uigetfile('*.trip', 'Select a trip file');
if isequal(tripPath,0)
    disp('User selected Cancel')
    return;
end
fileWithBaseMetasInfos = [tripPath filesep tripFile];

% Select XML file
[xmlFile, xmlPath] = uiputfile('*.xml', 'Select an XML file name, that will creating with the meta informations of the trip');
if isequal(xmlPath,0)
    disp('User selected Cancel')
    return;
end
fileToCreateWithMetasInfos = [xmlPath filesep xmlFile];

theTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(fileWithBaseMetasInfos,0.04,true);

% Entete du fichier XML
xmlContentLine = {};
xmlContentLine{1} = '<?xml version="1.0" encoding="ISO-8859-1"?>';
xmlContentLine{2} = '<bind_mapping xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" >';

metas =  theTrip.getMetaInformations();
metaDatas = metas.getDatasList();
for i=1:length(metaDatas)
    bind_data_name = metaDatas{i}.getName();
    bind_data_isbase = metaDatas{i}.isBase();
    bind_data_comment = metaDatas{i}.getComments();
    bind_data_frequency = metaDatas{i}.getFrequency();
    xmlContentLine = { xmlContentLine{:} generateXMLDataDescription(bind_data_name,bind_data_isbase,bind_data_comment,bind_data_frequency)};
    metaDataVariables = metaDatas{i}.getVariables();
    for j=1:length(metaDataVariables)
        bind_variable_name = metaDataVariables{j}.getName();
        bind_variable_type = metaDataVariables{j}.getType();
        bind_variable_unit = metaDataVariables{j}.getUnit();
        bind_variable_comments = metaDataVariables{j}.getComments();
        xmlContentLine = { xmlContentLine{:} generateXMLVariableDescription(bind_variable_name,bind_variable_type,bind_variable_unit,bind_variable_comments) };
    end
    xmlContentLine = { xmlContentLine{:} sprintf('\t%s','</data_mapping>') };
end

metaEvents = metas.getEventsList();
for i=1:length(metaEvents)
    bind_event_name = metaEvents{i}.getName();
    bind_event_isbase = metaEvents{i}.isBase();
    bind_event_comment = metaEvents{i}.getComments();
    xmlContentLine = { xmlContentLine{:} generateXMLEventDescription(bind_event_name,bind_event_isbase,bind_event_comment)};
    metaEventVariables = metaEvents{i}.getVariables();
    for j=1:length(metaEventVariables)
        bind_variable_name = metaEventVariables{j}.getName();
        bind_variable_type = metaEventVariables{j}.getType();
        bind_variable_unit = metaEventVariables{j}.getUnit();
        bind_variable_comments = metaEventVariables{j}.getComments();
        xmlContentLine = { xmlContentLine{:} generateXMLVariableDescription(bind_variable_name,bind_variable_type,bind_variable_unit,bind_variable_comments) };
    end
    xmlContentLine = { xmlContentLine{:} sprintf('\t%s','</event_mapping>') };
end

metaSituations = metas.getSituationsList();
for i=1:length(metaSituations)
    bind_situation_name = metaSituations{i}.getName();
    bind_situation_isbase = metaSituations{i}.isBase();
    bind_situation_comment = metaSituations{i}.getComments();
    xmlContentLine = { xmlContentLine{:} generateXMLSituationDescription(bind_situation_name,bind_situation_isbase,bind_situation_comment)};
    metaSituationVariables = metaSituations{i}.getVariables();
    for j=1:length(metaSituationVariables)
        bind_variable_name = metaSituationVariables{j}.getName();
        bind_variable_type = metaSituationVariables{j}.getType();
        bind_variable_unit = metaSituationVariables{j}.getUnit();
        bind_variable_comments = metaSituationVariables{j}.getComments();
        xmlContentLine = { xmlContentLine{:} generateXMLVariableDescription(bind_variable_name,bind_variable_type,bind_variable_unit,bind_variable_comments) };
    end
    xmlContentLine = { xmlContentLine{:} sprintf('\t%s','</situation_mapping>') };
end

xmlContentLine = { xmlContentLine{:} '</bind_mapping>' };

% generate XML file from the contents of the variable

fid = fopen(fileToCreateWithMetasInfos,'w','l','ISO-8859-1');
for i=1:length(xmlContentLine)
    fwrite(fid,sprintf('%s\n',xmlContentLine{i}));
end
fclose(fid);

delete(theTrip);

end

function out = generateXMLDataDescription(name,isBase,comments,frequency)
    out = sprintf('\t<data_mapping bind_data_name="%s" bind_data_isbase="%d" imported_timecode_id="" bind_data_comment="%s" bind_data_frequency="%d">',name,isBase,comments,frequency);
end

function out = generateXMLEventDescription(name,isBase,comments)
    out = sprintf('\t<event_mapping bind_event_name="%s" bind_event_isbase="%d" imported_timecode_id="" bind_event_comment="%s">',name,isBase,comments);
end

function out = generateXMLSituationDescription(name,isBase,comments)
    out = sprintf('\t<situation_mapping bind_situation_name="%s" bind_situation_isbase="%d" imported_start_timecode_id="" imported_end_timecode_id="" bind_situation_comment="%s">',name,isBase,comments);
end

function out = generateXMLVariableDescription(name,type,unit,comments)
    out = sprintf('\t\t<variable_mapping imported_variable_id="" bind_variable_name="%s" bind_variable_type="%s"  bind_variable_unit="%s" bind_variable_comments="%s"/>',name,type,unit,comments);
end
