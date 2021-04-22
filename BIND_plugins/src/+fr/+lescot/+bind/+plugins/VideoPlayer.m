%{
Class:
This class creates a plugin used to replay videos and sound associated to trips.
This plugin is configured by
<plugins.configurators.VideoPlayerConfigurator> class.
This plugin use to specific library for video and audioplayback.
DirectShowAudio4BIND.dll and DirectShowVideo4BIND.dll
The video library use the rendering engine of Direct3D VRM9 and thus, require the installation of direct 9... and cannot be used over remote desktop connexion.

%}
classdef VideoPlayer < fr.lescot.bind.plugins.TripPlugin
       properties (Access=public)
        newPosition;%rajout     
    end
    properties (Access = private)
        %{
        Property:
        ID of the video opened by the dll
        %}
        videoID;
        %{
        Property:
        ID of the audio opened by the dll
        %}
        audioID;
        %{
        Property:
        String corresponding to the description of the video
        %}
        videoDescription;
        %{
        Property:
        String corresponding to the description of the video
        %}
        audioDescription;
        %{
        Property:
        Boolean explaining the capabilities of the plugin to replay video
        %}
        videoPlaybackCapabilities;
        %{
        Property:
        Length of the video film in milliseconds
        
        %}
        videoDuration;
        %{
        Property:
        Number of frame to drop. Higher is more frame to drop (is less CPU
        intensive). ( 1 frame / decimation ) is displayed
        
        %}
        decimation;
        %{
        Property:
        timecode in seconde of the 0 frame of the video (for synchronisation)
        
        %}
        videoOffset;
        %{
        Property:
        timecode in seconde of the 0 frame of the audio (for synchronisation)
        
        %}
        audioOffset;
        %{
        Property:
        For frame counting and decimation process
        
        %}
        counter;
        
        %{
        Property:
        Boolean giving the status of Audio Playback
        
        %}
        isPlayingAudio;
        
        %{
        Property:
        Boolean explaining the capabilities of the plugin to replay audio
        %}
        audioPlaybackCapabilities;
    end
    
    methods
        
        %{
        Function:
        The constructor of the VideoPlayer plugin. When instanciated, a
        window is opened, meeting the parameters.
        
        Arguments:
        trip - the reference trip to work on.
        position - a string understandable by the movegui command.
        description - the name of the video description to load
        decimation - The number of frame to drop.
        
        Returns:
        this - a new VideoPlayer.
        %}
        function this = VideoPlayer(trip, position, videoDescription, audioDescription, decimation)
            % we call the constructor of the superclass "TripPlugin"
            this@fr.lescot.bind.plugins.TripPlugin(trip);
            this.videoDescription = videoDescription;
            this.audioDescription = audioDescription;
            availableInfos = trip.getMetaInformations();
            videoFiles = availableInfos.getVideoFiles();
            for i = 1:1:length(videoFiles)
                if(strcmp(videoFiles{i}.getDescription(),this.videoDescription))
                    theVideo = i;
                end
                if(strcmp(videoFiles{i}.getDescription(),this.audioDescription))
                    theAudio = i;
                end
            end
            this.videoPlaybackCapabilities=true;
            pathToVideo = videoFiles{theVideo}.getFileName();
            pathToAudio = videoFiles{theAudio}.getFileName();
            
