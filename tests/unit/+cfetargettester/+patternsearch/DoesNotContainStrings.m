classdef DoesNotContainStrings < cfetargettester.patternsearch.ContainsNoExpression
    % DoesNotContainStrings - MATLAB Unit Test constraint to verify absence of
    % strings in a cfetargettester.patternsearch.Buffer object
    % DoesNotContainStrings Properties:
    %
    %   Patterns - A string or a cell array of strings specififying the
    %   patterns to be searched for.
    %
    % Sample Usage:
    % -------------
    %
    %   %%% Verify absence of string %%%
    % 
    %   import cfetargettester.patternsearch.CCodeExtractor;
    %   import cfetargettester.patternsearch.DoesNotContainStrings;
    %
    %   % Instantiate the CCodeExtractor 
    %   codeExtractor = CCodeExtractor('directory_containing_C_code');
    % 
    %   % Extract file from the code
    %   fileObj = codeExtractor.extract(<fileName>);
    %
    %   % Verify absence of a string in it's executable code
    %   testCase = matlab.unittest.TestCase.forInteractiveUse;
    %   testCase.verifyThat(fileObj.ExecutableCode, ...
    %                       DoesNotContainStrings(<string>));
    % 
    %   % Verify absence of multiple strings
    %   testCase.verifyThat(fileObj.ExecutableCode, ...
    %                       DoesNotContainStrings({<string1>, <string2>}));
    %   See also
    %       cfetargettester.patternsearch.ContainsPatterns
    %       cfetargettester.patternsearch.ContainsOrderedPatterns
    %       cfetargettester.patternsearch.ContainsStrings
    %       cfetargettester.patternsearch.ContainsOrderedStrings 
    %       cfetargettester.patternsearch.DoesNotContainPatterns
    %       cfetargettester.patternsearch.CCodeExtractor
           
    methods
        function obj = DoesNotContainStrings(patterns)
            obj = obj@cfetargettester.patternsearch.ContainsNoExpression(patterns, ...
                cfetargettester.patternsearch.StringInterpretation());
        end
    end
end