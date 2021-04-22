classdef MachineGUI

    properties
        figureHandler;
    end
    
    methods
        
        function this = MachineGUI()
        
            this.figureHandler = figure('MenuBar', 'none', 'Name', 'Panneau de commande', 'NumberTitle', 'off', 'Resize', 'off', 'Toolbar', 'none', 'Position', [0 0 320 330]);
            windowBackgroundColor = get(this.figureHandler, 'Color');
            %Création du panel d'affichage
            panelAffichage = uipanel(this.figureHandler, 'Units', 'pixels', 'BackgroundColor', windowBackgroundColor, 'Title', 'Affichage', 'Position', [20 10 280 80]);
            texteTemperature = uicontrol(panelAffichage, 'Style', 'text', 'String', 'Temperature : 20°', 'Position', [10 30 220 20], 'BackgroundColor', windowBackgroundColor, 'HorizontalAlignment', 'left');
            textePression = uicontrol(panelAffichage, 'Style', 'text', 'String', 'Pression : 1 bar', 'Position', [10 10 220 20], 'BackgroundColor', windowBackgroundColor, 'HorizontalAlignment', 'left');
            %Création du panel de commandes
            panelCommandes = uipanel(this.figureHandler, 'Units', 'pixels', 'BackgroundColor', windowBackgroundColor, 'Title', 'Commande', 'Position', [20 100 280 200]);
            groupeLeviers = uibuttongroup(panelCommandes, 'Units', 'pixels', 'Position', [20 60 240 120]);
            levierRouge = uicontrol(groupeLeviers, 'Style','Radio','String','Levier rouge', 'Position', [10 80 220 20]);
            levierBleu = uicontrol(groupeLeviers, 'Style','Radio','String','Levier bleu', 'Position', [10 50 220 20]);
            levierNoir = uicontrol(groupeLeviers, 'Style','Radio','String','Levier noir', 'Position', [10 20 220 20]);
            caseSimulation = uicontrol(panelCommandes, 'Style', 'checkbox', 'String', 'Mode simulation', 'BackgroundColor', windowBackgroundColor, 'Position', [20 30 220 20]);
            boutonActionner = uicontrol(panelCommandes, 'Style', 'pushbutton', 'String', 'Actionner !', 'Position', [20 10 240 20]);
            movegui(this.figureHandler, 'center');
            
            %Menu
            menu = uimenu(this.figureHandler, 'Label', 'Fichier');
            uimenu(menu, 'Label', 'Reset');
            uimenu(menu, 'Label', 'Quitter');
        end
        
    end
    
end

