function varargout = carfollowing(varargin)
% carfollowing M-file for carfollowing.fig
%      carfollowing, by itself, creates a new carfollowing or raises the existing
%      singleton*.
%
%      H = carfollowing returns the handle to a new carfollowing or the handle to
%      the existing singleton*.
%
%      carfollowing('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in carfollowing.M with the given input arguments.
%
%      carfollowing('Property','Value',...) creates a new carfollowing or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before carfollowing_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to carfollowing_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help carfollowing

% Last Modified by GUIDE v2.5 05-Jun-2009 11:03:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @carfollowing_OpeningFcn, ...
    'gui_OutputFcn',  @carfollowing_OutputFcn, ...
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

% --- Executes just before carfollowing is made visible.
function carfollowing_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to carfollowing (see VARARGIN)

% Choose default command line output for carfollowing
handles.output = hObject;
handles.rounder = 100;
set(handles.trajectory,'XGrid','on')
% start of ugly hack
set(gcf,'toolbar','figure');
tools = findall(gcf,'Type','uitoolbar');
items = findall(tools);
trowaway = [2 3 4 5 6 7 9 13 14 15 16 17];
delete(items(trowaway));
% end of ugly hack

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using carfollowing.

% UIWAIT makes carfollowing wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = carfollowing_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, directory] = uigetfile('*.ev1');
if ~isequal(file, 0)
    newData1 = importdata(fullfile(directory,file));
    handles.FileName = file;
    handles.Directory = directory;
    % Create new variables in the base workspace from those fields.
    RawData.Code = newData1.data(:,1);
    RawData.Time = newData1.data(:,2);
    RawData.Lead = newData1.data(:,3);
    RawData.Follow = newData1.data(:,4);
    Code.Speed      = 0;
    Code.BeginBlock = 1;
    Code.EndBlock   = 2;
    
    for (i = 1:length(newData1.textdata(:,1)))
        if (findstr(cell2mat(newData1.textdata(i,1)), 'RPeak=')==1)
            SpeedLine = cell2mat(newData1.textdata(i,1));
            Code.Speed = str2num(SpeedLine(7:end));
        end
        if (findstr(cell2mat(newData1.textdata(i,1)), 'BeginBlock=')==1)
            BeginBlock = cell2mat(newData1.textdata(i,1));
            Code.BeginBlock = str2num(BeginBlock(12:end));
        end
        if (findstr(cell2mat(newData1.textdata(i,1)), 'EndBlock=')==1)
            EndBlock = cell2mat(newData1.textdata(i,1));
            Code.EndBlock = str2num(EndBlock(10:end));
        end
    end
    
    handles.Data.Blocks = length(find(RawData.Code == Code.BeginBlock));
    BlockBegin  = find(RawData.Code == Code.BeginBlock);
    BlockEnd    = find(RawData.Code == Code.EndBlock);
    
    set (handles.BlockBack, 'Enable', 'off');
    set (handles.BlockNext, 'Enable', 'off');
    
    for (i = 1:handles.Data.Blocks)
        code                         = RawData.Code(BlockBegin(i):BlockEnd(i));
        handles.Data.Block{i}.Time   = RawData.Time(BlockBegin(i):BlockEnd(i));
        handles.Data.Block{i}.Lead   = RawData.Lead(BlockBegin(i):BlockEnd(i));
        handles.Data.Block{i}.Follow = RawData.Follow(BlockBegin(i):BlockEnd(i));
        handles.Data.Block{i}.Time   = handles.Data.Block{i}.Time(find(code == Code.Speed));
        
        handles.Data.Block{i}.Time   = handles.Data.Block{i}.Time -  handles.Data.Block{i}.Time(1);
        handles.Data.Block{i}.Lead   = handles.Data.Block{i}.Lead(find(code == Code.Speed));
        handles.Data.Block{i}.Follow = handles.Data.Block{i}.Follow(find(code == Code.Speed));
        handles.Data.Block{i}.Params.Fs    = round(1/(handles.Data.Block{i}.Time(2)-handles.Data.Block{i}.Time(1))); % sampling frequency
        handles.Data.Block{i}.Params.dT    = 1/handles.Data.Block{i}.Params.Fs;
        
        L = length(handles.Data.Block{i}.Follow);
        handles.Data.Block{i}.Params.NFFT = 2^nextpow2(L); % Next power of 2 from length of y
        
        handles.Data.Block{i}.Params.StartSelection = handles.Data.Block{i}.Time(1);
        handles.Data.Block{i}.Params.EndSelection   = handles.Data.Block{i}.Time(end);
        
        handles.Data.Block{i}.Calc.FFTFollow = fft(handles.Data.Block{i}.Follow-mean(handles.Data.Block{i}.Follow), handles.Data.Block{i}.Params.NFFT)/L;
        handles.Data.Block{i}.Calc.FFTfreqs  = handles.Data.Block{i}.Params.Fs/2*linspace(0,1,handles.Data.Block{i}.Params.NFFT/2+1);
        %
        L = length(handles.Data.Block{i}.Lead);
        handles.Data.Block{i}.Calc.FFTLead = fft(handles.Data.Block{i}.Lead-mean(handles.Data.Block{i}.Lead), handles.Data.Block{i}.Params.NFFT)/L;
        %
        handles.Data.Block{i}.Calc.FilteredLeadFFT   = filter(ones(3,1)/3, 1, 2*abs(handles.Data.Block{i}.Calc.FFTLead(1:handles.Data.Block{i}.Params.NFFT/2+1)));
        handles.Data.Block{i}.Calc.FilteredFollowFFT = filter(ones(3,1)/3, 1, 2*abs(handles.Data.Block{i}.Calc.FFTFollow(1:handles.Data.Block{i}.Params.NFFT/2+1)));
        %
        [handles.Data.Block{i}.Calc.top, handles.Data.Block{i}.Calc.index] = max(handles.Data.Block{i}.Calc.FilteredLeadFFT);
        handles.Data.Block{i}.Params.MainFrequency      = [handles.Data.Block{i}.Calc.FFTfreqs(handles.Data.Block{i}.Calc.index) handles.Data.Block{i}.Calc.index];
        %
        lower = find(handles.Data.Block{i}.Calc.FilteredLeadFFT(1:handles.Data.Block{i}.Calc.index(1)) < (.5*handles.Data.Block{i}.Calc.top));
        handles.Data.Block{i}.Params.LowFrequencyIndex = [handles.Data.Block{i}.Calc.FFTfreqs(lower(end)) lower(end)];
        
        handles.Data.Block{i}.Params.LowFrequencyIndex(1) =  max(floor(handles.rounder * ...
            handles.Data.Block{i}.Params.LowFrequencyIndex(1))...
            /handles.rounder, handles.Data.Block{i}.Calc.FFTfreqs(2));


        [dum, handles.Data.Block{i}.Params.LowFrequencyIndex(2)] =  ...
            min(abs(handles.Data.Block{i}.Calc.FFTfreqs - ...
                    handles.Data.Block{i}.Params.LowFrequencyIndex(1))) ;

        %
        upper = find(handles.Data.Block{i}.Calc.FilteredLeadFFT(handles.Data.Block{i}.Calc.index(1):end) < (.5*handles.Data.Block{i}.Calc.top));
        handles.Data.Block{i}.Params.HighFrequencyIndex = [handles.Data.Block{i}.Calc.FFTfreqs(upper(1)+handles.Data.Block{i}.Calc.index(1)) upper(1)+handles.Data.Block{i}.Calc.index(1)];
        
        handles.Data.Block{i}.Params.HighFrequencyIndex(1) = ceil(handles.rounder * ...
            handles.Data.Block{i}.Params.HighFrequencyIndex(1))...
            /handles.rounder;

        [dum, handles.Data.Block{i}.Params.HighFrequencyIndex(2)] =  ...
            min(abs(handles.Data.Block{i}.Calc.FFTfreqs - ...
                    handles.Data.Block{i}.Params.HighFrequencyIndex(1))) ;

        %
        x = handles.Data.Block{i}.Lead -   mean(handles.Data.Block{i}.Lead);      %!!!!!!!!!!!!!!!!!!!!!
        y = handles.Data.Block{i}.Follow - mean(handles.Data.Block{i}.Follow);    %!!!!!!!!!!!!!!!!!!!!!
        %
        [ handles.Data.Block{i}.Calc.Pxx, handles.Data.Block{i}.Calc.Pyy, handles.Data.Block{i}.Calc.Pxy, ...
            handles.Data.Block{i}.Calc.Cxy, handles.Data.Block{i}.Calc.pha, handles.Data.Block{i}.Calc.phaseinsec, ...
            handles.Data.Block{i}.Calc.gain, handles.Data.Block{i}.Calc.F ] = ...
            coherence( x, y,[],[],handles.Data.Block{i}.Params.NFFT, handles.Data.Block{i}.Params.Fs);
        
        handles.CurrentBlock = i;
        handles = ReCalc(hObject, handles, false);
    end
    
    if (handles.Data.Blocks > 1)
        set (handles.BlockNext, 'Enable', 'on');
    end
    
    set (handles.fulltime, 'Enable', 'on');
    set (handles.fscalc, 'Enable', 'on');
    
    handles.CurrentBlock = 1;
    handles = PlotTrajectory(hObject, handles);
    handles = ReCalc(hObject, handles, false);
    guidata(hObject, handles);
