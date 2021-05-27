function varargout = MoTrack(varargin)

% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% Copyright (c) Josef Christian


% MOTRACK MATLAB code for MoTrack.fig
%      MOTRACK, by itself, creates a new MOTRACK or raises the existing
%      singleton*.
%
%      H = MOTRACK returns the handle to a new MOTRACK or the handle to
%      the existing singleton*.
%
%      MOTRACK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOTRACK.M with the given input arguments.
%
%      MOTRACK('Property','Value',...) creates a new MOTRACK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MoTrack_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MoTrack_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MoTrack

% Last Modified by GUIDE v2.5 17-Jun-2014 15:49:46


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MoTrack_OpeningFcn, ...
                   'gui_OutputFcn',  @MoTrack_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before MoTrack is made visible.
function MoTrack_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MoTrack (see VARARGIN)

data.textShift = 6; %distance of the marker labels from the markers in x and y dir

[rootPathName, ~, ~] = fileparts(mfilename('fullpath')); %get MoTrack directory

% set configuration values from file or default
if exist('config.mat','file')
    load config.mat  %load configuration file if exists
    config.rootPathName = rootPathName;
else
    %define default configuration
    config.rootPathName = rootPathName;
    
    config.threshold = 90;
    config.searchRadius = 20;
    config.maxArea = 50;
    config.minArea = 4;
    config.minSolidity = 0.6;
    config.maxEccentricity = 0.9;
    
    config.screenPosition = 'default';
    config.mainPosition = get(hObject,'Position');
    config.markerList = '';
    
    config.thresholdDisplayCheckValue = 0;
    config.greyscaleCheckValue = 0;
    config.labelsCheckValue = 1;
    config.autoPanCheckValue = 1;
    config.autoTrackCheckValue = 0;
    config.advanceFrameCheckValue = 1;
    config.advanceMarkerCheckValue = 0;
end

%set configuration
set(handles.threshold,'String',num2str(config.threshold))
set(handles.searchRadius,'String',num2str(config.searchRadius))
set(handles.maxArea,'String',num2str(config.maxArea))
set(handles.minArea,'String',num2str(config.minArea))
set(handles.minSolidity,'String',num2str(config.minSolidity))
set(handles.maxEccentricity,'String',num2str(config.maxEccentricity))
set(handles.markerListBox, 'String',config.markerList)

set(handles.thresholdDisplayCheck,'Value', config.thresholdDisplayCheckValue);
set(handles.greyscaleCheck,'Value', config.greyscaleCheckValue);
set(handles.labelsCheck, 'Value',config.labelsCheckValue);
set(handles.autoPanCheck, 'Value', config.autoPanCheckValue);
set(handles.autoTrackCheck, 'Value', config.autoTrackCheckValue);
set(handles.advanceFrameCheck, 'Value', config.advanceFrameCheckValue );
set(handles.advanceMarkerCheck, 'Value', config.advanceMarkerCheckValue);

%number of Markers
if ~isempty(get(handles.markerListBox,'String'))
    data.nMarkers = size(get(handles.markerListBox,'String'),1);
else
    data.nMarkers = 0;
end

%disable controls in player and options panels
handles.hPlayerControls = get(handles.playerPanel,'Children');
handles.hOptions1Controls = get(handles.optionsPanel1,'Children');
handles.hOptions2Controls = get(handles.optionsPanel2,'Children');
set(handles.hPlayerControls,'enable','off')
set(handles.hOptions1Controls,'enable','off')
set(handles.hOptions2Controls,'enable','off')
set(handles.menu_fileSave,'enable','off')
set(handles.menu_fileExportExcel,'enable','off')
set(handles.menu_fileExportWS,'enable','off')
set(handles.menu_image,'enable','off')

% initiate nextFrameButton userdata -> is used to make keypressfunctions wait for nextFrameFcn to complete (1 = complete ; 0 = not yet)
set(handles.nextFrameButton,'userdata',1);
set(handles.previousFrameButton,'userdata',1); % also for previous frame button 

%update appdata
setappdata(hObject,'data',data)
setappdata(hObject,'config',config)
setappdata(hObject,'tempPath',[])

% Choose default command line output for MoTrack
handles.hMain = hObject; %hMain is the handle to the MoTrack main window

