% createMetaEvent(trip,eventName,variables)
% Creates a metaEvent with associated variables and add it to the trip.
% If the metaEvent with this name already exists, it deletes it and
% recreate the proper metaEvent.
% trip:      the Trip object you're working on
% dataName:  a string, the name of the metaData to create
% variables: a cellArray containing information about the variables.
%            ie: {{'var1Name','var1Type'},{'var2Name','var2Type'},...}
function createMetaData(trip,dataName,variables)


if (trip.getMetaInformations().existData(dataName))
        trip.removeData(dataName);
end

% create a metaData
newMetaData = fr.lescot.bind.data.MetaData;
newMetaData.setName(dataName);
% create metaDataVariables
metaDataVariableArray = cell(size(variables));
for i=1:length(variables)
    metaDataVariableArray{i} = fr.lescot.bind.data.MetaDataVariable();
    metaDataVariableArray{i}.setName(variables{i}{1});
    metaDataVariableArray{i}.setType(variables{i}{2});
end
% set the metaDataVariables in the metaData
newMetaData.setVariables(metaDataVariableArray);
% add the metaData to the trip
trip.addData(newMetaData);

end