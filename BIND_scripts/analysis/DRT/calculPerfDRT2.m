function [ output_args ] = calculPerfDRT2(numsuj, track , typedrt, nametrip, namefiledrt,idfileres, nametaches, namedebut , namefin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%namevar = { 'DureeSeq' ; 'DebutSeqGMT' ; 'moyRT'; 'PourcReussi'};

 trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(nametrip, 0.04, true);


data = trip.getAllDataOccurences('localisation');
comments = data.getVariableValues('commentaires');
timecode  = cell2mat(data.getVariableValues('timecode'));
heureGMT  = data.getVariableValues('heureGMT');
heureGMT0 = heureGMT{1};
tempsgmt0 = str2num(heureGMT0(1:2))*3600+ str2num(heureGMT0(4:5))*60 +  str2num(heureGMT0(7:8)); 
heureGMTseconde = timecode + tempsgmt0;


idfiledrt= fopen(namefiledrt,'r');
resdrt = [];
fgets(idfiledrt); % lecture ligne de titre
linedrt ='';
while ((~feof(idfiledrt)) && (isempty(strfind(linedrt,'_'))))
    linedrt = fgets(idfiledrt); % 10:59:05;0.0000;686
    gmt = linedrt(1:8); reactiontime=  str2num(linedrt(17:length(linedrt)));  %#ok<*ST2NM>
    tempsgmt = str2num(gmt(1:2))*3600+ str2num(gmt(4:5))*60 +  str2num(gmt(7:8)); %#ok<ST2NM>
    resdrt = [resdrt; [tempsgmt reactiontime]]; %#ok<AGROW>
end;

for i=1:length(namedebut)
    indexdebut =find(cellfun('length',strfind(comments,namedebut{i}))); %#ok<*EFIND>
    indexfin =find(cellfun('length',strfind(comments,namefin{i})));  
    if isempty(indexdebut) || isempty(indexfin) 
           disp([' pb avec ' nametrip ' condition ' namedebut{i}]);
    else
 %       dureeSeq = timecode(indexfin) - timecode(indexdebut);
        debSeq = heureGMTseconde(indexdebut);
        finSeq = heureGMTseconde(indexfin);
        indexlignedrtcondition = find((resdrt(:,1)>=debSeq) & ...
        (resdrt(:,1)<=finSeq));
        resdrtSeq= resdrt(indexlignedrtcondition,:); %#ok<FNDSB>leng(
        for j=1:size(resdrtSeq,1)
            fprintf(idfileres,'%f\t%s\t%s\t%s\t%f\n', numsuj, track , typedrt, nametaches{i}, resdrtSeq(j,2));
        end;
    end
    
end


delete(trip);
%lengthcomments = cellfun('length',comments);
%indexComment = find(lengthcomments>1);
% commentslus = comments(indexComment)';




output_args = 1;
