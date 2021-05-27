close all
%clear all

cd('D:\LESCOT\PROJETS\ACT2')

REP = 'D:\LESCOT\PROJETS\ACT2\DATA';
if  ~exist(fullfile(REP,'figs'),'dir')
    mkdir(REP,'figs');
end
REP_fig = fullfile(REP,'figs');


%[temps,TIV,TTC,acc,frein,com1,com2] = import_var_ACT('D:\LESCOT\PROJETS\ACT2\DATA\17101417.var');
[timecode,Essai,Virage] = formatageTimecodeEssaiVirage(temps,com1);

%[temps,heureGMT,acc,frein,commentaires1,commentaires2,commentaires3] = import_var_ACT2();
acc_ini = acc;
N=length(temps);

%% TRAITEMENT DE RETOUR A ZERO
ind_acc_nz = find(acc~=0);
for i=1:1:length(ind_acc_nz)-1
    if ind_acc_nz(i+1) - ind_acc_nz(i) < 4
    acc(ind_acc_nz(i)+1 : ind_acc_nz(i+1)- 1) = (acc(ind_acc_nz(i+1)) + acc(ind_acc_nz(i)))/2;
    end      
end

ind_acc_z = find(acc==0);
for i=1:1:length(ind_acc_z)-1
    if ind_acc_z(i+1) - ind_acc_z(i) < 4
    acc(ind_acc_z(i)+1 : ind_acc_z(i+1)- 1) = 0;
    end      
end   

%% FILTRE MOVING AVEERAGE
n_largeur = 5;
square = [zeros(n_largeur,1) ; ones(n_largeur,1)/n_largeur  ];
acc_filt = conv(acc,square,'same');
acc_filt(acc<2)=0;

%% CALCUL DES TEMPS DE REACTION PEDALE ACC
ReactionTime = CalculerReactionTime(timecode,acc_filt,Essai);

%% TRACER DES GRAPHES
Plot_ReactionTime(timecode,acc,acc_filt,Essai,ReactionTime,2,'D:\LESCOT\PROJETS\ACT2\DATA\17101417.var',REP_fig)






