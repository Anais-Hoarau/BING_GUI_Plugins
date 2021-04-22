%{
Class:
This abstract class is the template for all the plugins that focus on
time driven data analysis with a graphical component, focused on an only
<kernel.Trip> object.

%}
classdef VisualisationPlugin < fr.lescot.bind.plugins.GraphicalPlugin & fr.lescot.bind.plugins.TripPlugin
    
    methods (Access = public)
        
        %{
        Function:
        Constructor of the plugin. It set the <currentTrip> to the one
        passed as argument, and creates a 100px by 100px window, which is
        visible by default. This window is accessible via the
        <getFigureHandler> method.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        varagin - An array of argument. However, the only correct number
        of arguments is ONE, and it must be the <kernel.Trip> to
        monitor.
        %}
        function plugin = VisualisationPlugin(varargin)
            plugin@fr.lescot.bind.plugins.TripPlugin(varargin{1});
        end
        
        %{
        Function:
        Setter for the current trip. This method changes the Trip
        monitored by the plugin, including the unregistration from the
        <kernel.Observable> step.
        
        Arguments:
        obj - The object on which the function is called, optionnal.
        newTrip - The new <kernel.Trip> object.
        %}
        function changeCurrentTrip(obj, newTrip)
            obj.currentTrip.removeObserver(obj);
            obj.currentTrip = newTrip;
            obj.currentTrip.addObserver(obj);
        end
        
    end
    
    methods (Abstract = true)
        
        %{
        Function:
        See <observation.Observer.update()>.
        
        %}
        update(object, message)   
    end
    
    methods(Static)
        
        %{
        Function:
        See <plugins.Plugin.isMultiTrip()>
        %}
        function out = isMultiTrip(this)
            out = false;
        end
        
    end
    
end

