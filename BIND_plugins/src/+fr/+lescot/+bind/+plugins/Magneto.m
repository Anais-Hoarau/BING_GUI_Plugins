%{
Class:
This class instanciates a panel that allow to control the trip, and by
extension all the plugins that observe the trip.
%}
classdef Magneto < fr.lescot.bind.plugins.GraphicalPlugin & fr.lescot.bind.plugins.TripPlugin
    
    properties(Access = private)
        %Simple commands panel controls
        
        %{
        Property:
        The handler of the first stop button (simple controls).
        
        %}
        stopButtonHandler;
        %{
        Property:
        The handler of the play button.
        
        %}
        playButtonHandler;
        %{
        Property:
        The handler of the play backward button.
        
        %}
        playBackwardButtonHandler;
        %{
        Property:
        The handler of the slider that indicates the current position in the file.
        
        %}
        sliderHandler;
        
        %Time panel elements
        
        %{
        Property:
        The text field that contains the current time.
        
        %}
        timeDisplayHandler;
        %{
        Property:
        The text field that contains the current remaining time before the end of the file.
        
        %}
        remainingTimeDisplayHandler;
        
        %Advanced command panel controls
        
        %{
        Property:
        The handler of the button that starts variable speed rewinding.
        
        %}
        rewindButtonHandler;
        %{
        Property:
        The handler of the button that moves one image backward.
        
        %}
        stepBackwardButtonHandler;
        %{
        Property:
        The handler of the second stop button (Advanced controls).
        
        %}
        stopButtonHandler2;
        %{
        Property:
        The handler of the button that moves one image forward.
        
        %}
        stepForwardButtonHandler;
        %{
        Property:
        The handler of the button that starts variable speed forwarding.
        
        %}
        forwardButtonHandler;
        
        %Backward speed block
        
        %{
        Property:
        The handler of the button that increase the speed of variable speed backward playing.
        
        %}
        increaseSpeedBackward;
        %{
        Property:
        The handler of the button that decrease the speed of variable speed backward playing.
        
        %}
        decreaseSpeedBackward;
        %{
        Property:
        The handler of the text field holding the value of the speed of variable speed backward playing.
        
        %}
        textSpeedBackward;
        
        %Forward speed block
		
        %{
        Property:
        The handler of the button that increase the speed of variable speed forward playing.
        
        %}
        increaseSpeedForward;
        %{
        Property:
        The handler of the button that decrease the speed of variable speed forward playing.
        
        %}
        decreaseSpeedForward;
        %{
        Property:
        The handler of the text field holding the value of the speed of variable speed forward playing.
        
        %}
        textSpeedForward;
        
        %{
        Property:
        The handler of the goto button (Advanced controls).
        
        %}
        gotoButton;
        
        %Utilities vars
        
        %{
        Property:
        A cell array that contains all the toggle buttons of the GUI that are (mostly) mutually exclusives.
        
        %}
        buttonsArray;
        
        %{
        Property:
        The color used by the buttons as BackgroundColor when they are instanciated.
        
        %}
        originalButtonsColor;
        
        %{
        Property:
        This handlers points to the 
        
        %}
        currentlyPlayingButton;
    end
    
    methods
        
        %{
        Function:
        The constructor of the Magneto plugin. When instanciated, a
        window is opened, meeting the parameters.
        
        Arguments:
        trip - <A fr.lescot.bind.kernel.Trip> object, that will be
        commanded by the plugin.
        position - The starting position of the window.
        
        
        Returns:
        this - a new VideoPlayerConfigurator.
        %}
        function magneto = Magneto(trip, position)
            magneto@fr.lescot.bind.plugins.TripPlugin(trip);
            magneto.buildUI(position);
            magneto.dynamizeUI();
            
            %Setting visible
            set(magneto.getFigureHandler,'Visible', 'on');
        end
        
        %{
        Function:
        
        This method is the implementation of the <observation.Observer.update> method. It
        updates the display after each message from the Trip.
        %TODO : update doc
        %}
        function update(this, message)
            if isa(message, 'fr.lescot.bind.kernel.TimerMessage')
                import('fr.lescot.bind.utils.StringUtils');
                set(this.timeDisplayHandler, 'String', ['Temps : ' StringUtils.formatSecondsToString(this.getCurrentTrip.getTimer.getTime())]);
                set(this.remainingTimeDisplayHandler, 'String', ['Restant : ' StringUtils.formatSecondsToString(this.getCurrentTrip().getMaxTimeInDatas() - this.getCurrentTrip.getTimer.getTime())]);
                set(this.sliderHandler, 'Value', this.getCurrentTrip.getTimer.getTime());  
            end
            if isa(message, 'fr.lescot.bind.plugins.KeyMessage')
               %Do things :)
            end
        end
        
    end
    
    methods(Static)
        %{
        Function:
        Returns the human-readable name of the filter.
        
        Returns:
        A String.
        
        %}
        function out = getName()
            out = '[ALL] Magnétoscope';
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
            out = 'fr.lescot.bind.configurators.MagnetoConfigurator';   
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
            bgColor = get(this.getFigureHandler(), 'Color');
            set(this.getFigureHandler, 'Name', 'Magnétoscope');
            set(this.getFigureHandler, 'Position', [0 0 350 320]);
            movegui(this.getFigureHandler, position);
            %Loading images
            stepBackwardImg = imread(which('step_backward.jpg'));
            rewindImg = imread(which('rewind.jpg'));
            stopImg = imread(which('stop.jpg'));
            playBackwardImg = imread(which('play_backward.jpg'));
            playImg = imread(which('play.jpg'));
            fastForwardImg = imread(which('fast_forward.jpg'));
            stepForwardImg = imread(which('step_forward.jpg'));
            %Adding ui elements
            %Simple commands panel
            simplePanel = uipanel(this.getFigureHandler(), 'BackgroundColor', bgColor, 'Title', 'Commandes basiques', 'Units', 'pixel', 'Position', [20 220 310 100]);
            this.playBackwardButtonHandler = uicontrol(simplePanel, 'Style','togglebutton','CData', playBackwardImg, 'Position',[70 30 50 50]);
            this.stopButtonHandler = uicontrol(simplePanel, 'Style','togglebutton','CData', stopImg, 'Position',[130 30 50 50]);
            this.playButtonHandler = uicontrol(simplePanel, 'Style','togglebutton','CData', playImg, 'Position',[190 30 50 50]);
            this.sliderHandler = uicontrol(simplePanel, 'Style','Slider', 'Position',[10 10 290 10], 'Max', this.getCurrentTrip().getMaxTimeInDatas());
            %The display panel
            displayPanel = uipanel(this.getFigureHandler(), 'BackgroundColor', bgColor, 'Title', 'Temps', 'Units', 'pixel', 'Position', [20 160 310 40]);
            this.timeDisplayHandler = uicontrol(displayPanel ,'Style','text','String','Temps : 00:00:00:0000', 'Position',[10 3 120 20],'BackgroundColor', bgColor, 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
            this.remainingTimeDisplayHandler = uicontrol(displayPanel ,'Style','text','String','Restant : 00:00:00:0000', 'Position',[150 3 120 20],'BackgroundColor', bgColor, 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
            %Advanced commands panel
            advancedPanel = uipanel(this.getFigureHandler(), 'BackgroundColor', bgColor, 'Title', 'Commandes avancées', 'Units', 'pixel', 'Position', [20 20 310 120]);
            this.rewindButtonHandler = uicontrol(advancedPanel, 'Style','togglebutton','CData', rewindImg, 'Position',[10 50 50 50]);
            this.stepBackwardButtonHandler = uicontrol(advancedPanel, 'Style','pushbutton','CData', stepBackwardImg, 'Position',[70 50 50 50]);
            this.stopButtonHandler2 = uicontrol(advancedPanel ,'Style','togglebutton','CData', stopImg, 'Position',[130 50 50 50]);
            this.stepForwardButtonHandler = uicontrol(advancedPanel, 'Style','pushbutton','CData', stepForwardImg, 'Position',[190 50 50 50]);
            this.forwardButtonHandler = uicontrol(advancedPanel,'Style','togglebutton','CData', fastForwardImg, 'Position',[250 50 50 50]);
            %The two spinners for the speed
            this.increaseSpeedBackward = uicontrol(advancedPanel, 'Style', 'pushbutton', 'String', '+', 'Position', [10 36 50 15]);
            this.decreaseSpeedBackward = uicontrol(advancedPanel, 'Style', 'pushbutton', 'String', '-', 'Position', [10 8 50 15]);
            this.textSpeedBackward = uicontrol(advancedPanel,'Style','text','String','1x', 'Position',[10 23 50 13]);
            
            this.increaseSpeedForward = uicontrol(advancedPanel, 'Style', 'pushbutton', 'String', '+', 'Position', [250 36 50 15]);
            this.decreaseSpeedForward = uicontrol(advancedPanel, 'Style', 'pushbutton', 'String', '-', 'Position', [250 8 50 15]);
            this.textSpeedForward = uicontrol(advancedPanel,'Style','text','String','1x', 'Position',[250 23 50 13]);
            
            %The goto button
            this.gotoButton = uicontrol(advancedPanel, 'Style', 'pushbutton', 'String', 'Aller à ...', 'Position', [115 8 80 35]);
            
            %Initialisation of the utility vars
            this.buttonsArray = {this.rewindButtonHandler this.stopButtonHandler this.playButtonHandler this.stopButtonHandler2 this.playBackwardButtonHandler this.forwardButtonHandler};
            this.originalButtonsColor = get(this.rewindButtonHandler, 'BackgroundColor');
            
        end
 
        %{
        Function:
        Adds all the callbacks to the GUI.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        %}
        function dynamizeUI(this)
            %Adding callbacks on buttons
            %Simple commands
            playBackwardButtonCallback = @this.playBackwardCallback;
            set(this.playBackwardButtonHandler, 'Callback', playBackwardButtonCallback);
            stopButtonCallback = @this.stopCallback;
            set(this.stopButtonHandler, 'Callback', stopButtonCallback);
            playButtonCallback = @this.playCallback;
            set(this.playButtonHandler, 'Callback', playButtonCallback);


            %Advanced commands
            set(this.stopButtonHandler2, 'Callback', stopButtonCallback);
            
            decreaseSpeedCallbackHandler = @this.decreaseSpeedBackwardCallback;
            set(this.decreaseSpeedBackward, 'Callback',decreaseSpeedCallbackHandler); 
            increaseSpeedBackwardCallbackHandler = @this.increaseSpeedBackwardCallback;
            set(this.increaseSpeedBackward, 'Callback',increaseSpeedBackwardCallbackHandler);
            rewindButtonCallback = @this.rewindCallback;
            set(this.rewindButtonHandler, 'Callback',rewindButtonCallback);

            stepForwardButtonCallback = @this.stepForwardCallback;
            set(this.stepForwardButtonHandler, 'Callback', stepForwardButtonCallback);
            stepBackwardButtonCallback = @this.stepBackwardCallback;
            set(this.stepBackwardButtonHandler, 'Callback', stepBackwardButtonCallback);
            
            decreaseSpeedCallbackHandler = @this.decreaseSpeedForwardCallback;
            set(this.decreaseSpeedForward, 'Callback',decreaseSpeedCallbackHandler); 
            increaseSpeedForwardCallbackHandler = @this.increaseSpeedForwardCallback;
            set(this.increaseSpeedForward, 'Callback',increaseSpeedForwardCallbackHandler);
            forwardButtonCallback = @this.forwardCallback;
            set(this.forwardButtonHandler, 'Callback',forwardButtonCallback);
            
            sliderCallbackHandler = @this.sliderCallback;
            addlistener(this.sliderHandler, 'Action', sliderCallbackHandler);
            
            gotoButtonCallbackHandler = @this.gotoButtonCallback;
            set(this.gotoButton, 'Callback', gotoButtonCallbackHandler);
        end
        
        %{
        Function:
        Unpush the non selected buttons if they are in <buttonsArray>.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        selectedButtonsArray - A cell array of button handlers.
        
        %}
        function setButtonsState(this, selectedButtonsArray)
            for i = 1:1:length(this.buttonsArray)
               isInSelectedArray = false;
               for j = 1:1:length(selectedButtonsArray)
                   isInSelectedArray = isInSelectedArray || ( selectedButtonsArray{j} ==  this.buttonsArray{i});
               end
               set(this.buttonsArray{i}, 'Value', isInSelectedArray);
            end
        end
        
        %{
        Function:
        The callback of the goto button.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        %}
        function gotoButtonCallback(this, ~, ~)
            timeElements = {'00' '00' '00' '000'};
            valid = false;
            while ~valid
                timeElements = inputdlg({'Heures', 'Minutes', 'Secondes', 'Millisecondes'}, 'Aller à', 1, timeElements);
                if ~isempty(timeElements)
                    timeElementsNum = cell(1, length(timeElements));
                    valid = true;
                    for i = 1:1:length(timeElements)
                        timeElementsNum{i} = str2double(timeElements{i});
                        valid = valid && ~isnan(timeElementsNum{i}) && (timeElementsNum{i} >= 0);
                    end
                else
                    valid = true;
                end
            end
            if ~isempty(timeElements)
                hours = timeElementsNum{1};
                minutes = timeElementsNum{2};
                seconds = timeElementsNum{3};
                millis = timeElementsNum{4};
                newTime = min(3600 * hours + 60 * minutes + seconds + millis / 1000, this.getCurrentTrip().getMaxTimeInDatas()); 
                this.getCurrentTrip().getTimer().setTime(newTime);
            end
        end
        
        %{
        Function:
        The callback of the "-" button related to forward speed.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        %}
        function decreaseSpeedForwardCallback(this, ~, ~)
           this.lesserSpeed(this.textSpeedForward);
           if this.currentlyPlayingButton == this.forwardButtonHandler
               this.forwardCallback(this.forwardButtonHandler);
           end
        end
        
        %{
        Function:
        The callback of the "+" button related to forward speed.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        %}
        function increaseSpeedForwardCallback(this, ~, ~)
           this.raiseSpeed(this.textSpeedForward);
           if this.currentlyPlayingButton == this.forwardButtonHandler
               this.forwardCallback(this.forwardButtonHandler);
           end
        end
        
        %{
        Function:
        The callback of the "-" button related to backward speed.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        %}
        function decreaseSpeedBackwardCallback(this, ~, ~)
           this.lesserSpeed(this.textSpeedBackward);
           if this.currentlyPlayingButton == this.rewindButtonHandler
               this.rewindCallback(this.rewindButtonHandler);
           end
        end
        
        %{
        Function:
        The callback of the "+" button related to backward speed.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        %}
        function increaseSpeedBackwardCallback(this, ~, ~)
           this.raiseSpeed(this.textSpeedBackward);
           if this.currentlyPlayingButton == this.rewindButtonHandler
               this.rewindCallback(this.rewindButtonHandler);
           end
        end
        
        %{
        Function:
        Parses the current content of a speed text field and divide it by
        two.
        
        Arguments:
        textField - The handler of a textfield containing a speed.
        
        %}
        function lesserSpeed(~, textField)
            currentString = get(textField, 'String');
            currentString = currentString(1:length(currentString)-1);
            newValue = str2double(currentString)/2;
            set(textField, 'String', [sprintf('%.4g', newValue) 'x']);
        end
        
        %{
        Function:
        Parses the current content of a speed text field and multiplies it by
        two.
        
        Arguments:
        textField - The handler of a textfield containing a speed.
        
        %}
        function raiseSpeed(~, textField)
            currentString = get(textField, 'String');
            currentString = currentString(1:length(currentString)-1);
            newValue = str2double(currentString)*2;
            set(textField, 'String', [sprintf('%.4g', newValue) 'x']);
        end
        
        %{
        Function:
        The callback of the time slider.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        %}
        function sliderCallback(this, ~, ~)
            this.stopCallback(this.stopButtonHandler);
            newTime = get(this.sliderHandler, 'Value');
            this.getCurrentTrip().getTimer().setTime(newTime);
        end
        
        %{
        Function:
        The callback of the forward play button.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        source - A handler to the object that caused the callback to be
        called.
        
        %}
        function forwardCallback(this, source, ~)
            if(this.getCurrentTrip.getTimer.getTime() < this.getCurrentTrip().getMaxTimeInDatas())
                currentString = get(this.textSpeedForward, 'String');
                currentString = currentString(1:length(currentString)-1);
                this.getCurrentTrip.getTimer.setMultiplier(str2double(currentString));
                this.getCurrentTrip.getTimer.startTimer();
            end
            this.setButtonsState({source});
            this.currentlyPlayingButton = source;
        end
        
        %{
        Function:
        The callback of the rewind play button.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        source - A handler to the object that caused the callback to be
        called.
        
        %}
        function rewindCallback(this, source, ~)
            if(this.getCurrentTrip.getTimer.getTime() > 0)
                currentString = get(this.textSpeedBackward, 'String');
                currentString = currentString(1:length(currentString)-1);
                this.getCurrentTrip.getTimer.setMultiplier(-1*str2double(currentString));
                this.getCurrentTrip.getTimer.startTimer();
            end
            this.setButtonsState({source});
            this.currentlyPlayingButton = source;
        end
        
        %{
        Function:
        The callback of the step one image backward button.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        source - A handler to the object that caused the callback to be
        called.
        
        %}
        function stepBackwardCallback(this, source, ~)
            this.getCurrentTrip.getTimer.stopTimer();
            this.getCurrentTrip.getTimer.setMultiplier(1);
            newTime = this.getCurrentTrip().getTimer().getTime() - this.getCurrentTrip().getTimer().getDefaultPeriod();
            this.getCurrentTrip.getTimer.setTime(max(0, newTime));
            this.setButtonsState({source});
            this.currentlyPlayingButton = source;
        end
        
        %{
        Function:
        The callback of the step one image forward button.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        source - A handler to the object that caused the callback to be
        called.
        
        %}
        function stepForwardCallback(this, source, ~)
            this.getCurrentTrip.getTimer.stopTimer();
            this.getCurrentTrip.getTimer.setMultiplier(1);
            newTime = this.getCurrentTrip().getTimer().getTime() + this.getCurrentTrip().getTimer().getDefaultPeriod();
            this.getCurrentTrip.getTimer.setTime(min(newTime, this.getCurrentTrip().getMaxTimeInDatas()));
            this.setButtonsState({source});
            this.currentlyPlayingButton = source;
        end
        
        %{
        Function:
        The callback of the play button.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        source - A handler to the object that caused the callback to be
        called.
        
        %}
        function playCallback(this, source, ~)
            this.getCurrentTrip.getTimer.setMultiplier(1);
            this.getCurrentTrip.getTimer.startTimer();
            this.setButtonsState({source});
            this.currentlyPlayingButton = source;
        end
        
        %{
        Function:
        The callback of the play backward button.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        source - A handler to the object that caused the callback to be
        called.
        
        %}
        function playBackwardCallback(this, source, ~)
            this.getCurrentTrip.getTimer.setMultiplier(-1);
            this.getCurrentTrip.getTimer.startTimer();
            this.setButtonsState({source});
            this.currentlyPlayingButton = source;
        end
        
        %{
        Function:
        The callback of the stop button.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        source - A handler to the object that caused the callback to be
        called.
        
        %}
        function stopCallback(this, source, ~)
            this.getCurrentTrip.getTimer.stopTimer();
            this.setButtonsState({this.stopButtonHandler this.stopButtonHandler2});
            this.currentlyPlayingButton = source;
        end
        
    end
    
end

