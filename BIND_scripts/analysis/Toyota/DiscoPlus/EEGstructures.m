%Convertisseur ACQ -> MAT

clc;clear all;close all
Fe = 500; 

SITUATION = {'BAC 0.2' 'BAC 0.5' 'Placebo'};


   
for suj = [1:16]
    
    for situation = 1:2
        
        

nameacq = ['E:\LAURENT\EEG Alcool\Sujet ' num2str(suj) ' ' cell2mat(SITUATION(situation)) '.acq']


mat = acq2mat(nameacq);


% Save de la structure des données sujet
namemat = ['G18_S' num2str(suj) '_' cell2mat(SITUATION(situation))];

cd('E:\LAURENT\EEG Alcool')


namemat(end-1)=[];

save (namemat,'mat')
% 
clear mat


    end
    
end



