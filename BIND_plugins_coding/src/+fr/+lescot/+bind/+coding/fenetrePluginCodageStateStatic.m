classdef fenetrePluginCodageStateStatic < fr.lescot.bind.coding.fenetrePluginCodage % & fr.lescot.bind.plugins.TripPlugin
    properties
        statePanel;
        
        stateMenus;
        
        stateEdit;
        
        codedStateList;
        
        currentTable;
        
        currentVariable;
        
        numeroOfStates;
        
        currentStateIndex;
        
        lastClickedState;
        
        existingStates;
        
        refreshList;
        
        numberOfStates;
    end
    
    properties (Constant)
        columnNames = {'#','StartTimecode','EndTimecode','Modalités'};
    end
    
    methods
        function this = fenetrePluginCodageStateStatic(figureHandler,table,variable,i,N)
            this@fr.lescot.bind.coding.fenetrePluginCodage(figureHandler)
            
            this.currentTable = table;
            this.currentVariable = variable;
            this.numeroOfStates = i;
            this.numberOfStates = N;
            this.existingStates = {};
            this.currentStateIndex = [];
            this.refreshList =true;
            
            %if ~this.currentVariable.isInfosGraphicOk
            this.initiliazeWindow;
            %             else
            %                 infosGraphic = this.currentVariable.getInfosGraphic;
            %                 this.rebuildWindow(infosGraphic);
            %             end
            set(this.getFigureHandler(), 'Resize', 'On');
            set(this.getFigureHandler(), 'Visible', 'On');
        end
        
        function initiliazeWindow(this)
            
            
            %% Retrieving modalities
            Modalities = this.currentVariable.getAllModalities;
            nb_mods = length(Modalities);
            
            %% Figure (suite)
            this.setName(['Type codage : ' this.currentTable])
            this.setColor([0.8 0.8 0.8])
            movegui(this.getFigureHandler(),'center')
            
            %prospect Create Menu
            modalitiesNames = {};
            for i_menus = 1:1:nb_mods
                modalitiesNames = [modalitiesNames, Modalities{i_menus}.getName];
            end
            %              nom = this.currentVariable.getName
            
            % la fenêtre occupe la totailité de l'écran en largeur
            
%____________________________parametrage pour tailleécran ___________________________________
            scrsz = get(groot,'ScreenSize');
            %hauteur et largeur panel
            widthpanel = scrsz (3)/7.1;
            heightpanel = scrsz (4)/12;
            
            %hauteur et largeur des éléments (popmenu, textedit)
            widthelement =widthpanel-20;
            heightcomment =  heightpanel-30;
            heightmenu = heightpanel-(heightpanel/2);
%__________________________________________________________________________________________
           
            % test si modalité popupmenu ou textedit 
            
            if ~isempty(strfind(this.currentVariable.getName,'comment'))
                
%   PARTIE COMMENTEE   pas de paramétrage écran_______________________________________________________________________         
%               this.setPosition([0 0 15+270*min(this.numberOfStates,7) 100*ceil(this.numberOfStates/7)-10])
%               this.statePanel.(this.currentTable) = fr.lescot.bind.coding.stateCodingPanel(this.getFigureHandler(), this.currentVariable.getName);
%               this.statePanel.(this.currentTable).setPosition([10+270*(this.numeroOfStates-1-(fix(this.numeroOfStates/8)*7)) this.height-10-85*ceil(this.numeroOfStates/7) 270 85])
%               this.stateEdit.(this.currentTable) = fr.lescot.bind.coding.stateCodingEdit(this.statePanel.(this.currentTable).panel_handle, this.currentVariable.getName);
%               this.stateEdit.(this.currentTable).setPosition([10 10 250 60])
%_____________________________________________________________________________________________________________
                
                this.setPosition([0 0 15+widthpanel*min(this.numberOfStates,7) (heightpanel+10)*ceil(this.numberOfStates/7)-10]);
                this.statePanel.(this.currentTable) = fr.lescot.bind.coding.stateCodingPanel(this.getFigureHandler(), this.currentVariable.getName);
                if mod(this.numeroOfStates,7)==1
                  this.statePanel.(this.currentTable).setPosition([10 this.height-10-heightpanel*ceil(this.numeroOfStates/7) widthpanel  heightpanel]);
                elseif  mod(this.numeroOfStates,7)==0
                        this.statePanel.(this.currentTable).setPosition([10+widthpanel*(this.numeroOfStates-1-(fix(this.numeroOfStates/8)*7)) this.height-10-heightpanel*ceil(this.numeroOfStates/7) widthpanel  heightpanel]);
                else
                this.statePanel.(this.currentTable).setPosition([10+widthpanel*(this.numeroOfStates-1-(fix(this.numeroOfStates/7)*7)) this.height-10-heightpanel*ceil(this.numeroOfStates/7) widthpanel  heightpanel]);
                end
                this.stateEdit.(this.currentTable) = fr.lescot.bind.coding.stateCodingEdit(this.statePanel.(this.currentTable).panel_handle, this.currentVariable.getName);
                this.stateEdit.(this.currentTable).setPosition([10 10 widthelement heightcomment])
                this.stateEdit.(this.currentTable).setActive
            else
%   PARTIE COMMENTEE   pas de paramétrage écran_______________________________________________________________________         

