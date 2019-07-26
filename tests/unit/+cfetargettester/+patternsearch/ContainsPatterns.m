classdef ContainsPatterns < cfetargettester.patternsearch.ContainsExpression 
    % ContainsPatterns - MATLAB Unit Test constraint to verify presence
    % of patterns in a cfetargettester.patternsearch.Buffer object
    %
    % ContainsPatterns is a MATLAB Unit constraint that verifies presence 
    % of patterns in a Buffer object. The Buffer objects are
    % usually created by the CCodeExtractor and are representations of the
    % analyzed C Code. 
    %
    % ContainsPatterns reads the 'Content' property of the Buffer object
    % and then uses 'regexp' to verify presence of patterns.
    %
    % ContainsPatterns Properties:
    %
    %   Patterns - A string or a cell array of strings specififying the
    %   patterns to be searched for.
    %
    %   MaxCount - A double specifiying the maximum number of times the
    %   pattern is expected to appear in the buffer. When Patterns is a
    %   cell array, each element of the cell array is expected to be
    %   present a maximum of MaxCount times.
    %
    %   MinCount - A double specifiying the minimum number of times the
    %   pattern is expected to appear in the buffer. When Patterns is a
    %   cell array, each element of the cell array is expected to be
    %   present a minimum of MinCount times.
    %
    % ContainsPatterns Methods:
    %
    %   ContainsPatterns - Class Constructor
    %
    % Param-Value:
    %       Parameter       Value
    %       ---------       ---------
    %       MaxCount        Of type double. Specifies the maximum number of
    %                       times the patterns are expected to appear in
    %                       the text of the buffer. Default Value is Inf.
    %       MinCount        Of type double. Specifies the minimum number of
    %                       times the patterns are expected to appear in
    %                       the text of the buffer. Default Valye is 1.
    %
    % Sample Usage:
    % -------------
    %
    % %1: %%% Verify presence of pattern %%%
    % 
    %   import cfetargettester.patternsearch.CCodeExtractor;
    %   import cfetargettester.patternsearch.ContainsPatterns;
    %
    %   % Instantiate the CCodeExtractor 
    %   codeExtractor = CCodeExtractor('directory_containing_C_code');
    % 
    %   % Extract file from the code
    %   fileObj = codeExtractor.extract(<fileName>);
    %
    %   % Verify presence of a pattern in it's executable code
    %   testCase = matlab.unittest.TestCase.forInteractiveUse;
    %   testCase.verifyThat(fileObj.ExecutableCode, ...
    %                       ContainsPatterns(<pattern>));
    % 
    % -------------------------------------------------------------------
    %
    % %2: %%% Verify presence of patterns %%%
    % 
    %   import cfetargettester.patternsearch.CCodeExtractor;
    %   import cfetargettester.patternsearch.ContainsPatterns;
    %
    %   % Instantiate the CCodeExtractor 
    %   codeExtractor = CCodeExtractor('directory_containing_C_code');
    % 
    %   % Extract file from the code
    %   fileObj = codeExtractor.extract(<fileName>);
    %
    %   % Verify presence of patterns in it's comments
    %   testCase = matlab.unittest.TestCase.forInteractiveUse;
    %   testCase.verifyThat(fileObj.Comments, ...
    %                       ContainsPatterns({<pattern1>, <pattern2>)});
    % 
    % -------------------------------------------------------------------
    %
    % %3: %%% Verify a pattern is present exactly 2 times %%%
    % 
    %   import cfetargettester.patternsearch.CCodeExtractor;
    %   import cfetargettester.patternsearch.ContainsPatterns;
    %
    %   % Instantiate the CCodeExtractor 
    %   codeExtractor = CCodeExtractor('directory_containing_C_code');
    % 
    %   % Extract file from the code
    %   fileObj = codeExtractor.extract(<fileName>);
    %
    %   % Verify a pattern is present a maximum of 5 times in the entire
    %   % text of the file
    %   testCase = matlab.unittest.TestCase.forInteractiveUse;
    %   testCase.verifyThat(fileObj, ContainsPatterns(<pattern>, ...
    %                                'MaxCount', 2, 'MinCount', 2));
    % 
    % -------------------------------------------------------------------
    %
    % %4: %%% Verify a pattern is present a maximum of 5 times %%%
    % 
    %   import cfetargettester.patternsearch.CCodeExtractor;
    %   import cfetargettester.patternsearch.ContainsPatterns;
    %
    %   % Instantiate the CCodeExtractor 
    %   codeExtractor = CCodeExtractor('directory_containing_C_code');
    % 
    %   % Extract file from the code
    %   fileObj = codeExtractor.extract(<fileName>);
    %
    %   % Verify a pattern is present a maximum of 5 times in the entire
    %   % text of the file
    %   testCase = matlab.unittest.TestCase.forInteractiveUse;
    %   testCase.verifyThat(fileObj, ContainsPatterns(<pattern>, ...
    %                                'MaxCount', 5));
    % 
    % -------------------------------------------------------------------
    %
    % %5: %%% Verify a pattern is present a maximum of 5 times and a minimum of 2 times%%%
    % 
    %   import cfetargettester.patternsearch.CCodeExtractor;
    %   import cfetargettester.patternsearch.ContainsPatterns;
    %
    %   % Instantiate the CCodeExtractor 
    %   codeExtractor = CCodeExtractor('directory_containing_C_code');
    % 
    %   % Extract file from the code
    %   fileObj = codeExtractor.extract(<fileName>);
    %
    %   % Verify a pattern is present a maximum of 5 times in the entire
    %   % text of the file
    %   testCase = matlab.unittest.TestCase.forInteractiveUse;
    %   testCase.verifyThat(fileObj, ContainsPatterns(<pattern>, ...
    %                                'MaxCount', 5, 'MinCount', 2));
    % 
    %   See also
    %       cfetargettester.patternsearch.ContainsOrderedPatterns
    %       cfetargettester.patternsearch.ContainsStrings
    %       cfetargettester.patternsearch.ContainsOrderedStrings 
    %       cfetargettester.patternsearch.DoesNotContainPatterns
    %       cfetargettester.patternsearch.DoesNotContainStrings
    %       cfetargettester.patternsearch.CCodeExtractor
           
    methods
        function obj = ContainsPatterns(patterns, varargin)
            import cfetargettester.patternsearch.RegularExpressionInterpretation;
            
            obj = obj@cfetargettester.patternsearch.ContainsExpression(patterns, RegularExpressionInterpretation(), varargin{:});
            if ~isempty(obj.Id) 
                % Throw an exception
                exception = MException(['CfeTargetTester:ContainsPatterns:' obj.Id], obj.Message);
                throw(exception);
            end
        end
    end
end
