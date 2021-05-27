%% strcmp_trip_meta_attribute function
% This function compare the value of a meta attribute to an expected value.
% It returns true if the meta attribute exists and its value is the same as
% expected value. It return false otherwise (if the value is different or
% if the meta attribute doesn't exist).
%
% out = strcmp_trip_meta_attribute(trip,meta_attr_id,value)
% 
% Arguments:
% trip:         the Trip object to be processed
% meta_attr_id: the meta attribute to be tested
% value:        the expected value of the meta attribute
%
% Output:
% out:          strcmp of the meta attribute value and the value if the
%               meta attribute exists, false otherwise

function out = strcmp_trip_meta_attribute(trip,meta_attr_id,value)
    % check if the meta attribute exists
    if any(strcmp(trip.getMetaInformations.getTripAttributesList,meta_attr_id))
        % meta attibute exists
        meta_attr_value = trip.getAttribute(meta_attr_id);
        out = strcmp(meta_attr_value,value);
    else
        out = false;
    end
end