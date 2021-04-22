%{
Class:
This class is a dedicated singeton observable that is designed to be called by a
plugin when it catches a keyboard event. Each time an event is passed to the
Manager, it is transmitted in the form of a <plugins.KeyMessage> to all the
plugins that observes it (by default, all the <GraphicalPlugins> do it).

Known bug:
Key pressed to enter text into an edit field should not be forwarded to the
other plugins. However, a bug in Matlab 'figure' object (more precisely in
CurrentObject property) cause the first input letter to be forwarded. As of
2010b, it is not solved. However, it is known by Matlab developpers, and we
can hope for a fix in a future release.
%}
classdef KeyPressManager < handle & fr.lescot.bind.observation.Observable
    
    
    methods (Access = private)
        %{
        Function:
        The constructor of the class is private, so it can't be used anywhere but in this class (part
        of the singleton implementation).
        %}
        function this = KeyPressManager()
        end
    end
    
    methods (Static)
        
        %{
        Function:
        Returns the singleton instance of the KeyManager.
        
        Returns:
        out - A KeyManager.
        %}
        function out = getInstance()
            persistent localInstance
            if isempty(localInstance) || ~isvalid(localInstance)
                localInstance = fr.lescot.bind.plugins.KeyPressManager();
            end
            out = localInstance;
        end
        
    end
    
    methods
        
        %{
        Function:
        Builds a <KeyMessage> from a WindowKeyPressFcn event and broadcasts it to
        all the suscribing plugins.
        %}
        function broadcastKeyEvent(this, src, event)
            %Determine if the currently selected control is a component requiring keyboard input
            %If it is the case, we don't broadcast the event
            broadCastEnabled = true;
            selectedElement = get(src, 'CurrentObject');
            selectedElementType = get(selectedElement, 'Type');
            if strcmp('uicontrol', selectedElementType)
                selectedElementStyle = get(selectedElement, 'Style');
                if any(strcmp(selectedElementStyle, {'edit'}))%add in the array any other uicontrol requiring text input
                    broadCastEnabled = false;
                end
                disp(['Broadcasting : ' selectedElementStyle ' : ' event.Key]);
            end
            if broadCastEnabled
                builtString = '';
                sortedModifiers = sort(event.Modifier);
                for i = 1:1:length(sortedModifiers)
                    builtString = [builtString sortedModifiers{i} '_']; %#ok<AGROW>
                end
                builtString = [builtString event.Key '_' event.Character];
                message = fr.lescot.bind.plugins.KeyMessage();
                message.setCurrentMessage(builtString);
                this.notifyAll(message);
            end
        end
        
    end
    
end