end

function handles = ReCalc(hObject, handles, doplot)

i = handles.CurrentBlock;

start = find(handles.Data.Block{i}.Time >= handles.Data.Block{i}.Params.StartSelection);
last  = find(handles.Data.Block{i}.Time <= handles.Data.Block{i}.Params.EndSelection);

start = start(1);
last=last(end);

L = last-start;

lfi = handles.Data.Block{i}.Params.LowFrequencyIndex(2);    
hfi = handles.Data.Block{i}.Params.HighFrequencyIndex(2);   

handles.Data.Block{i}.Calc.NFFT             = 2^nextpow2(L); % Next power of 2 from length of y
handles.Data.Block{i}.Calc.FFTFollow        = fft(handles.Data.Block{i}.Follow(start:last)-mean(handles.Data.Block{i}.Follow(start:last)), handles.Data.Block{i}.Calc.NFFT)/L;
handles.Data.Block{i}.Calc.FFTfreqs         = handles.Data.Block{i}.Params.Fs/2*linspace(0,1,handles.Data.Block{i}.Calc.NFFT/2+1);
handles.Data.Block{i}.Calc.FFTLead          = fft(handles.Data.Block{i}.Lead(start:last)-mean(handles.Data.Block{i}.Lead(start:last)), handles.Data.Block{i}.Calc.NFFT)/L;
handles.Data.Block{i}.Calc.FilteredLeadFFT  = filter(ones(3,1)/3, 1, 2*abs(handles.Data.Block{i}.Calc.FFTLead(1:handles.Data.Block{i}.Calc.NFFT/2+1)));
handles.Data.Block{i}.Calc.FilteredFollowFFT= filter(ones(3,1)/3, 1, 2*abs(handles.Data.Block{i}.Calc.FFTFollow(1:handles.Data.Block{i}.Calc.NFFT/2+1)));
% [handles.Data.Block{i}.Calc.top, ...
%     handles.Data.Block{i}.Calc.index]            = max(handles.Data.Block{i}.Calc.FilteredLeadFFT);
% 
% lower = find(handles.Data.Block{i}.Calc.FilteredLeadFFT(1:handles.Data.Block{i}.Calc.index(1)) < (.5*handles.Data.Block{i}.Calc.top));
% handles.Data.Block{i}.Params.LowFrequencyIndex = [handles.Data.Block{i}.Calc.FFTfreqs(lower(end)) lower(end)];
% 
% upper = find(handles.Data.Block{i}.Calc.FilteredLeadFFT(handles.Data.Block{i}.Calc.index(1):end) < (.5*handles.Data.Block{i}.Calc.top));
% handles.Data.Block{i}.Params.HighFrequencyIndex = [handles.Data.Block{i}.Calc.FFTfreqs(upper(1)+handles.Data.Block{i}.Calc.index(1)) upper(1)+handles.Data.Block{i}.Calc.index(1)];

