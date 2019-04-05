classdef (Abstract) ContainsOrderedExpression < cfetargettester.patternsearch.Contains

    methods
        function obj = ContainsOrderedExpression(patterns, interpretation)
            obj = obj@cfetargettester.patternsearch.Contains(patterns, interpretation);
        end
    end
    
    methods(Access = protected)
        function result = matchesExpression(constraint, actual)
            % Make a copy of the content
            content = actual.Content;
            
            for i = 1:numel(constraint.Patterns)
                % Find the occurrence of the pattern
                [startIdx, endIdx] = constraint.Interpretation.getPosition(content, constraint.Patterns{i});
                
                % If the pattern was not found, then error
                if numel(startIdx) == 0
                    result = false;                    
                    return;
                end
                
                % remove content of Content from the beginning of the
                % content to the end of the found pattern
                content(1:endIdx(1)) = [];
            end
            
            result = true;
        end
        
        function msg = generateFailingCondition(constraint, actual)
            msg = sprintf(['Following %ss were expected to be found in ' ...
                'order\n\n'], constraint.Interpretation.OutputString);
            tmpMsg = sprintf('\t%s\n', constraint.Patterns{:});
            msg = sprintf('%s%s', msg, tmpMsg);
            msg = sprintf('%sThey were not found in order.\n', msg);
            msg = sprintf('%s\nWithin File: %s\nWithin Section: %s', msg, ...
                actual.FileName, getDiagnostic(actual));
            
         end
    end
end
