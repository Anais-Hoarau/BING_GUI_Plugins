%{
Class:
This class is to be used in state coding windows. It is composed of one push button.
By default the button is inactive.
%}
classdef stateCodingButtons < fr.lescot.bind.coding.codingButtons
    properties
    end
    
    methods
        function this = stateCodingButtons(InterfaceHandle, name)
            this@fr.lescot.bind.coding.codingButtons()

            this.button_handle = uicontrol('Parent', InterfaceHandle, ...
                'Style', 'pushbutton', ...
                'Units','pixel',...
                'String', name, ...
                'Enable', 'inactive', ...
                'ButtonDownFcn', '');
            
            this.position = get(this.getButtonHandle,'position');
            this.color = get(this.getButtonHandle,'BackgroundColor');
            this.name = get(this.getButtonHandle,'String');
            this.font = get(this.getButtonHandle,'FontName');
            this.fontSize = get(this.getButtonHandle,'FontSize');
            this.fontWeight = get(this.getButtonHandle,'FontWeight');
            
        end
        
        %% Getters and Setters
        % Returns the handle of the push button
        function out = getButtonHandle(this)
            out = this.button_handle;
        end
        
        %Position
        function out = getPosition(this)
            out = this.position;
        end
        
        function setPosition(this, pos)
            this.position = pos;
            set(this.getButtonHandle,'position', this.position)
        end
        
        % Name
        function out = getName(this)
            out =  this.name;
        end
        
        function setName(this, name)
            this.name = name;
            set(this.getButtonHandle,'String', this.name)
        end
        
        % BackGround Color
        function out = getColor(this)
            out = this.color;
        end
        
        function setColor(this, color)
            this.color = color;
            set(this.getButtonHandle,'BackgroundColor', this.color)
        end
        
        %Font Name
        function out = getFont(this)
            out = this.font;
        end
        
        function setFont(this,font)
            this.font = font;
            set(this.getButtonHandle,'FontName', this.font)
        end
        
        % FontWeight
        function out = getFontWeight(this)
            out = this.fontWeight;
        end
        
        function setFontWeight(this,fontWeight)
            this.fontWeight = fontWeight;
            set(this.getButtonHandle,'fontWeight', this.fontWeight)
        end
        
        % FontSize
        function out = getFontSize(this)
            out = this.fontSize;
        end
        
        function setFontSize(this,fontSize)
            this.fontSize = fontSize;
            set(this.getButtonHandle,'FontSize', this.fontSize)
        end
        
        % ButtonDownFcn
        function setButtonDownFcn(this, funct_handle)
            this.ButtonDownFcn = funct_handle;
            if ~isempty(this.ButtonDownFcn)
                set(this.getButtonHandle,'ButtonDownFcn',this.ButtonDownFcn);
            else
                set(this.getButtonHandle,'ButtonDownFcn','')
            end
        end
        
        function out = getButtonDownFcn(this)
            out = this.ButtonDownFcn;
        end
        
        %Callback
        function setButtonCallback(this,funct_handle)
            this.ButtonCallback=funct_handle;
            set(this.getButtonHandle,'Callback',funct_handle);
        end
        
        % Active
        function setActive(this)
            set(this.button_handle, 'Enable', 'on')
        end
        
        function setInactive(this)
            set(this.button_handle, 'Enable', 'off')
        end
    end
    
end