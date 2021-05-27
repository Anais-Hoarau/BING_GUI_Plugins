 %{
Class:
This class is to be used in state coding windows. It is composed of one push button.
By default the button is inactive.
%}
classdef stateCodingEdit< fr.lescot.bind.coding.codingEdit
    properties
    end
    
    methods
        function this = stateCodingEdit(InterfaceHandle, editName)
            this@fr.lescot.bind.coding.codingEdit()

            this.edit_handle = uicontrol('Parent', InterfaceHandle, ...
                'Style', 'edit', ...
                'Units','pixel',...
                'TooltipString', editName, ...             
                'String', '',...
                'Max',10.,...
                'Enable', 'inactive', ...
                'Callback', '');
            
            this.position = get(this.getEditHandle,'position');
            this.color = get(this.getEditHandle,'BackgroundColor');
            this.name = get(this.getEditHandle,'String');
            this.font = get(this.getEditHandle,'FontName');
            this.fontSize = get(this.getEditHandle,'FontSize');
            this.fontWeight = get(this.getEditHandle,'FontWeight');
            
        end
        
        %% Getters and Setters
        % Returns the handle of the menu
        function out = getEditHandle(this)
            out = this.edit_handle;
        end
        
        %Position
        function out = getPosition(this)
            out = this.position;
        end
        
        function setPosition(this, pos)
            this.position = pos;
            set(this.getEditHandle,'position', this.position)
        end
        
        % Name
        function out = getName(this)
            out =  this.name;
        end
        
        function setName(this, name)
            this.name = name;
            set(this.getEditHandle,'String', this.name)
        end
        
        % BackGround Color
        function out = getColor(this)
            out = this.color;
        end
        
        function setColor(this, color)
            this.color = color;
            set(this.getEditHandle,'BackgroundColor', this.color)
        end
        
        %Font Name
        function out = getFont(this)
            out = this.font;
        end
        
        function setFont(this,font)
            this.font = font;
            set(this.getEditHandle,'FontName', this.font)
        end
        
        % FontWeight
        function out = getFontWeight(this)
            out = this.fontWeight;
        end
        
        function setFontWeight(this,fontWeight)
            this.fontWeight = fontWeight;
            set(this.getEditHandle,'fontWeight', this.fontWeight)
        end
        
        % FontSize
        function out = getFontSize(this)
            out = this.fontSize;
        end
        
        function setFontSize(this,fontSize)
            this.fontSize = fontSize;
            set(this.getEditHandle,'FontSize', this.fontSize)
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
        function setEditCallback(this,funct_handle)
            this.EditCallback=funct_handle;
            set(this.getEditHandle,'Callback',funct_handle);
        end
        
        % Active
        function setActive(this)
            set(this.edit_handle, 'Enable', 'on')
        end
        
        function setInactive(this)
            set(this.edit_handle, 'Enable', 'off')
        end
    end
    
end