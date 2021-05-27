% remove listed attributes from a trip file
function removeAttributes(trip, attributeList)
    meta_info = trip.getMetaInformations;
    for i_attribute = 1:length(attributeList)
        attribute = attributeList{i_attribute};
        if meta_info.existAttribute(attribute)
            disp(['Adding attribute ' attribute ' in trip ' trip.getTripPath]);
            trip.removeAttribute(attribute);
        else
            disp([attribute ' attribute doesn''t exist']);
        end
    end
end