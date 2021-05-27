function out = isStoplights( indic )
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
    binIndic = dec2bin(hex2dec(indicWithPadding(3)), 3);
    out =  logical(str2double(binIndic(1)));
end

