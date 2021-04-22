%{
Class:

This class is a dataholder for the metadata about a partipant to a trip
that are stored with the Trip.
%}
classdef MetaParticipant < handle
    
    %{
    Property:
    The structure that contains the key and the values associated to the
    participant.
    
    %}
    properties(Access = private)
        data;
    end
    
    methods
        
        %{
        Function:
        The contructor of a MetaParticipant.
        
        %}
        function this = MetaParticipant()
            this.data = struct;
        end
        
        %{
        Function:
        Set the value returned for a given key. If there is already a
        value for the key, it is overwritten.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        key - A string
        value - A string
        
        %}
        function setAttribute(this, key, value)
            this.data.(key) = value;
        end
        
        %{
        Function:
        Returns the value for the given key.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        key - a String
        
        Returns:
        A string
        
        
        Throws:
        META_INFOS_EXCEPTION - When the key have never
        been associated to a value, and thus does not exist.
        %}
        function out = getAttribute(this, key)
            import fr.lescot.bind.exceptions.ExceptionIds;
            if(any(strcmpi(key, fieldnames(this.data))))
                out = this.data.(key);
            else
                throw(MException(ExceptionIds.META_INFOS_EXCEPTION.getId(), 'The requested key is not present for this participant.'));
            end
        end
        
        %{
        Function:
        Remove the key / value pair for the given key.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        key - A string
        
        Throws:
        ./+fr/+lescot/+bind/+data/MetaParticipant.m:78: - When the key have never
        been associated to a value, and thus does not exist and can't be
        removed.
        %}
        function removeAttribute(this, key)
            import fr.lescot.bind.exceptions.ExceptionIds;
            if(any(strcmpi(key, fieldnames(this.data))))
                this.data = rmfield(this.data, key);
            else
                throw(MException(ExceptionIds.META_INFOS_EXCEPTION.getId(), 'The requested key is not present in the participant, so the removal couldn''t take place. The variable wasn''t modified.'));
            end
        end
        
        %{
        Function:
        Returns the list of the availaible keys.
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        A cell array of string
        
        %}
        function out = getAttributesList(this)
           out = fieldnames(this.data); 
        end
    end
    
end