%                 this.setPosition([0 0 15+270*min(this.numberOfStates,7) 100*ceil(this.numberOfStates/7)-10])
%                 this.statePanel.(this.currentTable) = fr.lescot.bind.coding.stateCodingPanel(this.getFigureHandler(), this.currentVariable.getName);
%                 this.statePanel.(this.currentTable).setPosition([10+270*(this.numeroOfStates-1-(fix(this.numeroOfStates/8)*7)) this.height-10-85*ceil(this.numeroOfStates/7) 270 85])
%                 this.stateMenus.(this.currentTable) = fr.lescot.bind.coding.stateCodingMenus(this.statePanel.(this.currentTable).panel_handle, this.currentVariable.getName, modalitiesNames);
%                 this.stateMenus.(this.currentTable).setPosition([10 10 250 40])
%                 this.stateMenus.(this.currentTable).setActive
%___________________________________________________________________________________________________________________________________________________
                this.setPosition([0 0 15+widthpanel*min(this.numberOfStates,7) (heightpanel+10)*ceil(this.numberOfStates/7)-10]);
                this.statePanel.(this.currentTable) = fr.lescot.bind.coding.stateCodingPanel(this.getFigureHandler(), this.currentVariable.getName); 
                %this.statePanel.(this.currentTable).setPosition([10+widthpanel*(this.numeroOfStates-1-(fix(this.numeroOfStates/8)*7)) this.height-10-heightpanel*ceil(this.numeroOfStates/7) widthpanel  heightpanel]);
                if mod(this.numeroOfStates,7)==1
                    this.statePanel.(this.currentTable).setPosition([10 this.height-10-heightpanel*ceil(this.numeroOfStates/7) widthpanel  heightpanel]);
                elseif  mod(this.numeroOfStates,7)==0
                        this.statePanel.(this.currentTable).setPosition([10+widthpanel*(this.numeroOfStates-1-(fix(this.numeroOfStates/8)*7)) this.height-10-heightpanel*ceil(this.numeroOfStates/7) widthpanel  heightpanel]);
                else
                        this.statePanel.(this.currentTable).setPosition([10+widthpanel*(this.numeroOfStates-1-(fix(this.numeroOfStates/7)*7)) this.height-10-heightpanel*ceil(this.numeroOfStates/7) widthpanel  heightpanel]);
                 end
                this.stateMenus.(this.currentTable) = fr.lescot.bind.coding.stateCodingMenus(this.statePanel.(this.currentTable).panel_handle, this.currentVariable.getName, modalitiesNames);
                this.stateMenus.(this.currentTable).setPosition([10 10 widthelement heightmenu])
                this.stateMenus.(this.currentTable).setActive
                
            end
            
        end
        
        function defineObjectCallback(this,trip)
            if ~isempty(strfind(this.currentVariable.getName,'comment'))
                stateCallback = @(x,y) this.stateEditCallback(trip,x,y);
                this.stateEdit.(this.currentTable).setEditCallback(stateCallback);
            else
                stateCallback = @(x,y) this.stateMenuCallback(trip,x,y);
                this.stateMenus.(this.currentTable).setMenuCallback(stateCallback);
            end
        end
        
        function stateEditCallback(this,trip,source,~)
            clickedEdit = {};
            if this.stateEdit.(this.currentTable).getEditHandle == source
                clickedEdit = this.stateEdit.(this.currentTable);
                stateName = this.stateEdit.(this.currentTable).edit_handle.TooltipString;
                modality = this.stateEdit.(this.currentTable).edit_handle.String;
            end
            if ~isempty(clickedEdit)
                newStates = {0 ,trip.getMaxTimeInDatas() ,modality};
                trip.setIsBaseSituation(this.currentTable,false);
                trip.setBatchOfTimeSituationVariableTriplets(this.currentTable,stateName,newStates');
                trip.setIsBaseSituation(this.currentTable,true);
            end
        end
        
        function stateMenuCallback(this,trip,source,~)
            clickedMenu = {};
            %Find correct menu
            if this.stateMenus.(this.currentTable).getMenuHandle == source
                clickedMenu = this.stateMenus.(this.currentTable);
                stateName = this.stateMenus.(this.currentTable).menu_handle.TooltipString;
                MenuValue = this.stateMenus.(this.currentTable).menu_handle.Value;
                modality = this.stateMenus.(this.currentTable).menu_handle.String{MenuValue};
                
            end
            if ~isempty(clickedMenu)
                newStates = {0 ,trip.getMaxTimeInDatas() ,modality};
                trip.setIsBaseSituation(this.currentTable,false);
                trip.setBatchOfTimeSituationVariableTriplets(this.currentTable,stateName,newStates');
                trip.setIsBaseSituation(this.currentTable,true);
            end
        end
        
        function updateExistingMods(this, trip)
            Metas = trip.getMetaInformations;
            if Metas.existSituation(this.currentTable)
                record = trip.getAllSituationOccurences(this.currentTable);
                if ~isempty(strfind(this.currentVariable.getName,'comment')) && ~isempty(this.stateEdit) && Metas.existSituationVariable(this.currentTable, this.stateEdit.(this.currentTable).edit_handle.TooltipString)
                    this.existingStates = record.buildCellArrayWithVariables({'startTimecode','endTimecode',this.stateEdit.(this.currentTable).edit_handle.TooltipString});
                    this.stateEdit.(this.currentTable).edit_handle.String = this.existingStates{3};
                elseif ~isempty(this.stateMenus) && Metas.existSituationVariable(this.currentTable, this.stateMenus.(this.currentTable).menu_handle.TooltipString)
                    this.existingStates = record.buildCellArrayWithVariables({'startTimecode','endTimecode',this.stateMenus.(this.currentTable).menu_handle.TooltipString});
                    for i_mod = 1:length(this.stateMenus.(this.currentTable).menu_handle.String)
                        if strcmp(this.stateMenus.(this.currentTable).menu_handle.String{i_mod}, this.existingStates{3})
                            value = i_mod;
                        end
                    end
                    this.stateMenus.(this.currentTable).menu_handle.Value = value;
                else
                    this.existingStates = {};
                end
            else
                this.existingStates = {};
            end
        end
        
    end
    
end
