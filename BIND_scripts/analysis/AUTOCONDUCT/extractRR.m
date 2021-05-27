function [posPic, valRR , RR2, DRR2 ]=extractRR(cardiac, logfile,prefixnamesavefigure)

    
FcMin=40; FcMax=200; % recherche des pics entre une fréquence comprise entre 40 bat/min et 200 bat/min
%seuilAmpliMinPicR = 1;% et amplitude du pic au minimu a 1 volt
Fech = 1000; % fréquence echantillonage 
SeuilmaxVariationFc= 30;% variation maximale admise de variation entre deux valeurs concécuitive de battement cardiaque
[cardiacb, seuilAmpliMinPicR] = ligneBaseCardiaque(cardiac);
seuilAmpliMinPicR=min(seuilAmpliMinPicR,1);
cadiacSeuille = (cardiacb>seuilAmpliMinPicR);
%cherche debut fin de pic 
diffCadiacSeuille = diff(cadiacSeuille);
debPic = find(diffCadiacSeuille>0);
finPic = find(diffCadiacSeuille<0);
if debPic(1) > finPic(1) %demarre par un debut de pic
    finPic= finPic(2:end);
end
if debPic(end) > finPic(end)% fini par une fin de  pic
    debPic= debPic(1:end-1);
end
if length(debPic) ~= length(finPic) 
    s= '     GROS BUG Pb avec le seullage du signal cardiaque';
    if logfile>0 ; fprintf(logfile,'%s\n',s); else disp(s); end  %#ok<SEPEX>
end
%figure;plot(cardiac); hold on; plot(diffCadiacSeuille,'r');plot(cadiacSeuille+5,'g');
% lgpic = finPic-debPic;
% hist(lgpic,0:1:1000);
maxPic = zeros(length(debPic),1);
posPic = zeros(length(debPic),1);
dureePic = zeros(length(debPic),1);
diffcardiacb = diff(cardiacb);
for i = 1:length(debPic)
    dd=find(diffcardiacb(max(1,debPic(i)-2000):debPic(i))<0,1,'last');
    if debPic(i) > 2000
        dd= 2000-dd; 
    else
        dd=length(max(1,debPic(i)-2000):debPic(i))-dd;
    end
    ff=find(diffcardiacb(finPic(i):min(finPic(i)+1000,length(diffcardiacb)))>0,1);
    [maxPic(i), indexPic] = max(cardiacb(debPic(i):finPic(i)));
    posPic(i) = debPic(i)+indexPic-1;
    if ~isempty(ff) && ~isempty(dd)
        dureePic(i)= (ff+ finPic(i)) - (debPic(i)-dd);
    elseif isempty(ff)&& ~isempty(dd)
        dureePic(i)= (finPic(i)) - (debPic(i)-dd);
    elseif ~isempty(ff)&& isempty(dd)
        dureePic(i)= (ff+ finPic(i)) - (debPic(i));
    else
        dureePic(i)= ( finPic(i)) - (debPic(i));
    end
%     if (debPic(i)-dd + ff < 10) 
%         disp(debPic(i));
%     end
end
    
% hold on;
% plot(1:length(cardiac),cardiac+5,'r');
% plot(1:length(cardiacb),cardiacb,'g');
% plot(1:length(cardiac),-min(dureePic,50)/10,'b');

valRR = zeros(length(debPic),1);
previousposmax = -1;
previousRR=-1;
RR2 = -1 * ones(length(debPic),1);% carre des RRi
DRR2 = -1 * ones(length(debPic),1); % carre des RRi moins RRi-1
for i = 1:length(debPic)
    [ ~ , posmax] = max(cardiac(debPic(i):finPic(i)));
    posmax = posmax + debPic(i)-1;
    if previousposmax < 0 % 
        valRR(i) = -1;
        previousposmax=posmax;
    else
        diffposmax=(posmax-previousposmax);
        valRR(i) = (diffposmax/Fech);

        if (valRR(i)) > 60/FcMin % décrochage
            valRR(i)=-2;
            previousposmax = posmax;
            previousRR = -1;
        elseif (valRR(i)) < 60/FcMax % pic intermediaire apres R
            valRR(i) = -3;
        elseif dureePic(i) < 10 % pic trop court
            valRR(i) = -4;
        elseif previousRR <0 %  raccrochage apres un pb
            RR2(i) = valRR(i)*valRR(i);
            previousRR=valRR(i);
            previousposmax=posmax;
        elseif abs( 60/valRR(i)-60/previousRR) > SeuilmaxVariationFc % variation trop importante du RC
            valRR(i)=-5;
        elseif abs(maxPic(i)- max(cardiacb(max(1,debPic(i)-floor(diffposmax/2)):min(length(cardiacb),finPic(i)+floor(diffposmax/2))))) > 0.1  % pic intermediare avant R
            valRR(i)=-6;
        else
%             if 0> valRR(i) && valRR(i)< 0.5
%                 disp(debPic(i));
%             end
            RR2(i) = valRR(i)*valRR(i);
            if previousRR > 0 
                DRR2(i) = (previousRR-valRR(i))^2; 
            end
            previousRR=valRR(i);
            previousposmax=posmax;
        end
    end
end
    
if ~isempty(prefixnamesavefigure)
    
    ii=strfind(prefixnamesavefigure,'\');
    if ~isempty(ii)
        labeltitre= prefixnamesavefigure(ii(end)+1:end);
    else
        labeltitre= prefixnamesavefigure;
    end
    labeltitre=strrep(labeltitre,'_',' ');
    fig= figure;
    hold on;
    plot(1:length(cardiacb),cardiacb,'g');
    plot(debPic,valRR,'+');
    indexBonRR = find(valRR>0);
    valRR = valRR(indexBonRR);
    RR2 = RR2(indexBonRR);
    DRR2 = DRR2(indexBonRR);
    posPic=posPic(indexBonRR);
    title([ labeltitre ' cardiaque']);
    savefig(fig,[ prefixnamesavefigure ' cardiaque.fig'])
    close(fig);
end
