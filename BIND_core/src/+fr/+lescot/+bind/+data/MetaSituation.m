%{
Class:

<MetaBase> extension with the specific properties of the situations (none at
the moment).

%}
classdef MetaSituation < fr.lescot.bind.data.MetaBase

    methods
        
        %{
        Function:
        Instanciates a new MetaSituation object, and set the frameworkVariables
        to the correct values.
        
        Returns:
        A MetaBase instance
        %}
        function out = MetaSituation()
            out@fr.lescot.bind.data.MetaBase;
            timeCodeStart = fr.lescot.bind.data.MetaEventVariable();
            timeCodeStart.setName('startTimecode');
            timeCodeStart.setType(fr.lescot.bind.data.MetaDataVariable.TYPE_REAL);
            timeCodeEnd = fr.lescot.bind.data.MetaEventVariable();
            timeCodeEnd.setName('endTimecode');
            timeCodeEnd.setType(fr.lescot.bind.data.MetaDataVariable.TYPE_REAL);
            out.setFrameworkVariables({timeCodeStart timeCodeEnd});
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
            out = [baseClassHash '|' 'SITUATION'];
        end
        
    end
    
end

