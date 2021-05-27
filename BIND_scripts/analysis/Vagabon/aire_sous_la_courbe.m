%[FileName,PathName,~] = uigetfile('*.jpg');
%files_path = 'D:\LESCOT\PROJETS DE RECHERCHE\THESE_GUILLAUME\VAGABON\Courbes';
%if ~exist(files_path, 'dir')
%end

files_path = uigetdir();
courbes = dirrec(files_path);
for i_courbe = 1:length(courbes)
    courbe = importdata(courbes{i_courbe});
    split_nom_courbe = strsplit(courbes{i_courbe}, '\');
    nb_pixels = size(courbe, 1) * size(courbe, 2);
    aire_sous_la_courbe_pct = (nb_pixels - length(find(courbe>200)))/nb_pixels*100;
    tab_aires_pct{i_courbe, 1} = split_nom_courbe{end};
    tab_aires_pct{i_courbe, 2} = aire_sous_la_courbe_pct;
end
save([files_path filesep 'tab_aires_pct'], 'tab_aires_pct')