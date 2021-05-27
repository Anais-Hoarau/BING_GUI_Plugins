%this function filters a timecode array obtained during an
%experiment by key pressing. The input arrays is

function [timecode_filtre,data_filtre] = filtrer_data_asynchrone(timecode, data)
    index=1;
    timecode_filtre(index)=timecode(1);
    data_filtre(index)=data(1);
    for i=2:1:length(timecode)
        if (data(i)~=data(i-1))
        index=index+1;
        timecode_filtre(index) = timecode(i);
        data_filtre(index)=data(i);
        
        end
        
    end


end