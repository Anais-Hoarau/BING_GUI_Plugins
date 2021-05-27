% graph_ride_parameters.m
% 
% Written by Christopher Nowakowski
% v 1.0     03/16/2009
%
% This is a script to create a graph of three linked subplots of various ride 
% quality parameters of the CACC System.  It is based on graph_acc_overview.m
%
% Flags (the first option is the default)
% 
% [-si or -mph] selects between m/s or mph for speed data
%
% [-sysclock or -utc] plots the data against the system clock (data.ts.ssm) or the 
%                     synchronized utc time (data.ts.utc_ssm)
%
% [-hms or -rel] sets the x-axis to show time in hours, minutes, and seconds or
%                -rel plots the data relative to the first data point
%
% [-raw] mode shows lines when a value drops to it's null value.  This is useful
%        for debugging, but makes for a busy graph.  The default is stop drawing
%        the line when it drops to its null value, which shows up as a line break.
%
% Note: flags should be set as a continuous character array.
% e.g.: '-mph -sysclock -hms -raw'
%

function [h] = graph_ride_parameters(data,flags)

% -------------------------------------------------------------------------------------------------
% Check Input Arguments
% -------------------------------------------------------------------------------------------------
usage_msg = 'Usage: [h] = graph_ride_parameters(data,flags);';

% Defaults
units = 1;      % si
clock = 'ssm';  % sysclock
raw = 0;        % off
hms = '-hms';   % plot by time of day

% Input Arg Checking
if nargin == 0 || (nargin ==1 && ischar(data) && strcmpi(data,'?')),
    disp(usage_msg);
    disp('Note: Valid flags include ''[-si or -mph] [-sysclock or -utc] [-hms or -rel] [-raw]''');
    return;

elseif nargin == 1 && isstruct(data),
    % Use Defaults

elseif nargin == 2 && isstruct(data) && ischar(flags),
    % Check for mph flag
    if (~isempty(findstr(flags,'mph'))),
        units = 2.2369362;
    end;
    % Check for utc flag
    if (~isempty(findstr(flags,'utc'))),
        clock = 'utc_ssm';
    end;
    % Check for relative flag
    if (~isempty(findstr(flags,'rel'))),
        hms = '-rel';
    end;
    % Check for raw flag
    if (~isempty(findstr(flags,'raw'))),
        raw = 1;
    end;
        
elseif nargin <= 2 && ~isstruct(data),
    error('%s\n%s','Error: data must be of type CACC data structure.',usage_msg);
    
else,
    error(usage_msg);
    
end;


% -------------------------------------------------------------------------------------------------
% X-Axis Setup
% -------------------------------------------------------------------------------------------------
x = data.ts.(clock);
[XAxisRange XAxisTicks XTickLabels XAxisTitle] = get_graph_xaxis_ts_scale(x,1,hms);

% Add a prefix to the x-axis title to tell whether it is system clock or utc
if (strcmpi(hms,'-rel')),
    % Don't add a prefix to the X-Axis Title if plotting in relative mode
    
elseif (strcmpi(clock,'ssm')),
    XAxisTitle = ['System ' XAxisTitle];

else,
    XAxisTitle = ['UTCP ' XAxisTitle];

end;
XMinorTickStatus = 'off';


% -------------------------------------------------------------------------------------------------
% Other Default Parameters & Color Definitions
% -------------------------------------------------------------------------------------------------
FigureTitle = ['Driver ' data.meta.driver ' ' data.meta.vehicle ' Trip ' data.meta.tripid ' '];
BackgroundColor = [0.9412 0.9412 0.9412]; % Excel default grey
speedometer_orange = [1 85/255 0];
amber = [1 190/255 0];


% -------------------------------------------------------------------------------------------------
% Draw Blank Figure
%
% Useful Commands
% clf(h,'reset');
% set(h,'Position',[0 0 1000 800]);
% -------------------------------------------------------------------------------------------------
ScreenSize = get(0,'ScreenSize');
OS = computer;
if (ismac),
    MenuAdjustment = 90;
