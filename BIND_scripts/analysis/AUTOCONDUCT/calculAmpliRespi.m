function [ timecoderespValuesOut, amplitudeRespi,periodeRespi,stabiliteBaserespi] =  calculAmpliRespi(respValues, timecoderespValues,prefixnamesavefigure)
%timecoderespValues = [1:length(respValues)]/1000;


dureeCalculMax =0.5; % duree ^rendanlaquelle on calcul le maximun et le minimum

signaltoProcess  = decimate(respValues,10)';
timecoderespValuesOut = timecoderespValues(1:10:length(respValues))';
FechRespi=round(1/mean(diff(timecoderespValuesOut)));
lengthwindow = floor(dureeCalculMax*FechRespi); % longueur de la fenetre en point

tabsignaltoProcess= zeros(length(signaltoProcess),lengthwindow);
for i=1:lengthwindow
    tabsignaltoProcess(i:end,i) = signaltoProcess(1:end-i+1);
end
maxsignaltoProcess=max(tabsignaltoProcess,[],2);
minsignaltoProcess=min(tabsignaltoProcess,[],2);
clear tabsignaltoProcess;

% plot(signaltoProcess);
% hold on;
% plot(maxsignaltoProcess,'r');
% plot(minsignaltoProcess,'g');
plateaumax = diff(maxsignaltoProcess)==0;
debplateaumax =find(diff(plateaumax)>0);
finplateaumax =find(diff(plateaumax)<0);
if(length(debplateaumax)>length(finplateaumax))
    debplateaumax=debplateaumax(1:end-1);
elseif(length(debplateaumax)<length(finplateaumax))
    finplateaumax=finplateaumax(2:end);
elseif debplateaumax(1) > finplateaumax(1)
    finplateaumax=finplateaumax(2:end);
    debplateaumax=debplateaumax(1:end-1);
end
%signaldureemax= zeros(length(plateaumax),1);
dureeplateaumax = finplateaumax-debplateaumax;
for i=1:length(dureeplateaumax)
    if dureeplateaumax(i) < lengthwindow-5
        plateaumax(debplateaumax(i):finplateaumax(i))=0;
    else
        % signaldureemax(debplateaumax(i):finplateaumax(i))=dureeplateaumax(i);
    end
end
%signaldureemax(signaldureemax==0)=NaN;
plateaumax = plateaumax.*maxsignaltoProcess(1:end-1);
valmax = (plateaumax==signaltoProcess(1:end-1)).*signaltoProcess(1:end-1);
valmax(valmax==0)= NaN;

%plateaumin = ((diff(minsignaltoProcess))==0).*minsignaltoProcess(1:end-1);

plateaumin = (diff(minsignaltoProcess))==0;
debplateaumin =find(diff(plateaumin)>0);
finplateaumin =find(diff(plateaumin)<0);
if(length(debplateaumin)>length(finplateaumin))
    debplateaumin=debplateaumin(1:end-1);
elseif(length(debplateaumin)<length(finplateaumin))
    finplateaumin=finplateaumin(2:end);
elseif debplateaumin(1) > finplateaumin(1)
    finplateaumin=finplateaumin(2:end);
    debplateaumin=debplateaumin(1:end-1);
end
%signaldureemin= zeros(length(plateaumin),1);
dureeplateaumin = finplateaumin-debplateaumin;
for i=1:length(dureeplateaumin)
    if dureeplateaumin(i) < lengthwindow-5
        plateaumin(debplateaumin(i):finplateaumin(i))=0;
    else
        % signaldureemin(debplateaumin(i):finplateaumin(i))=dureeplateaumin(i);
    end
end
%signaldureemin(signaldureemin==0)=NaN;
plateaumin = plateaumin.*minsignaltoProcess(1:end-1);
valmin = (plateaumin==signaltoProcess(1:end-1)).*signaltoProcess(1:end-1);
valmin(valmin==0)=NaN;


% plot([1:length(signaltoProcess)]/FechRespi,signaltoProcess); %#ok<NBRAK>
% hold on;
% plot([1:length(valmax)]/FechRespi,valmax,'r+'); %#ok<NBRAK>
% plot([1:length(signaldureemax)]/FechRespi,signaldureemax/10,'r'); %#ok<NBRAK>
% plot([1:length(valmin)]/FechRespi,valmin,'g+'); %#ok<NBRAK>
% plot([1:length(signaldureemin)]/FechRespi,signaldureemin/10,'g'); %#ok<NBRAK>

