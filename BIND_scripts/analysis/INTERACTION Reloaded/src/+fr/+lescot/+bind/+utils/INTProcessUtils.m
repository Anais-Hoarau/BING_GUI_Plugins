%{
Class:
This class contains some static methods used to process INTERACTION PI
%}
classdef INTProcessUtils
    %INTPROCESSUTILS Summary of this class goes here
    %   Detailed explanation goes here
    
    
    methods(Static)
        %{
            This function will connect to an INTERACTION trip, look for the
            'MatchedPOS' data and will use the 3 variables : 'wayType', 'wayAreaType', 'wayLegalSpeedLimit'
            To define the percentage of road contexts of the time window startTime - endTime

            Arguments:
            - Trip : the trip to look into
            - startTime : time of the start window to look from
            - endTime : time of the start window to look to

            Returns:
            - A cell containing the value of ratio of the 3 road context : Highway, rural, urban

            Modifiers:
            - Static
        %}
        function out = getRoadContextRatio( theTrip,startTime,endTime )
            
            %initialisation
            if nargout,
                out=[];
            end
            
            %input arguments
            if ~nargin | nargin ~= 3,
                error('DIRREC requires 3 arguments')
                return
            end
            
            % study of the driving time and distance dispatching according to
            % driving context
            
            roadTypeRecord = theTrip.getDataOccurencesInTimeInterval('MatchedPOS',startTime,endTime);
            if roadTypeRecord.isEmpty()
                out = [];
            end
            wayType = cell2mat(roadTypeRecord.getVariableValues('wayType'));
            wayAreaType = cell2mat(roadTypeRecord.getVariableValues('wayAreaType'));
            wayLegalSpeedLimit = cell2mat(roadTypeRecord.getVariableValues('wayLegalSpeedLimit'));
            originalWayAreaType = wayAreaType;
            
            % first find when driver is on the highway
            indexesOnHighway1 = find(wayType>=64); % 0x40 = 64
            % and add the fast way not labelled as highway
            indexesOnHighway2 = find(wayLegalSpeedLimit>=110); % keep only fast zones
            
            sampleOnHighway = length(indexesOnHighway1) + length(indexesOnHighway2);
            % intersection of the samples
            indexesOnHighway = intersect(indexesOnHighway1,indexesOnHighway2);
            
            % remove from the data all the moment when driver is on highway
            wayAreaType(indexesOnHighway) = [];
            wayLegalSpeedLimit(indexesOnHighway) = [];
            
            % in the remaining data, find when driver is on unknow roads
            indexesUnknow = find(wayAreaType==00);
            wayAreaType(indexesUnknow) = [];
            wayLegalSpeedLimit(indexesUnknow) = [];
            
            indexesUrban = find(wayLegalSpeedLimit<=60); % keep only slow zones
            sampleOnUrban = length(indexesUrban);
            % remove from data urban samples
            wayAreaType(indexesUrban) = [];
            
            % what's remain is rural
            sampleOnRural = length(wayAreaType);
            
            percentageHighway = 0;
            percentageRural  = 0;
            percentageUrban = 0;
            totalSamples = sampleOnHighway + sampleOnRural + sampleOnUrban;
            if totalSamples > 0
                percentageHighway = sampleOnHighway  / totalSamples * 100;
                percentageRural = sampleOnRural  / totalSamples * 100;
                percentageUrban = sampleOnUrban  / totalSamples * 100;
            end
            
            out = [percentageHighway percentageRural percentageUrban];
            
        end
    end
end