function out = isHeadlights( indic )
    indicWithoutPadding = indic;
    if length(indicWithoutPadding) == 1
        indicWithPadding = [indicWithoutPadding '00'];
    else if length(indicWithoutPadding) == 2
            indicWithPadding = [indicWithoutPadding '0'];
        else if length(indicWithoutPadding) == 3
                indicWithPadding = indicWithoutPadding;
            end
        end
    end
    binIndic = dec2bin(hex2dec(indicWithPadding(2)), 4);
    out =  logical(str2double(binIndic(3)));
end

