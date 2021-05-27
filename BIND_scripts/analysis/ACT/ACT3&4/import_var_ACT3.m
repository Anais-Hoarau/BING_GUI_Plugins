function [data] = import_var_ACT3(filename)
fileID = fopen(filename,'r');
formatSpec = '%*s %s %*s %*s %*s %f %s %f %s %f %f %f %f %*s %*s %*s %*s %*s %s %*s %*s %s %[^\n\r]';
% 1- temps ; 2- voie; 3- cap; 4- pk; 5- 
dataArray = textscan(fileID, formatSpec, 'Delimiter', '\t', 'HeaderLines', 1, 'ReturnOnError', false);
fclose(fileID);

%% Allocate imported array to column variable names


%% Mise en forme de la structure 'data'


com3 = dataArray{10};
com6 = dataArray{11};

data.scenario = com3{1}(strfind(com3{1},'Scenario'):end);

com =cell(length(com3),1);
for i=1:1:length(com3)
    com{i,1} = [com3{i} com6{i}]; 
end    
data.commentaires = com;

data.temps = dataArray{1};

data.vp.voie = dataArray{2};
data.vp.cap = str2double(strrep(dataArray{3},',','.'));
data.vp.pk= dataArray{4};
data.vp.vitesse= str2double(strrep(dataArray{5},',','.'));
data.vp.angleVolant = dataArray{6}*360/7500;%conversion de increment vers °
data.vp.acc = dataArray{7};
data.vp.frein = dataArray{8};
data.vp.embr = dataArray{9};

end