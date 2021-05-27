function [PositionVoie_filtree] = filtrage_postionVoie(timecode,PositionVoie,Route)

diff_Route  = [0 diff(Route)];
mask_int = zeros(1,length(PositionVoie));
PositionVoie_filtree = zeros(1,length(PositionVoie));
value=0;

for i=1:1:length(PositionVoie)
    if diff_Route(i)~=0
        value= value+1;
    end
    mask_int(i)=value;
end

mask_int = mask_int +1;

indice_sens_variation =5;

for j=1:1:(value+1)
    
    PositionVoie_temp = PositionVoie(mask_int==j);
    try
    sens_variation = (PositionVoie_temp(indice_sens_variation) - PositionVoie_temp(1)) ...
        / abs(PositionVoie_temp(indice_sens_variation) - PositionVoie_temp(1));
    catch
    end
    
    if j==1
        PositionVoie_filtree(mask_int==j) = PositionVoie_temp;
    else
             
        if sens_variation == last_sens_variation
            PositionVoie_temp = (PositionVoie_temp - (PositionVoie_temp(1) - last_value));
            PositionVoie_filtree(mask_int==j) = PositionVoie_temp;
        else
            
            PositionVoie_temp = PositionVoie_temp -PositionVoie_temp(1);
            PositionVoie_temp = - PositionVoie_temp;
            PositionVoie_temp = PositionVoie_temp + last_value;
            PositionVoie_filtree(mask_int==j) =PositionVoie_temp;
            
        end
    end
    
    last_value = PositionVoie_temp(end);

    try 
    last_sens_variation = (PositionVoie_temp(end) - PositionVoie_temp(end-indice_sens_variation)) ...
        /abs(PositionVoie_temp(end) - PositionVoie_temp(end-indice_sens_variation));
    catch
        disp('loupé')
    end

end

end