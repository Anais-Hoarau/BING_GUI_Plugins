%{
Class:
This class is the configurator of the <VideoPlayer> plugin

%}
classdef VideoPlayerConfigurator < fr.lescot.bind.configurators.PluginConfigurator_simplif
    
    properties (Access = private)
        %{
        Property:
        metainformations about trips. Contains a <data.MetaInformations>
        object
        
        %}
        tripInformation;
        %{
        Property:
        Handler on the list that displays video descriptions
        object
        
        %}
        videoList;
        %{
        Property:
        Handler on the list that displays video descriptions
        object
        
        %}
        audioList;
        %{
        Property:
        Handler on the position chooser widget
        
        %}
        positionChooser;
        %{
        Property:
        Indice of the selected video in the table
        object
        
        %}
        videoIndice;
        %{
        Property:
        Name of the description of the selected video in the table
        object
        
        %}
        activeVideoDescription;
        %{
        Property:
        Text to label decimation edit field.
        
        %}
        labelTextField;
        %{
        Property:
        Edit box for user input about decimation. 1 = no decimation
        
        %}
        decimationTextField; 
        
        
    end
    
    methods
        %{
        Function:
        The constructor of the VideoPlayerConfigurator plugin. When instanciated, a
        window is opened, meeting the parameters.
        
        Arguments:
        pluginId - unique identifier of the plugin to be configured
        (integer)
        tripInformation - a <data.MetaInformations> object that stores the
        available videos
        caller - handler to the interface that ask for a configuration, in
        order to be able to give back the configurator when closing.
        
        
        Returns:
        this - a new VideoPlayerConfigurator.
        %}
        function this = VideoPlayerConfigurator( pluginName, trip, metaTrip, varargin)
            this@fr.lescot.bind.configurators.PluginConfigurator_simplif(pluginName, trip, metaTrip, varargin);
            this.tripInformation = metaTrip;
            this.buildWindow();
            if length(varargin) == 1
                this.setUIState(varargin{1});
            end
        end
    end
    
    methods(Access = protected)
        %{
        Function:
        see <configurators.PluginConfigurator.setUIState()>
        %}
        function setUIState(this, configuration)
            position = configuration.findArgumentWithOrder(2).getValue();
            videoDescription = configuration.findArgumentWithOrder(3).getValue();
            audioDescription = configuration.findArgumentWithOrder(4).getValue();
            decimation = configuration.findArgumentWithOrder(5).getValue();
            
            %Select the right video in the selectable values
            availableDesc = get(this.videoList, 'String');
            selectedVideoDesc = 1;
            selectedAudioDesc = 1;
            for i = 1:1:length(availableDesc)
                if strcmp(availableDesc{i}, videoDescription)
                    selectedVideoDesc = i;
                    selectedAudioDesc = i;
                end
                if strcmp(availableDesc{i}, audioDescription)
                    selectedAudioDesc = i;
                end
            end
            set(this.videoList, 'Value', selectedVideoDesc);
            set(this.audioList, 'Value', selectedAudioDesc);
            %Set the decimation to the correct value
            set(this.decimationTextField, 'String', decimation);
            %Set the right position on the position chooser
            this.positionChooser.setSelectedPosition(position);
        end
    end
    
    
    methods(Access = private)
          
        %{
        Function:
        Build the window
        
        Arguments:
        this - optional
        
        %}
        function buildWindow(this)
            import fr.lescot.bind.widgets.*;
            windowBackgroundColor = get(this.getFigureHandler(), 'Color');
            set(this.getFigureHandler(), 'visible', 'on');
            set(this.getFigureHandler(), 'position', [0 0 400 350]);
            set(this.getFigureHandler(), 'Name', 'VideoPlayer configurator');
            closeCallbackHandle = @this.closeCallback;
            set(this.getFigureHandler(), 'CloseRequestFcn', closeCallbackHandle);
            uicontrol('Style', 'text', 'Position', [10 330 205 15], 'String', 'Veuillez sélectionner le fichier vidéo à lire');
            videoListCallbackHandle = @this.videoListCallback;
            this.videoList = uicontrol(this.getFigureHandler(), 'Style', 'listbox', 'Position', [10 230 380 100], 'Min', 1, 'Max', 1, 'Callback', videoListCallbackHandle);
            uicontrol('Style', 'text', 'Position', [10 210 318 15], 'String', 'Veuillez sélectionner le fichier audio à lire, si différent de la vidéo');
            this.audioList = uicontrol(this.getFigureHandler(), 'Style', 'listbox', 'Position', [10 110 380 100], 'Min', 1, 'Max', 1);
            this.refreshVideoList();
            listContextMenuVideo = uicontextmenu();
            contextMenuVideoCallbackHandle = @this.contextMenuVideoCallback;
            uimenu(listContextMenuVideo, 'Label', 'Details', 'Callback', contextMenuVideoCallbackHandle);
            set(this.videoList, 'Uicontextmenu', listContextMenuVideo);
            listContextMenuAudio = uicontextmenu();
            contextMenuAudioCallbackHandle = @this.contextMenuAudioCallback;
            uimenu(listContextMenuAudio, 'Label', 'Details', 'Callback', contextMenuAudioCallbackHandle);
            set(this.audioList, 'Uicontextmenu', listContextMenuAudio);
            this.positionChooser = PositionChooser(this.getFigureHandler(), 'Position', [10 10]);
            this.labelTextField = uicontrol(this.getFigureHandler(), 'Style', 'text', 'String', 'Proportion d''images a jouer : 1/', 'Position', [200 70 155 15], 'BackgroundColor', windowBackgroundColor);
            this.decimationTextField = uicontrol(this.getFigureHandler(), 'Style', 'edit', 'Min', 1, 'Max', 1, 'Position', [357 69 20 20], 'String', '1');
            validateCallbackHandle = @this.validateCallback;
            uicontrol(this.getFigureHandler(), 'Style', 'pushbutton', 'String', 'Valider', 'Position', [255 10 80 40], 'Callback', validateCallbackHandle);
            movegui(this.getFigureHandler(), 'center');
        end
        
        %{
        Function:
        The callback called when the "Detail" button of the video list is
        clicked. Generate a pop-up with more informations about the video
        file (none but the description already in the list for the
        moment).
        
        Arguments:
        this - optional
        source - for callback
        eventdata - for callback
        
        %}
        function contextMenuCallbackVideo(this, ~, ~)
            selectedDescriptionIndex = get(this.videoList, 'Value');
            selectedDescriptions = get(this.videoList, 'String');
            selectedDescription = selectedDescriptions{selectedDescriptionIndex};
            fullText = {};
            fullText{1} = ['Description : ' selectedDescription];
            msgbox(fullText ,'Details','Help', 'Modal');
        end
        
        %{
        Function:
        The callback called when the "Detail" button of the audio list is
        clicked. Generate a pop-up with more informations about the audio
        file (none but the description already in the list for the
        moment).
        
        Arguments:
        this - optional
        source - for callback
        eventdata - for callback
        
        %}
        function contextMenuCallbackAudio(this, ~, ~)
            selectedDescriptionIndex = get(this.audioList, 'Value');
            selectedDescriptions = get(this.audioList, 'String');
            selectedDescription = selectedDescriptions{selectedDescriptionIndex};
            fullText = {};
            fullText{1} = ['Description : ' selectedDescription];
            msgbox(fullText ,'Details','Help', 'Modal');
        end
        
        %{
        Function:
        The callback called when an element of the video list is clicked. 
        The audio list is updated with the same idx.
        
        Arguments:
        this - optional
        source - for callback
        eventdata - for callback
        
        %}
        function videoListCallback(this, ~, ~)
            selectedDesc = get(this.videoList, 'Value');
            set(this.audioList, 'Value', selectedDesc);
        end
        
        %{
        Function:
        Launched when the validate button is pressed. It launch the close
        callback.
        
        Arguments:
        this - optional
        source - for callback
        eventdata - for callback
        
        %}
        function validateCallback(this, src, eventdata)
            %%%%
             uiresume(this.getFigureHandler);
            %%%%%
            this.closeCallback(src, eventdata);
        end
        
        %{
        Function:
        Read the <data.MetaInformations> to fill in the table
        
        Arguments:
        this - optional
        
        %}
        function refreshVideoList(this)           
            meta = this.tripInformation;
            metaVideos = meta.getVideoFiles();
            dataVideos = cell(length(metaVideos),1);
            for i = 1:1:length(dataVideos)
                dataVideos{i,1} = metaVideos{i}.getDescription();
            end
            set(this.videoList, 'String', dataVideos);
            set(this.audioList, 'String', dataVideos);
        end
        
        %{
        Function:
        Activate the processes to send the configuration to the caller
        
        Arguments:
        this - optional
        source - for callback
        eventdata - for callback
        
        %}
        function closeCallback(this, source, ~)
            if source ~= this.getFigureHandler()
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
            selectedAudioIndice = get(this.audioList, 'Value');
            availableVideos = get(this.videoList, 'String');
            if ~isempty(availableVideos)
                argument2 = fr.lescot.bind.configurators.Argument('description',0,char(availableVideos{selectedVideoIndice}),3);
                argument3 = fr.lescot.bind.configurators.Argument('description',0,char(availableVideos{selectedAudioIndice}),4);
            else
                argument2 = fr.lescot.bind.configurators.Argument('description',0,'',3);
                argument3 = fr.lescot.bind.configurators.Argument('description',0,'',4);
            end
                argument4 = fr.lescot.bind.configurators.Argument('decimation',0,str2double(get(this.decimationTextField, 'String')),5);
                theConfig = fr.lescot.bind.configurators.Configuration();
                theConfig.setArguments({argument1 argument2 argument3 argument4});
                this.configuration = theConfig;
        end
    end
    
    methods(Static)      
        
        %{
        Function:
        See <configurators.PluginConfigurator.validateConfiguration>
        %}
        function out = validateConfiguration(referenceTrip, configuration)
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

