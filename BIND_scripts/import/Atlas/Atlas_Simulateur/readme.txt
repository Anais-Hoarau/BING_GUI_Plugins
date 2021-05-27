Voici quelques instructions pour comprendre le fonctionnement des programmes d'import 
de la manip ATLAS.

La difficulté principale consiste à importer et synchroniser de nombreuses sources 
de données :
+ Simulateur (fichiers var)
+ Vidéo
+ Cardiaque
(+ Facelab <= non réalisé)

== Où commencer ? ==

Deux points d'entrée :
+ batchImportAllAtlas
+ scriptImportManuel

batchImportAllAtlas permet d'importer toutes les données de tous les sujets d'un coup.
scriptImportManuel permet de sélectionner manuellement les sujets qui nous intéressent.

DESCRIPTION

Dans les deux cas, le principe est le suivant :
Un cell array contenant les informations de tous les sujets est construit (chemin des
fichiers, numéro de sujet, numéro de scénario, condition, etc.), puis il est filtré 
(dans le cas du scriptImportManuel) pour sélectionner un sous-ensemble de sujets.
Puis enfin, le script d'import et de synchronisation est appelé.


== import et synchronisation ==

FICHIERS

Il existe deux scripts d'import et de synchronisation :
+ BatchImportAtlas
+ batch_new/MagicBatchImportAtlas (à préférer)

Les deux fonctionnent sur le même principe. Le premier contient tout le code métier
dans le même fichier, le deuxième fait appel à des fonctions facilitatrices (dans le 
dossier utilitaires) et décorrèle mieux les différents parties du script.
MagicBatchImportAtlas est donc à préférer.

DESCRIPTION

Le script d'import et de synchronisation va vérifier la présence des fichiers 
nécessaires (simulateur, vidéo, cardio...) et s'il y a bien le bon nombre de 
fichiers attendu, va tenter de :
+ Importer le fichier .var en fichier BIND et ainsi créer un fichier .trip
+ Ajouter le fichier vidéo dans le .trip
+ Parser le fichier cardiaque pour importer la sous-partie intéressante dans le .trip

Si une des étapes n'est pas réalisée, l'étape suivante est essayée et ainsi de suite.
Si un problème se pose à une étape ou pour un sujet, le script continue à fonctionner
sur le sujet/scenario suivant.

Le script vérifie avant d'exécuter une étape si elle a déjà été exécutée par le 
passé. Si c'est le cas, plutôt que de refaire le calcul, on passe à l'étape suivante.

Un fichier .csv est créé pour lister l'état de l'ensemble des calculs sur l'ensemble
des sujets et des scénarios. Si une erreur n'a pas pu être gérée dans le script, 
cela sera noté dans le fichier csv.
En plus de cela, le détail de chaque erreur est enregistrée dans un fichier .log, ce
qui permet d'étudier plus en détail l'origine de l'erreur.


== Données Cardiaques ==

L'import des données cardiaque est délicat pour plusieurs raisons :
1) D'une part le fichier acknowledge doit être converti en fichier .mat matlab,
mais ce fichier matlab est parfois trop gros pour être chargé dans la mémoire, 
ce qui crée des erreurs de dépassement de taille mémoire.

2) d'autre part, les événements de synchronisation ne sont pas exportées dans le
fichier matlab. Il est donc nécessaire de les exporter manuellement (création
d'un journal d'événements)

3) il y a un fichier cardiaque pour la totalité de la manip. Il est donc 
nécessaire de redécouper (à partir des événements) la partie correspondante à 
chaque scénario.


Pour résoudre le point 1), la solution adoptée est d'ouvrir le fichier matlab seul
et de le sauvegarder dans un format matlab (.mat) récent qui permet la lecture des
donnée sans charger le fichier complet en mémoire.

Pour résoudre le point 2), le script batchParseCardioEvents parse les fichiers
journeaux d'événements pour construire un fichier matlab décrivant les événements 
(via la fonction parseCardioEvents).
Le fichier matlab généré (SXX_cardiaque_events.mat) peut ensuite être réutilisé
par le script d'import.

Pour résoudre le point 3), la fonction parseCardioEvents précédemment citée regroupe
les events en fonction de leurs types et de la condition (C, DV ou DVS) du scénario.


Lors de l'import dans BIND, les données cardiaques à 1000 Hz sont importées dans
une table de type data.
Les données provenant du journal d'événements sont importées dans une table de 
type event.

