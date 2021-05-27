%{
Class:
Abstract class for coding buttons that are used in the diffrent coding windows.
%}
classdef codingPanel < handle
    properties
        %{
        Property:
        handle or cell array of handles of the coding panel
        %}
        panel_handle;
        
        %{
        Property:
        Buttons Positons
        %}
        position;
        
        %{
        Property:
        Buttons colors
        %}
        color;
        
        %{
        Property:
        Buttons names
        %}
        name;
        
        %{
        Property:
        Buttons text font
        %}
        font;
        
        %{
        Property:
        Buttons text font size
        %}
        fontSize;
        
        %{
        Property:
        Buttons text font weight
        %}
        fontWeight;
        
    end
    
    methods 
        function this = codingPanel()
        end
    end
    
    methods (Abstract)
        %% Getter and Setter
        
        %Handle
        getPanelHandle(this)
        
        %Position
        getPosition(this)
        setPosition(this, pos)
        
        % Name
        getName(this)
        setName(this, name)
        
        % BackGround Color
        getColor(this)
        setColor(this, color)
        
        %Font Name
        getFont(this)
        setFont(this,font)

        % FontWeight
        getFontWeight(this)
        setFontWeight(this,fontWeight)
        
        % FontSize
        getFontSize(this)
        setFontSize(this,fontSize)
        
    end
end