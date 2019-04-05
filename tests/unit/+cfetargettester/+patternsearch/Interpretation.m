% Interpretation - This class decides how the string passed to the
% constraint is interpreted as. For now there are two interpretations.
% 'String' and 'Regular Expression'
% This class can be extended with new interpretations.
classdef Interpretation < handle
    properties(SetAccess = protected, Abstract)
        FindMethod;     % This is set to the method used to find the expression
        OutputString;   % This is the string used in diagnostics
    end
    methods(Abstract)
        getPosition(interpretation, content, pattern);
    end
end