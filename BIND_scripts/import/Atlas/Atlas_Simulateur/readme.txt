Voici quelques instructions pour comprendre le fonctionnement des programmes d'import 
de la manip ATLAS.

La difficult� principale consiste � importer et synchroniser de nombreuses sources 
de donn�es :
+ Simulateur (fichiers var)
+ Vid�o
+ Cardiaque
(+ Facelab <= non r�alis�)

== O� commencer ? ==

Deux points d'entr�e :
+ batchImportAllAtlas
+ scriptImportManuel

batchImportAllAtlas permet d'importer toutes les donn�es de tous les sujets d'un coup.
scriptImportManuel permet de s�lectionner manuellement les sujets qui nous int�ressent.

DESCRIPTION

Dans les deux cas, le principe est le suivant :
Un cell array contenant les informations de tous les sujets est construit (chemin des
fichiers, num�ro de sujet, num�ro de sc�nario, condition, etc.), puis il est filtr� 
(dans le cas du scriptImportManuel) pour s�lectionner un sous-ensemble de sujets.
Puis enfin, le script d'import et de synchronisation est appel�.


== import et synchronisation ==

FICHIERS

Il existe deux scripts d'import et de synchronisation :
+ BatchImportAtlas
+ batch_new/MagicBatchImportAtlas (� pr�f�rer)

Les deux fonctionnent sur le m�me principe. Le premier contient tout le code m�tier
dans le m�me fichier, le deuxi�me fait appel � des fonctions facilitatrices (dans le 
dossier utilitaires) et d�corr�le mieux les diff�rents parties du script.
MagicBatchImportAtlas est donc � pr�f�rer.

DESCRIPTION

Le script d'import et de synchronisation va v�rifier la pr�sence des fichiers 
n�cessaires (simulateur, vid�o, cardio...) et s'il y a bien le bon nombre de 
fichiers attendu, va tenter de :
+ Importer le fichier .var en fichier BIND et ainsi cr�er un fichier .trip
+ Ajouter le fichier vid�o dans le .trip
+ Parser le fichier cardiaque pour importer la sous-partie int�ressante dans le .trip

Si une des �tapes n'est pas r�alis�e, l'�tape suivante est essay�e et ainsi de suite.
Si un probl�me se pose � une �tape ou pour un sujet, le script continue � fonctionner
sur le sujet/scenario suivant.

Le script v�rifie avant d'ex�cuter une �tape si elle a d�j� �t� ex�cut�e par le 
pass�. Si c'est le cas, plut�t que de refaire le calcul, on passe � l'�tape suivante.

Un fichier .csv est cr�� pour lister l'�tat de l'ensemble des calculs sur l'ensemble
des sujets et des sc�narios. Si une erreur n'a pas pu �tre g�r�e dans le script, 
cela sera not� dans le fichier csv.
En plus de cela, le d�tail de chaque erreur est enregistr�e dans un fichier .log, ce
qui permet d'�tudier plus en d�tail l'origine de l'erreur.


== Donn�es Cardiaques ==

L'import des donn�es cardiaque est d�licat pour plusieurs raisons :
1) D'une part le fichier acknowledge doit �tre converti en fichier .mat matlab,
mais ce fichier matlab est parfois trop gros pour �tre charg� dans la m�moire, 
ce qui cr�e des erreurs de d�passement de taille m�moire.

2) d'autre part, les �v�nements de synchronisation ne sont pas export�es dans le
fichier matlab. Il est donc n�cessaire de les exporter manuellement (cr�ation
d'un journal d'�v�nements)

3) il y a un fichier cardiaque pour la totalit� de la manip. Il est donc 
n�cessaire de red�couper (� partir des �v�nements) la partie correspondante � 
chaque sc�nario.


Pour r�soudre le point 1), la solution adopt�e est d'ouvrir le fichier matlab seul
et de le sauvegarder dans un format matlab (.mat) r�cent qui permet la lecture des
donn�e sans charger le fichier complet en m�moire.

Pour r�soudre le point 2), le script batchParseCardioEvents parse les fichiers
journeaux d'�v�nements pour construire un fichier matlab d�crivant les �v�nements 
(via la fonction parseCardioEvents).
Le fichier matlab g�n�r� (SXX_cardiaque_events.mat) peut ensuite �tre r�utilis�
par le script d'import.

Pour r�soudre le point 3), la fonction parseCardioEvents pr�c�demment cit�e regroupe
les events en fonction de leurs types et de la condition (C, DV ou DVS) du sc�nario.


Lors de l'import dans BIND, les donn�es cardiaques � 1000 Hz sont import�es dans
une table de type data.
Les donn�es provenant du journal d'�v�nements sont import�es dans une table de 
type event.

