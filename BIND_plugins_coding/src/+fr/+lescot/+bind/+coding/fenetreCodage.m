classdef fenetreCodage < handle
    properties
        handleGraphic;
        
        position;
        
        width;
        
        height;
        
        name;
        
        color;
        
        editMode;
    end
    
    methods
        % Variable :  fr.lescot.bind.coding.Variable
        function this = fenetreCodage()
            this.buildWindow
        end
        
        function buildWindow(this)
            this.handleGraphic.interfaceFigure = figure('NumberTitle','off',...
                'MenuBar','none',...
                'Resize','off',...
                'HandleVisibility','on',... > change to callback after developping
                'DockControls','off',...
                'Visible','on');

            % Menu > Edition
            changeModeCallback = @(x,y) this.changeMode;
            this.handleGraphic.menuEdition = uimenu('Parent',this.handleGraphic.interfaceFigure,...
                'Label','Basculer en mode ''Edition'' ',...
                'Tag','menu_modeEdition', ...
                'Visible','on',...
                'Callback',changeModeCallback);
            this.editMode = false;
        end
        
        function activateEditMode(this)
            this.editMode = true;
            this.enableEditOptions;

        end
        
        function desactivateEditMode(this)
            this.editMode = false;
            this.disableEditOptions
        end
        
        function out = isEditMode(this)
            out = this.editMode;
        end
        
        function changeMode(this)
            if this.isEditMode
                this.desactivateEditMode
                set(this.handleGraphic.menuEdition,'Label', 'Basculer en mode ''Edition'' ')
            else
                this.activateEditMode
                set(this.handleGraphic.menuEdition,'Label', 'Retourner en mode ''Affichage'' ')
            end
        end
        
        % Figure Handler
        function out = getFigureHandler(this)
            out = this.handleGraphic.interfaceFigure;
        end
        
        % Position
        function setPosition(this,pos)
            this.position = pos;
            this.width = pos(3);
            this.height = pos(4);
            set(this.getFigureHandler, 'Units', 'Pixel')
            set(this.getFigureHandler, 'Position', this.position)
        end
       
        function out = getPosition(this,varargin)
            if nargin == 1
                set(this.getFigureHandler, 'Units', 'pixel')
                out = get(this.getFigureHandler, 'Position');
            elseif nargin == 2
                unit = varargin{1};
                currentUnit = get(this.getFigureHandler, 'Units');
                set(this.getFigureHandler, 'Units', unit)
                out = get(this.getFigureHandler, 'Position');
                set(this.getFigureHandler, 'Units', currentUnit);
            end
        end
        
        function out = getWidth(this)
            out = this.width;
        end
        
        function out = getHeight(this)
            out = this.height;
        end
        
        %Color
        function setColor(this, color)
            this.color = color;
            set(this.getFigureHandler,'Color',this.color)
        end
        
        function out = getColor(this)
            out = this.color;
        end
        
        % Name
        function setName(this, name)
            this.name = name;
            set(this.getFigureHandler, 'Name', this.name);
        end
        
        function out= getName(this)
            out = this.name;
        end
    end
    
    methods (Abstract)
        enableEditOptions(this)    

        disableEditOptions(this)    
    end
end