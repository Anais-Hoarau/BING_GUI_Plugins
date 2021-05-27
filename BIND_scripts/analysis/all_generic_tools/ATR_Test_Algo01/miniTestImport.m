%
% miniTestImport.m
%
%

suffixe = '_ven_mai_24_2013_09_42_04.txt';
fichier = ['WorldV2' suffixe];

fid=fopen(fichier,'r');
str1=fgetl(fid);
a = str1;                       % lecture de la première ligne, champ de 16 caractères,
Nb_Var = round(length(a)/16);   % contenant les noms de variables
% récupération des noms de variables
Var = cell(1,Nb_Var);
i=1;
for j= 1:length(a)
    c = a(j);
    if c ~= ' '
        Var(1,i) = strcat(Var(i), c);
        if a(j+1) == ' '
            i= i + 1;
        end
    end
end
clear a i j c

% la longueur de chaque champ est de 16 caractères.
% Var(2) = 'GAZE_ITEM_NAME' & Var(10) = 'HEAD_ITEM_NAME' sont des strings, 
% les autres variables sont numériques.

% récupération des données

i = 1; % n° de ligne
while ~feof(fid)
   i 
   str=fgetl(fid);
   V = cell(1,Nb_Var);
   for j=1:Nb_Var
       c1 = (16*(j-1)) + 1;
       c2 = 16*j;
       V(1,j) = cellstr(str(c1:c2));
   end
   
   for j=1:Nb_Var
       if (j~=2) & (j~=10)
           A = char(Var(j));
           expression = [A '(' num2str(i) ')' '=  str2num(char(V(' num2str(j) ')));'];
           eval(expression);
       end
   end
   i = i + 1;
end

