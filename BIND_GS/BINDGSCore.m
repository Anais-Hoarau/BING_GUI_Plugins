function BINDGSCore
%% Closing BIND-GS

% This function is called if the user tries to close any of the windows.
% We need to put set(figure,'CloseRequestFcn',@tryToClose)

    function tryToClose(src,callbackdata)
        
        if askBeforeClosing
            % Close request function
            % to display a question dialog box
            notAskAg = 'Yes, don'+"'"+'t ask again';
            
            selection = questdlg('Close BIND-GS?',...
                'Close',...
                'Yes','No',notAskAg,'Yes');
            switch selection
                case 'Yes'
                    delete(f);
                    delete(gui);
                case 'No'
                    return
                case notAskAg
                    delete(f);
                    delete(gui);
                     % Useless, but wil be useful once there is a config
                     % file
                    askBeforeClosing = 0;
            end
        else
            delete(f);
            delete(gui);
        end
    end

%% Creating the xml file

docNode = com.mathworks.xml.XMLUtils.createDocument('BIND-GS');
docRootNode = docNode.getDocumentElement;

%% GUI window creation

gui = figure('units','pixels','Position',[200 300 300 600]);
set(gui,'Name','BIND-GS properties','NumberTitle','off');
set(gui,'CloseRequestFcn',@tryToClose);
X = uicontrol(gui,'Style','text', 'Units', 'pixels', 'Position',[100 500 100 20]);
Y = uicontrol(gui,'Style','text', 'Units', 'pixels', 'Position',[100 450 100 20]);
Xt = uicontrol(gui,'Style','text', 'Units', 'pixels', 'Position',[100 520 100 20]);
Yt = uicontrol(gui,'Style','text', 'Units', 'pixels', 'Position',[100 470 100 20]);

% Matlab supports custom cursors that contain black, white, or transparent
% pixels. I have created a method that converts any image into a cursor.
% The lightest thrid of pixels becomes white, the darkest third becomes
% black, and the other third becomes transparent.
% Please note that the pointer of custom cursors is on the top left corner
% and that their dimensions are 16x16 pixels. The custom image is resized
% to fit those dimensions so there may be distortion and/or loss.
% There is also the possibility of having cursors of 32x32 pixels.

cursor_grab1 = createCursorFrom('cursor_grab1.png');
cursor_grab2 = createCursorFrom('cursor_grab2.png');
cursor_hourglass = createCursorFrom('cursor_hourglass.png');
cursor_grab1_big = createBigCursorFrom('cursor_grab1.png');
cursor_grab2_big = createBigCursorFrom('cursor_grab2.png');
cursor_hourglass_big = createBigCursorFrom('cursor_hourglass.png');
cursor_test_big = createBigCursorFrom('test.png');
setCursor(gui,'arrow');
%setCursor(gui,cursor_test_big);

% Hide cursor
% setCursor(gui,NaN(16,16));

% Default cursors:
% 'circle', 'arrow'
% For example:
% setCursor(gui,'circle');

set(gui,'WindowButtonUpFcn',@guiReleaseClick);
set(gui,'WindowButtonDownFcn',@guiClick);

set(X, 'String', '0');
set(Y, 'String', '0');
set(Xt, 'String', 'Width:');
set(Yt, 'String', 'Height:');

%% GUI click event

    function guiClick(~,~)
        setCursor(gui,cursor_grab2);
    end

%% GUI release click event

    function guiReleaseClick(~,~)
        setCursor(gui,cursor_grab1);
    end

%% Converting cdata into pointer cdata

    function out = cdataToPointerShapeCData(cursor)
        % We are going to convert it into grayscale
        cursorDimensions = size(cursor);
        csize = cursorDimensions(1);
        grayscale = NaN([csize csize]);
        for i = 1:csize
            for j = 1:csize
                temp = round(0.2989*cursor(i,j,1) +...
                    0.5870*cursor(i,j,2) + 0.1140*cursor(i,j,3));
                grayscale(i,j) = temp;
            end
        end
        out = NaN([csize csize]);
        % Under 85, black pixel
        % Above 170, white pixel
        % Otherwise transparent
        for i = 1:csize
            for j = 1:csize
                temp = grayscale(i,j);
                if temp < 85
                    out(i,j) = 1;
                end
                if temp > 170
                    out(i,j) = 2;
                end
            end
        end
    end

%% Creating a cursor from an image (actually its PointerShapeCData)

    function out = createCursorFrom(image)
        cursorImg = imread(image);
        cursorImg2 = imresize(cursorImg, [16 16]);
        out = cdataToPointerShapeCData(cursorImg2);
    end

%% Creating a big cursor from an image (actually its PointerShapeCData)

    function out = createBigCursorFrom(image)
        cursorImg = imread(image);
        cursorImg2 = imresize(cursorImg, [32 32]);
        out = cdataToPointerShapeCData(cursorImg2);
    end

%% Setting a cursor

    function setCursor(gui,cursor)
        if ischar(cursor)
            set(gui, 'pointer', cursor);
        else
            set(gui, 'pointer', 'custom', 'PointerShapeCData', cursor)
        end
    end

%% Editing the toolbar

    function editGUIToolbar()
        gui.ToolBar = 'figure';    % Hide the standard toolbar
        %tbh = uitoolbar(gui);    % Create a new empty toolbar
        
        % We are using the standard toolbar, but we remove everything that is
        % not useful. We can then add our own icons to this toolbar.
        a = findall(gcf);
        removeTools = ["Show Plot Tools","Hide Plot Tools","Save Figure",...
            "Open File","New Figure","Insert Legend","Insert Colorbar",...
            "Data Cursor","Rotate 3D","Pan","Zoom Out","Zoom In",...
            "Edit Plot","Link Plot","Show Plot Tools and Dock Figure",...
            "Brush/Select Data"];
        remToolsDim = size(removeTools);
        for counter = 1:remToolsDim(2)
            b = findall(a,'ToolTipString',removeTools(counter));
            set(b,'Visible','Off','Separator','off');
        end
    end

editGUIToolbar();

%% Editing the menubar

    function editGUIMenuBar()
        
        % Once a functionnality has been added, we can remove the
        % 'Enable','off' parameter from the corrseponding menu item.
        
        set(gui, 'MenuBar', 'none'); % Disable the standard one
        
        % The accelerator parameter is a shortcut key: ctrl + parameter
        % Enable off makes us unable to click on this item
        % Label is the name that the user sees
        
        menuFile = uimenu(gui,'Label','File'); % Create a menu called file
        menuFile_New = uimenu(menuFile,'Label','New','Accelerator',...
            'N','Enable','off');
        menuFile_Open = uimenu(menuFile,'Label','Open..','Accelerator',...
            'O','Enable','off');
        menuFile_Close = uimenu(menuFile,'Label','Close','Accelerator',...
            'W','Enable','off');
        
        menuFile_Save = uimenu(menuFile,'Label','Save','Accelerator',...
            'S','Enable','off');
        menuFile_Save.Separator = 'on';
        menuFile_SaveAs = uimenu(menuFile,'Label','Save as..',...
            'Enable','off');
        
        menuFile_ExportCode = uimenu(menuFile,'Label','Export code',...
            'Accelerator','E','Enable','off');
        menuFile_ExportCode.Separator = 'on';
        menuFile_ExportCodeAs = uimenu(menuFile,'Label','Export code as..',...
            'Enable','off');
        menuFile_RunCode = uimenu(menuFile,'Label','Run code',...
            'Accelerator','R','Enable','off');
        
        menuFile_PrintPreview = uimenu(menuFile,'Label','Print preview',...
            'Enable','off');
        menuFile_PrintPreview.Separator = 'on';
        menuFile_Print = uimenu(menuFile,'Label','Print','Accelerator',...
            'P','Enable','off');
        
        menuHelp = uimenu(gui,'Label','Help'); % Create a menu called help
        menuHelp_UserManual = uimenu(menuHelp,'Label','User manual',...
            'Enable','off');
        menuHelp_Contact = uimenu(menuHelp,'Label','Contact',...
            'Enable','off');
    end