handles.Data.Block{i}.Params.StartSelection = handles.Data.Block{i}.Time(start);
handles.Data.Block{i}.Params.EndSelection   = handles.Data.Block{i}.Time(last);

x = handles.Data.Block{i}.Lead(start:last) - mean(handles.Data.Block{i}.Lead(start:last));
y = handles.Data.Block{i}.Follow(start:last) - mean(handles.Data.Block{i}.Follow(start:last));

%[handles.Cxy{i} handles.F{i}] = mscohere(x,y,[],[],handles.Data.Block{i}.NFFT, handles.Fs{i});

        [ handles.Data.Block{i}.Calc.Pxx, handles.Data.Block{i}.Calc.Pyy, handles.Data.Block{i}.Calc.Pxy, ...
            handles.Data.Block{i}.Calc.Cxy, handles.Data.Block{i}.Calc.pha, handles.Data.Block{i}.Calc.phaseinsec, ...
            handles.Data.Block{i}.Calc.gain, handles.Data.Block{i}.Calc.F ] = ...
            coherence( x, y,[],[],handles.Data.Block{i}.Params.NFFT, handles.Data.Block{i}.Params.Fs);
        

handles.Data.Block{i}.Output.Coherences    = mean(handles.Data.Block{i}.Calc.Cxy(lfi(1):hfi(end)));
handles.Data.Block{i}.Output.Phases        = mean(handles.Data.Block{i}.Calc.phaseinsec(lfi(1):hfi(end)));
handles.Data.Block{i}.Output.Gains         = mean(handles.Data.Block{i}.Calc.gain(lfi(1):hfi(end)));
handles.Data.Block{i}.Output.CoherencesStd = std(handles.Data.Block{i}.Calc.Cxy(lfi(1):hfi(end)));
handles.Data.Block{i}.Output.PhasesStd     = std(handles.Data.Block{i}.Calc.phaseinsec(lfi(1):hfi(end)));
handles.Data.Block{i}.Output.GainsStd      = std(handles.Data.Block{i}.Calc.gain(lfi(1):hfi(end)));

guidata(hObject, handles);
if (doplot) UpdatePlot(hObject,handles);
end

function UpdatePlot(hObject,handles);

set(handles.coherenceline, 'XData', handles.Data.Block{handles.CurrentBlock}.Calc.F);
set(handles.coherenceline, 'YData', handles.Data.Block{handles.CurrentBlock}.Calc.Cxy);

set(handles.ltraject, 'XData', handles.Data.Block{handles.CurrentBlock}.Calc.FFTfreqs)
set(handles.ltraject, 'YData', handles.Data.Block{handles.CurrentBlock}.Calc.FilteredLeadFFT);

set(handles.ftraject, 'XData', handles.Data.Block{handles.CurrentBlock}.Calc.FFTfreqs)
set(handles.ftraject, 'YData', handles.Data.Block{handles.CurrentBlock}.Calc.FilteredFollowFFT);

set(handles.phaseline,'XData', handles.Data.Block{handles.CurrentBlock}.Calc.F);
set(handles.phaseline,'YData', handles.Data.Block{handles.CurrentBlock}.Calc.phaseinsec);

xlimits = get(handles.phase,'XLim');
ylimits = get(handles.phase,'YLim');
xinc = (xlimits(2)-xlimits(1))/5;
yinc = (ylimits(2)-ylimits(1))/5;

set(handles.phase,'XTick',[xlimits(1):xinc:xlimits(2)],...
    'YTick',[ylimits(1):yinc:ylimits(2)])

set(handles.Coh,        'String', handles.Data.Block{handles.CurrentBlock}.Output.Coherences);
set(handles.Phase,      'String', handles.Data.Block{handles.CurrentBlock}.Output.Phases);
set(handles.Gain,       'String', handles.Data.Block{handles.CurrentBlock}.Output.Gains);

set(handles.CohStd,     'String', handles.Data.Block{handles.CurrentBlock}.Output.CoherencesStd);
set(handles.PhaseStd,   'String', handles.Data.Block{handles.CurrentBlock}.Output.PhasesStd);
set(handles.GainStd,    'String', handles.Data.Block{handles.CurrentBlock}.Output.GainsStd);

set(handles.StartTime,  'String', handles.Data.Block{handles.CurrentBlock}.Params.StartSelection);
set(handles.EndTime,    'String', handles.Data.Block{handles.CurrentBlock}.Params.EndSelection);

%   PlotTrajectory(hObject, handles);

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)


function handles = PlotTrajectory(hObject, handles)
% Initial Plotting

set (handles.BlockNumberText, 'String', sprintf('File: %s - Block # %d of %d.', handles.FileName, handles.CurrentBlock, handles.Data.Blocks));
% Plot trajectories
hold(handles.trajectory, 'off');
plot(handles.trajectory, handles.Data.Block{handles.CurrentBlock}.Time, handles.Data.Block{handles.CurrentBlock}.Lead,  'b');

hold(handles.trajectory, 'on');
plot(handles.trajectory, handles.Data.Block{handles.CurrentBlock}.Time, handles.Data.Block{handles.CurrentBlock}.Follow, 'r');

