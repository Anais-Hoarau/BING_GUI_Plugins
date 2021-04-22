%{
Class:
This class contains some static methods used to manipulate plugins
%}
classdef PluginUtils

     
    methods(Static = true)
        
        %{
        Function:
        Returns a list of string containing all the names of the plugins 
        that can be instanciated.
        
        Throws:
        UNCLASSIFIED_EXCEPTION - If one of the classes of the
        plugins Packages does not have the isInstanciable method.
        
        Returns:
        pluginList : cell list with the name of the plugins
        
        %}
        function out = getAllAvailablePlugins(package)
            import fr.lescot.bind.exceptions.ExceptionIds;
            pluginList = {};
            indice = 1;
            [~, classNames] = fr.lescot.bind.utils.ClassPathUtils.getAllMFilesInPackage(package);
            classNames = strrep(classNames, '+','');
            plugins = fr.lescot.bind.utils.ClassPathUtils.classesExtendingClass(classNames,'fr.lescot.bind.plugins.Plugin');
             for i = 1:1:length(plugins)
               try
                   %isInstanciable test
                   expression = [char(plugins(i)) '.isInstanciable()'];
                   if(eval(expression))
                       pluginList(indice) = plugins(i);
                       indice = indice + 1;
                   end

               catch ME
                  throw(MException(ExceptionIds.UNCLASSIFIED_EXCEPTION.getId(), 'This class does not have the proper isInstanciable() method.'));
               end
             end
            
             out = pluginList;
        end
    end
end

