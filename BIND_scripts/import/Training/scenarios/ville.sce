V4.6

fran�ais

commentaireManip= Manip 2BeSafe 2009 r�dig� par Joceline Juin 2009 !! TACHE D'ACCEPTATION DE GAPS VILLE

; Flot7 avec 2RMS,Flot8 avec 2RMS ,Flot9 avec 2RMS ,Flot10 avec 2RMS ,Flot11 avec 2RMS ,Flot12 avec 2RMS 

nbreCoups= 501
numeroVhSujet= 0
autoriserHyperDepSgi= oui
lancerMdv= non
sautAleatoire= Oui

INSTRUCTION_VARIABLES()
	DECLARE(dist,ENTIER)
	AFFECTE(dist,0) ; variable permettant de fixer une distance
FIN

;--------Red�marrage sur D2(2) dans le sens indirect � 10m apr�s le rond-point d3 (18) ---------

;	le sujet (-1) est sur D2(2) en sens indirect � 10m apr�s le rond-point d3(18): 10806.5m-10=10796.5(107965) dans 2besafe.vp

;-----------------------------------------------------------------------------------------------


;---------- Cr�ation du li�vre (berlingo,-1000) devant le sujet (-1) -------------------

INSTRUCTION(0,0,FAUX,FAUX,VRAI,VRAI)
	SI Immediate()
		FAIRE
			CreerMobile ("C","M1",-1000,"Asservi",999,VRAI,0,"D2",FAUX,-58,FAUX,107665,180)
			ChangerEnvMessage(5,"VILLE",50,50,255,0,0)
			; Le li�vre -1000(berlingo2) suit la trajectoire 2besafe.v999
			; le li�vre (1000) est � l'arr�t sur le bas c�t� de D2(2)
			; le li�vre (1000) est � 20m apr�s le rond-point d3(18): 10806.5m-40= 10766.5(107665) 
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
			ChangerEnvMessage(5,"7*8*9*10*11*12",50,50,255,0,0)
		JSQA Immediate()
		ALLER ESSAI(3)
	FINSI
FIN


;---------------------------------------------------------------------------------------
;---------------------------------- D�but t�che de suivi du li�vre ---------------------

