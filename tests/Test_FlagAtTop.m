% 
% CFE SIL Interface code generation test cases for:
% Model: FlagAtTop
% Tests:
%   - FDC blocks at top model level
%   - FDC block in atomic (nonvirtual subsystem)
%

classdef Test_FlagAtTop < cfetargettester.CfeTargetTester
    
    properties
        TestModel = 'FlagAtTop' 
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
            
            % Check for correct layout of Event table (must occur in this order)            
            patterns(1).FileName = [testcase.TestInterface];          
            patterns(1).ContainsOrderedStrings = { ...                     
                '#define ECI_FLAG_TABLE_DEFINED          1'  ,...
                '#define ECI_FLAG_MAX_ID                 2'  ,...
                'static const ECI_Flag_t ECI_Flags[] = {'  ,...
                '{ &FdcAtTop_ConstP.CFS_FDC_Event_fdc_id,'  ,...
                '&fdcFlag_234'  ,...
                '},'  ,...
                '{ &FdcAtTop_ConstP.CFS_FDC_Event_fdc_id_b,'  ,...
                '&fdcFlag_233'  ,...
                '},'  ,...	
                '{ 0, 0 }'  ,...
                '};' }   ;           
            
            testcase.checkCodeContents(patterns);
        end        

    end
end