editGUIMenuBar();

%% Variable definition

% Ask before closing 1 = yes, 0 = no
askBeforeClosing = 0;

% Ask before deleting a block 1 = yes, 0 = no
askBeforeDeleting = 0;

% Careful, the minimum block width is defined by:
% x_left_of_tooth + tooth_width + indentation
%      30         +     30      +     30     = 90 for example
indentation = 30;

% highlightThickness is the thickness of the outline on highlighted blocks
% multiples of 0.5 work fine
highlightThickness = 2.5;

% The currently selected block (0 = none)
currentSelectedBlock = 0;

% How spaced apart blocks are when they are attached together.
% This is good for being able to differenciate multiple blocks of the same
% colour. Must be an integer or the blocks will look strange.
blockSpacing = 2;

dragging = [];
draggingObject = [];
orPos = [];

% Colours are defined by rgb values between 0 and 1.
% If you have a conventionnal rgb value, type it and add ' / 255 '
blue1 = [.3 .4 1];
red1 = [1 .3 .4];
green1 = [.4 1 .3];
blue2 = [175/255, 220/255, 255/255];
red2 = [255/255, 175/255, 176/255];
green2 = [176/255, 255/255, 175/255];
black = [0 0 0];
white = [1 1 1];

numberOfColors = 30;

%defaultColors = jet(numberOfColors);% allright, blue to red
%defaultColors = rand(numberOfColors, 3);% Allright colours that change at
%every startup.
%defaultColors = hsv(numberOfColors);% nice colours but lively
%defaultColors = hot(numberOfColors);% nice but limited range of colours,
%dark
%defaultColors = cool(numberOfColors);% allright, blue to pink
%defaultColors = spring(numberOfColors);% can hurt your eyes a little
%defaultColors = summer(numberOfColors);% soft colours
%defaultColors = autumn(numberOfColors);% can hurt your eyes
%defaultColors = winter(numberOfColors);% allright
defaultColors = lines(numberOfColors);% nice colours, does not depend on the number of colours
%defaultColors = gray(numberOfColors);% black to white, not great
%defaultColors = bone(numberOfColors);% black to white with blueish grays
%defaultColors = copper(numberOfColors);% coffee, mocha, hot
%chocolate, cream, etc
%defaultColors = pink(numberOfColors);% soft colours

f = figure('WindowButtonUpFcn',@dropObject,'units','pixels');
set(f,'WindowButtonMotionFcn',@moveObject);
set(f,'Position',[500 300 800 600]);
set(f,'Name','BIND-GS','NumberTitle','off');
set(f,'CloseRequestFcn',@tryToClose);

% Highlight color options
% 1 = color stored in highlightDefaultColor
% 2 = White if the block is dark, and black if the block is light
% 3 = complementary colour
highlightType = 1;
highlightDefaultColor = black;

% Whether to lighten up the block colours or not if they are dark
% This is so we can se which block has been highlighted
% 0 = no, 1 = yes
doLightenBlocks = 1;
% If the blocks are lightened, their grayscale value will be above this
% coefficient.
lightenAbove = 0.45;
% Every time it is lightened, it is lightened by this coefficient
lightenStep = 0.96;

% Here are some variables that affect putting blocks into a group
% after a drag and drop.
overlapX = 100;
overlapY = 20;

%% Editing the toolbar

    function editToolbar()
        f.ToolBar = 'figure';    % Hide the standard toolbar
        %tbh = uitoolbar(f);    % Create a new empty toolbar
        
        % We are using the standard toolbar, but we remove everything that is
        % not useful. We can then add our own icons to this toolbar.
        a = findall(gcf);
        removeTools = ["Show Plot Tools","Hide Plot Tools","Save Figure",...
            "Open File","New Figure","Insert Legend","Insert Colorbar",...
            "Data Cursor","Rotate 3D","Pan","Zoom Out","Zoom In",...
            "Edit Plot","Link Plot","Show Plot Tools and Dock Figure",...
            "Brush/Select Data"];
        remToolsDim = size(removeTools);
        for counter = 1:remToolsDim(2)
            b = findall(a,'ToolTipString',removeTools(counter));
            set(b,'Visible','Off','Separator','off');
        end
    end

editToolbar();

%% Editing the menubar

    function editMenuBar()
        
        % Once a functionnality has been added, we can remove the
        % 'Enable','off' parameter from the corrseponding menu item.
        
        set(f, 'MenuBar', 'none'); % Disable the standard one
        
        % The accelerator parameter is a shortcut key: ctrl + parameter
        % Enable off makes us unable to click on this item
        % Label is the name that the user sees
        
        menuFile = uimenu(f,'Label','File'); % Create a menu called file
        menuFile_New = uimenu(menuFile,'Label','New','Accelerator',...
            'N','Enable','off');
        menuFile_Open = uimenu(menuFile,'Label','Open..','Accelerator',...
            'O','Enable','off');
        menuFile_Close = uimenu(menuFile,'Label','Close','Accelerator',...
            'W','Enable','off');
        
        menuFile_Save = uimenu(menuFile,'Label','Save','Accelerator',...
            'S','Enable','off');
        menuFile_Save.Separator = 'on';
        menuFile_SaveAs = uimenu(menuFile,'Label','Save as..',...
            'Enable','off');
        
        menuFile_ExportCode = uimenu(menuFile,'Label','Export code',...
            'Accelerator','E','Enable','off');
        menuFile_ExportCode.Separator = 'on';
        menuFile_ExportCodeAs = uimenu(menuFile,'Label','Export code as..',...
            'Enable','off');
        menuFile_RunCode = uimenu(menuFile,'Label','Run code',...
            'Accelerator','R','Enable','off');
        
        menuFile_PrintPreview = uimenu(menuFile,'Label','Print preview',...
            'Enable','off');
        menuFile_PrintPreview.Separator = 'on';
        menuFile_Print = uimenu(menuFile,'Label','Print','Accelerator',...
            'P','Enable','off');
        
        menuHelp = uimenu(f,'Label','Help'); % Create a menu called help
        menuHelp_UserManual = uimenu(menuHelp,'Label','User manual',...
            'Enable','off');
        menuHelp_Contact = uimenu(menuHelp,'Label','Contact',...
            'Enable','off');
    end

editMenuBar();

%% Retrieving a colour from the colour scheme

    function out = getColor(index)
        rout = defaultColors(index,1);
        gout = defaultColors(index,2);
        bout = defaultColors(index,3);
        out = [rout gout bout];
        if doLightenBlocks
            temp = 0.2989*out(1) + 0.5870*out(2) + 0.1140*out(3);
            while temp < lightenAbove
                rout = 1 - (1 - rout)*lightenStep;
                gout = 1 - (1 - gout)*lightenStep;
                bout = 1 - (1 - bout)*lightenStep;
                out = [rout gout bout];
                temp = 0.2989*out(1) + 0.5870*out(2) + 0.1140*out(3);
            end
        end
    end

%% Selecting a block

    function selectBlock(blockID)
        if currentSelectedBlock ~= 0
            blockDeselection(currentSelectedBlock);
        end
        currentSelectedBlock = blockID;
        blockSelection(blockID);
        refreshFromXml();
    end

