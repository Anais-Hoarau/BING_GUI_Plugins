function [index, lats_area, longs_area]=defineSearchArea(lat_parcours, long_parcours, lat_centre, long_centre, searchAngle)

M = lat_parcours > lat_centre - searchAngle & lat_parcours < lat_centre + searchAngle & long_parcours > long_centre - searchAngle & long_parcours < long_centre + searchAngle;
index = find (M);
lats_area = lat_parcours(M);
longs_area = long_parcours(M);

end