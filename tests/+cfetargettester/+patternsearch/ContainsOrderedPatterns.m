classdef ContainsOrderedPatterns < cfetargettester.patternsearch.ContainsOrderedExpression
    % ContainsOrderedPatterns - MATLAB Unit Test constraint that verifies that
    % patterns passed to the constraint are present in the specified order
    %
    % ContainsOrderedPatterns is a convenience constraint that verifies
    % that the patterns that are passed to the constraint are present in
    % the same order as specified. This constraint operates on the any
    % class derived from the cfetargettester.patternsearch.Buffer object. 
    %
    % ContainsOrderedPatterns Properties:
    %
    %   Patterns - A cell array of strings containing the patterns to be
    %   searched for in order
    %
    % ContainsOrderedPatterns Methods:
    %
    %   ContainsOrderedPatterns - Class Constructor
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
    %   import cfetargettester.patternsearch.ContainsOrderedPatterns;
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
    %              ContainsOrderedPatterns({'pattern1', 'pattern2'}));
    %   See also
    %       cfetargettester.patternsearch.ContainsPatterns
    %       cfetargettester.patternsearch.ContainsStrings
    %       cfetargettester.patternsearch.ContainsOrderedStrings
    %       cfetargettester.patternsearch.DoesNotContainPatterns
    %       cfetargettester.patternsearch.DoesNotContainStrings
    %       cfetargettester.patternsearch.CCodeExtractor
                 
    methods
        function obj = ContainsOrderedPatterns(patterns)
            obj = obj@cfetargettester.patternsearch.ContainsOrderedExpression(patterns, ...
                cfetargettester.patternsearch.RegularExpressionInterpretation());
        end
    end
end