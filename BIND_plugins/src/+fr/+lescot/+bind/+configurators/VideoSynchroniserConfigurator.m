%{
Class:
This class is the configurator of the <VideoSynchroniser> plugin

%}
classdef VideoSynchroniserConfigurator < fr.lescot.bind.configurators.PluginConfigurator_simplif
    
    properties        
        %{
        Property:
        Handler on the list that displays video descriptions
        object
        
        %}
        videoList;
        %{
        Property:
        Handler on the position chooser widget
        
        %}
        positionChooser;
    end

    methods

        function this = VideoSynchroniserConfigurator(pluginName, trip, metaTrip, varargin)
            this@fr.lescot.bind.configurators.PluginConfigurator_simplif(pluginName, trip, metaTrip, varargin);
            this.buildWindow();
            if length(varargin) == 1
                this.setUIState(varargin{1});
            end
        end

    end

    methods(Access = private)

        function buildWindow(this)
            import fr.lescot.bind.widgets.*;
            %windowBackgroundColor = get(this.getFigureHandler(), 'Color');
            
            set(this.getFigureHandler(), 'position', [0 0 400 320]);
            set(this.getFigureHandler(), 'Name', 'Video Synchroniser configurator');
            closeCallbackHandle = @this.closeCallback;
            set(this.getFigureHandler(), 'CloseRequestFcn', closeCallbackHandle);
            this.videoList = uicontrol(this.getFigureHandler(), 'Style', 'listbox', 'Position', [10 110 380 200], 'Min', 1, 'Max', 1);
            this.refreshVideoList();
            this.positionChooser = PositionChooser(this.getFigureHandler(), 'Position', [10 10]);
            validateCallbackHandle = @this.validateCallback;
            uicontrol(this.getFigureHandler(), 'Style', 'pushbutton', 'String', 'Valider', 'Position', [255 10 80 40], 'Callback', validateCallbackHandle);
            movegui(this.getFigureHandler(), 'center');
        end
        %{
        Function:
        Read the <data.MetaInformations> to fill in the table
        
        Arguments:
        this - optional
        
        %}
        function refreshVideoList(this)           
            metaVideos = this.metaTrip.getVideoFiles();
            dataVideos = cell(length(metaVideos),1);
            for i = 1:1:length(dataVideos)
                dataVideos{i,1} = metaVideos{i}.getDescription();
            end
            set(this.videoList, 'String', dataVideos);
        end
        
        function validateCallback(this, src, eventdata)
            %%%%%
            uiresume(this.getFigureHandler);
            %%%%%

            this.closeCallback(src, eventdata);
        end

        function closeCallback(this, src, ~)
            if src ~= this.getFigureHandler()
                this.buildConfiguration();
                this.quitConfigurator();
            end
        end   
    
        
        %{
        Function:
        From the class information, build a cell array of
        <configurators.Argument> and store it.
        
        Arguments:
        this - optional
        
        %}
        function buildConfiguration(this)
            argument1 = fr.lescot.bind.configurators.Argument('position',0,this.positionChooser.getSelectedPosition(),2);
            selectedVideoIndice = get(this.videoList, 'Value');
            availableVideos = get(this.videoList, 'String');
            argument2 = fr.lescot.bind.configurators.Argument('description',0,char(availableVideos{selectedVideoIndice}),3);
            theConfig = fr.lescot.bind.configurators.Configuration();
            theConfig.setArguments({argument1 argument2});
            this.configuration = theConfig;
        end
    end
    
    methods(Access = protected)
        function setUIState(this, configuration)
            position = configuration.findArgumentWithOrder(2).getValue();
            description = configuration.findArgumentWithOrder(3).getValue();
            
            %Select the right video in the selectable values
            availableDesc = get(this.videoList, 'String');
            selectedDesc = 1;
            for i = 1:1:length(availableDesc)
                if strcmp(availableDesc{i}, description)
                    selectedDesc = i;
                end
            end
            set(this.videoList, 'Value', selectedDesc);
            %Set the right position on the position chooser
            this.positionChooser.setSelectedPosition(position);
        end
    end

    methods(Static)
        % Copied from the VideoPlayerConfigurator
        function out = validateConfiguration(referenceTrip,configuration)

            valid = true;
            %Check if the object is a configuration
            if ~isa(configuration, 'fr.lescot.bind.configurators.Configuration')
                valid = false;
            end
            
            %Check if referenceTrip is a trip (if plugins are opened before
            %a trip is loader, data should not be extracted from the trip)
            if ~isa(referenceTrip, 'fr.lescot.bind.data.MetaInformations')
                out = false;
                return;
            end
            
            %Check if the movie configured is still available
            selectedVideo = configuration.findArgumentWithOrder(3).getValue();
            videos = referenceTrip.getVideoFiles();
            isPresentInReference = false;
            for i = 1:1:length(videos)
               if strcmp(videos{i}.getDescription(), selectedVideo)
                   isPresentInReference = true;
               end
            end
            valid = valid && isPresentInReference;
            out = valid;
        end
    end
    
end