title(handles.trajectory,'Speed of Lead and Following Cars');
xlabel(handles.trajectory,'Time (sec)');
ylabel(handles.trajectory,'Speed (m/s)');

ylim(handles.trajectory, 'auto')
set(handles.trajectory, 'XGrid', 'on');

hold(handles.lead, 'off');
handles.ltraject = plot(handles.lead,   handles.Data.Block{handles.CurrentBlock}.Calc.FFTfreqs, ...
    handles.Data.Block{handles.CurrentBlock}.Calc.FilteredLeadFFT, 'b');

title(handles.lead,'Single-Sided Amplitude Spectrum of Lead Car Trajectory');

xlim(handles.lead, [0 .1]);
xlabel(handles.lead,'Frequency (Hz)');
ylabel(handles.lead,'|Magnitude(f)|');

hold(handles.follow, 'off');
handles.ftraject = plot(handles.follow,   handles.Data.Block{handles.CurrentBlock}.Calc.FFTfreqs, ...
    handles.Data.Block{handles.CurrentBlock}.Calc.FilteredFollowFFT, 'b');

title(handles.follow,'Single-Sided Amplitude Spectrum of Following Car Trajectory');
xlim(handles.follow, [0 .1]);
xlabel(handles.follow,'Frequency (Hz)');
ylabel(handles.follow,'|Magnitude(f)|');

handles.Data.Gui{handles.CurrentBlock}.TopCursor   = ...
    vcursor([handles.lead handles.follow], ...
    handles.Data.Block{handles.CurrentBlock}.Calc.FFTfreqs(handles.Data.Block{handles.CurrentBlock}.Calc.index(1)),...
    @movetop, ':',[229 145 186]/500);

handles.Data.Gui{handles.CurrentBlock}.UpperCursor = ...
    vcursor([handles.lead handles.follow], ...
    handles.Data.Block{handles.CurrentBlock}.Params.HighFrequencyIndex(1), @moveupper, '-',[229 145 186]/500);

handles.Data.Gui{handles.CurrentBlock}.LowerCursor = ...
    vcursor([handles.lead handles.follow], ...
    handles.Data.Block{handles.CurrentBlock}.Params.LowFrequencyIndex(1),  @movelower, '-',[229 145 186]/500);

% lfi = handles.Data.Block{i}.Params.LowFrequencyIndex(2);    
% hfi = handles.Data.Block{i}.Params.HighFrequencyIndex(2);   

handles.Data.Gui{handles.CurrentBlock}.StartSelectionCursor = ...
    vcursor(handles.trajectory, handles.Data.Block{handles.CurrentBlock}.Params.StartSelection, ...
    @movestartselection, '-',[229 145 186]/500);
handles.Data.Gui{handles.CurrentBlock}.EndSelectionCursor   = ...
    vcursor(handles.trajectory, handles.Data.Block{handles.CurrentBlock}.Params.EndSelection, ...
    @moveendselection,   '-',[229 145 186]/500);

set(handles.Top, 'String', sprintf('%4.3f', ...
    handles.Data.Block{handles.CurrentBlock}.Params.MainFrequency(1)));
set(handles.Lower, 'String', sprintf('%4.3f', ...
    handles.Data.Block{handles.CurrentBlock}.Params.LowFrequencyIndex(1)));
set(handles.Upper, 'String', sprintf('%4.3f', ...
    handles.Data.Block{handles.CurrentBlock}.Params.HighFrequencyIndex(1)));

linkaxes([handles.lead handles.follow], 'xy')

setAllowAxesPan(pan,handles.trajectory,true);
setAllowAxesPan(pan,handles.lead,false);
setAllowAxesPan(pan,handles.follow,false);

setAllowAxesZoom(zoom,handles.trajectory,true);
setAllowAxesZoom(zoom,handles.lead,false);
setAllowAxesZoom(zoom,handles.follow,false);

setAxesZoomMotion(zoom,handles.trajectory,'horizontal');
setAxesPanMotion(pan,handles.trajectory,'horizontal');

handles = ReCalc(hObject, handles, false);

set(handles.Coh,        'String', handles.Data.Block{handles.CurrentBlock}.Output.Coherences);
set(handles.Phase,      'String', handles.Data.Block{handles.CurrentBlock}.Output.Phases);
set(handles.Gain,       'String', handles.Data.Block{handles.CurrentBlock}.Output.Gains);

set(handles.CohStd,     'String', handles.Data.Block{handles.CurrentBlock}.Output.CoherencesStd);
set(handles.PhaseStd,   'String', handles.Data.Block{handles.CurrentBlock}.Output.PhasesStd);
set(handles.GainStd,    'String', handles.Data.Block{handles.CurrentBlock}.Output.GainsStd);

set(handles.StartTime,  'String', handles.Data.Block{handles.CurrentBlock}.Params.StartSelection);
set(handles.EndTime,    'String', handles.Data.Block{handles.CurrentBlock}.Params.EndSelection);

hold(handles.coherence, 'off');

handles.coherenceline = plot(handles.coherence, handles.Data.Block{handles.CurrentBlock}.Calc.F, ...
    handles.Data.Block{handles.CurrentBlock}.Calc.Cxy,  'b');

hold(handles.coherence, 'on');
title(handles.coherence,'Coherence function (blue) and Phase function (red)');
xlabel(handles.coherence,'Frequency (Hz)');
ylabel(handles.coherence,'Magnitude squared coherence');
xlim(handles.coherence, [0 .1])
ylim(handles.coherence, [0 1])
hold(handles.coherence, 'off');

if exist('handles.phase')
    delete(handles.phase);
end

handles.phase = axes('Position',get(handles.coherence,'Position'),...
    'XAxisLocation','bottom',...
    'YAxisLocation','right',...
    'Color','none',...
    'XColor','k','YColor','k');

ylabel(handles.phase,'Phase(lag) in seconds');

