function [dist] = dist_euclide(x1 , y1 , x2 , y2)

dist = sqrt( (x1-x2).^2 + (y1-y2).^2 );

