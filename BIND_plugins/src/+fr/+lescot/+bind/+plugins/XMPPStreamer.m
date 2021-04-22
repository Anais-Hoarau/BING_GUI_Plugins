%{
Class:
This class provides an XMPP streaming plugin that allows to stream datas
to a remote recipient.
The data are embedded in a dataform (xmpp protocol extension) that permit to create 
couple of 'variable/value'. A timecode field is always attached to the dataform in order to 
timestamp the variable value couple.

%}
classdef XMPPStreamer < fr.lescot.bind.plugins.TripStreamingPlugin & fr.lescot.bind.plugins.GraphicalPlugin
    
    properties(Access = private)
        %{
        Property:
        The matjab bot.
        
        %}
        bot;
        %{
        Property:
        The login used to connect to the xmpp server.
        
        %}
        username;
        %{
        Property:
        The ressource used to connect to the xmpp server.
        
        %}
        ressource;
        %{
        Property:
        The network name or the ip adress of the xmpp server.
        
        %}
        xmppServer;
        %{
        Property:
        The JID name of the messages recipient.
        
        %}
        recipientJID;
        %{
        Property:
        The inner counter of sent messages
        
        %}
        sentFramesCount;
        %{
        Property:
        The handler on the text fields used to display the content of
        <sentFramesLabel>.
        
        %}
        sentFramesLabel;
        %{
        Property:
        The handler on the toggle button that enables or disables
        synchronization.
        
        %}
        toggleSyncButton
    end
    
    methods
        %{
        Function:
        The constructor of the XMPPStreamer plugin. When instanciated, a
        window is opened, meeting the parameters.
        
        Arguments:
        trip - A <fr.lescot.bind.kernel.Trip> object, that will be
        commanded by the plugin.
        dataIdentifiers - A cell array of strings with a
        dataName.variableName format. Describes the variables that will be
        sent on each STEP or GOTO event.
        position - The starting position of the window.
        xmppServer - A string containing the adress of the xmpp server on
        which the plugin will connect.
        username - A string containing the login the plugin will use to connect to the xmpp
        server.
        password - A string containing the password the plugin will use to connect to the xmpp
        server.
        ressource - A string containing the ressource the plugin will use to connect to the xmpp
        server. May be an empty String.
        recipientJID - A string containing the jid of the reciptient of the streamed message. 
        
        
        Returns:
        this - a new XMPPStreamer.
        %}
        function this = XMPPStreamer(trip, dataIdentifiers, position, xmppServer, username, password, ressource, recipientJID)
            this@fr.lescot.bind.plugins.TripStreamingPlugin(trip, dataIdentifiers, 60, 'data');
            this@fr.lescot.bind.plugins.GraphicalPlugin();
            this.username = username;
            this.ressource = ressource;
            this.xmppServer = xmppServer;
            this.recipientJID = recipientJID;
            this.sentFramesCount = 0;
            this.buildUI(position);
            %Build and connect the XMPP bot
            this.bot = fr.lescot.matjab.Bot(xmppServer, username, password, ressource, 'false');
            try
                this.bot.connect();
            catch ME
                uiwait(errordlg(ME.message,'XMPPStreamer : Erreur', 'modal'));
                this.closeCallback();
            end
        end
        
        %{
        Function:
        
        This method is the implementation of the <observation.Observer.update> method. It
        updates the display after each message from the Trip.
        %}
        function update(this, message)
            import fr.lescot.matjab.*;
            import fr.lescot.matjab.extension.dataForm.*;
            this.update@fr.lescot.bind.plugins.TripStreamingPlugin(message);
            
            if any(strcmp(message.getCurrentMessage(), {'STEP' 'GOTO'})) && get(this.toggleSyncButton, 'Value')
                %Build the message
                message = Message();
                message.setTo(this.recipientJID);
                message.setFrom([this.username '@' this.xmppServer '/' this.ressource]);

                dataForm = DataForm('submit');
                dataForm.setTitle('variables');

                currentTime = this.getCurrentTrip.getTimer.getTime();
                % always add a "timecode" field to the dataform
                newField = FormField('reference.timecode');
                newField.addValue(num2str(currentTime));
                dataForm.addField(newField);
                
                for i = 1:1:this.dataNumber
                    [~, currentTimeIndex] = min(abs(cell2mat(this.dataBuffer{i,2}) - currentTime));
                    if ~isempty(currentTimeIndex)
                        newField = FormField([this.dataName{i} '.' this.variableName{i}]);
                        value = sprintf('%.12f',this.dataBuffer{i,1}{currentTimeIndex});
                        newField.addValue(value);
                        dataForm.addField(newField);
                    end
                end
                
                if ~isempty(dataForm.getFields)
                    message.addExtension(dataForm);
                    this.bot.sendMessage(message);
                    %Change the sent frame count
                    this.sentFramesCount = this.sentFramesCount + 1;
                    set(this.sentFramesLabel, 'String', ['Trames envoyées : ' sprintf('%d', this.sentFramesCount)]);
                end
            end
        end
        
        %{
        Function:
        This method overwrite the default delete to ensure that the bot
        is properly disconnected when the XMPPStreamer is deleted.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        void
        %}
        function delete(this)
            this.bot.disconnect();
        end
    end
        
    methods(Access = private)
        
        %{
        Function:
        Launched when the window have to be closed.
        
        Arguments:
        this - optional
        
        %}
        function closeCallback(this, ~, ~)
           this.closeWindow(); 
           this.delete();
        end
        
        %{
        Function:
        Build the window of the GUI
        
        Arguments:
        this - The object on which the function is called, optionnal.
        position - The initial position of the GUI.
        
        %}
        function buildUI(this, position)
            bgColor = get(this.getFigureHandler(), 'Color');
            set(this.getFigureHandler(), 'Name', 'XMPPStreamer');
            set(this.getFigureHandler, 'Position', [0 0 135 60]);
            this.sentFramesLabel = uicontrol(this.getFigureHandler(), 'Style','text','String','Trames envoyées : 0', 'Position',[10 45 180 15], 'BackgroundColor', bgColor, 'HorizontalAlignment', 'left');
            this.toggleSyncButton = uicontrol(this.getFigureHandler(), 'Style','togglebutton ','String','Synchronisation', 'Position',[10 10 120 30], 'HorizontalAlignment', 'left');
            set(this.toggleSyncButton, 'Value', 1); 
            movegui(this.getFigureHandler(), position);
            set(this.getFigureHandler(), 'Visible', 'on');
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
            out = '[D] Envoi de données sur le réseau';
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
            out = 'fr.lescot.bind.configurators.XMPPStreamerConfigurator';
        end
    end
    
end
