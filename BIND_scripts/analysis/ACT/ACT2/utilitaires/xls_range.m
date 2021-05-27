function xls_range_str = xls_range(column_start,ligne,nbre_column,nbre_ligne)
alphabet ={'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z'};

xls_column_list_simple = alphabet;
xls_column_list_double = cell(length(alphabet)^2,1);
i_tot=1;
for i_l=1:1:length(alphabet)
    for i_c=1:1:length(alphabet)
    xls_column_list_double{i_tot} = [alphabet{i_l} alphabet{i_c}];
    i_tot =i_tot+1;
    end
end

xls_column_list_double = cell(length(alphabet)^2,1);
i_tot=1;
for i_l=1:1:length(alphabet)
    for i_c=1:1:length(alphabet)
    xls_column_list_double{i_tot} = [alphabet{i_l} alphabet{i_c}];
    i_tot =i_tot+1;
    end
end

xls_column_list_triple = cell(length(alphabet)^3,1);
i_tot=1;
for i_1=1:1:length(alphabet)
    for i_2=1:1:length(alphabet)
        for i_3=1:1:length(alphabet)
            xls_column_list_triple{i_tot} = [alphabet{i_1} alphabet{i_2} alphabet{i_3}];
            i_tot =i_tot+1;
        end
    end
end

%xls_column_list = [xls_column_list_simple' ; xls_column_list_double];
xls_column_list = [xls_column_list_simple' ;  xls_column_list_double ; xls_column_list_triple];

xls_range_str = [ xls_column_list{column_start} num2str(ligne)  ':'  xls_column_list{column_start+nbre_column-1}  num2str(ligne+nbre_ligne-1)];

end

