classdef fenetrePluginCodage < handle
    properties
        handleGraphic;
        
        position;
        
        width;
        
        height;
        
        name;
        
        color;
    end
    
    methods
        % Variable :  fr.lescot.bind.coding.Variable
        function this = fenetrePluginCodage(figureHandler)
            this.handleGraphic.interfaceFigure = figureHandler;
            this.configWindow
        end
        
        function configWindow(this)
            set(this.getFigureHandler, ...
                'NumberTitle','off',...
                'MenuBar','none',...
                'Resize','off',...
                'HandleVisibility','callback',... > change to callback after developping (before : 'HandleVisibility','on',...)
                'DockControls','off',...
                'Visible','off');
            
           
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
end