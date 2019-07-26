% CCodeFileExtractor - This class can be used to extract scopes from C code
% generated with Simulink or MATLABCoder. These scopes can be further used to
% perform pattern search using the constraints in the
% cfetargettester.codeparser package.
%
% CCodeFileExtractor properties:
%   BuildDirectory - Path to the directory where 'buildInfo.mat' gets
%                   generated
%
% CCodeFileExtractor Methods:
%
%   extract() - Analyzes and extracts code constructs from a C source or
%              header file. Specify the file path relative to the
%              'BuildDirectory'.
%
% Description: The CCodeFileExtractor class helps in analyzing C code and
% extracing information about C source and header files. The extract
% method analyzes the files and breaks them into various code constructs
% like Executable Code, Comments and Functions.
%
% The input to CCodeFileExtractor should be the path to the directory where
% 'buildInfo.mat' gets created after code generation.
% One can then use the 'extract' function to extract files.
% The files should be relative to the CCodeFileExtractor's 'BuildDirectory'.
% The 'extract' function returns a cfetargettester.codeparser.CFile
% object.
%
% Note: The CCodeFileExtractor currently only supports file with the .c and the
% .h extention.
%
% Example: PARSE A SINGLE FILE
%
%
%   import cfetargettester.codeparser.CCodeFileExtractor;
%   import cfetargettester.codeparser.ContainsPatterns;
%
%   % Instantiate CCodeFileExtractor
%   codeExtractor = CCodeFileExtractor(<buildDirectory>);
%
%   % Extract a single C file with the .c extension
%   aFile = codeExtractor.extract('fileName.c');
%
%   % Verify existence of pattern in the executable code
%   testCase.verifyThat(aFile.ExecutableCode, ...
%                       ContainsPatterns('pattern'));
%
%   % Verify existence of pattern in the comments
%   testCase.verifyThat(aFile.Comments, ...
%                       ContainsPatterns('pattern'));
%
%   % Verify existence of pattern in the entire file
%   testCase.verifyThat(aFile, ContainsPatterns('pattern'));
%
%  Example: PARSE FILES USING A WILDCARD
%
%   import cfetargettester.codeparser.CCodeFileExtractor;
%   import cfetargettester.codeparser.ContainsPatterns;
%   import matlab.unittest.constraints.EveryElementOf;
%
%   % Instantiate CCodeFileExtractor
%   codeExtractor = CCodeFileExtractor(<buildDirectory>);
%
%   % Extract a list of files using a wildcard
%   fileList = codeExtractor.extract('m*.c');
%
%   % Verify existence of pattern in all the files
%   testcase.verifyThat(EveryElementOf(fileList), ...
%                       ContainsPatterns('pattern'));
%
%   See also
%       cfetargettester.codeparser.ContainsPatterns
%       cfetargettester.codeparser.ContainsOrderedPatterns
%       cfetargettester.codeparser.ContainsStrings
%       cfetargettester.codeparser.ContainsOrderedStrings
%


classdef(Sealed = true) CCodeFileExtractor < handle
 
    properties(SetAccess = private)
        BuildDirectory; % Directory that contains the C code (source and headers)
    end
    
    properties(Hidden)
        Configuration;  %TODO: for use of C front end 
    end
       
    methods (Sealed, Access = public)
       
        function cFileList = extract(obj, filesToExtract)
            fullFileNames = getFullFileNames(obj,filesToExtract);

            % Initialize the file list
            cFileList = [];
            
            % Iterate over the files and analyze them
            for i=1:numel(fullFileNames)
                % Instantiate a code anlyzer
                % remove option conifg from arg list below:   , obj.Configuration
                codeAnalyzer = cfetargettester.codeparser.CCodeParser(fullFileNames{i}); %TODO: remove obj.Configuration
                codeAnalyzer.analyze; % for now will just return the file contents
                cFileList = [cFileList codeAnalyzer.Results.AnalyzedFiles]; %#ok<AGROW>
            end
        end
        
    end
    
    methods (Static, Sealed)
    
        % Constructor
        function obj = CCodeFileExtractor(aBuildDirectory)
            aBuildDirectory = getPlatformSpecificName(aBuildDirectory);
            % Use the mex's system header files
            % obj.Configuration = internal.cxxfe.util.getMexFrontEndOptions('lang','C');
            obj.Configuration = [];
            % obj.updateFrontEndOptions
            
%             p = inputParser();
%             p.addRequired('BuildDirectory',@cfetargettester.checkBuildDirectory);
%             p.parse(aBuildDirectory);
                              
            %obj.BuildDirectory = p.Results.BuildDirectory;   
            obj.BuildDirectory = aBuildDirectory;   
            
        end
    
    end
    
    methods(Access = private)
               
        function verifyFileNameHasCorrectExtention(~, fileName)
            % Try to split the file
            splitFileName = strsplit(fileName, '.');
            
            % If there is no . and extension combo - that's an error
            if strcmp(splitFileName, fileName)
                exception = MException('CfeTargetTester:CCodeFileExtractor:InvalidFileName', ...
                    'File must have an extension');
                throw(exception);
            end
            
            % The second part of the file should be an h or a c
            if ~strcmp(splitFileName{end}, 'c') && ~strcmp(splitFileName{end}, 'h')
                exception = MException('CfeTargetTester:CCodeFileExtractor:InvalidFileExtension', ...
                    'Invalid file extension: you must pass a .h or .c file');
                throw(exception);
            end
        end

        function bool = areFilesRelativeToBuildDir(obj,filesToExtract)
            
            bool = false;
            
            filesDir = fileparts(filesToExtract);
            
            if isequal(exist(fullfile(obj.BuildDirectory,filesDir),'dir'),7)
                bool = true;
            end
            
        end
        
        function fullFileNames = getFullFileNames(obj,filesToExtract)
            % Convert the fileName to platform specific fileName
            filesToExtract = getPlatformSpecificName(filesToExtract);
            
            verifyFileNameHasCorrectExtention(obj, filesToExtract);
            

            if obj.areFilesRelativeToBuildDir(filesToExtract)
                filesToExtract = [obj.BuildDirectory filesep filesToExtract];
            end
            
            filePath = fileparts(filesToExtract);
            
            % Get the list of files
            fileList = dir(filesToExtract);
            
            % Ensure that this file exists
            if isempty(fileList)
                
                % Get the file name without the path
                fileNameWithoutPath = strsplit(filesToExtract, filesep);
                
                exception = MException('CfeTargetTester:CCodeFileExtractor:FileNotFound', ...
                    ['The file: ' fileNameWithoutPath{end} ' was not found']);
                throw(exception);
            end
            
             % Create the full path 
            fullFileNames = arrayfun(@(x) strcat(filePath,filesep,x.name),fileList,'UniformOutput',false);
            
        end
    end
end

function fileName = getPlatformSpecificName(Name)
    switch Name
        % The current directory
        case '.'
            fileName = '.';
        % The upper folder
        case '..'
            fileName = '..';
        case {'.\' './'}
            fileName = ['.' filesep];
        case {'..\' '../'}
            fileName = ['..' filesep];
        otherwise
            % Check if there are any file separators present
            if ~contains(Name, '\') && ~contains(Name, '/')
                fileName = Name;
                return
            end

            if contains(Name, '\')
                fileSeparator = '\';
            else
                fileSeparator = '/';
            end
            
            % collapseDelimeters-false will ensure that UNC path doesn't
            % fail
            fileParts = strsplit(Name, fileSeparator, 'CollapseDelimiters', false);
            fileName = strjoin(fileParts, filesep);
    end
end