tempsvalmax = find(~isnan(valmax));
tempsvalmin = find(~isnan(valmin));

amplitudeRespi = zeros(length(signaltoProcess),1);
periodeRespi = zeros(length(signaltoProcess),1);
demiPeriodeRespi = zeros(length(signaltoProcess),1);
stabiliteBaserespi = zeros(length(signaltoProcess),1);
dermax =-100;
dermin =-100;
tempsdermin=-1;
tempsdermax=-1;
indexdermin=1;
tempsdermaxN2= -1;

derminN2 =-1;
for i=1:length(tempsvalmax)
    if(tempsvalmin(indexdermin)>tempsvalmax(i))%pas de min depuis le dernier max
        if dermin>-99 % cas normal autre que premier
            if dermax> -99 && dermax<valmax(tempsvalmax(i))% cas d'un plateau en montee de pic on traite le pic en ecrasant le resultat précedant
                valmax(tempsdermax) =-2;
                if (abs(dermin-valmax(tempsvalmax(i))) > 0.2) % pic de taille suffisante
                    tempsdermax=tempsvalmax(i);
                    dermax=valmax(tempsdermax);
                    amplitudeRespi(tempsdermin:tempsdermax)=dermax-dermin;
                    demiPeriodeRespi(tempsdermin:tempsdermax)=(tempsdermax-tempsdermin)/FechRespi;

                    if tempsdermaxN2 > 0 % deuxieme  cas de max
                        periodeRespi(tempsdermaxN2:tempsdermax)=(tempsdermax-tempsdermaxN2)/FechRespi;
                        demiPeriodeRespi(tempsdermin:tempsdermax)=(tempsdermax-tempsdermaxN2)/FechRespi;
                        stabiliteBaserespi(tempsdermaxN2:tempsdermax) = derminN2 -dermin;
                    end
                    derminN2 = dermin;
                else
                    valmax(tempsvalmax(i)) =-100;
                end
                
            else % cas d'un plateau en descente de pic on l'ignore
                valmax(tempsvalmax(i)) =-300;
            end
        else % premier cas
            tempsdermax=tempsvalmax(i);
            dermax=valmax(tempsdermax);
        end
    else % cas normal il y a un min depuis le dernier max
        exitwhile =1;
        while exitwhile && indexdermin<length(tempsvalmin)
            if dermax<-99
                % traitement du premier cas
                tempsdermin = tempsvalmin(indexdermin);
                dermin = valmin(tempsdermin);
                tempsdermax=tempsvalmax(i);
            dermax=valmax(tempsdermax);
            else
                % cas normal autre que premier
                if(tempsvalmin(indexdermin)>tempsvalmax(i) )
                    exitwhile =0;
                else
                    if (abs(dermax-tempsvalmin(indexdermin)) > 0.2) % pic de taille normal
                        tempsdermin = tempsvalmin(indexdermin);
                        dermin = valmin(tempsdermin);
                    else % suppression des pic trop petit du souvent à une interference avec le cardiaque
                        valmin(tempsdermin(i)) =-150;
                    end
                    amplitudeRespi(tempsdermax:tempsdermin)=dermin-dermax;
                    indexdermin =indexdermin+1;
                end
            end
        end
        
        if dermin<-99
            % premier cas
            tempsdermax=tempsvalmax(i);
            dermax=valmax(tempsdermax);
        else
            % cas normal autre que premier
            if (abs(dermin-valmax(tempsvalmax(i))) > 0.2) % pic de taille normal
                tempsdermaxN2=tempsdermax;
                tempsdermax=tempsvalmax(i);
                dermax=valmax(tempsdermax);
                if tempsdermaxN2 > 0 % deuxieme  cas de max
                    periodeRespi(tempsdermaxN2:tempsdermax)=(tempsdermax-tempsdermaxN2)/FechRespi;
                    stabiliteBaserespi(tempsdermaxN2:tempsdermax) = derminN2 -dermin;
                end
                derminN2 = dermin;
            else
                valmax(tempsvalmax(i)) =-100;
                if indexdermin>1 && i>1 && (tempsvalmin(indexdermin-1)>tempsvalmax(i-1))
                    indexdermin=indexdermin-1;
                end
            end
            amplitudeRespi(tempsdermin:tempsdermax)=dermax-dermin;
        end
    end
