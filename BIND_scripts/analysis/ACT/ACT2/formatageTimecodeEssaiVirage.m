% This function takes the variable 'temps' generatted by the Lepsis
% simulator converts in a timecode in seconds

% this functions also processes the first comment column generated during a Lepsis
% simulation. It return start and the end timecodes of each 'Essai' and the number of the 'Essai'

function [timecode,Scenario,Essai,Virage] = formatageTimecodeEssaiVirage(temps,com1)

    N= length(temps);
    timecode = zeros(N,1);
    Essai=[];
    Virage=[];
    Scenario=[];
    
    deb_scenario =0;
    jjj=1;
    
    deb_essai=0;
    j=1;
    
    deb_Virage=0;
    jj=1;
    
    timecode(1,1) = 0;
    for i=1:1:N-1
        temp = temps{i+1};
        heure =  str2double(temp(1:2));
        minute =  str2double(temp(4:5));
        seconde =  str2double(temp(7:8));
        ms =  str2double(temp(9:end))/100;
        timecode(i+1,1) = (heure*3600 + minute*60 + seconde) + ms/1000;
        
    %% Début et Fin de scénario
        if ~isempty(strfind(com1{i},'__Vitesse=90km/h'))
            Scenario(jjj,1) = timecode(i+1,1);%#ok
            Scenario(jjj,3) = i+1;%#ok
            deb_scenario = 1;
        end
        
        if (~isempty(strfind(com1{i},'__TERMINE'))) && deb_scenario==1
            Scenario(jjj,2) = timecode(i+1,1);%#ok
            Scenario(jjj,4) = i+1;%#ok
            jjj=jjj+1;
            deb_scenario=0;
        end
        
    %% Formatage des commentaires Essai
        if ~isempty(strfind(com1{i},'DebutEssai'))
            Essai(j,1) = timecode(i+1,1);%#ok
            label = com1{i};
            Essai(j,3) = str2double(label(end));%#ok
            Essai(j,4) = i+1;%#ok
            deb_essai = 1;
        end
        
        if (~isempty(strfind(com1{i},'FinEssai'))) && deb_essai==1
            Essai(j,2) = timecode(i+1,1);%#ok
            Essai(j,5) = i+1;%#ok
            j=j+1;
            deb_essai=0;
        end

    %% Formatage des commentaires Virage    
        if (~isempty(strfind(com1{i},'DebutVirage')))||(~isempty(strfind(com1{i},'Debutvirage')))
            Virage(jj,1) = timecode(i,1);%#ok
            label = com1{i};
            Virage(jj,3) = str2double(label(end));%#ok
            Virage(jj,4) = i;%#ok
            deb_Virage = 1;
        end
        
        if ~isempty(strfind(com1{i},'FinVirage'))||~isempty(strfind(com1{i},'Finvirage')) && deb_Virage==1
            Virage(jj,2) = timecode(i,1);%#ok
            Virage(jj,5) = i;%#ok
            jj=jj+1;
            deb_Virage=0;
        end   
    end

end