classdef ContainsOrderedStrings < cfetargettester.patternsearch.ContainsOrderedExpression
    % ContainsOrderedStrings - MATLAB Unit Test constraint that verifies that
    % strings passed to the constraint are present in the specified order
    %
    % ContainsOrderedStrings is a convenience constraint that verifies
    % that the strings that are passed to the constraint are present in
    % the same order as specified. This constraint also operates on the
    % cfetargettester.patternsearch.Buffer object. 
    %
    % ContainsOrderedStrings Properties:
    %
    %   Patterns - A cell array of strings containing the strings to be
    %   searched for in order
    %
    % ContainsOrderedStrings Methods:
    %
    %   ContainsOrderedStrings - Class Constructor
    %
    % Sample Usage
    % ------------
    %
    %   % The CCodeExtractor imported depends on the product used to 
    %   % generate code. In the example below, code was generated using
    %   % Embedded Coder. If code is generated using MATLAB Coder, then 
    %   % import cfetargettester.patternsearch.CCodeExtractor instead.    
    %
    %   import cfetargettester.patternsearch.CCodeExtractor;
    %   import cfetargettester.patternsearch.ContainsOrderedStrings;
    %
    %   Instantiate the CCodeExtractor 
    %   codeExtractor = CCodeExtractor('directory_containing_C_code');
    % 
    %   % Extract file from the code
    %   fileObj = codeExtractor.extract(<fileName>);
    %
    %   % Verify presence of a patterns in order in it's executable code
    %   testCase = matlab.unittest.TestCase.forInteractiveUse;
    %   testCase.verifyThat(fileObj.ExecutableCode, ...
    %              ContainsOrderedStrings({'str1', 'str2'}));
    %   See also
    %       cfetargettester.patternsearch.ContainsPatterns
    %       cfetargettester.patternsearch.ContainsStrings
    %       cfetargettester.patternsearch.ContainsOrderedPatterns
    %       cfetargettester.patternsearch.DoesNotContainPatterns
    %       cfetargettester.patternsearch.DoesNotContainStrings
    %       cfetargettester.patternsearch.CCodeExtractor
           
    methods
        function obj = ContainsOrderedStrings(patterns)
            obj = obj@cfetargettester.patternsearch.ContainsOrderedExpression(patterns, ...
                cfetargettester.patternsearch.StringInterpretation());
        end
    end
end