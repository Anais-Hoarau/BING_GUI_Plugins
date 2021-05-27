function [posrevir] = wheelreversal(posvol)
%wheelreversal Summary of this function goes here
%   This function computes the number of times that the
%   direction of steering wheel movement is reversed through a small,
%   finite angle, or gap. Reported gap size varies from 0.5 to 30 deg. 
%   
%   posvol is the wheel output position in degrees as a function of time
%
%   For more informations, see Macdonald, W. A., & Hoffmann, E. R. (1980). Review of relationships between steering wheel reversal rate and driving task demand. Human Factors: The Journal of the Human Factors and Ergonomics Society, 22(6), 733?739.
%   
%   Hugo Loeches De La Fuente & Joffrey Taillard (2016)


baselineposvol = mean (posvol);
posvol = posvol - baselineposvol;

vitvol = gradient(posvol);
accvol = gradient(vitvol);




count = 1;
for ii = 1:length(vitvol)-1;

mult = vitvol(ii)*vitvol(ii+1:end);
    
posneg = find(mult<0);

if (isempty(posneg) == 0)
    
posrevir (count) = posneg(1)+ii;

    count = count + 1;
end


end


[posrevir,ia2,ic2] = unique(posrevir,'stable');
        

% valposrevir = posvol(posrevir);
% difvalposrevir = gradient(valposrevir);
% posnuldifvalposrevir = find(difvalposrevir == 0);
% posrevir(posnuldifvalposrevir)=[];

difposrevir = diff(posrevir);
posnuldifposrevir = find(difposrevir == 1);
posrevir(posnuldifposrevir+1)=[];

valposrevir = posvol(posrevir);
ampposrevir = find (abs(valposrevir) > 10); % Initialement 10 degrès max
posrevir(ampposrevir) = [];

valposrevir = posvol(posrevir);
ampposrevir2 = find (abs(valposrevir) < 0.5);
posrevir(ampposrevir2) = [];





end



