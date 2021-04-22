%{
Class:
This class is a minimalistic <configurators.ConfiguratorUser>
implementation, that allows some testing without having to use a full
loader. It diplays the content of the configuration it received.
%}
classdef LoaderMockUp < fr.lescot.bind.configurators.ConfiguratorUser

    methods
        
        %{
        Function:
        see <plugins.configurators.ConfiguratorUser>.
        %}
        function receiveConfiguration(this, pluginId, configuration)
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
    end
    
end

