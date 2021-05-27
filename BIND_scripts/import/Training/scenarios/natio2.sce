V4.6

fran�ais

commentaireManip= Manip training1 2010 r�dig� par Joceline !! TACHE DE DETECTION NATIO2

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
;--2RM12 d�tection frontale sur N2, 2RM21 d�passe fourgon sur la voie oppos�e au sujet sur N2, 2RM14 d�passement droite sur N3 ---------------------------
;-- 2RM15 d�passement sujet sur N5, 2RM2 d�tection lat�rale droite sur B1, 2RM2 stationaire sur B1, 2RM16 d�tection lat�rale droite sur rond-point d6 ----
;------------------------------Red�marrage sur N10 dans le sens indirect � 5m apr�s l'intersection N10XN2-------------------------------------------------

;	Pk N10XN2=2619.9m+20=2639.9(2639m),le sujet (-1) est � 20m avant N10XN2 dans 2besafe.vp

INSTRUCTION(30,3,FAUX,FAUX,VRAI,VRAI)
	SI Immediate()
		FAIRE
			ChangerEnvMessage(5,"12*21*14*15*2*2*16",50,50,255,0,0)
		JSQA Position(-1,"mobile","N10",26599,VRAI,FAUX,">")
		; Pk N10XN2=2619.9m+40=2659.9(26599),le sujet (-1) est � 40m avant N10XN2
		ALLER ESSAI(79)
	FINSI
FIN


;-------------------------------------------------- Flot4: Trafic sur la N2-----------------------------------------------------
;------------------------CitroenC4(-10),Smart (-222),RAV4Tex (-3),C4Noire(-4),Chrysler(-5)-------------------------------
;--sens de circulation:   1er v�hicule----- 2�me v�hi--3eme v�hi------4eme v�hi------5eme v�hi ---------------------------------
;---------------------D�tection frontale de la 2RM12 (-106) alors que le sujet est derri�re le flot4----------