set(hObject,'Position', config.mainPosition')
set(hObject,'closeRequestFcn',{@closeMain,handles});

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MoTrack wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = MoTrack_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.hMain; %output MoTrack GUI handle


function loadFrame(hObject,eventdata,handles)
% load frame to memory using videoreader object and display it
data = getappdata(handles.hMain,'data');  %reader object is stored in appdata
reader = data.reader;
frameNum = str2double(get(handles.frameNum,'String'));
I = read(reader,frameNum); %read frame
data.timecodes(frameNum,1) = data.reader.CurrentTime-0.04;
disp(num2str(data.timecodes(frameNum,1)))
if get(handles.greyscaleCheck,'Value') %&& size(I,3) == 3  %change to grayscale if RGB
    I = rgb2gray(I);
end
data.I = I;
% display either the grayscale image I or a thresholded black-white image
if get(handles.thresholdDisplayCheck,'Value') % check if grayscale or black-white
    Idisp = I > str2double(get(handles.threshold,'String')); %black-white
else
    Idisp = I; %grayscale
end
set(handles.hImage,'CData',Idisp); %display
setappdata(handles.hMain,'data',data) %update appdata

function selectPoint(hObject,eventdata,handles)
%store marker coordinates when the user manually clicks on the screen 
data = getappdata(handles.hMain,'data');
nMarkers = data.nMarkers; %number of markers
if nMarkers > 0 %only do something if there is a markerlist defined
    nFrames = data.nFrames;
    frameNum = str2double(get(handles.frameNum,'String')); %actual frame number
    pointPosition = get(handles.hScreenAxes,'currentPoint'); %get current point
    %index of the marker selected in the markerlist (build logical index array)
    markerIndex = get(handles.markerListBox,'Value');
    logicalMarkerIndex = zeros(1,data.nMarkers);
    logicalMarkerIndex(markerIndex) = 1;
    %store x and y coordinates
    data.xMeasured(frameNum,markerIndex) = pointPosition(1,1);
    data.yMeasured(frameNum,markerIndex) = pointPosition(1,2);
    %also use the clicked coordinates to set the estimated position for the kalman filter (this is the initialisation of the estimation and also allows manual correction of the estimated position at any time
    data.estimatedState(1,markerIndex,frameNum) = pointPosition(1,1);
    data.estimatedState(2,markerIndex,frameNum) = pointPosition(1,2);
    
    if frameNum > 1 %only possible for a frame number greater than 0
        alreadyClickedIndex = (data.estimatedState(1,:,frameNum - 1) ~= 0);
        data.estimatedState(3,logicalMarkerIndex & alreadyClickedIndex,frameNum) = data.estimatedState(1,logicalMarkerIndex & alreadyClickedIndex,frameNum) - data.estimatedState(1,logicalMarkerIndex & alreadyClickedIndex,frameNum - 1);
        data.estimatedState(4,logicalMarkerIndex & alreadyClickedIndex,frameNum) = data.estimatedState(2,logicalMarkerIndex & alreadyClickedIndex,frameNum) - data.estimatedState(2,logicalMarkerIndex & alreadyClickedIndex,frameNum - 1);
    else % for the first frame the velocity is unknown an is set to 0
        data.estimatedState(3,markerIndex,frameNum) = 0;
        data.estimatedState(4,markerIndex,frameNum) = 0;
    end
    
    setappdata(handles.hMain,'data',data);  %update appdata
    
    %auto pan if option is selected
    if get(handles.autoPanCheck,'Value')
        oldXLim = get(handles.hScreenAxes,'xLim');
        oldYLim = get(handles.hScreenAxes,'yLim');
        markerIndex = get(handles.markerListBox,'Value');
        logicalMarkerIndex = zeros(1,data.nMarkers);
        logicalMarkerIndex(markerIndex) = 1;
        alreadyClickedIndex = (data.estimatedState(1,:,frameNum) ~= 0);
        if ~isempty(data.estimatedState(3,logicalMarkerIndex & alreadyClickedIndex,frameNum)) && ~isempty(data.estimatedState(4,logicalMarkerIndex & alreadyClickedIndex,frameNum))
            newXLim = oldXLim + data.estimatedState(3,logicalMarkerIndex & alreadyClickedIndex,frameNum);
            newYLim = oldYLim + data.estimatedState(4,logicalMarkerIndex & alreadyClickedIndex,frameNum);
            if newXLim(1)>0 && newXLim(2)<data.resolution(2) && newYLim(1)>0 && newYLim(2)<data.resolution(1)
                set(handles.hScreenAxes,'XLim', newXLim, 'YLim',newYLim)
            else
                set(handles.hScreenAxes,'XLim', oldXLim, 'YLim',oldYLim)
            end
        end
    end
    
    plotMarkersAndLabels(hObject, eventdata, handles) %refesh display

    %auto advance - check options and advance frame or marker or advance frame after last marker if both options are selected 
    if get(handles.advanceMarkerCheck,'Value') &&  markerIndex(1) < nMarkers && length(markerIndex) == 1
        set(handles.markerListBox,'Value',markerIndex+1)
    end
    if get(handles.advanceFrameCheck,'Value') && get(handles.advanceMarkerCheck,'Value') && frameNum < nFrames && markerIndex(1) == nMarkers && length(markerIndex) == 1
        set(handles.markerListBox,'Value',1)
        nextFrameButton_Callback(hObject, eventdata, handles)
    elseif get(handles.advanceFrameCheck,'Value') && ~get(handles.advanceMarkerCheck,'Value') && frameNum < nFrames
        nextFrameButton_Callback(hObject, eventdata, handles)
    end

end

function plotMarkersAndLabels(hObject, eventdata, handles)
%plot measured markers and labels on screen
data = getappdata(handles.hMain,'data');
textShift = data.textShift;
frameNum = str2double(get(handles.frameNum,'String'));
markerList = cellstr(get(handles.markerListBox,'String'));
xMeasured = data.xMeasured;
yMeasured = data.yMeasured;

markerIndex = ~(xMeasured(frameNum,:)==0); %logical index of allready measured markers -> display measured only
%set the x and y data of the marker line objects and also the visible property
set(handles.hMarkersPlot(markerIndex),{'xData'},num2cell(xMeasured(frameNum,markerIndex)'),{'yData'},num2cell(yMeasured(frameNum,markerIndex)'),'visible','on')
textPosition = mat2cell([xMeasured(frameNum,markerIndex)' + textShift ,yMeasured(frameNum,markerIndex)' + textShift],ones(sum(markerIndex),1));
set(handles.hMarkersText(markerIndex),{'Position'}, textPosition,{'String'}, markerList(markerIndex), 'visible','on','hittest','off') %set all markers to visible
% set to invisible if not measured yet
set(handles.hMarkersPlot(~markerIndex),'visible','off')
if get(handles.labelsCheck,'Value')
    set(handles.hMarkersText(~markerIndex),'visible','off')
else
    set(handles.hMarkersText,'visible','off')
end


function keypress(hObject, eventdata, handles)

% actions on keypress
switch eventdata.Key
    case 'leftarrow' %one frame back
        modifiers = get([handles.hMain, handles.hScreenFigure],'currentmodifier');
        shiftPressed = ismember('shift',modifiers{1}) | ismember('shift',modifiers{2});
        if shiftPressed
            previousLabeledFrame(hObject, eventdata, handles)
        else
            if get(handles.previousFrameButton,'userdata')
                set(handles.previousFrameButton,'userdata',0);
                previousFrameFcn(hObject, eventdata, handles)
            end
        end
    case 'rightarrow' %advance one frame
        modifiers = get([handles.hMain, handles.hScreenFigure],'currentmodifier');
        shiftPressed = ismember('shift',modifiers{1}) | ismember('shift',modifiers{2});
        if shiftPressed
            nextLabeledFrame(hObject, eventdata, handles)
        else
            if get(handles.nextFrameButton,'userdata')
                set(handles.nextFrameButton,'userdata',0);
                nextFrameFcn(hObject, eventdata, handles)%nextFrameButton_Callback(hObject, eventdata, handles)
            end
        end
    case 'space' %play and stop video
        playButton_Callback(hObject, eventdata, handles)
    case 'delete'
        
        %marker context menu delete function (right click on marker)
        %delete current frame only
        %handles = guidata(handles.hMain);
        data = getappdata(handles.hMain,'data');
        frameNum = str2double(get(handles.frameNum,'String'));
        markerInd = get(handles.markerListBox,'value');
        data.xMeasured(frameNum,markerInd) = 0;
        data.yMeasured(frameNum,markerInd) = 0;
        setappdata(handles.hMain,'data',data)
        plotMarkersAndLabels(hObject, eventdata, handles)
end
% --- Executes during object creation, after setting all properties.
function markerListBox_CreateFcn(hObject, eventdata, handles)
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in nextFrameButton.
function nextFrameButton_Callback(hObject, eventdata, handles)
%advance one frame
set(handles.nextFrameButton,'enable','off')
drawnow
set(handles.nextFrameButton,'enable','on')
set(handles.nextFrameButton,'interruptible','off')
nextFrameFcn(hObject, eventdata, handles)

function nextFrameFcn(hObject, eventdata, handles)
%set(handles.nextFrameButton,'userdata',0);
data = getappdata(handles.hMain,'data');
nFrames = data.nFrames;
frameNum = str2double(get(handles.frameNum,'String')); %get actual frame number
%selectedMarkersInd = get(handles.markerListBox,'Value');
if frameNum < nFrames %advance only if video has not ended yet
    set(handles.frameNum,'String',frameNum + 1) %refresh frame number
    set(handles.frameSlider,'Value',frameNum + 1) %refresh slider
    loadFrame(hObject, eventdata, handles) %load the frame
    
    %auto track markers if option is selected
    if get(handles.autoTrackCheck,'Value') && data.nMarkers > 0
        autoTrack(hObject,eventdata,handles)  
    end
    
    %auto pan if option is selected
    if get(handles.autoPanCheck,'Value')
        oldXLim = get(handles.hScreenAxes,'xLim');
        oldYLim = get(handles.hScreenAxes,'yLim');
        markerIndex = get(handles.markerListBox,'Value');
        logicalMarkerIndex = zeros(1,data.nMarkers);
        logicalMarkerIndex(markerIndex) = 1;
        alreadyClickedIndex = (data.estimatedState(1,:,frameNum) ~= 0);
        if ~isempty(data.estimatedState(3,logicalMarkerIndex & alreadyClickedIndex,frameNum + 1)) && ~isempty(data.estimatedState(4,logicalMarkerIndex & alreadyClickedIndex,frameNum + 1))
            newXLim = oldXLim + data.estimatedState(3,logicalMarkerIndex & alreadyClickedIndex,frameNum + 1);
            newYLim = oldYLim + data.estimatedState(4,logicalMarkerIndex & alreadyClickedIndex,frameNum + 1);
            if newXLim(1)>0 && newXLim(2)<data.resolution(2) && newYLim(1)>0 && newYLim(2)<data.resolution(1)
                set(handles.hScreenAxes,'XLim', newXLim, 'YLim',newYLim)
            else
                set(handles.hScreenAxes,'XLim', oldXLim, 'YLim',oldYLim)
            end
        end
    end
    
    %refresh display
    plotMarkersAndLabels(hObject,eventdata,handles)
    
end
drawnow
pause(0.001)
set(handles.nextFrameButton,'userdata',1);

% --- Executes on button press in previousFrameButton.
function previousFrameButton_Callback(hObject, eventdata, handles)
set(handles.previousFrameButton,'enable','off')
drawnow
set(handles.previousFrameButton,'enable','on')
previousFrameFcn(hObject, eventdata, handles)


function previousFrameFcn(hObject, eventdata, handles)
data = getappdata(handles.hMain,'data');
frameNum = str2double(get(handles.frameNum,'String'));
if frameNum > 1
    set(handles.frameNum,'String',frameNum - 1) %refresh frame number
    set(handles.frameSlider,'Value',frameNum - 1) %refresh slider
    loadFrame(hObject, eventdata, handles) %load the frame
    
    %auto pan if option is selected
    if get(handles.autoPanCheck,'Value') && frameNum <= data.nFrames
        oldXLim = get(handles.hScreenAxes,'xLim');
        oldYLim = get(handles.hScreenAxes,'yLim');
        markerIndex = get(handles.markerListBox,'Value');
        logicalMarkerIndex = zeros(1,data.nMarkers);
        logicalMarkerIndex(markerIndex) = 1;
        alreadyClickedIndex = (data.estimatedState(1,:,frameNum-1) ~= 0);
        if ~isempty(data.estimatedState(3,logicalMarkerIndex & alreadyClickedIndex,frameNum)) && ~isempty(data.estimatedState(4,logicalMarkerIndex & alreadyClickedIndex,frameNum))
            newXLim = oldXLim - data.estimatedState(3,logicalMarkerIndex & alreadyClickedIndex,frameNum);
            newYLim = oldYLim - data.estimatedState(4,logicalMarkerIndex & alreadyClickedIndex,frameNum);
            if newXLim(1)>0 && newXLim(2)<data.resolution(2) && newYLim(1)>0 && newYLim(2)<data.resolution(1)
                set(handles.hScreenAxes,'XLim', newXLim, 'YLim',newYLim)
            else
                set(handles.hScreenAxes,'XLim', oldXLim, 'YLim',oldYLim)
            end
        end
    end
    
    plotMarkersAndLabels(hObject,eventdata,handles) %refresh display
end
drawnow
pause(0.001)
set(handles.previousFrameButton,'userdata',1);


function nextLabeledFrame(hObject, eventdata, handles)
%this function searches for the next labeled frame of one or multiple markers
data = getappdata(handles.hMain,'data');
currentFrame = str2double(get(handles.frameNum,'string'));
markerInd = get(handles.markerListBox,'value');
[findFrame,~] = find(any(data.xMeasured(currentFrame+1:end,markerInd),2),1,'first');
newFrame = findFrame + currentFrame;
if ~isempty(newFrame)
    set(handles.frameNum,'string',num2str(newFrame))
    set(handles.frameSlider,'Value',newFrame);
    loadFrame(hObject, eventdata, handles)
    plotMarkersAndLabels(hObject, eventdata, handles)
end


function previousLabeledFrame(hObject, eventdata, handles)
%this function searches for the previous labeled frame of one or multiple markers
data = getappdata(handles.hMain,'data');
currentFrame = str2double(get(handles.frameNum,'string'));
markerInd = get(handles.markerListBox,'value');
[findFrame,~] = find(any(data.xMeasured(currentFrame-1:-1:1,markerInd),2),1,'first');
newFrame = currentFrame - findFrame;
if ~isempty(newFrame)
    set(handles.frameNum,'string',num2str(newFrame))
    set(handles.frameSlider,'Value',newFrame);
    loadFrame(hObject, eventdata, handles)
    plotMarkersAndLabels(hObject, eventdata, handles)
end



function frameNum_Callback(hObject, eventdata, handles)
% load and display the entered frame
frameNum = str2double(get(hObject,'String'));
set(handles.frameSlider,'Value',frameNum);
loadFrame(hObject, eventdata, handles)
plotMarkersAndLabels(hObject,eventdata,handles)

% --- Executes during object creation, after setting all properties.
function frameNum_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in playButton.
function playButton_Callback(hObject, eventdata, handles)
set(handles.playButton, 'Enable', 'off');
drawnow
set(handles.playButton, 'Enable', 'on');
playFcn(hObject, eventdata, handles)

function playFcn(hObject, eventdata, handles)
data = getappdata(handles.hMain,'data');
frameNum = str2double(get(handles.frameNum,'String'));
nFrames = data.nFrames;
if ~get(handles.playButton,'userData')
    set(handles.playButton,'selected','off')
    set(handles.playButton,'String','Stop') %change play button label to stop
    frameRate = data.frameRate;
    set(handles.playButton,'userdata',1); %play button check, set to true

    while  frameNum < nFrames && get(handles.playButton,'userdata') %check frame number and play button
       tStart = tic;  %start time measure to slow down video to realtime if it is too fast
       nextFrameFcn(hObject, eventdata, handles)
       drawnow
       frameNum = str2double(get(handles.frameNum,'String'));
       tElapsed = toc(tStart);
       desiredPlayBackSpeed = 1;
       tDiff = (1/frameRate)*1/desiredPlayBackSpeed - tElapsed;
       if tDiff > 0  % slow down if it is too fast, do nothing if it is too slow
           pause(tDiff)
       end
    end
else
    set(handles.playButton,'userdata',0); %set playbutton to false (video is stopped)
    set(handles.playButton,'String','Play') %change play button label to play
end
if frameNum == nFrames
    set(handles.playButton,'userdata',0); %set playbutton to false (video is stopped)
    set(handles.playButton,'String','Play') %change play button label to play
end


function threshold_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of threshold as text
%        str2double(get(hObject,'String')) returns contents of threshold as a double
if isfield(handles,'hScreenFigure') && ishandle(handles.hScreenFigure)
    loadFrame(hObject, eventdata, handles)
end

% --- Executes during object creation, after setting all properties.
function threshold_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function minArea_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function maxArea_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function minSolidity_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function maxEccentricity_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function searchRadius_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menu_fileOpen_Callback(hObject, eventdata, handles)
%let the user browse for video file, load the first frame and initiate the data
tempPath = getappdata(handles.hMain,'tempPath');
if exist(tempPath,'dir')
    saveQuest = questdlg('Save this project?','MoTrack','Yes','No','Cancel','Cancel');
    check = get(handles.hMain,'userdata');
    check.saveQuest = saveQuest;
    set(handles.hMain,'userdata',check)
    switch saveQuest
        case 'No'
            %store window position if screen is being closed
            config = getappdata(handles.hMain,'config');
            config.screenPosition = get(handles.hScreenFigure,'Position');
            setappdata(handles.hMain,'config',config)
        case 'Yes'
            menu_fileSave_Callback(hObject, eventdata, handles)
            %store window position if screen is being closed
            config = getappdata(handles.hMain,'config');
            config.screenPosition = get(handles.hScreenFigure,'Position');
            setappdata(handles.hMain,'config',config)
        case 'default'
    end
    [videoFileName, videoPathName] = uigetfile(fullfile(tempPath,'.avi')); %browse for video file
else
    [videoFileName, videoPathName] = uigetfile('.avi');
end

if ~isnumeric(videoFileName)
    setappdata(handles.hMain,'tempPath',videoPathName)
    
    delete(findall(0,'Tag','Screen')) %delete screen window if one exists allready
    
    trip_file = cell2mat(dirrec(videoPathName, '.trip'));
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
    vru_type = cell2mat(trip.getAllSituationOccurences('VRU_characteristics').getVariableValues('VRU_type'));
    
    reader = VideoReader([videoPathName videoFileName]); %create video reader object
    firstFrame = 1;
    I = read(reader,firstFrame);  %load first frame
    if get(handles.greyscaleCheck,'Value') %&& size(I,3) == 3  %change to grayscale if RGB
        I = rgb2gray(I);
    end

    if get(handles.thresholdDisplayCheck,'Value')
        Idisp = I > str2double(get(handles.threshold,'String'));
    else
        Idisp = I;
    end

    data = getappdata(handles.hMain,'data');
    config = getappdata(handles.hMain,'config');
    data.I = I;
    data.resolution = size(I);  %video resolution (note: hight * width = y * x)
    nFrames = get(reader,'NumberOfFrames');  %length of video
    set(handles.frameNum,'String',num2str(firstFrame)); %display frame number
    data.frameRate = get(reader,'FrameRate');
    data.nFrames = nFrames;
    data.reader = reader;
    data.videoFileName = videoFileName;
    data.videoPathName = videoPathName;
    set(handles.nFramesDisp,'String',['/ ' num2str(nFrames)]) %display total number of frames
    set(handles.frameSlider,'Value',1)
    if nFrames > 1 %enable slider only if video has more than one frame
        set(handles.frameSlider,'enable','on')
        set(handles.frameSlider,'Min',1)
        set(handles.frameSlider,'Max',nFrames)
    else
        set(handles.frameSlider,'enable','off')
    end
    %create empty data variables or load from file if already exists
    if exist([videoPathName videoFileName(1:find(videoFileName == '.')) 'mat'],'file')
        configLocal = config;  %temporarily store the local configuration (config file)
        
        load([videoPathName videoFileName(1:find(videoFileName == '.')) 'mat'])
        data.reader = reader;
        data.videoFileName = videoFileName;
        data.videoPathName = videoPathName;
        set(handles.threshold,'String',num2str(config.threshold))
        set(handles.searchRadius,'String',num2str(config.searchRadius))
        set(handles.maxArea,'String',num2str(config.maxArea))
        set(handles.minArea,'String',num2str(config.minArea))
        set(handles.minSolidity,'String',num2str(config.minSolidity))
        set(handles.maxEccentricity,'String',num2str(config.maxEccentricity))
        set(handles.markerListBox, 'String',config.markerList)

        set(handles.thresholdDisplayCheck,'Value', config.thresholdDisplayCheckValue);
        set(handles.greyscaleCheck,'Value', config.greyscaleCheckValue);
        set(handles.labelsCheck, 'Value',config.labelsCheckValue);
        set(handles.autoPanCheck, 'Value', config.autoPanCheckValue);
        set(handles.autoTrackCheck, 'Value', config.autoTrackCheckValue);
        set(handles.advanceFrameCheck, 'Value', config.advanceFrameCheckValue );
        set(handles.advanceMarkerCheck, 'Value', config.advanceMarkerCheckValue);
        
        config.screenPosition = configLocal.screenPosition;  %set window positions to values in local config because data files might be opened on different systems
        config.rootPathName = configLocal.rootPathName; % and also the root path
        
    else
%         if isempty(get(handles.markerListBox,'String'))
%             data.markerList = '';
        if ~isempty(strfind(vru_type,'Cyclist'))
            config = getappdata(handles.hMain,'config');
            fileName = fullfile(config.rootPathName,'markerLists','PROSPECT_CAR_CYC_MARKERS.mat');
            if ~isnumeric(fileName)
                load(fileName);
                set(handles.markerListBox,'String',markerList)
                data.nMarkers = size(markerList,1);
                setappdata(handles.hMain,'data',data)
                data.markerList = cellstr(get(handles.markerListBox,'String'));
            end
            config.autoPanCheckValue = 1;
            config.advanceFrameCheckValue = 1;
        elseif ~isempty(strfind(vru_type,'Pedestrian'))
            config = getappdata(handles.hMain,'config');
            fileName = fullfile(config.rootPathName,'markerLists','PROSPECT_CAR_PED_MARKERS.mat');
            if ~isnumeric(fileName)
                load(fileName);
                set(handles.markerListBox,'String',markerList)
                data.nMarkers = size(markerList,1);
                setappdata(handles.hMain,'data',data)
                data.markerList = cellstr(get(handles.markerListBox,'String'));
            end
            config.autoPanCheckValue = 1;
            config.advanceFrameCheckValue = 1;
        elseif ~isempty(strfind(vru_type,'C')) && isempty(strfind(vru_type,'Cyclist'))
            config = getappdata(handles.hMain,'config');
            fileName = fullfile(config.rootPathName,'markerLists','PROSPECT_CYC_MARKERS.mat');
            if ~isnumeric(fileName)
                load(fileName);
                set(handles.markerListBox,'String',markerList)
                data.nMarkers = size(markerList,1);
                setappdata(handles.hMain,'data',data)
                data.markerList = cellstr(get(handles.markerListBox,'String'));
            end
            config.autoPanCheckValue = 1;
            config.advanceFrameCheckValue = 1;
        elseif ~isempty(strfind(vru_type,'P')) && isempty(strfind(vru_type,'Pedestrian'))
            config = getappdata(handles.hMain,'config');
            fileName = fullfile(config.rootPathName,'markerLists','PROSPECT_PED_MARKERS.mat');
            if ~isnumeric(fileName)
                load(fileName);
                set(handles.markerListBox,'String',markerList)
                data.nMarkers = size(markerList,1);
                setappdata(handles.hMain,'data',data)
                data.markerList = cellstr(get(handles.markerListBox,'String'));
            end
            config.autoPanCheckValue = 1;
            config.advanceFrameCheckValue = 1;
        else
            data.markerList = cellstr(get(handles.markerListBox,'String'));
        end
        %initiate data
        data.timecodes = zeros(data.nFrames,1);
        data.xMeasured = zeros(data.nFrames,data.nMarkers);
        data.yMeasured = zeros(data.nFrames,data.nMarkers);
        data.estimatedState = zeros(4,data.nMarkers, data.nFrames);
        data.P = cell(nFrames,1);

        set(handles.autoPanCheck, 'Value', config.autoPanCheckValue);
        set(handles.advanceFrameCheck, 'Value', config.advanceFrameCheckValue );
        
    end
    
%     for i_frame = 1:nFrames
%         read(reader,i_frame);
%         data.timecodes(i_frame) = reader.CurrentTime-0.04;
%         disp(num2str(i_frame));
%     end
            
    %update appdata
    setappdata(handles.hMain,'data',data)
    
    %set entries in markerListBox
    set(handles.markerListBox,'String',data.markerList)

    %create video screen figure and display first frame
    hScreenFigure = figure();
    set(hScreenFigure,'colormap',gray, 'Pointer', 'crosshair', 'name', [videoFileName ' - MoTrack'],'Tag','Screen','MenuBar','none','toolbar','figure','HandleVisibility','off');
    %delete unnecessary tools in the toolbar
    hToolBar = findall(hScreenFigure,'type','uitoolbar');
    delete(findall(hToolBar,'type','uipushtool'));
    delete(findall(hToolBar,'type','uitogglesplittool'));
    hToggleTools = findall(hToolBar,'type','uitoggletool'); delete(hToggleTools([1:5,9]))
    set(findall(hToolBar,'type','uitoggletool'),'Separator','off')
    
    set(hScreenFigure,'Position',config.screenPosition,'numberTitle','off');
    hScreenAxes = axes('parent',hScreenFigure);  %create axes
    set(hScreenAxes, 'Position',[0 0 1 1], 'XTick', [], 'YTick', [], 'Box', 'off')  %set axes props
    hImage = imagesc(Idisp,'parent',hScreenAxes);  %disp frame on axes
    hold(hScreenAxes,'on')
    handles.hScreenFigure = hScreenFigure; %write handles to handles struct
    handles.hScreenAxes = hScreenAxes;
    handles.hImage = hImage;
    set(handles.hScreenAxes,'UserData',1) %scrollWheel count initiazation
    set(hScreenFigure,'WindowButtonMotionFcn',{@displayCurrentPoint,handles},'WindowScrollWheelFcn',{@scrollWheelZoom,handles})
    screenUserData.beta = 0; % initiat beta for brightness adjustment
    set(hScreenFigure,'userData',screenUserData)
    
    %enable player and options controls
    set(handles.hPlayerControls,'enable','on')
    set(handles.hOptions1Controls,'enable','on')
    set(handles.hOptions2Controls,'enable','on')
    set(handles.menu_fileSave,'enable','on')
    set(handles.menu_fileExportExcel,'enable','on')
    set(handles.menu_fileExportWS,'enable','on')
    set(handles.menu_image,'enable','on')

    %create marker context menu
    hMarkerCM = uicontextmenu('parent',handles.hScreenFigure);
    uimenu(hMarkerCM,'Label','Delete','Callback',{@markerCM_delete,handles});
    uimenu(hMarkerCM,'Label','Delete forwards','Callback',{@markerCM_deleteForwards,handles});
    uimenu(hMarkerCM,'Label','Delete backwards','Callback',{@markerCm_deleteBackwards,handles});
    handles.hMarkerCM = hMarkerCM;
    
    %initialize marker and label handles
    handles.hMarkersPlot = nan(data.nMarkers,1);
    for m = 1:data.nMarkers
        handles.hMarkersPlot(m) = plot(handles.hScreenAxes,nan,nan,'*','color','c');
        set(handles.hMarkersPlot(m),'UIContextMenu',handles.hMarkerCM)
    end
    handles.hMarkersText = text(nan(data.nMarkers,1),nan(data.nMarkers,1), data.markerList,'color','y','parent',handles.hScreenAxes);

    plotMarkersAndLabels(hObject, eventdata, handles)

    %set buttondownfunction for Image
    set(hImage, 'ButtonDownFcn',{@selectPoint,handles})
    %set keypressfunction for figure window and close request function for screen
    set(handles.hScreenFigure,'windowkeypressfcn',{@keypress,handles},'CloseRequestFcn',{@closeScreen,handles})
    set(handles.hMain,'windowkeypressfcn',{@keypress,handles})
    %initiate stop button boolean in stopButton´s user data
    set(handles.playButton,'userData',0)
    %disable marker menu 
    set(handles.menu_marker,'enable','off')
    %updata handles
    guidata(handles.hMain, handles);
end

function scrollWheelZoom(hObject, eventdata, handles)
%mouse scroll wheel zoom function
%uses xlim and ylim to implement the zoom
data = getappdata(handles.hMain,'data');
scrolls = eventdata.VerticalScrollCount;
scrollCount = get(handles.hScreenAxes,'UserData') - scrolls;  %count number of zoom steps - needed to restore the original view before zooming in
oldXLim = get(handles.hScreenAxes,'xLim');
oldYLim = get(handles.hScreenAxes,'yLim');
oldXSize = oldXLim(2) - oldXLim(1);
oldYSize = oldYLim(2) - oldYLim(1);
currentPoint = get(handles.hScreenAxes,'currentPoint');

zoomFactor = scrolls/3;
set(handles.hScreenAxes,'UserData',scrollCount);

if scrollCount > 1
    XShift = sum(oldXLim)/2 - currentPoint(1,1);
    YShift = sum(oldYLim)/2 - currentPoint(1,2);

    if oldXLim(1) - oldXSize * zoomFactor - XShift < 0.5
        XShift2 = XShift - (0.5 - (oldXLim(1) - oldXSize * zoomFactor - XShift));
    elseif oldXLim(2) + oldXSize * zoomFactor - XShift > data.resolution(2) + 0.5
        XShift2 = -XShift - ((data.resolution(2) + 0.5) - (oldXLim(2) + oldXSize * zoomFactor + XShift));
    else
        XShift2 = XShift;
    end
    if oldYLim(1) - oldYSize * zoomFactor - YShift < 0.5
        YShift2 = YShift - (0.5 - (oldYLim(1) - oldYSize * zoomFactor - YShift));
    elseif oldYLim(2) + oldYSize * zoomFactor - YShift > data.resolution(1) + 0.5
        YShift2 = -YShift - ((data.resolution(1) + 0.5) - (oldYLim(2) + oldYSize * zoomFactor + YShift));
    else
        YShift2 = YShift;
    end

    newXLim(1) = oldXLim(1) - oldXSize * zoomFactor - XShift2;
    newXLim(2) = oldXLim(2) + oldXSize * zoomFactor - XShift2;
    newYLim(1) = oldYLim(1) - oldYSize * zoomFactor - YShift2;
    newYLim(2) = oldYLim(2) + oldYSize * zoomFactor - YShift2;

    newXSize = newXLim(2) - newXLim(1);

    if newXSize <= data.resolution(2) + 0.5 && newXLim(1) < newXLim(2) && newYLim(1) < newYLim(2)
        set(handles.hScreenAxes,'XLim', newXLim, 'YLim',newYLim)
    end
else
    set(handles.hScreenAxes,'UserData',1);
    set(handles.hScreenAxes,'XLim', [0.5 data.resolution(2)+0.5], 'YLim',[0.5 data.resolution(1)+0.5])
end

function displayCurrentPoint(hObject, eventdata, handles)
%disply current x and y coordintes in integer pxls
data = getappdata(handles.hMain,'data');
point = get(handles.hScreenAxes,'currentPoint');
set(handles.xDisp,'String',['X: ' sprintf('%0.0f',point(1,1) - 0.5)]);
set(handles.yDisp,'String',['Y: ' sprintf('%0.0f',data.resolution(1) + 0.5 - point(1,2))]);

function markerCM_delete(hObject, eventdata, handles)
%marker context menu delete function (right click on marker)
%delete current frame only
handles = guidata(handles.hMain);
data = getappdata(handles.hMain,'data');
frameNum = str2double(get(handles.frameNum,'String'));
markerInd = handles.hMarkersPlot == gco(handles.hScreenFigure);  %determine which marker was clicked
data.xMeasured(frameNum,markerInd) = 0;
data.yMeasured(frameNum,markerInd) = 0;
setappdata(handles.hMain,'data',data)
plotMarkersAndLabels(hObject, eventdata, handles)

function markerCM_deleteForwards(hObject, eventdata, handles)
%marker context menu delete forward function (right click on marker)
%delete current frame and all subsequent frames
handles = guidata(handles.hMain);
data = getappdata(handles.hMain,'data');
frameNum = str2double(get(handles.frameNum,'String'));
markerInd = handles.hMarkersPlot == gco(handles.hScreenFigure);
data.xMeasured(frameNum:end,markerInd) = 0;
data.yMeasured(frameNum:end,markerInd) = 0;
setappdata(handles.hMain,'data',data)
plotMarkersAndLabels(hObject, eventdata, handles)


function markerCm_deleteBackwards(hObject, eventdata, handles)
%marker context menu delete backward function (right click on marker)
%delete current frame and all previous frames
handles = guidata(handles.hMain);
data = getappdata(handles.hMain,'data');
frameNum = str2double(get(handles.frameNum,'String'));
markerInd = handles.hMarkersPlot == gco(handles.hScreenFigure);
data.xMeasured(1:frameNum,markerInd) = 0;
data.yMeasured(1:frameNum,markerInd) = 0;
setappdata(handles.hMain,'data',data)
plotMarkersAndLabels(hObject, eventdata, handles)
    

function menu_fileSave_Callback(hObject, eventdata, handles)
%save data, config and export in mat file with same directorey and filename like the video file
data = getappdata(handles.hMain,'data');
config = getappdata(handles.hMain,'config'); %#ok<NASGU>
X = data.xMeasured;
Y = data.yMeasured;
data = rmfield(data,'reader');
X(X == 0) = nan;
Y(Y == 0) = nan;
export.X = X - 0.5;
export.Y = data.resolution(1) + 0.5 - Y;
if data.nMarkers > 0 && isfield(data,'xMeasured')
    export.coords = [];
    for m = 1:length(data.markerList)
        export.coords.(data.markerList{m}) = [export.X(:,m), export.Y(:,m)];
    end    
end
export.markerNames = data.markerList; %#ok<STRNU>
save([data.videoPathName data.videoFileName(1:find(data.videoFileName == '.')) 'mat'],'data','export','config')

%save usefull data to trip
trip_file = cell2mat(dirrec(data.videoPathName, '.trip'));
trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, false);
if trip.getMetaInformations().existData('markersTraj_videoRef')
    trip.setIsBaseData('markersTraj_videoRef',0)
    removeDataTables(trip,{'markersTraj_videoRef'});
end
addDataTable2Trip(trip,'markersTraj_videoRef','type','REAL','frequency','25','comment','trajectories of markers point on shapes in video reference')
for i_mark = 1:length(data.markerList)
    addDataVariable2Trip(trip,'markersTraj_videoRef',[data.markerList{i_mark} '_x'],'REAL','unit','pixels','comment',['Trajectory of the ' data.markerList{i_mark} ' marker in x'])
    trip.setBatchOfTimeDataVariablePairs('markersTraj_videoRef',[data.markerList{i_mark} '_x'],[num2cell(0:0.04:length(data.xMeasured(:,i_mark))/25-0.04)', num2cell(data.xMeasured(:,i_mark))]')
    addDataVariable2Trip(trip,'markersTraj_videoRef',[data.markerList{i_mark} '_y'],'REAL','unit','pixels','comment',['Trajectory of the ' data.markerList{i_mark} ' marker in y'])
    trip.setBatchOfTimeDataVariablePairs('markersTraj_videoRef',[data.markerList{i_mark} '_y'],[num2cell(0:0.04:length(data.xMeasured(:,i_mark))/25-0.04)', num2cell(data.yMeasured(:,i_mark))]')
end
trip.setIsBaseData('markersTraj_videoRef',1)
% check data in trip
if length(trip.getAllDataOccurences('markersTraj_videoRef').getVariableValues('timecode')) ~= length(data.xMeasured)
    disp('error while saving data')
end
delete(trip)
disp('data saved')

% --------------------------------------------------------------------
function menu_fileExportWS_Callback(hObject, eventdata, handles)
%assign export to workspace
data = getappdata(handles.hMain,'data');
data.xMeasured(data.xMeasured == 0) = nan;
data.yMeasured(data.yMeasured == 0) = nan;
if data.nMarkers > 0 && isfield(data,'xMeasured')
    coords = [];
    for m = 1:length(data.markerList)
        coords.(data.markerList{m}) = [data.xMeasured(:,m) - 0.5, data.resolution(1) + 0.5 - data.yMeasured(:,m)];
    end
    assignin('base','coords',coords)
    assignin('base','X',data.xMeasured - 0.5)
    assignin('base','Y',data.resolution(1) + 0.5 - data.yMeasured)
    assignin('base','markerNames',data.markerList)
end
% --------------------------------------------------------------------
function menu_fileExportExcel_Callback(hObject, eventdata, handles)
%write export to excel file
data = getappdata(handles.hMain,'data');
xMeasured = data.xMeasured;
yMeasured = data.yMeasured;
xMeasured(xMeasured == 0) = nan;
yMeasured(yMeasured == 0) = nan;
if data.nMarkers > 0 && isfield(data,'xMeasured')
    [fileName, pathName] = uiputfile('*.xls', 'Save coordinate data as');
    if ~isnumeric(fileName)
        output = cell(size(data.xMeasured,1)+1,length(data.markerList)*2);
        for m = 1:length(data.markerList)
            output{1,m*2-1} = ['x_' data.markerList{m}];
            output{1,m*2} = ['y_' data.markerList{m}];
            output(2:end,m*2-1) = num2cell(xMeasured(:,m) - 0.5);
            output(2:end,m*2) = num2cell(data.resolution(1) + 0.5 - yMeasured(:,m));
        end
        frameList = vertcat({'frame'},num2cell(1:data.nFrames)');
        output = horzcat(frameList, output);
        [status,~] = xlswrite([pathName, fileName],output);
        %alternatively write to csv if xlswrite fails
        if ~status
            cell2csv([pathName, fileName(1:find(fileName == '.')) 'csv'],output)
        end
    end
end


% --- Executes on slider movement.
function frameSlider_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
data = getappdata(handles.hMain,'data');
frameNum = round(get(hObject,'Value'));
set(handles.frameNum,'String',num2str(frameNum));
loadFrame(hObject, eventdata, handles)

%auto pan if option is selected
if get(handles.autoPanCheck,'Value')
    oldXLim = get(handles.hScreenAxes,'xLim');
    oldYLim = get(handles.hScreenAxes,'yLim');
    oldXSize = oldXLim(2) - oldXLim(1);
    oldYSize = oldYLim(2) - oldYLim(1);
    markerIndex = get(handles.markerListBox,'Value');
    newXLim(1) = data.xMeasured(frameNum,markerIndex) - oldXSize/2;
    newXLim(2) = data.xMeasured(frameNum,markerIndex) + oldXSize/2;
    newYLim(1) = data.yMeasured(frameNum,markerIndex) - oldYSize/2;
    newYLim(2) = data.yMeasured(frameNum,markerIndex) + oldYSize/2;
    if newXLim(1)>0 && newXLim(2)<data.resolution(2) && newYLim(1)>0 && newYLim(2)<data.resolution(1)
        set(handles.hScreenAxes,'XLim', newXLim, 'YLim',newYLim)
    else
        set(handles.hScreenAxes,'XLim', oldXLim, 'YLim',oldYLim)
    end
end

plotMarkersAndLabels(hObject,eventdata,handles)
set(handles.frameSlider,'enable','off')
drawnow
set(handles.frameSlider,'enable','on')


% --- Executes during object creation, after setting all properties.
function frameSlider_CreateFcn(hObject, eventdata, handles)

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function menu_markerAdd_Callback(hObject, eventdata, handles)
%add marker to marker list
markerName = inputdlg('Markername','Add');
if ~isempty(markerName) && ~isempty(markerName{1})
    data = getappdata(handles.hMain,'data');
    markerList = get(handles.markerListBox,'String');
    if ~isempty(markerList)
        markerList = vertcat(cellstr(markerList),markerName);
    else
        markerList = markerName;
    end
    set(handles.markerListBox,'String',char(markerList))
    if ~isempty(markerList)
        data.nMarkers = size(markerList,1);
    else
        data.nMarkers = 0;
    end
    setappdata(handles.hMain,'data',data)
end

% --------------------------------------------------------------------
function menu_markerDelete_Callback(hObject, eventdata, handles)
%delete marker from marker list
markerList = get(handles.markerListBox,'String');
if ~isempty(markerList)
   data = getappdata(handles.hMain,'data');
   value = get(handles.markerListBox,'Value');
   markerList(value,:) = [];
   set(handles.markerListBox,'Value',1)
   set(handles.markerListBox,'String',markerList)
   if ~isempty(markerList)
        data.nMarkers = size(markerList,1);
   else
        data.nMarkers = 0;
   end
   setappdata(handles.hMain,'data',data)
end

% --------------------------------------------------------------------
function menu_markerDeleteAll_Callback(hObject, eventdata, handles)
set(handles.markerListBox,'String','')


% --------------------------------------------------------------------
function menu_markerOpenList_Callback(hObject, eventdata, handles)

config = getappdata(handles.hMain,'config');
if exist(fullfile(config.rootPathName,'markerLists'),'dir')
    [fileName, pathName] = uigetfile(fullfile(config.rootPathName,'markerLists','*.mat'),'Save Marker List File');
else
    [fileName, pathName] = uigetfile(fullfile(config.rootPathName,'*.mat'),'Save Marker List File');
end
if ~ isnumeric(fileName)
    data = getappdata(handles.hMain,'data');
    load(fullfile(pathName, fileName));
    set(handles.markerListBox,'String',markerList)
    if ~isempty(markerList)
        data.nMarkers = size(markerList,1);
    else
        data.nMarkers = 0;
    end
    setappdata(handles.hMain,'data',data)
end

% --------------------------------------------------------------------
function menu_markerSaveList_Callback(hObject, eventdata, handles)

config = getappdata(handles.hMain,'config');
if exist(fullfile(config.rootPathName,'markerLists'),'dir')
    [fileName, pathName] = uiputfile(fullfile(config.rootPathName,'markerLists','*.mat'),'Select Marker List File');
else
    [fileName, pathName] = uiputfile(fullfile(config.rootPathName,'*.mat'),'Select Marker List File');
end
if ~isnumeric(fileName)
    markerList = get(handles.markerListBox,'String'); %#ok<NASGU>
    save(fullfile(pathName, fileName),'markerList');
end


function closeMain(hObject, eventdata, handles)

config = getappdata(handles.hMain,'config');
hScreenFigure = findall(0,'Tag','Screen');
handles.hScreenFigure = hScreenFigure;
if ishandle(hScreenFigure)  %close screen and store windowposition
    closeScreen(hObject, eventdata, handles)
%     config.screenPosition = get(hScreenFigure,'Position');
%     delete(hScreenFigure)
end
check = get(handles.hMain,'userdata');

if isempty(check) || ismember(check.saveQuest,{'Yes','No'})
    %store main configurations
    config.threshold = str2double(get(handles.threshold,'String'));
    config.searchRadius = str2double(get(handles.searchRadius,'String'));
    config.maxArea = str2double(get(handles.maxArea,'String'));
    config.minArea = str2double(get(handles.minArea,'String'));
    config.minSolidity = str2double(get(handles.minSolidity,'String'));
    config.maxEccentricity = str2double(get(handles.maxEccentricity,'String'));
    config.markerList = get(handles.markerListBox, 'String');

    config.thresholdDisplayCheckValue = get(handles.thresholdDisplayCheck,'Value');
    config.greyscaleCheckValue = get(handles.greyscaleCheck,'Value');
    config.labelsCheckValue = get(handles.labelsCheck,'Value');
    config.autoPanCheckValue  = get(handles.autoPanCheck, 'Value');
    config.autoTrackCheckValue  = get(handles.autoTrackCheck, 'Value');
    config.advanceFrameCheckValue  = get(handles.advanceFrameCheck, 'Value');
    config.advanceMarkerCheckValue = get(handles.advanceMarkerCheck, 'Value');

    config.mainPosition = get(handles.hMain,'Position');
    save([config.rootPathName '\config.mat'],'config');
    delete(handles.hMain);  
end

function closeScreen(hObject, eventdata, handles) %#ok<*INUSL>
%set play button to stop state
if get(handles.playButton,'userData')
    playButton_Callback(hObject, eventdata, handles)
end
saveQuest = questdlg('Save this project?','MoTrack','Yes','No','Cancel','Cancel');
check = get(handles.hMain,'userdata');
check.saveQuest = saveQuest;
set(handles.hMain,'userdata',check)
switch saveQuest
    case 'No'
        %store window position if screen is being closed
        config = getappdata(handles.hMain,'config');
        config.screenPosition = get(handles.hScreenFigure,'Position');
        setappdata(handles.hMain,'config',config)
        delete(handles.hScreenFigure)
        set(handles.menu_marker,'enable','on')
        %disable player and options panel
        set(handles.hPlayerControls,'enable','off')
        set(handles.hOptions1Controls,'enable','off')
        set(handles.hOptions2Controls,'enable','off')
        set(handles.menu_fileSave,'enable','off')
        set(handles.menu_fileExportExcel,'enable','off')
        set(handles.menu_fileExportWS,'enable','off')
        set(handles.menu_image,'enable','off')
        %fo not display coordinates if no screen window is opened
        set(handles.xDisp,'String','')
        set(handles.yDisp,'String','')
    case 'Yes'
        menu_fileSave_Callback(hObject, eventdata, handles)
        %store window position if screen is being closed
        config = getappdata(handles.hMain,'config');
        config.screenPosition = get(handles.hScreenFigure,'Position');
        setappdata(handles.hMain,'config',config)
        delete(handles.hScreenFigure)
        set(handles.menu_marker,'enable','on')
        %disable player and options panel
        set(handles.hPlayerControls,'enable','off')
        set(handles.hOptions1Controls,'enable','off')
        set(handles.hOptions2Controls,'enable','off')
        set(handles.menu_fileSave,'enable','off')
        set(handles.menu_fileExportExcel,'enable','off')
        set(handles.menu_fileExportWS,'enable','off')
        set(handles.menu_image,'enable','off')
        %fo not display coordinates if no screen window is opened
        set(handles.xDisp,'String','')
        set(handles.yDisp,'String','')
    case 'default'
end
function menu_file_Callback(hObject, eventdata, handles)

function menu_marker_Callback(hObject, eventdata, handles)

function searchRadius_Callback(hObject, eventdata, handles)

function minArea_Callback(hObject, eventdata, handles)

function maxArea_Callback(hObject, eventdata, handles)

function minSolidity_Callback(hObject, eventdata, handles)

function maxEccentricity_Callback(hObject, eventdata, handles)

function markerListBox_Callback(hObject, eventdata, handles)

% --- Executes on button press in labelsCheck.
function labelsCheck_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of labelsCheck
    set(handles.labelsCheck,'enable','off')
    drawnow
    set(handles.labelsCheck,'enable','on')
    plotMarkersAndLabels(hObject, eventdata, handles)

% --- Executes on button press in thresholdDisplayCheck.
function thresholdDisplayCheck_Callback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of thresholdDisplayCheck
    set(handles.thresholdDisplayCheck,'enable','off')
    drawnow
    set(handles.thresholdDisplayCheck,'enable','on')
    loadFrame(hObject, eventdata, handles)
    
function greyscaleCheck_Callback(hObject, eventdata, handles)
    set(handles.greyscaleCheck,'enable','off')
    drawnow
    set(handles.greyscaleCheck,'enable','on')
    loadFrame(hObject, eventdata, handles)
    
function advanceMarkerCheck_Callback(hObject, eventdata, handles)
    set(handles.advanceMarkerCheck,'enable','off')
    drawnow
    set(handles.advanceMarkerCheck,'enable','on')

function advanceFrameCheck_Callback(hObject, eventdata, handles)
    set(handles.advanceFrameCheck,'enable','off')
    drawnow
    set(handles.advanceFrameCheck,'enable','on')

function autoTrackCheck_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSD>
    set(handles.autoTrackCheck,'enable','off')
    drawnow
    set(handles.autoTrackCheck,'enable','on')
    
function autoPanCheck_Callback(hObject, eventdata, handles)
    set(handles.autoPanCheck,'enable','off')
    drawnow
    set(handles.autoPanCheck,'enable','on')
    
function menu_help_Callback(hObject, eventdata, handles)

function menu_image_Callback(hObject, eventdata, handles)
imControl() %call imControl GUI