%% The block selection part

    function blockSelection(blockID)
        node = getNode(blockID, docRootNode);
        nodeName = char(node.getNodeName);
        removeBlockVisual(blockID);
        width = char(node.getAttribute('x'));
        height = char(node.getAttribute('y'));
        set(X, 'String', width);
        set(Y, 'String', height);
        switch nodeName
            case 'left'
                leftHighlightFromNode(node);
            case 'right'
                rightHighlightFromNode(node);
            case 'double'
                doubleHighlightFromNode(node);
            case 'Rubbish_bin'
                rubbishBinHighlightFromNode(node);
            case 'if'
                ifHighlightFromNode(node);
            case 'else'
                elseHighlightFromNode(node);
            case 'end'
                endHighlightFromNode(node);
            otherwise
                linearHighlightFromNode(node);
        end
    end

%% The block deselection part

    function blockDeselection(blockID)
        node = getNode(blockID, docRootNode);
        nodeName = char(node.getNodeName);
        removeBlockVisual(blockID);
        switch nodeName
            case 'left'
                leftFromNode(node);
            case 'right'
                rightFromNode(node);
            case 'double'
                doubleFromNode(node);
            case 'Rubbish_bin'
                rubbishBinFromNode(node);
            case 'if'
                ifFromNode(node);
            case 'else'
                elseFromNode(node);
            case 'end'
                endFromNode(node);
            otherwise
                linearFromNode(node);
        end
    end

%% Creating blocks based on xml nodes
    function leftHighlightFromNode(node)
        blockID = str2num(node.getAttribute('blockID'));
        x = str2num(node.getAttribute('x'));
        y = str2num(node.getAttribute('y'));
        color = getColor(1);
        highlightColor = getHighlightColor(color);
        newLinearLeftWBorder(color,highlightColor,highlightThickness,...
            blockID,0,0,x,y);
    end
    function leftFromNode(node)
        blockID = str2num(node.getAttribute('blockID'));
        x = str2num(node.getAttribute('x'));
        y = str2num(node.getAttribute('y'));
        color = getColor(1);
        newLinearLeft(color,blockID,0,0,x,y);
    end
    function rightHighlightFromNode(node)
        blockID = str2num(node.getAttribute('blockID'));
        x = str2num(node.getAttribute('x'));
        y = str2num(node.getAttribute('y'));
        color = getColor(2);
        highlightColor = getHighlightColor(color);
        newLinearRightWBorder(color,highlightColor,highlightThickness,...
            blockID,0,0,x,y);
    end
    function rightFromNode(node)
        blockID = str2num(node.getAttribute('blockID'));
        x = str2num(node.getAttribute('x'));
        y = str2num(node.getAttribute('y'));
        color = getColor(2);
        newLinearRight(color,blockID,0,0,x,y);
    end
    function doubleHighlightFromNode(node)
        blockID = str2num(node.getAttribute('blockID'));
        x = str2num(node.getAttribute('x'));
        y = str2num(node.getAttribute('y'));
        color = getColor(4);
        highlightColor = getHighlightColor(color);
        newLinearDoubleWBorder(color,highlightColor,highlightThickness,...
            blockID,0,0,x,y);
    end
    function doubleFromNode(node)
        blockID = str2num(node.getAttribute('blockID'));
        x = str2num(node.getAttribute('x'));
        y = str2num(node.getAttribute('y'));
        color = getColor(4);
        newLinearDouble(color,blockID,0,0,x,y);
    end
    function linearHighlightFromNode(node)
        blockID = str2num(node.getAttribute('blockID'));
        x = str2num(node.getAttribute('x'));
        y = str2num(node.getAttribute('y'));
        color = getColor(3);
        highlightColor = getHighlightColor(color);
        newLinearWBorder(color,highlightColor,highlightThickness,...
            blockID,0,0,x,y);
    end
    function linearFromNode(node)
        blockID = str2num(node.getAttribute('blockID'));
        x = str2num(node.getAttribute('x'));
        y = str2num(node.getAttribute('y'));
        color = getColor(3);
        newLinear(color,blockID,0,0,x,y);
    end
    function rubbishBinHighlightFromNode(node)
        blockID = str2num(node.getAttribute('blockID'));
        x = str2num(node.getAttribute('x'));
        y = str2num(node.getAttribute('y'));
        color = getColor(7);
        highlightColor = getHighlightColor(color);
        newLinearWBorder(color,highlightColor,highlightThickness,...
            blockID,0,0,x,y);
        xoff = round(x/4);
        yoff = round(y/4);
        x = round(x/2);
        y = round(y/2);
        newImageBlock('rubbish_bin.png',blockID,xoff,yoff,x,y);
    end
    function rubbishBinFromNode(node)
        blockID = str2num(node.getAttribute('blockID'));
        x = str2num(node.getAttribute('x'));
        y = str2num(node.getAttribute('y'));
        color = getColor(7);
        newLinear(color,blockID,0,0,x,y);
        xoff = round(x/4);
        yoff = round(y/4);
        x = round(x/2);
        y = round(y/2);
        newImageBlock('rubbish_bin.png',blockID,xoff,yoff,x,y);
    end

%% Creating specific blocks from xml nodes
    function ifFromNode(node)
        rightFromNode(node);
        color = getColor(2);
        blockID = str2num(node.getAttribute('blockID'));
        blockY = str2num(node.getAttribute('y'));
        ifText = uipanel(f,'units','pixels','Title','If',...
            'Position',[blockSpacing blockY-15-blockSpacing 15 18],'BorderType','none',...
            'userdata',blockID,'ButtonDownFcn',@dragObject);
        set(ifText,'BackgroundColor',color);
    end
    function ifHighlightFromNode(node)
        rightHighlightFromNode(node);
        color = getColor(2);
        blockID = str2num(node.getAttribute('blockID'));
        blockY = str2num(node.getAttribute('y'));
        ifText = uipanel(f,'units','pixels','Title','If',...
            'Position',[blockSpacing blockY-15-blockSpacing 15 18],'BorderType','none',...
            'userdata',blockID,'ButtonDownFcn',@dragObject);
        set(ifText,'BackgroundColor',color);
    end
    function elseFromNode(node)
        doubleFromNode(node);
        color = getColor(4);
        blockID = str2num(node.getAttribute('blockID'));
        blockY = str2num(node.getAttribute('y'));
        ifText = uipanel(f,'units','pixels','Title','Else',...
            'Position',[blockSpacing blockY-15-blockSpacing 30 18],'BorderType','none',...
            'userdata',blockID,'ButtonDownFcn',@dragObject);
        set(ifText,'BackgroundColor',color);
    end
    function elseHighlightFromNode(node)
        doubleHighlightFromNode(node);
        color = getColor(4);
        blockID = str2num(node.getAttribute('blockID'));
        blockY = str2num(node.getAttribute('y'));
        ifText = uipanel(f,'units','pixels','Title','Else',...
            'Position',[blockSpacing blockY-15-blockSpacing 30 18],'BorderType','none',...
            'userdata',blockID,'ButtonDownFcn',@dragObject);
        set(ifText,'BackgroundColor',color);
    end
    function endFromNode(node)
        leftFromNode(node);
        color = getColor(1);
        blockID = str2num(node.getAttribute('blockID'));
        blockY = str2num(node.getAttribute('y'));
        ifText = uipanel(f,'units','pixels','Title','End',...
            'Position',[blockSpacing blockY-15-blockSpacing 30 18],'BorderType','none',...
            'userdata',blockID,'ButtonDownFcn',@dragObject);
        set(ifText,'BackgroundColor',color);
    end
    function endHighlightFromNode(node)
        leftHighlightFromNode(node);
        color = getColor(1);
        blockID = str2num(node.getAttribute('blockID'));
        blockY = str2num(node.getAttribute('y'));
        ifText = uipanel(f,'units','pixels','Title','End',...
            'Position',[blockSpacing blockY-15-blockSpacing 30 18],'BorderType','none',...
            'userdata',blockID,'ButtonDownFcn',@dragObject);
        set(ifText,'BackgroundColor',color);
    end

