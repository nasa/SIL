% CCodeParser  - Analyzes C code using a compiler front end and creates a
% data structure that helps us to differentiate between various sections in
% a C header or source file. For example, it creates a data structure that
% gives us access to the comments of the file, executable code of the file,
% 
% This class may be enhanced to utilize a C compiler front end to help 
% create the data structure if more detail is desired for the meta data.  
% For example, individual sections of executable code and comments for 
% functions in the body of the C file.
%
% Syntax: 
% % Create a Code Parser object
% obj = CCodeParser('foo.c')
%
% % Or Pass a custom configuration to the constructor
% obj = CCodeParser('foo.c', config)
%
% % Analyze the code
% obj.analyze
%
% % Access the results
% results = obj.Results

classdef CCodeParser < handle
    properties(SetAccess = private)
        File                % Name of the file
        Configuration       % TODO: Configuration for future C preprocessor frontend
        Results = [];       % CCodeParser Results
    end
    
    properties (Hidden)
        AnalyzedData = [];  % Data that holds the analyzed files
    end
    
    methods
        function obj = CCodeParser(varargin)
            
            % Default configuration
            % opt = internal.cxxfe.FrontEndOptions();
                        
            % Initiate an Input Parser object
           p = inputParser;
           p.addRequired('aFile', @(x)(ischar(x) && ~isempty(x)));
           % p.addOptional('aConfiguration', opt, @(x)(isa(x, 'internal.cxxfe.FrontEndOptions')));
           p.parse(varargin{:});
            
            % Pass in the results
           obj.File = p.Results.aFile;
           % obj.Configuration = p.Results.aConfiguration;            
            
        end
        
        function analyze(aObj)
            % Analyze the code
            aObj.locAnalyze();
            
            % Create File
            aFileObj = createFile(aObj);  
            
            % Create the Results object
            aObj.Results = cfetargettester.codeparser.CCodeParserResults(aFileObj);
        end
    end
    
    methods(Access = 'private')
        function locAnalyze(aObj)
            
            % Analyze the file with the given configuration
            logMessages = [];
            parsedMetaData = [];
            %
            % TODO: Here is where a C compiler front end could be invoked to 
            % get meta data about the C or header file
            %
            % thisConfiguration = aObj.Configuration;
            % [logMessages, parsedMetaData] = someFutureCallToCompilerFrontEnd(aObj.File, thisConfiguration, 3); 
            
            % Analyze the messages recieved from the compiler front end
            % For now, there will be no error messages since we are not
            % using a C front end
            if ~isempty(logMessages)
               logIndices = arrayfun(@(x)isErrorOrFatalErrorLog(x),logMessages,'UniformOutput',false);
               errorLogMessages = logMessages([logIndices{:}]);
               % If the error message is not empty, throw an exception
                if ~isempty(errorLogMessages)
                    baseME = aObj.createMExceptionfromLogMessage(errorLogMessages);
                    throw(baseME);
                end
            end
            
            % Otherwise, collect the analyzed data
            aObj.createCodeStructure(parsedMetaData);
            
            function bool = isErrorOrFatalErrorLog(aLog)
               bool = isequal(aLog.kind, 'error') || isequal(aLog.kind, 'fatal'); 
            end
        end
        
        function baseME = createMExceptionfromLogMessage(~,errorLogMessages)
            baseME = MException('CfeTargetTester:CCodeParser:AnalyzationErrorsOccurred', 'Error(s) occurred analyzing C-Code file(s)');
            tempME = arrayfun(@(x) MException('CfeTargetTester:CCodeParser:ErrorAnalyzingFile', ...
                'The following error "%s" occured at\n\tFile Name:\t%s\n\tLine Number:\t%d\n\tDetails:\t%s', ...
                x.desc,x.file,x.line,x.detail), errorLogMessages,'UniformOutput',false);
            for idx = 1:length(tempME)
                baseME = baseME.addCause(tempME{idx});
            end
        end
        
        
        function createCodeStructure(aCodeAnalyzer, parsedMetaData) %#ok<INUSD>
            % TODO: parsedMetaData unused at this time
            aCodeAnalyzer.AnalyzedData = struct(...
                'Name', aCodeAnalyzer.File,...
                'FileBody', icreate_file_body_desc() ...
                );
                        
