function [REMINDTxt,REMINDNum] = creerDonneesRespi(tempsevent,tpsDebAutonomous,timecoderespValuesOut, amplitudeRespi,periodeRespi,stabiliteBaserespi )
% listeIndDuree = {'DureeReelleResp10s' 'DureeReelleResp20s' 'DureeReelleRespi40s' 'DureeReelleRespi130s'};
%listeIndResp = { 'RespiInspExp' 'AmpliRespi' 'AmpliRespiMoy10s' 'DeltaAmpliRespiMoy10sAvecMoy10sP' 'DeltaAmpliRespiMoy10sAvecMoy30sP' 'DeltaAmpliRespiMoy10sAvecMoy120sP'...
%'PeriodeRespi' 'PeriodeRespi10s' 'DeltaPeriodeRespiMoy10sAvecMoy10sP' 'DeltaPeriodeRespiMoy10sAvecMoy30sP' 'DeltaPeriodeRespiMoy10sAvecMoy120sP' ...
% 'StabiliteRespi'   'StabiliteRespi0s10s' 'StabiliteRespi10s20s' 'StabiliteRespi10s40s' 'StabiliteRespi10s130s'};


if tpsDebAutonomous<tempsevent-10
    t10s = tempsevent-10;
else
    t10s = tpsDebAutonomous;
end
if tpsDebAutonomous<tempsevent-20
    t20s = tempsevent-20;
else
    t20s = tpsDebAutonomous;
end
if tpsDebAutonomous<tempsevent-40
    t40s = tempsevent-40;
else
    t40s = tpsDebAutonomous;
end
if tpsDebAutonomous<tempsevent-130
    t130s = tempsevent-130;
else
    t130s = tpsDebAutonomous;
end
DureeReelleRespi10s = tempsevent- t10s;
DureeReelleRespi20s = tempsevent- t20s;
DureeReelleRespi40s = tempsevent- t40s;
DureeReelleRespi130s = tempsevent- t130s;


indexValok = find(timecoderespValuesOut>=t10s  & timecoderespValuesOut<tempsevent & ~isnan(stabiliteBaserespi) );
if ~isempty(indexValok)
    StabiliteRespi =  abs(stabiliteBaserespi(indexValok(end)));
    StabiliteRespi0s10s = mean(abs(stabiliteBaserespi(indexValok)));
else
    StabiliteRespi =-1;
    StabiliteRespi0s10s =-1;
end
indexValok = timecoderespValuesOut>=t20s  & timecoderespValuesOut<t10s & ~isnan(stabiliteBaserespi) ;
if ~isempty(indexValok)
    StabiliteRespi10s20s = mean(abs(stabiliteBaserespi(indexValok)));
else
    StabiliteRespi10s20s = -1;
end
indexValok = timecoderespValuesOut>=t40s  & timecoderespValuesOut<t10s & ~isnan(stabiliteBaserespi) ;
if ~isempty(indexValok)
    StabiliteRespi10s40s = mean(abs(stabiliteBaserespi(indexValok)));
else
    StabiliteRespi10s40s=-1;
end
indexValok = timecoderespValuesOut>=t130s  & timecoderespValuesOut<t10s & ~isnan(stabiliteBaserespi) ;
if ~isempty(indexValok)
    StabiliteRespi10s130s= mean(abs(stabiliteBaserespi(indexValok)));
else
    StabiliteRespi10s130s=-1;
end

indexValok = find(timecoderespValuesOut>=t10s  & timecoderespValuesOut<tempsevent & ~isnan(amplitudeRespi) );
if ~isempty(indexValok)
    AmpliRespi = abs(amplitudeRespi(indexValok(end)));
    RespiInspExp = sign(amplitudeRespi(indexValok(end)));
    PeriodeRespi = periodeRespi(indexValok(end));
    AmpliRespiMoy10s = mean(abs(amplitudeRespi(indexValok)));
    PeriodeRespi10s = mean(periodeRespi(indexValok));
else
    AmpliRespi = -1;
    RespiInspExp = 0;
    PeriodeRespi = 0;
    AmpliRespiMoy10s = -1;
    PeriodeRespi10s = -1;
end

indexValok = timecoderespValuesOut>=t20s  & timecoderespValuesOut<t10s & ~isnan(amplitudeRespi) ;
if ~isempty(indexValok)
    DeltaAmpliRespiMoy10sAvecMoy10sP = mean(abs(amplitudeRespi(indexValok))) -AmpliRespiMoy10s;
    DeltaPeriodeRespiMoy10sAvecMoy10sP=mean(periodeRespi(indexValok)) -PeriodeRespi10s;
else
    DeltaAmpliRespiMoy10sAvecMoy10sP= -1;
    DeltaPeriodeRespiMoy10sAvecMoy10sP =-1;
end

indexValok = timecoderespValuesOut>=t40s  & timecoderespValuesOut<t10s & ~isnan(amplitudeRespi) ;
if ~isempty(indexValok)
    DeltaAmpliRespiMoy10sAvecMoy30sP= mean(abs(amplitudeRespi(indexValok))) -AmpliRespiMoy10s;
    DeltaPeriodeRespiMoy10sAvecMoy30sP=mean(periodeRespi(indexValok)) -PeriodeRespi10s;
else
    DeltaAmpliRespiMoy10sAvecMoy30sP= -1;
    DeltaPeriodeRespiMoy10sAvecMoy30sP=-1;
end

indexValok = timecoderespValuesOut>=t130s  & timecoderespValuesOut<t10s & ~isnan(amplitudeRespi) ;
if ~isempty(indexValok)
    DeltaAmpliRespiMoy10sAvecMoy120sP= mean(abs(amplitudeRespi(indexValok))) -AmpliRespiMoy10s;
    DeltaPeriodeRespiMoy10sAvecMoy120sP=mean(periodeRespi(indexValok)) -PeriodeRespi10s;
    
else
    DeltaAmpliRespiMoy10sAvecMoy120sP= -1;
    DeltaPeriodeRespiMoy10sAvecMoy120sP=-1;
    
end

REMINDNum= [    DureeReelleRespi10s DureeReelleRespi20s DureeReelleRespi40s DureeReelleRespi130s RespiInspExp ...
                 AmpliRespi AmpliRespiMoy10s DeltaAmpliRespiMoy10sAvecMoy10sP DeltaAmpliRespiMoy10sAvecMoy30sP DeltaAmpliRespiMoy10sAvecMoy120sP...
                PeriodeRespi PeriodeRespi10s DeltaPeriodeRespiMoy10sAvecMoy10sP DeltaPeriodeRespiMoy10sAvecMoy30sP DeltaPeriodeRespiMoy10sAvecMoy120sP ...
                StabiliteRespi  StabiliteRespi0s10s StabiliteRespi10s20s StabiliteRespi10s40s StabiliteRespi10s130s];
REMINDTxt ='';
for i=1:length(REMINDNum)
    REMINDTxt = [REMINDTxt ',' num2str(REMINDNum(i))]; %#ok<AGROW>
end