else,
    MenuAdjustment = 75;
end;
FigureBottom = ScreenSize(4) - 800 - MenuAdjustment;
h = figure('InvertHardcopy','off','Color',[1 1 1],'Position',[1 FigureBottom 800 800]);
clear ScreenSize OS MenuAdjustment FigureBotom;


% -------------------------------------------------------------------------------------------------
% Subplot - Acceleration
% -------------------------------------------------------------------------------------------------
ax(1) = subplot(3,1,1);
line_objects = [];
legend_labels = [];

% Set Up Y-Axis
YAxisRange = [-0.4 0.4];
YAxisTicks = [-0.8 -0.6 -0.4 -0.35 -0.3 -0.25 -0.2 -0.15 -0.1 -0.05 0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.6 0.8];
% Note: Also setting 'YTickLabel' in the set command
YAxisTitle = 'Acceleration (g)';
YMinorTickStatus = 'on';
YGridStatus = 'off';

% Apply Axis Settings
set(gca,'TickDir','out',...
    'XTick',XAxisTicks,'XMinorTick',XMinorTickStatus,'XTickLabel',XTickLabels,...
    'YTick',YAxisTicks,'YMinorTick',YMinorTickStatus,'YGrid',YGridStatus,...    
    'FontSize',12,'Color',BackgroundColor);
xlim(XAxisRange);
ylim(YAxisRange);
xlabel(XAxisTitle,'fontsize',14,'fontweight','b');
ylabel(YAxisTitle,'fontsize',14,'fontweight','b');

% Apply Figure Title to First Subplot
title(FigureTitle,'fontsize',16,'fontweight','b');

% Draw Black Vertical Plot Box Line on Right Side of Graph
% line([XAxisRange(2) XAxisRange(2)],YAxisRange,'Color',[0 0 0]);
% Draw Black Horizonal Plot Box Line on Top of Graph
% line(XAxisRange,[YAxisRange(2)-.03 YAxisRange(2)-.03],'Color',[0 0 0]);

% Plot 0 line
line(XAxisRange, [0 0],'LineWidth', 1, 'Color',[0 0 0]);

% Plot Acceleration
l = line(x,data.veh.accl_x,'LineWidth',1,'Color',[0 0 .5]);
[line_objects legend_labels] = add_legend_entry(line_objects,legend_labels,l,'X Acc');
l= line(x,data.veh.accl_y,'LineWidth',1,'Color',[.5 0 0]);
[line_objects legend_labels] = add_legend_entry(line_objects,legend_labels,l,'Y Acc');

% Show Legend
if ~isempty(line_objects),
    %legend_bottom = 0.86 - 0.015*(length(line_objects)-1)/2;
    %legend(gca,line_objects,legend_labels,'Location',[.78 legend_bottom .12 .025],'FontSize',10);
    legend(gca,line_objects,legend_labels,'Location','Northeast','FontSize',10);
    legend('boxoff');
end;



% -------------------------------------------------------------------------------------------------
% Subplot - Throttle & Gear
% -------------------------------------------------------------------------------------------------
ax(2) = subplot(3,1,2);
line_objects = [];
legend_labels = [];

% Set Up Y-Axis
YAxisRange = [0 50];
YAxisTicks = [0 5 10 15 20 25 30 35 40 45 50 60 70 80 90 100];
% Note: Also setting 'YTickLabel' in the set command
YAxisTitle = 'Throttle (%) / Gear (x10)';
YMinorTickStatus = 'on';
YGridStatus = 'off';

% Apply Axis Settings
set(gca,'TickDir','out',...
    'XTick',XAxisTicks,'XMinorTick',XMinorTickStatus,'XTickLabel',XTickLabels,...
    'YTick',YAxisTicks,'YMinorTick',YMinorTickStatus,'YGrid',YGridStatus,...
    'FontSize',12,'Color',BackgroundColor);
   %'PlotBoxAspectRatio',PlotBoxAspectRatio,...