%% Get the highlight colour depending on the configuration settings

    function out = getHighlightColor(color)
        switch highlightType
            case 1
                out = highlightDefaultColor;
                return
            case 2
                temp = 0.2989*color(1) + 0.5870*color(2) + 0.1140*color(3);
                if temp > 0.5
                    out = black;
                    return
                end
                out = white;
                return
            case 3
                % Get the complementary colour
                out = [1 1 1]- color;
                return
        end
        out = highlightDefaultColor;
    end

%% define what blocks to drag

    function setDragGroup(blockID)
        % We load all of the elements into a temporary variable
        temp = findall(f);
        
        % We initialize a counter to keep track of the amount of elements
        n = 1;
        
        % We load all of the blockIDs of this block's siblings and their
        % children into a list so that we can drag them all like in
        % the solitaire card game: We drag all of the cards that are
        % under the card we are dragging.
        node = getNode(blockID,docRootNode);
        blockIDs = getDragIDs(node);
        
        % We want to remove the blocks we are dragging into a new group
        % node located at the root of the xml file.
        xmlRelocate(blockID);
        
        for i = 1:size(temp)
            % We load the i-eth object into a variable
            tempObj = temp(i);
            % We load its user data
            tempData = get(tempObj,'UserData');
            % We check it has user data
            if size(tempData)> 0
                % We check if this object is part of the objects we want
                % to drag
                % The size function returns the size of a table.
                % What interests us is the number of lines, not columns.
                % That's why we take the second element in the for loop.
                dimTemp = size(blockIDs);
                dimensions = dimTemp(2);
                for j = 1:dimensions
                    comparisonID = str2double(blockIDs(j));
                    if tempData == comparisonID
                        % We add it as the n-eth element
                        dragging{n} = tempObj;
                        n = n+1;
                    end
                end
            end
        end
    end

%% Initiate dragging

    function dragObject(hObject,~)
        
        userData = get(hObject, 'UserData');
        
        % Check whether it is a left or right click
        
        figHandle = ancestor(hObject, 'figure');
        clickType = get(figHandle, 'SelectionType');
        
        if strcmp(clickType, 'alt') % Right click
            selectBlock(userData);
        end
        if strcmp(clickType, 'normal') % Left click
            
            draggingObject = userData(1);
        
            setDragGroup(draggingObject);
       
            orPos = get(gcf,'CurrentPoint');
        end
    end

%% Stop dragging

    function dropObject(~,~)
        
        if ~isempty(dragging)
            
            newPos = get(gcf,'CurrentPoint');
            
            posDiff = newPos - orPos;
            
            % We want to find the highest placed rectangle (we take into
            % account its height) in order to store the coordinate into
            % the xml group node.
            highestPos = -999999;
            x = 999999;
            dim = size(dragging);
            % We only want to take into account the first block because
            % blocks that are further left will change the x coordinate.
            % To do this, we get the node of one of the blocks, then get
            % the group node, then get the first valid child (top block).
            object = dragging{1};
            tempBlockID = get(object,'UserData');
            tempChildNode = getNode(tempBlockID, docRootNode);
            tempGroupNode = getGroupNode(tempChildNode);
            tempChildNode = tempGroupNode.getFirstChild;
            while ~isempty(tempChildNode)
                tempBlockID = tempChildNode.getAttribute('blockID');
                if ~strcmp('',tempBlockID)
                    break;
                end
            end
            
            for i = 1:dim(2)
                % Select the object and move it for the last time
                object = dragging{i};
                blockID = get(object,'UserData');
                if  strcmp(tempBlockID,int2str(blockID))
                    set(object,'Position',get(object,'Position')...
                        + [posDiff(1:2) 0 0]);
                    % Retrieve the object's coordinates (including size).
                    pos = get(object,'Position');
                    y = pos(2) + pos(4);
                    % We want the top left coordinate, so we correct the
                    % values whenever a better one is found.
                    if y > highestPos
                        highestPos = y;
                    end
                    if pos(1) < x
                        x = pos(1);
                    end
                end
            end
            
            % We are modifying the group node's coordinates so that they
            % match with the new ones.
            object = dragging{1};
            blockID = get(object,'UserData');
            childNode = getNode(blockID, docRootNode);
            groupNode = getGroupNode(childNode);
            groupNode.setAttribute('x',int2str(x));
            groupNode.setAttribute('y',int2str(highestPos));
            
            slotInGroup(groupNode);
            
            dragging = [];
            draggingObject = [];
            refreshFromXml();
        end
        
    end

%% Get the x offset on the top depending on the type of block

    function out = getOffsetTop(node)
        strNodeName = node.getNodeName;
        charNodeName = char(strNodeName);
        switch charNodeName
            case {'right','if'}
                out = 0;
            case {'left','end'}
                out = -indentation;
            case {'double','else'}
                out = -indentation;
            otherwise
                out = 0;
        end
    end

%% Get the x offset on the bottom depending on the type of block

    function out = getOffsetBottom(node)
        strNodeName = node.getNodeName;
        charNodeName = char(strNodeName);
        switch charNodeName
            case {"right",'if'}
                out = indentation;
            case {"left",'end'}
                out = 0;
            case {"double",'else'}
                out = indentation;
            otherwise
                out = 0;
        end
    end

%% Slot a group into another one if it is close enough

    function slotInGroup(groupNode)
        node = groupNode.getFirstChild;
        offsetX = getOffsetTop(node);
        temp = com.mathworks.xml.XMLUtils.createDocument...
            ('temp_group');
        x = str2num(groupNode.getAttribute('x'))-offsetX;
        node = findOverlap(num2str(x),...
            groupNode.getAttribute('y'), temp);
        % This part checks if we have slotted our group onto the rubbish
        % bin. If so, we delete it.
        nodeName = node.getNodeName();
        if nodeName == 'Rubbish_bin'
            if tryToDelete() == 1
                dragging = [];
                deleteIds = getDragIDs(groupNode.getFirstChild);
                deleteSize = size(deleteIds);
                for delCounter = 1:deleteSize(2)
                    strId = deleteIds{delCounter};
                    intId = str2num(strId);
                    if currentSelectedBlock == intId
                        blockDeselection(currentSelectedBlock);
                        currentSelectedBlock = 0;
                    end
                    removeBlock(intId);
                end
            end
        end
        if (node ~= temp) && (node ~= groupNode)
            % Inside this statement, node must be a child of a group
            % node, otherwise nodes will be inserted outside of group
            % nodes.
            insertNode = node.getNextSibling;
            if ~isempty(insertNode)
                temp = groupNode.getFirstChild;
                moveXmlChainBefore(temp, insertNode);
            else
                temp = groupNode.getFirstChild;
                appendNode = node;
                if(node.getNodeName() ~= 'group')
                    appendNode = getGroupNode(node);
                end
                moveXmlChain(temp, appendNode);
            end
        end
    end

%% Ask to delete

    function out = tryToDelete()
        
        if askBeforeDeleting
            % Close request function
            % to display a question dialog box
            notAskAg = 'Yes, don'+"'"+'t ask again';
            
            selection = questdlg('Delete block(s)?',...
                'Delete',...
                'Yes','No',notAskAg,'Yes');
            switch selection
                case 'Yes'
                    out = 1;
                    return
                case 'No'
                    out = 0;
                    return
                case notAskAg
                    out = 1;
                    askBeforeDeleting = 0;
                    return
            end
        else
            out = 1;
        end
    end


