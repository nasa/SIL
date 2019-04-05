classdef DoesNotContainPatterns < cfetargettester.patternsearch.ContainsNoExpression
    % DoesNotContainPatterns - MATLAB Unit Test constraint to verify absence of
    % patterns in a cfetargettester.patternsearch.Buffer object
    % DoesNotContainPatterns Properties:
    %
    %   Patterns - A string or a cell array of strings specififying the
    %   patterns to be searched for.
    %
    % Sample Usage:
    % -------------
    %
    %   %%% Verify absence of pattern %%%
    % 
    %   import cfetargettester.patternsearch.CCodeExtractor;
    %   import cfetargettester.patternsearch.DoesNotContainPatterns;
    %
    %   % Instantiate the CCodeExtractor 
    %   codeExtractor = CCodeExtractor('directory_containing_C_code');
    % 
    %   % Extract file from the code
    %   fileObj = codeExtractor.extract(<fileName>);
    %
    %   % Verify absence of a pattern in it's executable code
    %   testCase = matlab.unittest.TestCase.forInteractiveUse;
    %   testCase.verifyThat(fileObj.ExecutableCode, ...
    %                       DoesNotContainPatterns(<pattern>));
    % 
    %   % Verify absence of multiple patterns
    %   testCase.verifyThat(fileObj.ExecutableCode, ...
    %                       DoesNotContainPatterns({<pattern1>, <pattern2>}));
    %   See also
    %       cfetargettester.patternsearch.ContainsPatterns
    %       cfetargettester.patternsearch.ContainsOrderedPatterns
    %       cfetargettester.patternsearch.ContainsStrings
    %       cfetargettester.patternsearch.ContainsOrderedStrings
    %       cfetargettester.patternsearch.DoesNotContainStrings
    %       cfetargettester.patternsearch.CCodeExtractor
          
    methods
        function obj = DoesNotContainPatterns(patterns)
            obj = obj@cfetargettester.patternsearch.ContainsNoExpression(patterns, ...
                cfetargettester.patternsearch.RegularExpressionInterpretation());
        end
    end
end