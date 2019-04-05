% ContainsWithCount - This class implements the MaxCount and the MinCount
% behavior for the ContainsPatterns and ContainsSubstrings class.

classdef(Sealed = true) ContainsWithCount < cfetargettester.patternsearch.Contains
    properties(SetAccess = private)
        MaxCount;   % Maximum number of times a pattern/string is expected to be found
        MinCount;   % Minimum number of times a pattern/string is expected to be found
    end

    methods
        function obj = ContainsWithCount(patterns, interpretation, varargin)
            obj = obj@cfetargettester.patternsearch.Contains(patterns, interpretation);
            
            p = inputParser;
            p.addParameter('MaxCount', inf, @(Count) (validateattributes(Count, {'numeric'}, {'scalar','nonnegative','finite','integer'})));
            p.addParameter('MinCount', 1, @(Count) (validateattributes(Count, {'numeric'}, {'scalar','nonnegative','finite','integer'})));
            p.parse(varargin{:});
            
            % Assign the results
            obj.MaxCount = p.Results.MaxCount;
            obj.MinCount = p.Results.MinCount;
        end
        
    end
    
    methods(Access = protected)
       
        % Function verifies whether the patterns were found
        function result = matchesExpression(constraint, actual)
            % Get ResultVector
            [~, resultVector] = getResultVector(constraint, actual);
            
            % If all the patterns were present at least MinCount times and
            % at most MaxCount times, then return true
            result = all(resultVector);
        end
        
        function msg = generateFailingCondition(constraint, actual)
            [count, resultVector] = getResultVector(constraint, actual);
            
            msg = sprintf('Within %s \n', actual.getDiagnostic());
            for patternIterator =1:numel(constraint.Patterns)
                if resultVector(patternIterator) == 0
                    if ~isinf(constraint.MaxCount) || constraint.MinCount ~=1
                        msg = sprintf('%s\t%s:''%s'' was expected to be found ', msg, constraint.Interpretation.OutputString, constraint.Patterns{patternIterator});
                    end
                    if ~isinf(constraint.MaxCount)
                        msg = sprintf('%sa maximum of %d time', msg, constraint.MaxCount);
                        if constraint.MaxCount > 1
                            msg = sprintf('%ss', msg);
                        end
                    end
                    if constraint.MinCount ~= 1
                        if ~isinf(constraint.MaxCount)
                            msg = sprintf('%s and a minimum of %d time', msg, constraint.MinCount);
                        else
                            msg = sprintf('%sa minimum of %d time', msg, constraint.MinCount);
                        end
                        
                        if constraint.MinCount > 1
                            msg = sprintf('%ss', msg);
                        end
                    end
                    
                    % If count is 0 - it was not found
                    % If count is greater than 0 - say that
                    if count(patternIterator) == 0
                        if ~isinf(constraint.MaxCount) || constraint.MinCount ~=1
                            msg = sprintf('%s but was not found\n', msg);
                        else
                            msg = sprintf('%s\t%s:''%s'' was not found\n', msg, constraint.Interpretation.OutputString, constraint.Patterns{patternIterator});
                        end
                    else
                        msg = sprintf('%s but was found %d time', msg, count(patternIterator));
                        if count(patternIterator) > 1
                            msg = sprintf('%ss', msg);
                        end
                        msg = sprintf('%s\n', msg);
                    end
                end
            end
        end
    end

    methods(Access = private)
        
        function [numberOfTimesPatternsWereFound, resultVector] = getResultVector(constraint, actual)
            % Check if we can find all patterns
            numberOfTimesPatternsWereFound = cell2mat(cellfun(...
                @(x)numel(...
                constraint.Interpretation.FindMethod(actual.Content, x)), ...
                constraint.Patterns, 'UniformOutput', false));
            
            % Verify whether all the patterns exist a minimum of MinCount
            % times and a maximum of MaxCount times
            resultVector = numberOfTimesPatternsWereFound>=constraint.MinCount & ...
                           numberOfTimesPatternsWereFound<=constraint.MaxCount;
                       
        end
        
    end
end
