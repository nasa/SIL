% CExecutableCode is a class used to describe the Non-Comments part of C
% Code. It is a concrete implementation of the Buffer class.
%
classdef (Sealed = true) CExecutableCode < cfetargettester.codeparser.BufferWithParent

    methods (Access = ?cfetargettester.codeparser.CCode)
        function obj = CExecutableCode(theParent,theContent)
            obj = obj@cfetargettester.codeparser.BufferWithParent(theParent,theContent);
        end
    end
    methods (Hidden)
        function diag = getBufferWithParentDiagnostic(~)
            diag = 'Executable Code in ';
        end
    end
end