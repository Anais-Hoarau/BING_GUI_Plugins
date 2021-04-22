%{
Class:
This class is an extension of <MetaBase> that adds some properties
specific to the Data type of data.

%}
classdef MetaData < fr.lescot.bind.data.MetaBase
    
    properties(Access = private)
        
        %{
        Property:
        the type of the data.
        
        %}
        type;
        
        %{
        Property:
        the frequency of the data.
        
        %}
        frequency;
    end
    
    methods
        
        %{
        Function:
        Instanciates a new MetaData object, and set the frameworkVariables
        to the correct values.
        
        Returns:
        A MetaBase instance
        %}
        function out = MetaData()
            out@fr.lescot.bind.data.MetaBase;
            timecode = fr.lescot.bind.data.MetaDataVariable();
            timecode.setName('timecode');
            timecode.setType(fr.lescot.bind.data.MetaDataVariable.TYPE_REAL);
            out.setFrameworkVariables({timecode});
        end
        
        %{
        Function:
        Getter for the frequency of the datas.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        Returns:
        The frequency of the datas.
        %}
        function out = getFrequency(this)
            out = this.frequency;
        end
        
          
        %{
        Function:
        Setter for the frequency of the datas.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        frequency - A numeric value containing the new frequency to set.
        %}
        function setFrequency(this, frequency)
            this.frequency = frequency;
        end
        
        %{
        Function:
        Getter for the type of the data.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        Returns:
        The type of the data.
        %}
        function out = getType(this)
            out = this.type;
        end
        
        %{
        Function:
        Setter for the type of the data.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        setType - the new type to set.
        %}
        function setType(this, type)
            this.type = type;
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
            out = [baseClassHash '|' num2str(this.frequency) '|' this.type '|' 'DATA'];
        end
        
    end
    
end

