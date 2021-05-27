%
% FL5_testImport.m
% importation de donn�es faceLAB 5
% voir l'automatisation des lectures de noms de fichiers
suffixe = '_jeu_juin_6_2013_09_19_06.txt'
% ------------------------------------------------------
% import des data du fichier Timing

A = importdata(['Timing' suffixe]);
a = char(A.textdata);
s = size(A.data);
Nb_FaceLab = s(1);
Nb_Var = s(2);

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

for i=1:Nb_Var
    expression = [char(Var(i)) ' =  A.data(:,i);'];
    eval(expression);
end
clear j i c A a s Var Nb_Var expression
% Les variables conserv�es :
% FRAME_NUM EXPERIMENT_TIME GMT_S GMT_MS
% Les variables effac�es :
clear DELAY ANNOTATION_ID

% ------------------------------------------------------
% import des data du fichier Eye

A = importdata(['Eye' suffixe]);
a = char(A.textdata);
s = size(A.data);
Nb_FaceLab = s(1);
Nb_Var = s(2);

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

for i=1:Nb_Var
    expression = [char(Var(i)) ' =  A.data(:,i);'];
    eval(expression);
end
clear j i c A a s Var Nb_Var expression
% Les variables conserv�es :
% FRAME_NUM BLINKING BLINK_FREQ BLINK_DURATION
% GAZE_QUAL_R EYEBALL_R_X EYEBALL_R_Y EYEBALL_R_Z
% GAZE_QUAL_L EYEBALL_L_X EYEBALL_L_Y EYEBALL_L_Z
% GAZE_CALIB SACCADE PUPIL_R_DIAM PUPIL_L_DIAM
% Les variables effac�es :
clear RIGHT_EYE_CLOSE LEFT_EYE_CLOSE RIGHT_CLOS_CONF LEFT_CLOS_CONF EYE_CLOSE_CALIB PERCLOS
clear GAZE_ROT_R_X GAZE_ROT_R_Y GAZE_ROT_L_X GAZE_ROT_L_Y
clear VERGE_PNT_X VERGE_PNT_Y VERGE_PNT_Z VERGE_DIST VERGE_ANGLE
clear PUPIL_R_X PUPIL_R_Y PUPIL_R_Z PUPIL_L_X PUPIL_L_Y PUPIL_L_Z

% ------------------------------------------------------
% import des data du fichier Face
% aucune variable import�e

% ------------------------------------------------------
% import des data du fichier HeadV2
% aucune variable import�e
% ------------------------------------------------------

% import des data du fichier WorldV2
% le format n'est pas identique aux autres fichiers !!!
% avant les traitement, nous rempla�ons sous un �diteur les Nothing en 0,
% pour cette exp�rimentation il n'y a qu'un seul plan dans le World Model,
% appel� "1", de mani�re � avoir une valeur num�rique

A = importdata(['WorldV2' suffixe]);
a = char(A.textdata);
s = size(A.data);
Nb_FaceLab = s(1);
Nb_Var = s(2);

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

for i=1:Nb_Var
    expression = [char(Var(i)) ' =  A.data(:,i);'];
    eval(expression);
end
clear j i c A a s Var Nb_Var expression
% Les variables conserv�es :
% FRAME_NUM GAZE_ITEM_NAME GAZE_PLANE_X GAZE_PLANE_Y GAZE_PIXEL_X GAZE_PIXEL_Y
% Les variables effac�es :
clear GAZE_WORLD_X GAZE_WORLD_Y GAZE_WORLD_Z
clear HEAD_ITEM_NAME HEAD_WORLD_X HEAD_WORLD_Y HEAD_WORLD_Z
clear HEAD_PLANE_X HEAD_PLANE_Y HEAD_PIXEL_X HEAD_PIXEL_Y

% ------------------------------------------------------

%sauvegarde des donn�es utiles
save('data_manip.mat')

