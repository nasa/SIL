% 
% CFE SIL Interface code generation test cases for:
% Model: ConditionalAtTop
% Tests:
%   - Conditional Msg blocks at top model level
%   - Conditional Msg block in atomic (nonvirtual subsystem)
%

classdef Test_ConditionalAtTop < cfetargettester.CfeTargetTester
    
    properties
        TestModel = 'ConditionalAtTop' 
        TestInterface = 'eci_interface.h'
        TestData  = 'test_data.mat'
    end
    
    methods(TestClassSetup)
        function loadModel(testcase)
                load_system(testcase.TestModel);
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
            % SIL mode is not supposed to work in this case
            % TODO testcase.verifyThat(@() testcase.silModeSim(testcase.TestModel), IssuesNoWarnings);                              
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
            
            % Check for correct layout of Event table (must occur in this order)            
            patterns(1).FileName = [testcase.TestInterface];          
            patterns(1).ContainsOrderedStrings = { ...                     
                'static ECI_Msg_t ECI_MsgSnd[] = {'  ,...
                '{ MSGBUS_CONDMSG1_MID, &condMsg1, sizeof(msgBus), NULL,'  ,...
                '&cmsgFlag_ConditionalAtTop_233 },'  ,...
                '{ MSGBUS_CONDMSG2_MID, &condMsg2, sizeof(msgBus), NULL,'  ,...
	            '&cmsgFlag_ConditionalAtTop_234 },'  ,...
                '{ 0, NULL, 0, NULL, NULL }'  ,...
                '};'    } ;            
            
            testcase.checkCodeContents(patterns);
        end        

    end
end