%             pathToVideo = '\\vrlescot\EQUIPE_SIGMA\These_Jonathan\Pre_experiment_data\Simu_RTMaps\200\Scenario_prototype_2\1.000000s\20180730_094023_RecFile_2\RecFile_2_20180730_094023_sensoray_2255_1_outputMAPSImage_1.avi';
%             pathToAudio = '\\vrlescot\EQUIPE_SIGMA\These_Jonathan\Pre_experiment_data\Simu_RTMaps\200\Scenario_prototype_2\1.000000s\20180730_094023_RecFile_2\RecFile_2_20180730_094023_Sound_Capture_DShow_1_stereoOutput.avi';
            this.videoOffset = videoFiles{theVideo}.getOffset();
            this.audioOffset = videoFiles{theAudio}.getOffset();
            this.decimation = decimation;
            if ~exist(pathToVideo,'file')
                this.videoPlaybackCapabilities = false;
                msgbox(['Le fichier video ' pathToVideo ' n''a pas été trouvé']);
            else
                % First of all, we check is the dll is loaded
                % in matlab, and if it is not the case, load it.
                if ~libisloaded('videoDllAlias')
                    % doc is here !
                    % http://www.mathworks.com/access/helpdesk/help/techdoc/ref/computer.html
                    arch = computer('arch');
                    switch arch
                        case 'win32'
                            loadlibrary('DShowVideo4BIND32.dll', @DShowVideo4BINDheader,'alias','videoDllAlias');
                        case 'win64'
                            loadlibrary('DShowVideo4BIND64.dll', @DShowVideo4BINDheader,'alias','videoDllAlias');
                    end
                end
                
                if ~libisloaded('audioDllAlias')
                    % doc is here !
                    % http://www.mathworks.com/access/helpdesk/help/techdoc/ref/computer.html
                    arch = computer('arch');
                    switch arch
                        case 'win32'
                            loadlibrary('DShowAudio4BIND32.dll', @DShowAudio4BINDheader,'alias','audioDllAlias');
                        case 'win64'
                            loadlibrary('DShowAudio4BIND64.dll', @DShowAudio4BINDheader,'alias','audioDllAlias');
                    end
                end
                
                % load video file and manage exceptions
                try
                    % load video file
                    this.videoID = calllib('videoDllAlias','LoadVideo',pathToVideo,0,['Camera view : ' videoDescription 'Audio listenning : ' audioDescription]);
                    this.audioPlaybackCapabilities = true;
                catch ME
                    if any(strcmp(ME.identifier,{'DSV4B:InitializingLibraryErr' 'DSA4B:CreateFilterGraphManagerErr'}))
                        errorMessage = 'Cannot initialise COM objects : video can not render';
                        msgbox(errorMessage)
                    end
                    
                    if strcmp(ME.identifier,'DSV4B:CantOpenFile')
                        errorMessage = 'Could not open the input file : Trying to open unexisting video file';
                        msgbox(errorMessage)
                    end
                    
                    if strcmp(ME.identifier,'DSV4B:NoSeekable')
                        errorMessage = 'The input video file doesn''t have seeking capabilities : replay with BIND requires direct video acces. video can not render!';
                        msgbox(errorMessage);
                    end
                    
                    % in all these situations, there is no way to play
                    % video
                    this.videoPlaybackCapabilities = false;
                end
                
                calllib('videoDllAlias', 'SetWindowPosition', this.videoID, position);
                this.videoDuration = calllib('videoDllAlias','GetDuration',this.videoID); % in milliseconds
                this.counter = 0;
                
                % load audio file and manage exceptions
                try
                    this.audioID = calllib('audioDllAlias','LoadAudio', pathToAudio);
                    this.audioPlaybackCapabilities = true;
                catch ME
                    this.audioPlaybackCapabilities = false;
                    if any(strcmp(ME.identifier,{'DSA4B:InitializingLibraryErr' 'DSA4B:CreateFilterGraphManagerErr'}))
                        errorMessage = 'Cannot initialise COM objects : audio can not render';
                        msgbox(errorMessage)
                    end
                    
                    if strcmp(ME.identifier,'DSA4B:CantOpenFile')
                        %no error message if the file is video only
                        %errorMessage = 'Could not open the input file : Trying to open unexisting audio file';
                        %msgbox(errorMessage)
                    end
                    
                    if strcmp(ME.identifier,'DSA4B:NoSeekable')
                        %errorMessage = 'The input audio file doesn''t have seeking capabilities : replay with BIND requires audio video acces. video can not render!';
                        %msgbox(errorMessage);
                    end
                
                end
                
                this.isPlayingAudio = false;
              
            end
        end
        
        %{
        Function:
        implementation of the <observation.Observer> interface. Can receive "STEP" and "GOTO"
        commands and "STOP" <observation.Message> and reacts
        accordingly : set video position and enable/disable audio playback
        
        Arguments:
        this - optional
        message - command
        
        %}
        function update(this,message)
            
            if strcmp(message.getCurrentMessage(),'TRIP_META_CHANGED')
                % Update the offset of the video
                availableInfos = this.getCurrentTrip().getMetaInformations();
                videoFiles = availableInfos.getVideoFiles();
                for i = 1:1:length(videoFiles)
                    if(strcmp(videoFiles{i}.getDescription(),this.videoDescription))
                        this.videoOffset = videoFiles{i}.getOffset();
                    end
                    if(strcmp(videoFiles{i}.getDescription(),this.audioDescription))
                        this.audioOffset = videoFiles{i}.getOffset();
                    end
                end
            end
            
            % if I receive a STEP, GOTO or a TRIP_META_CHANGED message from the trip,
            % I must update my position on the 2 dlls, audio et video
            if any(strcmp(message.getCurrentMessage(),{'STEP' 'GOTO' 'TRIP_META_CHANGED'}))
                
                timer = this.getCurrentTrip().getTimer();
                if this.videoPlaybackCapabilities
                    % calculation for decimation, find if frame must be redrawn
                    % because counter = n x decimation when the rest is 0
                    this.counter = this.counter + 1;
                    if and(mod(this.counter,this.decimation)==0, timer.getTime()>=-this.videoOffset)
                        % update video frame to trip timecode
                        calllib('videoDllAlias','SetPosition',this.videoID,1000*(timer.getTime() + this.videoOffset));
                    end
                end
                
                % consider audio controls only if video has
                % audio Playback Capabilities (determined during launch)
                if this.audioPlaybackCapabilities
                    % control audio playback (only play sound when watching
                    % video forward at x1 speed)
                    if (timer.getMultiplier() == 1 && timer.isRunning())
                        % good setup for sound playback
                        if ~this.isPlayingAudio && timer.getTime()>=-this.audioOffset
                            try
                                calllib('audioDllAlias','SetPosition',this.audioID,1000*(timer.getTime() + this.audioOffset));
                                calllib('audioDllAlias','Play',this.audioID);
                                this.isPlayingAudio = true;
                            catch ME
                                if strcmp(ME.identifier,'DSA4B:WrongID')
                                    errorMessage = 'Cannot navigate in audio file : wrong ID for SetPosition method';
                                    msgbox(errorMessage);
                                end
                            end
                        else
                            % need some regular basis resynchro because sound can not be step
                            % by step controlled and important derive occurs on
                            % slow machines
                            iterationWindow = 25 * 30;
                            if mod(this.counter,iterationWindow)==0
                                %reset counter
                                this.counter = 0;
                                %resynch
                                try
                                    calllib('audioDllAlias','SetPosition',this.audioID,1000*(timer.getTime() + this.audioOffset));
                                    calllib('audioDllAlias','Play',this.audioID);
                                catch ME
                                    if strcmp(ME.identifier,'DSA4B:WrongID')
                                        errorMessage = 'Cannot navigate in audio file : wrong ID for SetPosition method';
                                        msgbox(errorMessage);
                                    end
                                end
                            end
                        end
                    else
                        % bad setup for sound playback
                        if this.isPlayingAudio
                            try
                                calllib('audioDllAlias','Pause',this.audioID);
                                this.isPlayingAudio = false;
                            catch ME
                                if strcmp(ME.identifier,'DSA4B:WrongID')
                                    errorMessage = 'Cannot pause audio playback: wrong ID for Pause method';
                                    msgbox(errorMessage);
                                end
                            end
                            
                        end
                    end
                end
            end
            
            % if I receive a STOP message from the trip, I must
            % stop video playback
            if any(strcmp(message.getCurrentMessage(),{'STOP'}))
                if this.audioPlaybackCapabilities
                    if this.isPlayingAudio
                        try
                            calllib('audioDllAlias','Pause',this.audioID);
                            this.isPlayingAudio = false;
                        catch ME
                            if strcmp(ME.identifier,'DSA4B:WrongID')
                                errorMessage = 'Cannot pause audio playback: wrong ID for Pause method';
                                msgbox(errorMessage);
                            end
                        end
                        
                    end
                end
                %reset counter
                this.counter = 0;
            end
        end
        
        %{
        Function:
         Method to handle unloading of the dll
        
        Arguments:
        this - optional
        
        %}
        function delete(this)
            % if it was possible to load video, unload... and if it was the
            % last film, remove the library
            if this.videoPlaybackCapabilities
                calllib('videoDllAlias','UnloadVideo',this.videoID);
                
                if calllib('videoDllAlias', 'NoMoreVideo')
                    % when there is no more video to unload, we can unload the
                    % dll
                    unloadlibrary('videoDllAlias');
                end
            end
            
            % if it was possible to replay sound, unload the sound file and
            % if it was the last one, remove the library
            if this.audioPlaybackCapabilities
                calllib('audioDllAlias','UnloadAudio',this.audioID);
                
                if calllib('audioDllAlias', 'NoMoreAudio')
                    % when there is no more audio to unload, we can unload the
                    % dll
                    unloadlibrary('audioDllAlias');
                end
            end
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
            out = '[ALL] Lecteur AudioVidéo';
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
            out = 'fr.lescot.bind.configurators.VideoPlayerConfigurator';
        end
        
        
      
    end
end

