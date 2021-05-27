classdef fenetreCodageEvent < fr.lescot.bind.coding.fenetreCodage
    properties
       eventButtons;
       
       codedEventList;
       
       currentVariable;
    end
    
    methods
        function this = fenetreCodageEvent(Variable)
            this@fr.lescot.bind.coding.fenetreCodage()
            
            this.currentVariable = Variable;
            
            if ~this.currentVariable.isInfosGraphicOk 
                this.initiliazeWindow;
            else
                infosGraphic = this.currentVariable.getInfosGraphic;
                this.rebuildWindow(infosGraphic);
            end
            % Save graphic properties
            this.saveGraphicObjetProperties;
        end
        
        function initiliazeWindow(this)
            %% Retrieving modalities
            Modalities = this.currentVariable.getAllModalities;
            N = length(Modalities);
            
            %% Figure (suite)
            this.setName(['Codage Evènement : ' this.currentVariable.getName])
            this.setPosition([0 0 285 max(100+20*N,160)])
            this.setColor([0.8 0.8 0.8])
            movegui(this.getFigureHandler(),'center')
            
            %% Create Button
            this.eventButtons = cell(1,N);
            for i_buttons = 1:1:N
                this.eventButtons{i_buttons} = fr.lescot.bind.coding.eventCodingButtons(this.getFigureHandler(), Modalities{i_buttons}.getName);
                this.eventButtons{i_buttons}.setPosition([10 this.height-40*i_buttons 60 20])
            end
            this.disableButtons
            
            %% Create Event List Panel
            this.codedEventList = fr.lescot.bind.coding.codedModalityList(this.getFigureHandler());
            this.codedEventList.setName('Evénements codés : ')
            this.codedEventList.setPosition([80 10 this.getWidth-85 this.getHeight-20])
            this.codedEventList.setColumnNames({'#','Timecode','Modalités'})
        end
        
        function rebuildWindow(this,infosGraphic)
            Modalities = this.currentVariable.getAllModalities;
            % Figure
            this.setPosition(infosGraphic.Figure.Position)
            this.setName(infosGraphic.Figure.Name)
            this.setColor(infosGraphic.Figure.Color)
            % Buttons
            N = length(infosGraphic.Buttons.Positions);
            this.eventButtons = cell(1,N);
            for i_buttons = 1:1:N
                this.eventButtons{i_buttons} = fr.lescot.bind.coding.eventCodingButtons(this.getFigureHandler(), Modalities{i_buttons}.getName);
                this.eventButtons{i_buttons}.setPosition(infosGraphic.Buttons.Positions{i_buttons})
                this.eventButtons{i_buttons}.setColor(infosGraphic.Buttons.Colors{i_buttons})
                this.eventButtons{i_buttons}.setFont(infosGraphic.Buttons.Fonts{i_buttons})
                this.eventButtons{i_buttons}.setFontSize(infosGraphic.Buttons.FontSizes{i_buttons})
                this.eventButtons{i_buttons}.setFontWeight(infosGraphic.Buttons.FontWeights{i_buttons})
            end
            this.disableButtons;
            
            % CodedModalityList
            this.codedEventList = fr.lescot.bind.coding.codedModalityList(this.getFigureHandler());
            this.codedEventList.setName(infosGraphic.CodedModalityList.Name)
            this.codedEventList.setPosition(infosGraphic.CodedModalityList.Position)
            this.codedEventList.setColumnNames({'#','Timecode','Modalités'})
        end
        
        function enableEditOptions(this)
            this.enableFigureResize;
            this.enableButtons;
            this.enableCodedModalityList;
        end

        function enableButtons(this)
            for i=1:1:length(this.eventButtons)
                this.eventButtons{i}.setButtonDownFcn(@this.editObjects)
            end
        end
        
        function enableFigureResize(this)
            set(this.getFigureHandler(),'Resize','on','Color', [0.8 1 0.8])
        end
        
        function enableCodedModalityList(this)
            for i=1:1:length(this.codedEventList.getHandles)
                set(this.codedEventList.getHandles{i}, 'ButtonDownFcn', @this.editObjects)
            end
        end
        
        function disableEditOptions(this)
            this.disableFigureResize;
            this.disableButtons;
            this.disableCodedModalityList;
            this.saveGraphicObjetProperties
        end
        
        function disableButtons(this)
            for i=1:1:length(this.eventButtons)
                this.eventButtons{i}.setButtonDownFcn('');
            end
        end
        
        function disableCodedModalityList(this)
            for i=1:1:length(this.codedEventList.getHandles)
                set(this.codedEventList.getHandles{i}, 'ButtonDownFcn', '')
            end
        end
        
        function disableFigureResize(this)
            set(this.getFigureHandler(),'Resize','off','Color', [0.8 0.8 0.8])
        end
        
        function editObjects(this, source, eventData)
            % Find the edited button
            currentObjet = {};
            for i=1:1:length(this.eventButtons)
                if this.eventButtons{i}.getButtonHandle == source
                    currentObjet = this.eventButtons{i};
                end
            end
            if any(cell2mat(this.codedEventList.getHandles) == source)
                currentObjet = this.codedEventList;
            end
            
            if ~isempty(currentObjet)
                obj_pos = currentObjet.getPosition;
                click_pos = get(this.getFigureHandler,'CurrentPoint');
                switch get(this.getFigureHandler,'SelectionType')
                    %% Move et Resize
                    case 'normal'
                        pixel_offset = 3;
                        % Click in the center of button > Move
                        if (obj_pos(1)+pixel_offset<click_pos(1)) && (click_pos(1)<obj_pos(1)+obj_pos(3)-pixel_offset) ...
                                && (obj_pos(2)+pixel_offset<click_pos(2)) && (click_pos(2)<obj_pos(2)+obj_pos(4)-pixel_offset)
                            this.startMovingObject(currentObjet)
                            % Click on the border > Resize
                        else
                            this.startResizingObject(currentObjet)
                        end
                        %% Choose color et Font
                    case 'alt'
                        if ~isa(currentObjet,'fr.lescot.bind.coding.codedModalityList')
                            Liststr = {'Police','Couleur'};
                            [selec, ok] = listdlg('ListString',Liststr,'SelectionMode','Single','PromptString', 'Modifier','ListSize',[120 30],'ffs',0,'fus',2);
                            if ok == 1
                                switch Liststr{selec}
                                    case 'Police'
                                        FontInfos = uisetfont(currentObjet.getButtonHandle, 'Modifier la police');
                                        currentObjet.setFont(FontInfos.FontName)
                                        currentObjet.setFontWeight(FontInfos.FontWeight)
                                        currentObjet.setFontSize(FontInfos.FontSize)
                                    case 'Couleur'
                                        chosenColor = uisetcolor('Modifier la couleur');
                                        if length(chosenColor)>1
                                            currentObjet.setColor(chosenColor);
                                        end
                                end
                            end
                        end
                end
            end
            
        end    
        
       %% Saving Objects Properies
        function saveGraphicObjetProperties(this)
            
            % Figure properties
            infosGraphic.Figure.Name = this.getName;
            infosGraphic.Figure.Position = this.getPosition;
            infosGraphic.Figure.Color = this.getColor;
            
            N = length(this.eventButtons);
            buttons_positions = cell(1,N);
            buttons_colors = cell(1,N);
            buttons_fonts = cell(1,N);
            buttons_fontsizes = cell(1,N);
            buttons_fontweights = cell(1,N);
            % Buttons properties
            for i=1:1:N
                buttons_positions{i} = this.eventButtons{i}.getPosition;
                buttons_colors{i} = this.eventButtons{i}.getColor;
                buttons_fonts{i} = this.eventButtons{i}.getFont;
                buttons_fontsizes{i} = this.eventButtons{i}.getFontSize;
                buttons_fontweights{i} = this.eventButtons{i}.getFontWeight;
            end
            
            infosGraphic.Buttons.Positions = buttons_positions;
            infosGraphic.Buttons.Colors = buttons_colors;
            infosGraphic.Buttons.Fonts = buttons_fonts;
            infosGraphic.Buttons.FontSizes = buttons_fontsizes;
            infosGraphic.Buttons.FontWeights = buttons_fontweights;
            % Modality list properties
            
            infosGraphic.CodedModalityList.Name = this.codedEventList.getName;
            infosGraphic.CodedModalityList.Position = this.codedEventList.getPosition;
            
            this.currentVariable.setInfosGraphic(infosGraphic)
        end
          
        %% Moving and Resizing Objects
        function startMovingObject(this, object)
            set(this.getFigureHandler,'Pointer','fleur')
            
            current_pos = get(this.getFigureHandler,'CurrentPoint');
            obj_pos = object.getPosition;
            offset = current_pos-obj_pos(1:2);
            
            moveObjectCallback = @(x,y) this.moveObject(object, offset);
            set(this.getFigureHandler,'WindowButtonMotionFcn', moveObjectCallback)
            
            
            stopMovingObjectCallback = @(x,y) this.stopMovingObject(object);
            set(this.getFigureHandler,'WindowButtonUpFcn', stopMovingObjectCallback)
            
        end
        
        function moveObject(this, object, offset)
            fig_pos = this.getPosition;
            current_pos = get(this.getFigureHandler,'CurrentPoint');
            obj_pos = object.getPosition;
            new_obj_pos = [current_pos-offset obj_pos(3:4)];

            if all(fig_pos(3:4)-(new_obj_pos(1:2)+new_obj_pos(3:4))>5) && all(new_obj_pos(1:2) >5)
                object.setPosition(new_obj_pos);
                drawnow
            end
        end
        
        function stopMovingObject(this, object)
            set(this.getFigureHandler,'Pointer','arrow')
            set(this.getFigureHandler,'WindowButtonMotionFcn','')
        end
          
        function startResizingObject(this,object)
            set(this.getFigureHandler,'Pointer','topr')
            resizeObjectCallback = @(x,y) this.resizeObject(object);
            set(this.getFigureHandler,'WindowButtonMotionFcn', resizeObjectCallback)
            
            stopResizingObjectCallback = @(x,y) this.stopResizingObject(object);
            set(this.getFigureHandler,'WindowButtonUpFcn', stopResizingObjectCallback)
        end
        
        function resizeObject(this,object)
            fig_pos = this.getPosition;
            current_pos = get(this.getFigureHandler,'CurrentPoint');
            
            obj_pos = object.getPosition;
            new_obj_pos = [obj_pos(1:2) current_pos-obj_pos(1:2)];

            if all(current_pos-obj_pos(1:2)>20) && all(fig_pos(3:4)-current_pos>2)
                object.setPosition(new_obj_pos);
                drawnow
            end
        end
        
        function stopResizingObject(this,object)
            set(this.getFigureHandler,'Pointer','arrow')
            set(this.getFigureHandler,'WindowButtonMotionFcn','')
        end
        
    end
end