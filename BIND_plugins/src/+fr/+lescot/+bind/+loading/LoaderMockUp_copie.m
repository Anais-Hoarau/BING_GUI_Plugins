%{
Class:
This class is a minimalistic <configurators.ConfiguratorUser>
implementation, that allows some testing without having to use a full
loader. It diplays the content of the configuration it received.
%}
classdef LoaderMockUp_copie < fr.lescot.bind.configurators.ConfiguratorUser
    %{
    properties 
        listArgConfig; % matrice contenant les argumenents 
    end
    
    methods
        
        function loaderMockUp_listArgConfig= LoaderMockUp_copie(this,pluginId)
            loaderMockUp_listArgConfig=this.getListArgConfig(pluginId);
        end
        
        function out= getListArgConfig(pluginId)
            out=this.listArgConfig(pluginId, :,:);
        end
        
        function out= setListArgConfig(this,pluginId,valueArgOrder,value )
            listArgConfig(pluginId,valueArgOrder,4)=configuration.findArgumentWithOrder(valueArgOrder).setValue(value);
            out=this.listArgConfig;
        end
        
        function out= getValueArgOrder(pluginId,listArgConfig,valueArgOrder )
            out=listArgConfig(pluginId,valueArgOrder,4);
        end
         %}   
        %{
        Function:
        see <plugins.configurators.ConfiguratorUser>.
        
        function listArgConfig=receiveConfiguration(this, pluginId, configuration)
            import fr.lescot.bind.utils.StringUtils;
            for i = 1:1:configuration.getArgumentsMaxOrder()
                argument = configuration.findArgumentWithOrder(i);
                if ~isempty(argument)
                    disp(['Name : ' argument.getName()]);
                    listArgConfig(pluginId,i,1)=configuration.findArgumentWithOrder(i).getName()
                    listArgConfig(pluginId,i,2)=configuration.findArgumentWithOrder(i).getOrder()
                    listArgConfig(pluginId,i,3)=configuration.findArgumentWithOrder(i).isOptionnal()
                    listArgConfig(pluginId,i,4)=configuration.findArgumentWithOrder(i).getValue()
                    disp(['Order : ' sprintf('%d', argument.getOrder())]);
                    disp(['Optionnal : ' sprintf('%d', argument.isOptionnal())]);
                    disp('Values : ');
                    disp(argument.getValue());
                end
            end
            return
        end
        %}
        methods
            
        function receiveConfiguration(this, pluginId, configuration)%original
            import fr.lescot.bind.utils.StringUtils;
            for i = 1:1:configuration.getArgumentsMaxOrder()
                argument = configuration.findArgumentWithOrder(i);
                if ~isempty(argument)
                    disp(['Name : ' argument.getName()]);
                    disp(['Order : ' sprintf('%d', argument.getOrder())]);
                    disp(['Optionnal : ' sprintf('%d', argument.isOptionnal())]);
                    disp('Values : ');
                    disp(argument.getValue());
                end
            end
        end
        
        function launchPluginsWithTrip(this,tripSelection)
            launchPluginsWithTrip@fr.lescot.bind.loading.Loader();
        end
    end
    
end

