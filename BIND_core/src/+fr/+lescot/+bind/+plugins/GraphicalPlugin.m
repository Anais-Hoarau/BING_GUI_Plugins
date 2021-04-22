%{
Class:
This abstract class is the template for all the plugins that needs a
windows to dispay themselves. It includes a <KeyPressManager> to which it forwards
all the keyboard input detected. So, *don't use WindowKeyPress* in your plugins
to create some keyboard events. Instead, use the update method and detect
message of class fr.lescot.bind.plugins.KeyMessage and treat them in your plugin.
This way, all the graphical plugins will be able to react to all the keyboard input, 
provided that one of the have the focus. Please note that if several plugins
share some reactions to the same key combinations, *ALL* the plugins will
react, no matter which on have the focus.

%}
classdef GraphicalPlugin < fr.lescot.bind.plugins.Plugin & fr.lescot.bind.observation.Observer
    
    properties(Access = private)
        %{
        Property:
        The handle on the window.
        
        %}
        figureHandler;
        
        %{
        Property:
        The <KeyPressManager>.
        
        %}
        keyPressManager;
    end
    
    methods
        
        %{
        Function:
        The constructor of the class. It instanciates the window as a
        visible 100x100px window, and a location of [0,0]. Some other
        minor options are set, but they all can be overwritten anyway.
        
        Returns:
        The GraphicalPlugin object.
        %}
        function this = GraphicalPlugin()
            closeWindowCallback = @this.closeWindow;
            this.keyPressManager = fr.lescot.bind.plugins.KeyPressManager.getInstance();
            this.keyPressManager.addObserver(this);
            this.figureHandler = figure('MenuBar', 'none', 'Name', 'Plugin', 'DockControls', 'off', 'NumberTitle', 'off', 'Resize', 'off', 'Toolbar', 'none', 'Visible', 'off', 'Position', [0 0 100 100], 'CloseRequestFcn',closeWindowCallback, 'PaperPositionMode', 'auto');
            set(this.figureHandler, 'WindowKeyPressFcn', @this.keyPressCallback);
        end
        
        %{
        Function:
        Returns the figure handler.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        The figureHandler, thus allowing the use of the handle to modify
        the window or as a parent for other graphical components.
        %}
        function out = getFigureHandler(this)
            out = this.figureHandler;
        end
    end
    
    methods(Access = public)
        
        %{
        Function:
        The callback called when the window is closed.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        %}
        function closeWindow(this, ~, ~)
            delete(this.figureHandler);
            this.keyPressManager.removeObserver(this);
            delete(this);
        end
        
    end
    
    methods(Access = private)
        %{
        Function:
        The callback that calls the keyPressManager each time a keyboard event is caught.
        %}
        function keyPressCallback(this, source, evtData)
            this.keyPressManager.broadcastKeyEvent(source, evtData);
        end
        
    end
    
end