%% Find a node that overlaps with our group

    function out = findOverlap(x, y, temp)
        out = temp;
        groupNode = docRootNode.getFirstChild;
        while ~isempty(groupNode)
            posx = str2num(groupNode.getAttribute('x'));
            posy = str2num(groupNode.getAttribute('y'));
            offsetY = 0;
            offsetX = 0;
            empty = '';
            if ~strcmp(posx, empty)
                childNode = groupNode.getFirstChild;
                while ~isempty(childNode)
                    offsetY = offsetY + blockSpacing +...
                        str2num(childNode.getAttribute('y'));
                    offsetX = offsetX + getOffsetBottom(childNode);
                    searchy = posy - offsetY;
                    searchx = posx + offsetX;
                    if isOverlap(searchx, searchy, str2num(x), str2num(y)) == 1
                        out = childNode;
                        return
                    end
                    childNode = childNode.getNextSibling;
                end
            end
            groupNode = groupNode.getNextSibling;
        end
    end

%% Check if there is an overlap in the coordinates

    function out = isOverlap(x1, y1, x2, y2)
        left = x1 - overlapX;
        right = x1 + overlapX;
        top = y1 - overlapY;
        bottom = y1 + overlapY;
        if (left < x2)
            if (right > x2)
                if (top < y2)
                    if (bottom > y2)
                        out = 1;
                        return
                    end
                end
            end
        end
        out = 0;
    end

%% Drag

    function moveObject(~,~)
        
        if ~isempty(dragging)
            
            newPos = get(gcf,'CurrentPoint');
            
            posDiff = newPos - orPos;
            
            orPos = newPos;
            
            % The size function returns the size of a table.
            % What interests us is the number of lines, not columns.
            % That's why we take the second element in the for loop.
            dimensions = size(dragging);
            
            for i = 1:dimensions(2)
                object = dragging{i};
                set(object,'Position',get(object,'Position')...
                    + [posDiff(1:2) 0 0]);
            end
            
        end
        
    end

