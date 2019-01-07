classdef BufferWithParent < cfetargettester.codeparser.Buffer
    % This class is a Buffer which has a Parent
    properties (SetAccess = private, GetAccess = protected)
        Parent
    end
    
    methods (Abstract, Hidden)
        diagString = getBufferWithParentDiagnostic(obj)
    end
    
    methods (Access = protected)
        function obj = BufferWithParent(theParent,theContent)
            parser = inputParser();
            parser.addRequired('Parent', @validateParent);
            parser.parse(theParent);
            obj = obj@cfetargettester.codeparser.Buffer(theParent.FileName,theContent);
            obj.Parent = parser.Results.Parent;
        end
    end
    
    methods (Hidden)
        function diagString = getDiagnostic(obj)
            diagString = [obj.getBufferWithParentDiagnostic obj.Parent.getDiagnostic];
        end
        function spareFile(obj)
            obj.Parent.spareFile;
        end
    end
    
end

function bool = validateParent(theParent)
validateattributes(theParent, ...
    {'cfetargettester.codeparser.Buffer'}, ...
    {'nonempty', 'scalar'}, ...
    '', ...
    'Parent');
bool = true;
end