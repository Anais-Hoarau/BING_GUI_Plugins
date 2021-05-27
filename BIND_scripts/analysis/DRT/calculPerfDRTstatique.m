function [ output_args ] = calculPerfDRTstatique(numsuj, typedrt, typetache, namefiledrt, idfileres)
%fprintf(idfileres,'IdSujet\tTypeDRT\tCondition\tTpsRepDRT\n');

idfiledrt= fopen(namefiledrt,'r');
resdrt = [];
fgets(idfiledrt); % lecture ligne de titre
linedrt ='';
while ((~feof(idfiledrt)) && (isempty(strfind(linedrt,'_'))))
    linedrt = fgets(idfiledrt); % 10:59:05;0.0000;686
    gmt = linedrt(1:8); reactiontime = str2num(linedrt(17:length(linedrt)));  %#ok<*ST2NM>
    tempsgmt = str2num(gmt(1:2))*3600+ str2num(gmt(4:5))*60 +  str2num(gmt(7:8)); %#ok<ST2NM>
    resdrt = [resdrt; [tempsgmt reactiontime]]; %#ok<AGROW>

        for i=1:size(resdrt,1)
            fprintf(idfileres,'%f\t%s\t%s\t%f\n', numsuj, typedrt, typetache, resdrt(i,2));
        end;
    
end

output_args = 1;

