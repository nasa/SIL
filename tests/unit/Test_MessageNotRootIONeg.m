% 
% CFE SIL Interface code generation test cases for:
% Model: MessageNotRootIONeg
% Tests:
%   - Use of cfsTlmMessage or cfsCmdMessage custom storage class
%     not at the root level of the model should result in a failed
%     build.

classdef Test_MessageNotRootIONeg < cfetargettester.CfeTargetTester
    
    properties
        TestModel = 'MessageNotRootIONeg' 
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
  
        % Verify that build throws an error
        %
        function testMultiInstanceFail(testcase)  
            import matlab.unittest.constraints.Throws            
            import matlab.unittest.constraints.IssuesNoWarnings            
            
            % model build should throw an error
            %  for some reason there is no error ID
            testcase.verifyThat(@() testcase.generateCode(), ...
                Throws(''));     
        end                
    end
end
