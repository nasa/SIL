% CFile - This class represents a C source or header file
%
% CFile Properties:
%   Content - The entire text of the file.
%
%   FileName - The name of the file.
%
%   Comments - Comments contained within the C code (Anything within /* and
%   */. Note: CCode doesn't include C++ style comments
%
%   ExecutableCode - Executable Code within a file.
%
% CFile Methods:
%   extractDemarcated() - extract code demarcated by unique identifiers.
%
%   extractFunction() - extract code for a function within the file.
%
classdef (SupportExtensionMethods=true) CFile < cfetargettester.codeparser.CCode & ...
        cfetargettester.codeparser.Buffer
    properties (SetAccess = ?cfetargettester.codeparser.CCodeParser)
        FunctionList;   % List of functions - containers.Map
    end
    
    properties(Hidden)
        CommentsInfo;       % Struct Array for line number information
    end
    
    properties (Access = protected)
        CommentedCodeContent
        ExecutableCodeContent
    end
    
    methods (Access = ?cfetargettester.codeparser.CCodeParser)
        
        function obj = CFile(fileName, content, executableCode, comments)
            % Ensure that Functions belong to the same file
            
            obj = obj@cfetargettester.codeparser.Buffer(fileName,content);
            
            obj.CommentedCodeContent = comments;
            obj.ExecutableCodeContent = executableCode;
        end
    end
    
    methods
        function obj = set.FunctionList(obj, functionList)
            
            p = inputParser;
            p.addRequired('Functions', @(x) (isa(x, 'cfetargettester.codeparser.CFunction') || isempty(x)));
            p.parse(functionList);
            
            
            % Check if the file has any functions
            if ~isempty(p.Results.Functions)
                fcnNames = {p.Results.Functions.Name};
                fcnCell = mat2cell(p.Results.Functions, 1, ones(1, size(p.Results.Functions, 2)));
                
                % Create a Map
                obj.FunctionList = containers.Map(fcnNames, fcnCell);
            else
                obj.FunctionList = [];
            end
        end
        function fcnObj = extractFunction(obj, fcnName)
            % extractFunction: This function returns a function within a
            % file as a CFunction object
            %
            % Input Arguments:
            %   This function takes a string as an input which is the name
            %   of the function you want to perform pattern search on. Just
            %   pass the function name and not the function proptotype.
            %
            % Output:
            %   The output of this method is a
            %   cfetargettester.codeparser.CFunction object which can be then
            %   used with ContainsPatterns constraint to perform pattern
            %   search.
            %
            % Example
            %   funcObj = fileObj.extractFunction('functionName');
            %   testcase.verifyThat(funcObj, ContainsPatterns('pattern'));
            %   testcase.verifyThat(funcObj.ExecutableCode,
            %                       ContainsPatterns('pattern'));
            %   testcase.verifyThat(funcObj.Comments,
            %                       ContainsPatterns('pattern'));
            try
                fcnObj = obj.FunctionList(fcnName);
            catch e
                exception = MException('CfeTargetTester:CFile:FunctionNotExist', ...
                    'Function: %s does not exist in File: %s', ...
                    fcnName, obj.FileName);
                throw(exception);
            end
            
            
        end
        
        function fcnList = extractAllFunctions(obj)
            % extractAllFunctions: Returns all the functions within a file
            % as an array of CFunction objects
            %
            % Input Arguments: None
            %
            % Output: An array of CFunction objects
            fcnList = [];
            if ~numel(obj.FunctionList)
                return;
            else
                values = obj.FunctionList.values;
                for i = 1:numel(values)
                    fcnList = [fcnList values{i}]; %#ok<AGROW>
                end
            end
        end
        
        function diag = getDiagnostic(obj)
            % getDiagnostic: Returns helpful diagnostic information in case
            % of failure
            diag = ['File: ''' obj.FileName ''''];
        end
        
        
    end
end
