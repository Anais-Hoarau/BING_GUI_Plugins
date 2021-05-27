function [ SigEdaVarLente,SigEdaVarRapide] =  calculCourbeEDA(GsrValues, GsrTimecode,prefixnamesavefigure)
%timecoderespValues = [1:length(respValues)]/1000;

%hist(diff(GsrValues),-1:0.001:1);

GsrLisseLong = GsrValues;
for i=2:20
    GsrLisseLong =GsrLisseLong + [GsrValues(i:end) (ones(1,i-1)*GsrValues(end))] ;
end
GsrLisseLong=GsrLisseLong/20;

diffGsr = diff(GsrValues);
diffGsr(abs(diffGsr)>0.3) =0;
Gsr2 = [ GsrValues(1) cumsum(diffGsr)+GsrValues(1)];
GsrLisseCourt = Gsr2;
for i=2:3
    GsrLisseCourt =GsrLisseCourt + [Gsr2(i:end) (ones(1,i-1)*Gsr2(end))] ;
end
GsrLisseCourt=GsrLisseCourt/3;

sensGsrLisseLong = sign(diff(GsrLisseLong));
zerossensGsrLisseLong = find(sensGsrLisseLong==0);
for i=1:length(zerossensGsrLisseLong)
    if zerossensGsrLisseLong(i) > 1 
        sensGsrLisseLong(zerossensGsrLisseLong(i))=sensGsrLisseLong(zerossensGsrLisseLong(i)-1);
    else
         sensGsrLisseLong(zerossensGsrLisseLong(i))=sensGsrLisseLong(zerossensGsrLisseLong(i)+1);
    end
end
tpsminGsrLisseLong = find(diff(sensGsrLisseLong)>1.5);
posminGsrLisseLong=GsrTimecode(tpsminGsrLisseLong);
valminGsrLisseLong=GsrLisseLong(tpsminGsrLisseLong);
SigEdaVarLente =  interp1(posminGsrLisseLong,valminGsrLisseLong,GsrTimecode);

sensGsrLisseCourt = sign(diff(GsrLisseCourt));
zerossensGsrLisseCourt = find(sensGsrLisseCourt==0);
for i=1:length(zerossensGsrLisseCourt)
    if zerossensGsrLisseCourt(i) > 1 
        sensGsrLisseCourt(zerossensGsrLisseCourt(i))=sensGsrLisseCourt(zerossensGsrLisseCourt(i)-1);
    else
         sensGsrLisseCourt(zerossensGsrLisseCourt(i))=sensGsrLisseCourt(zerossensGsrLisseCourt(i)+1);
    end
end
tpsminGsrLisseCourt = find(diff(sensGsrLisseCourt)>1.5)+1;
posminGsrLisseCourt=GsrTimecode(tpsminGsrLisseCourt); 
valminGsrLisseCourt=GsrLisseCourt(tpsminGsrLisseCourt);
tpsmaxGsrLisseCourt = find(diff(sensGsrLisseCourt)<-1.5)+1;
posmaxGsrLisseCourt=GsrTimecode(tpsmaxGsrLisseCourt); 
valmaxGsrLisseCourt=GsrLisseCourt(tpsmaxGsrLisseCourt);

SigEdaVarRapide = zeros(length(GsrTimecode),1);
for i=1:length(tpsmaxGsrLisseCourt)
    debpic = find(tpsminGsrLisseCourt<tpsmaxGsrLisseCourt(i),1,'last');
    finpic = find(tpsminGsrLisseCourt>tpsmaxGsrLisseCourt(i),1,'first');
    if ~isempty(debpic) && ~isempty(finpic)
        SigEdaVarRapide(tpsminGsrLisseCourt(debpic):tpsminGsrLisseCourt(finpic))= ...
          GsrLisseCourt(tpsminGsrLisseCourt(debpic):tpsminGsrLisseCourt(finpic))-GsrLisseCourt(tpsminGsrLisseCourt(debpic));
    elseif isempty(debpic) && ~isempty(finpic)
        SigEdaVarRapide(tpsmaxGsrLisseCourt(i):tpsminGsrLisseCourt(finpic))= ...
          GsrLisseCourt(tpsmaxGsrLisseCourt(i):tpsminGsrLisseCourt(finpic));
    elseif ~isempty(debpic) && isempty(finpic)
        SigEdaVarRapide(tpsminGsrLisseCourt(debpic):tpsmaxGsrLisseCourt(i))= ...
          GsrLisseCourt(tpsminGsrLisseCourt(debpic):tpsmaxGsrLisseCourt(i))-GsrLisseCourt(tpsminGsrLisseCourt(debpic));
    else
        SigEdaVarRapide(psmaxGsrLisseCourt(i))= GsrLisseCourt(psmaxGsrLisseCourt(i));
    end        
