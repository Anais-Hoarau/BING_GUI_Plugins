 V4.6

français

commentaireManip= Manip training 1 2010 rédigé par Joceline juin 2009 !! TACHE DE DETECTION AUTOROUTE2 2RM19, 2RM3, 2RM5, 2RM6

nbreCoups= 251
numeroVhSujet= 0
autoriserHyperDepSgi= oui
lancerMdv= non
sautAleatoire= Oui

INSTRUCTION_VARIABLES()

	DECLARE(dist,ENTIER)
	AFFECTE(dist,0) ; variable permettant de fixer la vitesse de propulsion des flots avant dépassement ici 130 km/h
FIN

;---------- Création lièvre (berlingo,-1000) devant le sujet (-1) -------------------

INSTRUCTION(0,0,FAUX,FAUX,VRAI,VRAI)
	SI Immediate()
		FAIRE
			ChangerEnvMessage(5,"Autoroute_2",50,50,255,0,0)
			CreerMobile ("C","M1",-1000,"Asservi",00,VRAI,0.0,"N3",FAUX,28,FAUX,25660,0.0)
			; -1000 est le lièvre (berlingo2) qui suit la trajectoire 2besafe.v00
			ChangerIndicateur(-1000,VRAI,"clignotant_droit",1)
		JSQA OU(Exterieure("B31"),Exterieure("F1"))
		ALLER ESSAI(1)
	FINSI
FIN


;-----------------------------------------------------------------------------------------------------------------------
;-----------------------SUIVI DU VEHICULE LIEVRE: berlingo (-1000) ------------------------------------------------------
;-----------------------pour entrée sur autoroute: départ N3,puis B4 et enfin entrée sur autoroute A1------------------
;-----------------------------------------------------------------------------------------------------------------------


