V4.6

français

commentaireManip= Manip training1 2010 rédigé par Joceline !! TACHE DE DETECTION NATIO2

nbreCoups= 251
numeroVhSujet= 0
autoriserHyperDepSgi= oui
lancerMdv= non
sautAleatoire= Oui

INSTRUCTION_VARIABLES()
	DECLARE(dist,ENTIER)
	AFFECTE(dist,0)
FIN


INSTRUCTION(0,0,FAUX,FAUX,VRAI,VRAI)
	SI Immediate()
		FAIRE
			NeRienFaire()
		JSQA OU(Exterieure("B31"),Exterieure("F1"))
		ALLER ESSAI(1)
	FINSI
FIN

INSTRUCTION(10,1,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerEnvMessage(5,"Contact_SVP",50,50,255,0,0)
		JSQA Attente(2)
		ALLER ESSAI(2)
	FINSI
FIN

INSTRUCTION(20,2,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerEnvMessage(5,"NATIO2",50,50,255,0,0)
		JSQA Immediate()
		ALLER ESSAI(3)
	FINSI
FIN

;---------------------------------------------------------------------------------------------------------------------------------------------------------
;--2RM12 détection frontale sur N2, 2RM21 dépasse fourgon sur la voie opposée au sujet sur N2, 2RM14 dépassement droite sur N3 ---------------------------
;-- 2RM15 dépassement sujet sur N5, 2RM2 détection latérale droite sur B1, 2RM2 stationaire sur B1, 2RM16 détection latérale droite sur rond-point d6 ----
;------------------------------Redémarrage sur N10 dans le sens indirect à 5m après l'intersection N10XN2-------------------------------------------------

;	Pk N10XN2=2619.9m+20=2639.9(2639m),le sujet (-1) est à 20m avant N10XN2 dans 2besafe.vp

INSTRUCTION(30,3,FAUX,FAUX,VRAI,VRAI)
	SI Immediate()
		FAIRE
			ChangerEnvMessage(5,"12*21*14*15*2*2*16",50,50,255,0,0)
		JSQA Position(-1,"mobile","N10",26599,VRAI,FAUX,">")
		; Pk N10XN2=2619.9m+40=2659.9(26599),le sujet (-1) est à 40m avant N10XN2
		ALLER ESSAI(79)
	FINSI
FIN


;-------------------------------------------------- Flot4: Trafic sur la N2-----------------------------------------------------
;------------------------CitroenC4(-10),Smart (-222),RAV4Tex (-3),C4Noire(-4),Chrysler(-5)-------------------------------
;--sens de circulation:   1er véhicule----- 2ème véhi--3eme véhi------4eme véhi------5eme véhi ---------------------------------
;---------------------Détection frontale de la 2RM12 (-106) alors que le sujet est derrière le flot4----------

INSTRUCTION(790,79,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			CreerMobile ("V2","M1",-10,"Asservi",02,VRAI,194,"N2",FAUX,-18,FAUX,52821,180)
			; Création CitroenC4 (-10) sur la N2 roulant en sens indirect à 70 km/h (194)
			; trajectoire 2besafe.v02,CitroenC4 à 60m de N2XN10=5182.1+100m=5282.1m (52821)
			CreerMobile ("V1","M2",-222,"Asservi",02,VRAI,194,"N2",FAUX,-18,VRAI,600,-10,180)
			; Création Smart (-222) roulant en sens indirect sur la N2 à 70 km/h (194).Smart (-222) est à 60 m derrière la CitroenC4(-10).
			; Smart (-222) suit la trajectoire 2besafe.v02 sur la N2
			CreerMobile ("V1","M1",-3,"Asservi",02,VRAI,194,"N2",FAUX,-18,VRAI,800,-222,180)
			; Création RAV4Tex (-3) roulant en sens indirect sur la N2 à 70 km/h (194).RAV4Tex (-3) est à 80 m derrière la Smart (-222).
			; RAV4Tex (-3) suit la trajectoire 2besafe.v02 sur la N2
			CreerMobile ("V2","M4",-4,"Asservi",02,VRAI,194,"N2",FAUX,-18,VRAI,1500,-3,180)
			; Création C4Noire(-4) roulant en sens indirect sur la N2 à 70 km/h (194). C4Noire (-4) est à 150 m derrière la RAV4Tex(-4).
			; C4Noire (-4) suit la trajectoire 2besafe.v02 sur la N2.
			CreerMobile ("V3","M1",-5,"Asservi",02,VRAI,194,"N2",FAUX,-18,VRAI,1500,-4,180)
			; Création AudiTT (-5) roulant en sens indirect sur la N2 à 70 km/h (194). AudiTT(-5) est à 150 m derrière la C4Noire(-4).
			; AudiTT (-5) suit la trajectoire 2besafe.v02 sur la N2.				
	 	JSQA Immediate()
		ALLER ESSAI(80)
	FINSI
FIN



;------Création de la 2RM21(-25) sur N2 derrière le fourgon (-102) qui déboitera en frontal au moment où le sujet arrivera sur la voie d'en face------------- 
;--------------------------------------------Creation du ballon (-1000) ----------------------------------

INSTRUCTION(800,80,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			CreerMobile ("PL3","M3",-104,"Asservi",-1,VRAI,0.0,"N2",FAUX,-30,FAUX,30990,180)
			; Création du BusTex (-104) stationnaire sur le bord de la N2 en sens indirect
			; Bustext (-104) est à 500m après N2XN6: 3489.5m-390.5=3099.0 (30990)
			CreerMobile ("PL3","M3",-103,"Asservi",-1,VRAI,0.0,"N2",FAUX,-30,FAUX,14791,180)
			; Création du BusTex (-103) stationnaire sur le bord de la N2 en sens indirect
			; Bustext (-103) est à 500m avant N2XN3: 964.1m+515=1479.1 (14791)
			CreerMobile("C","M4",-102,"Asservi",17,VRAI,194,"N2",FAUX,18,FAUX,9841,0)
			; Création d'un Fourgon (-102) roulant à 70 km/h (194) en sens direct sur N2 (34)
			; Trajectoire 2BeSafe.v17,à 20m après N2XN3:964.1m+20=984.1(9841)
			CreerMobile("M1","M1",-25,"Asservi",17,VRAI,194,"N2",FAUX,18,FAUX,9741,0)
			; Création de la 2RM21(-25), 10 m derrrière le fourgon (-102) roulant à 70 km/h (194) dans la voie de gauche en sens direct sur N2(34)
			; Trajectoire 2BeSafe.v17, 974.1m-5=969.1(9691)
			CreerMobile("PL3","M4",-101,"Asservi",17,VRAI,194 ,"N2",FAUX,18,VRAI,1500,-102,0)
			; Création d'un camion de pompier (-101) roulant à 70 km/h (194) en sens direct sur N2 (34)
			; Trajectoire lepsis.v17,à 150m (1500) devant le Fourgon (-102)
			CreerMobile("V2","M3",-100,"Asservi",17,VRAI,194 ,"N2",FAUX,18,VRAI,800,-101,0)
			; Création de la ModusNoire(-100) roulant à 70 km/h (194) en sens direct sur N2 (34)
			; Trajectoire lepsis.v17,à 80m (800) devant le Pompier (-101)
		JSQA Position(-1,"mobile", "N2",51771, VRAI,FAUX,">")
		; le sujet (-1) a démarré et se trouve sur N2 (34) à 5m après N2XN10: 5182.1m -5=5177.1 (51771)
		ALLER ESSAI(81)
	FINSI
FIN

INSTRUCTION(810,81,FAUX,FAUX,VRAI,VRAI)
	SI OU(NumeroEssai(),Position(-1,"mobile","N2",44491,VRAI,FAUX,">"))
	; Sujet se trouve à 35 m avant N2XN7:4114.1+35=4449.1(44491)
		FAIRE
			NeRienFaire()	
		JSQA Position(-1,"mobile","N2",44441,VRAI,FAUX,">")
		; Sujet se trouve à 30 m avant N2XN7:4114.1+30=4444.1(44441)
		ALLER ESSAI(82)
	FINSI
FIN


INSTRUCTION(820,82,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			; Création de la 2RM12 (-106)
			CreerMobile ("M1","M1",-106,"Asservi",12,VRAI,138,"N7",FAUX,18,FAUX,39601,0)
			ChangerIndicateur(-106,VRAI,"phares",1)
			ChangerEnvMessage(5,"2RM12_N7",50,50,255,0,0)
			; Création de la 2RM12 (-106) en sens direct sur N7,10m avant N7XN2. Elle est dissimulée par une maison. 
			; 2RM12 se lance dans l'intersection à 50km/h(138)
			; Pk N7XN2=3970.1m,	3970.1-10=3960.1 (39601).
			; 2RM12 (-106) suit la trajectoire 2besafe.v12 sur la N7 puis tourne à droite sur la N2 et roule en sens direct.	
		JSQA Interdistance(-25,"mobile",-1,"mobile",5500,"<=")	; le 2RM21(-25) se trouve à 550m (5500) devant le sujet (-1)
		ALLER ESSAI(83)
	FINSI
FIN


INSTRUCTION(830,83,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerEnvMessage(5,"Enfants_N2",50,50,255,0,0)		; Création des enfants
			;CreerPanneau(-1001,83,"visuelle","aucun","aucune",150000,150000,0,0,100,1,1,"N2",FAUX,-30,VRAI,-200000,-1,180)
			; enfants sur la N2 créés à 200m(-200000mm) du sujet (-1) et sur le bas côté droit (-30)
			CreerPanneau(-1001,0,"visuelle","aucun","aucune",150000,150000,0,0,100,1,1,"N2",FAUX,-50,VRAI,-200000,-1,0)
			; petit garçon sur la N2 créés à 200m(-200000mm) du sujet (-1) et sur le bas côté droit (-50)
		JSQA Immediate()
		ALLER ESSAI(84)
	FINSI
FIN


INSTRUCTION(840,84,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			; Création du ballon
			ChangerEnvMessage(5,"Ballon_N2",50,50,255,0,0)
			;CreerMobile ("Tram1","M1",-1000,"Asservi",130,VRAI,20,"N2",FAUX,-20,VRAI,3500,-25,0)	
			; ballon (-1000) qui roule à 2m/s(20) sur la N2 en sens indirect sur le bord de la voie (-20), créé à 350 de la 2RM21(-25)
			CreerMobile ("Tram1","M1",-1000,"Asservi",130,VRAI,20,"N2",FAUX,-30,VRAI,-1950,-1,5)
			; ballon (-1000) qui roule à 2m/s(20) sur la N2 en sens indirect sur le bord de la voie (-30), créé à 195m(1950) du sujet(-1) et avec un cap de 5°
		JSQA Interdistance(-25,"mobile",-1,"mobile",2000,"<=")	; le 2RM21(-25) se trouve à 200m (2000) devant le sujet (-1)
		ALLER ESSAI(88)
	FINSI
FIN


INSTRUCTION(880,88,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-25,VRAI,"phares",1)
			; ChangerIndicateur(-25,FAUX,"clignotant_gauche",1)
			RegulerVitesseRelative(-25,-102,FAUX,-200,0,56,VRAI,2)
			;la 2RM21(-25) accélère en roulant à +20km/h (56) par rapport au fourgon(-102)
			RegulerAxiale(-25,0,0,VRAI,1)		; la 2RM21(-25) se déporte dans la voie de droite en 1s
			ChangerEnvMessage(5,"2RM12_N7",50,50,255,0,0)
		JSQA Interdistance(-25,"mobile",-102,"mobile",50,">")	; le 2RM21(-25) se trouve à 5m (50) devant le fourgon (-102)
		ALLER ESSAI(89)
	FINSI
FIN

;-----------Suivi du sujet (-1) par un Fourgon (-20) sur la N3(12)---------

INSTRUCTION(890,89,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerAxiale(-25,18,0,VRAI,3)	; la 2RM21(-25) se redéporte dans la voie de gauche en 3s devant le fourgon		
		JSQA Position(-1,"mobile","N3",800,VRAI,VRAI,">")
		; Sujet (-1) est sur la N3 80m après N3XN2: 0m+80=80(800)		
		ALLER ESSAI(90)
	FINSI
FIN

INSTRUCTION(900,90,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			CreerMobile ("C","M4",-20,"Asservi",14,VRAI,278,"N3",FAUX,18,FAUX,100,0)
			; Création du Fourgon (-20) en sens direct sur N3,10m après N3XN2. Pk N3XN2: 0+10= 10(100).
			; suit la trajectoire 2besafe.v14 et roule à 100km/h (278)
		JSQA Interdistance(-20,"mobile",-1,"mobile",250,"<")	
		; Attente que Jeep (-10) se retrouve à 25 m derrière le sujet (-1)
		ALLER ESSAI(91)
	FINSI
FIN


INSTRUCTION(910,91,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			SupprimerParNumero("mobile",-10)	; suppression de la CitroenC4 (-10) créée sur N2 en sens indirect
			SupprimerParNumero("mobile",-12)	; suppression de la AudiTT créée sur la N2 en sens indirect
			SupprimerParNumero("mobile",-5)		; suppression de la AudiTT (-5) créée sur N2 en sens indirect
			SupprimerParNumero("mobile",-4)		; suppression de la C4Noire (-4) créée sur N2 en sens indirect
			SupprimerParNumero("mobile",-3)		; suppression de la RAV4Tex (-3) créée sur N2 en sens indirect
			SupprimerParNumero("mobile",-222)	; suppression de la Smart (-222) créée sur N2 en sens indirect
			SupprimerParNumero("mobile",-104)	; suppression du BusTex (-104) stationaire créé sur N2 après N2XN6
			SupprimerParNumero("mobile",-103)	; suppression du BusTex (-103) stationaire créée sur N2 avant N2XN3		
			SupprimerParNumero("mobile",-106)	; suppression de la 2RM12 (-106) créée sur N2 en sens direct
			SupprimerParNumero("mobile",-102)	; suppression du Fourgon (-102) créé sur N2 en sens direct
			SupprimerParNumero("mobile",-25)	; suppression de la 2RM21(-25) créée sur N2 en sens direct
			SupprimerParNumero("mobile",-101)	; suppression du Pompier(-101) créé sur N2 en sens direct derrière Fourgon (-102)
			SupprimerParNumero("mobile",-100)	; suppression de la ModusNoire(-100) créé sur N2 en sens direct derrière Pompier (-101)
			RegulerVitesseRelative(-20,-1,FAUX,-200,0,0,VRAI,3)    ; Fourgon (-20) roule à la même vitesse que le sujet (-1)
		JSQA Position(-1,"mobile","N3",23472,VRAI,VRAI,">")
		; le sujet (-1) est à 110m avant N3XN5: 2457.2m-110= 2347.2(23472)
		ALLER ESSAI(92)
	FINSI
FIN	

;----------------------------Sujet (-1) tourne à gauche dans N3XN5----------------------------
;--------------------------------Flot5 frontal  sur la N3 (12)--------------------------------
;------------Fourgon(-21),ModusNoire(-22),GolfTex(-23),Chrysler(-24),Modus(-25)-----------
;---------- 1er véhicule---2ème véhi---3eme véhi------4eme véhi------5eme véhi ---------------
;--------Sujet (-1) traverse le Flot5 frontal sur la N3 (12) et TAG sur N5--------------------
;-----2RM14 (-105) arrive sur la N3 derrière le sujet (-1) et le dépasse par la droite -------


INSTRUCTION(920,92,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseRelative(-20,-1,FAUX,-100,0,0,VRAI,3)    
			; Fourgon (-20) roule à 10m(-100) derrière le sujet (-1) à la même vitesse
			;ChangerIndicateur(-20,VRAI,"clignotant_gauche",1)	clignotant avant pas beau sur ce véhicule
		JSQA Position(-1,"mobile","N3",21572,VRAI,VRAI,">")
		; le sujet (-1) est à 300m avant N3XN5: 2457.2m-300= 2157.2(21572)
		ALLER ESSAI(93)
	FINSI
FIN	

;----------------------------------Flot5 frontal sur N3---------------------------------------

INSTRUCTION(930,93,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseRelative(-20,-1,FAUX,-200,0,0,VRAI,3)    
			; Fourgon (-20) roule à 70km/h(194)
			CreerMobile ("C","M2",-21,"Asservi",13,VRAI,194,"N3",FAUX,-18,FAUX,27372,180)
			; Création Chrysler (-21) roulant en sens indirect sur la N3 (12) à 70 km/h (194). Trajectoire 2besafe.v13.
			; Pk N3XN5:2457.2m,Chrysler à 280m après N3XN5=2457.2+280=2737.2m (27372)
			CreerMobile ("V2","M3",-22,"Asservi",13,VRAI,194,"N3",FAUX,-18,VRAI,600,-21,180)
			; Création ModusNoire (-22) roulant en sens indirect sur la N3 à 70 km/h (194). ModusNoire est à 60 m derrière Chrysler (-21).
			; ModusNoire (-22) suit la trajectoire 2besafe.v13 sur la N3
			CreerMobile ("V1","M4",-23,"Asservi",13,VRAI,194,"N3",FAUX,-18,VRAI,800,-22,180)
			; Création GolfTex (-23) roulant en sens indirect sur la N3 à 70 km/h (194). GolfTex est à 80 m derrière ModusNoire(-22).
			; GolfTex(-23) suit la trajectoire 2besafe.v13 sur la N3
			CreerMobile ("V3","M1",-24,"Asservi",13,VRAI,194,"N3",FAUX,-18,VRAI,1500,-23,180)
			; Création AudiTT(-24) roulant en sens indirect sur la N3 à 70 km/h (194). AudiTT est à 150 m derrière GolfTex (-23).
			; AudiTT (-24) suit la trajectoire 2besafe.v13 sur la N3
			CreerMobile ("V1","M3",-25,"Asservi",13,VRAI,194,"N3",FAUX,-18,VRAI,1500,-24,180)
			; Création Modus (-25) roulant en sens indirect sur la N3 à 70 km/h (194). Modus est à 150 m derrière AudiTT(-24).
			; Modus (-25) suit la trajectoire 2besafe.v13 sur la N3
		JSQA Immediate()
		ALLER ESSAI(94)
	FINSI
FIN


INSTRUCTION(940,94,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseRelative(-20,-1,FAUX,-200,0,0,VRAI,3)    
			; Chrysler (-20) roule à la même vitesse que le sujet (-1)
		JSQA VitesseAbs(-1,"mobile",28,"<","")
		; vitesse du sujet (-1)<10km/h(28dm/s)
		; Sujet s'arrête pour laisser passer les véhicules du flot5 arrivant en face sur N3 en sens indirect
		ALLER ESSAI(95)
	FINSI
FIN	

INSTRUCTION(950,95,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-20,28,0,VRAI,1)
			RegulerAxiale(-20,5,0,VRAI,2)	; le Fourgon(-20) derrière le sujet (-1) se met sur la voie médiane en 2s
			ChangerIndicateur(-20,VRAI,"clignotant_gauche",1)	; le Fourgon met son clignotant à gauche
			; Chrysler (-20) roule à 20km/h(28) jusqu'à être à 6m derrière le sujet (-1)
		JSQA Interdistance(-20,"mobile",-1,"mobile",60,"<=")
		ALLER ESSAI(96)
	FINSI
FIN	

;-------------------2RM14 (-105) dépasse par la droite le sujet (-1) à N3XN5 -------------------------

INSTRUCTION(960,96,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseRelative(-20,-1,FAUX,-200,0,0,VRAI,3)    
			; Chrysler (-20) roule à la même vitesse que le sujet (-1)
			; Création de la 2RM14(-105) sur la N3 (12) à 3m (30) derrière le Chrysler (-20)
			; 2RM14 (-105) se trouve à 10m+10m (200) derrière le sujet (-1) et elle déboite vers la droite immédiatement
			; 2RM14 (-105) suit la trajectoire 2besafe.v14 et roule à 10km/h (28).
			CreerMobile ("M1","M1",-105,"Asservi",14,VRAI,56,"N3",FAUX,10,VRAI,-30,-20,0)
			RegulerAxiale(-105,30,0,FAUX,20)	
			; la 2RM14 (-105) se décalle dans la voie à droite de 3m(30) en dépassant à 20km/h(56)
			ChangerIndicateur(-105,VRAI,"phares",1)
			ChangerEnvMessage(5,"2RM14_N3",50,50,255,0,0)
		JSQA Interdistance(-1,"mobile",-105,"mobile",1,">")	
		; 2RM14 (-105) se trouve au niveau du sujet (-1)					
		ALLER ESSAI(97)
	FINSI
FIN

INSTRUCTION(970,97,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseRelative(-20,-1,FAUX,-200,0,0,VRAI,3)    
			; Chrysler (-20) roule à la même vitesse que le sujet (-1)
			RegulerVitesseFixe(-105,138,0,FAUX,50)    
			; 2RM14(-105) accélère jusqu'à 50km/h(138)
		JSQA Interdistance(-1,"mobile",-105,"mobile",50,">")	
		; 2RM14 (-105) se trouve à plus de 5m (50) devant le sujet (-1)				
		ALLER ESSAI(98)
	FINSI
FIN

INSTRUCTION(980,98,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseRelative(-20,-1,FAUX,-200,0,0,VRAI,3)    
			; Chrysler (-20) roule à la même vitesse que le sujet (-1)
			RegulerAxiale(-105,18,0,VRAI,5)	
			; 2RM14 (-105) se recentre dans la voie de droite en 2s aprés avoir doublé le sujet (-1)
			RegulerVitesseFixe(-105,138,0,VRAI,5) ; la 2RM14 (-105) accélère pour atteindre 50km/h (138) en 5s.
		JSQA Position(-1,"mobile","N5",12986,VRAI,FAUX,">")
		; Sujet a tourné à gauche sur la N5 après avoir traversé le flot5 sur la N3
		; sujet (-1) se trouve sur N5 à 30m aprés N5XN3: 1328.6-30=1298.6(12986)
		ALLER ESSAI(99)
	FINSI
FIN


;---------- 2RM15 (-106) arrive derrière le sujet (-1) sur N5 et le dépasse --------------------

INSTRUCTION(990,99,FAUX,FAUX,VRAI,VRAI)
	SI OU(NumeroEssai(),Position(-1,"mobile","N5",12986,VRAI,FAUX,">"))
	; Sujet a tourné à gauche sur la N5 après avoir traversé le flot5 sur la N3
	; sujet (-1) se trouve sur N5 à 30m aprés N5XN3: 1328.6-30=1298.6(12986)
		FAIRE
			RegulerVitesseFixe(-20,138,0,VRAI,5) 
			; le Chrysler (-20) accélère pour atteindre 50km/h (138) en 5s.
			CreerMobile ("M1","M1",-106,"Asservi",15,VRAI,278,"N5",FAUX,-18,VRAI,200,-1,180)
			ChangerIndicateur(-106,VRAI,"phares",1)
			ChangerEnvMessage(5,"2RM15_N5",50,50,255,0,0)
			; Création 2RM15 (-106) à 20m (200) derrière le sujet (-1), roulant en sens indirect sur la N5 (14) à 100 km/h (278). Trajectoire 2besafe.v15.
		JSQA Interdistance(-106,"mobile",-1,"mobile",110,"<=")	; le 2RM15(-106) se trouve à 11m (110) derrière le sujet (-1)	
		ALLER ESSAI(100)
	FINSI
FIN

INSTRUCTION(1000,100,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-106,FAUX,"clignotant_gauche",1)
			RegulerVitesseRelative(-106,-1,FAUX,-200,0,28,VRAI,2)
			; la 2RM15(-106) accélère en roulant à +10km/h par rapport au sujet (-1)
			RegulerAxiale(-106,16,0,VRAI,2)
			; la 2RM15(-106) se déporte dans la voie de gauche en 2s
			SupprimerParNumero("mobile",-21)	; suppression Chrysler (-21) créée sur la N3
			SupprimerParNumero("mobile",-22)	; suppression de la ModusNoire (-22) créée sur N3
			SupprimerParNumero("mobile",-23)	; suppression de la GolfTex (-23) créée sur N3
			SupprimerParNumero("mobile",-24)	; suppression de la Chrysler (-24) créée sur N3
			SupprimerParNumero("mobile",-25)	; suppression de la Modus (-25) créée sur N3
			SupprimerParNumero("mobile",-105)	; suppression de la 2RM14 (-105) créée sur N3
			ChangerEnvMessage(5,"2RM2_B1",50,50,255,0,0)			
		JSQA Interdistance(-106,"mobile",-1,"mobile",-50,"<")	
		; le 2RM15(-106) se trouve à 5m (50) devant le sujet (-1)	
		ALLER ESSAI(101)
	FINSI
FIN


;------------------- Sujet (-1) tourne à gauche dans N5XB1--------------------------------
;-----------Sujet (-1) TAG et s'insère dans le Flot6 latéral Droit sur la B1 (17) -------
;---------------------2RM15 (-106) latéral gauche sur la B1 (17)-------------------------
;-------------Flot6: Cam (-11),MercedesTaxi (-12),2RM2 (-13),Smart (-14),806 (-15)----
;------------------ 1er véhi---2ème véhi-------3eme véhi------4eme véhi---5eme véhi------


INSTRUCTION(1010,101,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-106,FAUX,"clignotant_gauche",1)
			RegulerAxiale(-106,-18,0,VRAI,2)
			; la 2RM15(-106) se déporte dans la voie de droite en 2s
			RegulerVitesseFixe(-106,278,0,VRAI,8) 
			; le 2RM15(-106) accélère pour atteindre 100km/h (278) en 8s.
		JSQA Position(-1,"mobile","N5",400,VRAI,FAUX,">")
		; sujet (-1) se trouve sur N5 à 40m avant N5XB1: 0+40=40(400)
		ALLER ESSAI(102)
	FINSI
FIN


INSTRUCTION(1020,102,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			CreerMobile ("PL3","M1",-11,"Asservi",05,VRAI,138,"B1",FAUX,18,FAUX,21662,0)
			; Création d'un Camion (-11) roulant en sens direct sur la B1 (17) à 50 km/h (138). Trajectoire 2besafe.v05.
			; le Camion (-11) à 60m de B1XN5:2226.2m,2226.2-60=2166.2m (21662)
			CreerMobile ("V3","M4",-12,"Asservi",05,VRAI,138,"B1",FAUX,18,VRAI,-550,-11,0)
			; Création MercedesTaxi (-12) roulant en sens direct sur la B1 à 50 km/h (138). MercedesTaxi est à 55 m (-550) derrière le camion (-11).
			; MercedesTaxi (-12) suit la trajectoire 2besafe.v05 sur la B1
			CreerMobile ("M1","M1",-13,"Asservi",05,VRAI,138,"B1",FAUX,18,VRAI,-300,-12,0)
			ChangerIndicateur(-13,VRAI,"phares",1)
			; Création 2RM2 (-13) roulant en sens direct sur la B1 à 50 km/h (138). 2RM2 est à 30 m (-300) derrière MercedesTaxi (-12) .
			; 2RM2 (-13) suit la trajectoire 2besafe.v05 sur la B1
			CreerMobile ("V1","M2",-14,"Asservi",05,VRAI,138,"B1",FAUX,18,VRAI,-1040,-13,0)
			; Création Smart (-14) roulant en sens direct sur la B1 à 50 km/h (138). Smart est à 124 m (-1040) derrière ModusNoire (-13).
			; Smart (-14) suit la trajectoire 2besafe.v05 sur la B1
			CreerMobile ("V3","M2",-15,"Asservi",05,VRAI,138,"B1",FAUX,18,VRAI,-580,-14,0)
			; Création Toledo (-15) roulant en sens direct sur la B1 à 50 km/h (138). Smart est à 58 m (-580) derrière la Smart (-14).
			; Toledo (-15) suit la trajectoire 2besafe.v05 sur la B1
		JSQA Position(-1,"mobile","B1",22342,VRAI,VRAI,">")
		; le sujet (-1) a démarré et est à 10m après B1XN5: 2226.2m,2226.2+8=2234.2m (22342)
		ALLER ESSAI(103)
	FINSI
FIN

;-------------Evitement de collision lors de l'insertion du sujet dans le Flot6---------------
;-----------Flot6: Cam (-11),MercedesTaxi (-12),2RM2 (-13),Smart (-14),Toledo (-15)-----------
;----------------- 1er véhi---2ème véhi----3eme véhi----4eme véhi---5eme véhi------------

INSTRUCTION(1030,103,FAUX,FAUX,VRAI,VRAI)
	SI ET(Interdistance(-1,"mobile",-11,"mobile",-70,">"),Position(-1,"mobile","B1",26262,VRAI,VRAI,"<"))
	 	; Sujet (-1) se trouve à moins de 7m (70) devant le cam(-10)
		; Sujet et camion roulent en sens direct donc Pk(-11)-Pk(-1)<0,critère d'interdistance négatif
		; Critère=-7m(-70)
		FAIRE
			RegulerVitesseRelative(-11,-1,FAUX,-200,0,-7,VRAI,2)
			; le camion (-11) ralentit puis roule à -4km/h (7) par rapport au sujet (-1) en restant à 20m (200) de distance
		JSQA Position(-1,"mobile","B1",26262,VRAI,VRAI,">")
		; le sujet (-1) est à 400m après B1XN5: 2226.2m +400=2626.2(26262)
		ALLER COURANT
	FINSI
FIN

INSTRUCTION(1031,103,FAUX,FAUX,VRAI,VRAI)
	SI ET(Enchaine(1030),Interdistance(-1,"mobile",-11,"mobile",-70,"<="))	
	; le sujet ne s'insère pas devant le camion(-11) en étant trop près
	; Sujet (-1) se trouve à plus de 7m (70) devant le cam (-10)
		FAIRE
			NeRienFaire()
		JSQA Immediate()
		ALLER ESSAI(108)
	FINSI
FIN

INSTRUCTION(1040,104,FAUX,FAUX,VRAI,VRAI)	; Insertion du sujet(-1) devant la MercedesTaxi(-12)
	SI ET(Interdistance(-1,"mobile",-12,"mobile",-70,">"),Position(-1,"mobile","B1",26262,VRAI,VRAI,"<"))
	; Sujet (-1) se trouve à moins de 7m (70) devant la MercedesTaxi(-12)
		FAIRE
			RegulerVitesseRelative(-12,-1,FAUX,-200,0,-7,VRAI,2)
			; le MercedesTaxi (-12) ralentit puis roule à -4km/h (7) par rapport au sujet (-1) en restant à 20m (200) de distance
		JSQA Position(-1,"mobile","B1",26262,VRAI,VRAI,">")
		; le sujet (-1) est à 400m après B1XN5: 2226.2m +400=2626.2(26262)
		ALLER COURANT
	FINSI
FIN

INSTRUCTION(1041,104,FAUX,FAUX,VRAI,VRAI)
	SI ET(Enchaine(1040),Interdistance(-1,"mobile",-12,"mobile",-70,"<="))	
	; le sujet ne s'insère pas devant la MercedesTaxi (-12) en étant trop près
	; Sujet (-1) se trouve à plus de 7m (70) devant RAV4Tex (-3)
		FAIRE
			NeRienFaire()
		JSQA Immediate()
		ALLER ESSAI(108)
	FINSI
FIN

INSTRUCTION(1050,105,FAUX,FAUX,VRAI,VRAI)	; Insertion du sujet(-1) devant la 2RM2(-13)
	SI ET(Interdistance(-1,"mobile",-13,"mobile",-70,">"),Position(-1,"mobile","B1",26262,VRAI,VRAI,"<"))
	; Sujet (-1) se trouve à moins de 7m (70) devant la 2RM2(-13)
		FAIRE
			RegulerVitesseRelative(-13,-1,FAUX,-200,0,-7,VRAI,2)
			; la 2RM2 (-13) ralentit puis roule à -4km/h (7) par rapport au sujet (-1) en restant à 20m (200) de distance
		JSQA Position(-1,"mobile","B1",26262,VRAI,VRAI,">")
		; le sujet (-1) est à 400m après B1XN5: 2226.2m +400=2626.2(26262)
		ALLER COURANT
	FINSI
FIN

INSTRUCTION(1051,105,FAUX,FAUX,VRAI,VRAI)
	SI ET(Enchaine(1050),Interdistance(-1,"mobile",-13,"mobile",-70,"<="))	
	; le sujet ne s'insère pas devant la 2RM2(-13) en étant trop près
	; Sujet (-1) se trouve à plus de 7m (70) devant la 2RM2(-3)
		FAIRE
			NeRienFaire()	
		JSQA Immediate()
		ALLER ESSAI(108)
	FINSI
FIN

INSTRUCTION(1060,106,FAUX,FAUX,VRAI,VRAI)	; Insertion du sujet(-1) devant la Smart(-14)
	SI ET(Interdistance(-1,"mobile",-14,"mobile",-70,">"),Position(-1,"mobile","B1",26262,VRAI,VRAI,"<"))
	 	; Sujet (-1) se trouve à moins de 7m (70) devant la Smart(-4)
		FAIRE
			RegulerVitesseRelative(-14,-1,FAUX,-200,0,-7,VRAI,2)
			; la Smart(-14) ralentit puis roule à -4km/h (7) par rapport au sujet (-1) en restant à 20m (200) de distance
		JSQA Position(-1,"mobile","B1",26262,VRAI,VRAI,">")
		; le sujet (-1) est à 400m après B1XN5: 2226.2m +400=2626.2(26262)
		ALLER COURANT
	FINSI
FIN

INSTRUCTION(1061,106,FAUX,FAUX,VRAI,VRAI)
	SI ET(Enchaine(1060),Interdistance(-1,"mobile",-14,"mobile",-70,"<="))	
	; le sujet ne s'insère pas devant la Smart(-14) en étant trop près
	; Sujet (-1) se trouve à plus de 7m (70) devant la Smart(-4)
		FAIRE
			NeRienFaire()	
		JSQA Immediate()
		ALLER ESSAI(108)
	FINSI
FIN

INSTRUCTION(1070,107,FAUX,FAUX,VRAI,VRAI)	; Insertion du sujet(-1) devant la Toledo(-15)
 	SI ET(Interdistance(-1,"mobile",-15,"mobile",-70,">"),Position(-1,"mobile","B1",26262,VRAI,VRAI,"<"))
	; Sujet (-1) se trouve à moins de 7m (70) devant la Toledo(-5)
		FAIRE
			RegulerVitesseRelative(-15,-1,FAUX,-200,0,-7,VRAI,2)
			; la Toledo (-15) ralentit puis roule à -4km/h (7) par rapport au sujet (-1) en restant à 20m (200) de distance
		JSQA Position(-1,"mobile","B1",26262,VRAI,VRAI,">")
		; le sujet (-1) est à 400m après B1XN5: 2226.2m +400=2626.2(26262)
		ALLER COURANT
	FINSI
FIN

INSTRUCTION(1071,107,FAUX,FAUX,VRAI,VRAI)
	SI ET(Enchaine(1070),Interdistance(-1,"mobile",-15,"mobile",-70,"<="))	
	; le sujet ne s'insère pas devant la Toledo(-15) en étant trop près
	; Sujet (-1) se trouve à plus de 7m (70) devant la 806(-5)
		FAIRE
			NeRienFaire()	
		JSQA Immediate()
		ALLER ESSAI(108)
	FINSI
FIN

;-------------------------------fin insertion dans Flot6----------------------------	

INSTRUCTION(1080,108,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			SupprimerParNumero("mobile",-106)	; supression de la 2RM15(-106) créée sur N5
			RegulerAxiale(-11,18,0,VRAI,3)	; le Camion(-11) se recentre dans la voie de droite en 2s
			RegulerAxiale(-12,18,0,VRAI,3)	; le MercedesTaxi (-12) se recentre dans la voie de droite en 2s
			RegulerAxiale(-13,18,0,VRAI,3)	; la 2RM2 (-13) se recentre dans la voie de droite en 2s
			RegulerAxiale(-14,18,0,VRAI,3)	; la Smart (-14) se recentre dans la voie de droite en 2s
			RegulerAxiale(-15,18,0,VRAI,3)	; la Toledo (-15) se recentre dans la voie de droite en 2s
		JSQA Position(-1,"mobile","B1",27262,VRAI,VRAI,">")
		; le sujet (-1) est à 500m après B1XN5: 2226.2m + 500=2726.2(27262)
		ALLER ESSAI(109)
	FINSI
FIN

;------------------ Conduite Flot6 sur la B1 (17) jusqu'au rond point d3(18)----------------------
;-------------- Cam(-11),MercedesTaxi(-12),2RM2(-13),Smart(-14),arrêt Toledo(-15)-------------------

INSTRUCTION(1090,109,FAUX,FAUX,VRAI,VRAI)
	SI OU(NumeroEssai(),Position(-1,"mobile","B1",27272,VRAI,VRAI,">"))
	; le sujet (-1) est à 501m après B1XN5: 2226.2m + 501=2727.2(27272)
		FAIRE
			RegulerVitesseFixe(-11,194,0,VRAI,8)	; accélération du Camion(-11) à 70km/h(194)
			RegulerVitesseFixe(-12,194,0,VRAI,8)	; accélération de la MercedesTaxi(-12) à 70km/h(194)
			RegulerVitesseFixe(-13,194,0,VRAI,8)	; accélération de la 2RM2(-13) à 70km/h(194)
			RegulerVitesseFixe(-14,194,0,VRAI,8)	; accélération de la smart (-14) à 70km/h(194)
			RegulerVitesseFixe(-15,0,0,VRAI,10)		; déccélération de la Toledo (-15) à 0km/h(0)
			RegulerAxiale(-15,40,0,VRAI,5)			; Toledo(-15) s'arrête sur le bas coté de la B1(17)
			ChangerIndicateur(-13,VRAI,"warning",1)	; Allumage des warning de la 2RM2(-13) stationnaire 
		JSQA Position(-11,"mobile","B1",43467,VRAI,VRAI,">")	
		; le camion (-11) se trouve sur la B1(17) à 750m avant le rond-point d3(18)
		; Pk B1Xd3:5096.7m-750=4346.7(43467)
		ALLER ESSAI(110)
	FINSI
FIN

;----------------- Cam(-11),MercedesTaxi(-12),arrêt 2RM2(-13),Smart(-14)-------------------

INSTRUCTION(1100,110,FAUX,FAUX,VRAI,VRAI)
	SI OU(NumeroEssai(),Position(-1,"mobile","B1",27272,VRAI,VRAI,">"))
	; le sujet (-1) est à 501m après B1XN5: 2226.2m + 501=2727.2(27272)
		FAIRE
			RegulerVitesseFixe(-11,194,0,VRAI,8)	; accélération du Camion(-11) à 70km/h(194)
			RegulerVitesseFixe(-12,194,0,VRAI,8)	; accélération de la MercedesTaxi(-12) à 70km/h(194)
			ChangerIndicateur(-13,VRAI,"clignotant_droit",1)	
			RegulerVitesseFixe(-13,0,0,VRAI,10)		; déccélération de la 2RM2(-13) à 0km/h(0)
			RegulerAxiale(-13,40,0,VRAI,5)			; 2RM2(-13) s'arrête sur le bas coté de la B1(17)
			RegulerVitesseFixe(-14,194,0,VRAI,8)	; accélération de la smart (-14) à 70km/h(194)		
		JSQA Position(-11,"mobile","B1",44467,VRAI,VRAI,">")	
		; le camion (-11) se trouve sur la B1(17) à 450m avant le rond-point d3(18)
		; Pk B1Xd3:5096.7m-650=4446.7(44467)
		ALLER ESSAI(111)
	FINSI
FIN

;----------------- Cam(-11),arret MercedesTaxi(-12),arret Smart (-14) -------------------

INSTRUCTION(1110,111,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-11,194,0,VRAI,8)	; accélération du Camion(-11) à 70km/h(194)
			RegulerVitesseFixe(-12,0,0,VRAI,10)		; déccélération de la MercedesTaxi(-12) à 0km/h(0)
			RegulerAxiale(-12,40,0,VRAI,10)			; MercédèsTaxi(-12) s'arrête sur le bas coté de la B1(17)
			ChangerIndicateur(-12,VRAI,"clignotant_droit",1)		
			RegulerVitesseFixe(-14,0,0,VRAI,10)		; déccélération de la smart (-14) à 0km/h(0)
			RegulerAxiale(-14,40,0,VRAI,5)			; smart (-14) s'arrête sur le bas coté de la B1(17)
		JSQA Position(-11,"mobile","B1",47967,VRAI,VRAI,">")	
		; le camion (-11) se trouve sur la B1 à moins de 300m du rond-point d3(18)
		; Pk B1Xd3:5096.7m-300=4796.7(47967)
		ALLER ESSAI(112)
	FINSI
FIN

INSTRUCTION(1120,112 ,FAUX ,FAUX ,VRAI ,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-11,111,0,VRAI,5)	; déccélération du Camion(-11) à 40km/h(111)
		JSQA Position(-11,"mobile","B1",50467,VRAI,VRAI,">")	
		; le camion (-11) se trouve sur la B1 à 50m avant le rond-point d3(18), Pk B1Xd3:5096.7m-50=5046.7(50467)
		ALLER ESSAI(113)
	FINSI
FIN

INSTRUCTION(1130,113,FAUX,FAUX ,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-11,70,0,VRAI,2)	; déccélération du Camion(-11) à 25km/h(70)
		JSQA Position(-11,"mobile","B1",50667,VRAI,VRAI,">")	
		; le camion (-11) se trouve sur la B1 30m avant le rond-point d3(18), Pk B1Xd3:5096.7m-30=5066.7(50667)
		ALLER ESSAI(114)
	FINSI
FIN

INSTRUCTION(1140,114,FAUX,FAUX ,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			CreerMobile ("PL3","M4",-103,"Asservi",-1,VRAI,0,"D9",FAUX,-18,FAUX,100,150)
			ChangerIndicateur(-103,VRAI,"warning",1)
			; Pompier (-103) créé sur D9 à 10m du rond point d3: D9Xd3:0m+10=10(100)
		JSQA Immediate()
		ALLER ESSAI(115)
	FINSI
FIN

;----------------Négociation du rond-point d3 (18) par le camion (-11) -------------------------

INSTRUCTION(1150,115,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-11,40,0,VRAI,5)	; déccélération du Camion(-11) à 15km/h(40)
		JSQA Position(-1,"mobile","d3",1126,VRAI,FAUX,">")	
		; le sujet(-1) se trouve sur le rond point d3(18) au niveau de la sortie D9, Pk d3XD9:112.6m (1126)
		ALLER ESSAI(117)
	FINSI
FIN


;-----------2RM16 (-105) latéral droit dans rond-point d3 (18) et qui stop avant le rond-point-----------
;-------------Détection latérale Droite du 2RM16 (-105) à l'arrêt à l'entrée d'un rond point-------------


INSTRUCTION(1170,117,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			CreerMobile ("M1","M1",-105,"Asservi",16,VRAI,110,"D2",FAUX,18,FAUX,107265,0)
			ChangerIndicateur(-105,VRAI,"phares",1)
			ChangerEnvMessage(5,"2RM16_D2",50,50,255,0,0)
			; Création 2RM16 (-105) roulant en sens direct sur la D2 (18) à la vitesse de 40km/h(110). 
			; 2RM16 créé à 80m du rond point: Pk D2Xd3:10806.5m-80=10726.5(107265)
			; 2RM16 (-105) suit la trajectoire 2besafe.v16
		JSQA Position(-105,"mobile","D2",107915,VRAI,VRAI,">")	
		; 2RM16(-105) se trouve sur la D2 à moins de 15m du rond-point d3(18)
		; Pk D2Xd3:10806.5m-15=10791.5(107915)
		ALLER ESSAI(118)
	FINSI
FIN

INSTRUCTION(1180,118,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-105,0,0,FAUX,80)	
			; arret de la 2RM16 sur la D2(18) quand elle est à moins de 6m du rond-point d3(18)
		JSQA Attente(9)
		; 2RM16 s'est arrêté avant le rond-point d3(18)
		ALLER ESSAI(119)
	FINSI
FIN

INSTRUCTION(1190,119,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			NeRienFaire()
		JSQA Position(-1,"mobile","D2",106198,VRAI,FAUX,"<")
		; sujet (-1) se trouve sur D2(2) à Pk=10619.8m(106198)
		ALLER ESSAI(120)
	FINSI
FIN


;--------Supression du Flot6 et de la 2RM15,de la 2RM16 quand sujet (-1) sur N2 après N2XN3---------
;----------Flot6: Cam (-11),MercedesTaxi (-12),2RM2 (-13),Smart (-14),806 (-15)------------------

INSTRUCTION(1200,120,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			SupprimerParNumero("mobile",-11)	; suppression du cam (-11) créée sur la B1
			SupprimerParNumero("mobile",-12)	; suppression de la MercedesTaxi (-12) créée sur B1
			SupprimerParNumero("mobile",-13)	; suppression de la 2RM2 (-13) créée sur B1
			SupprimerParNumero("mobile",-14)	; suppression de la Smart (-14) créée sur B1
			SupprimerParNumero("mobile",-15)	; suppression de la Toledo (-15) créée sur B1	
			SupprimerParNumero("mobile",-106)	; suppression de la 2RM15 (-106) créée sur B1
			SupprimerParNumero("mobile",-105)	; suppression de la 2RM16 (-105) créée sur D2
			SupprimerParNumero("mobile",-103)	; suppression des pompiers (-103) stationaire créé sur D9			
		JSQA Immediate()
		ALLER ESSAI(250)
	FINSI
FIN

		
;--------------------------------------------------------------------
;-----------------------Avertissement fin scenario -------------------
;---------------------------------------------------------------------


INSTRUCTION(2500,250,FAUX,FAUX,FAUX,FAUX)
	SI NumeroEssai()
		FAIRE
			ChangerEnvMessage(6,"TERMINE",50,50,255,0,0)
		JSQA Attente(5)
		ALLER COURANT
	FINSI
FIN
