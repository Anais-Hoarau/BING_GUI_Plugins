%{
Class:
This class instanciates a panel that allow to set the offset of the video.
TODO: Ajouter un menu avec un bouton d'aide
TODO: Ajouter le nom de la vidéo synchronisée quelque part sur l'interface.
%}
classdef VideoSynchroniser < fr.lescot.bind.plugins.VisualisationPlugin
        %%%%%%%%%%%%
        properties (Access=public)
            newPosition;%rajout
        end
        %%%%%%%%%%
    properties(Access = private)
        recordTcVideoButtonHandler;
        recordTcDataButtonHandler;
        synchroniseButtonHandler;     
        timeDisplayHandler;
        tcCurrentDisplayHandler;
        tcVideoDisplayHandler;
        tcDataDisplayHandler;
        tcVideo;
        tcData;
        metaVideoFile;
        videoDescription;
    end

    methods(Static)
        function out = isInstanciable()
            out = true;
        end

        function out = getConfiguratorClass()
            out = 'fr.lescot.bind.configurators.VideoSynchroniserConfigurator';
        end

        function out = getName()
           out = 'Video Synchroniser'; 
        end
    end

    methods
        function update(this, message)
            if any(strcmp(message.getCurrentMessage(),{'STEP' 'GOTO'}))
                import('fr.lescot.bind.utils.StringUtils');
                set(this.tcCurrentDisplayHandler, 'String', StringUtils.formatSecondsToString(this.getCurrentTrip.getTimer.getTime()));
            end
        end

        function this = VideoSynchroniser(trip,position,videoDescription)
            this@fr.lescot.bind.plugins.VisualisationPlugin(trip);
            % find the video from description
            this.videoDescription = videoDescription;
            metaInfo = trip.getMetaInformations();
            videoFiles = metaInfo.getVideoFiles();
            for i = 1:1:length(videoFiles)
                if(strcmp(videoFiles{i}.getDescription(),this.videoDescription))
                    this.metaVideoFile = videoFiles{i};
                end
            end
            % build UI
            this.buildUI(position);
            this.dynamizeUI();
            %Setting visible
            set(this.getFigureHandler,'Visible', 'on');
        end
    end

    methods(Access = private)

        function buildUI(this,position)
            bgColor = get(this.getFigureHandler(), 'Color');
            set(this.getFigureHandler, 'Name', ['Synchronisation vidéo : ' this.videoDescription]);
            set(this.getFigureHandler, 'Position', [0 0 300 150]);  %[left bottom width height]
            movegui(this.getFigureHandler, position);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %fermeture de la figure
            closeCallbackHandle = @this.closeCallback;
            set(this.getFigureHandler(), 'CloseRequestFcn', closeCallbackHandle);
 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


            %The display panel
            this.timeDisplayHandler = uicontrol(this.getFigureHandler() ,'Style','text','String','Timecode courant :', ...
                         'Position',[10 125 150 20],'BackgroundColor', bgColor, 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
            %Le panneau avec les boutons de contrôle
            this.recordTcVideoButtonHandler = uicontrol(this.getFigureHandler(), 'Style','pushbutton', 'String', ['Top vidéo (' this.videoDescription ') >'], 'Position',[10 100 150 20]);
            this.recordTcDataButtonHandler = uicontrol(this.getFigureHandler(), 'Style','pushbutton','String', 'Top données >', 'Position',[10 70 150 20]);
            this.synchroniseButtonHandler = uicontrol(this.getFigureHandler(), 'Style','pushbutton','String', 'Synchroniser', 'Position',[75 10 150 40],'Enable','off');
            %Les différents timecodes
            this.tcCurrentDisplayHandler = uicontrol(this.getFigureHandler() ,'Style','text','String',this.getCurrentTime, ...
                         'Position',[200 125 150 20],'BackgroundColor', bgColor, 'HorizontalAlignment', 'left');
            this.tcVideoDisplayHandler = uicontrol(this.getFigureHandler() ,'Style','text','String','--:--:--:---', ...
                         'Position',[200 97 150 20],'BackgroundColor', bgColor, 'HorizontalAlignment', 'left');
            this.tcDataDisplayHandler = uicontrol(this.getFigureHandler() ,'Style','text','String','--:--:--:---', ...
                         'Position',[200 67 150 20],'BackgroundColor', bgColor, 'HorizontalAlignment', 'left');  
        end

        function dynamizeUI(this)
            recordTcVideoButtonCallback = @this.recordTcVideoButtonCallback;
            set(this.recordTcVideoButtonHandler, 'Callback', recordTcVideoButtonCallback);
            recordTcDataButtonCallback = @this.recordTcDataButtonCallback;
            set(this.recordTcDataButtonHandler, 'Callback', recordTcDataButtonCallback);
            synchroniseButtonCallback = @this.synchroniseButtonCallback;
            set(this.synchroniseButtonHandler, 'Callback', synchroniseButtonCallback);
        end
        
        function current_time = getCurrentTime(this)
            current_time = fr.lescot.bind.utils.StringUtils.formatSecondsToString(this.getCurrentTrip.getTimer.getTime());
        end
        function recordTcVideoButtonCallback(this, source, ~)
            this.tcVideo = this.getCurrentTrip.getTimer.getTime();
            set(this.tcVideoDisplayHandler,'String',this.getCurrentTime());
            this.checkSynchronisable();
        end
        function recordTcDataButtonCallback(this, source, ~)
            this.tcData = this.getCurrentTrip.getTimer.getTime();
            set(this.tcDataDisplayHandler,'String',this.getCurrentTime());
            this.checkSynchronisable();
        end
        function synchroniseButtonCallback(this, source, ~)
            % Find current offset
            metaInfo = this.getCurrentTrip.getMetaInformations();
            videoFiles = metaInfo.getVideoFiles();
            for i = 1:1:length(videoFiles)
                if(strcmp(videoFiles{i}.getDescription(),this.videoDescription))
                    currentOffset = videoFiles{i}.getOffset();
                end
            end
            % calculate new offset
            offset = currentOffset + this.tcVideo - this.tcData;
            this.metaVideoFile.setOffset(offset);
            this.getCurrentTrip.updateVideoFileOffset(this.metaVideoFile);
            this.resetButtons();
        end
        function resetButtons(this)
            this.tcVideo = [];
            this.tcData = [];
            set(this.synchroniseButtonHandler,'Enable','off');
            set(this.tcVideoDisplayHandler,'String','--:--:--:---');
            set(this.tcDataDisplayHandler,'String','--:--:--:---');
            this.checkSynchronisable();
        end
        function checkSynchronisable(this)
            if not(isempty(this.tcVideo)) && not(isempty(this.tcData))
                set(this.synchroniseButtonHandler,'Enable','on');
            end
        end
        
        function closeCallback(this, src, ~)%ajout closeCallback
                nouvellePosition=this.getFigureHandler.Position();
                this.newPosition=nouvellePosition
                delete(this.getFigureHandler);
        end

    end

    
end