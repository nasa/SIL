classdef Contains < cfetargettester.constraints.CombinableConstraint
    % Contains - Abstract class that is a super class to the
    % ContainsWithCount and ContainsOrderedPatterns Constraint

    properties(SetAccess = private)
        Patterns;   % Regular expressions to be searched in the Buffer objects
    end
    
    properties(SetAccess = private, Hidden)
        Interpretation;     % This tells us how we want to interpret the string passed into the constraint
    end
    
    properties(Hidden)
        SparedLocation;     % Where the files are spared
    end
    
    methods (Access = protected)
        function obj = Contains(varargin)
            import cfetargettester.patternsearch.RegularExpressionInterpretation;
            p = inputParser();
            p.addRequired('Patterns', @obj.validatePatterns);
            p.addOptional('Interpretation', RegularExpressionInterpretation(), ...
                @(x) (isa(x, 'cfetargettester.patternsearch.Interpretation')));
            p.parse(varargin{:});
            
            % Convert a single string into a cell array
            if ischar(p.Results.Patterns)
                obj.Patterns = {p.Results.Patterns};
            else            
                obj.Patterns = p.Results.Patterns;
            end
            
            % Default Find method is regexp
            obj.Interpretation = p.Results.Interpretation;
        end
    end
    
    methods        
        
        function result = satisfiedBy(constraint, actual)
            result = ...
                (metaclass(actual) <= ?cfetargettester.codeparser.Buffer) ...
                && isscalar(actual) ...
                && matchesExpression(constraint, actual);
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            import matlab.unittest.diagnostics.StringDiagnostic
            
            % Validate that the passed object is a Buffer object
            if ~(metaclass(actual) <= ?cfetargettester.patternsearch.Buffer)
                diag = StringDiagnostic('Object is not of type Buffer');
                diag.join('Actual value must be an instance of cfetargettester.patternsearch.Buffer');
                return;
            end            
            
            % Validate that the object passed is a scalar
            if ~isscalar(actual)
                diag = StringDiagnostic('Scalar object found. Actual value must be a scalar');               
                return;
            end
            
             % Do the custom validation for the constraint
            if ~matchesExpression(constraint, actual)
                str = generateFailingCondition(constraint, actual);
                diag = StringDiagnostic.join(str); 
            end            
        end
        
    end
    
    methods(Access = protected, Abstract)
        result = matchesExpression(constraint, actual);
        msg = generateFailingCondition(constraint, actual);
    end
        
    methods(Access = protected)
        
        function validatePatterns(~, patterns)
            % Get the id and message for the exception if the pattern is
            % not valid
            [id, message] = cfetargettester.patternsearch.Contains.patternValidationResult(patterns);
            
            if isempty(id) && isempty(message)
                % Pattern is valid
                return
            else
                exception = MException(['Contains:' id], message);
                throw(exception);
            end
        end
        
        function lineNumbers = getLineNumbers(constraint, actual)
            % Extract line length information
            % Read the contents of the file
            try
                fileContent = fileread(actual.FileName);
            catch e
                exception = MException([class(constraint) ':FileReadFailure'], ['Failed to read file' actual.FileName]);
                exception = addCause(e, exception);
                throw(exception);
            end
            
            count = zeros(size(constraint.Patterns));
            for patternIterator = 1:numel(constraint.Patterns)
                % Check if the pattern exist
                %patternPositions = regexp(actual.Content, constraint.Patterns{patternIterator});
                patternPositions = constraint.Interpretation.FindMethod(actual.Content, constraint.Patterns{patternIterator});
                
                % The length of startIdx determines how many times the
                % pattern was found
                count(patternIterator) = numel(patternPositions);
                
                % Data structure to collect all line numbers
                lineNumbers{patternIterator} = []; %#ok<AGROW>
                
                if count(patternIterator)
                    % Find the position of the pattern in the file
                    startPos = constraint.Interpretation.FindMethod(fileContent, constraint.Patterns{patternIterator});
                    for positionIterator = 1:numel(startPos)
                        % Find the new lines before this occurence
                        newLines = regexp(fileContent(1:startPos(positionIterator)), '\n');
                        lineNumbers{patternIterator}(positionIterator) = numel(newLines) + 1;
                    end
                end
            end
            
        end
    end
    
    methods(Static, Access = {?cfetargettester.patternsearch.ContainsExpression})
        function [id, message] = patternValidationResult(patterns)
            % If patterns are the right type
            id = '';
            message = '';
            % Verify if the pattern is a string or a cell array
            if ischar(patterns) || iscell(patterns)     
                if isempty(patterns)
                    id = 'EmptyString';
                    message = 'Constraint does not accept empty strings.';
                end
                
                % If it's a cell, ensure that all the contents of the cell array
                % are strings
                if iscell(patterns)
                    for i=1:numel(patterns)
                        if ~ischar(patterns{i})
                            id = 'IncorrectCell';
                            message = 'Constraint was passed a cell array that contains non strings.';
                        end
                    end
                end
            else
                % If neither is the case
                id = 'InvalidArgument';
                message = 'Constraint was passed neither a string nor a cell array of strings.';
            end
        end
    end
end