xlimits = get(handles.coherence,'XLim');
ylimits = get(handles.coherence,'YLim');
xinc = (xlimits(2)-xlimits(1))/5;
yinc = (ylimits(2)-ylimits(1))/5;
set(handles.coherence,'XTick',[xlimits(1):xinc:xlimits(2)],...
    'YTick',[ylimits(1):yinc:ylimits(2)])

if (exist('handles.phaseline', 'var'))
    delete(handles.phaseline);
end
handles.phaseline = line(handles.Data.Block{handles.CurrentBlock}.Calc.F,...
        handles.Data.Block{handles.CurrentBlock}.Calc.phaseinsec, 'Parent', handles.phase, 'Color', 'r');
xlim(handles.phase, [0 .1])
ylim(handles.phase, [0 10])

xlimits = get(handles.phase,'XLim');
ylimits = get(handles.phase,'YLim');
xinc = (xlimits(2)-xlimits(1))/5;
yinc = (ylimits(2)-ylimits(1))/5;
set(handles.phase,'XTick',[xlimits(1):xinc:xlimits(2)],...
    'YTick',[ylimits(1):yinc:ylimits(2)])
ylim(handles.phase, [0 ylimits(2)]);
grid (handles.phase, 'on');
hold(handles.coherence, 'off');

guidata(gcf, handles);

function movestartselection(fig)
ud=guidata(gcbo);
x = get(ud.Data.Gui{ud.CurrentBlock}.StartSelectionCursor, 'XData'); x = x(1);
ud.Data.Block{ud.CurrentBlock}.Params.StartSelection = x;
set(ud.StartTime, 'String', sprintf('%4.2f', x));
guidata(fig, ud);
ReCalc(fig,ud, true);
guidata(fig, ud);

function moveendselection(fig)
ud=guidata(gcbo);
x = get(ud.Data.Gui{ud.CurrentBlock}.EndSelectionCursor, 'XData'); x = x(1);
ud.Data.Block{ud.CurrentBlock}.Params.EndSelection = x;
set(ud.EndTime, 'String', sprintf('%4.2f', x));
guidata(fig, ud);
ReCalc(fig,ud, true);
guidata(fig, ud);

function movetop(fig)
ud=guidata(gcbo);
x = get(ud.Data.Gui{ud.CurrentBlock}.TopCursor(1), 'XData'); x = x(1);
set(ud.Data.Gui{ud.CurrentBlock}.TopCursor(2), 'XData', [x x] );
set(ud.Top, 'String', sprintf('%4.3f', x));
lfi = find(ud.Data.Block{ud.CurrentBlock}.Calc.F > x);
ud.Data.Block{ud.CurrentBlock}.Params.MainFrequency(2) = lfi(1);
ud.Data.Block{ud.CurrentBlock}.Params.MainFrequency(1) = x;
guidata(fig, ud);

function movelower(fig)
ud=guidata(gcbo);
x = get(ud.Data.Gui{ud.CurrentBlock}.LowerCursor(1), 'XData'); x = x(1);
set(ud.Data.Gui{ud.CurrentBlock}.LowerCursor(2), 'XData', [x x] );
set(ud.Lower, 'String', sprintf('%4.3f', x));
lfi = find(ud.Data.Block{ud.CurrentBlock}.Calc.F > x);
ud.Data.Block{ud.CurrentBlock}.Params.LowFrequencyIndex(2) = lfi(1);
ud.Data.Block{ud.CurrentBlock}.Params.LowFrequencyIndex(1) = x;
guidata(fig, ud);
ReCalc(fig,ud, true);
guidata(fig, ud);

function moveupper(fig)
ud=guidata(gcbo);
x = get(ud.Data.Gui{ud.CurrentBlock}.UpperCursor(1), 'XData'); x = x(1);
set(ud.Data.Gui{ud.CurrentBlock}.UpperCursor(2), 'XData', [x x] );
set(ud.Upper, 'String', sprintf('%4.3f', x));
lfi = find(ud.Data.Block{ud.CurrentBlock}.Calc.F < x);
ud.Data.Block{ud.CurrentBlock}.Params.HighFrequencyIndex(2) = lfi(end);
ud.Data.Block{ud.CurrentBlock}.Params.HighFrequencyIndex(1) = x;
guidata(fig, ud);
ReCalc(fig,ud, true);
guidata(fig, ud);


% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
    ['Close ' get(handles.figure1,'Name') '...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end
delete(handles.figure1)


% --- Executes on button press in BlockBack.
function BlockBack_Callback(hObject, eventdata, handles)
% hObject    handle to BlockBack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.CurrentBlock > 1)
    handles.CurrentBlock = handles.CurrentBlock - 1;
    set(handles.BlockNext, 'Enable', 'on');
end
if (handles.CurrentBlock == 1)
    set(handles.BlockBack, 'Enable', 'off');
end
handles = PlotTrajectory(hObject, handles);
guidata(hObject, handles);


% --- Executes on button press in BlockNext.
function BlockNext_Callback(hObject, eventdata, handles)
% hObject    handle to BlockNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.CurrentBlock < handles.Blocks)
    handles.CurrentBlock = handles.CurrentBlock + 1;
    set(handles.BlockBack, 'Enable', 'on');
end
if (handles.CurrentBlock == handles.Blocks)
    set(handles.BlockNext, 'Enable', 'off');
end
handles = PlotTrajectory(hObject, handles);
guidata(hObject, handles);


