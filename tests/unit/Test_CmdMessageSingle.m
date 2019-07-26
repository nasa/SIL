% 
% CFE SIL Interface code generation test cases for:
% Model: CmdMessageSingle
% Tests:
%   - Check for a single Cmd message entry in Send and Recieve table
%

classdef Test_CmdMessageSingle < cfetargettester.CfeTargetTester
    
    properties
        TestModel = 'CmdMessageSingle' 
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
            import matlab.unittest.constraints.Throws          
            
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
                       
            % model build should produce no warnings
            testcase.verifyThat(@() testcase.generateCode(), IssuesNoWarnings);                
            
            % 
            patterns(1).FileName = [testcase.TestInterface];          
            patterns(1).ContainsOrderedStrings = { ...           
                'static ECI_Msg_t ECI_MsgSnd[] = {', ...
                '{ NESTEDBUS_DEF1_MID, &def1, sizeof(NestedBus), NULL, NULL },', ...
                '{ 0, NULL, 0, NULL, NULL }' , ...
                '};' , ...
                'static NestedBus abc1_queue[ECI_CMD_MSG_QUEUE_SIZE];' , ...
                'static ECI_Msg_t ECI_MsgRcv[] = {' , ...
                '{ NESTEDBUS_ABC1_MID, &abc1, sizeof(NestedBus), &abc1_queue[0], NULL },' , ...
                '{ 0, NULL, 0, NULL, NULL }' , ...
                '};' }   ;         
            
            testcase.checkCodeContents(patterns);
        end        

    end
end
