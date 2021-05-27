% graph_vs_ts.m
% 
% Written by Christopher Nowakowski
% v 1.0 written 11/18/2008
%
% This is a convenience script to graph CACC data structure columns quickly and conveniently.  
%

function [h] = graph_vs_ts(x,varargin)

% -------------------------------------------------------------------------------------------------
% Check Input Arguments
% -------------------------------------------------------------------------------------------------
usage_msg = 'Usage: [h] = graph_vs_ts(data.ts.ssm, data.y1, data.y2, ..., [''-rel'' or ''-abs'']);';
absolute = 0;

if nargin == 1 && strcmpi(x,'?'),
    disp(usage_msg);
    return;
elseif nargin < 2,
    error(usage_msg);
end;

if nargin > 2,
    for argin = 2:size(varargin,2),
        if ischar(varargin{argin}),
            if strcmpi(varargin{argin},'-abs') || strcmpi(varargin{argin},'abs') || strcmpi(varargin{argin},'-a'),
                absolute = 1;
            end;
        end;
    end;
end;

% -------------------------------------------------------------------------------------------------
% X-Axis Setup
% -------------------------------------------------------------------------------------------------
if absolute,
    [XAxisRange XAxisTicks XTickLabels XAxisTitle] = get_graph_xaxis_ts_scale(x,0,'-abs');
else,
    [XAxisRange XAxisTicks XTickLabels XAxisTitle] = get_graph_xaxis_ts_scale(x,0,'-rel');
end;
XMinorTickStatus = 'off';

% -------------------------------------------------------------------------------------------------
% Y-Axis Setup
% -------------------------------------------------------------------------------------------------
nargs = length(varargin);
[YAxisRange YAxisTicks] = get_graph_yaxis_scale(varargin,nargs);
YMinorTickStatus = 'off';
YGridStatus = 'off';

% -------------------------------------------------------------------------------------------------
% Other Default Parameters
% -------------------------------------------------------------------------------------------------
BackgroundColor = [0.9412 0.9412 0.9412];
LineWidth = 1;

% -------------------------------------------------------------------------------------------------
% Draw Blank Figure
% -------------------------------------------------------------------------------------------------
h = figure('InvertHardcopy','off','Color',[1 1 1],'Position',[0 0 1000 400]);

% Apply Axis Settings
set(gca,'TickDir','out',...
    'XTick',XAxisTicks,'XMinorTick',XMinorTickStatus,'XTickLabel',XTickLabels,...
    'YTick',YAxisTicks,'YMinorTick',YMinorTickStatus,'YGrid',YGridStatus,...
    'FontSize',12,'Color',BackgroundColor);
xlim(XAxisRange);
ylim(YAxisRange);
xlabel(XAxisTitle,'FontSize',12);
ylabel('Insert Title Here','FontSize',12);

% Draw Black Vertical Plot Box Line on Right Side of Graph
% line([XAxisRange(2) XAxisRange(2)],YAxisRange,'Color',[0 0 0]);

% Draw Black Horizonal Plot Box Line on Top of Graph
% line(XAxisRange,[YAxisRange(2)-.03 YAxisRange(2)-.03],'Color',[0 0 0]);

% -------------------------------------------------------------------------------------------------
% Plot Y Values
% -------------------------------------------------------------------------------------------------

% Figure out how many lines to plot
nargs = 0;
for argin = 1:size(varargin,2),
    if ~ischar(varargin{argin}),
        nargs = nargs + 1;
    end;
end;

% Get Colormap
cm = colormap; % cm is now a matrix of 64 rgb color values
if nargs > 1,
    color_step = 64/(nargs-1);
end;

% Plot Y Values
for argin = 1:size(varargin,2),
    if ~ischar(varargin{argin}),
        % Set Line Color - Default Color Map Goes from ROYGB
        if argin == 1,
            Lcolor = cm(1,:);
        else,
            Lcolor = cm(floor((argin-1)*color_step),:);
        end;
        % Draw the Line
        l = line(x,varargin{argin},'LineWidth',LineWidth,'Color',Lcolor);
        line_objects(argin) = l;
        legend_labels{argin} = ['Parameter ' num2str(argin)];
    end;
end;

% Show Legend
legend(gca,line_objects,legend_labels);


% ------------------------------------------------------------------------------
% Enable Dynamic X-Axis Rescaling on Zoom Callback Function
% ------------------------------------------------------------------------------
z = zoom;
set(z,'ActionPostCallback',@resize_xaxis_ts_on_zoom);

end



% -------------------------------------------------------------------------------------------------
% Function to Set the Y-Axis Range and TickMark Labels
% -------------------------------------------------------------------------------------------------
function [YAxisRange YAxisTicks] = get_graph_yaxis_scale(varargin,nargs)

% Set Default Y-Axis Min/Max
ymin = 0;
ymax = 0;

% Update Y-Axis Min/Max for each Y-Argument to be plotted
for argin = 1:nargs,
    if ~ischar(varargin{argin}),
        y = varargin{argin};
        ymin = min(ymin, min(y));
        ymax = max(ymax, max(y));
    end;
end;

% Snap Min/Max to nearest integer
ymin = double(floor(ymin));
ymax = double(ceil(ymax));

% Set Y-LabelStep according to value range
yrange = ymax - ymin;
if yrange <= 3,
    ylabel_step = 0.25;
elseif yrange <= 10,
    ylabel_step = 1;
elseif yrange <= 30,
    ylabel_step = 5;
elseif yrange <= 150,
    ylabel_step = 10;
elseif yrange <= 500,
    ylabel_step = 50;
elseif yrange <= 1000,
    ylabel_step = 100;
else
    ylabel_step = 1000;
end;

% Generate YAxisTicks
YAxisTicks = [];
if ymin < 0,
    label_value = 0;
    i = 1;
    while (label_value > (ymin - ylabel_step)),
        YAxisTicks(i) = label_value;
        i = i + 1;
        label_value = double(label_value - ylabel_step);
    end;
    YAxisTicks = fliplr(YAxisTicks);
end;
if isempty(YAxisTicks),
    i = 1;
    label_value = double(floor(ymin/ylabel_step)*ylabel_step);
else
    i = length(YAxisTicks) + 1;
    label_value = double(0 + ylabel_step);
end;
while (label_value <= (ymax+ylabel_step)),
    YAxisTicks(i) = label_value;
    i = i + 1;
    label_value = label_value + ylabel_step;
end;

% Set YAxisRange
YAxisRange = [YAxisTicks(1) YAxisTicks(length(YAxisTicks))];

end