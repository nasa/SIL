% 
% CFE SIL Interface code generation test cases for:
% Model: SimpleTunableParmReusable
% Tests:
%   - Model has simple tunable parm structure in header due to reusable cfg
%

classdef Test_SimpleTunableParmReusable < cfetargettester.CfeTargetTester
    
    properties
        TestModel = 'SimpleTunableParmReusable'
        TestInterface = 'eci_interface.h'
        ModelDataFile = 'SimpleTunableParmReusable_data.c';
        TestData  = 'test_data.mat'
    end
    
    methods(TestClassSetup)
        function loadModel(testcase)
                load_system(testcase.TestModel);
                testcase.configModelForTesting(testcase.TestModel);                
                testcase.addTeardown(@() close_system(testcase.TestModel, 0));
        end
    end
    
    methods(Test)
        %
        % Check that simulation modes work without warnings
        function testSimulationModes(testcase)
            import matlab.unittest.constraints.IssuesNoWarnings          
            testcase.verifyThat(@() testcase.normalModeSim(testcase.TestModel), IssuesNoWarnings);                
            testcase.verifyThat(@() testcase.acceleratorModeSim(testcase.TestModel), IssuesNoWarnings);  
            testcase.verifyThat(@() testcase.rapidAccelModeSim(testcase.TestModel), IssuesNoWarnings);       
            testcase.verifyThat(@() testcase.silModeSim(testcase.TestModel), IssuesNoWarnings);                              
        end
        
        % Check basic contents of SIL interface header 
        % - this will generate code
        %
        % This test model will have static data defined in the interface
        % (see patterns below).
        function testInterfaceHeader(testcase)  
            import matlab.unittest.constraints.IssuesNoWarnings
            
            mdl = testcase.TestModel;
            
            % model build should produce no warnings
            testcase.verifyThat(@() testcase.generateCode(), IssuesNoWarnings);                
            
            % Check typical patterns
            patterns(1).FileName = [testcase.TestInterface];          
            patterns(1).ContainsOrderedPatterns = { ...
                '#define\s*ECI_APP_REVISION_NUMBER\s*', ...
                '#define\s*MODEL_NAME_LEN\s*', ...                               
                ['#define\s*ECI_FLAG_MID\s*',upper(mdl),'_FDC_MID'], ...
                ['#define\s*ECI_CMD_MID\s*',upper(mdl),'_CMD_MID'], ...
                ['#define\s*ECI_PERF_ID\s*',upper(mdl),'_PERF_ID'], ...
                ['#define\s*ECI_TICK_MID\s*',upper(mdl),'_TICK_MID'], ...
                ['#define\s*ECI_HK_MID\s*',upper(mdl),'_HK_MID'], ... 
                ['#define\s*ECI_APP_MAIN\s*',lower(mdl),'_AppMain'], ...
                ['#define\s*ECI_APP_NAME_UPPER\s*\x22',upper(mdl),'\x22'], ...
                ['#define\s*ECI_APP_NAME_LOWER\s*\x22',lower(mdl),'\x22'], ...                
                ['#define\s*ECI_CMD_PIPE_NAME\s*\x22',upper(mdl),'_CMD_PIPE\x22'], ...    
                ['#define\s*ECI_DATA_PIPE_NAME\s*\x22',upper(mdl),'_DATA_PIPE\x22']};                               
%                 ['#define\s*ECI_TICK_HZ\s*',upper(mdl),'_HZ'], ...                               

            patterns(2).FileName = [testcase.ModelDataFile];          
            patterns(2).ContainsOrderedPatterns = { ...           
                '\s*Parameters_SimpleTunableParmReu\s*SimpleTunableParmReusable_P\s*=\s*\{', ...
                '\s*234\.0\s*,', ...
                '\s*3\.14\s*\}\s*;' };    
            
            testcase.checkCodeContents(patterns);
        end        

    end
end
