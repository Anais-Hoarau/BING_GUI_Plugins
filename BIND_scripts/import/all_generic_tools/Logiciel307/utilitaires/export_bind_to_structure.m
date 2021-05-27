%% export_bind_to_structure
% This function adds a new field (from BIND) in an existing data structure.
% 
%
% input arguments:
% trip:             The trip to export data from
% input_struct:     The structure of the relevant data source (for example
%                   all the codings done into bind can be grouped in a
%                   'video_coding' structure.
% marker_type:      The type of data that is exported from BIND ('data',
%                   'event' or 'situation'.
% marker_name:      The BIND name of the table that will be exported (for
%                   exemple 'GPS_5Hz').
%
% output arguments:
% output_struct:    The input structure in which a new field containing the
%                   data exported from BIND has been created.
%
%
% Example of use:
% Let's have say we have a structure with data:
% ExperimentName.SubjectNumber.Mopad
% ExperimentName.SubjectNumber.Kvaser
% And we have coded in BIND events in an event table called "codage".
% We want to export this event table in the 'video_coding' data source of
% the "ExperimentName" Structure.
% To do that, we call the function this way:
% 
% ExperimentName.SubjectNumber.video_coding = struct;
% ExperimentName.SubjectNumber.video_coding = ...
% export_bind_to_structure(trip,ExperimentName.SubjectNumber.video_coding,'event','codage');
%

function output_struct = export_bind_to_structure(trip,input_struct,marker_type,marker_name)

    output_struct = input_struct;

    switch(marker_type)
        case 'data'
            meta_marker_handler = @getMetaData;
            get_marker_values_handler = @getAllDataOccurences;
        case 'event'
            meta_marker_handler = @getMetaEvent;
            get_marker_values_handler = @getAllEventOccurences;
        case 'situation'
            meta_marker_handler = @getMetaSituation;
            get_marker_values_handler = @getAllSituationOccurences;
        otherwise
            exception = MException('ArgType:Unknown', ...
                        ['The type of tat ''' ...
                        ''' is not a valid BIND data type (use ''data'', ''event'', or ''situation'').']);
            throw(exception);
    end
    
    meta_info = trip.getMetaInformations();
        
    marker_struct = struct;

    meta_marker = meta_marker_handler(meta_info,marker_name);

    % get the variables
    variable_list = meta_marker.getVariablesAndFrameworkVariables();
    marker_values_record = get_marker_values_handler(trip,marker_name);

    % parses each variable
    for v = 1:length(variable_list)
        variable_struct = struct;
        variable_meta = variable_list{v};

        % parses the variable_name
        variable_name = variable_meta.getName();
        if strcmp(variable_name,'timecode')
            variable_new_name = 'time_sync';
        else
            variable_new_name = strrep(variable_name,' ','_');
            variable_new_name = strrep(variable_new_name,'é','e');
            variable_new_name = strrep(variable_new_name,'è','e');
            variable_new_name = strrep(variable_new_name,'à','a');
            variable_new_name = strrep(variable_new_name,'%','POURCENT_');
            variable_new_name = strrep(variable_new_name,'.','POINT_');
        end

        % fill up the variable_struct
        cell_values = marker_values_record.getVariableValues(variable_name);
        if strcmp('REAL',variable_meta.getType())
            variable_struct.values = cell2mat(cell_values);
        else
            % strings are stored in cell_arrays...
            variable_struct.values = cell_values;
        end
        variable_struct.unit = variable_meta.getUnit();
        variable_struct.comments = variable_meta.getComments();

        % for each variable => add the variable_new_name in data_struct
        marker_struct = setfield(marker_struct,variable_new_name,variable_struct);
    end
    % for each data => add the data_struct in bind_struct
    output_struct = setfield(output_struct,marker_name,marker_struct);

end