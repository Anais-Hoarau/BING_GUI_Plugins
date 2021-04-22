classdef MachineGUI < fr.lescot.bind.observation.Observer
    
    properties(Access = private)
        figureHandler;
        machine;
        %test field handler
        texteTemperature
        textePression;;
        %handler pour le button group
        groupeLeviers;
        %handler pour la checkbox
        simulationHandler
    end
    
    methods
        
        function this = MachineGUI(machine)
            this.machine = machine;
            this.machine.addObserver(this);
            this.figureHandler = figure('MenuBar', 'none', 'Name', 'Panneau de commande', 'NumberTitle', 'off', 'Resize', 'off', 'Toolbar', 'none', 'Position', [0 0 320 330]);
            windowBackgroundColor = get(this.figureHandler, 'Color');
            %Création du panel d'affichage
            panelAffichage = uipanel(this.figureHandler, 'Units', 'pixels', 'BackgroundColor', windowBackgroundColor, 'Title', 'Affichage', 'Position', [20 10 280 80]);
            this.texteTemperature = uicontrol(panelAffichage, 'Style', 'text', 'String', 'Température : 20°', 'Position', [10 30 220 20], 'BackgroundColor', windowBackgroundColor, 'HorizontalAlignment', 'left');
            this.textePression = uicontrol(panelAffichage, 'Style', 'text', 'String', 'Pression : 1 bar', 'Position', [10 10 220 20], 'BackgroundColor', windowBackgroundColor, 'HorizontalAlignment', 'left');
            %Création du panel de commandes
            panelCommandes = uipanel(this.figureHandler, 'Units', 'pixels', 'BackgroundColor', windowBackgroundColor, 'Title', 'Commande', 'Position', [20 100 280 200]);
            this.groupeLeviers = uibuttongroup(panelCommandes, 'Units', 'pixels', 'Position', [20 60 240 120]);
            uicontrol(this.groupeLeviers, 'Tag', 'rouge', 'Style','Radio','String','Levier rouge', 'Position', [10 80 220 20]);
            uicontrol(this.groupeLeviers, 'Tag', 'bleu', 'Style','Radio','String','Levier bleu', 'Position', [10 50 220 20]);
            uicontrol(this.groupeLeviers, 'Tag', 'noir', 'Style','Radio','String','Levier noir', 'Position', [10 20 220 20]);
            this.simulationHandler = uicontrol(panelCommandes, 'Style', 'checkbox', 'String', 'Mode simulation', 'BackgroundColor', windowBackgroundColor, 'Position', [20 30 220 20]);
            boutonActionner = uicontrol(panelCommandes, 'Style', 'pushbutton', 'String', 'Actionner !', 'Position', [20 10 240 20]);
            boutonCallbackHandler = @this.boutonActionnerCallback;
            set(boutonActionner, 'Callback', boutonCallbackHandler);
            movegui(this.figureHandler, 'center');
            
            %Menu
            menu = uimenu(this.figureHandler, 'Label', 'Fichier');
            resetHandler = uimenu(menu, 'Label', 'Reset');
            resetCallbackHandler = @this.resetCallback;
            set(resetHandler, 'Callback', resetCallbackHandler);
            quitterHandler = uimenu(menu, 'Label', 'Quitter');
            quitterCallbackHandler = @this.quitterCallback;
            set(quitterHandler, 'Callback', quitterCallbackHandler);
        end
        
        function update(this, message)
            set(this.texteTemperature, 'String', ['Température : ' num2str(this.machine.getTemperature()) '°']);
            set(this.textePression, 'String', ['Pression : ' num2str(this.machine.getPression()) ' bar']);
        end
        
    end
    
    methods(Access = private)
        
        function quitterCallback(this, source, eventdata)
            close(this.figureHandler);
        end
        
        function resetCallback(this, source, eventdata)
            this.machine.pousserLevierNoir();
        end
        
        function boutonActionnerCallback(this, source, eventdata)
            selectedRadio = get(this.groupeLeviers, 'SelectedObject');
            isSimulation = get(this.simulationHandler, 'Value');
            if(isSimulation)
                msgbox('Simulation effectuée','Simulation','help');
            else
                tag = get(selectedRadio, 'Tag');
                if(strcmp(tag, 'rouge'))
                    this.machine.pousserLevierRouge();
                else if strcmp(tag, 'bleu')
                        this.machine.pousserLevierBleu();
                    else if (strcmp(tag, 'noir'))
                            this.machine.pousserLevierNoir();
                        end
                    end
                end
            end
        end
        
    end
    
end

