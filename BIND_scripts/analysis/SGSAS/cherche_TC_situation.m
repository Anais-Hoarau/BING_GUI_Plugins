function TC_debut_fin = cherche_TC_situation(trip,Route_Pk_Sens_Situation)

record_localisation = trip.getAllDataOccurences('localisation');
record_trajectoire = trip.getAllDataOccurences('trajectoire');

pk = cell2mat(record_localisation.getVariableValues('pk'));
timecode = cell2mat(record_localisation.getVariableValues('timecode'));
route = str2double(record_localisation.getVariableValues('route'));
sens = record_trajectoire.getVariableValues('sens');

pkMax_route42 = 156900; %Cas particulier de la route 42 (rond point) avec rupture de PK (mettre en commentaire cette ligne si méthode n°2)

TC_debut_fin = zeros(size(Route_Pk_Sens_Situation,1),2);
for i=1:1:size(Route_Pk_Sens_Situation,1)
    cas_situation = ['debut_' Route_Pk_Sens_Situation{i,3}]; %Mettre en commentaire cette ligne si méthode n°2
    temp1 = timecode(cherche_TC(Route_Pk_Sens_Situation(i,1:3))); %Remplacer par "temp1 = timecode(find(cherche_TC(Route_Pk_Sens_Situation(i,1:3)))+1);" si méthode n°2
    if ~isempty(temp1)
        TC_debut_fin(i,1) = temp1(end);
    end
    cas_situation = ['fin_' Route_Pk_Sens_Situation{i,6}]; %Mettre en commentaire cette ligne si méthode n°2
    temp2 = timecode(cherche_TC(Route_Pk_Sens_Situation(i,4:6))); %Remplacer par "temp2 = timecode(find(cherche_TC(Route_Pk_Sens_Situation(i,4:6)))+1);" si méthode n°2
    if ~isempty(temp2)
        TC_debut_fin(i,2) = temp2(1);
    end
    if TC_debut_fin(i,1) > TC_debut_fin(i,2) || isempty(find(TC_debut_fin(i,1), 1))
        cas_situation = ['fin_' Route_Pk_Sens_Situation{i,6}]; %Mettre en commentaire cette ligne si méthode n°2
        temp1 = timecode(cherche_TC(Route_Pk_Sens_Situation(i,1:3))); %Remplacer par "temp1 = timecode(find(cherche_TC(Route_Pk_Sens_Situation(i,1:3)))+1);" si méthode n°2
        TC_debut_fin(i,1) = temp1(end);
    end
end

    function logical_indexes = cherche_TC(Route_Pk_Sens)
        
        if strcmp(cas_situation, 'debut_Direct') || strcmp(cas_situation, 'fin_Inverse')
            
            DeltaPk = 50;
            pk_not_found = 0;
            while any(route ==  Route_Pk_Sens{1} & (pk > Route_Pk_Sens{2}-DeltaPk & pk < Route_Pk_Sens{2}) & strcmp(sens,Route_Pk_Sens{3})) == 0;
                DeltaPk = DeltaPk + 50;
                if DeltaPk > 15000 %ajouter un fichier log dans lequel inscrire les écarts de pk supérieurs à 1m
                    pk_not_found = 1;
                    break
                end
            end
            logical_indexes = (route ==  Route_Pk_Sens{1} & (pk > Route_Pk_Sens{2}-DeltaPk & pk < Route_Pk_Sens{2}) & strcmp(sens,Route_Pk_Sens{3}));
            
            if pk_not_found %Gestion du cas particulier de la route 42 (rond point) avec rupture de PK dans le sens Inverse
                DeltaPk = 50;
                while any(Route_Pk_Sens{1} == 42 & route ==  Route_Pk_Sens{1} & (pk > pkMax_route42-DeltaPk & pk < pkMax_route42) & strcmp(sens,Route_Pk_Sens{3})) == 0;
                    DeltaPk = DeltaPk + 50;
                    if DeltaPk > 15000
                        break
                    end
                end
                logical_indexes = (route ==  Route_Pk_Sens{1} & (pk > pkMax_route42-DeltaPk & pk < pkMax_route42) & strcmp(sens,Route_Pk_Sens{3}));
            elseif isempty(logical_indexes)
                disp('C''est la merde, on pas trouve le triplet route_pk_sens')
            else
            end
            
        elseif strcmp(cas_situation, 'debut_Inverse') || strcmp(cas_situation, 'fin_Direct')
            
            DeltaPk = 50;
            while any(route ==  Route_Pk_Sens{1} & (pk > Route_Pk_Sens{2} & pk < Route_Pk_Sens{2}+DeltaPk) & strcmp(sens,Route_Pk_Sens{3})) == 0;
                DeltaPk = DeltaPk + 50;
                if DeltaPk > 15000
                    break
                end
            end
            logical_indexes = (route ==  Route_Pk_Sens{1} & (pk > Route_Pk_Sens{2} & pk < Route_Pk_Sens{2}+DeltaPk) & strcmp(sens,Route_Pk_Sens{3}));
            
            if isempty(logical_indexes)
                disp('C''est la merde, on pas trouve le triplet route_pk_sens')
            else
            end
            
        end
        
    end
end

%% Méthode n°2 moins précise mais fonctionne dans les cas particuliers de rupture de PK sur les rond points

% DeltaPk = 100;
% while any(route ==  Route_Pk_Sens{1} & (pk > Route_Pk_Sens{2}-DeltaPk  & pk < Route_Pk_Sens{2}+DeltaPk) & strcmp(sens,Route_Pk_Sens{3})) == 0;
%     DeltaPk = DeltaPk + 100;
%     if DeltaPk > 60000
%         break
%     end
% end
% logical_indexes = (route ==  Route_Pk_Sens{1} & (pk > Route_Pk_Sens{2}-DeltaPk  & pk < Route_Pk_Sens{2}+DeltaPk ) & strcmp(sens,Route_Pk_Sens{3}));
%
% if isempty(logical_indexes)
%     disp('C''est la merde, on pas trouve le triplet route_pk_sens')
% else
% end
