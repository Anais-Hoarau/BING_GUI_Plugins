function [struct_kvaser_filtree] = filtrage_struct_kvaser_ARS(struct_kvaser)

%% Initilisation de la structure kvaser filtrée en conservant le formalisme nécessaire à l'import via 'strct2bind'
struct_kvaser_filtree.META = struct_kvaser.META;
struct_kvaser_filtree.META.type = 'TEXT';

struct_kvaser_filtree.ARS.time_sync.unit ='s';
struct_kvaser_filtree.ARS.time_sync.comments = 'synchronised timecode';

struct_kvaser_filtree.ARS.ID.unit = '';
struct_kvaser_filtree.ARS.ID.comments = 'array has been converted to a single string';

struct_kvaser_filtree.ARS.LatDispl.unit = 'm';
struct_kvaser_filtree.ARS.LatDispl.comments = 'array has been converted to a single string';

struct_kvaser_filtree.ARS.LongDispl.unit = 'm';
struct_kvaser_filtree.ARS.LongDispl.comments = 'array has been converted to a single string';

struct_kvaser_filtree.ARS.VrelLong.unit = 'm/s';
struct_kvaser_filtree.ARS.VrelLong.comments = 'array has been converted to a single string';

struct_kvaser_filtree.ARS.Length.unit = 'categorie';
struct_kvaser_filtree.ARS.Length.comments = 'array has been converted to a single string';

struct_kvaser_filtree.ARS.Width.unit = 'categorie';
struct_kvaser_filtree.ARS.Width.comments = 'array has been converted to a single string';

struct_kvaser_filtree.ARS.LatSpeed.unit = 'm/s';
struct_kvaser_filtree.ARS.LatSpeed.comments = 'array has been converted to a single string';

struct_kvaser_filtree.ARS.ObstacleProba.unit = '';
struct_kvaser_filtree.ARS.ObstacleProba.comments = 'array has been converted to a single string';
    
%% Filtrage des données radar brutes    
radar_time = struct_kvaser.ARSSt.time_sync.values;
N =length(radar_time);

object_time = struct_kvaser.ARS1.time_sync.values;
N_objet = length(object_time);

Objets = cell(2,N-1);
number_missed_obj = 0;
pourcentage_accomplie =5; 
% Récupération des groupes de cible (40 en régle générale). Filtrage temporelle préalble pour agmenter la vitesse de traitement. 
% Ajout d'un décalage d'incide "number_missed_obj" pour compencer le manque de certaines cibles (39 au lieu de 40)
    for i_time=1:1:N-1
        if 100*(i_time/N)> pourcentage_accomplie
            disp (['Mise en forme des données radar : ' num2str(pourcentage_accomplie) ' % accompli'])
            pourcentage_accomplie = pourcentage_accomplie+5;
        end

        t1_radar = radar_time(i_time);
        t2_radar = radar_time(i_time+1);
        
        %i_time
        
        %filtre indice est une plage plus restreinte qui contient le pas
        %temps qui nous intresse
        if i_time <= 3
            filtre_indice = 1:1:(i_time+10)*40;
        elseif (i_time+3)*40 > N_objet
            filtre_indice = (i_time-3)*40+1-number_missed_obj : 1 : N_objet;
        else
            filtre_indice = (i_time-3)*40+1-number_missed_obj : 1 :(i_time+3)*40;
        end
        
        % le masque 'mask' permet de choisri les 40 cibles qui correspond
        % au pas temps en question
        mask = (object_time(filtre_indice)>t1_radar)&(object_time(filtre_indice)<t2_radar);
        number_missed_obj = number_missed_obj + (40-nnz(mask));

        Objets{1,i_time} = t1_radar;
        Objets{2,i_time} = SelectionPlageRadar(struct_kvaser,filtre_indice,mask);
    end
    disp('*** Mise en forme des données radar accompli ***');
% Boucle de filtrage primaire des objets. Permet de ne garder que les cibles mobiles (véhicules)
pourcentage_accomplie =5;
    for i_time =1:1:N-1
        if 100*(i_time/N)> pourcentage_accomplie
            disp (['Filtrage des données radar : ' num2str(pourcentage_accomplie) ' % accompli'])
            pourcentage_accomplie = pourcentage_accomplie+5;
        end
        
        struct_kvaser_filtree.ARS.time_sync.values(i_time,1) = Objets{1,i_time};
        struct_filtree = filtragePrimaireObjets(Objets{2,i_time});
        
        struct_kvaser_filtree.ARS.ID.values{i_time,1}= array2str(struct_filtree.ID);
        struct_kvaser_filtree.ARS.LatDispl.values{i_time,1}= array2str(round(10*struct_filtree.LatDispl)/10);
        struct_kvaser_filtree.ARS.LongDispl.values{i_time,1}= array2str(round(10*struct_filtree.LongDispl)/10);
        struct_kvaser_filtree.ARS.VrelLong.values{i_time,1}= array2str(struct_filtree.VrelLong);
        struct_kvaser_filtree.ARS.Length.values{i_time,1}= array2str(struct_filtree.Length);
        struct_kvaser_filtree.ARS.Width.values{i_time,1}= array2str(struct_filtree.Width);
        struct_kvaser_filtree.ARS.LatSpeed.values{i_time,1}= array2str(struct_filtree.LatSpeed);
        struct_kvaser_filtree.ARS.ObstacleProba.values{i_time,1}= array2str(struct_filtree.ObstacleProba);   
    end
    disp('*** Filtrage des données radar accompli ***');
