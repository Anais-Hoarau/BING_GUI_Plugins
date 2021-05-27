%This function takes a table of situations (timecode ; integers) and a
%list of situation [intergers1 integers2 ..] and calculate the time spend
%in each situation

% Inputs :  -   a 2xN array : [timecode | situations]
%           -   a list of situation [intergers1 integers2 ..]

% Output : - Cellarray of the time spend in each situation


function [varargout] = decompter_temps(tableau,liste_situation)

current_situation=0;
time_current_situation=0;
N=length(liste_situation);
index_tab=(1:1:N);
varargout=cell(1,N);
    
    %initialisation situation
    for i=1:1:length(tableau)   
       if any(tableau(i,2)== liste_situation)
           current_situation=tableau(i,2);
           index_current_situation=index_tab(tableau(i,2)== liste_situation);
           time_current_situation=tableau(i,1);
           break;
       end 
    end
    
    time_situation=zeros(1,N);
    compteur_situation=ones(1,N);
    liste_temps=cell(1,N);
    %calcul du temps passé dans chaque situation.
    for i=1:1:length(tableau)
        tableau(i,2);
        
        if tableau(i,2)~=current_situation && any(tableau(i,2) == liste_situation)
                
           time_situation(index_current_situation)=(tableau(i,1)-time_current_situation)+time_situation(index_current_situation);
           liste_temps{index_current_situation}(compteur_situation(index_current_situation))=(tableau(i,1)-time_current_situation);
           
           compteur_situation(index_current_situation)=compteur_situation(index_current_situation)+1;
           
           
           %Mise à jour de la situation actuelle : idex et temps
           current_situation=tableau(i,2);
           index_current_situation=index_tab(tableau(i,2) == liste_situation);
           time_current_situation=tableau(i,1);
       

        end
    end
    
    
    
    time_situation(index_current_situation)= (tableau(end,1)-time_current_situation) + time_situation(index_current_situation);
    liste_temps{index_current_situation}(compteur_situation(index_current_situation))=(tableau(i,1)-time_current_situation);
    
    for i=1:1:N
    varargout{i}=time_situation(i)/60.0;       
    end
    varargout{N+1}=liste_temps;
end