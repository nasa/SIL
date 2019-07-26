% RegularExpressionInterpretation - This class is used to specify that a string passed
% to a constraint must be interpreted as a regular expression
classdef(Sealed = true) RegularExpressionInterpretation < cfetargettester.patternsearch.Interpretation
    properties(SetAccess = protected)
        FindMethod;
        OutputString;
    end
    methods
        function obj = RegularExpressionInterpretation()
            obj.FindMethod = @regexp;
            obj.OutputString = 'pattern';
        end
        
        function [startIdx, endIdx] = getPosition(~, content, pattern)
            [startIdx, endIdx] = regexp(content, pattern);
        end
    end
end