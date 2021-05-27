% get_graph_xaxis_ts_scale.m
%
% Written by Christopher Nowakowski
% v 1.0     1/20/2009   - First Version
%
% This is a script to scale the X-Axis of a graph based on a column of timestamps
% and a type definition, either relative (to the first timestamp) or absolute (HH:MM).
%
% Inputs
% clock = data.ts.ssm
% scaling_type = Relative or Absolute
%
% Outputs
% XAxisRange [Min Max]
% XAxisLabels [Min Step Step... Max]
% XTickLabels {Label Label Label}
% XAxisTitle = Char Title with Units
%

function [XAxisRange XAxisTicks XTickLabels XAxisTitle] = get_graph_xaxis_ts_scale(clock,padding,absolute)

% -------------------------------------------------------------------------------------------------
% Check Input Arguments
% -------------------------------------------------------------------------------------------------
usage_msg = 'Usage: [XAxisRange XAxisTicks XTickLabels XAxisTitle] = get_graph_xaxis_ts_scale(data.ts.ssm,padding,[''-rel'' or ''-hms'']);';

if nargin == 0 || (nargin == 1 && ischar(clock) && strcmpi(clock,'?')),
    disp(usage_msg);
    disp('Padding is an integer corresponding to number of minimum time steps by which to pad the x-axis.');
    return;

elseif nargin == 1 && isnumeric(clock) && length(clock) >= 2,
    absolute = 0;
    padding = 0;

elseif nargin == 2 && isnumeric(clock) && length(clock) >= 2 && isnumeric(padding),
    absolute = 0;
    
elseif nargin == 3 && isnumeric(clock) && length(clock) >= 2 && isnumeric(padding),    
    if strcmpi(absolute,'-abs') || strcmpi(absolute,'abs') || strcmpi(absolute,'-a') || strcmpi(absolute,'-hms'),
        absolute = 1;
    else,
        absolute = 0;
    end;

else,
    error(usage_msg);
end;


% ------------------------------------------------------------------------------
% X-Axis Setup Based on Relative Data Range
%
% Set timestep equal to the number of seconds between each tick mark
% Set labelstep as the corresponding time difference between consecutive labels
% Set labelskip as the number of timesteps between each label
% snapto is whether the right side ends on a timestamp or fraction thereof
% ------------------------------------------------------------------------------

% Calculate Relative Data Range
xmin = clock(1);
xmax = clock(length(clock));
xrange = (xmax - xmin);

if xrange <=20,
    
    % Data is less than 20 seconds
    timestep = 1;       % 1 s
    if absolute,
       labelstep = 5;   % 5 s
       labelskip = 5;
       XAxisTitle = 'Time (HH:MM:SS) (1 s)';
    else,
        labelstep = 1;  % 1 s
        labelskip = 1;
        XAxisTitle = 'Time (s)';
    end;
    snapto = timestep;
    

elseif xrange <= 60,

    % Data is less than 1 minute
    if absolute,
        timestep = 1;   % 1 s
        labelstep = 10; % 10 s
        labelskip = 10;
        snapto = timestep;
        XAxisTitle = 'Time (HH:MM:SS) (1 s)';
    else,
        timestep = 1;   % 1 s
        labelstep = 5;  % 5 s
        labelskip = 5;
        snapto = timestep;
        XAxisTitle = 'Time (s)';
    end;
    

elseif xrange <= 120,

    % Data is less than 2 minutes
    if absolute,
        timestep = 10;      % 10 s
        labelstep = 30;     % 30 s
        labelskip = 3;
        snapto = labelstep;
        XAxisTitle = 'Time (HH:MM:SS) (10 s)';
    else,
        timestep = 5;       % 5 s
        labelstep = 10;     % 10 s
        labelskip = 2;
        snapto = timestep;
        XAxisTitle = 'Time (s)';
    end;
    

elseif xrange <= 300,

    % Data is less than 5 minutes so plot in seconds
    timestep = 10;      % 10 s
    labelstep = 30;     % 30 s
    labelskip = 3;
    if absolute,
        snapto = labelstep;
        XAxisTitle = 'Time (HH:MM:SS) (10 s)';
    else,
        snapto = timestep/2;
        XAxisTitle = 'Time (s)';
    end;    
    

elseif xrange <= 900,

    % Data is less than 15 minutes
    timestep  = 60;     % 1 min
    labelstep = 1;      % 1 min
    labelskip = 1;
    snapto = timestep;
    if absolute,
        XAxisTitle = 'Time (HH:MM)';
    else,
        XAxisTitle = 'Time (min)';
    end;
    
elseif xrange <= 4500,

    % Data is less than 75 minutes
    timestep = 300;     % 5 min
    labelstep = 5;      % 5 min
    labelskip = 1;
    snapto = timestep;
    if absolute,
        XAxisTitle = 'Time (HH:MM)';
    else,
        XAxisTitle = 'Time (min)';
    end;
    
elseif xrange <= 9000,

    % Data is less than 150 minutes (2.5 hours)
    timestep = 600;     % 10 min
    labelstep = 10;     % 10 min
    labelskip = 1;
    snapto = timestep/2;
    if absolute,
        XAxisTitle = 'Time (HH:MM)';
    else,
        XAxisTitle = 'Time (min)';
    end;
    
else,
    
    % Data is is greater than 2.5 hours
    timestep = 1800;    % 30 minutes
    labelstep = 1;      % 1 hour
    labelskip = 2;
    snapto = timestep/3;
    if absolute,
        XAxisTitle = 'Time (HH:MM)';
    else,
        XAxisTitle = 'Time (h)';
    end;
    
    
end;


% ------------------------------------------------------------------------------
% Apply X-Axis Settings
% ------------------------------------------------------------------------------

% Set XAxisRange
if absolute,
    xmin = floor(clock(1)/snapto)*snapto;
    xmax = ceil(clock(length(clock))/snapto)*snapto + snapto*padding;
else,
    xmax = xmin + ceil(xrange/snapto)*(snapto) + (snapto)*padding;
end;
XAxisRange = [xmin xmax];

% Set XAxisLabels and XTickLabels
i = 1;      % Array index
label = 0;  % Used for relative mode

for tick_mark_time=xmin:timestep:xmax,
    
    % Record Tick Mark Time in Seconds
    XAxisTicks(i) = tick_mark_time;
    
    % Check To See If Tick Mark Gets a Text Label
    if (mod(i-1,labelskip) == 0),
        
        % Record Tick Mark Label
        if absolute,
            hhmmss = convert_text_ts(tick_mark_time);
            if timestep < 60,
                XTickLabels{i} = hhmmss(1:8);
            else,
                XTickLabels{i} = hhmmss(1:5);
            end;
        else,
            XTickLabels{i} = num2str(label,'%d');
            label = label + labelstep;
        end;
    
    else,    
        % Skip This Label
        XTickLabels{i} = '';
    end;

    
    % Increment array index
    i = i+1;
end;


end