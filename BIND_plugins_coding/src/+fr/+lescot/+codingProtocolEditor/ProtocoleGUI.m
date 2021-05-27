classdef ProtocoleGUI < handle
    
    %< depouillement.codage.Variable ...
    %   & depouillement.codage.Protocol &  depouillement.codage.Family &  depouillement.codage.Modality & depouillement.codage.Interfacecodage
    
    %PROTOCOLEGUI Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        listeFamilles = { };
        % handles
        hFenetreProtocole;
        hFenetreVariable;
        hFenetreFamille;
        hFenetreNomModalite;
        hFenetreValeurModalite;
        hFenetreEvenement;
        hFenetreEtat;
        modeAffichage;
        variableEvenementActive;
        variableEtatActive;
        variableActive;
        modaliteActive;
        familleActive;
        protocoleActif;
        famillesProtocoleActif;
        handles;
    end
    
    methods
        function this = ProtocoleGUI()
            this.modaliteActive = {};
            this.familleActive = {};
            this.variableEvenementActive= {};
            this.variableEtatActive = {};
            this.variableActive= {};
            this.protocoleActif= {};
            this.famillesProtocoleActif= {};
            this.modeAffichage = 'lignes';
            this.hFenetreProtocole=figure(...
                'Units','characters',...
                'PaperUnits',get(0,'defaultfigurePaperUnits'),...
                'Color',[0.941 0.941 0.941],...
                'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
                'IntegerHandle','off',...
                'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
                'MenuBar','none',...
                'Name','Editeur de protocole de codage de données',...
                'NumberTitle','off',...
                'PaperPosition',get(0,'defaultfigurePaperPosition'),...
                'PaperSize',[20.98404194812 29.67743169791],...
                'PaperType',get(0,'defaultfigurePaperType'),...
                'Position',[103.8 34 216.4 28],...
                'Resize','off',...
                'HandleVisibility','callback',...
                'HitTest','off',...
                'Tag','FentreEditionProtocole',...
                'UserData',[],...
                'Visible','on');
            
            %% MENUS
            
            % Creation des menus ******************************************
            menuFichier = uimenu(...
                'Parent',  this.hFenetreProtocole,...
                'Checked','on',...
                'Label','Fichier',...
                'Tag','menu_Fichier');
            
            
            %'Callback',@(hObject,eventdata)essaifig8_export('menu_nouveau_Callback',hObject,eventdata,guidata(hObject)),...
            menuNouveauProtocole = uimenu(...
                'Parent',menuFichier,...
                'Label','Nouveau protocole',...
                'Tag','menu_nouveau');
            menuNouveauProtocoleCallbackHandler = @this.saisieNomProtocoleCallback;
            set(menuNouveauProtocole , 'Callback', menuNouveauProtocoleCallbackHandler);
            
            menuOuvrirProtocole = uimenu(...
                'Parent',menuFichier,...
                'Label','Ouvrir',...
                'Tag','menu_Ouvrir');
            menuOuvrirProtocoleCallbackHandler = @this.ouvrirProtocoleCallback;
            set(menuOuvrirProtocole , 'Callback', menuOuvrirProtocoleCallbackHandler);
            
            menuSauvegarderProtocole = uimenu(...
                'Parent',menuFichier,...
                'Label','Sauvegarder ',...
                'Tag','menu_Sauvegarder');
            menuSauvegarderProtocoleCallbackHandler = @this.sauvegarderProtocoleCallback;
            set(menuSauvegarderProtocole , 'Callback', menuSauvegarderProtocoleCallbackHandler);
            
            menuQuitter = uimenu(...
                'Parent',menuFichier,...
                'Label','Quitter',...
                'Tag','menu_Quitter');
            menuQuitterCallbackHandler = @this.quitterCallback;
            set(menuQuitter , 'Callback', menuQuitterCallbackHandler);
            
            menuEdition= uimenu(...
                'Parent',  this.hFenetreProtocole,...
                'Label','Edition',...
                'Tag','menu_Edition');
            
            menuRAZ = uimenu(...
                'Parent',menuEdition,...
                'Label','RAZ',...
                'Tag','menu_RAZ');
            appdata = [];
            appdata.lastValidTag = 'menu_ImporterFamilles';
            menuRAZCallbackHandler = @this.RAZCallback;
            set(menuRAZ , 'Callback', menuRAZCallbackHandler);
            
            menuImporterFamilles = uimenu(...
                'Parent',menuEdition,...
                'Label','Importer familles',...
                'Tag','menu_ImporterFamilles');
            menuImporterFamillesCallbackHandler = @this.ImporterFamillesCallback;
            set(menuImporterFamilles , 'Callback', menuImporterFamillesCallbackHandler);
            
            menuAffichage = uimenu(...
                'Parent',  this.hFenetreProtocole,...
                'Label','Affichage',...
                'Tag','menu_Affichage');
            
            menuVisualiser = uimenu(...
                'Parent',menuAffichage,...
                'Callback',@(hObject,eventdata)essaifig8_export('menu_visualiser_Callback',hObject,eventdata,guidata(hObject)),...
                'Label','Visualiser',...
                'Tag','menu_visualiser');
            menuVisualiserCallbackHandler = @this.VisualiserCallback;
            set(menuVisualiser , 'Callback', menuVisualiserCallbackHandler);
            
            menuEditer = uimenu(...
                'Parent',menuAffichage,...
                'Callback',@(hObject,eventdata)essaifig8_export('menu_Editer_Callback',hObject,eventdata,guidata(hObject)),...
                'Enable','off',...
                'Label','Editer',...
                'Tag','menu_Editer');
            
            %             h13 = uicontextmenu(...
            %                 'Parent',  this.hFenetreProtocole,...
            %                 'Callback',@(hObject,eventdata)essaifig8_export('Untitled_1_Callback',hObject,eventdata,guidata(hObject)),...
            %                 'Tag','Untitled_1');
            %
            %             h14 = uimenu(...
            %                 'Parent',h13,...
            %                 'Callback',@(hObject,eventdata)essaifig8_export('Untitled_2_Callback',hObject,eventdata,guidata(hObject)),...
            %                 'Label','gffgfg',...
            %                 'Tag','Untitled_2');
            %             % Fin de la Creation des menus ******************************************
            
            % debut de création des boutons ****************************************
            
            %% PROTOCOLE ET MODE D'AFFICHAGE
            panelProtocole = uipanel(...
                'Parent',  this.hFenetreProtocole,...
                'Units','characters',...
                'FontSize',12,...
                'FontWeight','bold',...
                'Title','Protocole',...
                'Tag','PanelProtocole',...
                'Clipping','on',...
                'Position',[-0.2 1.53846153846154 35.6 24]);
            
            panelIdentiteProtocole = uipanel(...
                'Parent',panelProtocole,...
                'Units','characters',...
                'Title',blanks(0),...
                'Tag','uipanel14',...
                'Clipping','on',...
                'Position',[1.6 10.8461538461538 30.6 10.9230769230769]);%,...
            %'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );
            
            editTextNomProtocole = uicontrol(...
                'Parent',panelIdentiteProtocole,...
                'Units','characters',...
                'BackgroundColor',[1 1 1],...
                'Callback',@(hObject,eventdata)essaifig8_export('EditTextNomProtocle_Callback',hObject,eventdata,guidata(hObject)),...
                'Position',[0.8 6.84615384615385 28 2.07692307692308],...
                'String',blanks(0),...
                'Style','text',...
                'Tag','EditTextNomProtocole');
            
            % texte
            titreEditTextNomProtocole= uicontrol(...
                'Parent',panelIdentiteProtocole,...
                'Units','characters',...
                'FontWeight','bold',...
                'Position',[9.60000000000001 9.15384615384616 10.4 1.07692307692308],...
                'String','Nom',...
                'Style','text',...
                'Tag','TextEditTextNomProtocole');
            
            editTextCommentaireProtocole = uicontrol(...
                'Parent',panelIdentiteProtocole,...
                'Units','characters',...
                'BackgroundColor',[1 1 1],...
                'Callback',@(hObject,eventdata)essaifig8_export('EditTextCommentaireProtocole_Callback',hObject,eventdata,guidata(hObject)),...
                'Position',[0.8 2.92307692307692 28 2.07692307692308],...
                'String',blanks(0),...
                'Style','text',...
                'Tag','EditTextCommentaireProtocole');
            
            %texte associé
            titreEditTextCommentaireProtocole = uicontrol(...
                'Parent',panelIdentiteProtocole,...
                'Units','characters',...
                'FontWeight','bold',...
                'Position',[6.8 5.23076923076923 16 1.07692307692308],...
                'String','Commentaire',...
                'Style','text',...
                'Tag','TextEditTextCommentaireProtocole');
            
            % bouton modifier
            boutonModifierNomProtocole = uicontrol(...
                'Parent',panelIdentiteProtocole,...
                'Units','characters',...
                'Position',[8 0.769230769230769 13.8 1.69230769230769],...
                'String','Modifier',...
                'Tag','BoutonModifierNomProtocole');%,...
            %'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );
            boutonModifierNomProtocoleCallbackHandler = @this.saisieNomProtocoleCallback;
            set(boutonModifierNomProtocole , 'Callback', boutonModifierNomProtocoleCallbackHandler);
            
            % mode affichage
            %groupe
            groupeBoutonsAffichage = uibuttongroup(...
                'Parent',panelProtocole,...
                'Units','characters',...
                'FontWeight','bold',...
                'Title','Mode d''affichage',...
                'Tag','PanelModeAffichage',...
                'Clipping','on',...
                'Position',[3.4 3 28.6 7.53846153846154],...
                'SelectedObject',[],...
                'SelectionChangeFcn',[],...
                'OldSelectedObject',[]);
            choisirModeAffichageCallbackHandler = @this.modeAffichageCallback;
            set(groupeBoutonsAffichage , 'SelectionChangeFcn',choisirModeAffichageCallbackHandler);
            %choix 1
            radioboutonAffichageColonnes = uicontrol(...
                'Parent',groupeBoutonsAffichage,...
                'Units','characters',...
                'Callback',@(hObject,eventdata)essaifig8_export('RadiobuttonAffichageColonnes_Callback',hObject,eventdata,guidata(hObject)),...
                'FontWeight','bold',...
                'Position',[2.4 2.53846153846154 17.4 1.76923076923077],...
                'String','Colonnes',...
                'Style','radiobutton',...
                'TooltipString','Les boutons de codage des variables d''une familles seront regoupées  en colonne sur l''interface de codage',...
                'Tag','RadiobuttonAffichageColonnes');
            
            %choix 2
            radioboutonAffichageLignes = uicontrol(...
                'Parent',groupeBoutonsAffichage,...
                'Units','characters',...
                'Callback',@(hObject,eventdata)essaifig8_export('RadiobuttonAffichageLignes_Callback',hObject,eventdata,guidata(hObject)),...
                'FontWeight','bold',...
                'Position',[2.4 4 17.4 1.76923076923077],...
                'String','Lignes',...
                'Style','radiobutton',...
                'TooltipString','Les boutons de codage des variables d''une familles seront regoupées en ligne sur l''interface de codage',...
                'Value',1,...
                'Tag','RadiobuttonAffichageLignes');
            
            %choix 3
            radioboutonAffichagePersonnalise = uicontrol(...
                'Parent',groupeBoutonsAffichage,...
                'Units','characters',...
                'Callback',@(hObject,eventdata)essaifig8_export('RadiobuttonAffichagePersonnalise_Callback',hObject,eventdata,guidata(hObject)),...
                'Enable','off',...
                'FontWeight','bold',...
                'Position',[2.4 0.846153846153847 20.6 1.76923076923077],...
                'String','Personnalisé',...
                'Style','radiobutton',...
                'Tag','RadiobuttonAffichagePersonnalise');
            
            % h44 = uicontrol(...
            % 'Parent',panelProtocole,...
            % 'Units','characters',...
            % 'Callback',@(hObject,eventdata)essaifig8_export('BoutonValideProtocole_Callback',hObject,eventdata,guidata(hObject)),...
            % 'FontWeight','bold',...
            % 'Position',[7.4 0.538461538461541 20 1.69230769230769],...
            % 'String','Valider',...
            % 'TooltipString','Le protocole validé ne sera plus modifiable ',...
            % 'Tag','BoutonValideProtocole');
            
            %% FAMILLES DE VARIABLE %%
            panelFamilles = uipanel(...
                'Parent',  this.hFenetreProtocole,...
                'Units','characters',...
                'FontSize',12,...
                'FontWeight','bold',...
                'Title','Familles de variables',...
                'Tag','PanelFamille',...
                'Clipping','on',...
                'Position',[36.4 1.61538461538462 48.2 24]);
            
            boutonAjouterFamille = uicontrol(...
                'Parent',panelFamilles,...
                'Units','characters',...
                'FontSize',13,...
                'FontWeight','bold',...
                'Position',[38 13.0769230769231 8 2],...
                'String','+',...
                'TooltipString','Ajouter une famille ',...
                'Tag','BoutonAjouteFamille');
            boutonAjouterFamilleCallbackHandler = @this.ajouterFamilleCallback;
            set(boutonAjouterFamille ,'Callback',boutonAjouterFamilleCallbackHandler);
            
            boutonSupprimerFamille= uicontrol(...
                'Parent',panelFamilles,...
                'Units','characters',...
                'FontSize',15,...
                'FontWeight','bold',...
                'Position',[38 10.6153846153846 8 2],...
                'String','-',...
                'TooltipString','Supprimer la  famille sélectionnée',...
                'Tag','BoutonSupprimeFamille');
            boutonSupprimerFamilleCallbackHandler = @this.supprimerFamilleCallback;
            set(boutonSupprimerFamille ,'Callback',boutonSupprimerFamilleCallbackHandler);
            
            boutonEditerFamille = uicontrol(...
                'Parent',panelFamilles,...
                'Units','characters',...
                'FontWeight','bold',...
                'Position',[38 8.07692307692308 8 2],...
                'String','Editer',...
                'TooltipString','Editer la famille sélectionnée',...
                'Tag','BoutonEditeFamille');
            boutonEditerFamilleCallbackHandler = @this.editerFamilleCallback;
            set(boutonEditerFamille ,'Callback',boutonEditerFamilleCallbackHandler);
            
            % liste des familles
            this.hFenetreFamille = uicontrol(...
                'Parent',panelFamilles,...
                'Units','characters',...
                'BackgroundColor',[1 1 1],...
                'Position',[2.8 1.46153846153846 33.8 19.3846153846154],...
                'Style','listbox',...
                'Value',1,...
                'Tag','ListboxFamille');
            listBoxFamilleCallbackHandler = @this.listBoxFamilleCallback;
            set(this.hFenetreFamille ,'Callback',listBoxFamilleCallbackHandler);
            
            
            
            %% VARIABLES
            panelVariables = uipanel(...
                'Parent',  this.hFenetreProtocole,...
                'Units','characters',...
                'FontSize',12,...
                'FontWeight','bold',...
                'Title','Variables',...
                'Tag','PanelVariables',...
                'Clipping','on',...
                'Position',[87.6 1.61538461538462 55.4 24]);
            
            % liste des etats
            this.hFenetreEtat = uicontrol(...
                'Parent',panelVariables,...
                'Units','characters',...
                'BackgroundColor',[1 1 1],...
                'CData',[],...
                'Max',2,...
                'Position',[2.6 12.1538461538462 40 8.69230769230769],...
                'String',{  blanks(0); blanks(0) },...
                'Style','listbox',...
                'Value',[],...
                'Tag','ListboxEvenement',...
                'Userdata','etat');
            listBoxVariableEtatCallbackHandler = @this.listBoxVariableCallback;
            set(this.hFenetreEtat ,'Callback',listBoxVariableEtatCallbackHandler);
            
            
            %liste des evenements
            this.hFenetreEvenement = uicontrol(...
                'Parent',panelVariables,...
                'Units','characters',...
                'BackgroundColor',[1 1 1],...
                'CData',[],...
                'Max',2,...
                'Position',[2.6 1.46153846153846 40 8.53846153846154],...
                'Style','listbox',...
                'Value',[],...
                'SelectionHighlight','off',...
                'Tag','ListBoxEtat',...
                'Userdata','evenement');
            listBoxVariableEvenementCallbackHandler = @this.listBoxVariableCallback;
            set(this.hFenetreEvenement ,'Callback',listBoxVariableEvenementCallbackHandler);
            
            % texte
            titreListBoxEvenements = uicontrol(...
                'Parent',panelVariables,...
                'Units','characters',...
                'FontAngle','italic',...
                'FontSize',10,...
                'FontWeight','bold',...
                'Position',[12.4 10 20.4 1.38461538461538],...
                'String','Evènements',...
                'Style','text',...
                'TooltipString','Evènements ponctuels',...
                'Tag','text2');
            
            
            titreListBoxEtats = uicontrol(...
                'Parent',panelVariables,...
                'Units','characters',...
                'FontAngle','italic',...
                'FontSize',10,...
                'FontWeight','bold',...
                'Position',[7.6 20.9230769230769 30.2 1.30769230769231],...
                'String','Etats',...
                'Style','text',...
                'TooltipString','Variables à modalités exclusives et exhaustives OU séquences',...
                'Tag','TextListboxEvenement');
            
            
            % ajouter etat
            boutonAjouterVariableEtat = uicontrol(...
                'Parent',panelVariables,...
                'Units','characters',...
                'FontSize',13,...
                'FontWeight','bold',...
                'Position',[44 16.2307692307692 8 2],...
                'String','+',...
                'Userdata','etat',...
                'TooltipString','Ajouter un état à la famille sélectionnée',...
                'Tag','BoutonAjouteVariableEtat');
            boutonAjouterVariableEtatCallbackHandler = @this.ajouterVariableCallback;
            set(boutonAjouterVariableEtat ,'Callback',boutonAjouterVariableEtatCallbackHandler);
            
            %supprimer etat
            boutonSupprimerVariableEtat = uicontrol(...
                'Parent',panelVariables,...
                'Units','characters',...
                'FontSize',15,...
                'FontWeight','bold',...
                'Position',[44 14.1538461538462 8 2],...
                'String','-',...
                'Userdata','etat',...
                'TooltipString','Supprimer l''état sélectionné',...
                'Tag','BoutonSupprimeVariableEtat');
            boutonSupprimerVariableEtatCallbackHandler = @this.supprimerVariableCallback;
            set(boutonSupprimerVariableEtat ,'Callback',boutonSupprimerVariableEtatCallbackHandler);
            
            % supprimer variable evenement
            boutonSupprimerVariableEvenement = uicontrol(...
                'Parent',panelVariables,...
                'Units','characters',...
                'FontSize',15,...
                'FontWeight','bold',...
                'Position',[44 3.46153846153846 8 2],...
                'String','-',...
                'Userdata','evenement',...
                'TooltipString','Supprimer l''évènement sélectionné',...
                'Tag','BoutonSupprimeVariableEvenement');
            boutonSupprimerVariableEvenementCallbackHandler = @this.supprimerVariableCallback;
            set(boutonSupprimerVariableEvenement ,'Callback',boutonSupprimerVariableEvenementCallbackHandler);
            
            %
            %             %ajouter variable evenement
            boutonAjouterVariableEvenement = uicontrol(...
                'Parent',panelVariables,...
                'Units','characters',...
                'FontSize',13,...
                'FontWeight','bold',...
                'Position',[44 5.46153846153846 8 2],...
                'String','+',...
                'Userdata','evenement',...
                'TooltipString','Ajouter un évènement à la famille sélectionnée',...
                'Tag','BoutonAjouteVariableEvenement');
            boutonAjouterVariableEvenementCallbackHandler = @this.ajouterVariableCallback;
            set(boutonAjouterVariableEvenement ,'Callback',boutonAjouterVariableEvenementCallbackHandler);
            

            %edition variables
            boutonEditeVariableEtat = uicontrol(...
                'Parent',panelVariables,...
                'Units','characters',...
                'FontWeight','bold',...
                'Position',[44 12.1538461538462 8 2],...
                'String','Editer',...
                'Userdata','etat',...
                'TooltipString','Editer l''état ou l'' évènement sélectionné',...
                'Tag','BoutonEditeVariable');
            boutonEditeVariableEtatCallbackHandler = @this.editerVariableCallback;
            set(boutonEditeVariableEtat ,'Callback',boutonEditeVariableEtatCallbackHandler);
            
            
            boutonEditeVariableEvenement = uicontrol(...
                'Parent',panelVariables,...
                'Units','characters',...
                'FontWeight','bold',...
                'Position',[44 1.46153846153846 8 2],...
                'String','Editer',...
                'Userdata','evenement',...
                'TooltipString','Editer l''état ou l'' évènement sélectionné',...
                'Tag','BoutonEditeVariable');
            boutonEditeVariableEvenementCallbackHandler = @this.editerVariableCallback;
            set(boutonEditeVariableEvenement ,'Callback',boutonEditeVariableEvenementCallbackHandler);
            
            %% MODALITES
            
            %Panel
            panelModalites = uipanel(...
                'Parent',  this.hFenetreProtocole,...
                'Units','characters',...
                'FontSize',12,...
                'FontWeight','bold',...
                'Title','Modalités',...
                'Tag','PanelModalites',...
                'Clipping','on',...
                'Position',[144.8 1.61538461538462 69.8 24]);
            
            % texte au sommet des listes
            titreListBoxModalite = uicontrol(...
                'Parent',panelModalites,...
                'Units','characters',...
                'FontAngle','italic',...
                'FontSize',10,...
                'FontWeight','bold',...
                'Position',[1.2 20.6923076923077 57.8 1.07692307692308],...
                'String','Nom                       Valeur',...
                'Style','text',...
                'TooltipString','nom affiché sur le bouton de codage , valeur dans le fichier de codage',...
                'Tag','TextListboxModalite');
            
            % listes des modalités : noms
            this.hFenetreNomModalite = uicontrol(...
                'Parent',panelModalites,...
                'Units','characters',...
                'BackgroundColor',[1 1 1],...
                'CData',[],...
                'Max',20,...
                'Position',[2.60000000000002 1.53846153846154 33.8 18.6923076923077],...
                'String',{  blanks(0); blanks(0) },...
                'Style','listbox',...
                'Value',[],...
                'Tag','ListboxNomModalite',...
                'UserData','Nom');
            
            listBoxNomModaliteCallbackHandler = @this.listBoxModaliteCallback;
            set(this.hFenetreNomModalite ,'Callback',listBoxNomModaliteCallbackHandler);
            
            
            % les valeurs
            this.hFenetreValeurModalite = uicontrol(...
                'Parent',panelModalites,...
                'Units','characters',...
                'BackgroundColor',[1 1 1],...
                'CData',[],...
                'Max',20,...
                'Position',[30.0000000000001 1.61538461538462 27.6 18.6153846153846],...
                'Style','listbox',...
                'Value',[],...
                'Tag','ListboxValeurModalite',...
                'UserData','Valeur');
            listBoxValeurModaliteCallbackHandler = @this.listBoxModaliteCallback;
            set(this.hFenetreValeurModalite ,'Callback',listBoxValeurModaliteCallbackHandler);
            
            % ajouter modalité
            boutonAjouterModalite = uicontrol(...
                'Parent',panelModalites,...
                'Units','characters',...
                'FontSize',13,...
                'FontWeight','bold',...
                'Position',[59.6 12.7692307692308 8 2],...
                'String','+',...
                'UserData','',...
                'TooltipString','Ajouter une modalité à la variable sélectionnée',...
                'Tag','BoutonAjouteModalite');
            boutonAjouterModaliteCallbackHandler = @this.ajouterModaliteCallback;
            set(boutonAjouterModalite ,'Callback',boutonAjouterModaliteCallbackHandler);
            
            
            
            % supprimer modalités
            boutonSupprimerModalite = uicontrol(...
                'Parent',panelModalites,...
                'Units','characters',...
                'FontSize',15,...
                'FontWeight','bold',...
                'Position',[59.6 10.2307692307692 8 2],...
                'String','-',...
                'TooltipString','Supprimer la  modalité sélectionnée',...
                'Tag','BoutonSupprimeModalite');
            boutonSupprimerModaliteCallbackHandler = @this.supprimerModaliteCallback;
            set(boutonSupprimerModalite ,'Callback',boutonSupprimerModaliteCallbackHandler);
            
            boutonEditerModalite = uicontrol(...
                'Parent',panelModalites,...
                'Units','characters',...
                'FontWeight','bold',...
                'Position',[59.6 7.69230769230771 8 2],...
                'String','Editer',...
                'TooltipString','Editer la modalité sélectionnée',...
                'Tag','BoutonEditeModalite');
            
            boutonEditerModaliteCallbackHandler = @this.editerModaliteCallback;
            set(boutonEditerModalite ,'Callback',boutonEditerModaliteCallbackHandler);
            
            %% sortie de la méthode
            
            handles = this.hFenetreProtocole;
            
            % a = depouillement.codage.Protocol('toto');
            % a.getName()
            % b= depouillement.codage.Family('titi');
            % b.getName
            this.handles = guihandles( this.hFenetreProtocole);
            %             this.handles.typevariable = 'etat';
            %             guidata(this.hFenetreProtocole,this.handles);
        end
        
        
        function saisieNomProtocoleCallback(this, source, eventdata)
            prompt={'Nom du protocole:',...
                'Commentaire:'};
            
            name='Déclaration du nouveau protocole';
            numlines=1;
            
            if ~isempty(this.protocoleActif)
                % si un protocole existe
                nom=char(this.protocoleActif.getName());
                comment=char( this.protocoleActif.getComments());
                defaultanswer= {nom,comment};
            else
                defaultanswer={'nom','commentaire'};
            end
            answer=inputdlg(prompt,name,1,defaultanswer);%,numlines);
            %%%%%%%%%%% A VOIR CREERerrordlg('Déja existant','Erreur')VOIR ARNAUD;
            % test reponse vide inutile
            if ~isempty(answer)
                if ~isempty(answer{1})
                    % answer 1 est la réponse au premier edit de la question : le nom
                    a = char(answer{1});
                    % on écrit sur la face avant le résultat du champ de saisie
                    set(this.handles.EditTextNomProtocole,'String',answer{1});
                    % creer l'objet Protocol
                    this.protocoleActif = fr.lescot.bind.coding.Protocol(a);
                end
                if ~isempty(answer(2))
                    % answer 2 est la réponse au second edit de la question : un
                    % commentaire
                    b= char(answer(2));
                    % ecriture sur face avant
                    set(this.handles.EditTextCommentaireProtocole,'String',answer(2));
                    % ajout du commentaire
                    this.protocoleActif.setComments(b);
                end
            end
        end
        function ouvrirProtocoleCallback(this, source, eventdata)
            [FileName,PathName,FilterIndex] = uigetfile('*.pro','Choisissez le nom du fichier de sauvegarde');
            if FileName~=0
                loadPathName = fullfile(PathName,FileName);
                load(loadPathName,'-mat','protocol');
                this.protocoleActif = protocol;
                % refresh protocol name
                set(this.handles.EditTextNomProtocole,'String',this.protocoleActif.getName());
                set(this.handles.EditTextCommentaireProtocole,'String',this.protocoleActif.getComments());
                % by default, first family is selected... we refresh all
                % lists : families, variables and modalities.
                this.MiseAJour2ListBoxFamilles();
                this.MiseAJour2ListBoxVariables();
                this.MiseAJour2ListBoxModalites();
                
            end
        end
        function sauvegarderProtocoleCallback(this, source, eventdata)
            % fonction de sauvegarde du protocole
            protocol = this.protocoleActif;
            [FileName,PathName,FilterIndex] = uiputfile('*.pro','Choisissez le nom du fichier de sauvegarde');
            if FileName~=0
                savePathName = fullfile(PathName,FileName);
                save(savePathName,'protocol');
            end
        end
        function quitterCallback(this, source, eventdata)
            close(this.hFenetreProtocole);
        end
        function RAZCallback(this, source, eventdata)
        end
        function ImporterFamillesCallback(this, source, eventdata)
        end
        function VisualiserCallback(this, source, eventdata)
        end
        
        
        function listBoxFamilleCallback(this, source, eventdata)
            indexlistBoxFamille=get(this.hFenetreFamille,'Value');
            % on teste si un element a bien été selectionné (liste non vide)
            if ~isempty(indexlistBoxFamille)
                allFamilies = this.protocoleActif.getAllFamilies();
                this.familleActive = allFamilies{indexlistBoxFamille};
                this.MiseAJour2ListBoxVariables();
                this.MiseAJour2ListBoxModalites();
                
            end
        end
        
        function ajouterFamilleCallback(this, source, eventdata)
            % pour crer des familles un protocole actif doit exister
            
            if ~isempty(this.protocoleActif)
                prompt={'Nom  de la  famille :','Commentaire:'};
                
                answer=inputdlg(prompt);
                if ~isempty(answer)
                    if ~isempty(answer{1})
                        existenceFamille=verifierExistenceNomFamille(this,answer{1});
                        
                        if ~(existenceFamille )
                            % ajout du nom de package
                            name = char(answer{1});
                            a = fr.lescot.bind.coding.Family(name);
                            b= char(answer(2));
                            a.setComments(b);
                            %ajouter famille dans protocole
                            this.protocoleActif.addFamily(a);
                            nouvellesFamilles = this.protocoleActif.getAllFamilies();
                            N = length(nouvellesFamilles);
                            nomFamilles = cell(1,N);
                            for i=1:1:N
                                nomFamilles{i} = nouvellesFamilles{i}.getName();
                            end
                            % on recharge et on selectionne avec le dernier
                            % element
                            set(this.hFenetreFamille,'String',nomFamilles,'Value',N,'SelectionHighlight','on');
                            this.familleActive = nouvellesFamilles{N};
                            
                            set(this.hFenetreEtat,'string', '');
                            set(this. hFenetreEvenement,'string', '');
                        else
                            errordlg('Ce nom est déjà utilisé ');
                        end
                        
                        this.MiseAJour2ListBoxVariables();
                        this.MiseAJour2ListBoxModalites();
                    end
                end
            else
                errordlg('Aucun protocole actif')
            end
        end
        function editerFamilleCallback(this, source, eventdata)
            %%%%%%%%%%% A CREERerrordlg('Déja existant','Erreur');
            %%%%% test si commentaire et nom non modifiés
            index = get(this.hFenetreFamille,'Value');
            prompt={'Nom  de la  famille :','Commentaire:'};
            nom = this.familleActive.getName();
            comment= getComments(this.familleActive);
            def = {char(nom),char(comment)};
            answer = inputdlg(prompt,'',1,def);
            % verifier answer pour mise à jour
            
            
            if ~isempty(answer)
                if ~isempty(answer{1})
                    a = char(answer{1});
                    % changer nom famille active
                    set(this.hFenetreFamille,'String',answer{1},'Value',index);
                    setName(this.familleActive,a);
                end
                if ~isempty(answer(2))
                    b= char(answer(2));
                    % changer commentaire famille active
                    setComments(this.familleActive,b);
                end
                %  A VOIR contrôler que le nom n'existe pas
            end
            %mise a jour de la listebox familles
            Familles = this.protocoleActif.getAllFamilies();
            N = length(Familles);
            nomFamilles = cell(1,N);
            for i=1:1:N
                nomFamilles{i} = Familles{i}.getName();
            end
            % on recharge et on selectionne avec la famille
            % editée
            % element
            set(this.hFenetreFamille,'String',nomFamilles,'Value',index);
            
            %mettre à jour index listbox
            %set(this.hFenetreFamille,'Value',index);
        end
        
        function supprimerFamilleCallback(this, source, eventdata)
            
            familleASupprimer = this.familleActive ;
            this.protocoleActif.removeFamily(familleASupprimer);
            
            famillesRestantes = this.protocoleActif.getAllFamilies();
            N = length(famillesRestantes);
            if N>0
                nomFamilles = cell(1,N);
                for i=1:1:N
                    nomFamilles{i} = char(famillesRestantes{i}.getName());
                end
                % on selectionne la derniere
                set(this.hFenetreFamille,'String',nomFamilles,'Value',N);
                this.familleActive = famillesRestantes{N};
                
            else
                set(this.hFenetreFamille,'String','');
                %this.familleActive = {};
                this.familleActive = {};
                set(this.hFenetreEtat,'string', '');
                set(this. hFenetreEvenement,'string', '');
            end
            
            this.MiseAJour2ListBoxVariables();
            this.MiseAJour2ListBoxModalites();
        end
        
        function out= verifierExistenceNomFamille(this,nomSaisi)
            % liste des familles du protocole
            listeFamillesProtocoleActif=this.protocoleActif.getAllFamilies;
            out=0;
            % voir si le nom choisi existe déjà
            for i=1:length(listeFamillesProtocoleActif)
                a = listeFamillesProtocoleActif{i};
                nomFamille = char(getName(a));
                b= char(nomSaisi);
                if (strcmp(nomFamille, b))
                    % retourne 1 si le nom existe dejà
                    out=1;
                end
            end
        end
        
        function out= verifierExistenceNomVariable(this,nomSaisi)
            % liste des variables de la famille
            listeVariablesFamilleActive=this.familleActive.getAllVariables;
            out=0;
            % voir si le nom choisi existe déjà
            for i=1:length(listeVariablesFamilleActive)
                a = listeVariablesFamilleActive{i};
                nomVariable = char(getName(a));
                b= char(nomSaisi);
                if (strcmp(nomVariable, b))
                    % retourne 1 si le nom existe dejà
                    out=1;
                end
            end
        end
        
        function ajouterVariableCallback(this, source, eventdata)
            % pour creer des familles un protocole actif doit exister
            typeVar=get(source,'userdata');
            if ~isempty(this.protocoleActif)
                
                if ~isempty (this.familleActive)
                    prompt={'Nom  de la  variable :','Commentaire:'};
                    
                    answer=inputdlg(prompt);
                    
                    if ~isempty(answer)
                        if ~isempty(answer{1})
                            existencenomVariable=verifierExistenceNomVariable(this,answer{1});
                            
                            if ~(existencenomVariable )
                                % ajout du nom de package
                                name = char(answer{1});
                                a = fr.lescot.bind.coding.Variable(name);
                                b= char(answer(2));
                                a.setComments(b);
                                a.setType(typeVar);
                                
                                this.familleActive.addVariable(a);
                                nouvellesVariables = this.familleActive.getAllVariables();
                                
                                N = length(nouvellesVariables);
                                n= 0;
                                nomsVariables = cell(1,N);
                                for i=1:1:N
                                    typ= nouvellesVariables{i}.getType();
                                    if strcmp (typ,typeVar)
                                        n=n+1;
                                        nomsVariables{n} = nouvellesVariables{i}.getName();
                                    end
                                end
                                
                                switch typeVar
                                    case 'etat'
                                        set(this.hFenetreEtat,'String',nomsVariables,'Value',n);
                                        this.variableEtatActive =  nouvellesVariables{N};
                                        
                                    case 'evenement'
                                        set(this.hFenetreEvenement,'String',nomsVariables,'Value',n);
                                        this.variableEvenementActive =  nouvellesVariables{N};
                                end
                                this.variableActive = nouvellesVariables{N};
                                % mettre à jour variable active
                                
                            else
                                errordlg('Ce nom est déjà utilisé ');
                            end
                            this.MiseAJour2ListBoxModalites();
                        end
                    end
                else
                    errordlg('Aucune famille active')
                end
            else
                errordlg('Aucun protocole actif')
            end
        end
        
        
        function supprimerVariableCallback(this, source, eventdata)
            typeVar=get(source,'userdata');
            switch typeVar
                case 'etat'
                    variableASupprimer = this.variableEtatActive ;
                case 'evenement'
                    variableASupprimer = this.variableEvenementActive ;
            end
            this.familleActive.removeVariable(variableASupprimer);
            switch typeVar
                case 'etat'
                    variablesRestantes= this.familleActive.getAllVariablesEtat();
                case 'evenement'
                    variablesRestantes= this.familleActive.getAllVariablesEvenement();
            end
            
            N = length(variablesRestantes);
            if (N>0)
                
                nomVariables = cell(1,N);
                for i=1:1:N
                    nomVariables{i} = char(variablesRestantes{i}.getName());
                end
            end
            switch typeVar
                case 'etat'
                    if N>0
                        set(this.hFenetreEtat,'String',nomVariables,'Value',N);
                        this.variableEtatActive=variablesRestantes{N};
                        this.variableActive=variablesRestantes{N};
                    else
                        set(this.hFenetreEtat,'String','');
                        this.variableActive= {};
                        this.variableEtatActive={};
                    end
                case 'evenement'
                    if N>0
                        set(this.hFenetreEvenement,'String',nomVariables,'Value',N);
                        this.variableEvenementActive=variablesRestantes{N};
                        this.variableActive=variablesRestantes{N};
                    else
                        set(this.hFenetreEvenement,'String','');
                        this.variableActive= {};
                        this.variableEvenementActive={};
                    end
            end
            
            this.MiseAJour2ListBoxModalites();
            
            
        end
        function listBoxVariableCallback(this, source, eventdata)
            
            
            % on test si un element a bien été selectionné (liste non vide)
            typeVar=get(source,'userdata');
            
            switch typeVar
                case 'etat'
                    indexlistBoxVariable=get(this.hFenetreEtat,'Value');
                    if ~isempty(indexlistBoxVariable)
                        allVariablesEtat = this.familleActive.getAllVariablesEtat();
                        this.variableEtatActive = allVariablesEtat{indexlistBoxVariable};
                        this.variableActive = this.variableEtatActive;
                    end
                    
                case 'evenement'
                    indexlistBoxVariable=get(this.hFenetreEvenement,'Value');
                    if ~isempty(indexlistBoxVariable)
                        allVariablesEvenement = this.familleActive.getAllVariablesEvenement();
                        this.variableEvenementActive = allVariablesEvenement{indexlistBoxVariable};
                        this.variableActive = this.variableEvenementActive;
                    end
            end
            this.MiseAJour2ListBoxModalites();
            % changer affichage modalité
            
            
        end
        function editerVariableCallback(this, source, eventdata)
            
            typeVar=get(source,'userdata');
            switch  typeVar
                case 'etat'
                    index = get(this.hFenetreEtat,'Value');
                    nom = this.variableEtatActive.getName();
                    comment= this.variableEtatActive.getComments();
                case 'evenement'
                    index = get(this.hFenetreEvenement,'Value');
                    nom = this.variableEvenementActive.getName();
                    comment= this.variableEvenementActive.getComments();
            end
            prompt={'Nom  de la  variable :','Commentaire:'};
            
            def = {char(nom),char(comment)};
            answer = inputdlg(prompt,'',1,def);
            if ~isempty(answer)
                if ~isempty(answer{1})
                    a = char(answer{1});
                    % changer nom famille active
                    switch  typeVar
                        case 'etat'
                            setName(this.variableEtatActive,a);
                        case 'evenement'
                            setName(this.variableEvenementActive,a);
                    end
                end
                if ~isempty(answer(2))
                    b= char(answer(2));
                    % changer commentaire famille active
                    
                    switch  typeVar
                        case 'etat'
                            setComments(this.variableEtatActive,b);
                        case 'evenement'
                            setComments(this.variableEvenementActive,b);
                    end
                end
                %mise a jour de la listebox variables etat
                switch  typeVar
                    case 'etat'
                        Variables = this.familleActive.getAllVariablesEtat();
                        N = length(Variables);
                    case 'evenement'
                        Variables = this.familleActive.getAllVariablesEvenement();
                end
                N = length(Variables);
                nomVariables = cell(1,N);
                for i=1:1:N
                    nomVariables{i} =Variables{i}.getName();
                end
                % on recharge et on selectionne avec la famille
                % editée
                % element
                switch  typeVar
                    case 'etat'
                        set(this.hFenetreEtat,'String',nomVariables,'Value',index);
                    case 'evenement'
                        set(this.hFenetreEvenement,'String',nomVariables,'Value',index);
                end
                %  A VOIR contrôler que le nom n'existe pas
            end

        end

        function listeVar = majListe(this,liste)
            listeVar = {};
            for i=1:length(liste)
                a = liste(i);
                
                listeVar = [listeVar a];
            end
            
            listeVar = listeVar';
        end
        function ajouterModaliteCallback (this, source, eventdata)
            % pour creer des familles un protocole actif doit exister
            
            if ~isempty(this.protocoleActif)
                
                if ~isempty (this.familleActive)
                    if ~isempty (this.variableActive)
                        %nomdef= this.variableActive.getType;
                        %nomdef= char(get(source,'userdata'));
                        %def = {nomdef,''};
                        
                        prompt={'Nom  de la  modalite :','valeur:'};
                        %answer = inputdlg(prompt,'',1,def);
                        answer=inputdlg(prompt);
                        
                        if ~isempty(answer)
                            if ~isempty(answer{1})
                                existencenomModalite=verifierExistenceNomModalite(this,answer{1});
                                
                                if ~(existencenomModalite )
                                    valeur = answer{2};
                                    % if ~isempty(answer{2})
                                    % ajout du nom de package
                                    name = char(answer{1});
                                    
                                    if  isempty(valeur)
                                        h= errordlg('il faut indiquer la valeur de la modalité');
                                        uiwait(h);
