% CCode - This class describes C Code as a collection of executable code and
% comments
%
% CCode Properties:
%   Comments - Comments contained within the C code (Anything within /* and
%   */. Note: CCode doesn't include C++ style comments
%
%   ExecutableCode - Executable Code within a file. 
%
% CCode Methods:
%   extractDemarcated() - This method takes as arguments strings that
%   demarcate code and returns a cfetargettester.codeparser.DemarcatedCCode
%   object. Read the method help for more details.
%
classdef (Abstract) CCode < handle
    
    properties (Abstract, Access = protected)
       CommentedCodeContent;
       ExecutableCodeContent;
    end

    properties(Dependent, SetAccess = protected)
        Comments;       % C style comments in a source or header file
        ExecutableCode; % executable code in a source or header file
    end
    
    methods
       
        function commentedCode = get.Comments(obj)
           commentedCode = cfetargettester.codeparser.CComments(obj, obj.CommentedCodeContent);
        end
        function exectuableCode = get.ExecutableCode(obj)
            exectuableCode = cfetargettester.codeparser.CExecutableCode(obj, obj.ExecutableCodeContent);
        end
    end
    
    methods(Sealed = true)
        function demarcatedObj = extractDemarcated(obj, sectionStart, sectionEnd)
            % extractDemarcated: Method to extract portion of code
            % demarcated by markers.
            % 
            % Input Arguments: 
            %   sectionStart: A string that specifies the start of the
            %   section of demarcated code
            %   sectionEnd : A string that specifies the end of the section
            %   of demarcated code
            % 
            % Example:
            %   /* sectionStart */
            %   int x = x++;
            %   y = process(x); /* Process x */
            %   /* sectionEnd */
            %
            % Explanation:
            %   Here, <sectionStart> must be a unique string that is
            %   contained within a C style comment. The comment should be
            %   of the form /* followed by any number of spaces followed by
            %   the <sectionStart> followed by any number of spaces
            %   followed by */. In the example above, extractDemarcated
            %   returns the cfetargettester.codeparser.DemarcatedCObject that
            %   contains 'int x = x++;\ny = process(x); /* Process x */' as
            %   it's content. One can then use the ContainsPatterns
            %   constraint for pattern search analysis.
            
            if isempty(sectionStart) || isempty(sectionEnd)
                throw(MException('CfeTargetTester:CCode:extractDemarcated:EmptySectionIdentifier', ...
                    'Section Markers cannot be empty'));
            end
            
            % Main algorithm begins here
            % Create a copy of the Content
            Content = obj.Content;
            
            % Find the first occurence of the section starter
            sectionStartIdx2 = []; %#ok<NASGU>
            expr = ['/\*[^\*]*' sectionStart '[^\*]*\*/'];
            [~, sectionStartIdx2] = regexp(Content, expr);
            
            % Throw the exception if you can't find the id
            if isempty(sectionStartIdx2)
                exception = MException('CfeTargetTester:CCode:SectionIdentifierNotFound', ...
                    ['Could not find section identifier: ' sectionStart]);
                throw(exception);
            end
            
            % Remove the part of the Content until the end of
            % sectionStartIdx(1) - the first time we found a marker. This
            % is to ensure that even if the sectionStart and sectionEnd are
            % the same string, the algorithm would behave correctly.
            
            Content(1:sectionStartIdx2(1)) = [];
            
            % Find the first occurence of the section end
            sectionEndIdx1 = []; %#ok<NASGU>
            expr = ['/\*[^\*]*' sectionEnd '[^\*]*\*/'];
            [sectionEndIdx1, ~] = regexp(Content, expr);
               
            % Throw the exception if you can't find the id
            if isempty(sectionEndIdx1)
                exception = MException('CfeTargetTester:CCode:SectionIdentifierNotFound', ...
                    ['Could not find section identifier: ' sectionEnd]);
                throw(exception);
            end
            
            % Remove the content from the end of sectionEndIdx1(1) to the
            % end of the buffer
            Content(sectionEndIdx1(1):end) = [];            
            demarcatedObj = cfetargettester.codeparser.DemarcatedCCode(obj, Content, sectionStart, sectionEnd);    
        end
    end
end
