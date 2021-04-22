classdef ContinentalTechnologiesViewer < fr.lescot.bind.plugins.GraphicalPlugin & fr.lescot.bind.plugins.TripStreamingPlugin
    
    properties (Access = private)
        %{
        Property:
        Properties containing all the data and data variables names present in the trip used to update the ContinentalTechnologiesViewer display. 
        They are so far hard written in the configurator plugin which might no be a good idea for futur evolution.
        
        %}
        dataIdentifiers;
        
        %{
        Property:
        RoadParameters is a structure containing the lastest update of the road properties given by the Continental camera.
        
        %}
        contiParameters
       
        %{
        Property:
        The handler to all the plot of the plugin. It is struct containing plot handler :
        fields : - target ; - lane ; - speedlimit;       
        
        %}
        plotHandler;
        
        %{
        Property:
        The handler to all the text plot of the plugin. It is struct containing text plot handler :
        fields : - target ; - lane ; - speedlimit;            
        
        %}
        textHandler;
        
        %{
        Property:
        The handler to all the axes of the plugin. It is struct containing axes handler :
        fields : - target ; - lane ; - speedlimit; 
        
        %}
        axeHandler;

        %{
        Property:
        The paramater is a structure containing the parameters of the
        circle used to display the speed limit
        
        %}
        AxesRatio;
        
                %{
        Property:
        Time since last figure refresh
        %}
        
        numberOfFrameSinceLastRefresh;
    end
    
    properties (Access = private, Constant)        
        
        %{
        Constant:
        The list of position codes supported by Matlab movegui function.
        
        Value:
        {'north', 'south', 'east', 'west', 'northeast', 'northwest', 'southeast', 'southwest', 'center'}
        %}
        POSITIONS_LIST = {'north', 'south', 'east', 'west', 'northeast', 'northwest', 'southeast', 'southwest', 'center'};;
        
        %{
        Constant:
        Length of the vehicule used for the car box plot
        
        %}
        VEHICLE_WIDTH = 1.5;
        
                %{
        Constant:
        Width of the vehicule used for the car box plot
        
        %}
        VEHICLE_LENGTH = 3;
        
        %{
        Constant:
        Maximum target that will be displayed. This is used at the intitiation step.
        
        %}
        MAX_TARGET_DISPLAYED = 10;
    end
    
    methods
        %{
        Function:
        The constructor of the ContinentalTechnologiesViewer plugin. When instanciated, a window is opened, meeting the parameters.
        
        Arguments:
        
        trip - The <kernel.Trip> object on which the DataPlotter will be synchronized and which data will be displayed. dataIdentifiers - A cell array of strings, which are all of the
        form "dataName.variableName". position - The initial position of the window.
        %}
        function this = ContinentalTechnologiesViewer(trip, dataIdentifiers, position)
            
            import fr.lescot.bind.exceptions.ExceptionIds;
            import fr.lescot.bind.utils.StringUtils;
            this@fr.lescot.bind.plugins.GraphicalPlugin();
            this@fr.lescot.bind.plugins.TripStreamingPlugin(trip, dataIdentifiers, 30, 'data');
            
            this.numberOfFrameSinceLastRefresh = 0;
            
            %% dataIdentifiers : recuperation & initialisation of contiParameters
            this.dataIdentifiers = dataIdentifiers;
            this.contiParameters = struct;
                        
            %% Graphical Interface 
            set(this.getFigureHandler(),'Unit','Point');
            
            % Resize callback : off
            set(this.getFigureHandler(), 'Resize', 'off');
            %callbackHandler = @this.resizeFigureCallback;
            %set(this.getFigureHandler(), 'ResizeFcn', callbackHandler);
            
            % figure properties
            set(this.getFigureHandler, 'Position', [0 0 540 430]);
            set(this.getFigureHandler, 'Color',[0.8 0.8 0.8]);
            set(this.getFigureHandler(),'Name','Continental Technologies Viewer')
            
            movegui(this.getFigureHandler, position);
            
            % Car box arrays
            WIDTH = this.VEHICLE_WIDTH;
            X_VEH = [-WIDTH/2 -WIDTH/2 WIDTH/2 WIDTH/2];
            Y_VEH = [-10 0 0 -10];
            
            % Initialization of the plots/plot handlers
            % Car Box
            this.plotHandler.target(1) = patch(X_VEH,Y_VEH,'b');
            this.axeHandler.target(1) = get(this.plotHandler.target(1),'parent');
            this.textHandler.target(1) = text(0,-10/2,'VICTOR','Color','w','HorizontalAlignment','center','FontSize',8,'FontWeight','bold');
            
            grid on           
            set(this.axeHandler.target(1),'Xlim',[-10,10],'Ylim',[-50 200]);
            set(this.axeHandler.target(1),'Xtick', -10:1:10);
            set(this.axeHandler.target(1),'Ytick', -50:10:200);
            set(get(this.axeHandler.target(1),'XLabel'),'String', 'meters');
            set(this.axeHandler.target(1),'Unit','Point');
            set(this.axeHandler.target(1),'Position',[20 30 510 380]);
            
            Xlim = get(this.axeHandler.target(1),'Xlim');
            Xsize = Xlim(2) -Xlim(1);
            Ylim = get(this.axeHandler.target(1),'Ylim');
            Ysize = Ylim(2)-Ylim(1);
            this.AxesRatio = Ysize/Xsize;
            
            LENGTH = this.AxesRatio * this.VEHICLE_LENGTH;
            Y_VEH = [-LENGTH 0 0 -LENGTH];
            set(this.plotHandler.target(1),'YData',Y_VEH);
            set(this.textHandler.target(1),'Position',[0 -LENGTH/2]);
            
            % Target Plot (patch)
            for i_target=1:1:this.MAX_TARGET_DISPLAYED 
                this.plotHandler.target(i_target+1) = patch(0,0,'w');
                this.textHandler.target(i_target+1)=text(0,0,'','Color','w');
                this.axeHandler.target(i_target+1) = get(this.textHandler.target(i_target+1),'parent');
            end
            
            % lanes
            x= -50:1:200;
            y=zeros(size(x));
            this.plotHandler.lane.left = line(y-3.5/2,x,'LineStyle','--','Color','w');
            this.axeHandler.lane.left = get(this.plotHandler.lane.left,'parent');
            set(this.axeHandler.lane.left,'Color',[0.8 0.8 0.8]);
            set(this.axeHandler.lane.left,'Unit','Point');
            
            this.plotHandler.lane.right = line(y+3.5/2,x,'LineStyle','--','Color','w');
            this.axeHandler.lane.right = get(this.plotHandler.lane.right,'parent');
            set(this.axeHandler.lane.right,'Color',[0.8 0.8 0.8])
            set(this.axeHandler.lane.right,'Unit','Point');
            
            uistack(this.plotHandler.lane.left,'bottom') 
            uistack(this.plotHandler.lane.right,'bottom')
            
            % speed limitation
            contiPara.sla.SpeedLimit = '';
            this.plotHandler.speedlimit = text(7.5,20,contiPara.sla.SpeedLimit,'Color','k','BackgroundColor','w', 'EdgeColor', 'r', 'LineWidth', 5, ...         
                                               'Margin', 7,'HorizontalAlignment','center','FontSize',16,'FontWeight','bold');
            
            % Display the Plugin figure
            set(this.getFigureHandler,'Visible', 'on')       
        end
        
        %{
        Function:
        
        This method is the implementation of the <observation.Observer.update> method. It
        updates the display after each message from the Trip.
        %}
        function update(this, message)
            
            this.update@fr.lescot.bind.plugins.TripStreamingPlugin(message);
            doRefresh = false;           
            if this.getCurrentTrip.getTimer.getPeriod()> 0.1
                doRefresh = false;
            elseif (any(strcmp(message.getCurrentMessage(), {'STEP' 'GOTO'})))
                doRefresh = true;
            end

            %The case of a STEP or a GOTO message
            if doRefresh
                currentTime = this.getCurrentTrip.getTimer.getTime();
                this.contiParameters_update(currentTime);
                this.regenerateDisplay();
            end
            
        end
        
    end
    
    methods (Access=private)
        %{
        Function:
        
        This method is update the contiParameters structure using the dataBuffer (This plugin is a TripStreamingPlugin).
        %}
        function contiParameters_update(this,currentTime)
            
            % DataBuffer cell-array with the size [lengh(dataIdentifiers x 2] : first colum containing the data , the second column containing the timecode
            data = this.dataBuffer;
            dataId = this.dataIdentifiers;
            % Determine les indices correspondant au temps le plus proche de la position actuelle pour les éléments du buffer
            for j=1:1:length(dataId)
                if strcmp(dataId{j},'Kvaser_ARS.ID')
                    [~,id_radar]=min(abs(cell2mat(data{j,2})-currentTime));    
                elseif strcmp(dataId{j},'Kvaser_LDW1.ALDW_LaneLtrlDist')
                    [~,id_camera]=min(abs(cell2mat(data{j,2})-currentTime));
                elseif strcmp(dataId{j},'Kvaser_SLA.SLA_WarnSpd_Val')
                    [~,id_sla]=min(abs(cell2mat(data{j,2})-currentTime));    
                end 
            end
            
            contiPara =  this.contiParameters;
            
            for j=1:1:length(dataId)                
                %ARS                
                if strcmp(dataId{j},'Kvaser_ARS.ID')
                    temp_data = data{j,1}; 
                    contiPara.radar.ID = str2num(temp_data{id_radar});%#ok
                elseif strcmp(dataId{j},'Kvaser_ARS.LatDispl')
                    temp_data = data{j,1};
                    contiPara.radar.LatDispl = str2num(temp_data{id_radar});%#ok
                elseif strcmp(dataId{j},'Kvaser_ARS.LongDispl')
                    temp_data = data{j,1};
                    contiPara.radar.LongDispl = str2num(temp_data{id_radar});%#ok
                elseif strcmp(dataId{j},'Kvaser_ARS.Length')
                    temp_data = data{j,1};
                    contiPara.radar.Length = str2num(temp_data{id_radar});%#ok
                elseif strcmp(dataId{j},'Kvaser_ARS.Width')
                    temp_data = data{j,1};
                    contiPara.radar.Width = str2num(temp_data{id_radar});%#ok
                % CAMERA         
                elseif strcmp(dataId{j},'Kvaser_LDW1.ALDW_LaneLtrlDist')
                    temp_data = data{j,1};
                    contiPara.camera.LateralDistance = temp_data{id_camera};
                elseif strcmp(dataId{j},'Kvaser_LDW1.ALDW_LaneNum')
                    temp_data = data{j,1};
                    contiPara.camera.LaneNumber = temp_data{id_camera};
                elseif strcmp(dataId{j},'Kvaser_LDW1.ALDW_LaneWidth')
                    temp_data = data{j,1};
                    contiPara.camera.LaneWidth = temp_data{id_camera};
                elseif strcmp(dataId{j},'Kvaser_LDW1.ALDW_LaneYawAngl')
                    temp_data = data{j,1};
                    contiPara.camera.LaneYawAngle = temp_data{id_camera};
                elseif strcmp(dataId{j},'Kvaser_LDW1.ALDW_NumLane')
                    temp_data = data{j,1};
                    contiPara.camera.NumberOfLane = temp_data{id_camera};
                elseif strcmp(dataId{j},'Kvaser_LDW2.ALDW_LanClothoidPara')
                    temp_data = data{j,1};
                    if id_camera-1<50 % average the road parameters to avoid fast variation on the plot
                        contiPara.camera.Clothoid = mean(cell2mat(temp_data(1 : id_camera)));
                    else
                        contiPara.camera.Clothoid = mean(cell2mat(temp_data(id_camera-50 : id_camera)));   
                    end
                elseif strcmp(dataId{j},'Kvaser_LDW2.ALDW_LaneHrztCrv')
                    temp_data = data{j,1};
                    if id_camera-1<50 % average the road parameters to avoid fast variation on the plot
                        contiPara.camera.HrzCurvature = mean(cell2mat(temp_data(1 : id_camera)));
                    else
                        contiPara.camera.HrzCurvature = mean(cell2mat(temp_data(id_camera-50 : id_camera)));   
                    end
                elseif strcmp(dataId{j},'Kvaser_LDW2.ALDW_LanMkCol_Lt')
                    temp_data = data{j,1};
                    if temp_data{id_camera} == 2
                        contiPara.camera.LaneColorLeft = 'y';
                    else
                        contiPara.camera.LaneColorLeft = 'w';
                    end
                elseif strcmp(dataId{j},'Kvaser_LDW2.ALDW_LanMkCol_Rt')
                    temp_data = data{j,1};
                    if temp_data{id_camera} == 2
                        contiPara.camera.LaneColorRight = 'y';
                    else
                        contiPara.camera.LaneColorRight = 'w';
                    end
                elseif strcmp(dataId{j},'Kvaser_LDW2.ALDW_LanMkLftType')
                    temp_data = data{j,1};
                    if temp_data{id_camera} == 2
                        contiPara.camera.LaneTypeLeft = '--';
                    else
                        contiPara.camera.LaneTypeLeft = '-';
                    end 
                elseif strcmp(dataId{j},'Kvaser_LDW2.ALDW_LanMkRitType')
                    temp_data = data{j,1};
                    if temp_data{id_camera} == 2
                        contiPara.camera.LaneTypeRight = '--';
                    else
                        contiPara.camera.LaneTypeRight = '-';
                    end 
                elseif strcmp(dataId{j},'Kvaser_LDW3.ALDW_LanMkLftWidth')
                    temp_data = data{j,1};
                    contiPara.camera.LaneWidthLeft = temp_data{id_camera};
                elseif strcmp(dataId{j},'Kvaser_LDW3.ALDW_LanMkRitWidth')
                    temp_data = data{j,1};
                    contiPara.camera.LaneWidthRight = temp_data{id_camera};
                %SLA
                elseif strcmp(dataId{j},'Kvaser_SLA.SLA_WarnSpd_Val')
                    temp_data = data{j,1};
                    if temp_data{id_sla} == 0 
                        contiPara.sla.SpeedLimit = '';
                    else
                        contiPara.sla.SpeedLimit = num2str(temp_data{id_sla});
                    end
                end
            end
            
            % update the parameters
            this.contiParameters = contiPara;
        end

        %{
        Function:
        
        This method handles the resizing of the figure.
        %}
        function resizeFigureCallback(this, ~ ,~)
            newSize = get(this.getFigureHandler(), 'Position');
            %Repositionning and resizing the axes panel          
            set(this.axeHandler, 'Position', [20 20 max(1,(newSize(3) - 40)) max(1, (newSize(4) - 40))]);
        end
 
        %{
        Function:
        
        This method is used to update the different plots with the new contiParameters
        %}
        function regenerateDisplay(this)
            contiPara = this.contiParameters;
            targetData = contiPara.radar;
            cameraData = contiPara.camera;
            % update target shape and position (radar)
            for i_target=1:1:this.MAX_TARGET_DISPLAYED
                if isempty(targetData.ID) || i_target>length(targetData.ID) 
                    set(this.plotHandler.target(i_target+1),'Xdata',[0 0],'Ydata', [0 0],'FaceColor','none');
                    set(this.textHandler.target(i_target+1),'String','','Position',[0 0]);
                else
                     [X_center,Y_center,X_patch,Y_patch] = this.CalculateTargetPosition(targetData,i_target);
                     set(this.plotHandler.target(i_target+1),'Xdata',X_patch,'Ydata',Y_patch,'FaceColor',[0.6 0.6 0.6]); % ,'LineWidth',edgeWidth,'EdgeColor',[1 0 0]);
                     set(this.textHandler.target(i_target+1),'Position',[X_center Y_center],'String',num2str(targetData.ID(i_target)), ...
                         'Color','r','HorizontalAlignment','center','VerticalAlignment','middle','FontWeight','bold','Fontsize',14,'Clipping','on');   
                end
            end
            
            % update the position and rotation of VICTOR
            [X_VEH,Y_VEH] = this.rotateVehicle(cameraData);
            set(this.plotHandler.target(1),'XData',X_VEH);
            set(this.plotHandler.target(1),'YData',Y_VEH);
            set(this.textHandler.target(1),'Position',[-cameraData.LateralDistance -this.AxesRatio*this.VEHICLE_LENGTH/2]);
            
            % update lane parameters
            Xlim = get(this.axeHandler.target(1),'Xlim');
            x_axes_width = Xlim(2)-Xlim(1);
            
            Ylim = get(this.axeHandler.target(1),'Ylim');
            
            pos_axe = get(this.axeHandler.target(1),'Position');
            axe_width = pos_axe(3);
            
            x=Ylim(1):1:Ylim(2);
            y_left = -((cameraData.HrzCurvature/2)*x.^2 + (cameraData.Clothoid/6)*x.^3) - cameraData.LaneWidth/2;
            y_right = -((cameraData.HrzCurvature/2)*x.^2 + (cameraData.Clothoid/6)*x.^3) + cameraData.LaneWidth/2;
            
            set(this.plotHandler.lane.right,'Xdata',y_right)
            set(this.plotHandler.lane.right,'Ydata',x)
            set(this.plotHandler.lane.right,'LineStyle',cameraData.LaneTypeRight, ...
                                            'LineWidth',cameraData.LaneWidthRight*(axe_width/x_axes_width)+0.1, ...
                                            'Color',cameraData.LaneColorRight);    
        
            set(this.plotHandler.lane.left,'Xdata',y_left)
            set(this.plotHandler.lane.left,'Ydata',x)
            set(this.plotHandler.lane.left,'LineStyle',cameraData.LaneTypeLeft, ...
                                            'LineWidth',cameraData.LaneWidthLeft*(axe_width/x_axes_width)+0.1, ...
                                            'Color',cameraData.LaneColorLeft); 
                                
                                
            % update le speed limit indicator
            set(this.plotHandler.speedlimit,'String',contiPara.sla.SpeedLimit)
        end
             
                %{
        Function:
        This function calculated provided weel-formated set of array to be used with the patch et text plot fonction
        
        Returns:
        A set of coordinates used for position the target patch box and the associated text label.
        
        %}
        function [X_center, Y_center, X_patch,Y_patch] = CalculateTargetPosition(this,targetData,i_target)               
                if targetData.Width(i_target) < 2
                    Length = this.AxesRatio * 1.6;
                    Width = 0.8;
                elseif targetData.Width(i_target) < 5
                    Length = this.AxesRatio * 3;
                    Width = 1.5;
                else
                    Length = this.AxesRatio * 5;
                    Width = 2.5;
                end
                
                X_center = -targetData.LatDispl(i_target);
                Y_center = targetData.LongDispl(i_target)+Length/2;
                X_patch = -[targetData.LatDispl(i_target)-Width/2 targetData.LatDispl(i_target)-Width/2 ...
                           targetData.LatDispl(i_target) + Width/2 targetData.LatDispl(i_target)+ Width/2];
                Y_patch = [targetData.LongDispl(i_target) targetData.LongDispl(i_target)+Length ...
                           targetData.LongDispl(i_target)+Length targetData.LongDispl(i_target)]; 
        end
       
               %{
        Function:
        
        This method calculates the coordinates for the rotation of the vehicle.
        %}
        function [X_VEH,Y_VEH]=rotateVehicle(this,cameraData)
            WIDTH = this.VEHICLE_WIDTH;
            LENGTH =  this.VEHICLE_LENGTH * this.AxesRatio;

            VEH1_ini=[-WIDTH/2,-LENGTH];
            VEH2_ini=[-WIDTH/2,0];
            VEH3_ini=[WIDTH/2,0];
            VEH4_ini=[WIDTH/2,-LENGTH];
            
            angle = (pi/180)*cameraData.LaneYawAngle;
            rot = [cos(angle) , -sin(angle) ; sin(angle) , cos(angle)];
            
            LateralDist = cameraData.LateralDistance;
            VEH1=rot*VEH1_ini';
            VEH2=rot*VEH2_ini';
            VEH3=rot*VEH3_ini';
            VEH4=rot*VEH4_ini';
            X_VEH = (([VEH1(1) VEH2(1) VEH3(1) VEH4(1)] - [-WIDTH/2 -WIDTH/2 WIDTH/2 WIDTH/2])/this.AxesRatio + [-WIDTH/2 -WIDTH/2 WIDTH/2 WIDTH/2])-LateralDist;
            Y_VEH = [VEH1(2) VEH2(2) VEH3(2) VEH4(2)];

        end
        
    end
    
    methods(Static)
        %{
        Function:
        Returns the human-readable name of the plugin.
        
        Returns:
        A String.
        
        %}
        function out = getName()
            out = '[CAN] ContinentalTechnologiesViewer';
        end
        
        %{
        Function:
        Overwrite <plugins.Plugin.isInstanciable()>.
        
        Returns:
        out - true
        %}
        function out = isInstanciable()
            out = true;
        end
        
        %{
        Function:
        Implements <fr.lescot.bind.plugins.Plugin.getConfiguratorClass()>.
        %}
        function out = getConfiguratorClass()
            out = 'fr.lescot.bind.configurators.ContinentalTechnologiesViewerConfigurator';
        end
        
    end
end