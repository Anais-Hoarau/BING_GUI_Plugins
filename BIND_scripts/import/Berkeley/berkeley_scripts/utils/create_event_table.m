% create_event_table.m
%
% Written by Christopher Nowakowski
% v.1  02/10/10
%
% This function basically creates an event table from a column of row numbers
% that were generated from using the find() command.  The function searches 
% for breaks in the row numbers.  Each block of contiguous row numbers is
% labeled as an event. The resulting event table has one row per event, and 
% contains the row number of the start of the event and the rown number of the 
% end of the event.
%
% Input:
%
% A column of row numbers that were generated from using the find() command
%
% Output:
%
% event_table = [event_number start_row end_row]
%
% Usage: [event_table] = create_event_table(event_index)
%

function [event_table] = create_event_table(event_index)

% ------------------------------------------------------------------------------
% Parse & Check Function Input Arguments
% ------------------------------------------------------------------------------
usage_msg = 'Usage: [event_table] = create_event_table(event_index);';

if (nargin == 1 && ischar(event_index) && strcmpi(event_index,'?')),
    disp(usage_msg);
    disp('event_table(:,1) = Event Number');
    disp('event_table(:,2) = Row where event started');
    disp('event_table(:,3) = Row where event ended');
    return;
elseif (nargin ~=1) || (nargin ==1 && ~isnumeric(event_index)),
    error(usage_msg);
end;


% ------------------------------------------------------------------------------
% Handle Empty Set Input
% ------------------------------------------------------------------------------
if isempty(event_index)
    event_table = [];
    return;
end;


% ------------------------------------------------------------------------------
% Find The Right Boundary of Each Distinct Event
% ------------------------------------------------------------------------------
diff_index = event_index(1:length(event_index)-1) - event_index(2:length(event_index));
right_break_index = find(diff_index ~= -1);
right_break_index = [right_break_index; length(event_index)];


% ------------------------------------------------------------------------------
% Create an Event Table
% ------------------------------------------------------------------------------
for i=1:length(right_break_index),
    event_table(i,1) = i;                                                       %#ok<*AGROW> % Event ID/Order
    if i == 1,
        event_table(i,2) = event_index(1);                                      % Data Row of Event Start
    else
        event_table(i,2) = event_index(right_break_index(i-1)+1);
    end;
    event_table(i,3) = event_index(right_break_index(i));                       % Data Row at Event End
end;

end