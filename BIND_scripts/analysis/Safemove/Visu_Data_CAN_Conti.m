%% Chargement du fichier mat de Kvaser
open('D:\SAFEMOVE_DATA\2_pre_manip_sujets\Ref05_130712_09h34\Ref05_safemove_enriched.mat');

%% R�cup�ration de la branche Conti
a = ans.safemove.conti.data;

%% R�cup�ration de les champs de la m�ta-structure de donn�es
liste=fieldnames(a);

%% It�ration
for i=2:8
   figure, 
   plot(a.(liste{1}).values,a.(liste{i}).values);
   title(char((liste{i})));
   xlabel(char(a.(liste{1}).unit));
   ylabel(char(liste{i}));
%    hgsave('.\ liste(i)')
end

