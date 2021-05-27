% graph_acc_overview.m
% 
% Written by Christopher Nowakowski
% v 1.0     12/9/2008   - First version written
%
% This is a script to create an overview graph the CACC data structure.  It 
% generates three stacked graphs: ACC Settings, Following Time Gap, and Speed.
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

function [h] = graph_acc_overview(data,flags)

% -------------------------------------------------------------------------------------------------
% Check Input Arguments
% -------------------------------------------------------------------------------------------------
usage_msg = 'Usage: [h] = graph_acc_overview(data,flags);';

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
% X-Axis Setup (either ssm or utc_ssm)
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
% Subplot - ACC System Status
% -------------------------------------------------------------------------------------------------
ax(1) = subplot(3,1,1);
line_objects = [];
legend_labels = [];

% Set Up Y-Axis
YAxisRange = [0 9.5];
YAxisTicks = [0 1 2 3 4 5 6 7 8 9];
% Note: Also setting 'YTickLabel' in the set command
YAxisTitle = 'ACC Gap Settings        ';
YMinorTickStatus = 'off';
YGridStatus = 'off';

% Apply Axis Settings
set(gca,'TickDir','out',...
    'XTick',XAxisTicks,'XMinorTick',XMinorTickStatus,'XTickLabel',XTickLabels,...
    'YTick',YAxisTicks,'YMinorTick',YMinorTickStatus,'YGrid',YGridStatus,...
    'YTickLabel',{'','0.6 s','0.7 s','0.9 s','1.1 s','1.6 s','2.2 s','Warnings','Active','ACC On'},...    
    'FontSize',12,'Color',BackgroundColor);
   %'PlotBoxAspectRatio',PlotBoxAspectRatio,...
xlim(XAxisRange);
ylim(YAxisRange);
xlabel(XAxisTitle,'fontsize',14,'fontweight','b');
ylabel(YAxisTitle,'fontsize',14,'fontweight','b');

% Apply Figure Title to First Subplot
title(FigureTitle,'fontsize',16,'fontweight','b');

% Draw Black Vertical Plot Box Line on Right Side of Graph
%line([XAxisRange(2) XAxisRange(2)],YAxisRange,'Color',[0 0 0]);
% Draw Black Horizonal Plot Box Line on Top of Graph
%line(XAxisRange,[YAxisRange(2)-.03 YAxisRange(2)-.03],'Color',[0 0 0]);


% Plot acc.enabled
if raw,
    line(x,data.acc.enabled*9,'LineWidth',1,'Color',[0 0 0]);
else,
    non_zero_line(x,data.acc.enabled*9,0,1.5,[0 0 0]);
end;

% Plot acc.active
if raw,
    line(x,data.acc.active*8,'LineWidth',1,'Color',[0 0 .5]);
else,
    non_zero_line(x,data.acc.active*8,0,1.5,[0 0 .5]);
end;

% Test Code
%data.acc.appr_warn(1000) = 3;
%data.acc.buzzer(5000) = 127;
%data.acc.buzzer2(10000) = 1;
%data.acc.buzzer3(15000) = 1;

% Plot warnings ('Marker','*')
l = non_zero_line(x,data.acc.appr_warn/3*8,0,1.5,[1 0 0],'d');
[line_objects legend_labels] = add_legend_entry(line_objects,legend_labels,l,'Approach Warning');

% Calculate Time Stamp Inegrity
ts_integrity = get_ts_integrity(x,0.085,0.015);

if raw,
    l = line(x,ts_integrity*7,'LineWidth',1,'Color',[0 .5 0]);
    if min(ts_integrity) ~= 0 || max(ts_integrity) ~= 0,
        [line_objects legend_labels] = add_legend_entry(line_objects,legend_labels,l,'Timestamp');
    end;
    
    l = line(x,data.acc.buzzer/127*7,'LineWidth',1,'Color',[1 0 0]);
    if min(data.acc.buzzer) ~= 0 || max(data.acc.buzzer) ~= 0,
        [line_objects legend_labels] = add_legend_entry(line_objects,legend_labels,l,'Buzzer');
    end;
    
    l = line(x,data.acc.buzzer2*7,'LineWidth',1,'Color',[.75 0 0]);
    if min(data.acc.buzzer2) ~= 0 || max(data.acc.buzzer2) ~= 0,
        [line_objects legend_labels] = add_legend_entry(line_objects,legend_labels,l,'Buzzer 2');
    end;
    
    l = line(x,data.acc.buzzer3*7,'LineWidth',1,'Color',[.5 0 0]);
    if min(data.acc.buzzer3) ~= 0 && max(data.acc.buzzer3) ~= 0,
        [line_objects legend_labels] = add_legend_entry(line_objects,legend_labels,l,'Buzzer 3');
    end;
else,
    
    l = non_zero_line(x,ts_integrity*7,0,1.5,[0 .5 0],'*');
    [line_objects legend_labels] = add_legend_entry(line_objects,legend_labels,l,'Timestamp');
    
    l = non_zero_line(x,data.acc.buzzer/127*7,0,1.5,[1 0 0],'*');
    [line_objects legend_labels] = add_legend_entry(line_objects,legend_labels,l,'Buzzer');
    
    l = non_zero_line(x,data.acc.buzzer2*7,0,1.5,[.75 0 0],'d');
    [line_objects legend_labels] = add_legend_entry(line_objects,legend_labels,l,'Buzzer 2');
    
    l = non_zero_line(x,data.acc.buzzer3*7,0,1.5,[.5 0 0],'s');
    [line_objects legend_labels] = add_legend_entry(line_objects,legend_labels,l,'Buzzer 3');
