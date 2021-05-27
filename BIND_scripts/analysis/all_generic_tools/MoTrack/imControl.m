function varargout = imControl(varargin)

% This file is part of MoTrack.
% 
% MoTrack is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% MoTrack is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with MoTrack.  If not, see <http://www.gnu.org/licenses/>.

% Copyright (c) Josef Christian


% IMCONTROL MATLAB code for imControl.fig
%      IMCONTROL, by itself, creates a new IMCONTROL or raises the existing
%      singleton*.
%
%      H = IMCONTROL returns the handle to a new IMCONTROL or the handle to
%      the existing singleton*.
%
%      IMCONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMCONTROL.M with the given input arguments.
%
%      IMCONTROL('Property','Value',...) creates a new IMCONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imControl_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imControl_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imControl

% Last Modified by GUIDE v2.5 17-Jun-2014 14:59:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @imControl_OpeningFcn, ...
                   'gui_OutputFcn',  @imControl_OutputFcn, ...
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




% --- Executes just before imControl is made visible.
function imControl_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imControl (see VARARGIN)

hScreenFigure = findall(0,'Tag','Screen');
data = get(hScreenFigure,'userData');
set(handles.brightnessSlider,'value',data.beta)

% Choose default command line output for imControl
handles.imControl = hObject;
% data.beta = 0;
% setappdata(handles.imControl,'data',data);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes imControl wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = imControl_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.imControl;


% --- Executes on slider movement.
function brightnessSlider_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
%apply the change in brightness level to the image
hScreenFigure = findall(0,'Tag','Screen');
data = get(hScreenFigure,'userData');
brighten(hScreenFigure,-data.beta);
beta = get(handles.brightnessSlider,'value');
brighten(hScreenFigure,beta);
data.beta = beta;
set(hScreenFigure,'userData',data)



% --- Executes during object creation, after setting all properties.
function brightnessSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
