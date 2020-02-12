classdef CfeTargetTester < matlab.unittest.TestCase
    % CfeTargetTester - Implementation of MATLAB Unittest test case
    % for CFE Codegen Target for MathWork's Simulink & Embedded Coder.  
    %
    % CfeTargetTester implements basic methods to build model code along
    % with the CFE/SIL interface header file, and provides facilities to 
    % scan this header for required patterns based on the test conditions.   
    %
    % CfeTargetTester Properties:
    %   tempWorkingDir
    %   workingFixture
    %   buildDir
    %
    %
    % CfeTargetTester Methods:
    %
    %   CfeTargetTester - Class Constructor
    %
    % Sample Usage
    % ------------
    %
    %   % The CCodeExtractor imported depends on the product used to 
    %   % generate code. In the example below, code was generated using
    %   % Embedded Coder. If code is generated using MATLAB Coder, then 
    %   % import codertest.patternsearch.CCodeExtractor instead.
    %
    %   import codertest.patternsearch.CCodeExtractor;
    %   import codertest.patternsearch.ContainsOrderedPatterns;
    %
    %   Instantiate the CCodeExtractor 
    %   codeExtractor = CCodeExtractor.forHostEmulation('directory_containing_C_code');
    % 
    %   % Extract file from the code
    %   fileObj = codeExtractor.extract(<fileName>);
    %
    %   % Verify presence of a patterns in order in it's executable code
    %   testCase = matlab.unittest.TestCase.forInteractiveUse;
    %   testCase.verifyThat(fileObj.ExecutableCode, ...
    %              ContainsOrderedPatterns({'pattern1', 'pattern2'}));
    %   See also
    %       CFE Codegen Target User Guide
    %       MathWorks Simulink User Guide
    %       MathWorks Embedded Coder User Guide
    %       targettester.patternsearch.ContainsPatterns
    %       targettester.patternsearch.ContainsStrings
    %       targettester.patternsearch.ContainsOrderedStrings
    %       targettester.patternsearch.DoesNotContainPatterns
    %       targettester.patternsearch.DoesNotContainStrings
    %       targettester.patternsearch.CCodeExtractor    
    properties
        tempWorkingDir
        workingFixture
        buildDir
    end
    
    methods(TestClassSetup)
        function setupTestEnv(testcase)
            origPath = path;
            addpath(pwd);
            testcase.addTeardown(@() path(origPath));            
        end
        
        function createTempWorkingDir(testcase)
            import matlab.unittest.fixtures.WorkingFolderFixture;
            testcase.workingFixture=testcase.applyFixture(WorkingFolderFixture('PreservingOnFailure', true));
            testcase.tempWorkingDir=pwd;
        end        
    end
   
    methods(TestClassTeardown)
        % none
    end
    
    methods
        % Set config items for model during testing
        function configModelForTesting(testcase, model) %#ok<INUSL>
            set_param(model, 'GenerateReport', 'off'); % dont generate report
        end
        
        % Normal mode sim
        function normalModeSim(testcase, model) %#ok<INUSL>
            set_param(model, 'SimulationMode', 'normal');
            sim(model);
        end
        
        % Accelerator mode sim
        function acceleratorModeSim(testcase, model) %#ok<INUSL>
            set_param(model, 'SimulationMode', 'accelerator');
            sim(model);
        end
        
        % Rapid Accelerator mode sim
        function rapidAccelModeSim(testcase, model) %#ok<INUSL>
            set_param(model, 'SimulationMode', 'rapid');
            sim(model);
        end
        
        % SIL mode sim
        function silModeSim(testcase, model) %#ok<INUSL>
            set_param(model, 'SimulationMode', 'Software-in-the-loop (SIL)');
            sim(model);
            set_param(model, 'SimulationMode', 'normal');
            
        end
                      
        % Readability checks for class model. This method assumes that
        % code has already been generated
        function checkInterfaceCodeContents(testcase, ~, patterns)
            workingDir = fullfile(testcase.tempWorkingDir.fullpath, ...
                'slprj');
            testcase.checkCodeContents(workingDir, patterns);
        end
                    
        % Do top model build 
        function generateCode(testcase)
            
            model=testcase.TestModel;
            % Compile the modelref RTW target code
            set_param(model, 'GenCodeOnly', 'off');
            % Select the IsClass checkbox for class models
            set_param(model, 'Dirty', 'on');
            set_param(model,'RTWVerbose','on');
            fprintf('Running standalone build test\n');            
            try
                rtwbuild(model,'ForceTopModelBuild',true);
                % testcase.verifyThat(@() rtwbuild(model), IssuesNoWarnings);                
                % Check executable extension               
                ext = '';
                if ispc
                    ext = '.exe';
                end
                expOutFile = [model, ext];
                pass = isequal(exist(fullfile(pwd,expOutFile), 'file'), 2);
                testcase.verifyEqual(pass, true, ['The output file ' expOutFile ' was not found in the expected location.']);
            catch ME
                disp(['Error during build. ', ME.message]);
                rethrow(ME);
            end
        end
              
        function checkCodeContents(testcase, patterns)
        % Readability checks for generated code
        %
        % 'patterns' is a struct with layout:
        %   'FileName' : File name with extension
        %   'ContainsStrings' : Strings expected to be found
        %   'ContainsOrderedStrings' : Strings expected to be found in order
        %   'DoesNotContainStrings' : Strings not expected to be found
            
            import cfetargettester.codeparser.CCodeFileExtractor
            import cfetargettester.patternsearch.ContainsPatterns
            import cfetargettester.patternsearch.DoesNotContainPatterns
            import cfetargettester.patternsearch.ContainsOrderedPatterns

            workingDir = [testcase.workingFixture.Folder filesep testcase.TestModel '_cfs_ert_rtw'];
            codeExtractor = CCodeFileExtractor(workingDir);
            
            % Iterate through each file to be checked and verify patterns
            for i = 1:length(patterns)
                fileObj = codeExtractor.extract(patterns(i).FileName);
                objToCheckPatterns = fileObj;                

                % Verify that code contains certain strings
                if isfield(patterns(i), 'ContainsStrings') && ...
                        ~isempty(patterns(i).ContainsStrings)
                    testcase.verifyThat( ...
                        objToCheckPatterns.ExecutableCode, ...
                        ContainsPatterns(cfetargettester.str2regexp( ...
                        patterns(i).ContainsStrings)));
                end

                % Verify that code contains certain patterns
                if isfield(patterns(i), 'ContainsPatterns') && ...
                        ~isempty(patterns(i).ContainsPatterns)
                    testcase.verifyThat( ...
                        objToCheckPatterns.ExecutableCode, ...
                        ContainsPatterns(patterns(i).ContainsPatterns));
                end
                
                % Verify that code does not contain certain strings
                if isfield(patterns(i), 'DoesNotContainStrings') && ...
                        ~isempty(patterns(i).DoesNotContainStrings)
                    testcase.verifyThat( ...
                        objToCheckPatterns.ExecutableCode, ...
                        DoesNotContainPatterns(cfetargettester.str2regexp( ...
                        patterns(i).DoesNotContainStrings)));
                end 
                
                % Verify that code does not contain certain patterns
                if isfield(patterns(i), 'DoesNotContainPatterns') && ...
                        ~isempty(patterns(i).DoesNotContainPatterns)
                    testcase.verifyThat( ...
                        objToCheckPatterns.ExecutableCode, ...
                        DoesNotContainPatterns(patterns(i).DoesNotContainPatterns));
                end
                
                % Verify that code contains certain strings in order
                if isfield(patterns(i), 'ContainsOrderedStrings') && ...
                        ~isempty(patterns(i).ContainsOrderedStrings)
                    testcase.verifyThat( ...
                        objToCheckPatterns.ExecutableCode, ...
                        ContainsOrderedPatterns(cfetargettester.str2regexp( ...
                        patterns(i).ContainsOrderedStrings)));
                end
                
                % Verify that code contains certain patterns in order
                if isfield(patterns(i), 'ContainsOrderedPatterns') && ...
                        ~isempty(patterns(i).ContainsOrderedPatterns)
                    testcase.verifyThat( ...
                        objToCheckPatterns.ExecutableCode, ...
                        ContainsOrderedPatterns(patterns(i).ContainsOrderedPatterns));
                end              
            end % end for         
        end % end checkCodeContents
      
        
    end %methods
    
end