%             fileRecord = [];
%             for iter = 1:parsedMetaData.getNumFiles
%                 Name = create_correct_filepath(parsedMetaData.getFileName(iter));
%                 if strfind(Name, aCodeAnalyzer.File)
%                     fileRecord = parsedMetaData.getFileRecord(iter);
%                     break;
%                 end
%             end
%             
%             if isempty(fileRecord)
%                 disp(['File ', aCodeAnalyzer.File,' is not found in the anaylzed structure'])
%                 return
%             end
            
            currentFileContent = fileread(aCodeAnalyzer.File);
            currentFileContent = regexprep(currentFileContent,'\r(?=\r)',sprintf('\r\n'));
            fileText = strsplit(currentFileContent, '\n', 'CollapseDelimiters', false);
            
            fileComments = []; % fileRecord.Comments;
            
            %Get all executable code in file
            fileCode = getExecutableCodeText(fileText,fileComments);
                                             
            aCodeAnalyzer.AnalyzedData.FileBody.Text = currentFileContent;
            aCodeAnalyzer.AnalyzedData.FileBody.Code = strjoin(fileCode','\n');
            if ~isempty(fileComments)
                aCodeAnalyzer.AnalyzedData.FileBody.Comments = strjoin({fileComments.Text},'\n');
            end
            aCodeAnalyzer.AnalyzedData.FileBody.CommentsInfo = fileComments;
        end
        
        function aFileObj = createFile(aObj)
            % This method gathers all the information from the AnalyzedData
            % object and created a CFile Object
            aCode = aObj.AnalyzedData.FileBody.Code;
            aComments = aObj.AnalyzedData.FileBody.Comments;
            commentsInfo = aObj.AnalyzedData.FileBody.CommentsInfo;
            aText = aObj.AnalyzedData.FileBody.Text;
            aFileObj  = cfetargettester.codeparser.CFile(aObj.File,aText,aCode,aComments);
            aFileObj.CommentsInfo = commentsInfo;            
        end       
    end
end

%--------------------------------------------------------------------------
function out = icreate_file_body_desc()

out = struct(...
    'Text','',...
    'Code', '',...
    'Comments', ''...
    );
%     'Functions', [] ...

end

function str = create_correct_filepath(filepath) %#ok<DEFNU>
    filePortions = strsplit(filepath, '/');
    str = strjoin(filePortions, filesep);
end

function fileCode = getExecutableCodeText(fileText,fileComments)

    fileCommentPositionArray = extractCommentPositionInfo(fileText,fileComments);

    %Remove all of the comments and replace with whitespace
    for idx3 = 1:size(fileCommentPositionArray,2)
        fileText{fileCommentPositionArray(1,idx3)}(fileCommentPositionArray(2,idx3):fileCommentPositionArray(3,idx3)) = ' ';
    end
    fileCode = fileText;
end

function fileCommentPositionArray = extractCommentPositionInfo(fileText,fileComments)
    fileCommentPositionArray = [];

    %Create a struct array of comment information
    for idx = 1:numel(fileComments)

        %Each comment may begin on one line and end on another.
        %This is captured in the first index (line number) from parsing the
        %code for both the StartPostion and EndPosition.  The goal of this loop
        %is to capture all lines which have comments with the starting and
        %ending position of each comment.  This is eventually populated in
        %fileCommentArray.

        %Take each fileComment struct and expand the information to cover all
        %lines that it is covering.  For instance, a fileComment struct which
        %has
        %   StartPosition: [1 1]
        %   EndPostion:    [3 3]
        %   Text:          '/*...'
        %
        %will be extracted into fileCommentArray as
        %   1               2               3      
        %   1               1               1      
        %   <lineLength>    <lineLength>    3
        % 
        %where <lineLength> is an actual value for the length of that
        %particular line which gets handled by populatePositionInfoForMultLineComments
        %  
        fileCommentPositionInfo = fileComments(idx).StartPosition(1):fileComments(idx).EndPosition(1);
        fileCommentPositionInfo = [fileCommentPositionInfo; ...
            zeros(size(fileCommentPositionInfo)); ...
            zeros(size(fileCommentPositionInfo))]; %#ok<AGROW>

        %The column StartPosition and EndPosition are captured in the
        %fileComment struct so populate this here
        fileCommentPositionInfo(2,1) = fileComments(idx).StartPosition(2);
        fileCommentPositionInfo(3,end) = fileComments(idx).EndPosition(2);

        fileCommentPositionInfo = populatePositionInfoForMultLineComments(fileCommentPositionInfo,fileText);
        fileCommentPositionArray = [fileCommentPositionArray,fileCommentPositionInfo]; %#ok<AGROW>
    end
end

function fileCommentPositionInfo = populatePositionInfoForMultLineComments(fileCommentPositionInfo,fileText)
%This is mainly for a multi-line comment.
%Need to capture the length of each line and 
%populate the Start and End Positions in the 
%fileCommentIndexInfo array that we are populating
    for idx2 = 1:length(fileCommentPositionInfo(1,:))
        lineNumber = fileCommentPositionInfo(1,idx2);
        
        lineSize = length(fileText{lineNumber});
        if (fileCommentPositionInfo(2,idx2) == 0)
            fileCommentPositionInfo(2,idx2) = 1;
        end
        if (fileCommentPositionInfo(3,idx2) == 0)
            fileCommentPositionInfo(3,idx2) = lineSize;
        end
        
    end
end
