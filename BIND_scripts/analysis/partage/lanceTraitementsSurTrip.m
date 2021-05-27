% Fonction permettant d'executer une suite d'actions configurable sur une
% suite de trip sélectionnés.

function lanceTraitementsSurTrip (tripFolderList, functionList)
% tripFolderList est un cell array des noms des trips à traiter
% functionList est un cell array des fonctions à appliquer aux trip ||
    % valeurs possibles : 'traitement' 'traitement_post_codage' ou 'export'

    for i=1:length(tripFolderList)
    
        if any(strcmp(functionList,'traitement')) % contient 'traitement'
            lanceTraitement(tripFolderList{i});
        end
        if any(strcmp(functionList,'traitement_post_codage')) % contient 'traitement_post_codage'
            lanceTraitementPostCodage(tripFolderList{i});
        end
        if any(strcmp(functionList,'export')) % contient 'export'
            lanceExport(tripFolderList{i});
        end
      
    end
    
end