% 
% CFE SIL Interface code generation test cases for:
% Model: CDSBasic
% Tests:
%   - Generation of CDS Table
%

classdef Test_CDSBasic < cfetargettester.CfeTargetTester
    
    properties
        TestModel = 'CDSBasic' 
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
            % Varsize signal in test model disallows Rapid Accel and SIL 
            % mode in this case
            % testcase.verifyThat(@() testcase.rapidAccelModeSim(testcase.TestModel), IssuesNoWarnings);       
            % testcase.verifyThat(@() testcase.silModeSim(testcase.TestModel), IssuesNoWarnings);                              
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
                '#define ECI_CDS_TABLE_DEFINED          1' , ...
                'static const ECI_Cds_t ECI_CdsTable[] = {' , ...
                '  { "ds_state",' , ...
                '35,' , ...
                '&ds_state,' , ...
                '},' , ...
                '  { "state1",' , ...
                '8,' , ...
                '&state1,' , ...
                '},' , ...
                ' { "state2",' , ...
                '400,' , ...
                '&state2,' , ...
                '},' , ...
                '{ NULL, 0, NULL }' , ...
                '};' };         
            
            testcase.checkCodeContents(patterns);
        end        

    end
end
