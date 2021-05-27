function [posPic, valRR, RR2, DRR2] = MadisonExtractRR(cardiac, logfile)
    
    FcMin=30; FcMax=200; % recherche des pics entre une fréquence comprise entre FcMin bat/min et FcMax bat/min
    
    %seuilAmpliMinPicR = 1;% et amplitude du pic au minimu a 1 volt
    
    Fech = 1000; % fréquence echantillonage
    SeuilmaxVariationFc= 50;% variation maximale admise de variation entre deux valeurs consécutives de battement cardiaque
    [B,A] = cheby2(4,20,[0.5/(Fech/2) 30/(Fech/2)]); % filtrage
    cardiaf = filtfilt(B,A,cardiac);
    cardiacb = ligneBaseCardiaque(cardiaf);
    
    seuilAmpliMinPicR = detecteMax(cardiacb, 500);
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
    for i = 2:(length(debPic)-1)
        dd=find(diffcardiacb(max(1,debPic(i)-2000):debPic(i))<0,1,'last')+max(1,debPic(i)-2000)-1;
        ff=find(diffcardiacb(finPic(i):min(finPic(i)+1000,length(diffcardiacb)))>0,1);
        [maxPic(i), indexPic] = max(cardiacb(debPic(i):finPic(i)));
        posPic(i) = debPic(i)+indexPic-1;
        dureePic(i)= debPic(i)-dd + ff;
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
        %     if i>1 && valRR(i-1)==-2
        %         valRR(i)=-7;
        %     else
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
            elseif dureePic(i) < 10   % pic trop court
                valRR(i) = -4;
            elseif  dureePic(i) > 70 % pic trop long
                valRR(i) = -4.5;
            elseif previousRR <0 %  raccrochage apres un pb
                RR2(i) = valRR(i)*valRR(i);
                previousRR=valRR(i);
                previousposmax=posmax;
            elseif abs( 60/valRR(i)-60/previousRR) > SeuilmaxVariationFc % variation trop importante du RC
                valRR(i)=-5;
                % pic intermediare avant R
            elseif abs(maxPic(i)- max(cardiacb(max(1,debPic(i)-floor(diffposmax/2)):min(length(cardiacb),finPic(i)+floor(diffposmax/2))))) > 0.1
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
        %     end
    end
    
    figure;
    plot(1:length(cardiacb),cardiacb,'g');
    hold on;
    plot(1:length(cardiac),cardiac+5,'b');
    plot(debPic,valRR,'+');
    plot(debPic,dureePic/10,'*');
    indexBonRR = find(valRR>0);
    valRR = valRR(indexBonRR);
    RR2 = RR2(indexBonRR);
    DRR2 = DRR2(indexBonRR);
    posPic = posPic(indexBonRR);
    dureePic=dureePic(indexBonRR);
    
end