%% Linear block creation

    function newLinear(color,userdata,posx,posy,width,height)
        if ~exist('width','var'), width = 500; end
        if ~exist('height', 'var'), height = 85; end
        % This block of code adds rectangles to the scene
        bottom_tooth_panel = uipanel(f,'units','pixels','Title','',...
            'Position',[posx+30 posy+0 30 15],'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        middle_panel = uipanel(f,'units','pixels','Title','',...
            'Position',[posx+0 posy+15 width height-15],'BorderType',...
            'none','userdata',userdata,'ButtonDownFcn',@dragObject);
        top_left_panel = uipanel(f,'units','pixels','Title','',...
            'Position',[posx+0 posy+height 30-blockSpacing 15],...
            'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        top_right_panel = uipanel(f,'units','pixels','Title','',...
            'Position',...
            [posx+60+blockSpacing posy+height width-60-blockSpacing 15],...
            'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        
        % This block of code colours the rectangles we just added
        hObject = bottom_tooth_panel;
        set(hObject,'BackgroundColor',color);
        hObject = middle_panel;
        set(hObject,'BackgroundColor',color);
        hObject = top_left_panel;
        set(hObject,'BackgroundColor',color);
        hObject = top_right_panel;
        set(hObject,'BackgroundColor',color);
        
    end

%% Linear block creation

    function newLinearWBorder(color1,color2,thickness,userdata,posx,posy,width,height)
        if ~exist('width','var'), width = 500; end
        if ~exist('height', 'var'), height = 85; end
        
        newLinear(color2,userdata,posx,posy,width,height);
        
        dth = 2*thickness;
        
        % This block of code adds rectangles to the scene
        bottom_tooth_panel = uipanel(f,'units','pixels','Title','',...
            'Position',...
            [posx+30+thickness posy+thickness 30-dth 15],...
            'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        middle_panel = uipanel(f,'units','pixels','Title','',...
            'Position',...
            [posx+thickness posy+15+thickness width-dth height-15-dth],...
            'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        top_left_panel = uipanel(f,'units','pixels','Title','',...
            'Position',...
            [posx+thickness posy+height-thickness 30-dth-blockSpacing 15],...
            'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        top_right_panel = uipanel(f,'units','pixels','Title','',...
            'Position',...
            [posx+60+thickness+blockSpacing posy+height-thickness width-60-dth-blockSpacing 15],...
            'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        
        % This block of code colours the rectangles we just added
        hObject = bottom_tooth_panel;
        set(hObject,'BackgroundColor',color1);
        hObject = middle_panel;
        set(hObject,'BackgroundColor',color1);
        hObject = top_left_panel;
        set(hObject,'BackgroundColor',color1);
        hObject = top_right_panel;
        set(hObject,'BackgroundColor',color1);
        
    end

%% Linear block creation

    function newLinearRight(color,userdata,posx,posy,width,height)
        if ~exist('width','var'), width = 500; end
        if ~exist('height', 'var'), height = 85; end
        % This block of code adds rectangles to the scene
        bottom_tooth_panel = uipanel(f,'units','pixels','Title','',...
            'Position',[posx+30+indentation posy+0 30 15],'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        middle_panel = uipanel(f,'units','pixels','Title','',...
            'Position',[posx+0 posy+15 width height-15],'BorderType',...
            'none','userdata',userdata,'ButtonDownFcn',@dragObject);
        top_left_panel = uipanel(f,'units','pixels','Title','',...
            'Position',[posx+0 posy+height 30-blockSpacing 15],'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        top_right_panel = uipanel(f,'units','pixels','Title','',...
            'Position',[posx+60+blockSpacing posy+height width-60-blockSpacing 15],'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        
        % This block of code colours the rectangles we just added
        hObject = bottom_tooth_panel;
        set(hObject,'BackgroundColor',color);
        hObject = middle_panel;
        set(hObject,'BackgroundColor',color);
        hObject = top_left_panel;
        set(hObject,'BackgroundColor',color);
        hObject = top_right_panel;
        set(hObject,'BackgroundColor',color);
        
    end

%% Linear block creation

    function newLinearRightWBorder(color1,color2,thickness,userdata,posx,posy,width,height)
        if ~exist('width','var'), width = 500; end
        if ~exist('height', 'var'), height = 85; end
        
        newLinearRight(color2,userdata,posx,posy,width,height);
        
        dth = 2*thickness;
        
        % This block of code adds rectangles to the scene
        bottom_tooth_panel = uipanel(f,'units','pixels','Title','',...
            'Position',...
            [posx+30+indentation+thickness posy+thickness 30-dth 15],...
            'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        middle_panel = uipanel(f,'units','pixels','Title','',...
            'Position',...
            [posx+thickness posy+15+thickness width-dth height-15-dth],...
            'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        top_left_panel = uipanel(f,'units','pixels','Title','',...
            'Position',...
            [posx+thickness posy+height-thickness 30-dth-blockSpacing 15],...
            'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        top_right_panel = uipanel(f,'units','pixels','Title','',...
            'Position',...
            [posx+60+thickness+blockSpacing posy+height-thickness width-60-dth-blockSpacing 15],...
            'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        
        % This block of code colours the rectangles we just added
        hObject = bottom_tooth_panel;
        set(hObject,'BackgroundColor',color1);
        hObject = middle_panel;
        set(hObject,'BackgroundColor',color1);
        hObject = top_left_panel;
        set(hObject,'BackgroundColor',color1);
        hObject = top_right_panel;
        set(hObject,'BackgroundColor',color1);
        
    end

%% Linear block creation

    function newLinearLeft(color,userdata,posx,posy,width,height)
        if ~exist('width','var'), width = 500; end
        if ~exist('height', 'var'), height = 85; end
        % This block of code adds rectangles to the scene
        bottom_tooth_panel = uipanel(f,'units','pixels','Title','',...
            'Position',[posx+30 posy+0 30 15],'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        middle_panel = uipanel(f,'units','pixels','Title','',...
            'Position',[posx+0 posy+15 width height-15],'BorderType',...
            'none','userdata',userdata,'ButtonDownFcn',@dragObject);
        top_left_panel = uipanel(f,'units','pixels','Title','',...
            'Position',[posx+0 posy+height 30+indentation-blockSpacing 15],'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        top_right_panel = uipanel(f,'units','pixels','Title','',...
            'Position',[posx+60+indentation+blockSpacing posy+height width-60-indentation-blockSpacing 15],'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        
        % This block of code colours the rectangles we just added
        hObject = bottom_tooth_panel;
        set(hObject,'BackgroundColor',color);
        hObject = middle_panel;
        set(hObject,'BackgroundColor',color);
        hObject = top_left_panel;
        set(hObject,'BackgroundColor',color);
        hObject = top_right_panel;
        set(hObject,'BackgroundColor',color);
        
    end

%% Linear block creation

    function newLinearLeftWBorder(color1,color2,thickness,userdata,posx,posy,width,height)
        if ~exist('width','var'), width = 500; end
        if ~exist('height', 'var'), height = 85; end
        
        newLinearLeft(color2,userdata,posx,posy,width,height);
        
        dth = 2*thickness;
        
        % This block of code adds rectangles to the scene
        bottom_tooth_panel = uipanel(f,'units','pixels','Title','',...
            'Position',...
            [posx+30+thickness posy+thickness 30-dth 15],...
            'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        middle_panel = uipanel(f,'units','pixels','Title','',...
            'Position',...
            [posx+thickness posy+15+thickness width-dth height-15-dth],...
            'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        top_left_panel = uipanel(f,'units','pixels','Title','',...
            'Position',...
            [posx+thickness posy+height-thickness 30+indentation-dth-blockSpacing 15],...
            'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        top_right_panel = uipanel(f,'units','pixels','Title','',...
            'Position',...
            [posx+60+indentation+thickness+blockSpacing posy+height-thickness width-60-indentation-dth-blockSpacing 15],...
            'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        
        % This block of code colours the rectangles we just added
        hObject = bottom_tooth_panel;
        set(hObject,'BackgroundColor',color1);
        hObject = middle_panel;
        set(hObject,'BackgroundColor',color1);
        hObject = top_left_panel;
        set(hObject,'BackgroundColor',color1);
        hObject = top_right_panel;
        set(hObject,'BackgroundColor',color1);
        
    end

%% Linear block creation

    function newLinearDouble(color,userdata,posx,posy,width,height)
        if ~exist('width','var'), width = 500; end
        if ~exist('height', 'var'), height = 85; end
        % This block of code adds rectangles to the scene
        bottom_tooth_panel = uipanel(f,'units','pixels','Title','',...
            'Position',[posx+30+indentation posy+0 30 15],'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        middle_panel = uipanel(f,'units','pixels','Title','',...
            'Position',[posx+0 posy+15 width height-15],'BorderType',...
            'none','userdata',userdata,'ButtonDownFcn',@dragObject);
        top_left_panel = uipanel(f,'units','pixels','Title','',...
            'Position',[posx+0 posy+height 30+indentation-blockSpacing 15],'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        top_right_panel = uipanel(f,'units','pixels','Title','',...
            'Position',[posx+60+indentation+blockSpacing posy+height width-60-indentation-blockSpacing 15],'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        
        % This block of code colours the rectangles we just added
        hObject = bottom_tooth_panel;
        set(hObject,'BackgroundColor',color);
        hObject = middle_panel;
        set(hObject,'BackgroundColor',color);
        hObject = top_left_panel;
        set(hObject,'BackgroundColor',color);
        hObject = top_right_panel;
        set(hObject,'BackgroundColor',color);
        
    end

%% Linear block creation

    function newLinearDoubleWBorder(color1,color2,thickness,userdata,posx,posy,width,height)
        if ~exist('width','var'), width = 500; end
        if ~exist('height', 'var'), height = 85; end
        
        newLinearDouble(color2,userdata,posx,posy,width,height);
        
        dth = 2*thickness;
        
        % This block of code adds rectangles to the scene
        bottom_tooth_panel = uipanel(f,'units','pixels','Title','',...
            'Position',...
            [posx+30+indentation+thickness posy+thickness 30-dth 15],...
            'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        middle_panel = uipanel(f,'units','pixels','Title','',...
            'Position',...
            [posx+thickness posy+15+thickness width-dth height-15-dth],...
            'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        top_left_panel = uipanel(f,'units','pixels','Title','',...
            'Position',...
            [posx+thickness posy+height-thickness 30+indentation-dth-blockSpacing 15],...
            'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        top_right_panel = uipanel(f,'units','pixels','Title','',...
            'Position',...
            [posx+60+indentation+thickness+blockSpacing posy+height-thickness width-60-indentation-dth-blockSpacing 15],...
            'BorderType','none',...
            'userdata',userdata,'ButtonDownFcn',@dragObject);
        
        % This block of code colours the rectangles we just added
        hObject = bottom_tooth_panel;
        set(hObject,'BackgroundColor',color1);
        hObject = middle_panel;
        set(hObject,'BackgroundColor',color1);
        hObject = top_left_panel;
        set(hObject,'BackgroundColor',color1);
        hObject = top_right_panel;
        set(hObject,'BackgroundColor',color1);
        
    end

%% Image block creation

    function newImageBlock(image,userdata,posx,posy,width,height)
        [x,map]=imread(image);
        I2=imresize(x, [width height]);
        image_panel = uicontrol(f,'style','pushbutton','units','pixels',...
            'Position',[posx posy width height],...
            'userdata',userdata,'ButtonDownFcn',@dragObject,'cdata',I2);
    end

%% Adding blocks to the screen

    function startupScene()
        
        % The first parameter is the colour of the block
        % The second one is the userdata: the first element is the group of
        % blocks and the second one is a unique identitifer for the block
        % The next two parameters are the x and y coordinates of the block
        % We can set the x and y to 0 because we will then refresh the
        % position from the xml file.
        % The last 2 parameters are optionnal, they define the width and
        % height of the blocks. The defaults are width = 500, height = 85.
        % Please note that the height does not take into account the tooth at
        % the bottom.
        
        % Linear right are to the right of the blocks under them
        %newLinearRight(getColor(2),1,0,0,120,90);
        %newLinear(getColor(3),2,0,0);
        %newLinearDouble(getColor(4),3,0,0,120,90);
        %newLinear(getColor(3),4,0,0,213,30);
        %newLinear(getColor(3),5,0,0,400,40);
        % Linear left are to the left of the blocks under them
        %newLinearLeft(getColor(1),6,0,0,100,30);
        %newLinear(getColor(3),7,0,0,450,40);
        
        % Rubbish bin.
        %newLinear(getColor(7),8,0,0,200,200);
        %newImageBlock('rubbish_bin.png',8,50,50,100,100);
        
        % Adding blocks with outlines is similar to adding blocks:
        % newLinearWBorder(a,b,c,d,e,f,g,h)
        % a = body colour
        % b = outline colour
        % c = border width, integer or 0.5
        % d = blockID
        % e = x coord when loaded
        % f = y coord when loaded
        % g = width (default 500)
        % h = height (default 85)
        % examples:
        % newLinearWBorder(getColor(1),black,1,1,0,0,100,30);
        % newLinearWBorder(getColor(2),black,0.5,2,0,0,120,90);
        % newLinearWBorder(getColor(3),black,1,3,0,0);
        % newLinearWBorder(getColor(4),black,0.5,4,0,0,213,30);
        % newLinearWBorder(getColor(5),black,2,5,0,0,400,20);
        % newLinearWBorder(getColor(6),black,0.5,6,0,0,450,40);
        % Please note that adding outlines to every block can cause lag.
        
        % Please note that the blockID MUST be unique as we use it as a
        % primary key for each block.
        % Please note that the x and y attributes are here to give the
        % initial dimensions of the block, NOT their coordinates. We use the
        % group's coordinates and an offset based on the size of the other
        % blocks.
        % If the group parameter corresponds to a group that does not exist,
        % a new group is created with the right parameter.
        createGroup(1, 250, 500);
        
        addToGroup('if', 1, 1, 120, 90);
        addToGroup('element', 1, 2, 500, 85);
        addToGroup('else', 1, 3, 100, 40);
        addToGroup('element', 1, 4, 213, 30);
        addToGroup('element', 1, 5, 400, 40);
        addToGroup('end', 1, 6, 100, 40);
        addToGroup('element', 1, 7, 450, 40);
        
        createGroup(2, 0, 650);
        addToGroup('Rubbish_bin', 2, 8, 200, 200);
        
        % We want to create the blocks based on this xml
        loadFromXml();
        
        % We want to move everything so that it corresponds to the xml file
        refreshFromXml();
        
    end

startupScene();

%% Loading all of the blocks from xml (we do not place them according to
% their coordinates. To do so, call refreshFromXml() afterwards.

    function loadFromXml()
        blockNodes = getBlockNodes();
        dim = size(blockNodes);
        dim = dim(2);
        for i = 1:dim
            node = blockNodes{i};
            nodeName = char(node.getNodeName);
            switch nodeName
                case 'left'
                    leftFromNode(node);
                case 'right'
                    rightFromNode(node);
                case 'double'
                    doubleFromNode(node);
                case 'Rubbish_bin'
                    rubbishBinFromNode(node);
                case 'if'
                    ifFromNode(node);
                case 'else'
                    elseFromNode(node);
                case 'end'
                    endFromNode(node);
                otherwise
                    linearFromNode(node);
            end
        end
    end

%% Retrieving all of the block nodes in the xml document

    function out = getBlockNodes()
        node = docRootNode.getFirstChild;
        out = {};
        counter = 1;
        while ~isempty(node)
            tempGroup = node.getAttribute('group');
            empty = '';
            childNode = node.getFirstChild;
            while ~isempty(childNode)
                if ~strcmp(tempGroup, empty)
                    tempAttr = childNode.getAttribute('blockID');
                    if ~strcmp(tempAttr, empty)
                        out{counter} = childNode;
                        counter = counter + 1;
                    end
                    childNode = childNode.getNextSibling;
                end
            end
            node = node.getNextSibling;
        end
    end

%% Creating a group

    function out = createGroup(group, x, y)
        thisElement = docNode.createElement('group');
        thisElement.setAttribute('group',int2str(group));
        thisElement.setAttribute('x',int2str(x));
        thisElement.setAttribute('y',int2str(y));
        docRootNode.appendChild(thisElement);
        out = thisElement;
    end

% We can for example create group 1 and 2 located respectively at
%  (200,100) and (500,100).
% Please note that the coordinate system's origin is at the bottom
% left of the screen, meaning that positive x is right and positive y
% is up.
%createGroup(1, 200, 100);
%createGroup(2, 500, 100);

%% Adding blocks to a group

    function addToGroup(name, groupNumber, blockID, x, y)
        
        % We recuperate all of the nodes called group
        allGroups = docRootNode.getElementsByTagName('group');
        
        % We declare our group variable. Temp is here so that we can
        % check if group has changed later.
        temp = com.mathworks.xml.XMLUtils.createDocument('temp_group');
        group = temp;
        
        % We cycle through the nodes called group until we find
        % the right one
        for k = 0:allGroups.getLength-1
            thisGroup = allGroups.item(k);
            if strcmp(thisGroup.getAttribute('group'),...
                    int2str(groupNumber))
                group = allGroups.item(k);
                break;
            end
        end
        
        % We check if our group has been found. If not we create it
        if group == temp
            group = createGroup(groupNumber, 150, 550);
        end
        
        % We add the new node as a child of the group we found
        thisElement = docNode.createElement(name);
        thisElement.setAttribute('blockID',int2str(blockID));
        thisElement.setAttribute('x',int2str(x));
        thisElement.setAttribute('y',int2str(y));
        group.appendChild(thisElement);
        
    end

%% Retrieving a group node with a particular group number

% This function is recursive. It will iterate through each sibling
% and when the sibling has children, it will call itself to iterate
% between the children. As soon as the wanted node is found, it will
% stop searching and return the value. If it does not find the
% node associated with the group number, it will return the input
% node.
    function out = getGroupNode(childNode)
        node = getParentNode(childNode);
        tempGroup = node.getNodeName();
        if strcmp(tempGroup, 'group')
            out = node;
            return
        else
            temp = getGroupNode(node);
            if temp ~= node
                out = temp;
                return
            end
        end
        out = childNode;
        return
    end

%% Retrieving a node with a particular blockID

% This function is recursive. It will iterate through each sibling
% and when the sibling has children, it will call itself to iterate
% between the children. As soon as the wanted node is found, it will
% stop searching and return the value. If it does not find the
% node associated with the blockID, it will return the input node.
    function out = getNode(blockID, parent)
        node = parent.getFirstChild;
        while ~isempty(node)
            tempAttr = node.getAttribute('blockID');
            tempGroup = node.getAttribute('group');
            empty = '';
            if ~strcmp(tempAttr, empty) || ~strcmp(tempGroup, empty)
                if strcmpi(tempAttr, int2str(blockID))
                    out = node;
                    return
                elseif ~isempty(node.getFirstChild)
                    temp = getNode(blockID, node);
                    if temp ~= node
                        out = temp;
                        return
                    end
                end
            end
            node = node.getNextSibling;
        end
        out = parent;
    end

% For example, if we want to find the node with the blockID '1' in
% the whole document, ce can type:
%getNode(1,docRootNode);

% If we know that the block is in a particular node called 'N',
% we can replace docRootNode by 'N'.

%% A loop example

%for i=1:20
%    thisElement = docNode.createElement('child_node');
%    thisElement.appendChild...
%        (docNode.createTextNode(sprintf('%i',i)));
%    docRootNode.appendChild(thisElement);
%end


%% Get the drag IDs

    function out = getDragIDs(node)
        out = {};
        n = 0;
        while ~isempty(node)
            n = n + 1;
            tempBlockID = node.getAttribute('blockID');
            % In order to increase the speed of execution, we can set
            % ressources for out, but since this function is only called
            % periodically, it has not been done yet.
            out{n} = tempBlockID;
            
            % This section checks for children and adds them if they fit
            % the bill
            if ~isempty(node.getFirstChild)
                temp = getDragIDs(node.getFirstChild);
                if ~isempty(temp)
                    for i = 1:size(temp)
                        n = n + 1;
                        out(n) = temp(i);
                    end
                end
            end
            % Get ready to examine the next sibling
            node = node.getNextSibling;
        end
    end

%% Find the parent node of a node

% This is native to the java library matlab is using,
% just use: node.getNodeParent()

%% Relocate the block nodes into a new group at the root

    function xmlRelocate(blockID)
        
        % Fist we check if the node with this blockID is the first one in
        % the group. If so, there is no need to relocate these nodes.
        
        relocateNode = getNode(blockID, docRootNode);
        relocateNodeParent = getParentNode(relocateNode);
        firstValidChildNode = relocateNodeParent.getFirstChild;
        
        while ~isempty(firstValidChildNode)
            attr = firstValidChildNode.getAttribute('blockID');
            if ~isempty(attr)
                break;
            end
            firstValidChildNode = firstValidChildNode.getNextSibling;
        end
        
        if relocateNode ~= firstValidChildNode
            
            % (1) We want to find a new group to put these nodes in
            
            groupNum = 0;
            n = 1;
            group = com.mathworks.xml.XMLUtils.createDocument('temp');
            while groupNum == 0
                
                % We recuperate all of the nodes called group
                allGroups = docRootNode.getElementsByTagName('group');
                
                % We declare our group variable. Temp is here so that we
                % can check if group has changed later.
                temp = com.mathworks.xml.XMLUtils.createDocument...
                    ('temp');
                group = temp;
                
                % We cycle through the nodes called group until we find
                % the right one
                for k = 0:allGroups.getLength-1
                    thisGroup = allGroups.item(k);
                    if strcmp(thisGroup.getAttribute('group'),...
                            int2str(n))
                        group = allGroups.item(k);
                        break;
                    end
                end
                
                if group == temp
                    groupNum = n;
                    group = createGroup(n, 0, 0);
                    % todo elseif group empty
                end
                n = n + 1;
            end
            
            % (2) Now that we have a group to put the nodes in, we select
            % the nodes to transfer then transfer them to the new group.
            
            % We are selecting the node with the blockID
            node = getNode(blockID, docRootNode);
            
            moveXmlChain(node, group);
            
        end
    end

% Here is an example of how to use this function:
% xmlRelocate(2);

%% Moving all of the nodes starting from a node to the end of a group

    function moveXmlChain(startNode, groupNode)
        
        % we select the nodes to transfer then transfer them to the
        % new group.
        
        % We are going to fill up a list with the nodes before moving
        % them. Otherwise, the .getNextSibling will not work because
        % we move the node. c is just a counter.
        
        nodes = [];
        c = 1;
        
        % We cycle through all of the nodes beneath our selected node
        % and store them in the list called nodes.
        while ~isempty(startNode)
            nodes{c} = startNode;
            startNode = startNode.getNextSibling;
            c = c + 1;
        end
        
        % As mentionned higher up, we need to take the second element
        % of the size function.
        dimension = size(nodes);
        % In this loop, we move all of the nodes stored in the nodes
        % variable into our new group.
        for i = 1:dimension(2)
            groupNode.appendChild(nodes{i});
        end
        
    end

%% Moving all of the nodes starting from a node to a position inside
% a group

    function moveXmlChainBefore(startNode, groupNode)
        
        % we select the nodes to transfer then transfer them to the
        % new group.
        
        % We are going to fill up a list with the nodes before moving
        % them. Otherwise, the .getNextSibling will not work because
        % we move the node. c is just a counter.
        
        nodes = [];
        c = 1;
        
        % We cycle through all of the nodes beneath our selected node
        % and store them in the list called nodes.
        while ~isempty(startNode)
            nodes{c} = startNode;
            startNode = startNode.getNextSibling;
            c = c + 1;
        end
        
        % As mentionned higher up, we need to take the second element
        % of the size function.
        dimension = size(nodes);
        % In this loop, we move all of the nodes stored in the nodes
        % variable inside the chosen group.
        for i = 1:dimension(2)
            groupNode.getParentNode().insertBefore(nodes{i}, groupNode);
        end
        
    end

%% Adding comments

%docNode.appendChild(docNode.createComment('this is a comment'));

%% Relocating blocks based on the xml (can be used to refresh their
% position or to set up the environment when loading a file).
% We also remove group nodes that are empty.

    function refreshFromXml()
        % We obtain all of the group nodes
        groupNodes = docRootNode.getElementsByTagName('group');
        emptyGroups = [];
        counter = 1;
        % We cycle through the group nodes
        for k = 0:groupNodes.getLength-1
            group = groupNodes.item(k);
            
            % We check if this group has children
            if group.hasChildNodes()
                % We obtain this groups children
                childNodes = group.getChildNodes();
                
                groupX = str2num(group.getAttribute('x'));
                groupY = str2num(group.getAttribute('y'));
                
                offsetX = 0;
                offsetY = 0;
                
                % We cycle through the children
                for l = 0:childNodes.getLength-1
                    child = childNodes.item(l);
                    temp = child.getAttribute('blockID');
                    blockID = str2num(temp);
                    % We don't want to offset the first block or it will
                    % not be aligned with the group coordinates
                    if l ~= 0
                        offsetX = offsetX + getOffsetTop(child);
                    end
                    posx = groupX + offsetX;
                    posy = groupY - offsetY;
                    moveBlock(blockID, posx, posy);
                    offsetY = offsetY + blockSpacing +...
                        str2num(child.getAttribute('y'));
                    offsetX = offsetX + getOffsetBottom(child);
                end
            else
                % If not, we prepare to remove this group node
                emptyGroups{counter} = group;
                counter = counter + 1;
            end
        end
        % Remove the empty group nodes we have noticed earlier
        emptyGroupsSize = size(emptyGroups);
        for counter = 1:emptyGroupsSize(2)
            group = emptyGroups{counter};
            group.getParentNode().removeChild(group);
        end
    end

%% Moving a block with a particular id to a particular position

    function moveBlock(blockID, posx, posy)
        relocating = [];
        
        % We load all of the elements into a temporary variable
        temp = findall(f);
        
        % We initialize a counter to keep track of the amount of elements
        n = 1;
        
        for i = 1:size(temp)
            % We load the i-eth object into a variable
            tempObj = temp(i);
            % We load its user data
            tempData = get(tempObj,'UserData');
            % We check it has user data
            if size(tempData)> 0
                % We check if this object is part of the objects we want
                % to relocate
                if tempData == blockID
                    % We add it as the n-eth element
                    relocating{n} = tempObj;
                    n = n+1;
                end
            end
        end
        
        % Now that we have all of the elements that compose our block
        % stored in 'relocating', we need to find its top left coordinate
        
        [x, y] = blockCoord(relocating);
        
        % Now that we have the real coordinates, we can calculate an
        % offset to aplly to all of the objects.
        
        offsetX = posx - x;
        offsetY = posy - y;
        
        % We can now cycle through all of the elements and offset them.
        dim = size(relocating);
        for i = 1:dim(2)
            object = relocating{i};
            set(object,'Position',get(object,'Position')...
                + [offsetX offsetY 0 0]);
        end
    end

%% Removing a block from the xml and visually and updating the screen

    function removeBlock(blockID)
        removeBlockVisual(blockID);
        removeBlockXml(blockID);
        refreshFromXml();
    end

%% Removing a block visually

    function removeBlockVisual(blockID)
        
        % We load all of the elements into a temporary variable
        temp = findall(f);
        
        for i = 1:size(temp)
            % We load the i-eth object into a variable
            tempObj = temp(i);
            % We load its user data
            tempData = get(tempObj,'UserData');
            % We check it has user data
            if size(tempData)> 0
                % We check if this object is part of the objects we want
                % to remove
                if tempData == blockID
                    % We delete it
                    delete(tempObj);
                end
            end
        end
    end

%% Removing a block from the xml
    function removeBlockXml(blockID)
        node = getNode(blockID, docRootNode);
        node.getParentNode().removeChild(node);
    end

%% Retrieving the coordinates of a block from the elements that
% compose it.

    function [outx, outy] = blockCoord(objects)
        
        outy = -999999;
        outx = 999999;
        dim = size(objects);
        for i = 1:dim(2)
            % Select the object
            object = objects{i};
            % Retrieve the object's coordinates (including size).
            pos = get(object,'Position');
            y = pos(2) + pos(4);
            % We want the top left coordinate, so we correct the
            % values whenever a better one is found.
            if y > outy
                outy = y;
            end
            if pos(1) < outx
                outx = pos(1);
            end
        end
    end

%% Output

    function printxml()
        % Saving the file
        
        xmlFileName = ['test','.bgs'];
        xmlwrite(xmlFileName,docNode);
        
        % Printing the file into the command window
        
        type(xmlFileName);
        
    end
%printxml();

end