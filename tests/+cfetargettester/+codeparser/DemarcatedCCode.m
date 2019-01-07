% DemarcatedCCode - This class represents code demarcated by comment markers
% 
% Example:
%   /* sectionStart */
%   int x = x++;
%   y = process(x); /* Process x */
%   /* sectionEnd */
% 
% In the example below, the code is demarcated by comments containing
% sectionStart and sectionEnd. 
%
% DemarcatedCCode Properties:
%   Content - The entire text of the code demarcated by the comment
%   markers. This text does not include the comments containing the section
%   markers.
%
%   FileName - The name of the file which contains the demarcated code.
% 
% One can use the ContainsPatterns or the ContainsOrderedPatterns
% constraints in the following manner.
%   testcase.verifyThat(demarcatedObj, ContainsPatterns('pattern'));
%
% Note: DemarcatedCCode represents only the text and not the executable
% code and comments present in the demarcated section.
%
classdef DemarcatedCCode < cfetargettester.codeparser.BufferWithParent
    properties (SetAccess = private)
        SectionStart;
        SectionEnd;
    end
    methods (Access = ?cfetargettester.codeparser.CCode)
        function obj = DemarcatedCCode(parent, content, sectionStart, sectionEnd)
            % Set the properties of the super class
            obj = obj@cfetargettester.codeparser.BufferWithParent(parent, content);
            
            p = inputParser;
            p.addRequired('SectionStart', @(x) (~isempty(x) && ischar(x)));
            p.addRequired('SectionEnd', @(x) (~isempty(x) && ischar(x)));
            p.parse(sectionStart, sectionEnd);
            
            % Set the properties of this class
            obj.SectionStart = p.Results.SectionStart;
            obj.SectionEnd = p.Results.SectionEnd;
            
        end            
    end
    methods (Hidden)
        function diag = getBufferWithParentDiagnostic(obj)
            diag = ['Code Demarcated by SectionStart: '...
                obj.SectionStart ' SectionEnd: ' obj.SectionEnd ' from '];
        end
    end
end