end
stabiliteBaserespi = abs(stabiliteBaserespi);

if  ~isempty(prefixnamesavefigure)
    ii=strfind(prefixnamesavefigure,'\');
    if ~isempty(ii)
        labeltitre= prefixnamesavefigure(ii(end)+1:end);
    else
        labeltitre= prefixnamesavefigure;
    end
    labeltitre=strrep(labeltitre,'_',' ');
    fig = figure;
    plagedata = [0 120]; 
    subplot(4,1,1); 
    plot([1:length(signaltoProcess)]/FechRespi,signaltoProcess); %#ok<NBRAK>
    hold on;
    valmaxOK=valmax;
    valmaxOK(valmaxOK<-99) = NaN;
    valmaxError=valmax;
    valmaxError(valmax>-99) = NaN;
    plot([1:length(valmax)]/FechRespi,valmaxOK,'r+'); %#ok<NBRAK>
    plot([1:length(valmax)]/FechRespi,-valmaxError/100,'ro'); %#ok<NBRAK>
    valminOK=valmin;
    valminOK(valminOK<-99) = NaN;
    valminError=valmin;
    valminError(valmin>-99) = NaN;
    plot([1:length(valmin)]/FechRespi,valminOK,'g+'); %#ok<NBRAK>
    plot([1:length(valmin)]/FechRespi,valminError/100,'go'); %#ok<NBRAK>
    title([ labeltitre ' Respiration']);
    xlim(plagedata);
    subplot(4,1,2);
    grid;
    plot([1:length(amplitudeRespi)]/FechRespi,abs(amplitudeRespi),'r'); %#ok<NBRAK>
    title('Amplitude');
    grid;
    xlim(plagedata);
    subplot(4,1,3);
    plot([1:length(periodeRespi)]/FechRespi,(periodeRespi),'b'); %#ok<NBRAK>
    title('Periode');
    grid;
    xlim(plagedata);
    subplot(4,1,4);
    plot([1:length(periodeRespi)]/FechRespi,(stabiliteBaserespi),'g'); %#ok<NBRAK>
    title('Indice de Stabilité');
    grid;
    xlim(plagedata);
    savefig(fig,[ prefixnamesavefigure ' respi1.fig'])
    close(fig);
    
    fig=figure;
    
    plot([1:length(signaltoProcess)]/FechRespi,signaltoProcess); %#ok<NBRAK>
    hold on;
    plot([1:length(amplitudeRespi)]/FechRespi,abs(amplitudeRespi)+10,'r'); %#ok<NBRAK>
    plot([1:length(periodeRespi)]/FechRespi,(periodeRespi)-5); %#ok<NBRAK>
    plot([1:length(periodeRespi)]/FechRespi,(stabiliteBaserespi)-10); %#ok<NBRAK>
    valmaxOK=valmax;
    valmaxOK(valmaxOK<-99) = NaN;
    valmaxError=valmax;
    valmaxError(valmax>-99) = NaN;
    plot([1:length(valmax)]/FechRespi,valmaxOK,'r+'); %#ok<NBRAK>
    plot([1:length(valmax)]/FechRespi,-valmaxError/100,'ro'); %#ok<NBRAK>
    valminOK=valmin;
    valminOK(valminOK<-99) = NaN;
    valminError=valmin;
    valminError(valmin>-99) = NaN;
    plot([1:length(valmin)]/FechRespi,valminOK,'g+'); %#ok<NBRAK>
    plot([1:length(valmin)]/FechRespi,valminError/100,'go'); %#ok<NBRAK>
    legend('Respiration','Amplitude','Periode','Stabilité','maxPic','maxerrorPic','minPic','minerrorPic');
    grid;
    title([ labeltitre ' Respiration']);
    savefig(fig,[ prefixnamesavefigure ' respi2.fig']);
    pause(1);
    close(fig);
    
end