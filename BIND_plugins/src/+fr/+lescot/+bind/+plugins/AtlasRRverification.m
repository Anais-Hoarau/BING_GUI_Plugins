%{
Class:
This class creates a plugin used for the coding of Atlas cardiac data. Each
event of the double task has to be coded in terms of : 1 - usability of the
cadiac data ; 2 - cognitive load of the participant 3 - type of task
%}
classdef AtlasRRverification < fr.lescot.bind.plugins.GraphicalPlugin & fr.lescot.bind.plugins.TripStreamingPlugin
    
    properties (Access = private)
        
                %{
        Property:
        List of all Events table in the trip.
        %}
        pluginSize;
        
        %{
        Property:
        List of all Events table in the trip.
        %}
        theTrip;
        
        %{
        Property:
        Complete information about the coded data. Structure containing the timecodes, table name, the coded values, etc.
        %}
        markerIdentifier;
        
        %{
        Property:
        Array of the press buttons handles
        %}
        EventSituationList;
        
        %{
        Property:
        Array containing the press buttons color infos
        %}
        selectCurrentPage
        
        %{
        Property:
        Strucutre containg the current Event infos : id, handles. Current
        Event  = the first preceding Event with regard to the the current
        timer
        %}
        currentPage;
        
        %{
        Property:
        Strucutre containg the previous Event infos : id, handlesn, color. 
        %}
        previous_event;

        %{
        Property:
        Strucutre containg the previous Event infos : id, handlesn, color. 
        %}
        completeEventsList;
        
        %{
        Property:
        Strucutre containg the previous Event infos : id, handlesn, color. 
        %}
        current_event;
        
        %{
        Property:
        Cardiac data. 
        %}
        data_cardiac;
        
                %{
        Property:
        Cardiac data. 
        %}
        data_hr;
        
        %{
        Property:
        Cardiac data. 
        %}
        hrv;
        
        %{
        Property:
        Cardiac data. 
        %}
        pics
        
        %{
        Property:
        axes handles
        %}
        axe_handles;
        
        %{
        Property:
        plot handles
        %}
        plot_handles;
        
        removeEventButton_handle;
        
        currentEventText_handle;
     
    end
    
    properties(Access = private, Constant)
        % 1 : initial color - grey ; 2 : current event color - red ;
        % 3 : modified - blue ; 4 : completed - green
        
        color_list = {[0.8 0.8 0.8] , [0.84706 0.16078 0] , [0.043137 0.51765 0.78039] , [0 0.49804 0]};
        
    end
    
    methods     
        %{
        Function:
        The constructor of the 'AtlasCoding' plugin. When instanciated, a
        window is opened, meeting the parameters.
        
        Arguments:
        trip - The <kernel.Trip> object on which the SituationDisplay will be
        synchronized and which situations will be displayed.
        situationIdentifiers - A cell array of strings, which are all of the
        form "situation.variableName".
        position - The starting position of the window. (In geographical notation).
        timeWindow - The width in seconds of the time windows displayed.
        
        Returns:
        out - a new 'AtlasRRverification'.
        %}
        function this = AtlasRRverification(trip, dataIdentifiers, position)
            import fr.lescot.bind.exceptions.ExceptionIds;
            
            this@fr.lescot.bind.plugins.GraphicalPlugin();
            this@fr.lescot.bind.plugins.TripStreamingPlugin(trip, dataIdentifiers, 20, 'data');
            
            this.pluginSize.width = 1200;
            this.pluginSize.height = 1000;
            
            this.theTrip = trip;
            this.markerIdentifier = 'event.cardiac_RRintervals';
            
            record = trip.getAllEventOccurences('cardiac_RRintervals');
            
            this.completeEventsList.timecodes = cell2mat(record.getVariableValues('timecode'));
            this.completeEventsList.type = record.getVariableValues('type_tache');
            this.completeEventsList.first_pic = cell2mat(record.getVariableValues('first_pic_tc'));
            this.completeEventsList.RRintervals = record.getVariableValues('RRintervals');
            
            this.current_event.id = 0;
            
            this.data_cardiac.timecode = nan;
            this.data_cardiac.values = nan;
            
            this.data_hr.timecode = nan;
            this.data_hr.value = nan;
            
            this.data_hr.timecode_interp = nan;
            this.data_hr.value_interp = nan;
            
            this.hrv.timecode = -0.5:0.5:6;
            this.hrv.values = nan * zeros(1,length(this.hrv.timecode));
            
            this.pics.timecodes = nan;
            this.pics.values = nan;
            
            
            % Build the GUI
            this.buildUI(position);  
        end
        
        %{
        Function:
        
        This method is the implementation of the <observation.Observer.update> method. It
        updates the display after each message from the Trip : update the current Event, the button color and selection and the progress bar.
        %}
        function update(this, message)
            
            %% Update Widget
            this.EventSituationList.update(message);
            
            %% Udapte Plugin variables
            this.update@fr.lescot.bind.plugins.TripStreamingPlugin(message);
            currentTime = this.getCurrentTrip().getTimer.getTime();
           
            %The case of a STEP or a GOTO message
            if (any(strcmp(message.getCurrentMessage(), {'STEP' 'GOTO' })))
                ids = find(this.completeEventsList.timecodes < currentTime+0.1);
                if isempty(ids)
                    new_id=1;
                else
                    new_id= ids(end);
                end
                
                if this.current_event.id ~= new_id
                    this.current_event.id = new_id;
                    if this.completeEventsList.timecodes(new_id) + 20 < currentTime || this.completeEventsList.timecodes(new_id) - 5.6 > currentTime
                    else
                        this.changeBufferStartTime(this.completeEventsList.timecodes(new_id) -5.6) % to be sure that the data before the event are present
                    end
                end
            end
            
            if (any(strcmp(message.getCurrentMessage(), {'EVENT_CONTENT_CHANGED'})))
                this.updateEventData
            end 
            
            set(this.currentEventText_handle,'String', ['Tache en cours : ' num2str(this.current_event.id)]);
            
            this.updateDataBuffer;

            % update plot
            this.updatePlot;
        end
    end
    
    methods(Access = private)
        %{
        Function:
        Build the window of the GUI
        
        Arguments:
        this - The object on which the function is called, optionnal.
        position - The initial position of the GUI.
        
        %}
        function buildUI(this, position)
            %set(this.getFigureHandler(), 'Visible', 'on');
            %movegui(this.getFigureHandler(),position);
            format longg

            set(this.getFigureHandler(), 'Position', [0 0 this.pluginSize.width this.pluginSize.height]);
            set(this.getFigureHandler(), 'Name', '[Atlas] Verification des intervalles RR');
            set(this.getFigureHandler(), 'Resize', 'off');