end

%% Function qui renvoit les données de la plage définit par 'filtre_indice' et 'mask'
function prop_stuct = SelectionPlageRadar(struct_kvaser,filtre_indice,mask)

if filtre_indice(end) > length(struct_kvaser.ARS1.Obj_MeasStat.values)
   filtre_indice_ARS1 = filtre_indice(1):1:length(struct_kvaser.ARS1.Obj_MeasStat.values);
   mask_ARS1 = mask(1:length(filtre_indice_ARS1));
else
   filtre_indice_ARS1 = filtre_indice;
   mask_ARS1 = mask;
end

MeasStat = struct_kvaser.ARS1.Obj_MeasStat.values(filtre_indice_ARS1);
prop_stuct.MeasStat = MeasStat(mask_ARS1);

DynProp = struct_kvaser.ARS1.Obj_DynProp.values(filtre_indice_ARS1);
prop_stuct.DynProp = DynProp(mask_ARS1);

ID = struct_kvaser.ARS1.Obj_ID.values(filtre_indice_ARS1);
prop_stuct.ID = ID(mask_ARS1);

LatDispl = struct_kvaser.ARS1.Obj_LatDispl.values(filtre_indice_ARS1);
prop_stuct.LatDispl = LatDispl(mask_ARS1);

LongDispl = struct_kvaser.ARS1.Obj_LongDispl.values(filtre_indice_ARS1);
prop_stuct.LongDispl = LongDispl(mask_ARS1);

VrelLong = struct_kvaser.ARS1.Obj_VrelLong.values(filtre_indice_ARS1);
prop_stuct.VrelLong = VrelLong(mask_ARS1);

Length = struct_kvaser.ARS1.Obj_Length.values(filtre_indice_ARS1);
prop_stuct.Length = Length(mask_ARS1);

Width = struct_kvaser.ARS1.Obj_Width.values(filtre_indice_ARS1);
prop_stuct.Width = Width(mask_ARS1);

if filtre_indice(end) > length(struct_kvaser.ARS2.Obj_LatSpeed.values)
   filtre_indice_ARS2 = filtre_indice(1):1:length(struct_kvaser.ARS2.Obj_LatSpeed.values);
   mask_ARS2 = mask(1:length(filtre_indice_ARS2));
else
   filtre_indice_ARS2 = filtre_indice;
   mask_ARS2 = mask;
end

LatSpeed = struct_kvaser.ARS2.Obj_LatSpeed.values(filtre_indice_ARS2);
prop_stuct.LatSpeed = LatSpeed(mask_ARS2 );

ObstacleProba = struct_kvaser.ARS2.Obj_ObstacleProba.values(filtre_indice_ARS2);
prop_stuct.ObstacleProba = ObstacleProba(mask_ARS2 );
end

%% Filtrage primaire des cibles. On ne garde que les cibles mobiles qui ont une taille bien définie 
% (et accéssoirement qui sont pas trop larges ... pont par exple)
function [struct_filtree] = filtragePrimaireObjets(struct)

mask = ((struct.MeasStat == 1) | (struct.MeasStat == 2) | (struct.MeasStat == 3) )  ...
    & ((struct.DynProp == 2) | (struct.DynProp == 3) | (struct.DynProp == 4)) ...
    & ~((struct.Length == 0) | (struct.Width == 0)) ...
    & (struct.Width < 4) ;
 
struct_filtree.MeasStat = struct.MeasStat(mask);
struct_filtree.DynProp = struct.DynProp(mask);
struct_filtree.ID = struct.ID(mask);
struct_filtree.LatDispl = struct.LatDispl(mask);
struct_filtree.LongDispl = struct.LongDispl(mask);
struct_filtree.VrelLong = struct.VrelLong(mask);
struct_filtree.Length = struct.Length(mask);
struct_filtree.Width = struct.Width(mask);
struct_filtree.LatSpeed = struct.LatSpeed(mask);
struct_filtree.ObstacleProba = struct.ObstacleProba(mask);
end

function [str]=array2str(array)
    str = '';
    if isempty(array)
        return; 
    else
        if size(array,1)>1
            array = array';
        end
        str = mat2str(array);
        if length(array)>1
            str = str(2:end-1);
        end
    end
end
