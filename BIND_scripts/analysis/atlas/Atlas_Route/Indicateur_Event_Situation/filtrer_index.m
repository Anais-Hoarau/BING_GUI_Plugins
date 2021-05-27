%Cette fonction filtre les indices et renvoie les debut et fin de groupes
%d'indices conséquetifs

function index_debut_fin = filtrer_index(index)
        
    if isempty(index)
        disp('Err: There is no indexes to filter')
        index_debut_fin = index;
        
    else
    
        index_debut_fin(1,1) = index(1,1);
        j=1;
        for i=1:1:(length(index)-1)

            if (index(i+1)-index(i))>3
                index_debut_fin(j,2)=index(1,i);
                j=j+1;
                index_debut_fin(j,1)=index(1,i+1);
            end
              
        end  
        index_debut_fin(j,2) = index(1,end);  
        
    end
end