%                                        prompt={'La  modalite doit avoir une valeur'};
%                                        answer=inputdlg(prompt);
%                                        if ~isempty(answer)
%                                        valeur = answer{1};
%                                        end;
                                        set(source,'userdata',answer{1});
                                        ajouterModaliteCallback (this, source, eventdata)
                                        set(source,'userdata','');
                                        
                                    end
                                    
                                    %b= char(answer(2));
                                    %a.setValue(b);
                                    if  ~isempty(valeur)
                                        a = fr.lescot.bind.coding.Modality(name);
                                        a.setName(name);
                                        
                                        a.setValue(valeur);
                                        this.variableActive.addModality(a);
                                        nouvellesModalites = this.variableActive.getAllModalities();
                                        
                                        N = length(nouvellesModalites);
                                        
                                        nomsModalites = cell(1,N);
                                        valeursModalites = cell(1,N);
                                        for i=1:1:N
                                            nomsModalites{i} = nouvellesModalites{i}.getName();
                                            valeursModalites{i}=nouvellesModalites{i}.getValue();
                                        end
                                        
                                        
                                        %mettre à jour les
                                        %listbox modalites
                                        set(this.hFenetreNomModalite,'String',nomsModalites,'Value',N);
                                        set(this.hFenetreValeurModalite,'String',valeursModalites,'Value',N);
                                        % mettre à jour modalite
                                        % active
                                        this.modaliteActive = nouvellesModalites{N};
                                        
                                    end
                                    
                                    
                                    
                                    %                                            else errordlg('La modalité doit avoir une valeur ');
                                    %                                            end;
                                else
                                    errordlg('Ce nom est déjà utilisé');
                                    
                                end
                            end
                        end
                    else
                        errordlg('Aucune variable active')
                    end

                else
                    errordlg('Aucune famille active')
                end
            else
                errordlg('Aucun protocole actif')
            end
            
        end
        function supprimerModaliteCallback (this, source, eventdata)
            
            
            modaliteASupprimer = this.modaliteActive ;
            
            this.variableActive.removeModality(modaliteASupprimer);
            
            modalitesRestantes= this.variableActive.getAllModalities();
            
            N = length(modalitesRestantes);
            if (N>0)
                
                nomsModalites = cell(1,N);
                valeursModalites = cell(1,N);
                for i=1:1:N
                    nomsModalites{i} = char(modalitesRestantes{i}.getName());
                    valeursModalites{i} = char(modalitesRestantes{i}.getValue());
                end
                set(this.hFenetreNomModalite,'String',nomsModalites,'Value',N);
                set(this.hFenetreValeurModalite,'String',valeursModalites,'Value',N);
                this.modaliteActive=modalitesRestantes(N);
                
                
            else
                set(this.hFenetreNomModalite,'String','');
                set(this.hFenetreValeurModalite,'String','');
                
            end
            
            
            
            
        end
        function editerModaliteCallback (this, source, eventdata)
            %%%%%%%%%%% A CREERerrordlg('Déja existant','Erreur');
            %%%%% test si commentaire et nom non modifiés
            index = get(this.hFenetreNomModalite,'Value');
            prompt={'Nom  de la  modalite :','Valeur:'};
            nom = this.modaliteActive.getName();
            valeur= this.modaliteActive.getValue();
            def = {char(nom),char(valeur)};
            answer = inputdlg(prompt,'',1,def);
            % verifier answer pour mise à jour
            
            
            if ~isempty(answer)
                if ~isempty(answer{1})
                    a = char(answer{1});
                    % changer nom nom active
                    set(this.hFenetreNomModalite,'String',answer{1},'Value',index);
                    this.modaliteActive.setName(a);
                end
                if ~isempty(answer(2))
                    b= char(answer(2));
                    set(this.hFenetreValeurModalite,'String',answer{2},'Value',index);
                    % changer valeur modalite active
                    this.modaliteActive.setValue(b);
                end
                %  A VOIR contrôler que le nom n'existe pas
            end
            %mise a jour des listbox modalites
            Modalites = this.variableActive.getAllModalities();
            N = length(Modalites);
            nomsModalites = cell(1,N);
            valeursModalites = cell(1,N);
            for i=1:1:N
                nomModalites{i} = Modalites{i}.getName();
                valeursModalites{i} = Modalites{i}.getValue();
            end
            % on recharge et on selectionne avec la
            % modalite
            % editée
            
            set(this.hFenetreNomModalite,'String',nomModalites,'Value',index);
            set(this.hFenetreValeurModalite,'String',valeursModalites,'Value',index);
            
            %mettre à jour index listbox
            %set(this.hFenetreFamille,'Value',index);
            
        end
        function listBoxModaliteCallback(this, source, eventdata)
            
            fenetreModalite=get(source,'userdata');
            
            switch fenetreModalite
                case 'Nom'
                    indexlistBox=get(this.hFenetreNomModalite,'Value');
                case 'Valeur'
                    indexlistBox=get(this.hFenetreValeurModalite,'Value');
            end
            if ~isempty(indexlistBox)
                allModalites = this.variableActive.getAllModalities();
                this.modaliteActive = allModalites{indexlistBox};
            end
            %              switch fenetreModalite
            %                  case 'Nom'
            set(this.hFenetreValeurModalite,'Value',indexlistBox);
            %                  case 'Valeur'
            set(this.hFenetreNomModalite,'Value',indexlistBox)
            %              end
            
        end
        function modeAffichageCallback(this, source, eventdata)
            choix = get (source,'SelectedObject');
            switch  get(choix,'Tag')
                case  'RadiobuttonAffichageColonnes'
                    this.modeAffichage = 'colonnes';
                    
                case 'RadiobuttonAffichageLignes'
                    this.modeAffichage = 'lignes';
                    
                case 'RadiobuttonAffichagePersonnalise'
                    this.modeAffichage = 'personnalise';
            end
            
        end
        function out= verifierExistenceNomModalite(this,nomSaisi)
            % liste des modalites de la variable selectionnée
            listeModalitesVariableActive=this.variableActive.getAllModalities;
            out=0;
            % voir si le nom choisi existe déjà
            for i=1:length(listeModalitesVariableActive)
                a = listeModalitesVariableActive{i};
                nomModalite = char(getName(a));
                b= char(nomSaisi);
                if (strcmp(nomModalite, b))
                    % retourne 1 si le nom existe dejà
                    out=1;
                end
            end
            
        end
        
        
        %% MISES A JOUR DES LIST BOX
        function MiseAJour2ListBoxFamilles(this, source, eventdata) %%%%%%%%%%%%%%%%%%%A FINIR
            
            if isempty(this.protocoleActif )
                nbfamilles = 0;
            else
                listefamilles=this.protocoleActif.getAllFamilies();
                nbfamilles = length(listefamilles);
            end
            if nbfamilles >0
                nomsFamilles = cell(1,nbfamilles);
                for i=1:1:nbfamilles
                    nomsFamilles{i} = listefamilles{i}.getName();
                end
                set(this.hFenetreFamille,'string',nomsFamilles,'value',1);
                this.familleActive = listefamilles{1};
            else
                set(this.hFenetreFamille,'string','');
                this.familleActive = {};
            end
            
        end
        
        function MiseAJour2ListBoxVariables(this, source, eventdata)
            
            if isempty(this.familleActive )
                nbvar = 0;
            else
                listevar=this.familleActive.getAllVariables();
                nbvar = length(listevar);
            end
            if nbvar >0
                listevaretat= this.familleActive.getAllVariablesEtat();
                
                nbVarEtat = length(listevaretat);
                if nbVarEtat>0
                    nomsVariables = cell(1,nbVarEtat);
                    for i=1:1:nbVarEtat
                        nomsVariables{i} = listevaretat{i}.getName();
                    end
                    set(this.hFenetreEtat,'string',nomsVariables,'value',1);
                    this.variableEtatActive=listevaretat{1} ;
                else
                    set(this.hFenetreEtat,'string','');
                    this.variableEtatActive = {};
                end
                
                listevarevenement= this.familleActive.getAllVariablesEvenement();
                nbVarEvenement = length(listevarevenement);
                if nbVarEvenement>0
                    nomsVariables = cell(1,nbVarEvenement);
                    for i=1:1:nbVarEvenement
                        nomsVariables{i} = listevarevenement{i}.getName();
                    end
                    set(this.hFenetreEvenement,'string',nomsVariables,'value',1);
                    this.variableEvenementActive=listevarevenement{1} ;
                else
                    set(this.hFenetreEvenement,'string','');
                    this.variableEvenementActive = {};
                end
                if nbVarEtat>0
                    
                    this.variableActive= listevaretat{1};
                    %    set(this.hFenetreEtat,'SelectionHighlight','on');
                    
                    % %                     if nbVarEvenement>0
                    % %                      set(this.hFenetreEvenement,'value',1);
                    % %                     end
                else
                    if nbVarEvenement>0
                        
                        
                        this.variableActive= listevarevenement{1};
                        % set(this.hFenetreEvenement,'SelectionHighlight','on');
                        
                    end
                end
            else
                this.variableActive=  {};
                set(this.hFenetreEvenement,'string','');
                set(this.hFenetreEtat,'string','');
                this.variableEtatActive = {};
                this.variableEvenementActive = {};
            end
            
            
        end
        function MiseAJour2ListBoxModalites(this, source, eventdata)
            if isempty(this.variableActive)
                N = 0;
            else
                listemodalites= this.variableActive.getAllModalities();
                
                N = length(listemodalites);
            end
            if N>0
                nomsModalites = cell(1,N);
                valeursModalites = cell(1,N);
                for i=1:1:N
                    nomsModalites{i} = listemodalites{i}.getName();
                    valeursModalites{i} = listemodalites{i}.getValue();
                end
                set(this. hFenetreNomModalite,'string',nomsModalites,'value',1);
                set(this. hFenetreValeurModalite,'string',valeursModalites,'value',1);
                this.modaliteActive = listemodalites{1};
            else
                set(this. hFenetreNomModalite,'string','');
                set(this. hFenetreValeurModalite,'string','');
                this.modaliteActive = {};
                
            end

        end
    end
    
end
