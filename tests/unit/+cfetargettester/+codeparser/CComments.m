% CComments - this class encapsulated the comments within a C source or
% header file. The class extends the Buffer class and hence inherits the
% following public properties:
%       Content
classdef (Sealed = true) CComments < cfetargettester.codeparser.BufferWithParent
    
    methods (Access = ?cfetargettester.codeparser.CCode)
        function obj = CComments(theParent,theContent)
            obj = obj@cfetargettester.codeparser.BufferWithParent(theParent,theContent);
        end
        
    end
    methods (Hidden)
        function diag = getBufferWithParentDiagnostic(~)
            diag = 'Comments in ';
        end
    end
end