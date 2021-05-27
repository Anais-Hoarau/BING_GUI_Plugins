%{
Class:
This class is to be used in state coding windows. It is composed of one push button.
By default the button is inactive.
%}
classdef situationCodingButtons < fr.lescot.bind.coding.codingButtons 
    properties
        %{
        Property:
        handle or cell array of handles of the coding buttons
        %}
        position2;
        
        isDebutPressed=false;
        
        debutPressedTime=[];
    end
    
    methods
        function this = situationCodingButtons(InterfaceHandle, name)
            this@fr.lescot.bind.coding.codingButtons()
            
            this.button_handle.text = uicontrol('Parent', InterfaceHandle, ...
                'Style', 'Text', ...
                'Backgroundcolor', get(InterfaceHandle, 'Color'),...
                'String', name, ...
                'HorizontalAlignment','center',...
                'Enable', 'inactive', ...
                'ButtonDownFcn', '');
            
            
            this.button_handle.debut = uicontrol('Parent', InterfaceHandle, ...
                'Style', 'pushbutton', ...
                'Units','pixel',...
                'String', 'Début', ...
                'Enable', 'inactive', ...
                'ButtonDownFcn', '');
            
            
            this.button_handle.fin = uicontrol('Parent', InterfaceHandle, ...
                'Style', 'pushbutton', ...
                'Units','pixel',...
                'String', 'Fin', ...
                'Enable', 'inactive', ...
                'ButtonDownFcn', '');
            
            this.position = get(this.getButtonHandle.debut,'position');
            this.position2 = get(this.getButtonHandle.fin,'position');
            this.color = get(this.getButtonHandle.debut,'BackgroundColor');
            this.name = get(this.getButtonHandle.text,'String');
            this.font = get(this.getButtonHandle.text,'FontName');
            this.fontSize = get(this.getButtonHandle.text,'FontSize');
            this.fontWeight = get(this.getButtonHandle.text,'FontWeight');
            
        end
        
        function out = getButtonHandle(this)
            out = this.button_handle;
        end
        
        %Position
        function out = getPosition(this)
            out = this.position;
        end
        
        function out = getPosition2(this)
            out = this.position2;
        end
        
        function setPosition(this, pos)
            %Pos Button Debut
            this.position = pos;
            set(this.getButtonHandle.debut,'position', this.position)
            %Pos Button Fin
            pos2 = this.position + [pos(3)+5 0 0 0];
            set(this.getButtonHandle.fin,'position',pos2)
            this.position2 = pos2;
            % Pos Button text
            pos3 = [pos(1) pos(2)+pos(4)+2 2*pos(3)+5 10];
            set(this.getButtonHandle.text,'position',pos3)
            set(this.getButtonHandle.text,'Units','points')
            pos4 = get(this.getButtonHandle.text,'position');
            set(this.getButtonHandle.text,'position', [pos4(1) pos4(2) pos4(3) this.getFontSize])
            set(this.getButtonHandle.text,'Units','Pixel')
        end
        
        % Name
        function out = getName(this)
            out =  this.name;
        end
        
        function setName(this, name)
            this.name = name;
            set(this.getButtonHandle.text,'String', this.name)
        end
        
        % BackGround Color
        function out = getColor(this)
            out = this.color;
        end
        
        function setColor(this, color)
            this.color = color;
            set(this.getButtonHandle.debut,'BackgroundColor', this.color)
            set(this.getButtonHandle.fin,'BackgroundColor', this.color)
        end
        
        function setColorDebut(this, color)
            set(this.getButtonHandle.debut,'BackgroundColor', color)
        end
        
        %Font Name
        function out = getFont(this)
            out = this.font;
        end
        
        function setFont(this,font)
            this.font = font;
            set(this.getButtonHandle.text,'FontName', this.font)
            set(this.getButtonHandle.debut,'FontName', this.font)
            set(this.getButtonHandle.fin,'FontName', this.font)
        end
        
        % FontWeight
        function out = getFontWeight(this)
            out = this.fontWeight;
        end
        
        function setFontWeight(this,fontWeight)
            this.fontWeight = fontWeight;
            set(this.getButtonHandle.text,'fontWeight', this.fontWeight)
            set(this.getButtonHandle.debut,'fontWeight', this.fontWeight)
            set(this.getButtonHandle.fin,'fontWeight', this.fontWeight)
        end
        
        % FontSize
        function out = getFontSize(this)
            out = this.fontSize; 
        end
        
        function setFontSize(this,fontSize)
            this.fontSize = fontSize;
            set(this.getButtonHandle.text,'FontSize', this.fontSize)
            set(this.getButtonHandle.debut,'FontSize', this.fontSize)
            set(this.getButtonHandle.fin,'FontSize', this.fontSize)
            
            this.setPosition(this.getPosition)
        end
        
        % ButtonDownFcn
        function setButtonDownFcn(this, funct_handle)
            this.ButtonDownFcn = funct_handle;
            if ~isempty(this.ButtonDownFcn)
                set(this.getButtonHandle.text,'ButtonDownFcn','')
                set(this.getButtonHandle.debut,'ButtonDownFcn',this.ButtonDownFcn)
                set(this.getButtonHandle.fin,'ButtonDownFcn',this.ButtonDownFcn)
            else
                set(this.getButtonHandle.text,'ButtonDownFcn','')
                set(this.getButtonHandle.debut,'ButtonDownFcn','')
                set(this.getButtonHandle.fin,'ButtonDownFcn','')
            end
        end
        
        function out = getButtonDownFcn(this)
            out = this.ButtonDownFcn;
            
        end
        
        %Callback
        function setButtonCallback(this,funct_handle)
            this.ButtonCallback = funct_handle;
            set(this.getButtonHandle.debut,'Callback',this.ButtonCallback)
            set(this.getButtonHandle.fin,'Callback',this.ButtonCallback)
        end
        
        function out = isPressed(this)
            out = this.isDebutPressed;
        end
        
        function setDebutPressed(this, bool)
            this.isDebutPressed = bool;
        end
        
        function out = getPressedTimecode(this)
            out = this.debutPressedTime;
        end
        
        function setPressedTimecode(this,timecode)
            this.debutPressedTime = timecode;
        end
        
        % Active
        function setActive(this)
            set(this.button_handle.debut, 'Enable', 'on')
            set(this.button_handle.fin, 'Enable', 'on')
        end
        
        function setInactive(this)
            set(this.button_handle.debut, 'Enable', 'off')
            set(this.button_handle.fin, 'Enable', 'off')
        end
        
    end
    
end