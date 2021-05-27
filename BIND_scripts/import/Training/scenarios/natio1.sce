V4.6

fran�ais

commentaireManip= Manip training 1 2010 r�dig� par Joceline !! TACHE DE DETECTION NATIO1


nbreCoups= 251
numeroVhSujet= 0
autoriserHyperDepSgi= oui
lancerMdv= non
sautAleatoire= Oui

INSTRUCTION_VARIABLES()
	DECLARE(dist,ENTIER)
	DECLARE(vitflotdisparition,ENTIER)
	DECLARE(vitpropulsion,REEL)
	AFFECTE(vitflotdisparition,550) ; variable permettant de fixer la vitesse de d�gagement des flots apr�s d�passement ici 198 km/h
	AFFECTE(vitpropulsion,361) ; variable permettant de fixer la vitesse de propulsion des flots avant d�passement ici 130 km/h
FIN


INSTRUCTION(0,0,FAUX,FAUX,VRAI,VRAI)
	SI Immediate()
		FAIRE
			NeRienFaire()
		JSQA OU(Exterieure("B31"),Exterieure("F1"))
		;ALLER ESSAI(11)
		ALLER ESSAI(45)
	FINSI
FIN



;-------------------------------------------------------------------------------------------------------------------------------------------------------------------
;---- 2RM7 d�tection frontale derri�re chrysler sur N9, 2RM8 d�passe le sujet sur N9, 2RM9 d�tection lat�rale droite sur N4 ----------------------------------------
;------------------------- 2RM10 d�tection lat�rale droite au rond-point d6, 2RM11 d�tection frontale sur N10 ------------------------------------------------------
;----- pi�ton qui marche sur N9 sens indirect + 2RM20 sur N9 d�passe berlingo2 sur la voie oppos�e au sujet, 2RM22 stationnaire sur N10 ----------------------------
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------


;-------------------------- Red�marrage sur N9 dans le sens indirect � 2m apr�s l'intersection N9XN2-----------------------------------------------