xlim(XAxisRange);
ylim(YAxisRange);
xlabel(XAxisTitle,'fontsize',14,'fontweight','b');
ylabel(YAxisTitle,'fontsize',14,'fontweight','b');

% Draw Black Vertical Plot Box Line on Right Side of Graph
% line([XAxisRange(2) XAxisRange(2)],YAxisRange,'Color',[0 0 0]);
% Draw Black Horizonal Plot Box Line on Top of Graph
% line(XAxisRange,[YAxisRange(2)-.02 YAxisRange(2)-.02],'Color',[0 0 0]);

% Plot Gear
l = line(x,data.veh.gear*10,'LineWidth',1,'Color',[.5 .5 .5]);
[line_objects legend_labels] = add_legend_entry(line_objects,legend_labels,l,'Gear');

% Plot Engine RPM
l = line(x,data.veh.rpm/100,'Linewidth',1,'Color',amber);
[line_objects legend_labels] = add_legend_entry(line_objects,legend_labels,l,'RPM');

% Plot OutputShaft RPM
l = line(x,data.veh.outputshaft_rpm/100,'Linewidth',1,'Color',speedometer_orange);
[line_objects legend_labels] = add_legend_entry(line_objects,legend_labels,l,'Shaft RPM');

% Plot Virtual Lidar Distance
l = line(x,data.acc.virtual_dist,'Linewidth',1,'Color',[0 0 .75]);
[line_objects legend_labels] = add_legend_entry(line_objects,legend_labels,l,'VDist');

% Plot Actual Lidar Distance
l = line(x,data.acc.dist,'Linewidth',1,'Color',[0 0.75 0]);
[line_objects legend_labels] = add_legend_entry(line_objects,legend_labels,l,'Dist');

% Plot Virtual Throttle
l = line(x,data.veh.throttle_virtual,'LineWidth',1,'Color',[0 0 0]);
[line_objects legend_labels] = add_legend_entry(line_objects,legend_labels,l,'VThrottle');


% Show Legend
if ~isempty(line_objects),
    legend(gca,line_objects,legend_labels,'Location','Northeast','FontSize',10);
    legend('boxoff');
end;


% -------------------------------------------------------------------------------------------------
% Subplot - Speed & Virtual Speed
% -------------------------------------------------------------------------------------------------
ax(3) = subplot(3,1,3);
line_objects = [];
legend_labels = [];

% Set Up Y-Axis
if units == 1,
    YAxisRange = [-10 40];
    YAxisTicks = [-10 -5 0 5 10 15 20 25 30 35 40 45];
    YTickLabels = {'-10' '-5' '0' '5' '10' '15' '20' '25' '30' '35' '40' '45'};
    YAxisTitle = 'Speed (m/s) ';
    YMinorTickStatus = 'off';
else,
    YAxisRange = [-20 75];
    YAxisTicks = [-20 -15 -10 -5 0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85];
    YTickLabels = {'-20' '' '-10' '' '0' '' '10' '' '20' '' '30' '' '40' '' '50' '' '60' '' '70' '' '80' ''};
    YAxisTitle = 'Speed (mph) ';
    YMinorTickStatus = 'off';
end;

YGridStatus = 'off';

% Apply Axis Settings
set(gca,'TickDir','out',...
    'XTick',XAxisTicks,'XMinorTick',XMinorTickStatus,'XTickLabel',XTickLabels,...
    'YTick',YAxisTicks,'YMinorTick',YMinorTickStatus,'YTickLabel',YTickLabels,...
    'YGrid',YGridStatus,...
    'FontSize',12,'Color',BackgroundColor);
   %'PlotBoxAspectRatio',PlotBoxAspectRatio,...
xlim(XAxisRange);
ylim(YAxisRange);
xlabel(XAxisTitle,'fontsize',14,'fontweight','b');
ylabel(YAxisTitle,'fontsize',14,'fontweight','b');

% Draw Black Vertical Plot Box Line on Right Side of Graph
% line([XAxisRange(2) XAxisRange(2)],YAxisRange,'Color',[0 0 0]);
% Draw Black Horizonal Plot Box Line on Top of Graph
% line(XAxisRange,[YAxisRange(2)-.3 YAxisRange(2)-.3],'Color',[0 0 0]);

