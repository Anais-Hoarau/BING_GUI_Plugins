classdef ExceptionIds
    
    properties
        stringValue;
    end
    
    methods
        function this = ExceptionIds(stringValue)
           this.stringValue = stringValue; 
        end
        
        function out = getId(this)
           out = this.stringValue; 
        end
    end
    
    enumeration
        ARGUMENT_EXCEPTION('BIND:ArgumentException');
        CONTENT_EXCEPTION('BIND:ContentException');
        DATA_EXCEPTION('BIND:DataException');
        EVENT_EXCEPTION('BIND:EventException');
        FILE_EXCEPTION('BIND:FileException');
        META_INFOS_EXCEPTION('BIND:MetaInfosException');
        NETWORK_EXCEPTION('BIND:NetworkException');
        OBSERVER_EXCEPTION('BIND:ObserverException');
        PLUGIN_EXCEPTION('BIND:PluginException');
        SITUATION_EXCEPTION('BIND:SituationException');
        UNCLASSIFIED_EXCEPTION('BIND:UnclassifiedException');
        SQL_EXCEPTION('BIND:SQLException');
    end
end

