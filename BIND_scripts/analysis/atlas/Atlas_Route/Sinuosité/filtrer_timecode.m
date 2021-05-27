%this function filters a timecode array obtained during an
%experiment by key pressing. The input arrays is

function timecode_filtree = filtrer_timecode(timecode, intervalle_temps)
    index=1;
    timecode_filtree(index)=timecode(1);
    for i=2:1:length(timecode)
        if (timecode(i)-timecode(i-1))>intervalle_temps
        index=index+1;
        timecode_filtree(index) = timecode(i);
        end
        
    end


end