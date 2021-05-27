% resize_xaxis_ts_on_zoom.m
%
% Written by Christopher Nowakowski
% 3/18/2009
%
% This is a callback function for a zoom event.  It is intended to be used when
% the X-Axis was originally scaled using the get_graph_xaxis_ts_scale.m
% function.  The problem is that once you manually set the X-Axis limits, like
% you tend to need to do if the axis is in timescale units, then MatLab freezes
% that axis scaling, even if you zoom in.
%
% This function will dynamically rescale and relabel the units on the X-Axis in
% response to a user zoom event.
% 
% Add the following code to the end of your graphing routine to enable this zoom 
% callback function for your graph:
%
% ------------------------------------------------------------------------------
% Enable Zoom Callback Function
% ------------------------------------------------------------------------------
% z = zoom;
% set(z,'ActionPostCallback',@resize_xaxis_ts_on_zoom);
% ------------------------------------------------------------------------------
%
% Note: if you have multiple subplots, I suggest that you link them with the 
% following command: linkaxes([axes object list],'x');
%
% There is a known bug when using multiple subplots.  If you do the zoom
% operations on the first subplot, and then switch to zooming in on a second
% subplot, only the original subplot that you started zooming in on will retain
% the ability to zoom back out to the orginal graph settings.  
%
% Fix: If you wish to zoom out to the original plot, click on a zoom tool, then 
% right-click on a graph and choose 'reset to original view' from the contextual 
% menu.
%


function resize_xaxis_ts_on_zoom(obj,evd)

% obj tells you what type of object did the callback (in this case, a figure)
% evd is a handle to the event object (which in this case is an Axes)
% evd is a 1x1 structure such that evd.Axes is a reference to the Axes being zoomed

% Get Reference to the Current Active Figure Number
h = gcf;

% Get Newly Requested X-Axis Limits
ReqXLim = get(evd.Axes,'XLim');
% disp(['The requested X-Limits are ' num2str(ReqXLim(1),'%2f') ' to ' num2str(ReqXLim(2),'%2f')]);
ReqXLim = ReqXLim';

% Determine whether X-Axis is Currently Relative or Absolute
XTickLabels = get(evd.Axes,'XTickLabel');
if isempty(XTickLabels),
    scale_mode = '-rel';
elseif (~isempty(findstr(XTickLabels{1},':'))),
    % Labels are in time-of-day format HH:MM
    scale_mode = '-abs';
else,
    % Labels start at 0 and counts up
    scale_mode = '-rel';   
end;

% Get New X-Axis Scaling
[XAxisRange XAxisTicks XTickLabels XAxisTitle] = get_graph_xaxis_ts_scale(ReqXLim,0,scale_mode);
% disp(['The filtered X-Limits will be ' num2str(XAxisRange(1),'%2f') ' to ' num2str(XAxisRange(2),'%2f')]);

% Get All Axes and Legend Handles & Loop Through Them
all_axes = get(h,'Children');
for i=1:length(all_axes),
    
    % Determine if Axes is a Tool, Legend, or Axis
    axes_type = get(all_axes(i),'Type');    % If it's an Axis or Legend, this will be 'axes'
    axes_tag = get(all_axes(i),'Tag');      % If this is an Axis, it will be ''
    if (strcmpi(axes_type,'axes') && length(axes_tag) == 0),
        
        % Axes is the graph axis so reset the X-Axis scale
        set(all_axes(i),'XLim',XAxisRange,'XTick',XAxisTicks,'XTickLabel',XTickLabels);
        
        % Update the XAxisTitle label saving any prefix that was added before the word 'Time'
        title_obj = get(all_axes(i),'XLabel');
        old_title = get(title_obj,'String');
        str_start = findstr(old_title,'Time');
        if (~isempty(str_start) && str_start > 1),
            new_title = [old_title(1:str_start-1) XAxisTitle];
        else,
            new_title = XAxisTitle;
        end;
        set(title_obj,'String',new_title)
    end;
    
end;    % For i...

end