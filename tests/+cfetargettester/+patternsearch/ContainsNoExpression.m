classdef (Abstract) ContainsNoExpression < cfetargettester.patternsearch.Contains
    % Super class for DoesNotContainPatterns and DoesNotContainStrings

    methods
        function obj = ContainsNoExpression(patterns, interpretation)
            obj = obj@cfetargettester.patternsearch.Contains(patterns, interpretation);
        end
    end
    
    methods(Access = protected)
        function result = matchesExpression(constraint, actual)           
            % Find which patterns exist
            count = cell2mat(cellfun(...
                @(x)numel(...
                constraint.Interpretation.FindMethod(actual.Content, x)), ...
                constraint.Patterns, 'UniformOutput', false));
            
            % If any pattern exists, this is a failure
            result = ~any(count);            
        end
        
        function msg = generateFailingCondition(constraint, actual)
            % Get line number information
            [count, linenumbers] = getResultVector(constraint, actual);
            
            msg = sprintf(['Content of %s \n fails constraint ' class(constraint)], actual.getDiagnostic());
            for patternIterator = 1:numel(constraint.Patterns)
                if count(patternIterator)
                    msg = sprintf(['%s\n\t%s:''%s'' was not expected to be ' ...
                        'found. It was found at line number'], msg, ...
                        constraint.Interpretation.OutputString, ...
                        constraint.Patterns{patternIterator});
                    if count(patternIterator) > 1
                        msg = sprintf('%ss', msg);
                    end
                    tmpMsg = sprintf(' %d,', ...
                        linenumbers{patternIterator}(1:count(patternIterator)));
                    tmpMsg(end) = '.';
                    msg = sprintf('%s%s', msg, tmpMsg);
                end
            end
        end
        
        function [count, linenumbers] = getResultVector(constraint, actual)
            % Check if we can find all patterns
            count = cell2mat(cellfun(...
                @(x)numel(...
                constraint.Interpretation.FindMethod(actual.Content, x)), ...
                constraint.Patterns, 'UniformOutput', false));
            
            linenumbers = getLineNumbers(constraint, actual);
        end
    end
end
