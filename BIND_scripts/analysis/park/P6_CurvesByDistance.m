function P6_CurvesByDistance(directory)
if nargin < 1
    % select the directory containing the data
    directory = uigetdir(char(java.lang.System.getProperty('user.home')));
end

import fr.lescot.bind.processing.*

% find the correct file for the trip database
pattern = '*.trip';
tripFile =  fullfile(directory, pattern);
listing = dir(tripFile);
tripFile = fullfile(directory, listing.name);


mkdir([directory filesep 'CurvesByDistance']);

% create a BIND trip object from the database
theTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFile,0.04,false);

% Use BIND to read data in matlab workspace
situationPOI = theTrip.getAllSituationOccurences('Intersection');
id = cell2mat(situationPOI.getVariableValues('Number'));
starttime = cell2mat(situationPOI.getVariableValues('startTimecode'));
endtime = cell2mat(situationPOI.getVariableValues('endTimecode'));
dataPOI = theTrip.getAllEventOccurences('POI');
timePOI = dataPOI.getVariableValues('TimeCode');
distancePOI = cell2mat(theTrip.getDataVariableValuesInterpolatedAccordingToTimecode(timePOI,'SensorsMeasures','DistanceDriven'));

index = 1; % counter for the number of the intersection
ind = 1; % counter for the number of the POI
i = 1; % indicatice to skim all the intersections
while i <= length(id)
    % First case: the intersections with only the "Entry Intersection"
    if id(i) == 40 || id(i) == 22
        set(gcf,'Position',[1,31,1280,920]);

        record1 = theTrip.getDataOccurencesInTimeInterval('SensorsMeasures',starttime(i), endtime(i));
        result1 = record1.buildCellArrayWithVariables({'timecode' 'Speed' 'SteeringwheelAngle' 'Gyrometer' 'AccX' 'AccY' 'DistanceDriven'});
        time = result1(1,:);
        speed = cell2mat(result1(2,:));
        angle = cell2mat(result1(3,:));
        gyrometer = cell2mat(result1(4,:));
        accx = result1(5,:);
        accy = result1(6,:);
        distance = cell2mat(result1(7,:));

        clignotant = cell2mat(theTrip.getDataVariableValuesInterpolatedAccordingToTimecode(time,'SensorsData','Clignotant'));
        
        acc = theTrip.getDataVariableValuesInterpolatedAccordingToTimecode(time,'ProcessedData','%Accelerator');
        brake = theTrip.getDataVariableValuesInterpolatedAccordingToTimecode(time,'ProcessedData','%Brake');
        clutch = theTrip.getDataVariableValuesInterpolatedAccordingToTimecode(time,'ProcessedData','%Clutch');
                
        subplot(6,2,1);
        plot(distance,speed);
        grid
        ylabel('Speed','FontSize',6);
        title(strcat('Evolution of the SPEED in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[distance(1) distancePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        set(gca,'ylim',[0 120]);
        set(gca,'ytick',[0 60 120]);
        
        subplot(6,2,2);
        plot(distance,angle);
        grid
        ylabel('Angle','FontSize',6);
        title(strcat('Evolution of the ANGLE in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[distance(1) distancePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        set(gca,'ylim',[-500 500]);
        set(gca,'ytick',[-500 0 500]);
        
        subplot(6,2,3);
        plot(distance,gyrometer);
        grid
        ylabel('Gyrometer','FontSize',6);
        title(strcat('Evolution of the GYROMETER in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);   
        set(gca,'xtick',[distance(1) distancePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        
        subplot(6,2,4);
        plot(distance,clignotant);
        grid
        ylabel('Clignotant','FontSize',6);
        title(strcat('Evolution of the CLIGNOTANT in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[distance(1) distancePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        
        subplot(6,2,5);
        plot(distance,cell2mat(acc));
        grid
        ylabel('%Accelerator','FontSize',6);
        title(strcat('Evolution of the %ACCELERATOR in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[distance(1) distancePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);     
        
        subplot(6,2,6);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([time;acc],{num2str(50)});
        derivAcc = cell2mat(processedData(2,:));
        plot(distance,derivAcc);
        grid
        ylabel('Derivative %Accelerator','FontSize',6);
        title(strcat('Derivative of %Accelerator in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[distance(1) distancePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        
        subplot(6,2,7);
        plot(distance,cell2mat(brake));
        grid
        ylabel('%Brake','FontSize',6);
        title(strcat('Evolution of the %BRAKE in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[distance(1) distancePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,8);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([time;brake],{num2str(50)});
        derivBrake = cell2mat(processedData(2,:));
        plot(distance,derivBrake);
        grid
        ylabel('Derivative %Brake','FontSize',6);
        title(strcat('Derivative of %Brake in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[distance(1) distancePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        
        subplot(6,2,9);
        plot(distance,cell2mat(clutch));
        grid
        ylabel('%Clutch','FontSize',6);
        title(strcat('Evolution of the %CLUTCH in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[distance(1) distancePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,10);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([time;clutch],{num2str(50)});
        derivClutch = cell2mat(processedData(2,:));
        plot(distance,derivClutch);
        grid
        ylabel('Derivative %Clutch','FontSize',6);
        title(strcat('Derivative of %Clutch in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[distance(1) distancePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        
        subplot(6,2,11);
        processedData = fr.lescot.bind.processing.signalProcessors.MovingAverageSmoothing.process([time;accx],{num2str(12)});
        masAccx = cell2mat(processedData(2,:));
        plot(distance,masAccx);
        grid
        ylabel('MovingAverage AccX','FontSize',6);
        title(strcat('Moving Average of AccX in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[distance(1) distancePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        
        subplot(6,2,12);
        processedData = fr.lescot.bind.processing.signalProcessors.MovingAverageSmoothing.process([time;accy],{num2str(12)});
        masAccy = cell2mat(processedData(2,:));
        plot(distance,masAccy);
        grid
        ylabel('MovingAverage AccY','FontSize',6);
        title(strcat('Moving Average of AccY in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[distance(1) distancePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        
        saveas(gcf,[directory filesep 'CurvesByDistance' filesep 'Intersection' num2str(index)], 'png');
        
        index = index + 1;
        ind = ind + 1;
        i = i + 1;
    
    % Second case : the intersection with no zones to explore, which,in fact, is an Eventment 
    % So we don't have graphs to display but its details
%     elseif id(i) == 41
%         
%         record1 = theTrip.getDataOccurencesInTimeInterval('SensorsMeasures',starttime(i), endtime(i));
%         result1 = record1.buildCellArrayWithVariables({'timecode' 'Speed' 'SteeringwheelAngle' 'Gyrometer' 'AccX' 'AccY'});
%         time = result1(1,:);
%         speed = cell2mat(result1(2,:));
%         angle = cell2mat(result1(3,:));
%         gyrometer = cell2mat(result1(4,:));
%         accx = cell2mat(result1(5,:));
%         accy = cell2mat(result1(6,:));
%         clignotant = cell2mat(theTrip.getDataVariableValuesInterpolatedAccordingToTimecode(time,'SensorsData','Clignotant'));
%         acc = cell2mat(theTrip.getDataVariableValuesInterpolatedAccordingToTimecode(time,'ProcessedData','%Accelerator'));
%         brake = cell2mat(theTrip.getDataVariableValuesInterpolatedAccordingToTimecode(time,'ProcessedData','%Brake'));
%         clutch = cell2mat(theTrip.getDataVariableValuesInterpolatedAccordingToTimecode(time,'ProcessedData','%Clutch'));
%         
%         close
%         disp('---About the POINT FEU---');
%         message = ['Speed: ' num2str(speed(1)) ';'];
%         disp(message);
%         message = ['Angle: ' num2str(angle(1)) ';'];
%         disp(message);
%         message = ['Gyrometer: ' num2str(gyrometer(1)) ';'];
%         disp(message);
%         message = ['Clignotant: ' num2str(clignotant(1)) ';'];
%         disp(message);
%         message = ['AccX: ' num2str(accx(1)) ';'];
%         disp(message);
%         message = ['AccY: ' num2str(accy(1)) ';'];
%         disp(message);
%         message = ['%Accelerator: ' num2str(acc(1)) ';'];
%         disp(message);
%         message = ['%Brake: ' num2str(brake(1)) ';'];
%         disp(message);
%         message = ['%Clutch: ' num2str(clutch(1)) '.'];
%         disp(message);
%         
%         index = index + 1;
%         ind = ind + 1;
%         i = i + 1;
      
    % Third case : the general intersections with three phases"Entry
    % Intersection""Intersection""Exit Intersection"    
    else
        set(gcf,'Position',[1,31,1280,920]);
        
        record1 = theTrip.getDataOccurencesInTimeInterval('SensorsMeasures',starttime(i), endtime(i+2));
        result1 = record1.buildCellArrayWithVariables({'timecode' 'Speed' 'SteeringwheelAngle' 'Gyrometer' 'AccX' 'AccY' 'DistanceDriven'});
        time = result1(1,:);
        speed = cell2mat(result1(2,:));
        angle = cell2mat(result1(3,:));
        gyrometer = cell2mat(result1(4,:));
        accx = result1(5,:);
        accy = result1(6,:);
        distance = cell2mat(result1(7,:));

        clignotant = cell2mat(theTrip.getDataVariableValuesInterpolatedAccordingToTimecode(time,'SensorsData','Clignotant'));
        
        acc = theTrip.getDataVariableValuesInterpolatedAccordingToTimecode(time,'ProcessedData','%Accelerator');
        brake = theTrip.getDataVariableValuesInterpolatedAccordingToTimecode(time,'ProcessedData','%Brake');
        clutch = theTrip.getDataVariableValuesInterpolatedAccordingToTimecode(time,'ProcessedData','%Clutch');
               
        [distance(1) distancePOI(ind) distancePOI(ind+1) distance(length(distance))]
        xtick1 = distance(1);
        xtick2 = distancePOI(ind);
        xtick3 = distancePOI(ind+1);
        xtick4 = distance(length(distance));
        if xtick2 == xtick3
            disp('Ajustement auto');
            xtick3 = xtick3 + ((xtick4 - xtick3)/2);
        end
        [xtick1 xtick2 xtick3 xtick4]
        
        subplot(6,2,1);
        plot(distance,speed);
        grid
        ylabel('Speed','FontSize',6);
        title(strcat('Evolution of the SPEED in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2 xtick3 xtick4]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(distance(length(distance))),'(ExitInt',num2str(index),')')},'FontSize',6);
        set(gca,'ylim',[0 120]);
        set(gca,'ytick',[0 60 120]);
        
        subplot(6,2,2);
        plot(distance,angle);
        grid
        ylabel('Angle','FontSize',6);
        title(strcat('Evolution of the ANGLE in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2 xtick3 xtick4]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(distance(length(distance))),'(ExitInt',num2str(index),')')},'FontSize',6);
        set(gca,'ylim',[-500 500]);
        set(gca,'ytick',[-500 0 500]);
        
        subplot(6,2,3);
        plot(distance,gyrometer);
        grid
        ylabel('Gyrometer','FontSize',6);
        title(strcat('Evolution of the GYROMETER in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2 xtick3 xtick4]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(distance(length(distance))),'(ExitInt',num2str(index),')')},'FontSize',6);
        
        subplot(6,2,4);
        plot(distance,clignotant);
        grid
        ylabel('Clignotant','FontSize',6);
        title(strcat('Evolution of the CLIGNOTANT in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2 xtick3 xtick4]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(distance(length(distance))),'(ExitInt',num2str(index),')')},'FontSize',6);
        
        subplot(6,2,5);
        plot(distance,cell2mat(acc));
        grid
        ylabel('%Accelerator','FontSize',6);
        title(strcat('Evolution of the %ACCELERATOR in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2 xtick3 xtick4]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(distance(length(distance))),'(ExitInt',num2str(index),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);     
        
        subplot(6,2,6);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([time;acc],{num2str(50)});
        derivAcc = cell2mat(processedData(2,:));
        plot(distance,derivAcc);
        grid
        ylabel('Derivative %Accelerator','FontSize',6);
        title(strcat('Derivative of %Accelerator in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2 xtick3 xtick4]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(distance(length(distance))),'(ExitInt',num2str(index),')')},'FontSize',6);
               
        subplot(6,2,7);
        plot(distance,cell2mat(brake));
        grid
        ylabel('%Brake','FontSize',6);
        title(strcat('Evolution of the %BRAKE in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2 xtick3 xtick4]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(distance(length(distance))),'(ExitInt',num2str(index),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,8);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([time;brake],{num2str(50)});
        derivBrake = cell2mat(processedData(2,:));
        plot(distance,derivBrake);
        grid
        ylabel('Derivative %Brake','FontSize',6);
        title(strcat('Derivative of %Brake in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2 xtick3 xtick4]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(distance(length(distance))),'(ExitInt',num2str(index),')')},'FontSize',6);
        
        subplot(6,2,9);
        plot(distance,cell2mat(clutch));
        grid
        ylabel('%Clutch','FontSize',6);
        title(strcat('Evolution of the %CLUTCH in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2 xtick3 xtick4]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(distance(length(distance))),'(ExitInt',num2str(index),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,10);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([time;clutch],{num2str(50)});
        derivClutch = cell2mat(processedData(2,:));
        plot(distance,derivClutch);
        grid
        ylabel('Derivative %Clutch','FontSize',6);
        title(strcat('Derivative of %Clutch in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2 xtick3 xtick4]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(distance(length(distance))),'(ExitInt',num2str(index),')')},'FontSize',6);
        
        subplot(6,2,11);
        processedData = fr.lescot.bind.processing.signalProcessors.MovingAverageSmoothing.process([time;accx],{num2str(12)});
        masAccx = cell2mat(processedData(2,:));
        plot(distance,masAccx);
        grid
        ylabel('MovingAverage AccX','FontSize',6);
        title(strcat('Moving Average of AccX in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2 xtick3 xtick4]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(distance(length(distance))),'(ExitInt',num2str(index),')')},'FontSize',6);
        
        subplot(6,2,12);
        processedData = fr.lescot.bind.processing.signalProcessors.MovingAverageSmoothing.process([time;accy],{num2str(12)});
        masAccy = cell2mat(processedData(2,:));
        plot(distance,masAccy);
        grid
        ylabel('MovingAverage AccY','FontSize',6);
        title(strcat('Moving Average of AccY in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2 xtick3 xtick4]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(distance(length(distance))),'(ExitInt',num2str(index),')')},'FontSize',6);

        saveas(gcf,[directory filesep 'CurvesByDistance' filesep 'Intersection' num2str(index)], 'png');
        
        
        % Devide an intersection into three zones
        % Create the folder for each intersection
        mkdir([directory filesep 'CurvesByDistance' filesep 'Intersection' num2str(index)]);
        % Entry Intersection
        record1 = theTrip.getDataOccurencesInTimeInterval('SensorsMeasures',starttime(i), endtime(i));
        result1 = record1.buildCellArrayWithVariables({'timecode' 'Speed' 'SteeringwheelAngle' 'Gyrometer' 'AccX' 'AccY' 'DistanceDriven'});
        time = result1(1,:);
        speed = cell2mat(result1(2,:));
        angle = cell2mat(result1(3,:));
        gyrometer = cell2mat(result1(4,:));
        accx = result1(5,:);
        accy = result1(6,:);
        distance = cell2mat(result1(7,:));

        clignotant = cell2mat(theTrip.getDataVariableValuesInterpolatedAccordingToTimecode(time,'SensorsData','Clignotant'));
        
        acc = theTrip.getDataVariableValuesInterpolatedAccordingToTimecode(time,'ProcessedData','%Accelerator');
        brake = theTrip.getDataVariableValuesInterpolatedAccordingToTimecode(time,'ProcessedData','%Brake');
        clutch = theTrip.getDataVariableValuesInterpolatedAccordingToTimecode(time,'ProcessedData','%Clutch');
                
        subplot(6,2,1);
        plot(distance,speed);
        ylabel('Speed','FontSize',6);
        title(strcat('Evolution of the SPEED in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[distance(1) distancePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        set(gca,'ylim',[0 120]);
        set(gca,'ytick',[0 60 120]);
        
        subplot(6,2,2);
        plot(distance,angle);
        grid
        ylabel('Angle','FontSize',6);
        title(strcat('Evolution of the ANGLE in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[distance(1) distancePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        set(gca,'ylim',[-500 500]);
        set(gca,'ytick',[-500 0 500]);
        
        subplot(6,2,3);
        plot(distance,gyrometer);
        grid
        ylabel('Gyrometer','FontSize',6);
        title(strcat('Evolution of the GYROMETER in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);   
        set(gca,'xtick',[distance(1) distancePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        
        subplot(6,2,4);
        plot(distance,clignotant);
        grid
        ylabel('Clignotant','FontSize',6);
        title(strcat('Evolution of the CLIGNOTANT in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[distance(1) distancePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        
        subplot(6,2,5);
        plot(distance,cell2mat(acc));
        grid
        ylabel('%Accelerator','FontSize',6);
        title(strcat('Evolution of the %ACCELERATOR in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[distance(1) distancePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);     
        
        subplot(6,2,6);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([time;acc],{num2str(50)});
        derivAcc = cell2mat(processedData(2,:));
        plot(distance,derivAcc);
        grid
        ylabel('Derivative %Accelerator','FontSize',6);
        title(strcat('Derivative of %Accelerator in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[distance(1) distancePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        
        subplot(6,2,7);
        plot(distance,cell2mat(brake));
        grid
        ylabel('%Brake','FontSize',6);
        title(strcat('Evolution of the %BRAKE in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[distance(1) distancePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,8);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([time;brake],{num2str(50)});
        derivBrake = cell2mat(processedData(2,:));
        plot(distance,derivBrake);
        grid
        ylabel('Derivative %Brake','FontSize',6);
        title(strcat('Derivative of %Brake in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[distance(1) distancePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        
        subplot(6,2,9);
        plot(distance,cell2mat(clutch));
        grid
        ylabel('%Clutch','FontSize',6);
        title(strcat('Evolution of the %CLUTCH in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[distance(1) distancePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,10);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([time;clutch],{num2str(50)});
        derivClutch = cell2mat(processedData(2,:));
        plot(distance,derivClutch);
        grid
        ylabel('Derivative %Clutch','FontSize',6);
        title(strcat('Derivative of %Clutch in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[distance(1) distancePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        
        subplot(6,2,11);
        processedData = fr.lescot.bind.processing.signalProcessors.MovingAverageSmoothing.process([time;accx],{num2str(12)});
        masAccx = cell2mat(processedData(2,:));
        plot(distance,masAccx);
        grid
        ylabel('MovingAverage AccX','FontSize',6);
        title(strcat('Moving Average of AccX in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[distance(1) distancePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        
        subplot(6,2,12);
        processedData = fr.lescot.bind.processing.signalProcessors.MovingAverageSmoothing.process([time;accy],{num2str(12)});
        masAccy = cell2mat(processedData(2,:));
        plot(distance,masAccy);
        grid
        ylabel('MovingAverage AccY','FontSize',6);
        title(strcat('Moving Average of AccY in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[distance(1) distancePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(distance(1)),'(EntryInt',num2str(index),')'),strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        
        saveas(gcf,[directory filesep 'CurvesByDistance' filesep 'Intersection' num2str(index) filesep 'Entry'], 'png');
        
        % Middle Intersection
        record1 = theTrip.getDataOccurencesInTimeInterval('SensorsMeasures',starttime(i+1), endtime(i+1));
        result1 = record1.buildCellArrayWithVariables({'timecode' 'Speed' 'SteeringwheelAngle' 'Gyrometer' 'AccX' 'AccY' 'DistanceDriven'});
        time = result1(1,:);
        speed = cell2mat(result1(2,:));
        angle = cell2mat(result1(3,:));
        gyrometer = cell2mat(result1(4,:));
        accx = result1(5,:);
        accy = result1(6,:);
        distance = cell2mat(result1(7,:));

        clignotant = cell2mat(theTrip.getDataVariableValuesInterpolatedAccordingToTimecode(time,'SensorsData','Clignotant'));
        
        acc = theTrip.getDataVariableValuesInterpolatedAccordingToTimecode(time,'ProcessedData','%Accelerator');
        brake = theTrip.getDataVariableValuesInterpolatedAccordingToTimecode(time,'ProcessedData','%Brake');
        clutch = theTrip.getDataVariableValuesInterpolatedAccordingToTimecode(time,'ProcessedData','%Clutch');
        
        xtick1 = distancePOI(ind);
        xtick2 = distancePOI(ind+1);
        if xtick1 == xtick2
            xtick2 = xtick2 * 1.01;
        end
        subplot(6,2,1);
        plot(distance,speed);
        grid
        ylabel('Speed','FontSize',6);
        title(strcat('Evolution of the SPEED in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2]);
        set(gca,'xticklabel',{strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')')},'FontSize',6);
        set(gca,'ylim',[0 120]);
        set(gca,'ytick',[0 60 120]);
        
        subplot(6,2,2);
        plot(distance,angle);
        grid
        ylabel('Angle','FontSize',6);
        title(strcat('Evolution of the ANGLE in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2]);
        set(gca,'xticklabel',{strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')')},'FontSize',6);
        set(gca,'ylim',[-500 500]);
        set(gca,'ytick',[-500 0 500]);
        
        subplot(6,2,3);
        plot(distance,gyrometer);
        grid
        ylabel('Gyrometer','FontSize',6);
        title(strcat('Evolution of the GYROMETER in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);   
        set(gca,'xtick',[xtick1 xtick2]);
        set(gca,'xticklabel',{strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')')},'FontSize',6);
        
        subplot(6,2,4);
        plot(distance,clignotant);
        grid
        ylabel('Clignotant','FontSize',6);
        title(strcat('Evolution of the CLIGNOTANT in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2]);
        set(gca,'xticklabel',{strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')')},'FontSize',6);
        
        subplot(6,2,5);
        plot(distance,cell2mat(acc));
        grid
        ylabel('%Accelerator','FontSize',6);
        title(strcat('Evolution of the %ACCELERATOR in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2]);
        set(gca,'xticklabel',{strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);     
        
        subplot(6,2,6);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([time;acc],{num2str(50)});
        derivAcc = cell2mat(processedData(2,:));
        plot(distance,derivAcc);
        grid
        ylabel('Derivative %Accelerator','FontSize',6);
        title(strcat('Derivative of %Accelerator in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2]);
        set(gca,'xticklabel',{strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')')},'FontSize',6);
        
        subplot(6,2,7);
        plot(distance,cell2mat(brake));
        grid
        ylabel('%Brake','FontSize',6);
        title(strcat('Evolution of the %BRAKE in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2]);
        set(gca,'xticklabel',{strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,8);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([time;brake],{num2str(50)});
        derivBrake = cell2mat(processedData(2,:));
        plot(distance,derivBrake);
        grid
        ylabel('Derivative %Brake','FontSize',6);
        title(strcat('Derivative of %Brake in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2]);
        set(gca,'xticklabel',{strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')')},'FontSize',6);
        
        subplot(6,2,9);
        plot(distance,cell2mat(clutch));
        grid
        ylabel('%Clutch','FontSize',6);
        title(strcat('Evolution of the %CLUTCH in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2]);
        set(gca,'xticklabel',{strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,10);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([time;clutch],{num2str(50)});
        derivClutch = cell2mat(processedData(2,:));
        plot(distance,derivClutch);
        grid
        ylabel('Derivative %Clutch','FontSize',6);
        title(strcat('Derivative of %Clutch in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2]);
        set(gca,'xticklabel',{strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')')},'FontSize',6);
        
        subplot(6,2,11);
        processedData = fr.lescot.bind.processing.signalProcessors.MovingAverageSmoothing.process([time;accx],{num2str(12)});
        masAccx = cell2mat(processedData(2,:));
        plot(distance,masAccx);
        grid
        ylabel('MovingAverage AccX','FontSize',6);
        title(strcat('Moving Average of AccX in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2]);
        set(gca,'xticklabel',{strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')')},'FontSize',6);
        
        subplot(6,2,12);
        processedData = fr.lescot.bind.processing.signalProcessors.MovingAverageSmoothing.process([time;accy],{num2str(12)});
        masAccy = cell2mat(processedData(2,:));
        plot(distance,masAccy);
        grid
        ylabel('MovingAverage AccY','FontSize',6);
        title(strcat('Moving Average of AccY in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2]);
        set(gca,'xticklabel',{strcat(num2str(distancePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')')},'FontSize',6);
        
        saveas(gcf,[directory filesep 'CurvesByDistance' filesep 'Intersection' num2str(index) filesep 'Middle'], 'png');
        
        % Exit Intersection
        record1 = theTrip.getDataOccurencesInTimeInterval('SensorsMeasures',starttime(i+2), endtime(i+2));
        result1 = record1.buildCellArrayWithVariables({'timecode' 'Speed' 'SteeringwheelAngle' 'Gyrometer' 'AccX' 'AccY' 'DistanceDriven'});
        time = result1(1,:);
        speed = cell2mat(result1(2,:));
        angle = cell2mat(result1(3,:));
        gyrometer = cell2mat(result1(4,:));
        accx = result1(5,:);
        accy = result1(6,:);
        distance = cell2mat(result1(7,:));

        clignotant = cell2mat(theTrip.getDataVariableValuesInterpolatedAccordingToTimecode(time,'SensorsData','Clignotant'));
        
        acc = theTrip.getDataVariableValuesInterpolatedAccordingToTimecode(time,'ProcessedData','%Accelerator');
        brake = theTrip.getDataVariableValuesInterpolatedAccordingToTimecode(time,'ProcessedData','%Brake');
        clutch = theTrip.getDataVariableValuesInterpolatedAccordingToTimecode(time,'ProcessedData','%Clutch');
        
        xtick1 = distancePOI(ind+1);
        xtick2 = distance(length(distance))
        if xtick1 == xtick2
            xtick2 = xtick2 * 1.01;
        end
        
        subplot(6,2,1);
        plot(distance,speed);
        grid
        ylabel('Speed','FontSize',6);
        title(strcat('Evolution of the SPEED in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2]);
        set(gca,'xticklabel',{strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(distance(length(distance))),'(ExitInt',num2str(index),')')},'FontSize',6);
        set(gca,'ylim',[0 120]);
        set(gca,'ytick',[0 60 120]);
        
        subplot(6,2,2);
        plot(distance,angle);
        grid
        ylabel('Angle','FontSize',6);
        title(strcat('Evolution of the ANGLE in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
         set(gca,'xtick',[xtick1 xtick2]);
        set(gca,'xticklabel',{strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(distance(length(distance))),'(ExitInt',num2str(index),')')},'FontSize',6);
        set(gca,'ylim',[-500 500]);
        set(gca,'ytick',[-500 0 500]);
        
        subplot(6,2,3);
        plot(distance,gyrometer);
        grid
        ylabel('Gyrometer','FontSize',6);
        title(strcat('Evolution of the GYROMETER in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);   
        set(gca,'xtick',[xtick1 xtick2]);
        set(gca,'xticklabel',{strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(distance(length(distance))),'(ExitInt',num2str(index),')')},'FontSize',6);
        
        subplot(6,2,4);
        plot(distance,clignotant);
        grid
        ylabel('Clignotant','FontSize',6);
        title(strcat('Evolution of the CLIGNOTANT in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2]);
        set(gca,'xticklabel',{strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(distance(length(distance))),'(ExitInt',num2str(index),')')},'FontSize',6);
        
        subplot(6,2,5);
        plot(distance,cell2mat(acc));
        grid
        ylabel('%Accelerator','FontSize',6);
        title(strcat('Evolution of the %ACCELERATOR in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2]);
        set(gca,'xticklabel',{strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(distance(length(distance))),'(ExitInt',num2str(index),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);     
        
        subplot(6,2,6);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([time;acc],{num2str(50)});
        derivAcc = cell2mat(processedData(2,:));
        plot(distance,derivAcc);
        grid
        ylabel('Derivative %Accelerator','FontSize',6);
        title(strcat('Derivative of %Accelerator in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2]);
        set(gca,'xticklabel',{strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(distance(length(distance))),'(ExitInt',num2str(index),')')},'FontSize',6);
        
        subplot(6,2,7);
        plot(distance,cell2mat(brake));
        grid
        ylabel('%Brake','FontSize',6);
        title(strcat('Evolution of the %BRAKE in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2]);
        set(gca,'xticklabel',{strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(distance(length(distance))),'(ExitInt',num2str(index),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,8);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([time;brake],{num2str(50)});
        derivBrake = cell2mat(processedData(2,:));
        plot(distance,derivBrake);
        grid
        ylabel('Derivative %Brake','FontSize',6);
        title(strcat('Derivative of %Brake in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2]);
        set(gca,'xticklabel',{strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(distance(length(distance))),'(ExitInt',num2str(index),')')},'FontSize',6);
        
        subplot(6,2,9);
        plot(distance,cell2mat(clutch));
        grid
        ylabel('%Clutch','FontSize',6);
        title(strcat('Evolution of the %CLUTCH in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2]);
        set(gca,'xticklabel',{strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(distance(length(distance))),'(ExitInt',num2str(index),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,10);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([time;clutch],{num2str(50)});
        derivClutch = cell2mat(processedData(2,:));
        plot(distance,derivClutch);
        grid
        ylabel('Derivative %Clutch','FontSize',6);
        title(strcat('Derivative of %Clutch in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2]);
        set(gca,'xticklabel',{strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(distance(length(distance))),'(ExitInt',num2str(index),')')},'FontSize',6);
        
        subplot(6,2,11);
        processedData = fr.lescot.bind.processing.signalProcessors.MovingAverageSmoothing.process([time;accx],{num2str(12)});
        masAccx = cell2mat(processedData(2,:));
        plot(distance,masAccx);
        grid
        ylabel('MovingAverage AccX','FontSize',6);
        title(strcat('Moving Average of AccX in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2]);
        set(gca,'xticklabel',{strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(distance(length(distance))),'(ExitInt',num2str(index),')')},'FontSize',6);
        
        subplot(6,2,12);
        processedData = fr.lescot.bind.processing.signalProcessors.MovingAverageSmoothing.process([time;accy],{num2str(12)});
        masAccy = cell2mat(processedData(2,:));
        plot(distance,masAccy);
        grid
        ylabel('MovingAverage AccY','FontSize',6);
        title(strcat('Moving Average of AccY in Intersection',num2str(index),' according to DistanceDriven'),'FontSize',6);
        set(gca,'xtick',[xtick1 xtick2]);
        set(gca,'xticklabel',{strcat(num2str(distancePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(distance(length(distance))),'(ExitInt',num2str(index),')')},'FontSize',6);
        
        saveas(gcf,[directory filesep 'CurvesByDistance' filesep 'Intersection' num2str(index) filesep 'Exit'], 'png');
        
        index = index + 1;
        ind = ind + 2;
        i = i + 3;

   end
end
delete(theTrip);
close('all');
delete(timerfindall);
clear all;
end