%             callbackHandler = @this.resizePluginCallback;
%             set(this.getFigureHandler(), 'ResizeFcn', callbackHandler);
            
            % use the fancy widget ^^
            this.EventSituationList = fr.lescot.bind.widgets.EventSituationList(this.getFigureHandler(),...
                this.theTrip,...
                this.markerIdentifier,...
                'Position', [2 100],...
                'Size', [this.pluginSize.width/6-2  this.pluginSize.height-100],...
                'BackgroundColor', get(this.getFigureHandler(), 'Color') );
           
           % Resize figure callback
%            set(this.getFigureHandler(), 'Resize', 'off');
%            resizeFigureCallbackHandler = @this.resizeFigureCallback;
%            set(this.getFigureHandler(), 'ResizeFcn', resizeFigureCallbackHandler);
           h_deb = 0.32;
           h_p = 0.67;
           v_p = 0.27; % height proportion of the plot
           % Plot cardiac
           set(0, 'currentfigure', this.getFigureHandler)
           hold on
           addPointCallBackFunction = @this.addPoint;
           this.plot_handles.cardiac = plot(this.data_cardiac.timecode, this.data_cardiac.values, 'ButtonDownFcn', addPointCallBackFunction);
           this.axe_handles.cardiac = gca;
           set(this.axe_handles.cardiac,'Position',[h_deb 0.7 h_p v_p])
           title('Données cardiaques')
           
           % Bar plot of the Event position
           cardiac_axes = axis(this.axe_handles.cardiac);
           event_bar_size = cardiac_axes(3:4);
           this.plot_handles.event_position = plot([0 0],event_bar_size, 'Color', [0 0.496 0]);
           this.plot_handles.event_deb = plot([0 0],event_bar_size, 'Color', 'r','LineStyle','--');
           this.plot_handles.event_fin = plot([0 0],event_bar_size, 'Color', 'r','LineStyle','--');
           this.axe_handles.event_position = gca;
           
           % Pics plot
           removePointCallBackFunction = @this.removePoint;
           this.plot_handles.pics_position = plot(this.pics.timecodes, this.pics.values, 'rs', 'ButtonDownFcn', removePointCallBackFunction);
           this.axe_handles.pics_position = gca;
           hold off
           
           % Plot Heart interpolation
           this.axe_handles.hr_interp = axes;
           set(this.axe_handles.hr_interp,'Position',[h_deb 0.37 h_p v_p])
           hold on
           this.plot_handles.hr = plot(this.axe_handles.hr_interp, this.data_hr.timecode, this.data_hr.value, 'LineStyle', 'none', ...
               'Marker', 's', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', 'r');         
           this.plot_handles.hr_interp = plot(this.axe_handles.hr_interp, this.data_hr.timecode_interp, this.data_hr.value_interp, 'k');
           title('Interpolation du rythme cardiaque (spline cubic)')
           hold off
           
           % Plot Heart rate variability
           this.axe_handles.hrv = axes;
           set(this.axe_handles.hrv,'Position',[h_deb 0.04 h_p v_p])
           hold on
           this.plot_handles.hrv = plot(this.axe_handles.hrv, this.hrv.timecode, this.hrv.values, 'LineStyle', 'none', ...
               'Marker', 's', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', this.color_list{4});
           title('Variation du rythme cardiaque')
           hrv_axis = axis(this.axe_handles.hrv);
           for i = 1:1:length(this.hrv.timecode)
               this.plot_handles.v_bar(i) = plot([this.hrv.timecode(i) this.hrv.timecode(i)], hrv_axis(3:4), 'k--');
           end
           axis(this.axe_handles.hrv,[-0.5 6 hrv_axis(3:4)])
           set(this.axe_handles.hrv, 'XTick', this.hrv.timecode)
           
           hold off
           
           % Text and RemoveEventButton
           removeEventCallbackHandle = @this.removeEvent;
           this.removeEventButton_handle = uicontrol('Style', 'pushbutton',...
               'String', 'Retirer la tâche acutelle',...
               'Position', [20 20 150 50], 'Callback', removeEventCallbackHandle);
           
           
           this.currentEventText_handle = uicontrol('Style', 'text',...
               'String', 'Tache en cours : ', 'FontSize', 12,...
               'BackgroundColor', [0.8 0.8 0.8],...
               'Position', [200 25 150 28]);
           
           movegui(this.getFigureHandler(),position);
           set(this.getFigureHandler(), 'Visible', 'on');
        end     

        %{
        Function:
        
        the resizing is handled automatically.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        %}
        function resizeFigureCallback(this, ~ ,~)      
        end  
         
        function updateDataBuffer(this)
        % DataBuffer cell-array with the size [lengh(dataIdentifiers x 2] : first colum containing the data , the second column containing the timecode
            data = this.dataBuffer;   
            this.data_cardiac.timecode = cell2mat(data{1,2});
            this.data_cardiac.values =  cell2mat(data{1,1});  
        end
        
        function updatePlot(this)
            
            import fr.lescot.bind.utils.StringUtils;          
            currentEventTime = this.completeEventsList.timecodes(this.current_event.id);
            [~,closestCurrentTime_id] =  min(abs(this.data_cardiac.timecode - currentEventTime));
            closestCurrentTime = this.data_cardiac.timecode(closestCurrentTime_id);
            if max(this.data_cardiac.timecode) - closestCurrentTime > 11 & closestCurrentTime - min(this.data_cardiac.timecode) > 5.5
                mask_cardiac = (this.data_cardiac.timecode < currentEventTime + 11) & (this.data_cardiac.timecode > currentEventTime - 5.5);
            else
                return
            end
            xCardiacData = this.data_cardiac.timecode(mask_cardiac);
            yCardiacData = this.data_cardiac.values(mask_cardiac);
            
            Utils = fr.lescot.bind.utils.StringUtils;
            formatTimecode = @(x) Utils.formatSecondsToString(x);
            
            if ~isempty(xCardiacData)
                % Update cardiac plot
                set(this.plot_handles.cardiac, 'XData', xCardiacData, 'YData', yCardiacData)
                current_axes =  [min(xCardiacData), max(xCardiacData), min(yCardiacData)*1.1 , max(yCardiacData)*1.1+0.1];
                axis(this.axe_handles.cardiac, current_axes);
                axis(this.axe_handles.event_position, current_axes);
                set(this.axe_handles.cardiac,'XTickLabel',arrayfun(formatTimecode,round(min(xCardiacData):1:max(xCardiacData)),'UniformOutput',0));
                
                % Update event position plot
                xEventData = [currentEventTime currentEventTime];
                yEventata = current_axes(3:4);
                set(this.plot_handles.event_position, 'XData', xEventData, 'YData', yEventata)
                set(this.plot_handles.event_deb, 'XData', xEventData-0.5, 'YData', yEventata)
                set(this.plot_handles.event_fin, 'XData', xEventData+6, 'YData', yEventata)
                
                % Update pics plot           
                RRintervalles = str2num(this.completeEventsList.RRintervals{this.current_event.id});%#ok
                N_pics = length(RRintervalles)+1;
                this.pics.timecodes = zeros(1,N_pics);
                this.pics.values = zeros(1,N_pics);
                this.pics.timecodes(1) = this.completeEventsList.first_pic(this.current_event.id);
                %this.pics.values(1) = yCardiacData(xCardiacData == this.pics.timecodes(1));
                [~,id_min_tc] = min(abs(xCardiacData - this.pics.timecodes(1)));
                this.pics.values(1) = yCardiacData(id_min_tc);
                
                for i_pic = 1:1:N_pics-1
                    this.pics.timecodes(i_pic+1) = this.pics.timecodes(i_pic) + RRintervalles(i_pic)/1000;
                    [~, id] = min(abs(xCardiacData - this.pics.timecodes(i_pic+1)));
                    this.pics.values(i_pic+1) = yCardiacData(id);
                end
                set(this.plot_handles.pics_position, 'XData', this.pics.timecodes, 'YData', this.pics.values);
                
                % Update hr interpolation value : interpolation des intervalles RR à 10Hz
                this.data_hr.timecode = this.pics.timecodes(1:end-1) + diff(this.pics.timecodes)/2;
                this.data_hr.value = 60./(RRintervalles/1000);
                
                this.data_hr.timecode_interp = xCardiacData(1):1/10:xCardiacData(end);
                this.data_hr.value_interp = interp1(this.data_hr.timecode, this.data_hr.value, this.data_hr.timecode_interp, 'spline');
                
                set(this.plot_handles.hr, 'XData', this.data_hr.timecode, 'YData', this.data_hr.value);
                set(this.plot_handles.hr_interp, 'XData', this.data_hr.timecode_interp, 'YData', this.data_hr.value_interp);
                
                current_axes = [min(this.data_hr.timecode_interp), max(this.data_hr.timecode_interp), ...
                                min(this.data_hr.value)*0.9 , max(this.data_hr.value)*1.1+0.1];
                            
                axis(this.axe_handles.hr_interp, current_axes);
                set(this.axe_handles.hr_interp,'XTickLabel',arrayfun(formatTimecode,round(min(this.data_hr.timecode_interp):1:max(this.data_hr.timecode_interp)),'UniformOutput',0));
                
                
                % Update Heart Rate Variability plot
                this.hrv.timecode = (-0.5:0.5:5.5) + 0.25;
                
                mask_hrv = (this.data_hr.timecode_interp < currentEventTime + 6) & (this.data_hr.timecode_interp > currentEventTime - 0.5);
                interp_heartRate_section = this.data_hr.value_interp(mask_hrv);             
                this.hrv.values = mean(reshape(interp_heartRate_section, 5, []));
                this.hrv.values = this.hrv.values - this.hrv.values(1);
                
                % Write values in a file
                nomSujet = this.theTrip.getAttribute('nomSujet');
                hrv_event_ID = this.current_event.id;
                hrv_event_TC = this.completeEventsList.timecodes(hrv_event_ID);
                hrv_event_TYPE = this.completeEventsList.type(hrv_event_ID);
                hrv_event_VALUES = this.hrv.values;
                file_id_hrv = fopen('ATLAS_hrv.tsv', 'a');
                fprintf(file_id_hrv, '%s\t', nomSujet, num2str(hrv_event_ID), hrv_event_TC, cell2mat(hrv_event_TYPE), hrv_event_VALUES);
                fprintf(file_id_hrv, '\n');
                fclose(file_id_hrv);
                
                set(this.plot_handles.hrv,'XData', this.hrv.timecode, 'YData', this.hrv.values) ;
                axis(this.axe_handles.hrv,[-0.5 6 min(this.hrv.values)-abs(15/100*min(this.hrv.values)) max(this.hrv.values)+10/100*abs(max(this.hrv.values))])
                for i=1:1:length(this.plot_handles.v_bar)
                    set(this.plot_handles.v_bar,'YData', [min(this.hrv.values)-abs(15/100*min(this.hrv.values)) max(this.hrv.values)+10/100*abs(max(this.hrv.values))])
                end
            end
        end      
        
        function updateEventData(this)
            record = this.theTrip.getAllEventOccurences('cardiac_RRintervals');
            this.completeEventsList.timecodes = cell2mat(record.getVariableValues('timecode'));
            this.completeEventsList.type = record.getVariableValues('type_tache');
            this.completeEventsList.first_pic = cell2mat(record.getVariableValues('first_pic_tc'));
            this.completeEventsList.RRintervals = record.getVariableValues('RRintervals');
        end
        
        function addPoint(this, caller_handle, ~)
            clickedPoint = get(gca,'CurrentPoint');
            clickedPoint = clickedPoint(1,1:2);
            x_click = clickedPoint(1);
            y_click = clickedPoint(2);
            
            [~,id] = min(abs(this.data_cardiac.timecode - x_click));
            
            intervalle_size = 20;
            ids = max(1, id-intervalle_size):1:min(length(this.data_cardiac.values),id+intervalle_size);
            [~, id_new_pic] = max(this.data_cardiac.values(ids));
            tc_ids = this.data_cardiac.timecode(ids);
            new_pic_position = tc_ids(id_new_pic);
            
            if ~any(new_pic_position > this.pics.timecodes-0.05 & new_pic_position < this.pics.timecodes+0.05)
                mask =   this.pics.timecodes > new_pic_position;
                pics_tc = [this.pics.timecodes(~mask) new_pic_position  this.pics.timecodes(mask)];
                this.theTrip.setEventVariableAtTime('cardiac_RRintervals','first_pic_tc', ...
                    this.completeEventsList.timecodes(this.current_event.id), pics_tc(1));
                this.theTrip.setEventVariableAtTime('cardiac_RRintervals','RRintervals', ...
                    this.completeEventsList.timecodes(this.current_event.id), this.array2str(round(diff(pics_tc)*1000)));
            end
            
        end
        
        function removePoint(this, caller_handle, ~)
            clickedPoint = get(gca,'CurrentPoint');
            clickedPoint = clickedPoint(1,1:2);
            x_click = clickedPoint(1);
            y_click = clickedPoint(2);
            
            % Get the closest point
            [~,id_x] = min(abs(this.pics.timecodes-x_click));

            ids = 1:1:length(this.pics.timecodes);
            mask= ids~=id_x;
            pics_tc = this.pics.timecodes(mask);
            this.theTrip.setEventVariableAtTime('cardiac_RRintervals','first_pic_tc', ...
                this.completeEventsList.timecodes(this.current_event.id), pics_tc(1));
            this.theTrip.setEventVariableAtTime('cardiac_RRintervals','RRintervals', ...
                this.completeEventsList.timecodes(this.current_event.id), this.array2str(round(diff(pics_tc)*1000)));
        end

        function removeEvent(this,~,~)
            try
                this.theTrip.removeEventOccurenceAtTime('cardiac_RRintervals',this.completeEventsList.timecodes(this.current_event.id))
                if this.current_event.id ~=1
                    this.current_event.id = this.current_event.id-1;
                end
                this.theTrip.getTimer().setTime(this.completeEventsList.timecodes(this.current_event.id+1))
            catch
            end
            
        end
        
        function [str] = array2str(this, array)
            str = '';
            if isempty(array)
                return;
            else
                if size(array,1)>1
                    array = array';
                end
                str = mat2str(array);
                if length(array)>1
                    str = str(2:end-1);
                end
            end
        end
        
    end
    
    methods(Static)
        
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
            out = 'fr.lescot.bind.configurators.AtlasRRverificationConfigurator';   
        end
        
        %{
        Function:
        Implements <fr.lescot.bind.plugins.Plugin.geName()>.
        %}
        function out = getName()
            out = '[Atlas] RRintervals Verification';   
        end  
    end
end