INSTRUCTION(30,3,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerAxiale(-1000,-50,0,FAUX,50)
			; li�vre(-1000) se d�porte vers le centre de la voie de gauche sur D2
			RegulerVitesseFixe(-1000,138,0,FAUX,300)	
			;li�vre (-1000) roule � 50 km/h (138)
		JSQA Position(-1000,"mobile","D2",100205,VRAI,FAUX,">")
		; Pk D2XD12=9970.5m+50=10020.5(100205),le li�vre (-1000) est � 50m avant D2XD12(9)
		ALLER ESSAI(198)
	FINSI
FIN



;----------------------------------------------------------------------------------------------------------
;-------------------------- D�but Estimation n�1 des GAPS: flot7 ------------------------------------------
;------------ Sujet sur D2(2) traverse le flot7 lat�ral gauche sur D12(9) au niveau de D2XD12--------------

INSTRUCTION(1980,198,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			EvenementSonore(0,1,VRAI)
			RegulerVitesseFixe(-1000,69,0,FAUX,100)
			; li�vre(-1000) ralentit et roule � 25 km/h(69)
		JSQA Position(-1,"mobile","D2",100205,VRAI,FAUX,">")
		; le sujet (-1) est � � 50m avant D2XD12(9): 9970.5m+50=10020.5(100205)
		ALLER ESSAI(199)
	FINSI
FIN

;--------- Flot 7 en ville lat�ral gauche sur D12 (9) en sens indirect avec 2RMs  ----------
;------------------ CitroenC4(-10),Moto1 (-222),C4Noire(-4),Moto2(-5) ----------------------------
;------- 1er VL ----- 1�re moto pour gap risqu� -- 2eme VL ---- 2�me moto pour gap s�curis� ------
;------------- Sujet (-1) traverse le flot 7 pour continuer tout droit sur la D2(2)---------------


INSTRUCTION(1990,199,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerEnvMessage(5,"Flot7",50,50,255,0,0)
			CreerMobile ("V2","M1",-10,"Asservi",70,VRAI,69,"D12",FAUX,-48,FAUX,13167,180)
			; Cr�ation CitroenC4 (-10) sur la D12(9) roulant en sens indirect � 25 km/h(69)
			; trajectoire 2besafe.v70,CitroenC4 � 80m de D12XD2=1236.7+80m=1316.7m (13167)
			CreerMobile ("M1","M1",-222,"Asservi",70,VRAI,69,"D12",FAUX,-48,VRAI,700,-10,180)
			; Cr�ation Moto1(-222) roulant en sens indirect sur la D12(9) � 25 km/h(69)
			; Moto1(-222)  se trouve � 70 m derri�re la CitroenC4(-10)
			; Moto1(-222) suit la trajectoire 2besafe.v70 sur la D12(9)
			CreerMobile ("V2","M4",-4,"Asservi",70,VRAI,69,"D12",FAUX,-48,VRAI,100,-222,180)
			; Cr�ation C4Noire(-4) roulant en sens indirect sur la D12 � 25 km/h (69)
			; C4Noire (-4) est � 10 m derri�re la Moto1(-222).
			; C4Noire (-4) suit la trajectoire 2besafe.v70 sur la D12.
			CreerMobile ("M1","M1",-5,"Asservi",70,VRAI,69,"D12",FAUX,-48,VRAI,700,-4,180)
			; Moto2(-5)  se trouve � 70 m derri�re la C4Noire(-4)
			; Moto2(-5) suit la trajectoire 2besafe.v70 sur la D12(9)			
	 	JSQA Immediate()
		ALLER ESSAI(200)
	FINSI
FIN

INSTRUCTION(2000,200,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-222,VRAI,"phares",1)
	 	JSQA Immediate()
		ALLER ESSAI(201)
	FINSI
FIN

INSTRUCTION(2010,201,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-5,VRAI,"phares",1)
	 	JSQA Immediate()
		ALLER ESSAI(203)
	FINSI
FIN

INSTRUCTION(2030,203,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,69,0,FAUX,100)
			; li�vre(-1000) ralentit et roule � 25 km/h(69)
		JSQA Position(-1000,"mobile","D2",99505,VRAI,FAUX,">")
		; le li�vre (-1000) est � 20m apr�s D2XD12(9): 9970.5m-20=9950.5(99505)	
		ALLER ESSAI(204)
	FINSI
FIN

INSTRUCTION(2040,204,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			EvenementSonore(0,1,FAUX)
			RegulerVitesseFixe(-1000,0,0,FAUX,100)
			; li�vre(-1000) s'arr�te
		JSQA Position(-1000,"mobile","D2",99410,VRAI,FAUX,">")
		;le li�vre (-1000) s'arr�te 19.5m apr�s D2XD12(9): 9970.5m-29.5=9941.0(99410)	
		ALLER ESSAI(205)
	FINSI
FIN

INSTRUCTION(2050,205,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-1000,FAUX,"warning",1)
			RegulerVitesseFixe(-1000,0,0,FAUX,50)
			; li�vre(-1000) met ses warnings
		JSQA Position(-1,"mobile","D2",99675,VRAI,FAUX,">")
		; le sujet (-1) est � 3m apr�s D2XD12(9): 9970.5m-3=9967.5(99675) 
		; le sujet(-1) est � 26.5m du li�vre(-1000)				
		ALLER ESSAI(206)
	FINSI
FIN

;------------------------------Fin Estimation n�1 des GAPS: flot 7 -----------------------------
;-----------------------------------------------------------------------------------------------

INSTRUCTION(2060,206,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,138,0,FAUX,200)	
			;li�vre (-1000) roule � 50 km/h (138)
		JSQA Position(-1000,"mobile","D2",88882,VRAI,FAUX,">")
		; le li�vre (-1000) est � 50m avant D2XD11(8): 8838.2+50=8888.2(88882)
		ALLER ESSAI(207)
	FINSI
FIN


;-------------------- Supression du flot7 -----------------------------
INSTRUCTION(2070,207,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			SupprimerParNumero("mobile",-10)	; suppression du CitroenC4(-10) cr��e sur la D12(9)
			SupprimerParNumero("mobile",-222)	; suppression de la Moto1 (-222) cr��e sur la D12(9)
			SupprimerParNumero("mobile",-4)		; suppression de la C4Noire (-4) cr��e sur la D12(9)
			SupprimerParNumero("mobile",-5)		; suppression de la Moto2 (-5) cr��e sur la D12(9)
		JSQA Immediate()
		ALLER ESSAI(208)
	FINSI
FIN

INSTRUCTION(2080,208,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,69,0,FAUX,200)	
			ChangerIndicateur(-1000,FAUX,"clignotant_droit",1)
			;li�vre (-1000) ralentit � 25 km/h (69) et tourne � droite sur la D11(8)
		JSQA Position(-1,"mobile","D11",12144,VRAI,FAUX,">")
		; le sujet (-1) est � 10m apr�s D11XD2(8): 1224.4-10=1214.4(12144)
		ALLER ESSAI(209)
	FINSI
FIN

;----------------- Flot 8 en ville lat�rale droit sur D16 (23) avec 2RMs  ------------------------
;--------------------- CitroenC4(-12),Moto1 (-13),C4Noire(-15),Moto3(-20) ------------------------------
;---------- 1er VL ----- 1�re moto pour gap risqu� -- 2eme VL ---- 2�me moto pour gap s�curis� ---------
;------------- Sujet (-1) traverse le flot 8 pour continuer tout droit sur la D11(8)--------------------

INSTRUCTION(2090,209,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,138,0,FAUX,300)
			; li�vre(-1000) accc�l�re sur la D11(8) et roule � 50 km/h(138)
		JSQA Position(-1000,"mobile","D11",7478,VRAI,FAUX,">")
		; le li�vre(-1000) est � 50m avant D11XD16(23): 697.8m+50=747.8(7478)
		ALLER ESSAI(210)
	FINSI
FIN

INSTRUCTION(2100,210,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,69,0,FAUX,100)
			EvenementSonore(0,1,VRAI)
			; li�vre(-1000) ralentit � 25 km/h(69) sur D11 (8) en sens indirect
		JSQA Position(-1,"mobile","D11",7478,VRAI,FAUX,">")
		; le sujet(-1) est � 50m avant D11XD16(23): 697.8m+50=747.8(7478)
		ALLER ESSAI(211)
	FINSI
FIN

;---------------------------------------------------------------------------------------------------------------
;-------------------------------- D�but Estimation n�2 des GAPS: flot 8  ---------------------------------------
;------------- Sujet sur D11(8) traverse le flot8 lat�ral droit sur D16(23) au niveau de D11XD16----------------

INSTRUCTION(2110,211,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerEnvMessage(5,"Flot8",50,50,255,0,0)
			CreerMobile ("V2","M1",-12,"Asservi",80,VRAI,69,"D16",FAUX,18,FAUX,2209,0)
			; Cr�ation CitroenC4(-12) roulant en sens direct sur la D16(23) � 25 km/h(69)
			; trajectoire 2besafe.v80,CitroenC4 � 80m de D16XD11=300.9-80m=220.9m (2209)
			CreerMobile ("M1","M1",-13,"Asservi",80,VRAI,69,"D16",FAUX,18,VRAI,-700,-12,0)
			; Cr�ation Moto1(-13) roulant en sens direct sur la D16(23) � 25 km/h(69)
			; Moto1(-13)  se trouve � 70 m derri�re la CitroenC4(-12)
			; Moto1(-13) suit la trajectoire 2besafe.v80 sur la D16(23)
			CreerMobile ("V2","M4",-15,"Asservi",80,VRAI,69,"D16",FAUX,18,VRAI,-100,-13,0)
			; Cr�ation C4Noire(-15) roulant en sens indirect sur la D16(23) � 25 km/h (69)
			; C4Noire(-15) est � 10 m derri�re la Moto1(-13)
			; C4Noire(-15) suit la trajectoire 2besafe.v80 sur la D12.
			CreerMobile ("M1","M1",-20,"Asservi",80,VRAI,69,"D16",FAUX,18,VRAI,-700,-15,0)
			; Moto2(-20)  se trouve � 70 m derri�re la C4Noire(-15)
			; Moto2(-20) suit la trajectoire 2besafe.v80 sur la D16(23)		
	 	JSQA Immediate()
		ALLER ESSAI(212)
	FINSI
FIN

INSTRUCTION(2120,212,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-13,VRAI,"phares",1)
	 	JSQA Immediate()
		ALLER ESSAI(214)
	FINSI
FIN

INSTRUCTION(2140,214,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-20,VRAI,"phares",1)
	 	JSQA Immediate()
		ALLER ESSAI(216)
	FINSI
FIN			

INSTRUCTION(2160,216,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,69,0,FAUX,100)
			; le li�vre(-1000) roule � 25km/h(69) sur D11 en sens indirect
			ChangerIndicateur(-21,VRAI,"phares",1)
		JSQA Position(-1000,"mobile","D11",6778,VRAI,FAUX,">")
		; le li�vre(-1000) est sur D11 � 10m apr�s D11XD16(23): 697.8m-20=677.8(6778)		
		ALLER ESSAI(217)
	FINSI
FIN

INSTRUCTION(2170,217,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			EvenementSonore(0,1,FAUX)
			RegulerVitesseFixe(-1000,0,0,FAUX,100)
			; li�vre(-1000) s'arr�te
		JSQA Position(-1000,"mobile","D11",6683,VRAI,FAUX,">")
		; le li�vre(-1000) s'arr�te sur D11 en sens indirect � 29.5m apr�s D11XD16(23): 697.8m-29.5=668.8(6683)	
		ALLER ESSAI(218)
	FINSI
FIN

;------------------------------Fin Estimation n�2 des GAPS: flot 8 -----------------------------
;-----------------------------------------------------------------------------------------------

INSTRUCTION(2180,218,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,0,0,FAUX,50)
			ChangerIndicateur(-1000,VRAI,"warning",1)
			; li�vre(-1000) met ses warnings
		JSQA Position(-1,"mobile","D11",6948,VRAI,FAUX,">")
		; le sujet (-1) est sur D11 � 3m apr�s D11XD10(7):697.8m-3=694.8(6948)
		; le sujet(-1) est � 26.5m du li�vre(-1000)
		ALLER ESSAI(219)
	FINSI
FIN

;------------------------------Fin Estimation n�2 des GAPS: flot 8 -----------------------------
;-----------------------------------------------------------------------------------------------

INSTRUCTION(2190,219,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-1000,VRAI,"warning",0)
			RegulerVitesseFixe(-1000,138,0,FAUX,200)
			; le li�vre roule � 50 km/h (138)
		JSQA Position(-1000,"mobile","D11",2906,VRAI,FAUX,">")
		; le li�vre (-1000) est � 50m avant D11XD10(7): 240.6m+50=290.6(2906)	
		ALLER ESSAI(220)
	FINSI
FIN

;-------------------------- Supression du flot 8--------------------------------------
INSTRUCTION(2200,220,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			SupprimerParNumero("mobile",-12)	; suppression du CitroenC4(-12) cr��e sur la D16(23)
			SupprimerParNumero("mobile",-13)	; suppression de la Moto1 (-13) cr��e sur la D16(23)
			SupprimerParNumero("mobile",-15)	; suppression de la C4Noire (-15) cr��e sur la D16(23)
			SupprimerParNumero("mobile",-20)	; suppression de la Moto2 (-20) cr��e sur la D16(23)	
		JSQA Immediate()
		ALLER ESSAI(221)
	FINSI
FIN


INSTRUCTION(2210,221,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,69,0,FAUX,100)
			ChangerIndicateur(-1000,FAUX,"clignotant_droit",1)
			;li�vre (-1000) d�cc�l�re � 25 km/h(69) et tourne � droite sur D10 en sens indirect
		JSQA Position(-1,"mobile","D10",7215,VRAI,FAUX,">")
		; le sujet(-1) est sur D10 � 10m apr�s D10XD2: 731.5-10=721.5(7215)
		ALLER ESSAI(222)
	FINSI
FIN

INSTRUCTION(2220,222,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,138,0,FAUX,300)	
			;li�vre (-1000) acc�l�re jusqu'� 50 km/h(138) sur D10(7) en sens indirect
		JSQA Position(-1000,"mobile","D10",6782,VRAI,FAUX,">")
		; le li�vre (-1000) est sur D10 � 50m avant D10XD2: 628.2+50=678.2(6782)
		ALLER ESSAI(223)
	FINSI
FIN

INSTRUCTION(2230,223,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,69,0,FAUX,100)	
			;li�vre (-1000) d�cc�l�re jusqu'� 25 km/h(69) sur D10(7) en sens indirect
		JSQA Position(-1,"mobile","D10",6182,VRAI,FAUX,">")
		; le sujet (-1) est sur D10 � 10m apr�s D10XD2: 628.2-10=618.2(6182)
		ALLER ESSAI(224)
	FINSI
FIN

;---------------------------------------------------------------------------------------------------------------
;-----------------------------------D�but Estimation n�3 des GAPS: flot 9 --------------------------------------
;---- Sujet sur D10(7) en sens indirect s'ins�re dans le flot9 lat�ral gauche sur D1(33) au niveau de D10XD1 ---

INSTRUCTION(2240,224,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,138,0,FAUX,300)	
			;li�vre (-1000) acc�l�re jusqu'� 50 km/h(138) sur D10(7) en sens indirect
		JSQA Position(-1000,"mobile","D10",4421,VRAI,FAUX,">")
		; le li�vre (-1000) est sur D10 � 50m avant D10XD1: 392.1+50=442.1(4421)
		ALLER ESSAI(225)
	FINSI
FIN

INSTRUCTION(2250,225,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			EvenementSonore(0,1,VRAI)
			RegulerVitesseFixe(-1000,69,0,FAUX,100)
			ChangerIndicateur(-1000,FAUX,"clignotant_droit",1)
			; li�vre(-1000) d�cc�l�re � 25 km/h(69) et tourne � droite sur D1(33) en sens direct
		JSQA Position(-1,"mobile","D10",4421,VRAI,FAUX,">")
		; le sujet (-1) est sur D10 � 50m avant D10XD1: 392.1+50=442.1(4421)
		ALLER ESSAI(226)
	FINSI
FIN


;------------------ Flot 9 en ville lat�rale gauche sur D1 (33) avec 2RMs  -----------------------
;---------------------- CitroenC4(-10),Moto1 (-222), C4Noire(-4),Moto3(-5)------------------------------
;----------- 1er VL ----- 1�re moto pour gap risqu� -- 2eme VL ---- 2�me moto pour gap s�curis� --------
;-------- Sujet (-1) sur la D10(7) s'ins�re dans le flot 9 pour continuer � droite sur la D1(33)--------

INSTRUCTION(2260,226,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerEnvMessage(5,"Flot9",50,50,255,0,0)
			CreerMobile ("V2","M1",-10,"Asservi",90,VRAI,69,"D1",FAUX,18,FAUX,33272,0)
			; Cr�ation CitroenC4(-10) roulant en sens direct sur la D1(33) � 25 km/h(69)
			; trajectoire 2besafe.v90,CitroenC4 � 150m de D1XD10=3477.2-150m=3327.2m (33272)
			CreerMobile ("M1","M1",-222,"Asservi",90,VRAI,69,"D1",FAUX,18,VRAI,-700,-10,0)
			; Cr�ation Moto1(-222) roulant en sens direct sur la D1(33) � 25 km/h(69)
			; Moto1(-222)  se trouve � 70 m derri�re la CitroenC4(-10)
			; Moto1(-222) suit la trajectoire 2besafe.v90 sur la D1(33)
			CreerMobile ("V2","M4",-4,"Asservi",90,VRAI,69,"D1",FAUX,18,VRAI,-100,-222,0)
			; Cr�ation C4Noire(-4) roulant en sens indirect sur la D1(33) � 25 km/h (69)
			; C4Noire(-4) est � 10 m derri�re la Moto1(-222)
			; C4Noire(-4) suit la trajectoire 2besafe.v90 sur la D1(33)
			CreerMobile ("M1","M1",-5,"Asservi",90,VRAI,69,"D1",FAUX,18,VRAI,-700,-4,0)
			; Moto2(-5)  se trouve � 70 m derri�re la C4Noire(-15)
			; Moto2(-5) suit la trajectoire 2besafe.v90 sur la D1(33)		
	 	JSQA Immediate()
		ALLER ESSAI(227)
	FINSI
FIN

INSTRUCTION(2270,227,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-222,VRAI,"phares",1)
	 	JSQA Immediate()
		ALLER ESSAI(228)
	FINSI
FIN

INSTRUCTION(2280,228,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-5,VRAI,"phares",1)
	 	JSQA Immediate()
		ALLER ESSAI(230)
	FINSI
FIN

INSTRUCTION(2300,230,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,69,0,FAUX,100)
			ChangerIndicateur(-1000,FAUX,"clignotant_droit",1)
			; li�vre(-1000) d�cc�l�re � 25 km/h(69) et tourne � droite sur D1(33) en sens direct
		JSQA Position(-1,"mobile","D1",35472,VRAI,VRAI,">")
		; le sujet (-1) s'ins�re dans le flot 9 et se trouve � 70m apr�s D1XD10: 3477.2m+70=3547.2(35472)
		ALLER ESSAI(231)
	FINSI
FIN

INSTRUCTION(2310,231,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			EvenementSonore(0,1,FAUX)
			RegulerVitesseFixe(-1000,138,0,FAUX,300)
			RegulerAxiale(-1000,18,0,FAUX,200)
			ChangerIndicateur(-1000,FAUX,"clignotant_gauche",1)
			;li�vre(-1000) acc�l�re � 50 km/h(138) et se d�porte dans la voie de gauche sur D1(33) en sens direct
			RegulerVitesseFixe(-10,138,0,FAUX,300)
			RegulerAxiale(-10,45,0,FAUX,200)
			RegulerVitesseFixe(-222,138,0,FAUX,300)
			RegulerAxiale(-222,45,0,FAUX,200)
			RegulerVitesseFixe(-4,138,0,FAUX,300)
			RegulerAxiale(-4,45,0,FAUX,200)
			RegulerVitesseFixe(-5,138,0,FAUX,300)
			RegulerAxiale(-5,45,0,FAUX,200)
			; le flot 9 acc�l�re � 50km/h(138) et se met dans la voie de droite
		JSQA Position(-1000,"mobile","D1",38785,VRAI,VRAI,">")	
		; le li�vre(-1000) est � 50m avant D1XD8: 3928.5-50=3878.5(38785)		
		ALLER ESSAI(232)
	FINSI
FIN

INSTRUCTION(2320,232,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,69,0,FAUX,400)
			RegulerAxiale(-1000,18,0,FAUX,200)
			ChangerIndicateur(-1000,FAUX,"clignotant_gauche",1)
			;li�vre(-1000) acc�l�re � 50 km/h(138) et se d�porte dans la voie de gauche sur D1(33) en sens direct
			RegulerVitesseFixe(-10,138,0,FAUX,300)
			RegulerAxiale(-10,45,0,FAUX,200)
			RegulerVitesseFixe(-222,138,0,FAUX,300)
			RegulerAxiale(-222,45,0,FAUX,200)
			RegulerVitesseFixe(-4,138,0,FAUX,300)
			RegulerAxiale(-4,45,0,FAUX,200)
			RegulerVitesseFixe(-5,138,0,FAUX,300)
			RegulerAxiale(-5,45,0,FAUX,200)
			; le flot 9 acc�l�re � 50km/h(138) et se met dans la voie de droite
		JSQA OU(Position(-1,"mobile","D1",38785,VRAI,VRAI,">"),Position(-1000,"mobile","D1",38985,VRAI,VRAI,">"))
		; le sujet (-1) est � 50m avant D1XD8: 3928.5-50=3878.5(38785) ou le li�vre(-1000) se trouve � 30m avant D1XD8: 3928.5-30=3898.5(38985)	
		ALLER ESSAI(233)
	FINSI
FIN

INSTRUCTION(2330,233,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,69,0,FAUX,100)
			RegulerAxiale(-1000,18,0,FAUX,200)
			ChangerIndicateur(-1000,FAUX,"clignotant_gauche",1)
			; le li�vre(-1000) ralentit � 25km/h(69) et tourne � gauche sur la D8 en sens direct
			RegulerVitesseFixe(-10,69,0,FAUX,100)
			RegulerVitesseFixe(-222,69,0,FAUX,100)
			RegulerVitesseFixe(-4,69,0,FAUX,100)
			RegulerVitesseFixe(-5,69,0,FAUX,100)
			; le flot 9 ralentit � 25km/h(69) et tourne � droite sur D8(6) en sens indirect
		JSQA Position(-1000,"mobile","D8",2409,VRAI,VRAI,">")	
		; le li�vre(-1000) se trouve 10m apr�s D8XD1:230.9+10=240.9(2409)
		ALLER ESSAI(234)
	FINSI
FIN

;------------------------------Fin Estimation n�3 des GAPS: flot 9 -----------------------------
;-----------------------------------------------------------------------------------------------


;-------------------------- Supression du flot 9 --------------------------------------

INSTRUCTION(2340,234,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,0,0,FAUX,100)
			RegulerAxiale(-1000,18,0,FAUX,200)
			ChangerIndicateur(-1000,FAUX,"clignotant_gauche",1)			
			;li�vre (-1000) a ralentit � 25km/h (69) et tourne � gauche sur la D8(6) en sens direct
		JSQA Position(-1000,"mobile","D8",2504,VRAI,VRAI,">")	
		; le li�vre (-1000) est � 19.5m apr�s D8XD1(33): 230.9m+19.5=250.4(2504)	
		ALLER ESSAI(235)
	FINSI
FIN

INSTRUCTION(2350,235,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,0,0,FAUX,50)
			ChangerIndicateur(-1000,FAUX,"warning",1)			
			;li�vre (-1000) s'est arr�t� sur la D8(6) en sens direct
		JSQA Position(-1,"mobile","D8",2339,VRAI,VRAI,">")	
		; le sujet (-1) est � 3m apr�s D8XD1(33): 230.9m+3=233.9(2339), soit � 16.5m du li�vre	
		ALLER ESSAI(236)
	FINSI
FIN

;---------------------------------------------------------------------------------------------------------------
;-----------------------------------D�but Estimation n�4 des GAPS: flot 10 -------------------------------------
;------ Sujet sur D8(6) en sens direct s'ins�re dans le flot10 lat�ral droit sur D1(33) au niveau de D1XD8 -----

INSTRUCTION(2360,236,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerAxiale(-1000,18,0,FAUX,200)
			RegulerVitesseFixe(-1000,138,0,FAUX,200)	
			;li�vre (-1000) acc�l�re � 50 km/h (138) en sens direct sur la D8(6)
		JSQA Position(-1000,"mobile","D8",5658,VRAI,VRAI,">")	
		; le li�vre (-1000) est � 50m avant D8XD1(33): 615.8m-50=565.8(5658)	
		ALLER ESSAI(237)
	FINSI
FIN

INSTRUCTION(2370,237,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			SupprimerParNumero("mobile",-10)	; suppression du CitroenC4(-10) cr��e sur la D1(33)
			SupprimerParNumero("mobile",-222)	; suppression de la Moto1 (-222) cr��e sur la D1(33)
			SupprimerParNumero("mobile",-4)		; suppression de la C4Noire (-4) cr��e sur la D1(33)
			SupprimerParNumero("mobile",-5)		; suppression de la Moto2 (-5) cr��e sur la D1(33)
			EvenementSonore(0,1,VRAI)
			RegulerVitesseFixe(-1000,69,0,FAUX,100)
			RegulerAxiale(-1000,18,0,FAUX,200)
			ChangerIndicateur(-1000,FAUX,"clignotant_gauche",1)
			; li�vre(-1000) sur D8(6) ralentit � 25 km/h(69) et tourne � gauche sur D1(33) en sens direct
		JSQA Position(-1,"mobile","D8",5658,VRAI,VRAI,">")	
		; le sujet (-1) est � 50m avant D8XD1(33): 615.8m-50=565.8(5658)				
		ALLER ESSAI(238)
	FINSI
FIN

;----------------- Flot 10 en ville lat�ral droit sur D1 (33) avec 2RMs  ----------------------------
;----------------------- CitroenC4(-12),Moto1 (-13), C4Noire(-15),Moto3(-20)-------------------------------
;----------- 1er VL ----- 1�re moto pour gap risqu� -- 2eme VL ---- 2�me moto pour gap s�curis� -----------
;-- Sujet (-1) sur la D8(6) en sens direct s'ins�re dans le flot 10 pour continuer � gauche sur la D1(33)--

INSTRUCTION(2380,238,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerEnvMessage(5,"Flot10",50,50,255,0,0)
			CreerMobile ("V2","M1",-12,"Asservi",100,VRAI,69,"D1",FAUX,18,FAUX,19510,0)
			; Cr�ation CitroenC4(-12) roulant en sens direct sur la D1(33) � 25 km/h(69)
			; trajectoire 2besafe.v100,CitroenC4 � 150m de D1XD8=2101.0-150m=1951.0m (19510)
			CreerMobile ("M1","M1",-13,"Asservi",100,VRAI,69,"D1",FAUX,18,VRAI,-700,-12,0)
			; Cr�ation Moto1(-13) roulant en sens direct sur la D1(23) � 25 km/h(69)
			; Moto1(-13)  se trouve � 70 m derri�re la CitroenC4(-12)
			; Moto1(-13) suit la trajectoire 2besafe.v100 sur la D1(33)
			CreerMobile ("V2","M4",-15,"Asservi",100,VRAI,69,"D1",FAUX,18,VRAI,-100,-13,0)
			; Cr�ation C4Noire(-15) roulant en sens indirect sur la D1(33) � 25 km/h (69)
			; C4Noire(-15) est � 10 m derri�re la Moto1(-13)
			; C4Noire(-15) suit la trajectoire 2besafe.v100 sur la D1(33)
			CreerMobile ("M1","M1",-20,"Asservi",100,VRAI,69,"D1",FAUX,18,VRAI,-700,-15,0)
			; Moto2(-20)  se trouve � 70 m derri�re la C4Noire(-15)
			; Moto2(-20) suit la trajectoire 2besafe.v100 sur la D1(33)	
	 	JSQA Immediate()
		ALLER ESSAI(239)
	FINSI
FIN

INSTRUCTION(2390,239,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-13,VRAI,"phares",1)
	 	JSQA Immediate()
		ALLER ESSAI(240)
	FINSI
FIN

INSTRUCTION(2400,240,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-20,VRAI,"phares",1)
	 	JSQA Immediate()
		ALLER ESSAI(242)
	FINSI
FIN

INSTRUCTION(2420,242,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerAxiale(-1000,45,0,FAUX,200)
 			RegulerVitesseFixe(-1000,69,0,FAUX,100)
			; li�vre(-1000) ralentit � 25 km/h(69), se met dans la voie de droite
			; li�vre (-1000) tourne � droite sur D1(33) en sens direct
		JSQA Position(-1000,"mobile","D1",21310,VRAI,VRAI,">")
		; le li�vre (-1000) est � 30m apr�s D1XD8(6):2101.0m+30=2131.0(21310)
		ALLER ESSAI(243)
	FINSI
FIN


INSTRUCTION(2430,243,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			EvenementSonore(0,1,FAUX)
			RegulerVitesseFixe(-1000,69,0,FAUX,100)
			; li�vre(-1000) d�cc�l�re � 25km/h(69) sur la D1 et continue tout droit sur D1 en sens direct
			RegulerVitesseFixe(-12,69,0,FAUX,300)
			RegulerVitesseFixe(-13,69,0,FAUX,300)
			RegulerVitesseFixe(-15,69,0,FAUX,300)
			RegulerVitesseFixe(-20,69,0,FAUX,300)
			; le flot 10 d�cc�l�re � 25km/h(69) puis tourne � droite en sens indirect sur la D8 (2�me embranchement D1XD8)
		JSQA Position(-1000,"mobile","D1",23806,VRAI,VRAI,">")
		; le li�vre (-1000) est sur D1 10m apr�s D1XD8: 2370.6+10=2380.6(23806)			
		ALLER ESSAI(244)
	FINSI
FIN

INSTRUCTION(2440,244,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,0,0,FAUX,100)
			; li�vre(-1000) s'arr�te sur la D1(33) en sens direct
		JSQA Position(-1000,"mobile","D1",23901,VRAI,VRAI,">")
		; le li�vre (-1000) est sur D1 19.5m apr�s D1XD8: 2370.6+19.5=2390.1(23901)			
		ALLER ESSAI(245)
	FINSI
FIN

INSTRUCTION(2450,245,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,0,0,FAUX,50)
			ChangerIndicateur(-1000,FAUX,"warning",1)
			; li�vre(-1000) s'arr�te et met ses warnings sur la D1(33) en sens direct
		JSQA Position(-1,"mobile","D1",23731,VRAI,VRAI,">")
		; le sujet (-1) est sur D1 3m apr�s D1XD8: 2370.6+3=2373.1(23731)			
		ALLER ESSAI(246)
	FINSI
FIN

INSTRUCTION(2460,246,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerAxiale(-1000,18,0,FAUX,300)
			RegulerVitesseFixe(-1000,138,0,FAUX,200)
			; li�vre(-1000) acc�l�re � 50km/h(138) sur la D1(33) en sens direct
		JSQA Position(-1000,"mobile","D1",24149,VRAI,VRAI,">")
		; le li�vre (-1000) est sur D1 50m avant D1XD10: 2464.9-50=2414.9(24149)			
		ALLER ESSAI(247)
	FINSI
FIN

INSTRUCTION(2470,247,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,69,0,FAUX,100)
			ChangerIndicateur(-1000,FAUX,"clignotant_gauche",1)
			; le li�vre(-1000) d�cc�l�re � 50km/h(69) sur la D1(33) en sens direct
			; le li�vre (-1000) tourne � gauche sur la D10(7) en sens direct
		JSQA Position(-1,"mobile","D10",100,VRAI,VRAI,">")
		; le sujet (-1) est sur D1 10m apr�s D10XD1: 0+10=10(100)	
		ALLER ESSAI(248)
	FINSI
FIN

INSTRUCTION(2480,248,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,138,0,FAUX,300)	
			;li�vre (-1000) acc�l�re � 50 km/h (138) sur la D10 en sens direct
		JSQA Position(-1000,"mobile","D10",3421,VRAI,VRAI,">")
		; le li�vre (-1000) est sur D10 � 50m avant D10XD1(33): 392.1m-50=342.1(3421)	
		ALLER ESSAI(249)
	FINSI
FIN

;-------------------------- Supression du flot 10--------------------------------------
INSTRUCTION(2490,249,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			SupprimerParNumero("mobile",-12)	; suppression du CitroenC4(-12) cr��e sur la D1(33)
			SupprimerParNumero("mobile",-13)	; suppression de la Moto1 (-13) cr��e sur la D1(33)
			SupprimerParNumero("mobile",-15)	; suppression de la C4Noire (-15) cr��e sur la D1(33)
			SupprimerParNumero("mobile",-20)	; suppression de la Moto3 (-20) cr��e sur la D1(33)
		JSQA Immediate()
		ALLER ESSAI(250)
	FINSI
FIN

INSTRUCTION(2500,250,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,69,0,FAUX,100)
			RegulerAxiale(-1000,48,0,FAUX,300)
			; li�vre(-1000) ralentit � 25 km/h(69) et tourne � droite sur D1(33)
			ChangerIndicateur(-1000,FAUX,"clignotant_droit",1)
		JSQA Position(-1000,"mobile","D1",34672,VRAI,FAUX,">")	
		; le li�vre (-1000) est sur D1 � 10m apr�s D1XD10:3477.2-10=3467.2 (34672)		
		ALLER ESSAI(251)
	FINSI
FIN



INSTRUCTION(2510,251,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			NeRienFaire()			
		JSQA Position(-1,"mobile","D1",32772,VRAI,FAUX,">")	
		; le sujet (-1) est � 200m apr�s D1XD10: 3477.2-200=3277.2(32772)	
		ALLER ESSAI(252)
	FINSI
FIN	

;-------------------------------------------------------------------------------------------------------------
;---------------------------------- D�but Estimation n�5 des GAPS: flot 11 -----------------------------------
;-------------------------- Sujet sur D1(33) s'ins�re dans le flot11 arri�re sur D1(33) ----------------------
;--------------------------------- Sujet (-1) et flot 11 en sens indirect sur D1 ----------------------------



;---- Flot 11 en ville arri�re sur D10 (7) en sens indirect  dans la voie de gauche avec 2RMs  ----
;----------------------- CitroenC4(-10),Moto1 (-222),C4Noire(-4),Moto3(-5) ------------------------------
;----------- 1er VL ----- 1�re moto pour gap risqu� -- 2eme VL ---- 2�me moto pour gap s�curis� ---------
;---- Sujet (-1) sur la D1(33) dans la voie de droite s'ins�re dans le flot 11 dans la voie de gauche ---

INSTRUCTION(2520,252,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerEnvMessage(5,"Flot11",50,50,255,0,0)
			CreerMobile ("V2","M1",-10,"Asservi",110,VRAI,97,"D1",FAUX,-18,VRAI,200,-1,180)
			; Cr�ation CitroenC4(-10) roulant en sens indirect sur la D1(33) � 60 km/h(166) � 20m derri�re le sujet (-1)	
			; trajectoire 2besafe.v110
			CreerMobile ("M1","M1",-222,"Asservi",110,VRAI,97,"D1",FAUX,-18,VRAI,700,-10,180)
			; Cr�ation Moto1(-222) roulant en sens indirect sur la D1(33) � 60 km/h(166)
			; Moto1(-222)  se trouve � 70 m derri�re la CitroenC4(-10)
			; Moto1(-222) suit la trajectoire 2besafe.v110 sur la D1(33)
			CreerMobile ("V2","M4",-4,"Asservi",110,VRAI,97,"D1",FAUX,-18,VRAI,100,-222,180)
			; Cr�ation C4Noire(-4) roulant en sens indirect sur la D1(33) � 60 km/h(166)
			; C4Noire(-4) est � 10 m derri�re la Moto2(-3)
			; C4Noire(-4) suit la trajectoire 2besafe.v110 sur la D1(33)
			CreerMobile ("M1","M1",-5,"Asservi",110,VRAI,97,"D1",FAUX,-18,VRAI,700,-4,180)
			; Moto3(-5)  se trouve � 70 m derri�re la C4Noire(-15)
			; Moto3(-5) suit la trajectoire 2besafe.v110 sur la D1(33) � 60 km/h(166)
	 	JSQA Immediate()
		ALLER ESSAI(253)
	FINSI
FIN

INSTRUCTION(2530,253,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-222,VRAI,"phares",1)
	 	JSQA Immediate()
		ALLER ESSAI(254)
	FINSI
FIN

INSTRUCTION(2540,254,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-5,VRAI,"phares",1)
	 	JSQA Immediate()
		ALLER ESSAI(255)
	FINSI
FIN

INSTRUCTION(2550,255,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			EvenementSonore(0,1,VRAI)
		JSQA Interdistance(-10,"mobile",-1,"mobile",20,">")
		; le sujet(-1) et la citroen C4(-10), 1er v�hicule du flot 11 roulent en sens indirect sur D1(33)
		; la 1�re voiture du flot11(-10) passe devant le sujet(-1) et le d�passe de 2m(20): Pk(-1) - Pk(-10)>0
		ALLER ESSAI(256)
	FINSI
FIN

INSTRUCTION(2560,256,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			EvenementSonore(0,1,FAUX)
			RegulerVitesseFixe(-10,97,0,FAUX,300)	
			; 1er v�hicule du flot11 d�cc�l�re � 35 km/h(97) et continue tout droit sur D10 en sens indirect
			RegulerVitesseFixe(-222,97,0,FAUX,300)	
			; la 1�re moto du flot11 d�cc�l�re � 35 km/h(97) et continue tout droit sur D10 en sens indirect
			RegulerVitesseFixe(-4,97,0,FAUX,300)	
			; le 2�me v�hicule du flot11 d�cc�l�re � 35 km/h(97) et continue tout droit sur D10 en sens indirect
			RegulerVitesseFixe(-5,97,0,FAUX,300)	
			; la 2�me moto du flot11 d�cc�l�re � 35 km/h(97) et continue tout droit sur D10 en sens indirect
			RegulerVitesseFixe(-1000,69,0,FAUX,300)	
			; le li�vre reste � 25 km/h(69) et continue tout droit sur D1 en sens indirect
		JSQA Interdistance(-4,"mobile",-1,"mobile",20,">")
		; le 2�me v�hicule du flot11 (-4) rattrape le sujet(-1), le sujet doit s'ins�rer derri�re	
		ALLER ESSAI(257)
	FINSI
FIN	


INSTRUCTION(2570,257,FAUX,FAUX,VRAI,VRAI)
	SI ET(NumeroEssai(),DecalageLat(-1,-29,">"))
	; le sujet(-1) est dans la voie de gauche:
	; milieu de la voie de gauche:-1.8m(-18), ligne centrale: -3.7m(-37), position lat�rale du Sujet > -2.9(-29) =-3,7-1/2 voiture(0.8m)
		FAIRE
			RegulerVitesseRelative(-1000,-1,FAUX,100,0,0,FAUX,300)
			; le li�vre(-1000) roule � la m�me vitesse que celle du sujet (-1)
			ChangerIndicateur(-1000,FAUX,"warning",1)		
			; le li�vre garde ses warnings tant que le sujet n'est pas retourn� dans la voie de droite
		JSQA DecalageLat(-1,-45,"<")
		; le sujet(-1) retourne dans la voie de droite: 
		; milieu de la voie de droite: -5.6m(-56), ligne centrale: -3.7m(-37), position lat�rale du Sujet < -4.5m(-45) =-3,7+1/2 voiture(0.8m)
		ALLER ESSAI(258)
	FINSI
FIN


INSTRUCTION(2580,258,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,138,0,FAUX,200)
			; li�vre(-1000) acc�l�re � 50 km/h(138) et continue tout droit sur D1 en sens indirect	
			RegulerVitesseFixe(-10,165,0,FAUX,100)
			RegulerVitesseFixe(-222,165,0,FAUX,100)
			RegulerVitesseFixe(-4,165,0,FAUX,100)
			RegulerVitesseFixe(-5,165,0,FAUX,100)
			; Tous les v�hicules du flot11 acc�l�rent � 60km/h(165) et continuent tout droit sur la D1 en sens direct
		JSQA Position(-1000,"mobile","D1",25149,VRAI,FAUX,">")
		; le li�vre(-1000) en sens indirect sur D1 est � 50m avant D1XD10:2464.9m+50=2514.9(25149) (1er embranchement)
		ALLER ESSAI(271)
	FINSI
FIN


INSTRUCTION(2710,271,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,69,0,FAUX,100)
			ChangerIndicateur(-1000,FAUX,"clignotant_gauche",1)
			; li�vre(-1000) ralentit � 25km/h(69) et tourne � gauche sur la D1(33) en sens indirect		
		JSQA Position(-1000,"mobile","D1",24449,VRAI,FAUX,">")	
		; le li�vre (-1000) est � 20m apr�s D1XD10: 2464.9-20=2444.9(24449)		
		ALLER ESSAI(272)
	FINSI
FIN

INSTRUCTION(2720,272,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-1000,FAUX,"clignotant_gauche",1)	
			RegulerAxiale(-1000,-18,0,FAUX,200)
			;li�vre (-1000) se d�porte dans la voie de gauche sur D1
		JSQA Position(-1000,"mobile","D1",24354,VRAI,FAUX,">")	
		; le li�vre (-1000) est � 29.5m apr�s D1XD10: 2464.9-29.5=2435.4(24354)	
		ALLER ESSAI(274)
	FINSI
FIN


;----------------------------------------------------------------------------------------------------------
;---------------------------------- D�but Estimation n�6 des GAPS: flot 12 --------------------------------
;------ Sujet traverse flot12 frontal pour tourner � gauche sur D8 en sens indirect apr�s D1XD8 -----------
;-------------- Sujet (-1) en sens indirect et flot 11 en sens direct sur D1 (33) -------------------------

INSTRUCTION(2740,274,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerAxiale(-1000,-18,0,FAUX,200)
			RegulerVitesseFixe(-1000,69,0,FAUX,400)	
			; li�vre(-1000) roule � 25 km/h(69) et continue sur D1(33) en sens indirect dans la voie de gauche 
		JSQA Position(-1,"mobile","D1",24206,VRAI,FAUX,">")	
		; le sujet(-1) est � 50m avant D1XD8(6): 2370.6+50=2420.6(24206)				
		ALLER ESSAI(276)
	FINSI
FIN

;------------------------- Flot 12 en ville frontal sur D1 (33) en sens direct avec 2RMs  --------------------
;---------------- CitroenC4(-12),Moto1 (-13),Moto2(-14),C4Noire(-15),Moto3(-20),Moto4(-21)--------------------------
;----------- 1er VL ----- 1�re moto pour gap risqu� -- 2eme VL ---- 2�me moto pour gap s�curis� --------------------
;---Sujet(-1) sur la D1(7) en sens indirect traverse le flot 12 pour tourner � gauche sur la D8(6) en sens direct---


INSTRUCTION(2760,276,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerEnvMessage(5,"Flot12",50,50,255,0,0)		
			RegulerVitesseFixe(-1000,69,0,FAUX,400)
			CreerMobile ("V2","M1",-12,"Asservi",120,VRAI,69,"D1",FAUX,48,FAUX,22906,0)
			; Cr�ation CitroenC4(-12) roulant en sens direct sur la D1(33) � 50 km/h(138)
			; trajectoire 2besafe.v120,CitroenC4 � 50m de D1XD8=2370.6-50=2320.6(23206)
			CreerMobile ("M1","M1",-13,"Asservi",120,VRAI,69,"D1",FAUX,45,VRAI,-700,-12,0)
			; Cr�ation Moto1(-13) roulant en sens direct sur la D1(33) � 50 km/h(138)
			; Moto1(-13)  se trouve � 70 m derri�re la CitroenC4(-12)
			; Moto1(-13) suit la trajectoire 2besafe.v120 sur la D1(33)
			CreerMobile ("V2","M4",-15,"Asservi",120,VRAI,69,"D1",FAUX,45,VRAI,-100,-13,0)
			; Cr�ation C4Noire(-15) roulant en sens indirect sur la D1(33) � 50 km/h(138)
			; C4Noire(-15) est � 10 m derri�re la Moto1(-13)
			; C4Noire(-15) suit la trajectoire 2besafe.v120 sur la D1(33)
			CreerMobile ("M1","M1",-20,"Asservi",120,VRAI,69,"D1",FAUX,45,VRAI,-700,-15,0)
			; Moto3(-20)  se trouve � 70 m derri�re la C4Noire(-15)
			; Moto3(-20) suit la trajectoire 2besafe.v120 sur la D1(33)			
	 	JSQA Immediate()
		ALLER ESSAI(277)
	FINSI
FIN

INSTRUCTION(2770,277,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-13,VRAI,"phares",1)
	 	JSQA Immediate()
		ALLER ESSAI(278)
	FINSI
FIN

INSTRUCTION(2780,278,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			ChangerIndicateur(-20,VRAI,"phares",1)
	 	JSQA Immediate()
		ALLER ESSAI(281)
	FINSI
FIN


;------------------------------Fin Estimation n�5 des GAPS: flot 11 ----------------------------
;-----------------------------------------------------------------------------------------------



;-------------------------- Supression du flot 11--------------------------------------

INSTRUCTION(2810,281,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			EvenementSonore(0,1,VRAI)
			SupprimerParNumero("mobile",-10)	; suppression du CitroenC4(-10) cr��e sur la D1(33)
			SupprimerParNumero("mobile",-222)	; suppression de la Moto1 (-222) cr��e sur la D1(33)
			SupprimerParNumero("mobile",-4)	; suppression de la C4Noire (-4) cr��e sur la D1(33)
			SupprimerParNumero("mobile",-5)	; suppression de la Moto3 (-5) cr��e sur la D1(33)
		JSQA Immediate()
		ALLER ESSAI(282)
	FINSI
FIN

INSTRUCTION(2820,282,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,69,0,FAUX,100)
			ChangerIndicateur(-1000,FAUX,"clignotant_gauche",1)
			; li�vre(-1000) ralentit � 25km/h(69) et tourne � gauche sur la D8(6) en sens indirect
			RegulerVitesseFixe(-12,69,0,FAUX,100)
			RegulerVitesseFixe(-13,69,0,FAUX,100)
			RegulerVitesseFixe(-15,69,0,FAUX,100)
			RegulerVitesseFixe(-20,69,0,FAUX,100)
			; le flot 12 ralentit � 25km/h(69)
		JSQA Position(-1000,"mobile","D8",20291,VRAI,FAUX,">")	
		; le li�vre (-1000) est sur D8 20m apr�s D1XD8(6): 2049.1-20=2029.1(20291)				
		ALLER ESSAI(283)
	FINSI
FIN

INSTRUCTION(2830,283,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			EvenementSonore(0,1,FAUX)
			RegulerVitesseFixe(-1000,0,0,FAUX,100)
			; li�vre(-1000) s'arr�te sur la D8(6) en sens indirect
		JSQA Position(-1000,"mobile","D8",20196,VRAI,FAUX,">")
		; le li�vre(-1000) est sur D8 en sens indirect � 29.5m apr�s D8XD1: 2049.1-29.5=2019.6(20196)
		; le sujet (-1) a travers� le flot12 et se retrouve derri�re le li�vre apr�s D8XD1				
		ALLER ESSAI(284)
	FINSI
FIN

INSTRUCTION(2840,284,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,0,0,FAUX,50)
			ChangerIndicateur(-1000,FAUX,"warning",1)
			; le li�vre (-1000) met ses warnings
		JSQA Position(-1,"mobile","D8",20461,VRAI,FAUX,">")
		; le sujet (-1) roulant en sens indirect est � 3m apr�s D8XD1: 2049.1-3=2046.1(20461)
		; le sujet(-1) est � 26.5m du li�vre(-1000)
		ALLER ESSAI(285)
	FINSI
FIN

INSTRUCTION(2850,285,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,138,0,FAUX,200)
			; le li�vre red�marre � 50km/h(138) sur D8(6) en sens indirect
		JSQA Position(-1000,"mobile","D8",19991,VRAI,FAUX,">")
		; le li�vre (-1000) est � 50m apr�s D8XD1: 2049.1-50=1999.1(19991)		
		ALLER ESSAI(286)
	FINSI
FIN

INSTRUCTION(2860,286,FAUX,FAUX,VRAI,VRAI)
	SI NumeroEssai()
		FAIRE
			RegulerVitesseFixe(-1000,0,0,VRAI,100)
			RegulerAxiale(-1000,-50,0,FAUX,200)
			; le li�vre s'arr�te sur D8 sur le c�t� en 10s
		JSQA Attente(10)
		ALLER ESSAI(500)
	FINSI
FIN	


;--------------------------------------------------------------------
;-----------------------Avertissement fin scenario -------------------
;---------------------------------------------------------------------

INSTRUCTION(5000,500,FAUX,FAUX,FAUX,FAUX)
	SI NumeroEssai()
		FAIRE
			ChangerEnvMessage(6,"TERMINE",50,50,255,0,0)
		JSQA Attente(5)
		ALLER COURANT
	FINSI
FIN
