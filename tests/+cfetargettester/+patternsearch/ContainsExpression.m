classdef (Abstract) ContainsExpression < cfetargettester.constraints.CombinableConstraint
   
    properties (SetAccess = private, Hidden)
        InnerConstraint;    % Inner Constraint to which the work of pattern search is delegated
        Id;                 % Id of the error in case string passed to the constraint is incorrect
        Message;            % Message to be displayed in the error message
        SparedLocation;     % For testability
    end
    
    properties(SetAccess = private)
        Patterns;           % Patterns to be searched for
        MaxCount;           % Maximum number of times the pattern is to be found
        MinCount;           % Minimum number of times the pattern is to be found
    end
    
    methods
        function obj = ContainsExpression(patterns, interpretation, varargin)
            % Verify if the patterns are valid
            [obj.Id, obj.Message] = cfetargettester.patternsearch.Contains.patternValidationResult(patterns);
            
            % If the error message and id are empty, then we are good :)
            if isempty(obj.Id) && isempty(obj.Message)
                obj.InnerConstraint = cfetargettester.patternsearch.ContainsWithCount(patterns, interpretation, varargin{:});
                obj.Patterns = obj.InnerConstraint.Patterns;
                obj.MaxCount = obj.InnerConstraint.MaxCount;
                obj.MinCount = obj.InnerConstraint.MinCount;
            end
        end
        
        function result = satisfiedBy(constraint, actual)
            result = constraint.InnerConstraint.satisfiedBy(actual);
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            import matlab.unittest.diagnostics.StringDiagnostic
            innerDiag = constraint.InnerConstraint.getDiagnosticFor(actual);
            innerDiag.diagnose();
            innerDiagMessage = '';   
            % Create the full message
            innerDiagMessage = sprintf('%s\n%s', innerDiag.DiagnosticResult, innerDiagMessage);            
             % Do the custom validation for the constraint
            if ~constraint.satisfiedBy(actual)
                diag = StringDiagnostic.join(innerDiagMessage); 
            end            
            
        end
    end
end