INSTRUCTION(790,79,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			CreerMobile ("V2","M1",-10,"Asservi",02,VRAI,194,"N2",FAUX,-18,FAUX,52821,180)
			; Cr�ation CitroenC4 (-10) sur la N2 roulant en sens indirect � 70 km/h (194)
			; trajectoire 2besafe.v02,CitroenC4 � 60m de N2XN10=5182.1+100m=5282.1m (52821)
			CreerMobile ("V1","M2",-222,"Asservi",02,VRAI,194,"N2",FAUX,-18,VRAI,600,-10,180)
			; Cr�ation Smart (-222) roulant en sens indirect sur la N2 � 70 km/h (194).Smart (-222) est � 60 m derri�re la CitroenC4(-10).
			; Smart (-222) suit la trajectoire 2besafe.v02 sur la N2
			CreerMobile ("V1","M1",-3,"Asservi",02,VRAI,194,"N2",FAUX,-18,VRAI,800,-222,180)
			; Cr�ation RAV4Tex (-3) roulant en sens indirect sur la N2 � 70 km/h (194).RAV4Tex (-3) est � 80 m derri�re la Smart (-222).
			; RAV4Tex (-3) suit la trajectoire 2besafe.v02 sur la N2
			CreerMobile ("V2","M4",-4,"Asservi",02,VRAI,194,"N2",FAUX,-18,VRAI,1500,-3,180)
			; Cr�ation C4Noire(-4) roulant en sens indirect sur la N2 � 70 km/h (194). C4Noire (-4) est � 150 m derri�re la RAV4Tex(-4).
			; C4Noire (-4) suit la trajectoire 2besafe.v02 sur la N2.
			CreerMobile ("V3","M1",-5,"Asservi",02,VRAI,194,"N2",FAUX,-18,VRAI,1500,-4,180)
			; Cr�ation AudiTT (-5) roulant en sens indirect sur la N2 � 70 km/h (194). AudiTT(-5) est � 150 m derri�re la C4Noire(-4).
			; AudiTT (-5) suit la trajectoire 2besafe.v02 sur la N2.				
	 	JSQA Immediate()
		ALLER ESSAI(80)
	FINSI
FIN



;------Cr�ation de la 2RM21(-25) sur N2 derri�re le fourgon (-102) qui d�boitera en frontal au moment o� le sujet arrivera sur la voie d'en face------------- 
;--------------------------------------------Creation du ballon (-1000) ----------------------------------

INSTRUCTION(800,80,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			CreerMobile ("PL3","M3",-104,"Asservi",-1,VRAI,0.0,"N2",FAUX,-30,FAUX,30990,180)
			; Cr�ation du BusTex (-104) stationnaire sur le bord de la N2 en sens indirect
			; Bustext (-104) est � 500m apr�s N2XN6: 3489.5m-390.5=3099.0 (30990)
			CreerMobile ("PL3","M3",-103,"Asservi",-1,VRAI,0.0,"N2",FAUX,-30,FAUX,14791,180)
			; Cr�ation du BusTex (-103) stationnaire sur le bord de la N2 en sens indirect
			; Bustext (-103) est � 500m avant N2XN3: 964.1m+515=1479.1 (14791)
			CreerMobile("C","M4",-102,"Asservi",17,VRAI,194,"N2",FAUX,18,FAUX,9841,0)
			; Cr�ation d'un Fourgon (-102) roulant � 70 km/h (194) en sens direct sur N2 (34)
			; Trajectoire 2BeSafe.v17,� 20m apr�s N2XN3:964.1m+20=984.1(9841)
			CreerMobile("M1","M1",-25,"Asservi",17,VRAI,194,"N2",FAUX,18,FAUX,9741,0)
			; Cr�ation de la 2RM21(-25), 10 m derrri�re le fourgon (-102) roulant � 70 km/h (194) dans la voie de gauche en sens direct sur N2(34)
			; Trajectoire 2BeSafe.v17, 974.1m-5=969.1(9691)
			CreerMobile("PL3","M4",-101,"Asservi",17,VRAI,194 ,"N2",FAUX,18,VRAI,1500,-102,0)
			; Cr�ation d'un camion de pompier (-101) roulant � 70 km/h (194) en sens direct sur N2 (34)
			; Trajectoire lepsis.v17,� 150m (1500) devant le Fourgon (-102)
			CreerMobile("V2","M3",-100,"Asservi",17,VRAI,194 ,"N2",FAUX,18,VRAI,800,-101,0)
			; Cr�ation de la ModusNoire(-100) roulant � 70 km/h (194) en sens direct sur N2 (34)
			; Trajectoire lepsis.v17,� 80m (800) devant le Pompier (-101)
		JSQA Position(-1,"mobile", "N2",51771, VRAI,FAUX,">")
		; le sujet (-1) a d�marr� et se trouve sur N2 (34) � 5m apr�s N2XN10: 5182.1m -5=5177.1 (51771)
		ALLER ESSAI(81)
	FINSI
FIN

INSTRUCTION(810,81,FAUX,FAUX,VRAI,VRAI)
	SI OU(NumeroEssai(),Position(-1,"mobile","N2",44491,VRAI,FAUX,">"))
	; Sujet se trouve � 35 m avant N2XN7:4114.1+35=4449.1(44491)
		FAIRE
			NeRienFaire()	
		JSQA Position(-1,"mobile","N2",44441,VRAI,FAUX,">")
		; Sujet se trouve � 30 m avant N2XN7:4114.1+30=4444.1(44441)
		ALLER ESSAI(82)
	FINSI
FIN


INSTRUCTION(820,82,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			; Cr�ation de la 2RM12 (-106)
			CreerMobile ("M1","M1",-106,"Asservi",12,VRAI,138,"N7",FAUX,18,FAUX,39601,0)
			ChangerIndicateur(-106,VRAI,"phares",1)
			ChangerEnvMessage(5,"2RM12_N7",50,50,255,0,0)
			; Cr�ation de la 2RM12 (-106) en sens direct sur N7,10m avant N7XN2. Elle est dissimul�e par une maison. 
			; 2RM12 se lance dans l'intersection � 50km/h(138)
			; Pk N7XN2=3970.1m,	3970.1-10=3960.1 (39601).
			; 2RM12 (-106) suit la trajectoire 2besafe.v12 sur la N7 puis tourne � droite sur la N2 et roule en sens direct.	
		JSQA Interdistance(-25,"mobile",-1,"mobile",5500,"<=")	; le 2RM21(-25) se trouve � 550m (5500) devant le sujet (-1)
		ALLER ESSAI(83)
	FINSI
FIN


INSTRUCTION(830,83,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerEnvMessage(5,"Enfants_N2",50,50,255,0,0)		; Cr�ation des enfants
			;CreerPanneau(-1001,83,"visuelle","aucun","aucune",150000,150000,0,0,100,1,1,"N2",FAUX,-30,VRAI,-200000,-1,180)
			; enfants sur la N2 cr��s � 200m(-200000mm) du sujet (-1) et sur le bas c�t� droit (-30)
			CreerPanneau(-1001,0,"visuelle","aucun","aucune",150000,150000,0,0,100,1,1,"N2",FAUX,-50,VRAI,-200000,-1,0)
			; petit gar�on sur la N2 cr��s � 200m(-200000mm) du sujet (-1) et sur le bas c�t� droit (-50)
		JSQA Immediate()
		ALLER ESSAI(84)
	FINSI
FIN


INSTRUCTION(840,84,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			; Cr�ation du ballon
			ChangerEnvMessage(5,"Ballon_N2",50,50,255,0,0)
			;CreerMobile ("Tram1","M1",-1000,"Asservi",130,VRAI,20,"N2",FAUX,-20,VRAI,3500,-25,0)	
			; ballon (-1000) qui roule � 2m/s(20) sur la N2 en sens indirect sur le bord de la voie (-20), cr�� � 350 de la 2RM21(-25)
			CreerMobile ("Tram1","M1",-1000,"Asservi",130,VRAI,20,"N2",FAUX,-30,VRAI,-1950,-1,5)
			; ballon (-1000) qui roule � 2m/s(20) sur la N2 en sens indirect sur le bord de la voie (-30), cr�� � 195m(1950) du sujet(-1) et avec un cap de 5�
		JSQA Interdistance(-25,"mobile",-1,"mobile",2000,"<=")	; le 2RM21(-25) se trouve � 200m (2000) devant le sujet (-1)
		ALLER ESSAI(88)
	FINSI
FIN


INSTRUCTION(880,88,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-25,VRAI,"phares",1)
			; ChangerIndicateur(-25,FAUX,"clignotant_gauche",1)
			RegulerVitesseRelative(-25,-102,FAUX,-200,0,56,VRAI,2)
			;la 2RM21(-25) acc�l�re en roulant � +20km/h (56) par rapport au fourgon(-102)
			RegulerAxiale(-25,0,0,VRAI,1)		; la 2RM21(-25) se d�porte dans la voie de droite en 1s
			ChangerEnvMessage(5,"2RM12_N7",50,50,255,0,0)
		JSQA Interdistance(-25,"mobile",-102,"mobile",50,">")	; le 2RM21(-25) se trouve � 5m (50) devant le fourgon (-102)
		ALLER ESSAI(89)
	FINSI
FIN

;-----------Suivi du sujet (-1) par un Fourgon (-20) sur la N3(12)---------

INSTRUCTION(890,89,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerAxiale(-25,18,0,VRAI,3)	; la 2RM21(-25) se red�porte dans la voie de gauche en 3s devant le fourgon		
		JSQA Position(-1,"mobile","N3",800,VRAI,VRAI,">")
		; Sujet (-1) est sur la N3 80m apr�s N3XN2: 0m+80=80(800)		
		ALLER ESSAI(90)
	FINSI
FIN

INSTRUCTION(900,90,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			CreerMobile ("C","M4",-20,"Asservi",14,VRAI,278,"N3",FAUX,18,FAUX,100,0)
			; Cr�ation du Fourgon (-20) en sens direct sur N3,10m apr�s N3XN2. Pk N3XN2: 0+10= 10(100).
			; suit la trajectoire 2besafe.v14 et roule � 100km/h (278)
		JSQA Interdistance(-20,"mobile",-1,"mobile",250,"<")	
		; Attente que Jeep (-10) se retrouve � 25 m derri�re le sujet (-1)
		ALLER ESSAI(91)
	FINSI
FIN


INSTRUCTION(910,91,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			SupprimerParNumero("mobile",-10)	; suppression de la CitroenC4 (-10) cr��e sur N2 en sens indirect
			SupprimerParNumero("mobile",-12)	; suppression de la AudiTT cr��e sur la N2 en sens indirect
			SupprimerParNumero("mobile",-5)		; suppression de la AudiTT (-5) cr��e sur N2 en sens indirect
			SupprimerParNumero("mobile",-4)		; suppression de la C4Noire (-4) cr��e sur N2 en sens indirect
			SupprimerParNumero("mobile",-3)		; suppression de la RAV4Tex (-3) cr��e sur N2 en sens indirect
			SupprimerParNumero("mobile",-222)	; suppression de la Smart (-222) cr��e sur N2 en sens indirect
			SupprimerParNumero("mobile",-104)	; suppression du BusTex (-104) stationaire cr�� sur N2 apr�s N2XN6
			SupprimerParNumero("mobile",-103)	; suppression du BusTex (-103) stationaire cr��e sur N2 avant N2XN3		
			SupprimerParNumero("mobile",-106)	; suppression de la 2RM12 (-106) cr��e sur N2 en sens direct
			SupprimerParNumero("mobile",-102)	; suppression du Fourgon (-102) cr�� sur N2 en sens direct
			SupprimerParNumero("mobile",-25)	; suppression de la 2RM21(-25) cr��e sur N2 en sens direct
			SupprimerParNumero("mobile",-101)	; suppression du Pompier(-101) cr�� sur N2 en sens direct derri�re Fourgon (-102)
			SupprimerParNumero("mobile",-100)	; suppression de la ModusNoire(-100) cr�� sur N2 en sens direct derri�re Pompier (-101)
			RegulerVitesseRelative(-20,-1,FAUX,-200,0,0,VRAI,3)    ; Fourgon (-20) roule � la m�me vitesse que le sujet (-1)
		JSQA Position(-1,"mobile","N3",23472,VRAI,VRAI,">")
		; le sujet (-1) est � 110m avant N3XN5: 2457.2m-110= 2347.2(23472)
		ALLER ESSAI(92)
	FINSI
FIN	

;----------------------------Sujet (-1) tourne � gauche dans N3XN5----------------------------
;--------------------------------Flot5 frontal  sur la N3 (12)--------------------------------
;------------Fourgon(-21),ModusNoire(-22),GolfTex(-23),Chrysler(-24),Modus(-25)-----------
;---------- 1er v�hicule---2�me v�hi---3eme v�hi------4eme v�hi------5eme v�hi ---------------
;--------Sujet (-1) traverse le Flot5 frontal sur la N3 (12) et TAG sur N5--------------------
;-----2RM14 (-105) arrive sur la N3 derri�re le sujet (-1) et le d�passe par la droite -------


INSTRUCTION(920,92,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseRelative(-20,-1,FAUX,-100,0,0,VRAI,3)    
			; Fourgon (-20) roule � 10m(-100) derri�re le sujet (-1) � la m�me vitesse
			;ChangerIndicateur(-20,VRAI,"clignotant_gauche",1)	clignotant avant pas beau sur ce v�hicule
		JSQA Position(-1,"mobile","N3",21572,VRAI,VRAI,">")
		; le sujet (-1) est � 300m avant N3XN5: 2457.2m-300= 2157.2(21572)
		ALLER ESSAI(93)
	FINSI
FIN	

;----------------------------------Flot5 frontal sur N3---------------------------------------

INSTRUCTION(930,93,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseRelative(-20,-1,FAUX,-200,0,0,VRAI,3)    
			; Fourgon (-20) roule � 70km/h(194)
			CreerMobile ("C","M2",-21,"Asservi",13,VRAI,194,"N3",FAUX,-18,FAUX,27372,180)
			; Cr�ation Chrysler (-21) roulant en sens indirect sur la N3 (12) � 70 km/h (194). Trajectoire 2besafe.v13.
			; Pk N3XN5:2457.2m,Chrysler � 280m apr�s N3XN5=2457.2+280=2737.2m (27372)
			CreerMobile ("V2","M3",-22,"Asservi",13,VRAI,194,"N3",FAUX,-18,VRAI,600,-21,180)
			; Cr�ation ModusNoire (-22) roulant en sens indirect sur la N3 � 70 km/h (194). ModusNoire est � 60 m derri�re Chrysler (-21).
			; ModusNoire (-22) suit la trajectoire 2besafe.v13 sur la N3
			CreerMobile ("V1","M4",-23,"Asservi",13,VRAI,194,"N3",FAUX,-18,VRAI,800,-22,180)
			; Cr�ation GolfTex (-23) roulant en sens indirect sur la N3 � 70 km/h (194). GolfTex est � 80 m derri�re ModusNoire(-22).
			; GolfTex(-23) suit la trajectoire 2besafe.v13 sur la N3
			CreerMobile ("V3","M1",-24,"Asservi",13,VRAI,194,"N3",FAUX,-18,VRAI,1500,-23,180)
			; Cr�ation AudiTT(-24) roulant en sens indirect sur la N3 � 70 km/h (194). AudiTT est � 150 m derri�re GolfTex (-23).
			; AudiTT (-24) suit la trajectoire 2besafe.v13 sur la N3
			CreerMobile ("V1","M3",-25,"Asservi",13,VRAI,194,"N3",FAUX,-18,VRAI,1500,-24,180)
			; Cr�ation Modus (-25) roulant en sens indirect sur la N3 � 70 km/h (194). Modus est � 150 m derri�re AudiTT(-24).
			; Modus (-25) suit la trajectoire 2besafe.v13 sur la N3
		JSQA Immediate()
		ALLER ESSAI(94)
	FINSI
FIN


INSTRUCTION(940,94,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseRelative(-20,-1,FAUX,-200,0,0,VRAI,3)    
			; Chrysler (-20) roule � la m�me vitesse que le sujet (-1)
		JSQA VitesseAbs(-1,"mobile",28,"<","")
		; vitesse du sujet (-1)<10km/h(28dm/s)
		; Sujet s'arr�te pour laisser passer les v�hicules du flot5 arrivant en face sur N3 en sens indirect
		ALLER ESSAI(95)
	FINSI
FIN	

INSTRUCTION(950,95,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-20,28,0,VRAI,1)
			RegulerAxiale(-20,5,0,VRAI,2)	; le Fourgon(-20) derri�re le sujet (-1) se met sur la voie m�diane en 2s
			ChangerIndicateur(-20,VRAI,"clignotant_gauche",1)	; le Fourgon met son clignotant � gauche
			; Chrysler (-20) roule � 20km/h(28) jusqu'� �tre � 6m derri�re le sujet (-1)
		JSQA Interdistance(-20,"mobile",-1,"mobile",60,"<=")
		ALLER ESSAI(96)
	FINSI
FIN	

;-------------------2RM14 (-105) d�passe par la droite le sujet (-1) � N3XN5 -------------------------

INSTRUCTION(960,96,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseRelative(-20,-1,FAUX,-200,0,0,VRAI,3)    
			; Chrysler (-20) roule � la m�me vitesse que le sujet (-1)
			; Cr�ation de la 2RM14(-105) sur la N3 (12) � 3m (30) derri�re le Chrysler (-20)
			; 2RM14 (-105) se trouve � 10m+10m (200) derri�re le sujet (-1) et elle d�boite vers la droite imm�diatement
			; 2RM14 (-105) suit la trajectoire 2besafe.v14 et roule � 10km/h (28).
			CreerMobile ("M1","M1",-105,"Asservi",14,VRAI,56,"N3",FAUX,10,VRAI,-30,-20,0)
			RegulerAxiale(-105,30,0,FAUX,20)	
			; la 2RM14 (-105) se d�calle dans la voie � droite de 3m(30) en d�passant � 20km/h(56)
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
			; Chrysler (-20) roule � la m�me vitesse que le sujet (-1)
			RegulerVitesseFixe(-105,138,0,FAUX,50)    
			; 2RM14(-105) acc�l�re jusqu'� 50km/h(138)
		JSQA Interdistance(-1,"mobile",-105,"mobile",50,">")	
		; 2RM14 (-105) se trouve � plus de 5m (50) devant le sujet (-1)				
		ALLER ESSAI(98)
	FINSI
FIN

INSTRUCTION(980,98,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseRelative(-20,-1,FAUX,-200,0,0,VRAI,3)    
			; Chrysler (-20) roule � la m�me vitesse que le sujet (-1)
			RegulerAxiale(-105,18,0,VRAI,5)	
			; 2RM14 (-105) se recentre dans la voie de droite en 2s apr�s avoir doubl� le sujet (-1)
			RegulerVitesseFixe(-105,138,0,VRAI,5) ; la 2RM14 (-105) acc�l�re pour atteindre 50km/h (138) en 5s.
		JSQA Position(-1,"mobile","N5",12986,VRAI,FAUX,">")
		; Sujet a tourn� � gauche sur la N5 apr�s avoir travers� le flot5 sur la N3
		; sujet (-1) se trouve sur N5 � 30m apr�s N5XN3: 1328.6-30=1298.6(12986)
		ALLER ESSAI(99)
	FINSI
FIN


;---------- 2RM15 (-106) arrive derri�re le sujet (-1) sur N5 et le d�passe --------------------

INSTRUCTION(990,99,FAUX,FAUX,VRAI,VRAI)
	SI OU(NumeroEssai(),Position(-1,"mobile","N5",12986,VRAI,FAUX,">"))
	; Sujet a tourn� � gauche sur la N5 apr�s avoir travers� le flot5 sur la N3
	; sujet (-1) se trouve sur N5 � 30m apr�s N5XN3: 1328.6-30=1298.6(12986)
		FAIRE
			RegulerVitesseFixe(-20,138,0,VRAI,5) 
			; le Chrysler (-20) acc�l�re pour atteindre 50km/h (138) en 5s.
			CreerMobile ("M1","M1",-106,"Asservi",15,VRAI,278,"N5",FAUX,-18,VRAI,200,-1,180)
			ChangerIndicateur(-106,VRAI,"phares",1)
			ChangerEnvMessage(5,"2RM15_N5",50,50,255,0,0)
			; Cr�ation 2RM15 (-106) � 20m (200) derri�re le sujet (-1), roulant en sens indirect sur la N5 (14) � 100 km/h (278). Trajectoire 2besafe.v15.
		JSQA Interdistance(-106,"mobile",-1,"mobile",110,"<=")	; le 2RM15(-106) se trouve � 11m (110) derri�re le sujet (-1)	
		ALLER ESSAI(100)
	FINSI
FIN

INSTRUCTION(1000,100,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-106,FAUX,"clignotant_gauche",1)
			RegulerVitesseRelative(-106,-1,FAUX,-200,0,28,VRAI,2)
			; la 2RM15(-106) acc�l�re en roulant � +10km/h par rapport au sujet (-1)
			RegulerAxiale(-106,16,0,VRAI,2)
			; la 2RM15(-106) se d�porte dans la voie de gauche en 2s
			SupprimerParNumero("mobile",-21)	; suppression Chrysler (-21) cr��e sur la N3
			SupprimerParNumero("mobile",-22)	; suppression de la ModusNoire (-22) cr��e sur N3
			SupprimerParNumero("mobile",-23)	; suppression de la GolfTex (-23) cr��e sur N3
			SupprimerParNumero("mobile",-24)	; suppression de la Chrysler (-24) cr��e sur N3
			SupprimerParNumero("mobile",-25)	; suppression de la Modus (-25) cr��e sur N3
			SupprimerParNumero("mobile",-105)	; suppression de la 2RM14 (-105) cr��e sur N3
			ChangerEnvMessage(5,"2RM2_B1",50,50,255,0,0)			
		JSQA Interdistance(-106,"mobile",-1,"mobile",-50,"<")	
		; le 2RM15(-106) se trouve � 5m (50) devant le sujet (-1)	
		ALLER ESSAI(101)
	FINSI
FIN


;------------------- Sujet (-1) tourne � gauche dans N5XB1--------------------------------
;-----------Sujet (-1) TAG et s'ins�re dans le Flot6 lat�ral Droit sur la B1 (17) -------
;---------------------2RM15 (-106) lat�ral gauche sur la B1 (17)-------------------------
;-------------Flot6: Cam (-11),MercedesTaxi (-12),2RM2 (-13),Smart (-14),806 (-15)----
;------------------ 1er v�hi---2�me v�hi-------3eme v�hi------4eme v�hi---5eme v�hi------


INSTRUCTION(1010,101,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-106,FAUX,"clignotant_gauche",1)
			RegulerAxiale(-106,-18,0,VRAI,2)
			; la 2RM15(-106) se d�porte dans la voie de droite en 2s
			RegulerVitesseFixe(-106,278,0,VRAI,8) 
			; le 2RM15(-106) acc�l�re pour atteindre 100km/h (278) en 8s.
		JSQA Position(-1,"mobile","N5",400,VRAI,FAUX,">")
		; sujet (-1) se trouve sur N5 � 40m avant N5XB1: 0+40=40(400)
		ALLER ESSAI(102)
	FINSI
FIN


INSTRUCTION(1020,102,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			CreerMobile ("PL3","M1",-11,"Asservi",05,VRAI,138,"B1",FAUX,18,FAUX,21662,0)
			; Cr�ation d'un Camion (-11) roulant en sens direct sur la B1 (17) � 50 km/h (138). Trajectoire 2besafe.v05.
			; le Camion (-11) � 60m de B1XN5:2226.2m,2226.2-60=2166.2m (21662)
			CreerMobile ("V3","M4",-12,"Asservi",05,VRAI,138,"B1",FAUX,18,VRAI,-550,-11,0)
			; Cr�ation MercedesTaxi (-12) roulant en sens direct sur la B1 � 50 km/h (138). MercedesTaxi est � 55 m (-550) derri�re le camion (-11).
			; MercedesTaxi (-12) suit la trajectoire 2besafe.v05 sur la B1
			CreerMobile ("M1","M1",-13,"Asservi",05,VRAI,138,"B1",FAUX,18,VRAI,-300,-12,0)
			ChangerIndicateur(-13,VRAI,"phares",1)
			; Cr�ation 2RM2 (-13) roulant en sens direct sur la B1 � 50 km/h (138). 2RM2 est � 30 m (-300) derri�re MercedesTaxi (-12) .
			; 2RM2 (-13) suit la trajectoire 2besafe.v05 sur la B1
			CreerMobile ("V1","M2",-14,"Asservi",05,VRAI,138,"B1",FAUX,18,VRAI,-1040,-13,0)
			; Cr�ation Smart (-14) roulant en sens direct sur la B1 � 50 km/h (138). Smart est � 124 m (-1040) derri�re ModusNoire (-13).
			; Smart (-14) suit la trajectoire 2besafe.v05 sur la B1
			CreerMobile ("V3","M2",-15,"Asservi",05,VRAI,138,"B1",FAUX,18,VRAI,-580,-14,0)
			; Cr�ation Toledo (-15) roulant en sens direct sur la B1 � 50 km/h (138). Smart est � 58 m (-580) derri�re la Smart (-14).
			; Toledo (-15) suit la trajectoire 2besafe.v05 sur la B1
		JSQA Position(-1,"mobile","B1",22342,VRAI,VRAI,">")
		; le sujet (-1) a d�marr� et est � 10m apr�s B1XN5: 2226.2m,2226.2+8=2234.2m (22342)
		ALLER ESSAI(103)
	FINSI
FIN

;-------------Evitement de collision lors de l'insertion du sujet dans le Flot6---------------
;-----------Flot6: Cam (-11),MercedesTaxi (-12),2RM2 (-13),Smart (-14),Toledo (-15)-----------
;----------------- 1er v�hi---2�me v�hi----3eme v�hi----4eme v�hi---5eme v�hi------------

INSTRUCTION(1030,103,FAUX,FAUX,VRAI,VRAI)
	SI ET(Interdistance(-1,"mobile",-11,"mobile",-70,">"),Position(-1,"mobile","B1",26262,VRAI,VRAI,"<"))
	 	; Sujet (-1) se trouve � moins de 7m (70) devant le cam(-10)
		; Sujet et camion roulent en sens direct donc Pk(-11)-Pk(-1)<0,crit�re d'interdistance n�gatif
		; Crit�re=-7m(-70)
		FAIRE
			RegulerVitesseRelative(-11,-1,FAUX,-200,0,-7,VRAI,2)
			; le camion (-11) ralentit puis roule � -4km/h (7) par rapport au sujet (-1) en restant � 20m (200) de distance
		JSQA Position(-1,"mobile","B1",26262,VRAI,VRAI,">")
		; le sujet (-1) est � 400m apr�s B1XN5: 2226.2m +400=2626.2(26262)
		ALLER COURANT
	FINSI
FIN

INSTRUCTION(1031,103,FAUX,FAUX,VRAI,VRAI)
	SI ET(Enchaine(1030),Interdistance(-1,"mobile",-11,"mobile",-70,"<="))	
	; le sujet ne s'ins�re pas devant le camion(-11) en �tant trop pr�s
	; Sujet (-1) se trouve � plus de 7m (70) devant le cam (-10)
		FAIRE
			NeRienFaire()
		JSQA Immediate()
		ALLER ESSAI(108)
	FINSI
FIN

INSTRUCTION(1040,104,FAUX,FAUX,VRAI,VRAI)	; Insertion du sujet(-1) devant la MercedesTaxi(-12)
	SI ET(Interdistance(-1,"mobile",-12,"mobile",-70,">"),Position(-1,"mobile","B1",26262,VRAI,VRAI,"<"))
	; Sujet (-1) se trouve � moins de 7m (70) devant la MercedesTaxi(-12)
		FAIRE
			RegulerVitesseRelative(-12,-1,FAUX,-200,0,-7,VRAI,2)
			; le MercedesTaxi (-12) ralentit puis roule � -4km/h (7) par rapport au sujet (-1) en restant � 20m (200) de distance
		JSQA Position(-1,"mobile","B1",26262,VRAI,VRAI,">")
		; le sujet (-1) est � 400m apr�s B1XN5: 2226.2m +400=2626.2(26262)
		ALLER COURANT
	FINSI
FIN

INSTRUCTION(1041,104,FAUX,FAUX,VRAI,VRAI)
	SI ET(Enchaine(1040),Interdistance(-1,"mobile",-12,"mobile",-70,"<="))	
	; le sujet ne s'ins�re pas devant la MercedesTaxi (-12) en �tant trop pr�s
	; Sujet (-1) se trouve � plus de 7m (70) devant RAV4Tex (-3)
		FAIRE
			NeRienFaire()
		JSQA Immediate()
		ALLER ESSAI(108)
	FINSI
FIN

INSTRUCTION(1050,105,FAUX,FAUX,VRAI,VRAI)	; Insertion du sujet(-1) devant la 2RM2(-13)
	SI ET(Interdistance(-1,"mobile",-13,"mobile",-70,">"),Position(-1,"mobile","B1",26262,VRAI,VRAI,"<"))
	; Sujet (-1) se trouve � moins de 7m (70) devant la 2RM2(-13)
		FAIRE
			RegulerVitesseRelative(-13,-1,FAUX,-200,0,-7,VRAI,2)
			; la 2RM2 (-13) ralentit puis roule � -4km/h (7) par rapport au sujet (-1) en restant � 20m (200) de distance
		JSQA Position(-1,"mobile","B1",26262,VRAI,VRAI,">")
		; le sujet (-1) est � 400m apr�s B1XN5: 2226.2m +400=2626.2(26262)
		ALLER COURANT
	FINSI
FIN

INSTRUCTION(1051,105,FAUX,FAUX,VRAI,VRAI)
	SI ET(Enchaine(1050),Interdistance(-1,"mobile",-13,"mobile",-70,"<="))	
	; le sujet ne s'ins�re pas devant la 2RM2(-13) en �tant trop pr�s
	; Sujet (-1) se trouve � plus de 7m (70) devant la 2RM2(-3)
		FAIRE
			NeRienFaire()	
		JSQA Immediate()
		ALLER ESSAI(108)
	FINSI
FIN

INSTRUCTION(1060,106,FAUX,FAUX,VRAI,VRAI)	; Insertion du sujet(-1) devant la Smart(-14)
	SI ET(Interdistance(-1,"mobile",-14,"mobile",-70,">"),Position(-1,"mobile","B1",26262,VRAI,VRAI,"<"))
	 	; Sujet (-1) se trouve � moins de 7m (70) devant la Smart(-4)
		FAIRE
			RegulerVitesseRelative(-14,-1,FAUX,-200,0,-7,VRAI,2)
			; la Smart(-14) ralentit puis roule � -4km/h (7) par rapport au sujet (-1) en restant � 20m (200) de distance
		JSQA Position(-1,"mobile","B1",26262,VRAI,VRAI,">")
		; le sujet (-1) est � 400m apr�s B1XN5: 2226.2m +400=2626.2(26262)
		ALLER COURANT
	FINSI
FIN

INSTRUCTION(1061,106,FAUX,FAUX,VRAI,VRAI)
	SI ET(Enchaine(1060),Interdistance(-1,"mobile",-14,"mobile",-70,"<="))	
	; le sujet ne s'ins�re pas devant la Smart(-14) en �tant trop pr�s
	; Sujet (-1) se trouve � plus de 7m (70) devant la Smart(-4)
		FAIRE
			NeRienFaire()	
		JSQA Immediate()
		ALLER ESSAI(108)
	FINSI
FIN

INSTRUCTION(1070,107,FAUX,FAUX,VRAI,VRAI)	; Insertion du sujet(-1) devant la Toledo(-15)
 	SI ET(Interdistance(-1,"mobile",-15,"mobile",-70,">"),Position(-1,"mobile","B1",26262,VRAI,VRAI,"<"))
	; Sujet (-1) se trouve � moins de 7m (70) devant la Toledo(-5)
		FAIRE
			RegulerVitesseRelative(-15,-1,FAUX,-200,0,-7,VRAI,2)
			; la Toledo (-15) ralentit puis roule � -4km/h (7) par rapport au sujet (-1) en restant � 20m (200) de distance
		JSQA Position(-1,"mobile","B1",26262,VRAI,VRAI,">")
		; le sujet (-1) est � 400m apr�s B1XN5: 2226.2m +400=2626.2(26262)
		ALLER COURANT
	FINSI
FIN

INSTRUCTION(1071,107,FAUX,FAUX,VRAI,VRAI)
	SI ET(Enchaine(1070),Interdistance(-1,"mobile",-15,"mobile",-70,"<="))	
	; le sujet ne s'ins�re pas devant la Toledo(-15) en �tant trop pr�s
	; Sujet (-1) se trouve � plus de 7m (70) devant la 806(-5)
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
			SupprimerParNumero("mobile",-106)	; supression de la 2RM15(-106) cr��e sur N5
			RegulerAxiale(-11,18,0,VRAI,3)	; le Camion(-11) se recentre dans la voie de droite en 2s
			RegulerAxiale(-12,18,0,VRAI,3)	; le MercedesTaxi (-12) se recentre dans la voie de droite en 2s
			RegulerAxiale(-13,18,0,VRAI,3)	; la 2RM2 (-13) se recentre dans la voie de droite en 2s
			RegulerAxiale(-14,18,0,VRAI,3)	; la Smart (-14) se recentre dans la voie de droite en 2s
			RegulerAxiale(-15,18,0,VRAI,3)	; la Toledo (-15) se recentre dans la voie de droite en 2s
		JSQA Position(-1,"mobile","B1",27262,VRAI,VRAI,">")
		; le sujet (-1) est � 500m apr�s B1XN5: 2226.2m + 500=2726.2(27262)
		ALLER ESSAI(109)
	FINSI
FIN

;------------------ Conduite Flot6 sur la B1 (17) jusqu'au rond point d3(18)----------------------
;-------------- Cam(-11),MercedesTaxi(-12),2RM2(-13),Smart(-14),arr�t Toledo(-15)-------------------

INSTRUCTION(1090,109,FAUX,FAUX,VRAI,VRAI)
	SI OU(NumeroEssai(),Position(-1,"mobile","B1",27272,VRAI,VRAI,">"))
	; le sujet (-1) est � 501m apr�s B1XN5: 2226.2m + 501=2727.2(27272)
		FAIRE
			RegulerVitesseFixe(-11,194,0,VRAI,8)	; acc�l�ration du Camion(-11) � 70km/h(194)
			RegulerVitesseFixe(-12,194,0,VRAI,8)	; acc�l�ration de la MercedesTaxi(-12) � 70km/h(194)
			RegulerVitesseFixe(-13,194,0,VRAI,8)	; acc�l�ration de la 2RM2(-13) � 70km/h(194)
			RegulerVitesseFixe(-14,194,0,VRAI,8)	; acc�l�ration de la smart (-14) � 70km/h(194)
			RegulerVitesseFixe(-15,0,0,VRAI,10)		; d�cc�l�ration de la Toledo (-15) � 0km/h(0)
			RegulerAxiale(-15,40,0,VRAI,5)			; Toledo(-15) s'arr�te sur le bas cot� de la B1(17)
			ChangerIndicateur(-13,VRAI,"warning",1)	; Allumage des warning de la 2RM2(-13) stationnaire 
		JSQA Position(-11,"mobile","B1",43467,VRAI,VRAI,">")	
		; le camion (-11) se trouve sur la B1(17) � 750m avant le rond-point d3(18)
		; Pk B1Xd3:5096.7m-750=4346.7(43467)
		ALLER ESSAI(110)
	FINSI
FIN

;----------------- Cam(-11),MercedesTaxi(-12),arr�t 2RM2(-13),Smart(-14)-------------------

INSTRUCTION(1100,110,FAUX,FAUX,VRAI,VRAI)
	SI OU(NumeroEssai(),Position(-1,"mobile","B1",27272,VRAI,VRAI,">"))
	; le sujet (-1) est � 501m apr�s B1XN5: 2226.2m + 501=2727.2(27272)
		FAIRE
			RegulerVitesseFixe(-11,194,0,VRAI,8)	; acc�l�ration du Camion(-11) � 70km/h(194)
			RegulerVitesseFixe(-12,194,0,VRAI,8)	; acc�l�ration de la MercedesTaxi(-12) � 70km/h(194)
			ChangerIndicateur(-13,VRAI,"clignotant_droit",1)	
			RegulerVitesseFixe(-13,0,0,VRAI,10)		; d�cc�l�ration de la 2RM2(-13) � 0km/h(0)
			RegulerAxiale(-13,40,0,VRAI,5)			; 2RM2(-13) s'arr�te sur le bas cot� de la B1(17)
			RegulerVitesseFixe(-14,194,0,VRAI,8)	; acc�l�ration de la smart (-14) � 70km/h(194)		
		JSQA Position(-11,"mobile","B1",44467,VRAI,VRAI,">")	
		; le camion (-11) se trouve sur la B1(17) � 450m avant le rond-point d3(18)
		; Pk B1Xd3:5096.7m-650=4446.7(44467)
		ALLER ESSAI(111)
	FINSI
FIN

;----------------- Cam(-11),arret MercedesTaxi(-12),arret Smart (-14) -------------------

INSTRUCTION(1110,111,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-11,194,0,VRAI,8)	; acc�l�ration du Camion(-11) � 70km/h(194)
			RegulerVitesseFixe(-12,0,0,VRAI,10)		; d�cc�l�ration de la MercedesTaxi(-12) � 0km/h(0)
			RegulerAxiale(-12,40,0,VRAI,10)			; Merc�d�sTaxi(-12) s'arr�te sur le bas cot� de la B1(17)
			ChangerIndicateur(-12,VRAI,"clignotant_droit",1)		
			RegulerVitesseFixe(-14,0,0,VRAI,10)		; d�cc�l�ration de la smart (-14) � 0km/h(0)
			RegulerAxiale(-14,40,0,VRAI,5)			; smart (-14) s'arr�te sur le bas cot� de la B1(17)
		JSQA Position(-11,"mobile","B1",47967,VRAI,VRAI,">")	
		; le camion (-11) se trouve sur la B1 � moins de 300m du rond-point d3(18)
		; Pk B1Xd3:5096.7m-300=4796.7(47967)
		ALLER ESSAI(112)
	FINSI
FIN

INSTRUCTION(1120,112 ,FAUX ,FAUX ,VRAI ,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-11,111,0,VRAI,5)	; d�cc�l�ration du Camion(-11) � 40km/h(111)
		JSQA Position(-11,"mobile","B1",50467,VRAI,VRAI,">")	
		; le camion (-11) se trouve sur la B1 � 50m avant le rond-point d3(18), Pk B1Xd3:5096.7m-50=5046.7(50467)
		ALLER ESSAI(113)
	FINSI
FIN

INSTRUCTION(1130,113,FAUX,FAUX ,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-11,70,0,VRAI,2)	; d�cc�l�ration du Camion(-11) � 25km/h(70)
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
			; Pompier (-103) cr�� sur D9 � 10m du rond point d3: D9Xd3:0m+10=10(100)
		JSQA Immediate()
		ALLER ESSAI(115)
	FINSI
FIN

;----------------N�gociation du rond-point d3 (18) par le camion (-11) -------------------------

INSTRUCTION(1150,115,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-11,40,0,VRAI,5)	; d�cc�l�ration du Camion(-11) � 15km/h(40)
		JSQA Position(-1,"mobile","d3",1126,VRAI,FAUX,">")	
		; le sujet(-1) se trouve sur le rond point d3(18) au niveau de la sortie D9, Pk d3XD9:112.6m (1126)
		ALLER ESSAI(117)
	FINSI
FIN


;-----------2RM16 (-105) lat�ral droit dans rond-point d3 (18) et qui stop avant le rond-point-----------
;-------------D�tection lat�rale Droite du 2RM16 (-105) � l'arr�t � l'entr�e d'un rond point-------------


INSTRUCTION(1170,117,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			CreerMobile ("M1","M1",-105,"Asservi",16,VRAI,110,"D2",FAUX,18,FAUX,107265,0)
			ChangerIndicateur(-105,VRAI,"phares",1)
			ChangerEnvMessage(5,"2RM16_D2",50,50,255,0,0)
			; Cr�ation 2RM16 (-105) roulant en sens direct sur la D2 (18) � la vitesse de 40km/h(110). 
			; 2RM16 cr�� � 80m du rond point: Pk D2Xd3:10806.5m-80=10726.5(107265)
			; 2RM16 (-105) suit la trajectoire 2besafe.v16
		JSQA Position(-105,"mobile","D2",107915,VRAI,VRAI,">")	
		; 2RM16(-105) se trouve sur la D2 � moins de 15m du rond-point d3(18)
		; Pk D2Xd3:10806.5m-15=10791.5(107915)
		ALLER ESSAI(118)
	FINSI
FIN

INSTRUCTION(1180,118,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-105,0,0,FAUX,80)	
			; arret de la 2RM16 sur la D2(18) quand elle est � moins de 6m du rond-point d3(18)
		JSQA Attente(9)
		; 2RM16 s'est arr�t� avant le rond-point d3(18)
		ALLER ESSAI(119)
	FINSI
FIN

INSTRUCTION(1190,119,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			NeRienFaire()
		JSQA Position(-1,"mobile","D2",106198,VRAI,FAUX,"<")
		; sujet (-1) se trouve sur D2(2) � Pk=10619.8m(106198)
		ALLER ESSAI(120)
	FINSI
FIN


;--------Supression du Flot6 et de la 2RM15,de la 2RM16 quand sujet (-1) sur N2 apr�s N2XN3---------
;----------Flot6: Cam (-11),MercedesTaxi (-12),2RM2 (-13),Smart (-14),806 (-15)------------------

INSTRUCTION(1200,120,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			SupprimerParNumero("mobile",-11)	; suppression du cam (-11) cr��e sur la B1
			SupprimerParNumero("mobile",-12)	; suppression de la MercedesTaxi (-12) cr��e sur B1
			SupprimerParNumero("mobile",-13)	; suppression de la 2RM2 (-13) cr��e sur B1
			SupprimerParNumero("mobile",-14)	; suppression de la Smart (-14) cr��e sur B1
			SupprimerParNumero("mobile",-15)	; suppression de la Toledo (-15) cr��e sur B1	
			SupprimerParNumero("mobile",-106)	; suppression de la 2RM15 (-106) cr��e sur B1
			SupprimerParNumero("mobile",-105)	; suppression de la 2RM16 (-105) cr��e sur D2
			SupprimerParNumero("mobile",-103)	; suppression des pompiers (-103) stationaire cr�� sur D9			
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
