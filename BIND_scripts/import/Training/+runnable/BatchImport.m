mappingType = questdlg('Quel fichier de mapping utiliser ?','Mapping','T1','T2','T1');

% cd('C:\Users\sornette\Desktop\canards boiteux\');
% varList = {...
%         './entraines/S02 enrichi/s02 avt/S02natio1_avant/08041016.var', 'natio1';...%KO : fichier vide
%         './entraines/S02 enrichi/s02 avt/S02natio1_avant/natio1 2_dernières 2RM/08031131.var', 'natio1';...%KO : réorganization
%         %'./entraines/S02 enrichi/s02 avt/S02natio1_avant/natio1 5_1eres 2RM/08041027.var', 'natio1';...
%         './entraines/S02 enrichi/s02 avt/S02natio1_avant/S02_natio1_2dernières motos/08031131.var', 'natio1';...%KO
%         %'./entraines/S02 enrichi/s02 avt/S02ville_avant/S02 ville 2_derniers flots/08041057.var', 'ville';...
%         %'./entraines/S02 enrichi/s02 avt/S02ville_avant/S02 ville 4_1ers flots/08041039.var', 'ville';...
%         './entraines/S02 enrichi/s02 avt/S02ville_avant/ville 2ème lancement_2derniers flots/08041057.var', 'ville';... : KO
%         './entraines/S06 enrichi/S06 aps/S06 natio2 debut/28051453.var', 'natio2';...%KO
%         %'./entraines/S06 enrichi/S06 aps/S06 natio2_a partir dep a droite/28051519.var', 'natio2';...
%         './entraines/S08 enrichi_no ville/S08 avt/S08_natio1/11051659.var', 'ville';...%KO : fichier vide
%         './entraines/S08 enrichi_no ville/S08 avt/S08_natio1/train1_natio1_s08.var', 'ville';...%KO
%         './non-entraines/S11 enrichi/S11 avt/S11_ville_1ere/07061353.var', 'ville';...%KO : fichier vide
%         %'./non-entraines/S11 enrichi/S11 avt/S11_ville_1ere/train1_ville_s11.var', 'ville';...
%         %'./non-entraines/S15 enrichi/S15 avt/15_ville_1_manque dernier flot/15060954.var', 'ville';...
%         %'./non-entraines/S15 enrichi/S15 avt/S15_ville_pour dernier flot/15061013.var', 'ville';...
%         %'./non-entraines/S16 enrichi/S16 aps/S16 ville 2eme 2derniers flots/23061751.var', 'ville';...
%         %'./non-entraines/S16 enrichi/S16 aps/S16_ville 2eme_manque dernier flot/23061734.var', 'ville';...
%         './non-entraines/S18 enrichi/S18 aps/S18 natio1/24061711.var', 'natio1';...%KO : fichier vide
%         %'./non-entraines/S18 enrichi/S18 aps/S18 natio1/train1.var', 'natio1';...
%         %'./non-entraines/S25 enrichi_no ville/S25 avt/S25 autor2 derniere moto/15091019.var', 'autor2';...
%         %'./non-entraines/S25 enrichi_no ville/S25 avt/S25 autor2 sans derniere moto/15090921.var', 'autor2';...
%         %'./non-entraines/S26 enrichi/S26 avt/S26 natio2/18082002.var', 'natio2';...
%         './non-entraines/S26 enrichi/S26 avt/S26 natio2 planté/18082018.var', 'natio2';...%KO
%         %'./non-entraines/S32 enrichi/S32 aps/S32 autor2 plante dernière moto/26081734.var', 'autor2';...
%         %'./non-entraines/S32 enrichi/S32 aps/S32 autor2 pour la dernière moto/26081749.var', 'autor2';...
%     };

cd('C:\Users\sornette\Desktop\T2');
%     './s05 rdv1/s05 autor2 1/train1.var', 'autor2';
%     './s05 rdv1/s05 autor2 dern 2rm/train1.var', 'autor2';
%     './s08 rdv1/s08 ville 1 deux 1ers/train1.var'
%     './s09 rdv2/s09 auor2 dern/train1.var'
%     './s09 rdv2/s09 autor2 début/train1.var'
%     ./s43 rdv1/s43 autor2 fin/train1.var
%     ./s43 rdv1/s43 autor2 planté/train1.var
%     ./s35 rdv2/s35 natio 2 jusqu-dép-droite-compris/train1.var
%     ./s35 rdv2/s35 natio2/train1.var
%     ./s18 rdv2/s18 ville2/train1.var
%     ./s18 rdv2/s18 ville2 3flots 1er/train1.var
%     ./s38 rdv1/s38 natio2 pas bon/train1.var
%     ./s38 rdv1/s38 natio2__/train1.var
%     ./s41 rdv1/s41 natio1 2/train1.var
%     ./s41 rdv1/s41 natio1 5dern/train1.var
%./s20 rdv-1/s20 entconduite/train1.var', 'natio2';
%'./s24 rdv-2/sauv s24/train1.var', 'autor2';
% ./s26 rdv1/s26 ville dern 2/s26_rdv1_ville1_/train1.var
% ./s26 rdv1/s26 ville dern 2/train1.var
% ./s26 rdv1/s26 ville planté 2 1ers/train1.var
% ./s26 rdv1/s26 ville1 sans dern/train1.var
%         ./s38 rdv2_/s38 natio1/train1.var
%         ./s38 rdv2_/s38 natio1 4 dernières motos/train1.var

varList = {
%     './s01 rdv1/s01 autor2/train1.var', 'autor2', 'noBV';
%     './s01 rdv1/s01 natio1/train1.var', 'natio1', 'noBV';
     %'./s01 rdv1/s01 ville/train1.var', 'ville1', 'BV';
%     './s01 rdv2/s01 autor1/train1.var', 'autor1', 'noBV';
%     './s01 rdv2/s01 natio2/train1.var', 'natio2', 'noBV';
%     './s01 rdv2/s01 ville2/train1.var', 'ville2', 'BV';
%      './s02 1/s02 natio1/s02_rdv1_natio1/train1.var', 'natio1', 'noBV';
%      './s02 rdv2/s02 natio2/s02_rdv2_natio2/train1.var', 'natio2', 'noBV';
%     './s02 1/s02 ville 1/train1.var', 'ville1', 'BV';
%     './s02 rdv2/s02 autor1/train1.var', 'autor1', 'noBV';
%     './s02 rdv2/s02 ville2/train1.var', 'ville2', 'BV';
%     './s03 rdv1/s03 autor2/train1.var', 'autor2', 'noBV';
%     './s03 rdv1/s03 natio1/train1.var', 'natio1', 'noBV';
%     './s03 rdv1/s03 ville1/train1.var', 'ville1', 'noBV';
%     './s03 rdv2/s03 autor1/train1.var', 'autor1', 'noBV';
%     './s03 rdv2/s03 natio2/train1.var', 'natio2', 'noBV';
%     './s03 rdv2/s03 ville2/train1.var', 'ville2', 'BV';
%     './s04 rdv1/s04 autor1/train1.var', 'autor1', 'noBV';
%     './s04 rdv1/s04 natio2/train1.var', 'natio2', 'noBV';
%     './s04 rdv1/s04 ville1/train1.var', 'ville1', 'BV';
%     './s04 rdv2/s04 autor2/train1.var', 'autor2', 'noBV';
%     './s04 rdv2/s04 natio1/train1.var', 'natio1', 'noBV';
%     './s04 rdv2/s04 ville2/train1.var', 'ville2', 'BV';
%     './s05 rdv1/s05 natio1/train1.var', 'natio1', 'noBV';
%     './s05 rdv1/s05 ville1/train1.var', 'ville1', 'BV';
%     './s05 rdv2/s05 autor1/train1.var', 'autor1', 'noBV';
%     './s05 rdv2/s05 natio2/train1.var', 'natio2', 'noBV';
%     './s05 rdv2/s05 ville2/train1.var', 'ville2', 'BV';
%     './s06 rdv1/s06 autor2/train1.var', 'autor2', 'noBV';
%     './s06 rdv1/s06 natio1/train1.var', 'natio1', 'noBV';
%     './s06 rdv1/s06 ville1/train1.var', 'ville1', 'BV';
%        './s06 rdv2/s06 autor1/train1.var', 'autor1', 'noBV';
%     './s06 rdv2/s06 ville2/train1.var', 'ville2', 'BV';
%        's06 rdv2/s06 natio2/s06_rdv2_natio2/train1.var', 'natio2', 'noBV';
%     './s08 rdv1/s08 autor1/train1.var', 'autor1', 'noBV';
%     './s08 rdv1/s08 natio2/train1.var', 'natio2', 'noBV';
%     './s08 rdv1/s08 ville entier/train1.var', 'ville1', 'BV';
%     './s08 rdv2/s08 autor2/train1.var', 'autor2', 'noBV';
%     './s08 rdv2/s08 natio1/train1.var', 'natio1', 'noBV';
%     './s08 rdv2/s08 ville2/train1.var', 'ville2', 'BV';
%     './s09 rdv1/s09 autor1/train1.var', 'autor1', 'noBV';
%     './s09 rdv1/s09 nayio2/train1.var', 'natio2', 'noBV';
%     './s09 rdv1/s09 ville1/train1.var', 'ville1', 'BV';
%     './s09 rdv2/s09 natio1/train1.var', 'natio1', 'noBV';
%     './s09 rdv2/s09 ville2/train1.var', 'ville2', 'BV';
%     './s10 rdv1/s10 autor2/train1.var', 'autor2', 'noBV';
%     './s10 rdv1/s10 natio1/train1.var', 'natio1', 'noBV';
%     './s10 rdv1/s10 ville1/train1.var', 'ville1', 'BV';
%     './s10 rdv2/s10 autor1/train1.var', 'autor1', 'noBV';
%     './s10 rdv2/s10 natio2/train1.var', 'natio2', 'noBV';
%     './s10 rdv2/s10 ville2/train1.var', 'ville2', 'BV';
%     './s11 rdv1/s11 autor1/train1.var', 'autor1', 'noBV';
%     './s11 rdv1/s11 natio2/train1.var', 'natio2', 'noBV';
%     './s11 rdv1/s11 ville1/train1.var', 'ville1', 'BV';
%     './s11 rdv2/s11 auotr2/train1.var', 'autor2', 'noBV';
%     './s11 rdv2/s11 natio1/train1.var', 'natio1', 'noBV';
%     './s11 rdv2/s11 ville2/train1.var', 'ville2', 'BV';
%     './s12 rdv1/s12 autor1/train1.var', 'autor1', 'noBV';
%     './s12 rdv1/s12 natio2/train1.var', 'natio2', 'noBV';
%     './s12 rdv2/s12 autor2/train1.var', 'autor2', 'noBV';
%     './s12 rdv2/s12 natio1/train1.var', 'natio1', 'noBV';
%     './s14 rdv1/s14 autor2/train1.var', 'autor2', 'noBV';
%     './s14 rdv1/s14 natio1/train1.var', 'natio1', 'noBV';
%     './s14 rdv1/s14 ville 1/train1.var', 'ville1', 'noBV';
%     './s14 rdv2/s14 autor1/train1.var', 'autor1', 'noBV';
%     './s14 rdv2/s14 natio2/train1.var', 'natio2', 'noBV';
%     './s14 rdv2/s14 ville 2_/train1.var', 'ville2', 'BV';
%     './s15 rdv1/s15 autor2/train1.var', 'autor2', 'noBV';
%     './s15 rdv1/s15 natio1/train1.var', 'natio1', 'noBV';
%     './s15 rdv1/s15 ville1/train1.var', 'ville1', 'BV';
%     './s15 rdv2/s15 autor1/train1.var', 'autor1', 'noBV';
%     './s15 rdv2/s15 natio2/train1.var', 'natio2', 'noBV';
%     './s15 rdv2/s15 ville2/train1.var', 'ville2', 'BV';
%     './s16 rdv1/s16 autor2/train1.var', 'autor2', 'noBV';
%     './s16 rdv1/s16 natio1/train1.var', 'natio1', 'noBV';
%     './s16 rdv2/s16 autor1/train1.var', 'autor1', 'noBV';
%     './s16 rdv2/s16 natio2/train1.var', 'natio2', 'noBV';
%     './s16 rdv2/s16 ville2/train1.var', 'ville2', 'BV';
%     './S17 rdv-1/autor2/train1.var', 'autor2', 'noBV';
%     './S17 rdv-1/Natio1/train1.var', 'natio1', 'noBV';
%     './S17 rdv-1/ville/train1.var', 'ville1', 'noBV';
%     './s17 rdv-2/s17 autor1/train1.var', 'autor1', 'noBV';
%     './s17 rdv-2/s17 natio2/train1.var', 'natio2', 'noBV';
%     './s17 rdv-2/s17 ville2/train1.var', 'ville2', 'BV';
%     './s18 rdv1/s18 autor1/train1.var', 'autor1', 'noBV';
%     './s18 rdv1/s18 natio2/train1.var', 'natio2', 'noBV';
%     './s18 rdv1/s18 ville1 sans dern flot/train1.var', 'ville1', 'noBV';
%     './s18 rdv2/s18 auor2/train1.var', 'autor2', 'noBV';
%     './s18 rdv2/s18 autor2/train1.var', 'autor2', 'noBV';
%     './s18 rdv2/s18 natio1/train1.var', 'natio1', 'noBV';
%     './s20 rdv-1/s20 autor2/train1.var', 'autor2', 'noBV';
%     './s20 rdv-1/s20 natio1/train1.var', 'natio1', 'noBV';
%     './s20 rdv-1/s20 ville/train1.var', 'ville1', 'noBV';
%     './s20 rdv-2/s20 autor1/train1.var', 'autor1', 'noBV';
%     './s20 rdv-2/s20 natio2/train1.var', 'natio2', 'noBV';
%     './s20 rdv-2/s20 ville2/train1.var', 'ville2', 'BV';
%     './s21 rdv1/s21 autor1/train1.var', 'autor1', 'noBV';
%     './s21 rdv1/s21 natio2/train1.var', 'natio2', 'noBV';
%     './s21 rdv1/s21 ville1/train1.var', 'ville1', 'BV';
%     './s21 rdv2/s21 autor2/train1.var', 'autor2', 'noBV';
%     './s21 rdv2/s21 natio1/train1.var', 'natio1', 'noBV';
%     './s21 rdv2/s21 ville2/train1.var', 'ville2', 'BV';
%     './s23 rdv1/s23 autor2/train1.var', 'autor2', 'noBV';
%     './s23 rdv1/s23 natio1/train1.var', 'natio1', 'noBV';
%     './s23 rdv1/s23 ville1/train1.var', 'ville1', 'BV';
%     './s23 rdv2/s23 autor1/train1.var', 'autor1', 'noBV';
%     './s23 rdv2/s23 natio2/train1.var', 'natio2', 'noBV';
%     './s23 rdv2/s23 ville2/train1.var', 'ville2', 'noBV';
%     './s24 rdv-2/s24 natio2/train1.var', 'natio2', 'noBV';
%     './s24 rdv-2/s24 ville2/train1.var', 'ville2', 'BV';
%     './s24 rdv1/s24 autor2/train1.var', 'autor2', 'noBV';
%     './s24 rdv1/s24 natio1/train1.var', 'natio1', 'noBV';
%     './s24 rdv1/s24 ville1/train1.var', 'ville1', 'noBV';
%     './s25 rdv1/s25 autor2/train1.var', 'autor2', 'noBV';
%     './s25 rdv1/s25 natio1/train1.var', 'natio1', 'noBV';
%     './s25 rdv1/s25 ville1/train1.var', 'ville1', 'BV';
%     './s25 rdv2/s25 autor1/train1.var', 'autor1', 'noBV';
%     './s25 rdv2/s25 natio2/train1.var', 'natio2', 'noBV';
%     './s25 rdv2/s25 ville2/train1.var', 'ville2', 'BV';
%      './s26 2/s26 autor2/train1.var', 'autor2', 'noBV';
%     './s26 2/s26 natio1/train1.var', 'natio1', 'noBV';
%     './s26 2/s26 ville2/train1.var', 'ville2', 'BV';
%     './s26 rdv1/s26 autor1/train1.var', 'autor1', 'noBV';
%     './s26 rdv1/s26 natio2/train1.var', 'natio2', 'noBV';
%     './s27 rdv1/s27 autor2/train1.var', 'autor2', 'noBV';
%     './s27 rdv1/s27 natio1/train1.var', 'natio1', 'noBV';
%     './s27 rdv1/s27 ville1/train1.var', 'ville1', 'BV';
%     './s27 rdv2/s27 autor1/train1.var', 'autor1', 'noBV';
%     './s27 rdv2/s27 natio2/train1.var', 'natio2', 'noBV';
%     './s27 rdv2/s27 ville2/train1.var', 'ville2', 'BV';
%     './s28 rdv1/s28 autor2/train1.var', 'autor2', 'noBV';
%     './s28 rdv1/s28 natio1/train1.var', 'natio1', 'noBV';
%     './s28 rdv1/s28 ville1/train1.var', 'ville1', 'noBV';
%     './s28 rdv2/s28 autor1/train1.var', 'autor1', 'noBV';
%     './s28 rdv2/s28 natio2/train1.var', 'natio2', 'noBV';
%     './s28 rdv2/s28 ville2/train1.var', 'ville2', 'noBV';
%     './s29 rdv1/s29 autor1/train1.var', 'autor1', 'noBV';
%     './s29 rdv1/s29 natio2/train1.var', 'natio2', 'noBV';
%     './s29 rdv1/s29 ville1/train1.var', 'ville1', 'BV';
%     './s29 rdv2/s29 autor2/train1.var', 'autor2', 'noBV';
%     './s29 rdv2/s29 natio1/train1.var', 'natio1', 'noBV';
%     './s29 rdv2/s29 ville2/train1.var', 'ville2', 'BV';
%     './s30 rdv1/s30 autor2/train1.var', 'autor2', 'noBV';
%     './s30 rdv1/s30 natio1/train1.var', 'natio1', 'noBV';
%     './s30 rdv1/s30 ville1/train1.var', 'ville1', 'BV';
%     './s30 rdv2/s30 autor1/train1.var', 'autor1', 'noBV';
%     './s30 rdv2/s30 ville2/train1.var', 'ville2', 'BV';
 %     's30 rdv2/s30 natio2/s30_rdv2_natio2/train1.var', 'natio2', 'noBV';
%     './s32 rdv1/s32 autor2/train1.var', 'autor2', 'noBV';
%     './s32 rdv1/s32 natio1/train1.var', 'natio1', 'noBV';
%     './s32 rdv1/s32 ville1/train1.var', 'ville1', 'BV';
%     './s32 rdv2/s32 autor1/train1.var', 'autor1', 'noBV';
%     './s32 rdv2/s32 natio2/train1.var', 'natio2', 'noBV';
%     './s32 rdv2/s32 ville2/train1.var', 'ville2', 'BV';
%     './s33 rdv1/sA autor1/train1.var', 'autor1', 'noBV';
%     './s33 rdv1/sA natio2/train1.var', 'natio2', 'noBV';
%     './s33 rdv1/sA ville 1/train1.var', 'ville1', 'BV';
%     './s33 rdv2/s33 autor2/train1.var', 'autor2', 'noBV';
%     './s33 rdv2/s33 natio1/train1.var', 'natio1', 'noBV';
%     './s33 rdv2/s33 ville2/train1.var', 'ville2', 'BV';
%     './s34 rdv1/s34 autor1/train1.var', 'autor1', 'noBV';
%     './s34 rdv1/s34 natio2/train1.var', 'natio2', 'noBV';
%     './s34 rdv1/s34 ville1/train1.var', 'ville1', 'BV';
%     './s34 rdv2/s34 autor2/train1.var', 'autor2', 'noBV';
%     './s34 rdv2/s34 natio1/train1.var', 'natio1', 'noBV';
%     './s34 rdv2/s34 ville2/train1.var', 'ville2', 'BV';
%     './s35 rdv1/s35 autor2/train1.var', 'autor2', 'noBV';
%     './s35 rdv1/s35 natio1/train1.var', 'natio1', 'noBV';
%     './s35 rdv1/s35 ville1/train1.var', 'ville1', 'BV';
%     './s35 rdv2/s35 ville2/train1.var', 'ville2', 'BV';
%     './s36 rdv1/s36 autor1/train1.var', 'autor1', 'noBV';
%     './s36 rdv1/s36 natio2/train1.var', 'natio2', 'noBV';
%     './s36 rdv2/s36 autor2/train1.var', 'autor2', 'noBV';
%     './s36 rdv2/s36 natio1/train1.var', 'natio1', 'noBV';
%     './s37 rdv1/s37 autor1/train1.var', 'autor1', 'noBV';
%     './s37 rdv1/s37 natio2/train1.var', 'natio2', 'noBV';
%     './s37 rdv1/s37 ville1 sans dern flot/train1.var', 'ville1', 'BV';
%     './s38 rdv1/s38 autor1/train1.var', 'autor1', 'noBV';
%        './s38 rdv2_/s38 autor2/train1.var', 'autor2', 'noBV';
%     './s40 rdv1/s40 autor1/train1.var', 'autor1', 'noBV';
%     './s40 rdv1/s40 natio2/train1.var', 'natio2', 'noBV';
%     './s40 rdv1/s40 ville1/train1.var', 'ville1', 'BV';
%     './s40 rdv2/s40 autor2/train1.var', 'autor2', 'noBV';
%     './s40 rdv2/s40 natio1/train1.var', 'natio1', 'noBV';
%     './s40 rdv2/s40 ville2/train1.var', 'ville2', 'BV';
%     './s41 rdv1/s41 autor2/train1.var', 'autor2', 'noBV';
%     './s41 rdv2/s41 autor1/train1.var', 'autor1', 'noBV';
%     './s41 rdv2/s41 natio2/train1.var', 'natio2', 'noBV';
%      './s41 rdv1/s41 natio1 2/s41_rdv1_natio1 2/train1.var', 'natio1', 'noBV';
%     './s43 rdv1/s43 natio1/train1.var', 'natio1', 'noBV';
%     './s43 rdv1/s43 ville1/train1.var', 'ville1', 'BV';
%     './s43 rdv2/s43 autor1/train1.var', 'autor1', 'noBV';
%     './s43 rdv2/s43 natio2/train1.var', 'natio2', 'noBV';
%     './s43 rdv2/s43 ville/train1.var', 'ville2', 'BV';
%     './s45 rdv1/s45 autor1/train1.var', 'autor1', 'noBV';
%     './s45 rdv1/s45 natio2/train1.var', 'natio2', 'noBV';
%     './s45 rdv1/s45 ville1/train1.var', 'ville1', 'BV';
%     './s45 rdv2/s45 autor2/train1.var', 'autor2', 'noBV';
%     './s45 rdv2/s45 natio1/train1.var', 'natio1', 'noBV';
%     './s45 rdv2/s45 ville2/train1.var', 'ville2', 'BV'
};



mappingFile = ['mapping' mappingType '.xml'];

for i = 1:1:size(varList, 1)
    varFile = varList{i, 1};
    varScenario = varList{i, 2};
    headerType =  varList{i, 3};
    [varFolder, varFileName, ~] = fileparts(varFile);
    tripFullPath = [varFolder filesep varFileName '.trip'];
    disp('--------------------------------------------------------');
    disp(['Treating ' varFile ' :' varScenario]);
    try
        disp('------------------------ Step 1 ------------------------');
        Step1_fixHeaders(varFile, headerType);
        disp('------------------------ Step 2 ------------------------');
        Step2_importVarFile(mappingFile, varFile, varFolder);
        disp('------------------------ Step 3 ------------------------');
        Step3_deleteEmptyDatas(tripFullPath);
        disp('------------------------ Step 4 ------------------------');
        Step4_reorganizeData(tripFullPath, varScenario);
        log = fopen('BatchImport.log', 'a+');
        fprintf(log, '%s\n', [datestr(now) ' : ' varFile 'OK']);
        fprintf(log, '%s\n', '---------------------------------------------------------------------------------');
        fclose(log);
    catch ME
        disp('Error caught, logging and skipping to next file');
        log = fopen('BatchImport.log', 'a+');
        fprintf(log, '%s\n', [datestr(now) ' : Error with this trip : ' varFile]);
        fprintf(log, '%s', ME.getReport('extended', 'hyperlinks', 'off'));
        fprintf(log, '%s\n', '---------------------------------------------------------------------------------');
        fclose(log);
    end
end