INSTRUCTION(10,1,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerEnvMessage(5,"Contact_SVP_",50,50,255,0,0)
		JSQA Attente(2)
		ALLER ESSAI(2)
	FINSI
FIN

;------------Création du trafic: MercedesTaxi (-10) dans l'autre sens sur la N3-----------


INSTRUCTION(20,2,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerEnvMessage(5,"0*1*3*4*5*6",50,50,255,0,0)
			CreerMobile ("V3","M4",-10,"Asservi",01,VRAI,194,"N3",FAUX,-18,FAUX,41394,180)
			; MercedesTaxi(-10) roule en sens inverse sur la N3 à 70 km/h (194)
			; MercedesTaxi (-10) créé avec la trajectoire 2besafe.v01 sur la N3 à contresens,ils sont espacés de 30m.
			; Modif dans lepsi0.v01 Pk=4139,4+30=4169.4,4 (41694)
		JSQA Immediate()
		ALLER ESSAI(3)
	FINSI
FIN

INSTRUCTION(30,3,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			NeRienFaire()	
		JSQA Immediate()
		ALLER ESSAI(4)
	FINSI
FIN

;--------------------------------2RM19 (-106) traverse intersection N5N3 devant le sujet-----------------------------
;-----------------------------------Détection latérale droit de la 2RM19 (-106) sur N5 ----------------------------- 

INSTRUCTION(40,4,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerEnvMessage(5,"2RM0_N5",50,50,255,0,0)
			CreerMobile("M1","M1",-106,"Asservi",19,FAUX,-1,0,"N5",FAUX,-18,FAUX,14086,0.0)
			; Création du 2RM19 (-106) qui suit la trajectoire 2besafe.v19
			; 2RM19(-106) créée à 80 m aprés l'inter N5N3: Pk=1328.6m+80=1408.6 (14086dm)
			; Création du Vp à 100 m de N3N5: 2457.2-100=2357.2 (2357m) dans train1.vp
			RegulerVitesseRelative(-106,-1,VRAI,0.0,0,-0.01,VRAI,0)
 			; 2RM19(-106) roule avec une vitesse relative identique à celle du sujet jusqu'à ce que le sujet entre dans l'intersection
			ChangerIndicateur(-1000,VRAI,"clignotant_droit",0)
		JSQA Position(-1,"mobile","N3",24172,VRAI,VRAI,">")	; le sujet est à 40m avant N3XN5
		; Pk N3XN5=2457.2-40=2417.2m (24172)
		ALLER ESSAI(5)
	FINSI
FIN


INSTRUCTION(50,5,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-1000,FAUX,"clignotant_gauche",1)
			RegulerAxiale(-1000,18,0,FAUX,300)
			; lièvre(-1000) se déporte vers le centre de la voie
			RegulerVitesseFixe(-1000,194,0,FAUX,400)	
			;lièvre (-1000) roule à 70 km/h (194)
			RegulerVitesseFixe(-106,112,0,FAUX,100)
 			; 2RM19 (-106)roule à 40 km/h (112)
		JSQA Position(-1000,"mobile","N3",26100,VRAI,VRAI,">")	
		; lièvre a dépassé N3XN5 de 152.8m
		; Pk N3XN5=2457.2+152.8=2610.0(26100)
		ALLER COURANT
	FINSI
FIN

INSTRUCTION(51,5,FAUX,FAUX,VRAI,VRAI)
	SI Enchaine(50)
		FAIRE
 			NeRienFaire()
		JSQA Position(-1000,"mobile","N3",41570,VRAI,VRAI,">")	
		; lièvre a dépassé N3XB4 de 14.4m
		; Pk N3XB4=4171.4-14.4m=4157.0(41570)
		ALLER ESSAI(6)
	FINSI
FIN

INSTRUCTION(60,6,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerAxiale(-1000,32,0,VRAI,2)		
			; Déport latérale du lièvre afin d'éviter une trajectoie angulaire	
			RegulerVitesseFixe(-1000,150,0,VRAI,5)	
			; Lièvre (-1000) ralentit à 54 km/h (150) en 5s
		JSQA Attente(5)
		ALLER ESSAI(7)
	FINSI
FIN

INSTRUCTION(70,7,FAUX,FAUX,FAUX,VRAI)
	SI NumeroEssai()
		FAIRE
		    SupprimerParNumero("mobile",-106)	; suppression 2RM0 (-106) sur N5
			RegulerVitesseFixe(-1000,75,0,FAUX,10)	
			; Lièvre roule à 27 km/h (75)
		JSQA Position(-1000,"mobile","B4",6000,VRAI,VRAI,">")	; lièvre est à 69.9m de l'A1
		; Pk B4XA1=669.9m-69.9=600(6000)
		ALLER ESSAI(8)
	FINSI
FIN

INSTRUCTION(80,8,FAUX,FAUX,FAUX,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-1000,FAUX,"clignotant_gauche",1)
			RegulerVitesseFixe(-1000,194,0,FAUX,400)	;	lièvre(-1000) roule à 70 km/h (194)
			SupprimerParNumero("mobile",-10)			;	suppression de la MercedesTaxi (-10) sur la N3
		JSQA Position(-1000,"mobile","A1",320020,VRAI,VRAI,">")
		ALLER ESSAI(10)
	FINSI
FIN


;---------------------------------------------------------------------------------
;-------------creation flot 1: lièvre à 70 km/h (194),flot 1 à 100 km/h (278)----
;-------------------longueur du flot1 = 3276 dm ----------------------------------
;---------------Remontée de la 2RM3 (-105) à 120 km/h (333)-----------------------
;---------------------------------------------------------------------------------
;---------------------------------------------------------------------------------
;----------creation flot 2: lièvre à 70 km/h (194),flot 2 à 80 km/h (222)--------
;-------------------longueur de flot = 2778 dm -----------------------------------
;---------------------------------------------------------------------------------


INSTRUCTION(100,10,FAUX,FAUX,FAUX,VRAI)
	SI NumeroEssai()
		FAIRE
			CreerMobile ("V1","M3",-10,"Asservi",-1,VRAI,361,"A1",FAUX,67,VRAI,-6000,-1000,0.0)
			; véhicule de tête Modus(-10) du flot1 créé sur A1 à 600m (6000) derrière le lièvre (-1000)
			CreerMobile("V2","M4",-11,"Asservi",-1,VRAI,361,"A1",FAUX,67,VRAI,-11250,-1000,0.0)
			; véhicule de tête C4Noire(-11) du flot2 créé sur A1 à 1125m (11250) derrière le lièvre (-1000)
		JSQA Attente(5)
		ALLER ESSAI(11)
	FINSI
FIN


INSTRUCTION(110,11,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			; I1=556 dm + (1/2*34.5) + (1/2*34.5)=590				
			CreerMobile("V1","M4",-222,"Asservi",-1,FAUX,-10,0.,"A1",FAUX,67,VRAI,-590,-10,0.0)
			; I3=666 dm + (1/2*40) + (1/2*43)=707
			CreerMobile("V3","M2",-12,"Asservi",-1,FAUX,-11,0.0 ,"A1",FAUX,67,VRAI,-707,-11,0.0)
		JSQA Immediate()
		ALLER ESSAI(12)
	FINSI
FIN

INSTRUCTION(120,12,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			; I3=834 dm + (1/2*34.5) + (1/2*20)=861
			CreerMobile("V3","M3",-3,"Asservi",-1,FAUX,-10,0.0,"A1",FAUX,67,VRAI,-861,-222,0.0)
			; I1=444 dm + (1/2*43) + (1/2*34.5)=483
			CreerMobile("V1","M4",-13,"Asservi",-1,FAUX,-11,0.0 ,"A1",FAUX,67,VRAI,-483,-12,0.0)
		JSQA Immediate()
		ALLER ESSAI(13)
	FINSI
FIN

INSTRUCTION(130,13,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			; I4=973 dm + (1/2*43) + (1/2*40)=1014			
			CreerMobile("V2","M3",-4,"Asservi",-1,FAUX,-10,0.0 ,"A1",FAUX,67,VRAI,-1014,-3,0.0)
			; I2=555 dm + (1/2*34.5) + (1/2*43)=594
			CreerMobile("V3","M4",-14,"Asservi",-1,FAUX,-11,0.0 ,"A1",FAUX,67,VRAI,-594,-13,0.0)
		JSQA Immediate()
		ALLER ESSAI(14)
	FINSI
FIN

INSTRUCTION(140,14,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			; I2=695 dm + (1/2*40) + (1/2*169)=799			
			CreerMobile("PL3","M2",-5,"Asservi",-1,FAUX,-10,0.0 ,"A1",FAUX,67,VRAI,-799,-4,0.0)
			; I4=888 dm + (1/2*43) + (1/2*169)=994			
			CreerMobile("C","M4",-15,"Asservi",-1,FAUX,-11,0.0 ,"A1",FAUX,67,VRAI,-994,-14,0.0)
		JSQA Immediate()
		ALLER ESSAI(15)
	FINSI
FIN

INSTRUCTION(150,15,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
            NeRienFaire()
		JSQA Immediate()
		ALLER ESSAI(16)
	FINSI
FIN


INSTRUCTION(160,16,FAUX,FAUX,FAUX,VRAI)
	SI NumeroEssai()
		FAIRE
			;Création de la 2RM3 (-105) qui remonte le flot1
			CreerMobile("M1","M1",-105,"Asservi",-1,FAUX,-10,0.0 ,"A1",FAUX,67,VRAI,-2800,-10,0.0)		
			ChangerIndicateur(-105,VRAI,"phares",1)
			ChangerEnvMessage(5,"2RM3_A1_flot1",50,50,255,0,0)		
		JSQA Immediate()
		ALLER ESSAI(17)
	FINSI
FIN
;---------------------------------------------------------------------------

INSTRUCTION(170,17,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,194,0,FAUX,2)
			HyperDeplacerMobile(-10,"A1",VRAI,80000,32767,32767.,32767.,FAUX,FAUX)
			HyperDeplacerMobile(-222,"A1",VRAI,80000,32767,32767.,32767.,FAUX,FAUX)
			HyperDeplacerMobile(-3,"A1",VRAI,80000,32767,32767.,32767.,FAUX,FAUX)
			HyperDeplacerMobile(-4,"A1",VRAI,80000,32767,32767.,32767.,FAUX,FAUX)
			HyperDeplacerMobile(-5,"A1",VRAI,80000,32767,32767.,32767.,FAUX,FAUX)
			HyperDeplacerMobile(-11,"A1",VRAI,80000,32767,32767.,32767.,FAUX,FAUX)
			HyperDeplacerMobile(-12,"A1",VRAI,80000,32767,32767.,32767.,FAUX,FAUX)
			HyperDeplacerMobile(-13,"A1",VRAI,80000,32767,32767.,32767.,FAUX,FAUX)
			HyperDeplacerMobile(-14,"A1",VRAI,80000,32767,32767.,32767.,FAUX,FAUX)
			HyperDeplacerMobile(-15,"A1",VRAI,80000,32767,32767.,32767.,FAUX,FAUX)
			HyperDeplacerMobile(-105,"A1",VRAI,80000,32767,32767.,32767.,FAUX,FAUX)
		JSQA Interdistance(-10,"mobile",-1000,"mobile",2170,"<")
		;les deux flots (flot1 et flot2) ont été avancé sur la A1 de 800m(8000)
		ALLER ESSAI(18)
	FINSI
FIN


INSTRUCTION(180,18,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE		
			RegulerVitesseFixe(-10,278,0,FAUX,1)
			RegulerVitesseFixe(-222,278,0,FAUX,1)
			RegulerVitesseFixe(-3,278,0,FAUX,1)
			RegulerVitesseFixe(-4,278,0,FAUX,1)
			RegulerVitesseFixe(-5,278,0,FAUX,1)
			RegulerVitesseFixe(-11,278,0,FAUX,1)
			RegulerVitesseFixe(-12,278,0,FAUX,1)
			RegulerVitesseFixe(-13,278,0,FAUX,1)
			RegulerVitesseFixe(-14,278,0,FAUX,1)
			RegulerVitesseFixe(-15,278,0,FAUX,1)
			RegulerVitesseFixe(-105,333,0,FAUX,1)	;2RM3(-105) remonte le flot à +20 km/h (33.3m/s=120 km/h)
		JSQA Interdistance(-10,"mobile",-1000,"mobile",1500,"<")
		ALLER ESSAI(19)
	FINSI
FIN


INSTRUCTION(190,19,FAUX,FAUX,VRAI,VRAI)	;le flot1 va dans la voie de gauche avant dépassement du lièvre
	SI NumeroEssai()
		FAIRE
			RegulerAxiale(-10,30,0,VRAI,2)
			RegulerAxiale(-222,30,0,VRAI,2)
			RegulerAxiale(-3,30,0,VRAI,2)
			ChangerEnvMessage(5,"2RM3_A1_flot1",50,50,255,0,0)
			RegulerAxiale(-4,30,0,VRAI,2)
			RegulerAxiale(-5,30,0,VRAI,2)
			RegulerAxiale(-105,43,0,VRAI,2)	;2RM3 (-105) dans la voie de gauche
		JSQA Interdistance(-10,"mobile",-1000,"mobile",1200,"<")	; déboitement flot1 avant dépassement -100
		ALLER ESSAI(20)
	FINSI
FIN


;--------------------------------------------------------------------------------------------
;-----------------------flot1: véhicule lievre double une smart (-100)-----------------------
;--------------------------------------------------------------------------------------------


INSTRUCTION(200,20,FAUX,FAUX,VRAI,FAUX)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,194,0,FAUX,2)
		JSQA Attente(3)
		ALLER COURANT
	FINSI
FIN

INSTRUCTION(201,20,FAUX,FAUX,FAUX,VRAI)
	SI Enchaine(200)
		FAIRE
			CreerMobile("V1","M2",-100,"Asservi",00,FAUX,-1000,0, "A1",FAUX,65,VRAI,500,-1000,0)
			; Smart (-100) créée à la vitesse du véhicule lièvre et suit la trajectoire 2besafe.v00
			JSQA Attente(3)
		ALLER ESSAI(21)
	FINSI
FIN


INSTRUCTION(210,21,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-1000,FAUX,"clignotant_gauche",1)
			RegulerVitesseFixe(-1000,278,0,FAUX,2) 
			;lièvre (-1000) accélère
			RegulerAxiale(-1000,35,0,VRAI,5)
			;lièvre (-1000) se déporte dans la voie de gauche    
		JSQA Interdistance(-1000,"mobile",-100,"mobile",-970,"<")
		ALLER ESSAI(22)
	FINSI
FIN

INSTRUCTION(220,22,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-1000,FAUX,"clignotant_droit",1)
			RegulerVitesseFixe(-1000,194,0,FAUX,2)
			RegulerAxiale(-1000,65,0,VRAI,5)    
			; lièvre(-1000) retourne dans la voie de droite
		JSQA Attente(5)
		ALLER essai(23)
	FINSI
FIN

;------------------Rabattement des véhicules du flot1 et de la 2RM3(-3) aprés dépassement du lièvre --------------------------

INSTRUCTION(230,23,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
            NeRienFaire()
		JSQA Interdistance(-10,"mobile",-1000,"mobile",-100,"<")
		ALLER COURANT
	FINSI
FIN

INSTRUCTION(231,23,FAUX,FAUX,VRAI,VRAI)
	SI Enchaine(230)
		FAIRE
			RegulerAxiale(-10,65,0,VRAI,2)	
			; Rabattement 1er véhicule du flot1 (-10) dans voie de droite
			ChangerIndicateur(-10,FAUX,"clignotant_droit",1)	
		JSQA Interdistance(-222,"mobile",-1000,"mobile",-100,"<")
		ALLER COURANT
	FINSI
FIN

INSTRUCTION(232,23,FAUX,FAUX,VRAI,VRAI)
	SI Enchaine(231)
		FAIRE
			RegulerAxiale(-222,65,0,VRAI,2)	
			; Rabattement 2ème véhicule du flot1 (-222) dans voie de droite
			ChangerIndicateur(-222,FAUX,"clignotant_droit",1)				
		JSQA Interdistance(-3,"mobile",-1000,"mobile",-100,"<")
		ALLER COURANT
	FINSI
FIN

INSTRUCTION(234,23,FAUX,FAUX,VRAI,VRAI)
	SI Enchaine(232)
		FAIRE
			RegulerAxiale(-3,65,0,VRAI,2)	
			; Rabattement 3ème véhicule (-3) du flot1 dans voie de droite
			ChangerIndicateur(-3,FAUX,"clignotant_droit",1)	
		JSQA Interdistance(-4,"mobile",-1000,"mobile",-100,"<")
		ALLER COURANT
	FINSI
FIN

INSTRUCTION(235,23,FAUX,FAUX,VRAI,VRAI)
	SI Enchaine(234)
		FAIRE
			RegulerAxiale(-4,65,0,VRAI,2)	
			; Rabattement 4ème véhicule du flot1 (-4) dans voie de droite
			RegulerAxiale(-105,65,0,VRAI,2)	
			; Rabattement de la 2RM3 (-105) dans voie de droite
			ChangerIndicateur(-4,FAUX,"clignotant_droit",1)				
		JSQA Interdistance(-5,"mobile",-1000,"mobile",-100,"<")
		ALLER ESSAI(24)
	FINSI
FIN


;-------------------Ralentissement et parking dans BAU de la smart (-100)----------------

INSTRUCTION(240,24,FAUX,FAUX,FAUX,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerAxiale(-5,65,0,VRAI,2)
			; Rabattement 5ème véhicule du flot1 (-5) dans voie de droite
			ChangerIndicateur(-5,VRAI,"clignotant_droit",1)
			RegulerVitesseFixe(-100,30,0,FAUX,5)
			; le véhicule -100 ralentit et se rabat dans la BAU
			RegulerAxiale(-100,100,0,VRAI,4)
			RegulerAxiale(-11,35,0,VRAI,2)
			; déport dans la voie de gauche du 1er véhicule (-11) du flot 2
			RegulerVitesseFixe(-11,222,0,FAUX,1)
			SupprimerParNumero("mobile",-105)	
			; Suppression de la 2RM3 (-105) du flot1			
		JSQA Attente(5)
		ALLER ESSAI(25)
	FINSI
FIN

;-------------------PL blanc (-103) arrêté avec warning dans la BAU-----------------
;-------------------2RM5 (-105) arrêté sur la BAU à 496.5m derrière le NALCO-----------------------

INSTRUCTION(250,25,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			CreerMobile ("PL3","M1",-103,"Asservi",-1,VRAI,0.0,"A1",FAUX,92,FAUX,350000,0.0)
			; Création du PL blanc (-103) stationnaire dans la BAU
			CreerMobile("M1","M1",-105,"Asservi",-1,VRAI,0.0 ,"A1",FAUX,97,VRAI,-4965,-103,0)		
			; Création de la 2RM5 (-105) stationnaire dans la BAU,trajectoire -1, elle est à 496.5m(4965) derrière le PL
			ChangerEnvMessage(5,"2RM5_A1",50,50,255,0,0)
			SupprimerParNumero("mobile",-10)	
			; Suppression du 1er véhicule (-10) du flot1		
		JSQA Immediate()
		ALLER ESSAI(26)
	FINSI
FIN


;------------------------------Déport flot2 dans voie de gauche sur A1-----------------------------


INSTRUCTION(260,26,FAUX,FAUX,VRAI,VRAI)
	SI OU(NumeroEssai(),Position(-1,"mobile","A1",342488,VRAI,VRAI,">"))
		FAIRE
			RegulerAxiale(-106,43,0,VRAI,2)
			RegulerVitesseFixe(-106,278,0,FAUX,1)
			ChangerIndicateur(-105,VRAI,"warning",1)
			; allumage warning 2RM5 stationnaire devant PL blanc			
			; 2RM4 (-106) remonte le flot à +20 km/h (27.8 m/s=100 km/h)
			RegulerAxiale(-12,35,0,VRAI,2)
			; Déport dans la voie de gauche des véhicules du flot 2 (-12,-13,-14 et-15) du flot 2
			RegulerVitesseFixe(-12,222,0,FAUX,1)
			RegulerAxiale(-13,30,0,VRAI,2)
			RegulerVitesseFixe(-13,222,0,FAUX,1)
			RegulerAxiale(-14,30,0,VRAI,2)
			RegulerVitesseFixe(-14,222,0,FAUX,1)
			RegulerAxiale(-15,30,0,VRAI,2)	 
			RegulerVitesseFixe(-15,222,0,FAUX,1)
		JSQA Interdistance(-11,"mobile",-1000,"mobile",1000,"<")
		ALLER ESSAI(27)
	FINSI
FIN
 

;--------------------------------------------------------------------------------------------
;-----------------------flot2: véhicule lievre double une Modus (-25)-----------------------
;--------------------------------------------------------------------------------------------


INSTRUCTION(270,27,FAUX,FAUX,VRAI,FAUX)
	SI NumeroEssai()
		FAIRE
			SupprimerParNumero("mobile",-100)	
			; Suppression de la Smart (-100) garée sur la BAU
		JSQA Attente(3)
		ALLER ESSAI(28)
	FINSI
FIN

INSTRUCTION(280,28,FAUX,FAUX,FAUX,VRAI)
	SI NumeroEssai()
		FAIRE
			CreerMobile("V1","M3",-25,"Asservi",00,FAUX,-1000,0, "A1",FAUX,65,VRAI,500,-1000,0)
			; Modus (-25) créée à la vitesse du véhicule lièvre (-1000) et suit la trajectoire 2besafe.v00
		JSQA Attente(3)
		ALLER ESSAI(29)
	FINSI
FIN

INSTRUCTION(290,29,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-1000,FAUX,"clignotant_gauche",1)
			RegulerVitesseFixe(-1000,222,0,FAUX,2)
			RegulerAxiale(-1000,35,0,VRAI,5)	    
			; Lièvre (-1000) accélère pour aller dans la voie de gauche
		JSQA Interdistance(-1000,"mobile",-25,"mobile",-970,"<")
		ALLER ESSAI(30)
	FINSI
FIN

INSTRUCTION(300,30,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-1000,FAUX,"clignotant_droit",1)
			RegulerVitesseFixe(-1000,194,0,FAUX,2)
			RegulerAxiale(-1000,65,0,VRAI,5)   
			; Lièvre (-1000) retourne dans la voie de droite
		JSQA Attente(5)
		ALLER ESSAI(31)
	FINSI
FIN

;------------------Rabattement du flot2 dans la voie de droite et de la 2RM4(-106) qui a remonté le flot2 aprés dépassement du lièvre--------------------------

INSTRUCTION(310,31,FAUX,FAUX,VRAI,VRAI)
	SI ET(NumeroEssai(),Position(-1,"mobile","A1",367748,VRAI,VRAI,"<"))
		FAIRE
			ChangerIndicateur(-105,VRAI,"warning",1)	; Allumage des warning de la 2RM5(-105) stationnaire sur BAU A1
    ;       NeRienFaire()
		JSQA Interdistance(-11,"mobile",-1000,"mobile",-100,"<")
		ALLER COURANT
	FINSI
FIN

INSTRUCTION(311,31,FAUX,FAUX,VRAI,VRAI)
	SI ET(Enchaine(310),Position(-1,"mobile","A1",367748,VRAI,VRAI,"<"))
		FAIRE
			RegulerAxiale(-11,65,0,VRAI,2)	
			; Rabattement 1er véhicule du flot2 (-11) dans voie de droite
			ChangerIndicateur(-11,FAUX,"clignotant_droit",1)	
		JSQA Interdistance(-12,"mobile",-1000,"mobile",-100,"<")
		ALLER COURANT
	FINSI
FIN

INSTRUCTION(312,31,FAUX,FAUX,VRAI,VRAI)
	SI ET(Enchaine(311),Position(-1,"mobile","A1",367748,VRAI,VRAI,"<"))
		FAIRE	
			RegulerAxiale(-12,65,0,VRAI,2)	
			; Rabattement 2ème véhicule du flot2 (-12) dans voie de droite
			ChangerIndicateur(-12,FAUX,"clignotant_droit",1)				
		JSQA Interdistance(-13,"mobile",-1000,"mobile",-100,"<")
		ALLER COURANT
	FINSI
FIN

INSTRUCTION(313,31,FAUX,FAUX,VRAI,VRAI)
	SI ET(Enchaine(312),Position(-1,"mobile","A1",367748,VRAI,VRAI,"<"))
		FAIRE
			RegulerAxiale(-13,65,0,VRAI,2)	
			; Rabattement 3ème véhicule du flot2 (-13) dans voie de droite
			ChangerIndicateur(-13,FAUX,"clignotant_droit",1)				
		JSQA Interdistance(-14,"mobile",-1000,"mobile",-100,"<")
		ALLER COURANT
	FINSI
FIN

INSTRUCTION(314,31,FAUX,FAUX,VRAI,VRAI)
	SI ET(Enchaine(313),Position(-1,"mobile","A1",367748,VRAI,VRAI,"<"))
		FAIRE
			RegulerAxiale(-14,65,0,VRAI,2)	
			; Rabattement 4ème véhicule du flot2 (-14) dans voie de droite
			ChangerIndicateur(-14,FAUX,"clignotant_droit",1)				
		JSQA Interdistance(-15,"mobile",-1000,"mobile",-50,"<")
		ALLER ESSAI(32)
	FINSI
FIN

; Un piéton (pK=2712.0m) se trouve de l'autre côté de la glissière après le télphone de secours (pK=2617.3m)

;-------------------Ralentissement et parking dans BAU de la Modus (-100) + rattrapage du sujet par la Chrysler (-10) dans voie de droite ----------------

INSTRUCTION(320,32,FAUX,FAUX,VRAI,VRAI)
	SI OU(NumeroEssai(),ET(Position(-25,"mobile","A1",26073,VRAI,VRAI,">"),Position(-25,"mobile","A1",26033,VRAI,VRAI,"<"))) 	
	; si le flot2 ne s'est pas rabattu quand la modus derrière le sujet est à 10m avant le téléphone de secours: 2617.3m-10=2607.3 (26073)
		FAIRE
			; Rabattement 5ème véhicule du flot2 (-15) dans voie de droite	
			RegulerAxiale(-15,65,0,VRAI,2)	
			; Modus (-25) ralentit et se gare dans la BAU			
			ChangerIndicateur(-15,VRAI,"clignotant_droit",1)
			RegulerVitesseFixe(-25,30,0,FAUX,5)	 
			RegulerAxiale(-25,100,0,VRAI,4)
			SupprimerParNumero("mobile",-105)	
			; Suppression de la 2RM5 (-105) stationnaire sur la BAU
		JSQA Attente(5)
		ALLER ESSAI(33)
	FINSI
FIN

;----------------------------------------Chrysler (-10) créée à 200m derrière la Modus (-25) -----------------------------------------------

INSTRUCTION(330,33,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			CreerMobile ("C","M2",-10,"Asservi",04,VRAI,333,"A1",FAUX,65,FAUX,13845,0)
			; Création d'une Chrysler (-10) à 100m derrière la Modus(-25) qui se trouve au Pk=1584,5m. Pk de la Chrysler= 1584,5 - 200=1384,5m (13845dm)  
			; Chrysler suit la trajectoire 2besafe.v04 et roule à 120 km/h (333)
		JSQA Interdistance(-10,"mobile",-1,"mobile",500,"<")	; Attente que Chrysler (-10) se retrouve à 50 m derrière le sujet (-1)
		ALLER ESSAI(34)
	FINSI
FIN

; Un piéton (pK=27120) se trouve de l'autre côté de la glissière après le télphone de secours (pK=26173)

INSTRUCTION(340,34,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			CreerMobile ("V1","M4",-104,"Asservi",-1,VRAI,0.0,"A1",FAUX,92,FAUX,30233,0.0)
			ChangerIndicateur(-104,VRAI,"warning",1)
		 	; Création d'une GolfTex (-104) stationnaire dans la BAU
			RegulerVitesseFixe(-10,250,0,FAUX,5)
			; Chrysler (-10) ralentit pour atteindre la vitesse du lièvre (-1000)
		JSQA Interdistance(-10,"mobile",-1,"mobile",150,"<")	
		; Attente que Chrysler (-10) se retrouve à 15 m derrière le sujet (-1)
		ALLER ESSAI(35)
	FINSI
FIN

;----------------------------Suivi du sujet par la Chrysler et création de la 2RM6 (-105) ----------------------------
;--------Détection sur les rétros de la 2RM6 (-105) qui dépasse le sujet (-1) par la droite sur la bretelle B7----

INSTRUCTION(350,35,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
		 	; Creation d'un PL Cam (-101) à 300m(3000) devant le sujet et roulant dans l'autre sens sur l'autoroute
			CreerMobile ("PL3","M1",-101,"Asservi",-1,VRAI,197,"A1",FAUX,-65,VRAI,3000,-1,180)
			RegulerVitesseRelative(-10,-1,FAUX,-200,0,0,VRAI,3)    ; la Chrysler (-10) roule à la même vitesse que le sujet (-1) 
			; Chrysler (-10) se trouve à 20m (200) derrière le sujet (-1)
		JSQA Position(-1000,"mobile","A1",41917,VRAI,VRAI,">")	
		; lièvre (-1000) est sur A1 à 40 m de la bretelle de sortie B7.
		; Pk A1XB7:4231.7,4231.7-40=4191.7 (41917)
		ALLER ESSAI(36)
	FINSI
FIN

INSTRUCTION(360,36,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-1000,VRAI,"clignotant_droit",1)
			CreerMobile("M1","M1",-105,"Asservi",06,FAUX,-1,0,"A1",FAUX,65,VRAI,-80,-10,0) 
			ChangerEnvMessage(5,"2RM6_A1",50,50,255,0,0)
			; Création du 2RM6 (-105) sur A1 8m derrière la Chrysler (-10).
			; 2RM6 (-105) suit la trajectoire 2besafe.v06
			; 2RM6(-105) roule à la même vitesse que le sujet (-1)
		JSQA Attente(3)
		ALLER ESSAI(37)
	FINSI
FIN

;-------------------Sortie de l'autoroute + faufilement 2RM6 (-105) par la BAU sur la bretelle B7 + Suppression des flot1 et flot2---------------

INSTRUCTION(370,37,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerAxiale(-105,90,0,VRAI,2)	
			; Faufilement du 2RM6 (-105) dans la BAU
			ChangerIndicateur(-105,VRAI,"phares",1)
		JSQA Attente(2)
		ALLER ESSAI(38)
	FINSI
FIN	

INSTRUCTION(380,38,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-105,250,0,FAUX,5)    
			; 2RM6 (-105) acccélère jusqu'à 90 km/h (250) pour dégager par la droite sur la B7	
			RegulerVitesseFixe(-10,150,0,FAUX,10)
			; Chrysler(-10) ralentit à 54 km/h (150)
		JSQA Attente(4)
		ALLER ESSAI(39)
	FINSI
FIN	

INSTRUCTION(390,39,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE

			RegulerVitesseFixe(-1000,150,0,FAUX,10)
			; Lièvre(-1000) roule à 54 km/h (150)
			RegulerVitesseFixe(-105,198,0,FAUX,5)    
			; 2RM6 (-105) ralentit jusqu'à 70 km/h (198) pour prendre la B7	à côté du sujet et du lièvre
		JSQA Interdistance(-1000,"mobile",-105,"mobile",30,">")
		; la 2RM6(-105) dépasse le lièvre (-1000) de 3m (30)
		ALLER ESSAI(40)
	FINSI
FIN

INSTRUCTION(400,40,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-1000,VRAI,"clignotant_droit",0)	
		JSQA Position(-1,"mobile","B7",8972,VRAI,VRAI,">")	
		; le sujet(-1) est à 10 m avant la fin de la bretelle de sortie B7,907.2-10=897.2(8972)			
		ALLER ESSAI(41)
	FINSI
FIN

INSTRUCTION(410,41,FAUX,FAUX,VRAI,VRAI)
	SI OU(NumeroEssai(),Position(-1,"mobile","N2",62943,VRAI,FAUX,">"))	
	; le sujet(-1) est sur N2 en sens indirect à 80 m après la jonction N2XB7: 6374.3m-80=6294.3(62943)
		FAIRE
			RegulerAxiale(-1000,-18,0,VRAI,5)	
			RegulerVitesseFixe(-1000,194,0,FAUX,400)	;	VL=70 km/h (194)
			SupprimerParNumero("mobile",-10)	;	Suppression de la Chrysler (-10)
			SupprimerParNumero("mobile",-222)
           	SupprimerParNumero("mobile",-3)
   		    SupprimerParNumero("mobile",-4)
   		    SupprimerParNumero("mobile",-5)
			SupprimerParNumero("mobile",-103)	; 	Suppression du PL Nalco (-103) stationnaire dans la BAU
			SupprimerParNumero("mobile",-104)	; 	Suppression de la GolfTex (-104) stationnaire dans la BAU
			SupprimerParNumero("mobile",-101)	; 	Suppression du PL Cam (-101) roulant sur l'autoroute de l'autre coté et dans l'autre sens
			SupprimerParNumero("mobile",-11)
			SupprimerParNumero("mobile",-12)
           	SupprimerParNumero("mobile",-13)
   		    SupprimerParNumero("mobile",-14)
   		    SupprimerParNumero("mobile",-15)
			SupprimerParNumero("mobile",-25)	; Supression modus (-25) arrétée sur BAU		
		JSQA Position(-1,"mobile","N2",62843,VRAI,FAUX,">")		
		; le sujet(-1) est sur N2 en sens indirect à 90 m après la jonction N2XB7: 6374.3m-90=6284.3(62843)
		ALLER ESSAI(42)
	FINSI
FIN

INSTRUCTION(420,42,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,0,0,FAUX,400)
			RegulerAxiale(-1000,-33,0,VRAI,5)
			ChangerIndicateur(-1000,VRAI,"warning",1)
			RegulerAxiale(-105,-18,0,VRAI,5) 
			; correction erreur axiale pour le 2RM6
		JSQA Position(-1,"mobile","N2",62243,VRAI,FAUX,">")	
		; le sujet (-1) est sur N2 en sens indirect à 150 m après la jonction N2XB7: 6374.3m-150=6224.3(62243)
		ALLER ESSAI(43)
	FINSI
FIN

INSTRUCTION(430,43,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,0,0,FAUX,100)
			RegulerVitesseFixe(-105,120,0,FAUX,5) ; ralentissement 2RM6
			RegulerAxiale(-105,-18,0,VRAI,5)
			; correction erreur axiale pour le 2RM6
		JSQA Position(-1,"mobile","N2",62124,VRAI,FAUX,">")	
		; jusqu'à ce que le sujet (-1) s'arrête sur la N2 derrière le lièvre
		ALLER ESSAI(250)
	FINSI
FIN

;--------------------------------------------------------------------
;-----------------------avertissement fin scenario -------------------
;---------------------------------------------------------------------


INSTRUCTION(2500,250,FAUX,FAUX,FAUX,FAUX)
	SI NumeroEssai()
		FAIRE
			SupprimerParNumero("mobile",-105)	; 	Suppression 2RM6 (-105) qui s'est faufilé par la droite sur B7
			ChangerEnvMessage(6,"TERMINE",50,50,255,0,0)
		JSQA Attente(5)
		ALLER COURANT
	FINSI
FIN
