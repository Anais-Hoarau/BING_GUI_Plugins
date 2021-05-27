function [tableREMINDNum,  tableREMINDTxt ]= extractTRINDV3(numsuj,numcond,tripname,listeConditions,logfile)
%listeConditions = { 'Audio_triste', 'Audio_neutre' , 'Rappel',  'Histoire' };
%tableREM= extractTR(0,1,'RecFile_BIND_20180830_093949.trip',listeConditions,0);
tableREMINDTxt = {};
tableREMINDNum = [];
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripname, 0.04, false);
metaInfos = trip.getMetaInformations();
if metaInfos.existEvent('CADISP')
    cadispevents = trip.getAllEventOccurences('CADISP');
    actions = cadispevents.getVariableValues('action');
    modes = cadispevents.getVariableValues('mode');
    temps = cadispevents.getVariableValues('timecode');
    namesavefileSigCard=['.\data\signaux\Suj' num2str(numsuj,'%02d') listeConditions{numcond} 'Card.mat'];
    namesavefileSigRespi=['.\data\signaux\Suj' num2str(numsuj,'%02d') listeConditions{numcond} 'Respi.mat'];
    namesavefileSigEDA=['.\data\signaux\Suj' num2str(numsuj,'%02d') listeConditions{numcond} 'EDA.mat'];
    prefixnamesavefigure=['.\data\figures\Suj' num2str(numsuj,'%02d') listeConditions{numcond}];
    %prefixnamesavefigure='';
    if metaInfos.existData('BIOPAC_MP150')
        dataRecord = trip.getAllDataOccurences('BIOPAC_MP150');
        ecgTimecode = cell2mat(dataRecord.getVariableValues('timecode'));
    end
    if ~exist(namesavefileSigCard,'file')
        if metaInfos.existData('BIOPAC_MP150')
             ecgValues = cell2mat(dataRecord.getVariableValues('ecg'));
            [posPic,valRR , RR2, DRR2 ]=extractRR(ecgValues,logfile,prefixnamesavefigure) ;
            save(namesavefileSigCard,'posPic','valRR' , 'RR2', 'DRR2');
        else
            s=['Suj' num2str(numsuj) ' Cond ' listeConditions{numcond} ' GROS BUG DATA pb data BIOPAC_MP150 inconnu'];
            if logfile>0 ; fprintf(logfile,'%s\n',s); else disp(s); end %#ok<SEPEX>
        end
    else
        load(namesavefileSigCard,'posPic','valRR' , 'RR2', 'DRR2');
    end
    timecodePic=ecgTimecode(posPic)';
    
    if ~exist(namesavefileSigRespi,'file')
        if metaInfos.existData('BIOPAC_MP150')
            dataRecord = trip.getAllDataOccurences('BIOPAC_MP150');
            ecgTimecode = cell2mat(dataRecord.getVariableValues('timecode'));
            respValues = cell2mat(dataRecord.getVariableValues('resp'));
            [ timecoderespValuesOut, amplitudeRespi,periodeRespi,stabiliteBaserespi] =  calculAmpliRespi(respValues, ecgTimecode,prefixnamesavefigure);
            save(namesavefileSigRespi,'timecoderespValuesOut', 'amplitudeRespi','periodeRespi','stabiliteBaserespi');
            
        else
            s=['Suj' num2str(numsuj) ' Cond ' listeConditions{numcond} ' GROS BUG DATA pb data BIOPAC_MP150 inconnu'];
            if logfile>0 ; fprintf(logfile,'%s\n',s); else disp(s); end %#ok<SEPEX>
        end
    else
        load(namesavefileSigRespi,'timecoderespValuesOut', 'amplitudeRespi','periodeRespi','stabiliteBaserespi');
    end
    
    if ~exist(namesavefileSigEDA,'file')
        if metaInfos.existData('EMPATICA_E4_Gsr')
            dataRecord = trip.getAllDataOccurences('EMPATICA_E4_Gsr');
            GsrValues = cell2mat(dataRecord.getVariableValues('Gsr'));
            GsrTimecode = cell2mat(dataRecord.getVariableValues('timecode'));
            [ SigEdaVarLente,SigEdaVarRapide] =  calculCourbeEDA(GsrValues, GsrTimecode,prefixnamesavefigure);
            save(namesavefileSigEDA,'SigEdaVarLente','SigEdaVarRapide','GsrTimecode');
            
        else
            s=['Suj' num2str(numsuj) ' Cond ' listeConditions{numcond} ' GROS BUG DATA pb data EMPATICA_E4_Gsr inconnu'];
            if logfile>0 ; fprintf(logfile,'%s\n',s); else disp(s); end %#ok<SEPEX>
        end
    else
        load(namesavefileSigEDA, 'SigEdaVarLente','SigEdaVarRapide','GsrTimecode'); %#ok<NASGU>
    end
    
    
    modeNmoins1='';
    modeNmoins2='';
    tpsNmoins1='';
    tpsNmoins2='';
    nbREM = 0;
    for i=1:length(actions)
        action =actions{i};
        mode = modes{i};
        tempsevent = temps{i};
        route = trip.getDataVariableOccurencesInTimeInterval('DR2_Vehicule_VHS_vp', 'Route', tempsevent, tempsevent+0.1).getVariableValues('Route');
        if length(route) >=1
            route = route{1};
        else
            route = '0';
        end
        if strcmp(action,'click')
            if strcmp(mode,'auto_available')
            else
                s=['            Warning click Suj' num2str(numsuj) ' Cond ' listeConditions{numcond} ' temps ' num2str(tempsevent) ' pb data CADISP mode dans action click : '  num2str(i) ' ' action ' '  mode];
                if logfile>0 ; fprintf(logfile,'%s\n',s); else disp(s); end %#ok<SEPEX>
            end
        elseif strcmp(action,'display')
            if strcmp(mode,'auto_available')
            elseif strcmp(mode,'autonomous')
                tpsDebAutonomous = tempsevent;
            elseif strcmp(mode,'critical')
            elseif strcmp(mode,'end_zone')
            elseif strcmp(mode,'manual')
                if i> 1
                    [REMINDTxtCardiac,REMINDNumCardiac] = creerDonneesIndCardiaque(tempsevent,tpsDebAutonomous,timecodePic,valRR , RR2, DRR2 );
                    [REMINDTxtRespi,REMINDNumRespi] = creerDonneesRespi(tempsevent,tpsDebAutonomous,timecoderespValuesOut, amplitudeRespi,periodeRespi,stabiliteBaserespi );
                    if strcmp(modeNmoins1,'critical') && strcmp(modeNmoins2,'autonomous')
                        tpsREM = tempsevent-tpsNmoins1;
                        tableREMINDTxt{nbREM+1}= [num2str(numsuj) ',' listeConditions{numcond} ',' num2str(tempsevent) ',NonPlan,' ( route) ',' num2str(tpsREM)  REMINDTxtCardiac REMINDTxtRespi]; %#ok<AGROW>
                        tableREMINDNum= [tableREMINDNum; [(numsuj) numcond tempsevent 1 str2double(route) tpsREM REMINDNumCardiac REMINDNumRespi]]; %#ok<AGROW>
                        nbREM=nbREM+1;
                    elseif strcmp(modeNmoins1,'critical') && strcmp(modeNmoins2,'end_zone')
                        tpsREM = tempsevent-tpsNmoins2;
                        tableREMINDTxt{nbREM+1}= [num2str(numsuj) ',' listeConditions{numcond} ','  num2str(tempsevent) ',Plan,' ( route) ',' num2str(tpsREM)  REMINDTxtCardiac REMINDTxtRespi]; %#ok<AGROW>
                        tableREMINDNum= [tableREMINDNum ;[(numsuj) numcond tempsevent 0 str2double(route) tpsREM REMINDNumCardiac REMINDNumRespi]]; %#ok<AGROW>
                        nbREM=nbREM+1;
                    elseif strcmp(modeNmoins1,'end_zone') && strcmp(modeNmoins2,'autonomous')
                        tpsREM = tempsevent-tpsNmoins1;
                        tableREMINDTxt{nbREM+1}= [num2str(numsuj) ',' listeConditions{numcond} ',' num2str(tempsevent) ',Plan,' ( route) ',' num2str(tpsREM) REMINDTxtCardiac REMINDTxtRespi]; %#ok<AGROW>
                        tableREMINDNum= [tableREMINDNum ;[(numsuj) numcond tempsevent 0 str2double(route) tpsREM REMINDNumCardiac REMINDNumRespi]]; %#ok<AGROW>
                        nbREM=nbREM+1;
                    else
                        s=['Suj' num2str(numsuj) ' Cond ' listeConditions{numcond} ' temps ' num2str(tempsevent) ' GROS BUG DATA pb data CADISP enchainement : '  num2str(i) ' ' action ' '  mode ' :modeNmoins2 ' modeNmoins2 ' modeNmoins1 ' modeNmoins1];
                        if logfile>0 ; fprintf(logfile,'%s\n',s); else disp(s); end %#ok<SEPEX>
                    end
                end
            else
                s=['Suj' num2str(numsuj) ' Cond ' listeConditions{numcond} '  temps ' num2str(tempsevent) ' GROS BUG DATA pb data CADISP mode dans action display : '  num2str(i) ' ' action ' '  mode];
                if logfile>0 ; fprintf(logfile,'%s\n',s); else disp(s); end %#ok<SEPEX>
            end
            modeNmoins2=modeNmoins1;
            modeNmoins1=mode;
            tpsNmoins2=tpsNmoins1;
            tpsNmoins1=tempsevent;
        else
            s=['Suj' num2str(numsuj) ' Cond ' listeConditions{numcond} 'temps ' num2str(tempsevent) ' GROS BUG DATA pb data CADISP action'  num2str(i) ' ' action ' '  mode];
            if logfile>0 ; fprintf(logfile,'%s\n',s); else disp(s); end %#ok<SEPEX>
        end
        
    end
else
    s=['Suj' num2str(numsuj) ' Cond ' listeConditions{numcond} ' GROS BUG DATA pb data CADISP inconnu'];
    if logfile>0 ; fprintf(logfile,'%s\n',s); else disp(s); end %#ok<SEPEX>
end
delete(trip);



