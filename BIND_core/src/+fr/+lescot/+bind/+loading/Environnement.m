%{
Class:
This class is mostly dedicated to saving and loading a loader run environnement in a file. An environnement
is composed of a list of trips, a list of plugin classes, and a configuration for each plugin. Files are
saved in .env format.
%}
classdef Environnement < handle
    
    properties(Access = private)
        %{
        Property:
        The cell array of string representing the plugins classes.
        %}
        pluginClasses = {};
        %{
        Property:
        The cell array of <configurators.Configuration>.
        %}
        pluginConfigurations = {};
        %{
        Property:
        The cell array of <kernel.Trip>.
        %}
        trips = {};
    end
    
    methods
        
        %{
        Function:
        Sets the plugins of the environnement with their <configurators.Configuration> objects.
        
        Arguments:
        this - The object on which the method is called. Optionnal.
        pluginClasses - A cell array of strings.
        pluginConfigurations - A cell array of <configurators.Configuration>.
        
        Throws:
        ARGUMENT_EXCEPTION - if pluginClasses and pluginConfigurations
        don't have the same length.
        %}
        function setpluginClassesAndConfigurations(this, pluginClasses, pluginConfigurations)
            import fr.lescot.bind.exceptions.ExceptionIds;
            if length(pluginClasses) ~= length(pluginConfigurations)
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'The size of pluginClasses and pluginConfigurations must be the same.'));
            end
            this.pluginClasses = pluginClasses;
            this.pluginConfigurations = pluginConfigurations;
        end
        
        %{
        Function:
        Returns the plugins of the environnement with their <configurators.Configuration> objects.
        
        Arguments:
        this - The object on which the method is called. Optionnal.

        Returns:
        pluginClasses - A cell array of strings.
        pluginConfigurations - A cell array of <configurators.Configuration>.
        %}
        function [pluginClasses pluginConfigurations] = getpluginClassesAndConfigurations(this)
            pluginClasses = this.pluginClasses;
            pluginConfigurations = this.pluginConfigurations;
        end
        
        %{
        Function:
        Set the list of <kernel.Trip> objects.
        
        Arguments:
        this - The object on which the method is called. Optionnal.
        trips - A cell array of <kernel.Trip> objects.
        %}
        function setTrips(this, trips)
            this.trips = trips;
        end
        
        %{
        Function:
        Set the list of <kernel.Trip> objects.
        
        Arguments:
        this - The object on which the method is called. Optionnal.
        
        Returns:
        out - A cell array of <kernel.Trip> objects.
        %}
        function out = getTrips(this)
            out = this.trips;
        end
        
        %{
        Function:
        Saves the environnement to the specified .env file.
        
        Arguments:
        this - The object on which the method is called. Optionnal.
        filePath - The path to the destination file.
        
        Throws:
        ARGUMENT_EXCEPTION - If filePath do not end with .end
        %}
        function saveToFile(this, filePath)
            import fr.lescot.bind.exceptions.ExceptionIds;
            if ~regexp(filePath, '\.env$')
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'The file name must end with ".env"'));
            end
            tripsNumber = this.trips;
            tripOpeningCommands = cell(1, length(tripsNumber));
            for i = 1:1:length(tripsNumber)
                tripOpeningCommands{1, i} = fr.lescot.bind.loading.Environnement.tripInstanceToCommand(this.trips{i});
            end
            pluginClasses = this.pluginClasses; %#ok<PROP,NASGU>
            pluginConfigurations = this.pluginConfigurations; %#ok<PROP,NASGU>
            save(filePath, 'tripOpeningCommands', 'pluginClasses', 'pluginConfigurations');
        end
    end
    
    methods(Static)
        
        %{
        Function:
        Returns a new Environnement instance built from a .env file, but only with informations on 
        plugins and configurations. The program does not try to instanciate the trips.
        Useful if the objectif is only to swith plugins
        
        Arguments:
        filePath - The path to the destination file.
        
        Throws:
        ARGUMENT_EXCEPTION - If filePath do not end with .end
        %}
        function out = loadPluginsAndConfigsFromFile(filePath)
            import fr.lescot.bind.exceptions.ExceptionIds;
            if ~regexp(filePath, '\.env$')
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'The file name must end with ".env"'));
            end
            out = fr.lescot.bind.loading.Environnement();
            loaded = load(filePath, '-mat');
            out.pluginClasses = loaded.pluginClasses;
            out.pluginConfigurations = loaded.pluginConfigurations;
            out.trips = {};
        end
        
        
        %{
        Function:
        Returns a new Environnement instance built from a .env file. The program instanciate the trips.
        
        Arguments:
        filePath - The path to the destination file.
        
        Throws:
        ARGUMENT_EXCEPTION - If filePath do not end with .end
        %}
        function out = loadFromFile(filePath)
            import fr.lescot.bind.exceptions.ExceptionIds;
            if ~regexp(filePath, '\.env$')
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'The file name must end with ".env"'));
            end
            out = fr.lescot.bind.loading.Environnement();
            loaded = load(filePath, '-mat');
            out.pluginClasses = loaded.pluginClasses;
            out.pluginConfigurations = loaded.pluginConfigurations;
            trips = cell(1, length(loaded.tripOpeningCommands)); %#ok<PROP>
            for i = 1:1:length(loaded.tripOpeningCommands)
                trips{i} = eval(loaded.tripOpeningCommands{i}); %#ok<PROP>
            end
            out.trips = trips; %#ok<PROP>
        end
    end
    
    methods(Access=private, Static)
        %{
        Function:
        Generate a line of code from an instance of a Trip. This line of code can be used via
        eval to generate a new instance based on the same file.
        
        Arguments:
        tripInstance - A <kernel.Trip> object.
        
        Throws:
        UNCLASSIFIED_EXCEPTION - If the class of the Trip object is not recognized as on
        that can be transformed to a command.
        %}
        function out = tripInstanceToCommand(tripInstance)
            import fr.lescot.bind.exceptions.ExceptionIds;
            tripClass = class(tripInstance);
            switch tripClass
                case 'fr.lescot.bind.kernel.implementation.SQLiteTrip'
                    dataBasePath = tripInstance.getTripPath();
                    period = tripInstance.getTimer().getPeriod();
                    out = ['fr.lescot.bind.kernel.implementation.SQLiteTrip('''	dataBasePath ''',' sprintf('%.12f', period) ', false)'];
                otherwise
                    throw(MException(ExceptionIds.UNCLASSIFIED_EXCEPTION.getId(), 'The trip can''t be transformed into an instanciation command, since it is not of a supported Trip subclass.'));
            end
            
        end
    end
    
end