INSTRUCTION(450,45,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerEnvMessage(5,"Contact_SVP_",50,50,255,0,0)
		JSQA Attente(2)
		ALLER ESSAI(46)
	FINSI
FIN

INSTRUCTION(460,46,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerEnvMessage(5,"NATIO1",50,50,255,0,0)
		JSQA Immediate()
		ALLER ESSAI(47)
	FINSI
FIN

INSTRUCTION(470,47,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerEnvMessage(5,"7*8*9*10*11*20*22",50,50,255,0,0)
		JSQA Position(-1,"mobile","N9",42359,VRAI,FAUX,">")	
		; le sujet a roul� et se trouve � plus de 40m de l'intersection N9XN2
		; Pk N9XN2=4275.9m,4275.9-40=4235.9m(42359)
		ALLER ESSAI(48)
	FINSI
FIN




;--------------------Trafic  sur la N9 roulant en sens oppos� par rapport au sujet---------------------------
;----------------- modus (-222),modusnoire (-3),AudiTT (-10) et 2RM7 (-105) espac� de 30m -------------------
;----------------------D�tection frontale 2RM7 (-105) derri�re un VL-----------------------------------------
;--------------------------- pi�ton qui marche sur N9 sens indirect------------------------------------------
;--------------------- D�tection frontale 2RM20 (-25) derri�re le berlingo2 qu'elle d�passera ---------------


INSTRUCTION(480,48,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			; Cr�ation 3 VL (-3,-222 et -10) roulent � 70km/h(194) sur la N9 dans le sens oppos� par rapport au sujet
			CreerMobile ("V2","M3",-3,"Asservi",07,VRAI,194,"N9",FAUX,18,FAUX,34000,0)	
			; modusnoire (-3) roulant � 70km/h (194) dans la voie de gauche,sur la N9 en sens direct 
		JSQA Immediate()
		ALLER ESSAI(49)
	FINSI
FIN


INSTRUCTION(490,49,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			CreerMobile ("C","M1",-222,"Asservi",07,VRAI,194,"N9",FAUX,18,FAUX,25000,0)	
			; berlingo2 (-222) roulant � 70km/h (194)dans la voie de gauche,sur la N9 en sens direct
			CreerMobile ("M1","M1",-25,"Asservi",07,VRAI,194,"N9",FAUX,18,FAUX,24900,0)	
			; 2RM20 (-25) roulant � 70km/h (194) dans la voie de gauche,sur la N9 en sens direct, � 10 m derri�re la berlingo2 (-222)
			ChangerIndicateur(-25,VRAI,"phares",1)
		JSQA Interdistance(-25,"mobile",-1,"mobile",5500,"<=")	; le 2RM20 (-25) se trouve � moins de 550m (4500) devant le sujet (-1)
		ALLER ESSAI(50)
	FINSI
FIN

INSTRUCTION(500,50,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			CreerObjet("passagePieton","N9",FAUX,-10,VRAI,-2000,90)		; Cr�ation du passage pi�ton sur N9 � 200m (-2000) devant le sujet qui roule en sens indirect sur la N9(29)
			ChangerEnvMessage(5,"Passage_Pieton_N9",50,50,255,0,0)	
		JSQA Immediate()
		ALLER ESSAI(51)
	FINSI
FIN


INSTRUCTION(510,51,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerEnvMessage(5,"Pieton_N9",50,50,255,0,0)			
			CreerPieton(0,0,-400,0,0,"homme","M1",20)		; pi�ton qui longe le bord droit de la route en remontant la N9 en sens indirect sur 40m(-400)
		JSQA Interdistance(-25,"mobile",-1,"mobile",2000,"<=")	; le 2RM20 (-25) se trouve � moins de 200m (2000) devant le sujet (-1)
		ALLER ESSAI(52)
	FINSI
FIN


INSTRUCTION(520,52,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-25,FAUX,"clignotant_gauche",1)
			RegulerVitesseRelative(-25,-222,FAUX,-200,0,56,VRAI,2)
			; la 2RM20(-25) acc�l�re en roulant � +20km/h(56)par rapport � la berlingo2 (-222)   
			RegulerAxiale(-25,0,0,VRAI,1)	; la 2RM20 (-25) se d�porte dans la voie de droite en 1s.
		JSQA Interdistance(-25,"mobile",-222,"mobile",50,">")	; le 2RM20 (-25) se trouve � 5m (50) devant la berlingo2 (-222)	
		ALLER ESSAI(53)
	FINSI
FIN

INSTRUCTION(530,53,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerAxiale(-25,18,0,VRAI,3)	; la 2RM20 (-25) se red�porte dans la voie de gauche en 3s devant la modus
			; Cr�ation VL (-10) et le 2RM7 (-105) roulent � 70km/h(194) sur la N9 dans le sens oppos� par rapport au sujet
			CreerMobile ("V3","M1",-10,"Asservi",07,VRAI,194,"N9",FAUX,18,FAUX,20000,0)	
			; AudiTT (-10) roulant � 70km/h (194) dans la voie de gauche,sur la N9 en sens direct
			CreerMobile ("M1","M1",-105,"Asservi",07,VRAI,194,"N9",FAUX,18,FAUX,19700,0)	
			; 2RM7 (-105) roulant � 70km/h (194) dans la voie de gauche,sur la N9 en sens direct
			ChangerIndicateur(-105,VRAI,"phares",1)
			ChangerEnvMessage(5,"2RM7_N9",50,50,255,0,0)
		JSQA Position(-1,"mobile","N9",22759,VRAI,FAUX,">")	; le sujet se trouve � plus de 2000m de l'intersection N9XN2
		; Pk N9XN2=4275.9m,42759-2000=2275.9m (22759)			
		ALLER ESSAI(54)
	FINSI
FIN

;------------------------Trafic surla N9 roulant dans le m�me sens que le sujet -------------------------------
;------------------------------Smart (-4) roulant lentement devant le sujet------------------------------------
;--------- D�tection sur les r�troviseurs du 2RM8 (-106) arrivant rapidement derri�re le sujet (-1)------------

INSTRUCTION(540,54,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			; Cr�ation d'une Smart (-4) roulant � 40 km/h(111) sur la N9 dans la m�me voie devant le sujet (-1)
			CreerMobile ("V1","M2",-4,"Asservi",08,VRAI,111,"N9",FAUX,-18,FAUX,16000,180) ; Smart (-4) roulant � 40km/h (111dm/s)  devant le sujet sur la N9 (Pk:1600m) en sens indirect
			; Cr�ation de la 2RM8(-106) roulant � 100km/h (278) sur la N9 dans la m�me voie derri�re le sujet (-1) � 100m (1000)
			CreerMobile ("M1","M1",-106,"Asservi",08,VRAI,278,"N9",FAUX,-18,VRAI,1000,-1,180)
			ChangerIndicateur(-106,VRAI,"phares",1)
			ChangerEnvMessage(5,"2RM8_N9",50,50,255,0,0)
			RegulerVitesseRelative(-106,-1,FAUX,-70,0,0,VRAI,7)    ; la 2RM8 (-106) rattrape le sujet (-1) en roulant plus vite jusqu'� ce qu'elle se retourve � 10 m (-70) derri�re le sujet		
		JSQA Interdistance(-106,"mobile",-1,"mobile",110,"<=")	; le 2RM8 (-106) se trouve � 11m (110) derri�re le sujet (-1)
		; sens indirect=> Pk(-106)-Pk(-1)est positif quand -106 arrive derri�re -1. + les 2 mobiles s'approchent,+ la valeur positive diminue=> condition <			
		ALLER ESSAI(55)
	FINSI
FIN

;------------------------------d�passement du sujet (-1) par la 2RM8 (-106)---------------------------------

INSTRUCTION(550,55,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-106,FAUX,"clignotant_gauche",1)
			RegulerVitesseRelative(-106,-1,FAUX,-200,0,28,VRAI,2)
			; la 2RM8 (-106) acc�l�re en roulant � +10km/h(28)par rapport au sujet (-1)   
			RegulerAxiale(-106,16,0,VRAI,2)	; la 2RM8 (-106) se d�porte dans la voie de gauche en 2s.
		JSQA Interdistance(-106,"mobile",-1,"mobile",-20,"<")	; le 2RM8 (-106) se trouve � 2m (20) devant le sujet (-1)			
		; sens indirect=> Pk(-106)-Pk(-1)est n�gatif quand -106 passe devant -1. + les 2 mobiles s'�loignent,+ la valeur n�gative augmente=> condition <
		ALLER ESSAI(56)
	FINSI
FIN

INSTRUCTION(560,56,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerAxiale(-106,-18,0,VRAI,2)	
			; la 2RM8 (-106) se d�porte dans la voie de droite en 2s apr�s avoir doubl� le sujet (-1)   
			; la 2RM8 (-106) rattrape la GolfTex (-4) en roulant plus vite jusqu'� ce qu'elle se retourve � 10 m (-70) derri�re elle
			ChangerIndicateur(-106,FAUX,"clignotant_gauche",1)
		JSQA Interdistance(-106,"mobile",-4,"mobile",220,"<=")	; le 2RM8 (-106) se trouve � 22m (220) derri�re la GolfTex (-4)
		; sens indirect=> Pk(-106)-Pk(-4)est positif quand -106 arrive derri�re -4. 
		ALLER ESSAI(57)
	FINSI
FIN

;-------------d�passement de la Smart (-4) par la 2RM8 (-106)----------

INSTRUCTION(570,57,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE   
			RegulerAxiale(-106,16,0,VRAI,2)	; la 2RM8 (-106) se d�porte dans la voie de gauche en 2s.
			ChangerIndicateur(-4,VRAI,"warning",1)
		JSQA Interdistance(-106,"mobile",-4,"mobile",-50,"<")	
		; le 2RM8 (-106) se trouve � 5m (50) devant la Smart (-4)		
		; sens indirect=> Pk(-106)-Pk(-4)est n�gatif quand -106 passe devant -4. + les 2 mobiles s'�loignent,+ la valeur n�gative augmente=> condition <
		ALLER ESSAI(58)
	FINSI
FIN

INSTRUCTION(580,58,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerAxiale(-106,-18,0,VRAI,2)
			; la 2RM8 (-106) se d�porte dans la voie de droite en 2s
		JSQA Attente(2)			
		ALLER ESSAI(59)
	FINSI
FIN

INSTRUCTION(590,59,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			NeRienFaire()
		JSQA Position(-106,"mobile","N9",300,VRAI,FAUX,">")	
		; le 2RM8 se trouve � moins de 30m de l'intersection N9XN4
		; Pk N9XN4=0m,0+30=30m (300)				
		ALLER ESSAI(60)
	FINSI
FIN

INSTRUCTION(600,60,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-106,55,0,VRAI,2)	
			; ralentissement de la 2RM08 (-106) � 20km/h(55) en 2s avant de tourner sur la N4(0)
		JSQA Attente(5)			
		ALLER ESSAI(61)
	FINSI
FIN

INSTRUCTION(610,61,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-106,55,0,VRAI,2)	
			; ralentissement de la 2RM08 (-106) � 20km/h(55) en 2s avant de tourner sur la N4(0)
		JSQA Position(-1,"mobile","N9",400,VRAI,FAUX,">")	
		; le sujet (-1) se trouve � moins de 40m de l'intersection N9XN4
		; Pk N9XN4=0m,0+40=40m (400)				
		ALLER ESSAI(62)
	FINSI
FIN


;---------------------- Supression de tout le trafic cr�� sur la N9 ------------------------

INSTRUCTION(620,62,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			SupprimerParNumero("mobile",-10)	; suppression de la AudiTT (-10) cr��e sur N9
			SupprimerParNumero("mobile",-222)	; suppression de la berlingo2 (-222) cr��e sur N9
			SupprimerParNumero("mobile",-25)	; suppression de la 2RM20 (-25) cr��e sur N9
			SupprimerParNumero("mobile",-3)	; suppression de la modusnoire (-3) cr��e sur N9
			SupprimerParNumero("mobile",-4)	; suppression de la Smart (-4) cr��e sur N9
			SupprimerParNumero("mobile",-105)	; suppression de la 2RM7 (-105) cr��e sur N9		
		JSQA Immediate()
		ALLER ESSAI(63)
	FINSI
FIN

;----------------- Trafic Lat�ral Droit sur N4XN9: Toledo (-11) et 2RM9 (-105) espac�es de 30m ------------------------ 
;-------------------- D�tection lat�rale droite du 2RM9 (-105) arrivant derri�re un Toledo (-11)-----------------------

INSTRUCTION(630,63,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			NeRienFaire()
		JSQA Position(-1,"mobile","N9",400,VRAI,FAUX,">")	
		; le sujet(-1) se trouve � moins de 40m (400) de l'intersection N9XB6
		; Pk N9XN4=0m,0+40=40m (400)	
		ALLER ESSAI(64)
	FINSI
FIN

INSTRUCTION(640,64,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			CreerMobile ("V3","M2",-11,"Asservi",09,VRAI,138,"N4",FAUX,18,FAUX,9737,0)
			; Cr�ation Toledo (-11) roulant en sens direct sur la N4 � 50 km/h (138)
			; Modif dans lepsi0.v09 Pk N4XN9:1023.7m,Toledo(-11) � 50m de N4XN9=1023.7-50=973.7m (9737)
			CreerMobile ("M1","M1",-105,"Asservi",09,VRAI,138,"N4",FAUX,18,VRAI,300,-11,0)
			ChangerIndicateur(-105,VRAI,"phares",1)
			ChangerEnvMessage(5,"2RM9_N4",50,50,255,0,0)
			; Cr�ation 2RM9 (-105) roulant en sens direct sur la N4 � 50 km/h (138)
			; 2RM9(-105) est � 30 m de Toledo.
			; Toledo (-11) et 2RM9 (-105) suivent la trajectoire 2besafe.v09 sur la N4
		JSQA Immediate()
		ALLER ESSAI(65)
	FINSI
FIN

INSTRUCTION(650,65,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			NeRienFaire()
		JSQA Position(-11,"mobile","N4",18457,VRAI,VRAI,">")	
		; Toledo (-11) qui se trouve sur la N4 est � moins de 30m (40) du rond-point d6(41)
		; Pk N4Xd6=1875.7m -30=1845.7(18457)
		ALLER ESSAI(66)
	FINSI
FIN

INSTRUCTION(660,66,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-11,69,0,VRAI,4)	; ralentissement du Toledo(-11) � 25km/h(69) en 2s sur la N4(0) avant d'entrer dans le rond-point d6(41)		
			RegulerAxiale(-11,18,0,VRAI,4)	; d�viation lat�rale pour �viter l'angle droit de l'axiale entre N4 et d6 en 2s
			RegulerVitesseFixe(-105,55,0,VRAI,4)	; ralentissement de la 2RM09 � 20km/h(55) en 2s sur la N4(0) � l'entr�e du rond-point d6(41)
			RegulerAxiale(-105,18,0,VRAI,2)
		JSQA Attente(4)
		ALLER ESSAI(67)
	FINSI
FIN

INSTRUCTION(670,67,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-11,42,0,VRAI,2)	; ralentissement du Toledo(-11) � 15km/h(42)
			SupprimerParNumero("mobile",-106)	; suppression de la 2RM8 (-106) cr��e sur N9
		JSQA Position(-1,"mobile","d6",3234,VRAI,FAUX,">")	
		; le sujet se trouve sur le rond point d6 apr�s le pk=323.4m(3234) 
		ALLER ESSAI(68)
	FINSI
FIN


;--------2RM10 (-106) arrivant sur le rond-point d6(41)par la N7 et qui stop pour c�der le passage au sujet (-1)----------


INSTRUCTION(680,68,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			CreerMobile ("M1","M1",-106,"Asservi",10,VRAI,110,"N7",FAUX,18,FAUX,66671,0)
			ChangerIndicateur(-106,VRAI,"phares",1)
			ChangerEnvMessage(5,"2RM10_N7",50,50,255,0,0)
			; Cr�ation 2RM10 (-106) roulant en sens direct sur la N7 � la vitesse 40km/h(110). 
			; 2RM10(-106) cr�� � 80m du rond point sur N7Xd6: 6817.1m-80=6737.1(67371) !!on le voit apparaitre arret� � l'intersectkl 
			; 2RM10(-106) cr�� � 80m du rond point sur N7Xd6: 6817.1m-150=6667.1(66671)
			; 2RM10 (-106) suit la trajectoire 2besafe.v10
		JSQA Position(-106,"mobile","N7",68021,VRAI,VRAI,">")	
		; 2RM10(-106) se trouve sur la N7 � moins de 15m du rond-point d6(41)
		; Pk N7Xd6=6817.1m -15=6802.1(68021)
		ALLER ESSAI(69)
	FINSI
FIN


INSTRUCTION(690,69,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-106,0,0,FAUX,80)	
			; arr�t de la 2RM10(-106) quand elle est � moins de 6m du rond-point d6(41)
		JSQA Position(-106,"mobile","N7",68071,VRAI,VRAI,">")	
		; 2RM10(-106) stoppe sur la N7 6m avant le rond-point d6(41)
		; Pk N7Xd6=6817.1m -6=6807.1(68071)
		ALLER ESSAI(70)
	FINSI
FIN

INSTRUCTION(700,70,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-106,0,0,FAUX,8)	
			; arret de la 2RM10 sur la N7(37) quand elle est � moins de 4m du rond-point d6(41)
		JSQA Position(-1,"mobile","N10",56424,VRAI,FAUX,">")
		; sujet(-1) se trouve sur la N10 150m apr�s le rond-point d6(41)
		; Pk N10Xd6=5792.4m-150=5642.4(56424)
		ALLER ESSAI(73)
	FINSI
FIN


INSTRUCTION(730,73,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			SupprimerParNumero("mobile",-11)	; suppression de la Toledo (-11)cr��e sur la N4
			SupprimerParNumero("mobile",-105)	; suppression de la 2RM9 (-205) cr��e sur N4
			SupprimerParNumero("mobile",-106)	; suppression de la 2RM10 (-106) cr��e sur N7		
		JSQA Position(-1,"mobile","N10",42062,VRAI,FAUX,">")
		; sujet(-1) se trouve � mi-chemin sur la N10: (5792.4m (Pk N10Xd6) - 2619.9m (Pk N10XN2))/2=1586.2m
		; 5792.4-1586.2=4206.2m(42062)
		ALLER ESSAI(74)
	FINSI
FIN



;-----------------Flot3: Trafic sur la N10 roulant en sens oppos� au sujet (-1)--------------------
;-----------------------Trafic en sens direct: Toledo (-4),GolfTex(-3),BusTex (-222)---------------
;--------- D�tection frontale de la 2RM11 (-105) roulant en sens direct sur N10 -------------------
;----------------------------- 2RM22(-106) sur N10 stationnaire sur le bord de la voie ------------

INSTRUCTION(740,74,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			CreerMobile ("PL3","M3",-222,"Asservi",11,VRAI,194,"N10",FAUX,18,FAUX,26249,0)
			; Cr�ation BusTex (-222) roulant en sens direct sur la N10 � 70 km/h (194)
			; BusTex suit la trajectoire lepsi0.v11 
			; Pk N10XN2:2619.9m,BustTex � 5m de N10XN2=2619.9+5=2624.9m (26249)
			CreerMobile ("V1","M4",-3,"Asservi",11,VRAI,220,"N10",FAUX,18,VRAI,1800,-222,0)
			; Cr�ation GolfTex (-3) roulant en sens direct sur la N10 � 80 km/h (220)
			; GolfTex est � 180 m devant le BusTex(-222).
			; GolfTex (-3) suit la trajectoire 2besafe.v11 sur la N10
			CreerMobile ("V3","M2",-4,"Asservi",11,VRAI,220,"N10",FAUX,18,VRAI,1500,-3,0)
			; Cr�ation Toledo (-4) roulant en sens direct sur la N10 � 80 km/h (220).Toledo est � 150 m devant GolfTex.
			; Toledo (-4) suit la trajectoire 2besafe.v11 sur la N10
			CreerMobile ("M1","M1",-105,"Asservi",11,VRAI,138,"N10",FAUX,18,VRAI,5000,-4,0)
			; Cr�ation 2RM11 (-105) roulant en sens direct sur la N10 � 50 km/h (138)
			; 2RM11(-105) est � 500 m (5000) devant Toledo(-4).
			; 2RM11(-105) suit la trajectoire 2besafe.v11 sur la N10.
			ChangerIndicateur(-105,VRAI,"phares",1)
			ChangerEnvMessage(5,"2RM11_N10",50,50,255,0,0)	
			CreerMobile ("V3","M3",-5,"Asservi",18,VRAI,278,"N10",FAUX,-18,VRAI,1000,-1,180)
			; Cr�ation de la BMW(-5) roulant � 100km/h (278) sur la N10 en sens indirect dans la m�me voie 	derri�re le sujet (-1) � 100m (1000)
			; BMW(-5) suit la trajectoire 2besafe.v18 sur la N10.
			RegulerVitesseRelative(-5,-1,FAUX,-70,0,0,VRAI,6)
			; la BMW(-5) rattrape le sujet(-1) en roulant plus vite jusqu'� ce qu'elle se retrouve � 7 m (-70) derri�re le sujet	
			ChangerEnvMessage(5,"2RM22_N10",50,50,255,0,0)
			CreerMobile("M1","M1",-106,"Asservi",-1,VRAI,0,"N10",FAUX,-35,FAUX,26799,180)
			; Cr�ation de la 2RM22(-106) stationnaire sur le bas c�t� sur la N10,trajectoire -1
			; 2RM22(-105) est � 60m avant N10XN2: Pk N10XN2=2619.9m+60=2679.9(26799)			
		JSQA Interdistance(-5,"mobile",-1,"mobile",130,"<=")	; le  BMW(-5) se trouve � 11m (110) derri�re le sujet (-1)
		; sens indirect=> Pk(-1)- Pk(-5) est positif quand -5 arrive derri�re -1. + les 2 mobiles s'approchent,+ la valeur positive diminue=> condition <			
		ALLER ESSAI(75)
	FINSI
FIN
		
;------------------------------d�passement du sujet(-1) par la BMW(-5)---------------------------------

INSTRUCTION(750,75,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseRelative(-5,-1,FAUX,-200,0,28,VRAI,2) 
			; la BMW(-5) acc�l�re en roulant � +10km/h(28)par rapport au sujet (-1)   
			RegulerAxiale(-5,16,0,VRAI,2)	
			; la BMW(-5) se d�porte dans la voie de gauche en 2s
			ChangerIndicateur(-5,FAUX,"clignotant_gauche",1)
		JSQA Interdistance(-5,"mobile",-1,"mobile",-50,"<")	; le BMW(-5) se trouve � 5m (50) devant le sujet (-1)		
		; sens indirect=> Pk(-105)-Pk(-1)est n�gatif quand -106 passe devant -1. + les 2 mobiles s'�loignent,+ la valeur n�gative augmente=> condition <
		ALLER ESSAI(76)
	FINSI
FIN

INSTRUCTION(760,76,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-106,VRAI,"warning",1)	; Allumage des warning de la 2RM22(-106) stationnaire sur la N10
			RegulerAxiale(-5,-18,0,VRAI,2)	
			; la BMW(-5) se d�porte dans la voie de droite en 2s apr�s avoir doubl� le sujet(-1)
			RegulerVitesseFixe(-5,278,0,VRAI,5)	
			; acc�l�ration de la BMW(-5) � 100km/h(278) en 5s apr�s d�passement du sujet(-1)
		JSQA Position(-1,"mobile","N10",26999,VRAI,FAUX,">")
		; Pk N10XN2=2619.9m+80=2699.9(26999), le sujet (-1) est � 80m avant N10XN2
		ALLER ESSAI(77)
	FINSI
FIN


INSTRUCTION(770,77,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-5,69,0,VRAI,8)		; ralentissement de la BMW � 25 km/h(69) avant de tourner sur la N2
			SupprimerParNumero("mobile",-222)		; suppression du BusTex (-222)cr��e sur la N10
			SupprimerParNumero("mobile",-3)			; suppression de la GolfTex (-3) cr��e sur N10
			SupprimerParNumero("mobile",-4)			; suppression de la Toledo (-4) cr��e sur N10
			SupprimerParNumero("mobile",-5)			; suppression de la BMW (-5) cr��e sur N10
			SupprimerParNumero("mobile",-105)		; suppression de la 2RM11 (-105) cr��e sur N10	
		JSQA Attente(8)
		ALLER ESSAI(250)
	FINSI
FIN



;---------------------------------------------------------------------
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
