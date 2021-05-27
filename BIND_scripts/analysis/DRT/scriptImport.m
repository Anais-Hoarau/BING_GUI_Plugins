pathToTrip = 'D:\Ldumont\DRT_MATLAB\datatrip';
pathToVAR = 'D:\Ldumont\DRT_MATLAB\datavar\Autoroute';
listdir = dir(pathToVAR);
for i=3:length(listdir)
    posstr= strfind(listdir(i).name, '.var');
    if ~isempty(posstr)
        nametrip = [  pathToTrip '\' listdir(i).name(1:posstr-1) '.trip'];
        if ~exist(nametrip,'file')
            LEPSIS2BIND_DRT('D:\Ldumont\DRT2012\datavar\descriXMLautoroute.xml',pathToVAR, listdir(i).name, ...
                 pathToTrip);
        end;
    end;
end;
  
pathToTrip = 'D:\Ldumont\DRT_MATLAB\datatrip';
pathToVAR = 'D:\Ldumont\DRT_MATLAB\datavar\Route';
listdir = dir(pathToVAR);
for i=3:length(listdir)
    posstr= strfind(listdir(i).name, '.var');
    if ~isempty(posstr)
        nametrip = [  pathToTrip '\' listdir(i).name(1:posstr-1) '.trip'];
        if ~exist(nametrip,'file')
            LEPSIS2BIND_DRT('descriXML.xml',pathToVAR,listdir(i).name, ...
                 pathToTrip);
        end;
    end;
end;