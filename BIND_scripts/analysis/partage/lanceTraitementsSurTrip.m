% Fonction permettant d'executer une suite d'actions configurable sur une
% suite de trip s�lectionn�s.

function lanceTraitementsSurTrip (tripFolderList, functionList)
% tripFolderList est un cell array des noms des trips � traiter
% functionList est un cell array des fonctions � appliquer aux trip ||
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