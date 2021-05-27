% resize_figure.m
% 
% Written by Christopher Nowakowski
% v 1.0     2/1/2009   - First version written
%
% This 

function resize_figure(h,width,height,axis_fontsize,label_fontsize,legend_fontsize)

% ------------------------------------------------------------------------------
% Check Input Arguments
% ------------------------------------------------------------------------------

usage_msg = 'Usage: resize_figure(Figure,Width{pixels},Height{pixels},[XY Axis, Axis Titles, and Legends FontSizes{points}])';

if (nargin == 1 && ischar(h) && strcmpi(h,'?')),
    disp(usage_msg);
    return;

elseif (nargin == 3),
    axis_fontsize = 0;
    label_fontsize = 0;
    legend_fontsize = 0;

elseif (nargin == 4),
    label_fontsize = 0;
    legend_fontsize = 0;

elseif (nargin == 5),
    legend_fontsize = 0;

elseif (nargin == 6),
    % All Input Parameter's Specified

else
    error(usage_msg);
end;


% ------------------------------------------------------------------------------
% Resize Figure
% ------------------------------------------------------------------------------

% Calculate Figure Bottom Based on Screen Size
ScreenSize = get(0,'ScreenSize');
OS = computer;
if (ismac),
    MenuAdjustment = 90;
else,
    MenuAdjustment = 75;
end;
FigureBottom = ScreenSize(4) - height - MenuAdjustment;
if (FigureBottom < 0),
    disp('Warning: Requested figure height exceeds screen size.  Figure scaled to fit screen.');
    height = ScreenSize(4) - MenuAdjustment;
    FigureBottom = 1;
end;

% Check Width Against ScreenSize
if (width > ScreenSize(3)),
    disp('Warning: Requested figure width exceeds screen size.  Figure scaled to fit screen.');
    width = ScreenSize(3);
end;

% Set Figure Position
set(h,'Position',[1 FigureBottom width height]);

% Reset FontSizes
if (nargin > 3),
    % Get All Axes and Legend Handles
    graph_axes = get(h,'Children');
    
    % Loop Through Handles to Set Font Sizes
    for i=1:length(graph_axes),
        
        % Determine if Axes is a Legend or an Axis
        axes_type = get(graph_axes(i),'Type');  % 'axes' for axis or legend
        axes_tag = get(graph_axes(i),'Tag');    % '' for axis 'legend' for legend
        if (strcmpi(axes_type,'axes') && strcmpi(axes_tag,'legend') && legend_fontsize > 0),
            % Axes is a legend
            set(graph_axes(i),'FontSize',legend_fontsize);
        
        elseif (strcmpi(axes_type,'axes') && ~strcmpi(axes_tag,'legend') && axis_fontsize > 0),
            % Axes is the graph axis
            set(graph_axes(i),'FontSize',axis_fontsize);
        
            % Set XY Axis Labels
            if (label_fontsize > 0),
                label = get(graph_axes(i),'YLabel');
                set(label,'FontSize',label_fontsize);
                label = get(graph_axes(i),'XLabel');
                set(label,'FontSize',label_fontsize);
            end;
            
        end;    % if strcmpi(axes_tag...     
    end;    % For i...        
end;    % if (nargin > 3...

end