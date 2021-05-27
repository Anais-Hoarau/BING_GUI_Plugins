% Cette fonction creer les un cellarray de timecode de début et de fin de
% situation. Elle prend en entrée l'array des timecode, les données
% (TopConsigne typiquement) et la valeur qui correspont à la situation en
% question

function timecode_array_debut_fin = extrat_debut_fin_situation_timecode(timecode,data,situation_value)
index=(1:1:length(timecode));
index_situation = filtrer_index(index(data==situation_value));

j=1;
timecode_array_debut_fin = zeros(size(index_situation,1),2);

    if ~isempty(index_situation)
        for i=1:1:size(index_situation,1)
            timecode_array_debut_fin(j,1) = timecode(index_situation(i,1));
            timecode_array_debut_fin(j,2) = timecode(index_situation(i,2));
            j=j+1;
        end
    else
        
        disp(['Il n''y a pas de Topage correspondant à la valeur :' num2str(situation_value)])
        
        timecode_array_debut_fin(:,:) = [];
    end
    
end