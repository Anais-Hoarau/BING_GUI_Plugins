 %{
Class:
This class is to be used in state coding windows. It is composed of one push button.
By default the button is inactive.
%}
classdef stateCodingMenus < fr.lescot.bind.coding.codingMenus
    properties
    end
    
    methods
        function this = stateCodingMenus(InterfaceHandle, menuName, modalitiesNames)
            this@fr.lescot.bind.coding.codingMenus()
          
            this.menu_handle = uicontrol('Parent', InterfaceHandle, ...
                'Style', 'popupmenu', ...
                'Units','pixel',...
                'Max',10,...
                'TooltipString', menuName, ...
                'String', modalitiesNames, ...
                'Enable', 'inactive', ...
                'Callback', '');
            
            this.position = get(this.getMenuHandle,'position');
            this.color = get(this.getMenuHandle,'BackgroundColor');
            this.name = get(this.getMenuHandle,'String');
            this.font = get(this.getMenuHandle,'FontName');
            this.fontSize = get(this.getMenuHandle,'FontSize');
            this.fontWeight = get(this.getMenuHandle,'FontWeight');
            
        end
        
        %% Getters and Setters
        % Returns the handle of the menu
        function out = getMenuHandle(this)
            out = this.menu_handle;
        end
        
        %Position
        function out = getPosition(this)
            out = this.position;
        end
        
        function setPosition(this, pos)
            this.position = pos;
            set(this.getMenuHandle,'position', this.position)
        end
        
        % Name
        function out = getName(this)
            out =  this.name;
        end
        
        function setName(this, name)
            this.name = name;
            set(this.getMenuHandle,'String', this.name)
        end
        
        % BackGround Color
        function out = getColor(this)
            out = this.color;
        end
        
        function setColor(this, color)
            this.color = color;
            set(this.getMenuHandle,'BackgroundColor', this.color)
        end
        
        %Font Name
        function out = getFont(this)
            out = this.font;
        end
        
        function setFont(this,font)
            this.font = font;
            set(this.getMenuHandle,'FontName', this.font)
        end
        
        % FontWeight
        function out = getFontWeight(this)
            out = this.fontWeight;
        end
        
        function setFontWeight(this,fontWeight)
            this.fontWeight = fontWeight;
            set(this.getMenuHandle,'fontWeight', this.fontWeight)
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
%         function setButtonDownFcn(this, funct_handle)
%             this.ButtonDownFcn = funct_handle;
%             if ~isempty(this.ButtonDownFcn)
%                 set(this.getButtonHandle,'ButtonDownFcn',this.ButtonDownFcn);
%             else
%                 set(this.getButtonHandle,'ButtonDownFcn','')
%             end
%         end
%         
%         function out = getButtonDownFcn(this)
%             out = this.ButtonDownFcn;
%         end
        
        %Callback
        function setMenuCallback(this,funct_handle)
            this.MenuCallback=funct_handle;
            set(this.getMenuHandle,'Callback',funct_handle);
        end
        
        % Active
        function setActive(this)
            set(this.menu_handle, 'Enable', 'on')
        end
        
        function setInactive(this)
            set(this.menu_handle, 'Enable', 'off')
        end
    end
    
end