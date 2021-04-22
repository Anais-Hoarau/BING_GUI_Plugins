%{
Class:
This geographic event discoverer finds in a Trip the closest points to a
lis of given points of interest (POIs). The POIs are looked for in the
order of the POICoordinates cell array. For the first POI, the distance between
all the coordinated in inputCellArray are calculated (using the Haversine
formula). Then the closest point is declared to be a match. All the points
that are before the match in inputCellArray are discarded, and the same
algorithm starts over on the next POI, calculating the distance on the
remaining points. This is the only way to discriminate between two passages
at the same point at different moments. So be careful when using this
algorithm, the order of elements in both arguments is very important !
%}
classdef TripPOIFinder < fr.lescot.bind.processing.GeographicEventDiscoverer
    
    methods(Access = public, Static)
        
        %{
        Function:
        
        Arguments:
        POICoordinates : A 2xn cell array, with the first line representing
        the latitude of the POIs and the second line representing the
        longitude of those POIs.
        %}
        function out = extract(inputCellArray, POICoordinates)
            import fr.lescot.bind.processing.*;
            %TODO : ligne à commenter absolument !!!!
            inputCellArray = num2cell(sortrows(cell2mat(inputCellArray)')');
            out = cell(1, size(POICoordinates, 2));
            indexOfLastFoundPOI = 1;
            for i = 1:1:size(POICoordinates, 2)
                %calculate the distance between the POI and all the
                %remaining coordinates
                latPOI = POICoordinates{1,i};
                longPOI = POICoordinates{2,i};
                distances = zeros(1, length(inputCellArray)-indexOfLastFoundPOI+1);
                for j = indexOfLastFoundPOI:1:length(inputCellArray)
                    latGPS = inputCellArray{2, j};
                    longGPS = inputCellArray{3, j};
                    distancesIndex = (j-indexOfLastFoundPOI)+1;
                    distances(distancesIndex) =  geographicEventDiscoverers.TripPOIFinder.calculateDistance(latPOI, longPOI, latGPS, longGPS);
                end

                indexStartOfCloseSituation = -1;
                indexEndOfCloseSituation = -1;
                isInSituation = false;
                maxDistance = 0.05;
                %TODO : gérer le cas ou on a une seule distance consécutive
                %< maxDistance ==> On remet tout à 0 sauf j
                for j = 1:1:length(distances)
                    if ~isInSituation && distances(j) < maxDistance
                        indexStartOfCloseSituation = j;
                        isInSituation = true;
                    elseif isInSituation && distances(j) >= maxDistance
                        indexEndOfCloseSituation = j - 1;
                        break;
                    end
                end
                [minDistance, indexMinDistance] = min(distances(indexStartOfCloseSituation:indexEndOfCloseSituation));
                indexPOIFound = indexMinDistance + (indexStartOfCloseSituation - 1) + (indexOfLastFoundPOI - 1);
                
                out{i} = inputCellArray{1, indexPOIFound};
                indexOfLastFoundPOI = indexPOIFound;
                
                disp(['[' sprintf('%.6f', latPOI) ', ' sprintf('%.6f', longPOI) '] --> [' sprintf('%.6f', inputCellArray{2, indexPOIFound}) ',' sprintf('%.6f', inputCellArray{3, indexPOIFound}) '] (' sprintf('%.2f', minDistance*1000) 'm)']);
            end
        end
        
    end
    
    methods(Access=private, Static)
        
        %{
        Function:
        Calculates the distance in kilometers between two coordinates in
        degrees, using the Haversine formula.
        
        Arguments:
        lat1 - the latitude of point 1 as a numeric value in degrees.
        long1 - the longitude of point 1 as a numeric value in degrees.
        lat2 - the latitude of point 2 as a numeric value in degrees.
        long2 - the longitude of point 2 as a numeric value in degrees.
        
        Returns:
        out - the distance in kilometers between the two points.
        %}
        function out = calculateDistance(lat1, long1, lat2, long2)
            earthRadius = 6371;
            
            %Degrees to radians
            lat1 = lat1*pi/180;
            lat2 = lat2*pi/180;
            long1 = long1*pi/180;
            long2 = long2*pi/180;
            
            %haversine formula
            deltaLat = lat2-lat1;
            deltaLon = long2-long1;
            a = sin(deltaLat/2)^2 + cos(lat2) * cos(lat1) * sin(deltaLon/2)^2;
            c = 2 * atan2(sqrt(a), sqrt(1-a));
            out = earthRadius * c;
        end

    end
    
end

