% 
% CFE SIL Interface code generation test cases for:
% Model: EventMdlRef
% Tests:
%   - Event block in a model ref in muti-instance config
%   - Event block in a model ref in single instance config
%   - ...and there is no Event Table genrerated.
%
%     In multi-instance we should see a fatal build error.
%     In single instance we get a warning, but should not
%     create any event table information in the header.

classdef Test_EventMdlRef < cfetargettester.CfeTargetTester
    
    properties
        TestModel = 'EventMdlRef' 
        TestModelRef = 'EventBot'
        TestInterface = 'eci_interface.h'
        TestData  = 'test_data.mat'
    end
    
    methods(TestClassSetup)
        function loadModel(testcase)
                load_system(testcase.TestModel);
                load_system(testcase.TestModelRef);
                testcase.configModelForTesting(testcase.TestModel); 
                testcase.configModelForTesting(testcase.TestModelRef);                  
                testcase.addTeardown(@() close_system(testcase.TestModel, 0));
                testcase.addTeardown(@() close_system(testcase.TestModelRef, 0));               
        end
    end
    
    methods(Test)
  
        % Verify that Event block in model ref context in multi-instance 
        % throw a fatal
        %
        function testMultiInstanceFail(testcase)  
            import matlab.unittest.constraints.Throws            
            
            set_param(testcase.TestModelRef,'ModelReferenceNumInstancesAllowed', 'Multi');
            save_system(testcase.TestModelRef);
            % model build should throw an error
            testcase.verifyThat(@() testcase.generateCode(), ...
                Throws('Simulink:modelReference:MultiInstanceDWorkDataNotReusableSC'));                
            set_param(testcase.TestModelRef,'ModelReferenceNumInstancesAllowed', 'Single');
            save_system(testcase.TestModelRef);                     
        end
        
        % Verify that Event block in model ref context in single-instance
        % will give a warning
        %   (the warning is: "Block is being used in a Model Reference. 
        %    This will not result in code being generated for CFS Event 
        %    Tables")
        %
        function testSingleInstanceWarning(testcase)  
            import matlab.unittest.constraints.IssuesWarnings            
           
            set_param(testcase.TestModelRef,'ModelReferenceNumInstancesAllowed', 'Single');
            save_system(testcase.TestModelRef);
            % model build should give warning
            testcase.verifyThat(@() testcase.generateCode(), ...
                IssuesWarnings({'RTW:tlc:GenericWarn'}));                
        end
        
        function testNoEventTableCreate(testcase)  
        % In the case of the build in single instance, there should be 
        % no Event Table data generated in interface header.
            patterns(1).FileName = [testcase.TestInterface];          
            patterns(1).DoesNotContainStrings = { ...                     
                '#define ECI_EVENT_TABLE_DEFINED' , ...
                'static const ECI_Evs_t ECI_Events[] = {' ...
                };
            
            testcase.checkCodeContents(patterns);        
        end        
        
    end
end
