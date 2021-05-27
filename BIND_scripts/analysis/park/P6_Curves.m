function P6_Curves(directory)
if nargin < 1
    % select the directory containing the data
    directory = uigetdir(char(java.lang.System.getProperty('user.home')));
end

import fr.lescot.bind.processing.signalProcessors.*

% find the correct file for the trip database
pattern = '*.trip';
tripFile =  fullfile(directory, pattern);
listing = dir(tripFile);
tripFile = fullfile(directory, listing.name);

mkdir([directory filesep 'Curves']);

% create a BIND trip object from the database
theTrip = fr.lescot.bind.kernel.implementation.SQLiteTrip(tripFile,0.04,false);

% Use BIND to read data in matlab workspace
situationPOI = theTrip.getAllSituationOccurences('Intersection');
id = cell2mat(situationPOI.getVariableValues('Number'));
starttime = cell2mat(situationPOI.getVariableValues('startTimecode'));
endtime = cell2mat(situationPOI.getVariableValues('endTimecode'));
eventPOI = theTrip.getAllEventOccurences('POI');
timePOI = cell2mat(eventPOI.getVariableValues('TimeCode'));

index = 1; % counter for the number of the intersection
ind = 1; % counter for the number of the POI
i = 1; % indicatice to skim all the intersections
while i <= length(id)
    disp(['i : ' num2str(i)]);
    disp(['id : ' num2str(id(i))]);
    % First case: the intersections with only the "Entry Intersection"
    if id(i) == 40 || id(i) == 22
        set(gcf,'Position',[1,31,1280,920]);
        
        record1 = theTrip.getDataOccurencesInTimeInterval('SensorsMeasures',starttime(i), endtime(i));
        result1 = record1.buildCellArrayWithVariables({'timecode' 'Speed' 'SteeringwheelAngle' 'Gyrometer' 'AccX' 'AccY'});
        time1 = cell2mat(result1(1,:));
        speed = cell2mat(result1(2,:));
        angle = cell2mat(result1(3,:));
        gyrometer = cell2mat(result1(4,:));
        accx = result1(5,:);
        accy = result1(6,:);
        
        record2 = theTrip.getDataOccurencesInTimeInterval('SensorsData',starttime(i), endtime(i));
        result2 = record2.buildCellArrayWithVariables({'timecode' 'Clignotant'});
        time2 = cell2mat(result2(1,:));
        clignotant = cell2mat(result2(2,:));
        
        record3 = theTrip.getDataOccurencesInTimeInterval('ProcessedData',starttime(i), endtime(i));
        result3 = record3.buildCellArrayWithVariables({'timecode' '%Accelerator' '%Brake' '%Clutch'});
        time3 = cell2mat(result3(1,:));
        acc = cell2mat(result3(2,:));
        brake = cell2mat(result3(3,:));
        clutch = cell2mat(result3(4,:));
        
        subplot(6,2,1);
        plot(time1,speed);
        ylabel('Speed','FontSize',6);
        title(strcat('Evolution of the SPEED in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        set(gca,'ylim',[0 120]);
        set(gca,'ytick',[0 60 120]);
        
        subplot(6,2,2);
        plot(time1,angle);
        ylabel('Angle','FontSize',6);
        title(strcat('Evolution of the ANGLE in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        set(gca,'ylim',[-500 500]);
        set(gca,'ytick',[-500 0 500]);
        
        subplot(6,2,3);
        plot(time1,gyrometer);
        ylabel('Gyrometer','FontSize',6);
        title(strcat('Evolution of the GYROMETER in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        %set(gca,'ylim',[-500 500]);
        %set(gca,'ytick',[-500 0 500]);     
        
        subplot(6,2,4);
        plot(time2,clignotant);
        ylabel('Clignotant','FontSize',6);
        title(strcat('Evolution of the GYROMETER in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        %set(gca,'ylim',[-500 500]);
        %set(gca,'ytick',[-500 0 500]);
        
        subplot(6,2,5);
        plot(time3,acc);
        ylabel('%Accelerator','FontSize',6);
        title(strcat('Evolution of the %ACCELERATOR in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);     
        
        subplot(6,2,6);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([result3(1,:);result3(2,:)],{num2str(50)});
        derivAcc = cell2mat(processedData(2,:));
        plot(time3,derivAcc);
        ylabel('Derivative %Accelerator','FontSize',6);
        title(strcat('Derivative of %Accelerator in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        %set(gca,'ylim',[0 100]);
        %set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,7);
        plot(time3,brake);
        ylabel('%Brake','FontSize',6);
        title(strcat('Evolution of the %BRAKE in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,8);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([result3(1,:);result3(3,:)],{num2str(50)});
        derivBrake = cell2mat(processedData(2,:));
        plot(time3,derivBrake);
        ylabel('Derivative %Brake','FontSize',6);
        title(strcat('Derivative of %Brake in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        %set(gca,'ylim',[0 100]);
        %set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,9);
        plot(time3,clutch);
        ylabel('%Clutch','FontSize',6);
        title(strcat('Evolution of the %CLUTCH in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,10);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([result3(1,:);result3(4,:)],{num2str(50)});
        derivClutch = cell2mat(processedData(2,:));
        plot(time3,derivClutch);
        ylabel('Derivative %Clutch','FontSize',6);
        title(strcat('Derivative of %Clutch in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        %set(gca,'ylim',[0 100]);
        %set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,11);
        processedData = fr.lescot.bind.processing.signalProcessors.MovingAverageSmoothing.process([result1(1,:);accx],{num2str(12)});
        masAccx = cell2mat(processedData(2,:));
        plot(time1,masAccx);
        ylabel('MovingAverage AccX','FontSize',6);
        title(strcat('Moving Average of AccX in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        %set(gca,'ylim',[0 100]);
        %set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,12);
        processedData = fr.lescot.bind.processing.signalProcessors.MovingAverageSmoothing.process([result1(1,:);accy],{num2str(12)});
        masAccy = cell2mat(processedData(2,:));
        plot(time1,masAccy);
        ylabel('MovingAverage AccY','FontSize',6);
        title(strcat('Moving Average of AccY in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        %set(gca,'ylim',[0 100]);
        %set(gca,'ytick',[0 50 100]);
        
        saveas(gcf,[directory filesep 'Curves' filesep 'Intersection' num2str(index)], 'png');
        
        index = index + 1;
        ind = ind + 1;
        i = i + 1;
    
    % Second case : the intersection with no zones to explore, which,in fact, is an Eventment 
    % So we don't have graphs to display but its details
%     elseif id(i) == 41
%         
%         record = theTrip.getDataOccurencesInTimeInterval('SensorsMeasures',starttime(i), endtime(i));
%         result = record.buildCellArrayWithVariables({'timecode' 'Speed' 'SteeringwheelAngle' 'Gyrometer' 'AccX' 'AccY'});
%         speed = cell2mat(result(2,:));
%         angle = cell2mat(result(3,:));
%         gyrometer = cell2mat(result(4,:));
%         accx = cell2mat(result(5,:));
%         accy = cell2mat(result(6,:));
%         record = theTrip.getDataOccurencesInTimeInterval('SensorsData',starttime(i), endtime(i));
%         result = record.buildCellArrayWithVariables({'timecode' 'Clignotant'});
%         clignotant = cell2mat(result(2,:));
%         record = theTrip.getDataOccurencesInTimeInterval('ProcessedData',starttime(i), endtime(i));
%         result = record.buildCellArrayWithVariables({'timecode' '%Accelerator' '%Brake' '%Clutch'});
%         acc = cell2mat(result(2,:));
%         brake = cell2mat(result(3,:));
%         clutch = cell2mat(result(4,:));
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
        disp(['Looking for data in interval : [' num2str(starttime(i)) ';' num2str(endtime(i+2)) ']']);
        
        record1 = theTrip.getDataOccurencesInTimeInterval('SensorsMeasures',starttime(i), endtime(i+2));
        
        result1 = record1.buildCellArrayWithVariables({'timecode' 'Speed' 'SteeringwheelAngle' 'Gyrometer' 'AccX' 'AccY'});
        time1 = cell2mat(result1(1,:));
        speed = cell2mat(result1(2,:));
        angle = cell2mat(result1(3,:));
        gyrometer = cell2mat(result1(4,:));
        accx = result1(5,:);
        accy = result1(6,:);
        
        record2 = theTrip.getDataOccurencesInTimeInterval('SensorsData',starttime(i), endtime(i+2));
        result2 = record2.buildCellArrayWithVariables({'timecode' 'Clignotant'});
        time2 = cell2mat(result2(1,:));
        clignotant = cell2mat(result2(2,:));
        
        record3 = theTrip.getDataOccurencesInTimeInterval('ProcessedData',starttime(i), endtime(i+2));
        result3 = record3.buildCellArrayWithVariables({'timecode' '%Accelerator' '%Brake' '%Clutch'});
        time3 = cell2mat(result3(1,:));
        acc = cell2mat(result3(2,:));
        brake = cell2mat(result3(3,:));
        clutch = cell2mat(result3(4,:));
        
        subplot(6,2,1);
        plot(time1,speed);
        ylabel('Speed','FontSize',6);
        title(strcat('Evolution of the SPEED in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind) timePOI(ind+1) endtime(i+2)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(endtime(i+2)),'(ExitInt',num2str(index),')')},'FontSize',6);
        set(gca,'ylim',[0 120]);
        set(gca,'ytick',[0 60 120]);
        
        subplot(6,2,2);
        plot(time1,angle);
        ylabel('Angle','FontSize',6);
        title(strcat('Evolution of the ANGLE in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind) timePOI(ind+1) endtime(i+2)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(endtime(i+2)),'(ExitInt',num2str(index),')')},'FontSize',6);
        set(gca,'ylim',[-500 500]);
        set(gca,'ytick',[-500 0 500]);
        
        subplot(6,2,3);
        plot(time1,gyrometer);
        ylabel('Gyrometer','FontSize',6);
        title(strcat('Evolution of the GYROMETER in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind) timePOI(ind+1) endtime(i+2)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(endtime(i+2)),'(ExitInt',num2str(index),')')},'FontSize',6);
        %set(gca,'ylim',[-500 500]);
        %set(gca,'ytick',[-500 0 500]);     
        
        subplot(6,2,4);
        plot(time2,clignotant);
        ylabel('Clignotant','FontSize',6);
        title(strcat('Evolution of the GYROMETER in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind) timePOI(ind+1) endtime(i+2)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(endtime(i+2)),'(ExitInt',num2str(index),')')},'FontSize',6);
        %set(gca,'ylim',[-500 500]);
        %set(gca,'ytick',[-500 0 500]);
        
        subplot(6,2,5);
        plot(time3,acc);
        ylabel('%Accelerator','FontSize',6);
        title(strcat('Evolution of the %ACCELERATOR in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind) timePOI(ind+1) endtime(i+2)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(endtime(i+2)),'(ExitInt',num2str(index),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);     
        
        subplot(6,2,6);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([result3(1,:);result3(2,:)],{num2str(50)});
        derivAcc = cell2mat(processedData(2,:));
        plot(time3,derivAcc);
        ylabel('Derivative %Accelerator','FontSize',6);
        title(strcat('Derivative of %Accelerator in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind) timePOI(ind+1) endtime(i+2)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(endtime(i+2)),'(ExitInt',num2str(index),')')},'FontSize',6);
        %set(gca,'ylim',[0 100]);
        %set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,7);
        plot(time3,brake);
        ylabel('%Brake','FontSize',6);
        title(strcat('Evolution of the %BRAKE in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind) timePOI(ind+1) endtime(i+2)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(endtime(i+2)),'(ExitInt',num2str(index),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,8);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([result3(1,:);result3(3,:)],{num2str(50)});
        derivBrake = cell2mat(processedData(2,:));
        plot(time3,derivBrake);
        ylabel('Derivative %Brake','FontSize',6);
        title(strcat('Derivative of %Brake in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind) timePOI(ind+1) endtime(i+2)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(endtime(i+2)),'(ExitInt',num2str(index),')')},'FontSize',6);
        %set(gca,'ylim',[0 100]);
        %set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,9);
        plot(time3,clutch);
        ylabel('%Clutch','FontSize',6);
        title(strcat('Evolution of the %CLUTCH in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind) timePOI(ind+1) endtime(i+2)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(endtime(i+2)),'(ExitInt',num2str(index),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,10);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([result3(1,:);result3(4,:)],{num2str(50)});
        derivClutch = cell2mat(processedData(2,:));
        plot(time3,derivClutch);
        ylabel('Derivative %Clutch','FontSize',6);
        title(strcat('Derivative of %Clutch in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind) timePOI(ind+1) endtime(i+2)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(endtime(i+2)),'(ExitInt',num2str(index),')')},'FontSize',6);
        %set(gca,'ylim',[0 100]);
        %set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,11);
        processedData = fr.lescot.bind.processing.signalProcessors.MovingAverageSmoothing.process([result1(1,:);accx],{num2str(12)});
        masAccx = cell2mat(processedData(2,:));
        plot(time1,masAccx);
        ylabel('MovingAverage AccX','FontSize',6);
        title(strcat('Moving Average of AccX in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind) timePOI(ind+1) endtime(i+2)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(endtime(i+2)),'(ExitInt',num2str(index),')')},'FontSize',6);
        %set(gca,'ylim',[0 100]);
        %set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,12);
        processedData = fr.lescot.bind.processing.signalProcessors.MovingAverageSmoothing.process([result1(1,:);accy],{num2str(12)});
        masAccy = cell2mat(processedData(2,:));
        plot(time1,masAccy);
        ylabel('MovingAverage AccY','FontSize',6);
        title(strcat('Moving Average of AccY in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind) timePOI(ind+1) endtime(i+2)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(endtime(i+2)),'(ExitInt',num2str(index),')')},'FontSize',6);
        %set(gca,'ylim',[0 100]);
        %set(gca,'ytick',[0 50 100]);
        
        saveas(gcf,[directory filesep 'Curves' filesep 'Intersection' num2str(index)], 'png');
        
        % Devide an intersection into three zones
        % Create the folder for each intersection
        mkdir([directory filesep 'Curves' filesep 'Intersection' num2str(index)]);
        % Entry Intersection
        record1 = theTrip.getDataOccurencesInTimeInterval('SensorsMeasures',starttime(i), endtime(i));
        result1 = record1.buildCellArrayWithVariables({'timecode' 'Speed' 'SteeringwheelAngle' 'Gyrometer' 'AccX' 'AccY'});
        time1 = cell2mat(result1(1,:));
        speed = cell2mat(result1(2,:));
        angle = cell2mat(result1(3,:));
        gyrometer = cell2mat(result1(4,:));
        accx = result1(5,:);
        accy = result1(6,:);
        
        record2 = theTrip.getDataOccurencesInTimeInterval('SensorsData',starttime(i), endtime(i));
        result2 = record2.buildCellArrayWithVariables({'timecode' 'Clignotant'});
        time2 = cell2mat(result2(1,:));
        clignotant = cell2mat(result2(2,:));
        
        record3 = theTrip.getDataOccurencesInTimeInterval('ProcessedData',starttime(i), endtime(i));
        result3 = record3.buildCellArrayWithVariables({'timecode' '%Accelerator' '%Brake' '%Clutch'});
        time3 = cell2mat(result3(1,:));
        acc = cell2mat(result3(2,:));
        brake = cell2mat(result3(3,:));
        clutch = cell2mat(result3(4,:));
                
        subplot(6,2,1);
        plot(time1,speed);
        ylabel('Speed','FontSize',6);
        title(strcat('Evolution of the SPEED in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        set(gca,'ylim',[0 120]);
        set(gca,'ytick',[0 60 120]);
        
        subplot(6,2,2);
        plot(time1,angle);
        ylabel('Angle','FontSize',6);
        title(strcat('Evolution of the ANGLE in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        set(gca,'ylim',[-500 500]);
        set(gca,'ytick',[-500 0 500]);
        
        subplot(6,2,3);
        plot(time1,gyrometer);
        ylabel('Gyrometer','FontSize',6);
        title(strcat('Evolution of the GYROMETER in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        %set(gca,'ylim',[-500 500]);
        %set(gca,'ytick',[-500 0 500]);     
        
        subplot(6,2,4);
        plot(time2,clignotant);
        ylabel('Clignotant','FontSize',6);
        title(strcat('Evolution of the GYROMETER in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        %set(gca,'ylim',[-500 500]);
        %set(gca,'ytick',[-500 0 500]);
        
        subplot(6,2,5);
        plot(time3,acc);
        ylabel('%Accelerator','FontSize',6);
        title(strcat('Evolution of the %ACCELERATOR in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);     
        
        subplot(6,2,6);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([result3(1,:);result3(2,:)],{num2str(50)});
        derivAcc = cell2mat(processedData(2,:));
        plot(time3,derivAcc);
        ylabel('Derivative %Accelerator','FontSize',6);
        title(strcat('Derivative of %Accelerator in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        %set(gca,'ylim',[0 100]);
        %set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,7);
        plot(time3,brake);
        ylabel('%Brake','FontSize',6);
        title(strcat('Evolution of the %BRAKE in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,8);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([result3(1,:);result3(3,:)],{num2str(50)});
        derivBrake = cell2mat(processedData(2,:));
        plot(time3,derivBrake);
        ylabel('Derivative %Brake','FontSize',6);
        title(strcat('Derivative of %Brake in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        %set(gca,'ylim',[0 100]);
        %set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,9);
        plot(time3,clutch);
        ylabel('%Clutch','FontSize',6);
        title(strcat('Evolution of the %CLUTCH in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,10);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([result3(1,:);result3(4,:)],{num2str(50)});
        derivClutch = cell2mat(processedData(2,:));
        plot(time3,derivClutch);
        ylabel('Derivative %Clutch','FontSize',6);
        title(strcat('Derivative of %Clutch in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        %set(gca,'ylim',[0 100]);
        %set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,11);
        processedData = fr.lescot.bind.processing.signalProcessors.MovingAverageSmoothing.process([result1(1,:);accx],{num2str(8)});
        masAccx = cell2mat(processedData(2,:));
        plot(time1,masAccx);
        ylabel('MovingAverage AccX','FontSize',6);
        title(strcat('Moving Average of AccX in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        %set(gca,'ylim',[0 100]);
        %set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,12);
        processedData = fr.lescot.bind.processing.signalProcessors.MovingAverageSmoothing.process([result1(1,:);accy],{num2str(8)});
        masAccy = cell2mat(processedData(2,:));
        plot(time1,masAccy);
        ylabel('MovingAverage AccY','FontSize',6);
        title(strcat('Moving Average of AccY in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[starttime(i) timePOI(ind)]);
        set(gca,'xticklabel',{strcat(num2str(starttime(i)),'(EntryInt',num2str(index),')'),strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')')},'FontSize',6);
        %set(gca,'ylim',[0 100]);
        %set(gca,'ytick',[0 50 100]);
        
        saveas(gcf,[directory filesep 'Curves' filesep 'Intersection' num2str(index) filesep 'Entry'], 'png');
        
        % Middle Intersection
        record1 = theTrip.getDataOccurencesInTimeInterval('SensorsMeasures',starttime(i+1), endtime(i+1));
        result1 = record1.buildCellArrayWithVariables({'timecode' 'Speed' 'SteeringwheelAngle' 'Gyrometer' 'AccX' 'AccY'});
        time1 = cell2mat(result1(1,:));
        speed = cell2mat(result1(2,:));
        angle = cell2mat(result1(3,:));
        gyrometer = cell2mat(result1(4,:));
        accx = result1(5,:);
        accy = result1(6,:);
        
        record2 = theTrip.getDataOccurencesInTimeInterval('SensorsData',starttime(i+1), endtime(i+1));
        result2 = record2.buildCellArrayWithVariables({'timecode' '%Accelerator' '%Brake' '%Clutch' 'Clignotant'});
        time2 = cell2mat(result2(1,:));
        clignotant = cell2mat(result2(2,:));
        
        record3 = theTrip.getDataOccurencesInTimeInterval('ProcessedData',starttime(i+1), endtime(i+1));
        result3 = record3.buildCellArrayWithVariables({'timecode' '%Accelerator' '%Brake' '%Clutch'});
        time3 = cell2mat(result3(1,:));
        acc = cell2mat(result3(2,:));
        brake = cell2mat(result3(3,:));
        clutch = cell2mat(result3(4,:));
        
        subplot(6,2,1);
        plot(time1,speed);
        ylabel('Speed','FontSize',6);
        title(strcat('Evolution of the SPEED in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[timePOI(ind) timePOI(ind+1)]);
        set(gca,'xticklabel',{strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')')},'FontSize',6);
        set(gca,'ylim',[0 120]);
        set(gca,'ytick',[0 60 120]);
        
        subplot(6,2,2);
        plot(time1,angle);
        ylabel('Angle','FontSize',6);
        title(strcat('Evolution of the ANGLE in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[timePOI(ind) timePOI(ind+1)]);
        set(gca,'xticklabel',{strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')')},'FontSize',6);
        set(gca,'ylim',[-500 500]);
        set(gca,'ytick',[-500 0 500]);
        
        subplot(6,2,3);
        plot(time1,gyrometer);
        ylabel('Gyrometer','FontSize',6);
        title(strcat('Evolution of the GYROMETER in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[timePOI(ind) timePOI(ind+1)]);
        set(gca,'xticklabel',{strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')')},'FontSize',6);
        %set(gca,'ylim',[-500 500]);
        %set(gca,'ytick',[-500 0 500]);     
        
        subplot(6,2,4);
        plot(time2,clignotant);
        ylabel('Clignotant','FontSize',6);
        title(strcat('Evolution of the GYROMETER in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[timePOI(ind) timePOI(ind+1)]);
        set(gca,'xticklabel',{strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')')},'FontSize',6);
        %set(gca,'ylim',[-500 500]);
        %set(gca,'ytick',[-500 0 500]);
        
        subplot(6,2,5);
        plot(time3,acc);
        ylabel('%Accelerator','FontSize',6);
        title(strcat('Evolution of the %ACCELERATOR in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[timePOI(ind) timePOI(ind+1)]);
        set(gca,'xticklabel',{strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);     
        
        subplot(6,2,6);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([result3(1,:);result3(2,:)],{num2str(50)});
        derivAcc = cell2mat(processedData(2,:));
        plot(time3,derivAcc);
        ylabel('Derivative %Accelerator','FontSize',6);
        title(strcat('Derivative of %Accelerator in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[timePOI(ind) timePOI(ind+1)]);
        set(gca,'xticklabel',{strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')')},'FontSize',6);
        %set(gca,'ylim',[0 100]);
        %set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,7);
        plot(time3,brake);
        ylabel('%Brake','FontSize',6);
        title(strcat('Evolution of the %BRAKE in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[timePOI(ind) timePOI(ind+1)]);
        set(gca,'xticklabel',{strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,8);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([result3(1,:);result3(3,:)],{num2str(50)});
        derivBrake = cell2mat(processedData(2,:));
        plot(time3,derivBrake);
        ylabel('Derivative %Brake','FontSize',6);
        title(strcat('Derivative of %Brake in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[timePOI(ind) timePOI(ind+1)]);
        set(gca,'xticklabel',{strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')')},'FontSize',6);
        %set(gca,'ylim',[0 100]);
        %set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,9);
        plot(time3,clutch);
        ylabel('%Clutch','FontSize',6);
        title(strcat('Evolution of the %CLUTCH in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[timePOI(ind) timePOI(ind+1)]);
        set(gca,'xticklabel',{strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,10);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([result3(1,:);result3(4,:)],{num2str(50)});
        derivClutch = cell2mat(processedData(2,:));
        plot(time3,derivClutch);
        ylabel('Derivative %Clutch','FontSize',6);
        title(strcat('Derivative of %Clutch in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[timePOI(ind) timePOI(ind+1)]);
        set(gca,'xticklabel',{strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')')},'FontSize',6);
        %set(gca,'ylim',[0 100]);
        %set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,11);
        processedData = fr.lescot.bind.processing.signalProcessors.MovingAverageSmoothing.process([result1(1,:);accx],{num2str(8)});
        masAccx = cell2mat(processedData(2,:));
        plot(time1,masAccx);
        ylabel('MovingAverage AccX','FontSize',6);
        title(strcat('Moving Average of AccX in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[timePOI(ind) timePOI(ind+1)]);
        set(gca,'xticklabel',{strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')')},'FontSize',6);
        %set(gca,'ylim',[0 100]);
        %set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,12);
        processedData = fr.lescot.bind.processing.signalProcessors.MovingAverageSmoothing.process([result1(1,:);accy],{num2str(8)});
        masAccy = cell2mat(processedData(2,:));
        plot(time1,masAccy);
        ylabel('MovingAverage AccY','FontSize',6);
        title(strcat('Moving Average of AccY in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[timePOI(ind) timePOI(ind+1)]);
        set(gca,'xticklabel',{strcat(num2str(timePOI(ind)),'(POI ',num2str(ind),')'),strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')')},'FontSize',6);
        %set(gca,'ylim',[0 100]);
        %set(gca,'ytick',[0 50 100]);
        
        saveas(gcf,[directory filesep 'Curves' filesep 'Intersection' num2str(index) filesep 'Middle'], 'png');

        % Exit Intersection
        record1 = theTrip.getDataOccurencesInTimeInterval('SensorsMeasures',starttime(i+2), endtime(i+2));
        result1 = record1.buildCellArrayWithVariables({'timecode' 'Speed' 'SteeringwheelAngle' 'Gyrometer' 'AccX' 'AccY'});
        time1 = cell2mat(result1(1,:));
        speed = cell2mat(result1(2,:));
        angle = cell2mat(result1(3,:));
        gyrometer = cell2mat(result1(4,:));
        accx = result1(5,:);
        accy = result1(6,:);
        
        record2 = theTrip.getDataOccurencesInTimeInterval('SensorsData',starttime(i+2), endtime(i+2));
        result2 = record2.buildCellArrayWithVariables({'timecode' '%Accelerator' '%Brake' '%Clutch' 'Clignotant'});
        time2 = cell2mat(result2(1,:));
        clignotant = cell2mat(result2(5,:));
        
        record3 = theTrip.getDataOccurencesInTimeInterval('ProcessedData',starttime(i+2), endtime(i+2));
        result3 = record3.buildCellArrayWithVariables({'timecode' '%Accelerator' '%Brake' '%Clutch'});
        time3 = cell2mat(result3(1,:));
        acc = cell2mat(result3(2,:));
        brake = cell2mat(result3(3,:));
        clutch = cell2mat(result3(4,:));
        
        subplot(6,2,1);
        plot(time1,speed);
        ylabel('Speed','FontSize',6);
        title(strcat('Evolution of the SPEED in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[timePOI(ind+1) endtime(i+2)]);
        set(gca,'xticklabel',{strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(endtime(i+2)),'(ExitInt',num2str(index),')')},'FontSize',6);
        set(gca,'ylim',[0 120]);
        set(gca,'ytick',[0 60 120]);
        
        subplot(6,2,2);
        plot(time1,angle);
        ylabel('Angle','FontSize',6);
        title(strcat('Evolution of the ANGLE in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[timePOI(ind+1) endtime(i+2)]);
        set(gca,'xticklabel',{strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(endtime(i+2)),'(ExitInt',num2str(index),')')},'FontSize',6);
        set(gca,'ylim',[-500 500]);
        set(gca,'ytick',[-500 0 500]);
        
        subplot(6,2,3);
        plot(time1,gyrometer);
        ylabel('Gyrometer','FontSize',6);
        title(strcat('Evolution of the GYROMETER in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[timePOI(ind+1) endtime(i+2)]);
        set(gca,'xticklabel',{strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(endtime(i+2)),'(ExitInt',num2str(index),')')},'FontSize',6);
        %set(gca,'ylim',[-500 500]);
        %set(gca,'ytick',[-500 0 500]);     
        
        subplot(6,2,4);
        plot(time2,clignotant);
        ylabel('Clignotant','FontSize',6);
        title(strcat('Evolution of the GYROMETER in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[timePOI(ind+1) endtime(i+2)]);
        set(gca,'xticklabel',{strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(endtime(i+2)),'(ExitInt',num2str(index),')')},'FontSize',6);
        %set(gca,'ylim',[-500 500]);
        %set(gca,'ytick',[-500 0 500]);
        
        subplot(6,2,5);
        plot(time3,acc);
        ylabel('%Accelerator','FontSize',6);
        title(strcat('Evolution of the %ACCELERATOR in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[timePOI(ind+1) endtime(i+2)]);
        set(gca,'xticklabel',{strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(endtime(i+2)),'(ExitInt',num2str(index),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);     
        
        subplot(6,2,6);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([result3(1,:);result3(2,:)],{num2str(50)});
        derivAcc = cell2mat(processedData(2,:));
        plot(time3,derivAcc);
        ylabel('Derivative %Accelerator','FontSize',6);
        title(strcat('Derivative of %Accelerator in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[timePOI(ind+1) endtime(i+2)]);
        set(gca,'xticklabel',{strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(endtime(i+2)),'(ExitInt',num2str(index),')')},'FontSize',6);
        %set(gca,'ylim',[0 100]);
        %set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,7);
        plot(time3,brake);
        ylabel('%Brake','FontSize',6);
        title(strcat('Evolution of the %BRAKE in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[timePOI(ind+1) endtime(i+2)]);
        set(gca,'xticklabel',{strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(endtime(i+2)),'(ExitInt',num2str(index),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,8);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([result3(1,:);result3(3,:)],{num2str(50)});
        derivBrake = cell2mat(processedData(2,:));
        plot(time3,derivBrake);
        ylabel('Derivative %Brake','FontSize',6);
        title(strcat('Derivative of %Brake in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[timePOI(ind+1) endtime(i+2)]);
        set(gca,'xticklabel',{strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(endtime(i+2)),'(ExitInt',num2str(index),')')},'FontSize',6);
        %set(gca,'ylim',[0 100]);
        %set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,9);
        plot(time3,clutch);
        ylabel('%Clutch','FontSize',6);
        title(strcat('Evolution of the %CLUTCH in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[timePOI(ind+1) endtime(i+2)]);
        set(gca,'xticklabel',{strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(endtime(i+2)),'(ExitInt',num2str(index),')')},'FontSize',6);
        set(gca,'ylim',[0 100]);
        set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,10);
        processedData = fr.lescot.bind.processing.signalProcessors.QADDerivative.process([result3(1,:);result3(4,:)],{num2str(50)});
        derivClutch = cell2mat(processedData(2,:));
        plot(time3,derivClutch);
        ylabel('Derivative %Clutch','FontSize',6);
        title(strcat('Derivative of %Clutch in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[timePOI(ind+1) endtime(i+2)]);
        set(gca,'xticklabel',{strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(endtime(i+2)),'(ExitInt',num2str(index),')')},'FontSize',6);
        %set(gca,'ylim',[0 100]);
        %set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,11);
        processedData = fr.lescot.bind.processing.signalProcessors.MovingAverageSmoothing.process([result1(1,:);accx],{num2str(8)});
        masAccx = cell2mat(processedData(2,:));
        plot(time1,masAccx);
        ylabel('MovingAverage AccX','FontSize',6);
        title(strcat('Moving Average of AccX in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[timePOI(ind+1) endtime(i+2)]);
        set(gca,'xticklabel',{strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(endtime(i+2)),'(ExitInt',num2str(index),')')},'FontSize',6);
        %set(gca,'ylim',[0 100]);
        %set(gca,'ytick',[0 50 100]);
        
        subplot(6,2,12);
        processedData = fr.lescot.bind.processing.signalProcessors.MovingAverageSmoothing.process([result1(1,:);accy],{num2str(8)});
        masAccy = cell2mat(processedData(2,:));
        plot(time1,masAccy);
        ylabel('MovingAverage AccY','FontSize',6);
        title(strcat('Moving Average of AccY in Intersection',num2str(index)),'FontSize',6);
        set(gca,'xtick',[timePOI(ind+1) endtime(i+2)]);
        set(gca,'xticklabel',{strcat(num2str(timePOI(ind+1)),'(POI ',num2str(ind+1),')'),strcat(num2str(endtime(i+2)),'(ExitInt',num2str(index),')')},'FontSize',6);
        %set(gca,'ylim',[0 100]);
        %set(gca,'ytick',[0 50 100]);
        
        saveas(gcf,[directory filesep 'Curves' filesep 'Intersection' num2str(index) '\Exit'], 'png');
        
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