function Top_Callback(hObject, eventdata, handles)
% hObject    handle to Top (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Top as text
%        str2double(get(hObject,'String')) returns contents of Top as a double


% --- Executes during object creation, after setting all properties.
function Top_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Top (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function Lower_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Lower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function Upper_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Upper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in fscalc.
function fscalc_Callback(hObject, eventdata, handles)
% hObject    handle to fscalc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% nog niet goed!

[handles.Data.Block{handles.CurrentBlock}.Calc.top, handles.Data.Block{handles.CurrentBlock}.Calc.index] = ...
                                                max(handles.Data.Block{handles.CurrentBlock}.Calc.FilteredLeadFFT);

lower = find(handles.Data.Block{handles.CurrentBlock}.Calc.FilteredLeadFFT(1:handles.Data.Block{handles.CurrentBlock}.Calc.index(1)) < ...
                                                (.5*handles.Data.Block{handles.CurrentBlock}.Calc.top));
                            
upper = find(handles.Data.Block{handles.CurrentBlock}.Calc.FilteredLeadFFT(handles.Data.Block{handles.CurrentBlock}.Calc.index(1):end) < ...
                                                (.5*handles.Data.Block{handles.CurrentBlock}.Calc.top));

                                            
handles.Data.Block{handles.CurrentBlock}.Params.LowFrequencyIndex  = [handles.Data.Block{handles.CurrentBlock}.Calc.FFTfreqs(lower(end)) lower(end)];
handles.Data.Block{handles.CurrentBlock}.Params.HighFrequencyIndex = [handles.Data.Block{handles.CurrentBlock}.Calc.FFTfreqs(upper(1)+handles.Data.Block{handles.CurrentBlock}.Calc.index(1)) upper(1)+handles.Data.Block{handles.CurrentBlock}.Calc.index(1)];
handles.Data.Block{handles.CurrentBlock}.Params.MainFrequency      = [handles.Data.Block{handles.CurrentBlock}.Calc.FFTfreqs(handles.Data.Block{handles.CurrentBlock}.Calc.index) handles.Data.Block{handles.CurrentBlock}.Calc.index];

set(handles.Data.Gui{handles.CurrentBlock}.TopCursor, 'XData', ...
        [handles.Data.Block{handles.CurrentBlock}.Params.MainFrequency(1) ...
         handles.Data.Block{handles.CurrentBlock}.Params.MainFrequency(1)]);

handles.Data.Block{handles.CurrentBlock}.Params.LowFrequencyIndex(1) =  max((floor(handles.rounder * ...
            handles.Data.Block{handles.CurrentBlock}.Params.LowFrequencyIndex(1))...
            /handles.rounder), handles.Data.Block{handles.CurrentBlock}.Calc.FFTfreqs(2));

[dum, handles.Data.Block{handles.CurrentBlock}.Params.LowFrequencyIndex(2)] =  ...
            min(abs(handles.Data.Block{handles.CurrentBlock}.Calc.FFTfreqs - ...
                    handles.Data.Block{handles.CurrentBlock}.Params.LowFrequencyIndex(1))) ;

set(handles.Data.Gui{handles.CurrentBlock}.LowerCursor, 'XData', ...
                    [handles.Data.Block{handles.CurrentBlock}.Params.LowFrequencyIndex(1) ...
                        handles.Data.Block{handles.CurrentBlock}.Params.LowFrequencyIndex(1)]);

handles.Data.Block{handles.CurrentBlock}.Params.HighFrequencyIndex(1) = ceil(handles.rounder * ...
            handles.Data.Block{handles.CurrentBlock}.Params.HighFrequencyIndex(1))...
            /handles.rounder;

[dum, handles.Data.Block{handles.CurrentBlock}.Params.HighFrequencyIndex(2)] =  ...
            min(abs(handles.Data.Block{handles.CurrentBlock}.Calc.FFTfreqs - ...
                    handles.Data.Block{handles.CurrentBlock}.Params.HighFrequencyIndex(1))) ;
            
set(handles.Data.Gui{handles.CurrentBlock}.UpperCursor, 'XData', ...
                    [handles.Data.Block{handles.CurrentBlock}.Params.HighFrequencyIndex(1) ...
                        handles.Data.Block{handles.CurrentBlock}.Params.HighFrequencyIndex(1)]);

set(handles.Top, 'String', sprintf('%4.3f', ...
    handles.Data.Block{handles.CurrentBlock}.Params.MainFrequency(1)));

set(handles.Lower, 'String', sprintf('%4.3f', ...
    handles.Data.Block{handles.CurrentBlock}.Params.LowFrequencyIndex(1)));
            
set(handles.Upper, 'String', sprintf('%4.3f', ...
    handles.Data.Block{handles.CurrentBlock}.Params.HighFrequencyIndex(1)));

guidata(hObject, handles);
handles = ReCalc(hObject,handles, true);
guidata(hObject, handles);


function Lower_Callback(hObject, eventdata, handles)
% hObject    handle to Lower (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Lower as text
%        str2double(get(hObject,'String')) returns contents of Lower as a double
ud=guidata(gcf);
lowfreq = str2double(get(hObject,'String'));
lfi = find(ud.Data.Block{ud.CurrentBlock}.Calc.F > lowfreq);
ud.Data.Block{ud.CurrentBlock}.Params.LowFrequencyIndex(2) = lfi(1);
ud.Data.Block{ud.CurrentBlock}.Params.LowFrequencyIndex(1) = lowfreq;
set(ud.Data.Gui{ud.CurrentBlock}.LowerCursor(1), 'XData', [lowfreq lowfreq] );
set(ud.Data.Gui{ud.CurrentBlock}.LowerCursor(2), 'XData', [lowfreq lowfreq] );

guidata(gcf, ud);
ReCalc(gcf,ud, true);


function Upper_Callback(hObject, eventdata, handles)
% hObject    handle to Upper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Upper as text
%        str2double(get(hObject,'String')) returns contents of Upper as a double
ud=guidata(gcf);
highfreq = str2double(get(hObject,'String'));
lfi = find(ud.Data.Block{ud.CurrentBlock}.Calc.F > highfreq);
ud.Data.Block{ud.CurrentBlock}.Params.HighFrequencyIndex(2) = lfi(end);
ud.Data.Block{ud.CurrentBlock}.Params.HighFrequencyIndex(1) = highfreq;
set(ud.Data.Gui{ud.CurrentBlock}.UpperCursor(1), 'XData', [highfreq highfreq] );
set(ud.Data.Gui{ud.CurrentBlock}.UpperCursor(2), 'XData', [highfreq highfreq] );

guidata(gcf, ud);
ReCalc(gcf,ud, true);



function StartTime_Callback(hObject, eventdata, handles)
% hObject    handle to StartTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StartTime as text
%        str2double(get(hObject,'String')) returns contents of StartTime as a double

handles.Data.Block{handles.CurrentBlock}.Params.StartSelection = str2double(get(hObject,'String'));

set(handles.Data.Gui{handles.CurrentBlock}.StartSelectionCursor, 'XData', ...
    [str2double(get(hObject,'String')) str2double(get(hObject,'String'))])

handles = ReCalc(hObject,handles, true);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function StartTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StartTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EndTime_Callback(hObject, eventdata, handles)
% hObject    handle to EndTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EndTime as text
%        str2double(get(hObject,'String')) returns contents of EndTime as a double
handles.Data.Block{handles.CurrentBlock}.Params.EndSelection = str2double(get(hObject,'String'));

set(handles.Data.Gui{handles.CurrentBlock}.EndSelectionCursor, 'XData', ...
    [str2double(get(hObject,'String')) str2double(get(hObject,'String'))])

handles = ReCalc(hObject,handles, true);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function EndTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EndTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in fulltime.
function fulltime_Callback(hObject, eventdata, handles)
% hObject    handle to fulltime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Data.Block{handles.CurrentBlock}.Params.StartSelection = handles.Data.Block{handles.CurrentBlock}.Time(1);
handles.Data.Block{handles.CurrentBlock}.Params.EndSelection   = handles.Data.Block{handles.CurrentBlock}.Time(end);

set(handles.StartTime, 'String', sprintf('%4.2f', handles.Data.Block{handles.CurrentBlock}.Time(1)));
set(handles.EndTime, 'String', sprintf('%4.2f', handles.Data.Block{handles.CurrentBlock}.Time(end)));

set(handles.Data.Gui{handles.CurrentBlock}.StartSelectionCursor, 'XData', ...
    [handles.Data.Block{handles.CurrentBlock}.Time(1) handles.Data.Block{handles.CurrentBlock}.Time(1)])
set(handles.Data.Gui{handles.CurrentBlock}.EndSelectionCursor, 'XData', ...
    [handles.Data.Block{handles.CurrentBlock}.Time(end) handles.Data.Block{handles.CurrentBlock}.Time(end)])

handles = ReCalc(hObject,handles, true);
guidata(hObject,handles);


function msCoh_Callback(hObject, eventdata, handles)
% hObject    handle to msCoh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of msCoh as text
%        str2double(get(hObject,'String')) returns contents of msCoh as a double


% --- Executes during object creation, after setting all properties.
function msCoh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to msCoh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Phase_Callback(hObject, eventdata, handles)
% hObject    handle to Phase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Phase as text
%        str2double(get(hObject,'String')) returns contents of Phase as a double


% --- Executes during object creation, after setting all properties.
function Phase_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Phase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Gain_Callback(hObject, eventdata, handles)
% hObject    handle to Gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Gain as text
%        str2double(get(hObject,'String')) returns contents of Gain as a double


% --- Executes during object creation, after setting all properties.
function Gain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function Coh_Callback(hObject, eventdata, handles)
% hObject    handle to Coh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Coh as text
%        str2double(get(hObject,'String')) returns contents of Coh as a double


% --- Executes during object creation, after setting all properties.
function Coh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Coh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------

% --------------------------------------------------------------------
function Test_Callback(hObject, eventdata, handles)
% % hObject    handle to Test (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% handles.Blocks      = 2;
% handles.FileName = 'Build-In TestData';
% set (handles.BlockBack, 'Enable', 'off');
% set (handles.BlockNext, 'Enable', 'off');
% 
% len = 4000;
% Fs=10;
% insin = [.04 .06];
% gain = [1.1 3.0];
% phasedifinsec = [2 4];
% noise = [0 1];
% 
% for (i = 1:handles.Blocks)
%     
%     handles.Data.Block{i}.Time   = ((1:len) / Fs)';
%     handles.Data.Block{i}.Lead   = zeros(len,1);
%     
%     for s = 1:length(insin)
%         handles.Data.Block{i}.Lead   = handles.Data.Block{i}.Lead + sin(2*pi*handles.Data.Block{i}.Time*insin(s));
%     end
%     
%     nl = length(handles.Data.Block{i}.Lead(1:end-((phasedifinsec(i)*Fs)-1)));
%     handles.Data.Block{i}.Follow = gain(i)*handles.Data.Block{i}.Lead(1:end-((phasedifinsec(i)*Fs)-1)) + (noise(i) * (rand(nl,1) - .5));
%     handles.Data.Block{i}.Lead   = handles.Data.Block{i}.Lead(phasedifinsec(i)*Fs:end);
%     handles.Data.Block{i}.Time   = handles.Data.Block{i}.Time(phasedifinsec(i)*Fs:end);
%     
%     handles.Fs{i}                = Fs; % sampling frequency
%     handles.dT{i}                = 1/handles.Fs{i};
%     
%     L = length(handles.Data.Block{i}.Follow);
%     handles.Data.Block{i}.NFFT = 2^nextpow2(L); % Next power of 2 from length of y
%     
%     handles.Data.Block{i}.FFTFollow = fft(handles.Data.Block{i}.Follow-mean(handles.Data.Block{i}.Follow), handles.Data.Block{i}.NFFT)/L;
%     handles.Data.Block{i}.FFTfreqs  = handles.Fs{i}/2*linspace(0,1,handles.Data.Block{i}.NFFT/2+1);
%     
%     L = length(handles.Data.Block{i}.Lead);
%     handles.Data.Block{i}.FFTLead = fft(handles.Data.Block{i}.Lead-mean(handles.Data.Block{i}.Lead), handles.Data.Block{i}.NFFT)/L;
%     
%     handles.Data.Block{i}.FilteredLeadFFT   = filter(ones(3,1)/3, 1, 2*abs(handles.Data.Block{i}.FFTLead(1:handles.Data.Block{i}.NFFT/2+1)));
%     handles.Data.Block{i}.FilteredFollowFFT = filter(ones(3,1)/3, 1, 2*abs(handles.Data.Block{i}.FFTFollow(1:handles.Data.Block{i}.NFFT/2+1)));
%     [handles.Data.Block{i}.top, handles.Data.Block{i}.index] = max(handles.Data.Block{i}.FilteredLeadFFT);
%     
%     lower = find(handles.Data.Block{i}.FilteredLeadFFT(1:handles.Data.Block{i}.index(1)) < (.5*handles.Data.Block{i}.top));
%     handles.Data.Block{i}.LowFrequencyIndex = lower(end);
%     %
%     upper = find(handles.Data.Block{i}.FilteredLeadFFT(handles.Data.Block{i}.index(1):end) < (.5*handles.Data.Block{i}.top));
%     handles.Data.Block{i}.HighFrequencyIndex = upper(1)+handles.Data.Block{i}.index(1);
%     
%     handles.Data.Block{i}.StartSelection = handles.Data.Block{i}.Time(1);
%     handles.Data.Block{i}.EndSelection   = handles.Data.Block{i}.Time(end);
%     
%     x = handles.Data.Block{i}.Lead   - mean(handles.Data.Block{i}.Lead);
%     y = handles.Data.Block{i}.Follow - mean(handles.Data.Block{i}.Follow);
%     
%     [ handles.Pxx{i}, handles.Pyy{i}, handles.Pxy{i}, handles.Cxy{i}, handles.pha{i}, handles.phaseinsec{i}, handles.gain{i}, handles.F{i} ] = ...
%                 coherence( x, y,[],[],handles.Data.Block{i}.NFFT, handles.Fs{i});
% end
% 
% if (handles.Blocks > 1)
%     set (handles.BlockNext, 'Enable', 'on');
% end
% 
% set (handles.fulltime, 'Enable', 'on');
% set (handles.fscalc, 'Enable', 'on');
% 
% handles.CurrentBlock = 1;
% guidata(hObject, handles);
% handles = PlotTrajectory(hObject, handles);
% guidata(hObject, handles);


% --------------------------------------------------------------------
function SaveMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to SaveMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[path,fn,ext,versn] = fileparts(fullfile(handles.Directory, handles.FileName));
ofn = strcat(fn, '.xls');
[file, directory] = uiputfile('*.xls', 'Output FileName', ofn );
ofn = fullfile(directory, file);
for ( b = 1: handles.Data.Blocks )
    Out = {'filename', 'blocknumber', 'StartTime', 'EndTime', 'StartFreq', 'EndFreq', 'Coherence', 'CStd', 'Phase', 'PStd', 'Gain', 'GStd' ; ...
    fn, b, ...
    handles.Data.Block{b}.Params.StartSelection, ...
    handles.Data.Block{b}.Params.EndSelection, ...
    handles.Data.Block{b}.Params.LowFrequencyIndex(1) , ... 
    handles.Data.Block{b}.Params.HighFrequencyIndex(1), ...
    handles.Data.Block{b}.Output.Coherences, ...
    handles.Data.Block{b}.Output.CoherencesStd, ...
    handles.Data.Block{b}.Output.Phases, ...
    handles.Data.Block{b}.Output.PhasesStd, ...
    handles.Data.Block{b}.Output.Gains, ...
    handles.Data.Block{b}.Output.GainsStd; };
    xlswrite(ofn, Out, sprintf('Block %d', b));
end


% --------------------------------------------------------------------
function Holep_Callback(hObject, eventdata, handles)
% hObject    handle to Holep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function About_Callback(hObject, eventdata, handles)
% hObject    handle to About (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox({'Smeargle 0.1a (m.m.span@rug.nl)'; '050-636402';'20-4-2009'}, 'Info', 'help', 'modal');


% --------------------------------------------------------------------
function textsave_Callback(hObject, eventdata, handles)
% hObject    handle to textsave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[path,fn,ext,versn] = fileparts(fullfile(handles.Directory, handles.FileName));
ofn = strcat(fn, '.dat');
[file, directory] = uiputfile('*.dat', 'Output FileName', ofn );
ofn = fullfile(directory, file);
if ~exist(ofn)
    txtfile = fopen(ofn, 'w');
    fprintf(txtfile,'filename\tblocknumber\tStartTime\tEndTime\tStartFreq\tEndFreq\tCoherence\tCStd\tPhase\tPStd\tGain\tGStd\n');
else
    txtfile = fopen(ofn, 'a');
end
for ( b = 1: handles.Data.Blocks )
    fprintf(txtfile, '%s\t%i\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n', ...
    fn, b, ...
    handles.Data.Block{b}.Params.StartSelection, ...
    handles.Data.Block{b}.Params.EndSelection, ...
    handles.Data.Block{b}.Params.LowFrequencyIndex(1) , ... 
    handles.Data.Block{b}.Params.HighFrequencyIndex(1), ...
    handles.Data.Block{b}.Output.Coherences, ...
    handles.Data.Block{b}.Output.CoherencesStd, ...
    handles.Data.Block{b}.Output.Phases, ...
    handles.Data.Block{b}.Output.PhasesStd, ...
    handles.Data.Block{b}.Output.Gains, ...
    handles.Data.Block{b}.Output.GainsStd);
end
fclose(txtfile);
