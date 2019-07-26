% 
% CFE SIL Interface code generation test cases for:
% Model: TimeAtTop
% Tests:
%   - CFS Time blocks at top model level
%   - CFS Time block in atomic (nonvirtual subsystem)
%

classdef Test_TimeAtTop < cfetargettester.CfeTargetTester
    
    properties
        TestModel = 'TimeAtTop' 
        TestSubsystem = 'AtomicSubsystem.c';
        TestInterface = 'eci_interface.h'
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

        % Test for codegen with no warrnings
        function testCodegen(testcase)  
            import matlab.unittest.constraints.IssuesNoWarnings
                       
            % model build should produce no warnings
            testcase.verifyThat(@() testcase.generateCode(), IssuesNoWarnings);                           
        end        
        
        % Check basic contents of SIL interface header 
        % - this will generate code
        %
        % This test model will have static data defined in the interface
        % (see patterns below).
        function testInterfaceHeader(testcase)  
            
            mdl = testcase.TestModel;
           
            % Check for standard defines             
            patterns(1).FileName = [testcase.TestInterface];          
            patterns(1).ContainsOrderedPatterns = { ...
                ['#define\s*ECI_APP_REVISION_NUMBER\s*'], ...
                ['#define\s*MODEL_NAME_LEN\s*'], ...                               
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
            
            % Checking for empty Send/Receive tables
            patterns(2).FileName = [testcase.TestInterface];          
            patterns(2).ContainsOrderedStrings = { ...                       
                'static ECI_Msg_t ECI_MsgSnd[] = {'  , ...
                '{ 0, NULL, 0, NULL, NULL }'  , ...
                '};'  , ...
                'static ECI_Msg_t ECI_MsgRcv[] = {'  , ...
                '{ 0, NULL, 0, NULL, NULL }'  , ...
                '};'  }   ;            
            
            testcase.checkCodeContents(patterns);
        end   
        
        % Check that model generates code for the GNC Time block 
        %
        function testModelUsingGncTime(testcase)  
            patterns(1).FileName = [testcase.TestModel '.c'];          
            patterns(1).ContainsOrderedStrings = { ...
                'void TimeAtTop_step(void)', ...
                '{', ...
                'TimeAtTop_Y.Out1 = ((real_T)ECI_Step_TimeStamp.Seconds + ((real_T)', ...
                'ECI_Step_TimeStamp.Subseconds/4294967296.0));', ...
                'TimeAtTop_AtomicSubsystem(&TimeAtTop_Y.Out2);', ...
                '}'   };
                      
            testcase.checkCodeContents(patterns);
        end        

        % Check that atomic subsystem generates code for the GNC Time block 
        %
        function testSubsystemUsingGncTime(testcase)             
            patterns(1).FileName = [testcase.TestSubsystem];          
            patterns(1).ContainsOrderedStrings = { ...
                'void TimeAtTop_AtomicSubsystem(real_T *rty_Out1)', ...
                '{', ...
                '(*rty_Out1) = ((real_T)ECI_Step_TimeStamp.Seconds + ((real_T)', ...
                'ECI_Step_TimeStamp.Subseconds/4294967296.0));', ...
                '}'   };                                       
                      
            testcase.checkCodeContents(patterns);
        end        
        
    end
end