% Plot ACC Set Speed
if raw,
    l = line(x,data.acc.set_speed*units,'LineWidth',1,'Color',amber);
else,
    l = non_zero_line(x,data.acc.set_speed*units,0,1.5,amber);
end;
[line_objects legend_labels] = add_legend_entry(line_objects,legend_labels,l,'Set Speed');

% Plot Speed
l = line(x,data.veh.speed*units,'LineWidth',1,'Color',[0 0 0]);
[line_objects legend_labels] = add_legend_entry(line_objects,legend_labels,l,'Speed');

% Lead Veh Comm Speed
%l = line(x,data.comm.speed*units,'LineWidth',1,'Color',speedometer_orange);
%[line_objects legend_labels] = add_legend_entry(line_objects,legend_labels,l,'LV Speed');

% Virtual LV Speed
l = line(x,(data.veh.speed+data.acc.virtual_speed)*units,'LineWidth',1,'Color',[0 0 .75]);
[line_objects legend_labels] = add_legend_entry(line_objects,legend_labels,l,'Virt Speed');

% Relative LV Speed
l = line(x,(data.veh.speed+data.acc.rel_speed)*units,'LineWidth',1,'Color',[0 0.75 0]);
[line_objects legend_labels] = add_legend_entry(line_objects,legend_labels,l,'LV Speed');

% Plot Brake
if raw,
    if units == 1,
        amp = 2;
    else,
        amp = 5;
    end;
    l = line(x,data.veh.brake*amp,'LineWidth',1,'Color',[1 0 0]);
else,
    l = non_zero_line(x,data.veh.speed.*double(data.veh.brake)*units,0,1.5,[1 0 0]);
end;
[line_objects legend_labels] = add_legend_entry(line_objects,legend_labels,l,'Brake');

% Show Legend
if ~isempty(line_objects),
    legend(gca,line_objects,legend_labels,'Location','Northeast','FontSize',10);
    legend('boxoff');
end;


% ------------------------------------------------------------------------------
% Link Subplot X-Axes
% ------------------------------------------------------------------------------
linkaxes(ax,'x');

% ------------------------------------------------------------------------------
% Enable Zoom Callback Function
% ------------------------------------------------------------------------------
z = zoom;
set(z,'ActionPostCallback',@resize_xaxis_ts_on_zoom);

end


% -------------------------------------------------------------------------------------------------
% Function to add a legend entry
% -------------------------------------------------------------------------------------------------
function [line_objects legend_labels] = add_legend_entry(line_objects,legend_labels,l,text)

if ~isempty(l),
    entry = length(line_objects) + 1;
    line_objects(entry) = l;
    legend_labels{entry} = text;
end;

end


% -------------------------------------------------------------------------------------------------
% Function to remove zero values from a plot
% -------------------------------------------------------------------------------------------------
function [l] = non_zero_line(x,y,zero_value,Lwidth,Lcolor,Marker)

% Locate non-zero elements
non_zero_index = find(y ~= zero_value);
if isempty(non_zero_index),
    l = [];
    return;
end;

% Subtract each element from each subsequent element to find sequence breaks
diff_index = non_zero_index(1:length(non_zero_index)-1) - non_zero_index(2:length(non_zero_index));
right_break_index = find(diff_index ~= -1);
right_break_index = [right_break_index; length(non_zero_index)]; % Add last element

% Plot each non-zero section
for i=1:length(right_break_index),
    % Define left edge of line
    if i == 1,
        left = non_zero_index(1);
    else,
        left = non_zero_index(right_break_index(i-1)+1);
    end;
    right = non_zero_index(right_break_index(i));
    if nargin == 6 && ischar(Marker),
        l = line(x(left:right),y(left:right),'LineWidth',Lwidth,'Color',Lcolor,'Marker',Marker);
    else,
        l = line(x(left:right),y(left:right),'LineWidth',Lwidth,'Color',Lcolor);
    end;
end;

end