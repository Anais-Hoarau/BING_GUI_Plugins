%{
Class:

This class is a dataholder for the datas about a video file.
%}
classdef MetaVideoFile < handle

    properties(Access = private)
        %{
        Property:
        Contains the textual description of the video playback (front camera, back
        camera, splitter,...)
        
        %}
        description;
        
        %{
        Property:
        Contains the path to the video file.
        
        %}
        fileName;
        
        %{
        Property:
        Contains the time of the image with the "time 0" timestamp.
        
        %}
        offset;
    end
    
    methods
        
        %{
        Function:
        The contructor of a MetaVideoFile.
        
        Arguments:
        fileName - the path to the file
        offset - the time in seconds 
        description - the description of the file 
        
        %}
        function this = MetaVideoFile(fileName, offset, description)
            this.setDescription(description);
            this.setFileName(fileName);
            this.setOffset(offset);
        end
        
        %{
        Function:
        Setter for the description of the video playback
        
        Arguments:
        this - The object on which the function is called, optionnal.
        description - A string
        
        %}
        function setDescription(this, description)
           this.description = description; 
        end
        
        %{
        Function:
        Getter for the description of the video playback
        
        Arguments:
        this - The object on which the function is called, optionnal.
        description - A string
        
        %}
        function out = getDescription(this)
           out = this.description; 
        end
        
        %{
        Function:
        Setter for the path to the file
        
        Arguments:
        this - The object on which the function is called, optionnal.
        fileName - A string
        
        %}
        function setFileName(this, fileName)
           this.fileName = fileName; 
        end
        
        %{
        Function:
        Getter for the path to the file
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        A string
        
        %}
        function out = getFileName(this)
            out = this.fileName;
        end
        
        %{
        Function:
        Setter for the offset in seconds
        
        Arguments:
        this - The object on which the function is called, optionnal.
        offset - A number
        
        %}
        function setOffset(this, offset)
           this.offset = offset; 
        end
        
        %{
        Function:
        Getter for the offset of the image
        
        Arguments:
        this - The object on which the function is called, optionnal.
        
        Returns:
        A number
        
        %}
        function out = getOffset(this)
            out = this.offset;
        end
    end
    
end