end;

% Plot acc.car_space
if raw,
    line(x,data.acc.car_space.*data.acc.enabled,'LineWidth',1,'Color',speedometer_orange);
else,
    non_zero_line(x,data.acc.car_space.*data.acc.enabled,0,1.5,speedometer_orange);
end;

% Show Legend
if ~isempty(line_objects),
    %legend_bottom = 0.86 - 0.015*(length(line_objects)-1)/2;
    %legend(gca,line_objects,legend_labels,'Location',[.78 legend_bottom .12 .025],'FontSize',10);
    legend(gca,line_objects,legend_labels,'Location','Northeast','FontSize',10);
    legend('boxoff');
end;



% -------------------------------------------------------------------------------------------------
% Subplot - Following Distance
% -------------------------------------------------------------------------------------------------
ax(2) = subplot(3,1,2);
line_objects = [];
legend_labels = [];

% Set Up Y-Axis
YAxisRange = [0 4];
YAxisTicks = [-1.0 -0.5 0.0 0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0];
% Note: Also setting 'YTickLabel' in the set command
YAxisTitle = 'Following Time Gap (s) ';
YMinorTickStatus = 'on';
YGridStatus = 'off';

% Apply Axis Settings
set(gca,'TickDir','out',...
    'XTick',XAxisTicks,'XMinorTick',XMinorTickStatus,'XTickLabel',XTickLabels,...
    'YTick',YAxisTicks,'YMinorTick',YMinorTickStatus,'YGrid',YGridStatus,...
    'YTickLabel',{'-1.0','-0.5','0.0','0.5','1.0','1.5','2.0','2.5','3.0','3.5','4.0','4.5','5.0'},...
    'FontSize',12,'Color',BackgroundColor);
   %'PlotBoxAspectRatio',PlotBoxAspectRatio,...
xlim(XAxisRange);
ylim(YAxisRange);
xlabel(XAxisTitle,'fontsize',14,'fontweight','b');
ylabel(YAxisTitle,'fontsize',14,'fontweight','b');

% Draw Black Vertical Plot Box Line on Right Side of Graph
%line([XAxisRange(2) XAxisRange(2)],YAxisRange,'Color',[0 0 0]);
% Draw Black Horizonal Plot Box Line on Top of Graph
%line(XAxisRange,[YAxisRange(2)-.02 YAxisRange(2)-.02],'Color',[0 0 0]);

% Plot acc.car_space (but only when acc.active)
y = zeros(length(data.acc.car_space),1);
filter = find(data.acc.car_space == 1);
y(filter) = 0.6;
filter = find(data.acc.car_space == 2);
y(filter) = 0.8;
filter = find(data.acc.car_space == 3);
y(filter) = 0.9;
filter = find(data.acc.car_space == 4);
y(filter) = 1.1;
filter = find(data.acc.car_space == 5);
y(filter) = 1.6;
filter = find(data.acc.car_space == 6);
y(filter) = 2.2;
filter = find(data.acc.active == 0);
y(filter) = 0;


% Plot acc.time_gap
if raw,
    l = line(x,y,'LineWidth',1,'Color',speedometer_orange);
    % l = line(x,data.acc.time_gap,'LineWidth',1,'Color',[0 0 0]);
else,
    l = non_zero_line(x,y,0,1.5,speedometer_orange);
end;
[line_objects legend_labels] = add_legend_entry(line_objects,legend_labels,l,'Gap Setting');

l = non_zero_line(x,data.acc.time_gap,-1,1,[0 0 0]);
[line_objects legend_labels] = add_legend_entry(line_objects,legend_labels,l,'Time Gap');

% Show Legend
if ~isempty(line_objects),
    legend(gca,line_objects,legend_labels,'Location','Northeast','FontSize',10);
    legend('boxoff');
end;


% -------------------------------------------------------------------------------------------------
% Subplot - Speed
% -------------------------------------------------------------------------------------------------
ax(3) = subplot(3,1,3);
line_objects = [];
legend_labels = [];

% Set Up Y-Axis
if units == 1,
    YAxisRange = [0 40];
    YAxisTicks = [0 5 10 15 20 25 30 35 40];
    YTickLabels = {'0' '5' '10' '15' '20' '25' '30' '35' '40'};
    YAxisTitle = 'Speed (m/s) ';
    YMinorTickStatus = 'on';
else,
    YAxisRange = [0 75];
    YAxisTicks = [0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95];
    YTickLabels = {'0' '' '10' '' '20' '' '30' '' '40' '' '50' '' '60' '' '70' '' '80' '' '90' ''};
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
%line([XAxisRange(2) XAxisRange(2)],YAxisRange,'Color',[0 0 0]);
% Draw Black Horizonal Plot Box Line on Top of Graph
%line(XAxisRange,[YAxisRange(2)-.3 YAxisRange(2)-.3],'Color',[0 0 0]);

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