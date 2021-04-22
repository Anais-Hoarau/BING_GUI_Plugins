%{
Class:

<MetaBase> extension with the specific properties of the events (none at
the moment).

%}
classdef MetaEvent < fr.lescot.bind.data.MetaBase
    
    methods
        
        %{
        Function:
        Instanciates a new MetaEvent object, and set the frameworkVariables
        to the correct values.
        
        Returns:
        A MetaBase instance
        %}
        function out = MetaEvent()
            out@fr.lescot.bind.data.MetaBase;
            timecode = fr.lescot.bind.data.MetaEventVariable();
            timecode.setName('timecode');
            timecode.setType(fr.lescot.bind.data.MetaDataVariable.TYPE_REAL);
            out.setFrameworkVariables({timecode});
        end
        
        %{
        Function:
        Returns a hash of the object, which is an identifier string which
        is equal between two objects only if the two objects are equal
        (equality being here an esuality of value, not of reference).
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        A string   
        %}     
        function out = hash(this)
            baseClassHash = hash@fr.lescot.bind.data.MetaBase(this);
            out = [baseClassHash '|' 'EVENT'];
        end
        
    end
    
end

