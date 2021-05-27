directory = uigetdir('C:\Documents and Settings\huang\Bureau\Data');
[pathstr, name, ext] =  fileparts(directory);

tripSet = fr.lescot.bind.utils.TripSetUtils.loadAllSQLiteTripsInSubdirectory(directory);
tripsCellArray = tripSet.getTrips();

variables = cell(1,10); % The second number is the quantity of the variables that you wanna treat
variables{1} = 'AverageSpeed';
variables{2} = 'StdevSpeed';
variables{3} = 'AverageAngle';
variables{4} = 'StdevAngle';
variables{5} = 'AverageAccelerator';
variables{6} = 'StdevAccelerator';
variables{7} = 'AverageBrake';
variables{8} = 'StdevBrake';
variables{9} = 'AverageClutch';
variables{10} = 'StdevClutch';

positions = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};
totaltype = {'RP','CP','CNP','TADCP','TAGNP','TADNP','TAGS','TADS','TAGF','TADF','TDS','TDF'};

for m = 1:length(variables)
    for n = 1:length(tripsCellArray)
        theTrip = tripsCellArray{n};
        theTripMetaInfos = theTrip.getMetaInformations();
        
        intersections = theTrip.getAllSituationOccurences('Intersection');
        label = intersections.getVariableValues('Label');
        number = cell2mat(intersections.getVariableValues('Number'));
        type = intersections.getVariableValues('Type');
        values = cell2mat(intersections.getVariableValues(variables{m}));
        
%         tripdatavalue = theTrip.getAllDataOccurences('MetaTripDatas').getVariableValues('value');
%         tripnumber = tripdatavalue(2);
%         tripnumber = regexp(tripnumber{1},'\d+','match');
%         tripnumber = str2num(tripnumber{1});
%         participant = theTrip.getAllDataOccurences('MetaParticipantDatas').getVariableValues('value');
%         drivercode = participant(2);
%         drivercode = regexp(drivercode{1},'\d+','match');
%         drivercode = str2num(drivercode{1});
%         status = participant(3);
%         status = str2num(status{1});
        drivercode = theTripParticipant.getAttribute('numSujet');
        
        
        if n == 1
            datatowrite = {'Trip Number','Driver Code','Driver Status'; tripnumber drivercode status};
            for j = 1:length(totaltype)
                s = xlswrite([folderadr '\' variables{m} '.xls'], datatowrite, totaltype{j});
            end
        else
            for j = 1:length(totaltype)
                s = xlswrite([folderadr '\' variables{m} '.xls'], [tripnumber drivercode status], totaltype{j},['A' num2str(n+1)]);
            end
        end
        
        for i = 1:length(totaltype)
            ind = find(strcmp(type,totaltype{i}) == true);
            indice = 4;
            index = 0; % to add 'A'or 'B'etc before
            if n == 1
                for j = 1:length(ind)
                    name = [label{ind(j)} num2str(number(ind(j)))];
                    datatowrite = {name; values(ind(j))};
                    if index == 0
                        s = xlswrite([folderadr '\' variables{m} '.xls'], datatowrite, totaltype{i},[positions{indice} '1']);
                        indice = indice + 1;
                        if indice > 26
                            index = index + 1;
                            indice = indice - 26;
                        end
                        disp('finish if');
                    else
                        s = xlswrite([folderadr '\' variables{m} '.xls'], datatowrite, totaltype{i},[positions{index} positions{indice} '1']);
                        indice = indice + 1;
                        if indice > 26
                            index = index + 1;
                            indice = indice - 26;
                        end
                        disp('finish else');
                    end
                end
            else
                for j = 1:length(ind)
                    name = [label{ind(j)} num2str(number(ind(j)))];
                    if index == 0
                        s = xlswrite([folderadr '\' variables{m} '.xls'], values(ind(j)), totaltype{i},[positions{indice} num2str(n+1)]);
                        indice = indice + 1;
                        if indice > 26
                            index = index + 1;
                            indice = indice - 26;
                        end
                        disp('finish if');
                    else
                        s = xlswrite([folderadr '\' variables{m} '.xls'], values(ind(j)), totaltype{i},[positions{index} positions{indice} num2str(n+1)]);
                        indice = indice + 1;
                        if indice > 26
                            index = index + 1;
                            indice = indice - 26;
                        end
                        disp('finish else');
                    end
                end
            end
        end
        
        disp('finish a folder!');
        clear theTrip
    end
end