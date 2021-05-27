%Convertisseur ACQ -> MAT

clc;clear all;close all
Fe = 500; 

SITUATION = {'BAC 02' 'BAC 05' 'Placebo'};

for suj = [13:16]
    newsuj = suj-1;
    for situation = 1:3
        
        % E:\JOFFREY\Repos_acq
blaze = ['G18_S' num2str(newsuj) '_' cell2mat(SITUATION(situation)) '_Repos'];
nameacq = ['E:\JOFFREY\Repos_acq\' blaze '.acq'];
mat = acq2mat(nameacq);

% Save de la structure des données sujet
namemat = blaze;

cd('E:\JOFFREY\Repos_mat')
%E:\JOFFREY\Repos_mat


%namemat(end-1)=[];

save (namemat,'mat')
% 
clear mat


    end
    
end



