
%Durantin Gautier le 04/12/2012

function ecgconv(x,y,f)

global ecg;
global fs;
global s;

if ~ischar(x)
    error('Le premier argument doit etre un nom de fichier .mat')
end

if ~ischar(y)
    error('Le second argument doit etre un nom de fichier .mat')
end

if ~isscalar(f)
    error('Le troisième argument doit être la fréquence d echantillonage')
end

s=load(x);

ecg=s.data(:,1);
fs=f;
save(y,'ecg','fs')

end

