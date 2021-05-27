close all

chercheur ='GERMAN';

trips_folder= ['D:\LESCOT\PROJETS\SGSAS\DATA_' chercheur '\'];
fig_folder = ['D:\LESCOT\PROJETS\SGSAS\Plot _ PosVoie AngleVolant\' chercheur];

trips_list = dirrec(trips_folder, '.trip');

for i_trip=1:1:length(trips_list)
trip_path = trips_list{i_trip};

[file_path,participant,ext]=fileparts(trip_path);

trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_path, 0.04, true);

clear timecode timecode_trajectoire

record_vitesse = trip.getAllDataOccurences('vitesse');

timecode =  cell2mat(record_vitesse.getVariableValues('timecode'));
timecode_deb = timecode(1);

try
acc = (100/255)* cell2mat(record_vitesse.getVariableValues('accélérateur'));
catch
acc = (100/255)* cell2mat(record_vitesse.getVariableValues('accelerateur'));   
end
brake =(100/255)* cell2mat(record_vitesse.getVariableValues('frein'));
clutch = (100/255)* cell2mat(record_vitesse.getVariableValues('embrayage'));


try
situation_stimulation = trip.getAllSituationOccurences('Stimulation_CURVE');
catch
end

try
situation_stimulation = trip.getAllSituationOccurences('Stimulation_ALL');
catch
end


startTC = cell2mat( situation_stimulation.getVariableValues('startTimecode'));
endTC = cell2mat( situation_stimulation.getVariableValues('endTimecode'));

stim = zeros(size(timecode));
h1=figure;
for i=1:1:size(startTC,2)
    
    record_trajectoire=trip.getDataOccurencesInTimeInterval('trajectoire',startTC(i),endTC(i));
    timecode_trajectoire = (cell2mat(record_trajectoire.getVariableValues('timecode'))-timecode_deb)/60.0;
    PositionVoie = cell2mat(record_trajectoire.getVariableValues('voie'));
    AngleVolant = cell2mat(record_trajectoire.getVariableValues('angle volant'));
    
    stim(timecode > startTC(i) & timecode < endTC(i)) = 100;
    
   
    subplot(6,3,i), [AX,p1,P2] = plotyy(timecode_trajectoire,PositionVoie,timecode_trajectoire,AngleVolant);
    title([participant '- simulation' num2str(i)])
    xlim(AX(1),[min(timecode_trajectoire) max(timecode_trajectoire)])
    xlim(AX(2),[min(timecode_trajectoire) max(timecode_trajectoire)])
    set(AX(1),'FontSize', 7)
    set(AX(2),'FontSize', 7)
    if i==1
    legend('PositionVoie','Angle Volant')
    end


    
end
screen_size = get(0, 'ScreenSize');
set(h1, 'Position', [0 0 screen_size(3) screen_size(4) ] );


hgsave(h1, [fig_folder '\' participant '_stim'])
print(h1,[fig_folder '\' participant],'-djpeg','-r800')

h2=figure;
patch(timecode,stim,[0.7 1 1])
hold on
plot(timecode,acc,timecode,brake,timecode,clutch,'linewidth',2)
legend('stimulation','accelerateur','frein','embrayage')
title([participant ext])
hgsave(h2, [fig_folder '\' participant '_fulltrip'])



delete(trip);
end