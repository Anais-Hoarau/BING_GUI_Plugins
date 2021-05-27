% Check if MetaAttribute attribute is present in the trip
% and if its value is equal to expected_value.
% Return true if attribute exists and attribute value equals
% expected_value, return false otherwise
% If expected_value is not a char (let's say = 0), then just check the presence of the attribute.
function out = check_trip_meta(trip,attribute,expected_value)
    try % Ideally, no need to have a try/catch: there should be a attributeExists method!
        value = trip.getAttribute(attribute);
        if strcmp(value,expected_value) || ~ischar(expected_value)
            out = true;
        else
            out = false;
        end
    catch ME
        % Ideally, test ME to check that it is an empty array error.
        out = false;
    end
end