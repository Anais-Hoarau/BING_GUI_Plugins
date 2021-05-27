%{
Function:
This function displays axis on a parent figure, with a title containing the variableName


Parameters:
- parentWindow : a handler to the figure on which to create the axis and
the plots
- timecodes : value of X axis (array of numbers)
- variableToDisplay : value of Y axis (array of numbers)
- variableName : the name to display on the title of the curve (a string)
- window title : the title of the window!

%}
function displayCurves(parentWindow, timecodes, variableToDisplay,variableName,windowTitle)
                set(parentWindow,'Name',windowTitle);
                % display 
                dataLength = length(timecodes);
                set(parentWindow,'ToolBar','figure');
                uicontrol(parentWindow, 'Style', 'text', 'String',windowTitle, 'Position', [0 750 1024 20], 'BackgroundColor', get(parentWindow, 'Color'),'FontWeight','bold');
                uicontrol(parentWindow, 'Style', 'text', 'String',['Variable : ' variableName ' vs. timecode'], 'Position', [0 720 1024 20], 'BackgroundColor', get(parentWindow, 'Color'),'FontWeight','bold');
                
                axesHandler1 = axes('Parent', parentWindow, 'Units', 'pixels', 'Position', [50 390 960 300]);
                borne = round(dataLength/2);
                times = timecodes(1:borne);
                datas = variableToDisplay(1:borne);
                plot(axesHandler1,times,datas);
                set(axesHandler1,'XGrid','off','YGrid','on','ZGrid','off'); % draw Y lines
                set(axesHandler1,'GridLineStyle','-');
                set(axesHandler1,'MinorGridLineStyle',':');
                set(axesHandler1,'YMinorGrid','on'); % add minor lines
                set(axesHandler1,'YMinorTick','on');
                hold(axesHandler1);
                
                axesHandler2 = axes('Parent', parentWindow, 'Units', 'pixels', 'Position', [50 30 960 300]);
                times = timecodes(borne:dataLength);
                datas = variableToDisplay(borne:dataLength);
                plot(axesHandler2,times,datas);
                set(axesHandler2,'XGrid','off','YGrid','on','ZGrid','off'); % draw Y lines
                set(axesHandler2,'GridLineStyle','-');
                set(axesHandler2,'MinorGridLineStyle',':');
                set(axesHandler2,'YMinorGrid','on'); % add minor lines
                set(axesHandler2,'YMinorTick','on');
                hold(axesHandler2);
                hold(axesHandler2);
                
end

