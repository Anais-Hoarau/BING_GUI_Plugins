%{
Class:
This class is to be used in state coding windows. It is composed of one push button.
By default the button is inactive.
%}
classdef stateCodingPanel < fr.lescot.bind.coding.codingPanel
    properties
    end
    
    methods
        function this = stateCodingPanel(InterfaceHandle, PanelName)
            this@fr.lescot.bind.coding.codingPanel()

            this.panel_handle = uipanel('Parent', InterfaceHandle, ...
                'Units','pixel',...
                'Title', PanelName, ...
                'FontSize',10, ...
                'ForegroundColor', 'red');
            
            this.position = get(this.getPanelHandle,'position');
            this.color = get(this.getPanelHandle,'BackgroundColor');
            this.font = get(this.getPanelHandle,'FontName');
            this.fontSize = get(this.getPanelHandle,'FontSize');
            this.fontWeight = get(this.getPanelHandle,'FontWeight');
        end
        
        %% Getters and Setters
        
        % Returns the handle of the panel
        function out = getPanelHandle(this)
            out = this.panel_handle;
        end
        
        %Position
        function out = getPosition(this)
            out = this.position;
        end
        
        function setPosition(this, pos)
            this.position = pos;
            set(this.getPanelHandle,'position', this.position)
        end
        
        % Name
        function out = getName(this)
            out =  this.name;
        end
        
        function setName(this, name)
            this.name = name;
            set(this.getPanelHandle,'String', this.name)
        end
        
        % BackGround Color
        function out = getColor(this)
            out = this.color;
        end
        
        function setColor(this, color)
            this.color = color;
            set(this.getPanelHandle,'BackgroundColor', this.color)
        end
        
        %Font Name
        function out = getFont(this)
            out = this.font;
        end
        
        function setFont(this,font)
            this.font = font;
            set(this.getPanelHandle,'FontName', this.font)
        end
        
        % FontWeight
        function out = getFontWeight(this)
            out = this.fontWeight;
        end
        
        function setFontWeight(this,fontWeight)
            this.fontWeight = fontWeight;
            set(this.getPanelHandle,'fontWeight', this.fontWeight)
        end
        
        % FontSize
        function out = getFontSize(this)
            out = this.fontSize;
        end
        
        function setFontSize(this,fontSize)
            this.fontSize = fontSize;
            set(this.getButtonHandle,'FontSize', this.fontSize)
        end
        
    end
end