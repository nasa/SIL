% StringInterpretation - This class is used to specify that a string passed
% to a constraint must be interpreted as a string and not as a regular
% expression
classdef(Sealed = true) StringInterpretation < cfetargettester.patternsearch.Interpretation
    properties(SetAccess = protected)
        FindMethod;
        OutputString;
    end
    methods
        function obj = StringInterpretation()
            obj.FindMethod = @strfind;
            obj.OutputString = 'string';
        end
        
        function [startIdx, endIdx] = getPosition(obj, content, pattern)
            startIdx = obj.FindMethod(content, pattern);
            endIdx = startIdx + numel(pattern) - 1;
        end
    end
end