end
 SigEdaVarRapide(SigEdaVarRapide<0) =0;   
 
 
 
 if  ~isempty(prefixnamesavefigure)
     ii=strfind(prefixnamesavefigure,'\');
    if ~isempty(ii)
        labeltitre= prefixnamesavefigure(ii(end)+1:end); 
    else
        labeltitre= prefixnamesavefigure;
    end
    labeltitre=strrep(labeltitre,'_',' ');
    fig = figure;
    hold on;
    plot(GsrTimecode,GsrLisseLong+2 ,'-');
    plot(GsrTimecode,GsrValues,'-');
    plot(GsrTimecode,Gsr2-2,'-');
    plot(GsrTimecode,GsrLisseCourt-4 ,'-');

    legend('GsrLisseLong','Gsr','Gsr2 0.3','GsrLisse 3pt');
    title([ labeltitre ' EDA']);
    %      dataRecord = trip.getAllDataOccurences('EMPATICA_E4_Hr_Ibi');
    %     HrValues = cell2mat(dataRecord.getVariableValues('Hr'));
    %     HrTimecode = cell2mat(dataRecord.getVariableValues('timecode'));
    %      plot(HrTimecode(2:end-1),HrValues,'*');
    %         IbiValues = cell2mat(dataRecord.getVariableValues('Ibi'));
    %     IbiTimecode = cell2mat(dataRecord.getVariableValues('timecode'));
    %      plot(IbiTimecode(2:end-1),IbiValues,'*');
    %
    savefig(fig,[ prefixnamesavefigure 'EDA1.fig']);
    close(fig);

    fig = figure;
    hold on;
    plot(GsrTimecode,GsrLisseLong+2 ,'-');
    plot(GsrTimecode,GsrValues,'-');
    plot(GsrTimecode,GsrLisseCourt-4 ,'-');
     plot(GsrTimecode,SigEdaVarRapide ,'-');
     plot(posminGsrLisseLong,valminGsrLisseLong+2,'g+'); 
    plot(posmaxGsrLisseCourt,valmaxGsrLisseCourt-4,'r+'); 
    plot(posminGsrLisseCourt,valminGsrLisseCourt-4,'g+'); 
  
    
    legend('GsrLisseLong','Gsr','GsrLisse 3pt','SigEdaVarRapide','posminGsrLisseLong','maxGsrLisseCourt','minGsrLisseCourt');

        savefig(fig,[ prefixnamesavefigure 'EDA2.fig']);
    close(fig);
    
    fig = figure;
    hold on;
    plot(GsrTimecode,GsrValues,'-');
    plot(GsrTimecode,SigEdaVarLente-2,'-');
    plot(GsrTimecode,SigEdaVarRapide-4 ,'-');
    legend('Gsr','SigEdaVarLente','SigEdaVarRapide');
    title([ labeltitre ' EDA']);
    %      dataRecord = trip.getAllDataOccurences('EMPATICA_E4_Hr_Ibi');
    %     HrValues = cell2mat(dataRecord.getVariableValues('Hr'));
    %     HrTimecode = cell2mat(dataRecord.getVariableValues('timecode'));
    %      plot(HrTimecode(2:end-1),HrValues,'*');
    %         IbiValues = cell2mat(dataRecord.getVariableValues('Ibi'));
    %     IbiTimecode = cell2mat(dataRecord.getVariableValues('timecode'));
    %      plot(IbiTimecode(2:end-1),IbiValues,'*');
    %
    savefig(fig,[ prefixnamesavefigure 'EDA.fig']);
    close(fig);
end
      