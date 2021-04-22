%{
Class:
This discoverer is very versatile, since it detects a sequence of values
with a defined relation to a defined threshold. For example you can find
continuous sequences where the value of the signal is equal to 3. Or locate
sequence where the signal is different from a certain value.

It is to be noted that 1 element sequences will not be returned, since they
are not valid BIND sequences (they are closer of events).

So, for example, with this input :
:[1 | 2 | 3 | 4 | 5 | 6 | 7 | 8]
:[4 | 1 | 2 | 3 | 4 | 5 | 5 | 5]
if we set the operator to '>' and the threshold to 3, we will have this
output :
:[ 5 ]
:[ 8 ]
Which mean that from timecodes 5 to 8, the condition signal > 3 is matched.
(see <SituationDiscoverer.extract()> for an explanation of the output format.
If we call the extract method on the same array but with the operator '~='
and the threshold 4, we will have :
:[2 | 6]
:[4 | 8]
%}

classdef ThresholdComparator < fr.lescot.bind.processing.SituationDiscoverer
    
    
    methods (Static)
        
         %{
        Function:

        Arguments:
        operator - a relational operator (one of <, >, <=, >=, ==, ~=)
        threshold - a numeric value
        
        Throws:
        ARGUMENT_EXCEPTION - If operator is not a
        relational operator.
        %}
        function out = extract(inputCellArray, operator, threshold)    
            import fr.lescot.bind.exceptions.ExceptionIds;
            if ~any(strcmpi(operator, {'<' '>' '<=' '>=' '==' '~='}))
                throw(MException(ExceptionIds.ARGUMENT_EXCEPTION.getId(), 'operator must be a relational operator. Type "doc ''Relational Operators''" for a complete list.'));
            end
            logicalFunction = @(value)eval([num2str(value) operator num2str(threshold)]);
            out = fr.lescot.bind.processing.situationDiscoverers.SimpleLogicalFunctionDiscoverer.extract(inputCellArray, logicalFunction); 
        end
        
    end
end

