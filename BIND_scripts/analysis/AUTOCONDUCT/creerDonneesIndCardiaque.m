function [REMINDTxt,REMINDNum] = creerDonneesIndCardiaque(tempsevent,tpsDebAutonomous,timecodePic,valRR , RR2, DRR2 )
% listeIndDuree = {'DureeReelle10s' 'DureeReelle30s' 'DureeReelle120s'};
% listeIndCard = {'ConfSDRR10s' 'ConfSDRR30s' 'ConfSDRR120s' 'ConfRMSSD10s' 'ConfRMSSD30s' 'ConfRMSSD120s'...
%   'SDNN10s' 'SDNN30s' 'SDNN120s' 'RMSSD10s' 'RMSSD10s' 'RMSSD30s' 'RMSSD120s' ...
%     'RRMax10s' 'RRMax30s' 'RRMax120s' 'RRMin10s' 'RRMin30s' 'RRMin120s' };


if tpsDebAutonomous<tempsevent-10
    t10s = tempsevent-10;
else
    t10s = tpsDebAutonomous;
end

DureeReelle10s = tempsevent- t10s;
indexValok = find(timecodePic>=t10s  & timecodePic<tempsevent & RR2>0 );
if ~isempty(indexValok)
    RRMoy10s = mean(valRR(indexValok));
    SDNN10s = sqrt((sum(RR2(indexValok)) - length(indexValok)*RRMoy10s^2)/(length(indexValok)-1));
    RRMax10s = max(valRR(indexValok));
    RRMin10s = min(valRR(indexValok));
    ConfSDRR10s = length(indexValok)*RRMoy10s/10;
else
    RRMoy10s = -1;
    SDNN10s = -1;
    RRMax10s =-1;
    RRMin10s =-1;
    ConfSDRR10s = 0;
end
indexValok = find(timecodePic>=t10s  & timecodePic<tempsevent & DRR2>0 );
if ~isempty(indexValok)
    RMSSD10s = sqrt((sum(DRR2(indexValok)))/(length(indexValok)-1));
    ConfRMSSD10s = length(indexValok)*RRMoy10s/10;
else
    RMSSD10s = -1;
    ConfRMSSD10s = -1;
end

if tpsDebAutonomous<tempsevent-120
    t120s = tempsevent-120;
else
    t120s = tpsDebAutonomous;
end
DureeReelle120s = tempsevent- t120s;
indexValok = find(timecodePic>=t120s  & timecodePic<tempsevent & RR2>0 );
if ~isempty(indexValok)
    RRMoy120s = mean(valRR(indexValok));
    SDNN120s = sqrt((sum(RR2(indexValok)) - length(indexValok)*RRMoy120s^2)/(length(indexValok)-1));
    RRMax120s = max(valRR(indexValok));
    RRMin120s = min(valRR(indexValok));
    ConfSDRR120s = length(indexValok)*RRMoy120s/120;
else
    RRMoy120s = -1;
    SDNN120s = -1;
    RRMax120s = -1;
    RRMin120s = -1;
    ConfSDRR120s = 0;
end
indexValok = find(timecodePic>=t120s  & timecodePic<tempsevent & DRR2>0 );
if ~isempty(indexValok)
    RMSSD120s = sqrt((sum(DRR2(indexValok)))/(length(indexValok)-1));
    ConfRMSSD120s = length(indexValok)*RRMoy120s/120;
else
    RMSSD120s = -1;
    ConfRMSSD120s = 0;
end



if tpsDebAutonomous<tempsevent-30
    t30s = tempsevent-30;
else
    t30s = tpsDebAutonomous;
end
DureeReelle30s = tempsevent- t30s;
indexValok = find(timecodePic>=t30s  & timecodePic<tempsevent & RR2>0 );
if ~isempty(indexValok)
    RRMoy30s = mean(valRR(indexValok));
    SDNN30s = sqrt((sum(RR2(indexValok)) - length(indexValok)*RRMoy30s^2)/(length(indexValok)-1));
    RRMax30s = max(valRR(indexValok));
    RRMin30s = min(valRR(indexValok));
    ConfSDRR30s = length(indexValok)*RRMoy30s/30;
else
    RRMoy30s =-1;
    SDNN30s = -1;
    RRMax30s = -1;
    RRMin30s = -1;
    ConfSDRR30s = 0;
end

indexValok = find(timecodePic>=t30s  & timecodePic<tempsevent & DRR2>0 );
if ~isempty(indexValok)
    RMSSD30s = sqrt((sum(DRR2(indexValok)))/(length(indexValok)-1));
    ConfRMSSD30s = length(indexValok)*RRMoy30s/30;
else
    RMSSD30s = -1;
    ConfRMSSD30s = 0;
end


REMINDNum= [  DureeReelle10s DureeReelle30s DureeReelle120s ...
    ConfSDRR10s ConfSDRR30s ConfSDRR120s ConfRMSSD10s ConfRMSSD30s ConfRMSSD120s ...
    SDNN10s SDNN30s SDNN120s RMSSD10s RMSSD30s RMSSD120s RRMax10s RRMax30s RRMax120s RRMin10s RRMin30s RRMin120s];
REMINDTxt ='';
for i=1:length(REMINDNum)
    REMINDTxt = [REMINDTxt ',' num2str(REMINDNum(i))]; %#ok<AGROW>
end