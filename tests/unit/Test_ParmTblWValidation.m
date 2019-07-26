% 
% CFE SIL Interface code generation test cases for:
% Model: ParmTblWValidation
% Tests:
%   - Model with parameter tables runs without warning
%   - Model defines correct param table structure in interface header
%   - Model generates definition of table validation function
%   - Model generates definition of parameter table
%

classdef Test_ParmTblWValidation < cfetargettester.CfeTargetTester
    
    properties
        TestModel = 'ParmTblWValidation'
        TestInterface = 'eci_interface.h'
        TblDataFile = 'parmTbl.c';
        TblWValDataFile = 'parmTblWVal.c';
        TblValFile = 'tblValFcn_f.c';
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
            
            % Check pattern for param table def is valid
            patterns(1).FileName = [testcase.TestInterface];          
            patterns(1).ContainsOrderedStrings = { ...
                '#include "ParmTblWValidation.h"',...
                '#define ECI_PARAM_TBL_DEFINED 1', ...
                'parmTbl_b *parmTblWVal;', ...                               
                'int32_T tblValFcn_f(const parmTbl_b *parmTblWVal_0);', ...                               
                'static ECI_Tbl_t ECI_ParamTable[] = {', ... 
                '},', ...
                '{ 0, 0, 0, 0, 0 }', ...    
                '};'};              
            
            % Check definition of param table with validation function is
            % correct
            patterns(2).FileName = [testcase.TestInterface];          
            patterns(2).ContainsOrderedStrings = { ...
                '{',...
                '&(parmTblWVal),', ...
                '"parmTblWVal",', ...
                '"ParmTblWValidation app''s parmTblWVal table",', ...
                '"parmTblWVal.tbl",', ...
                'sizeof(parmTbl_b),', ...
                '&tblValFcn_f', ...
                '}'};          
            
            % Check definition of param table without validation is correct
            patterns(3).FileName = [testcase.TestInterface];          
            patterns(3).ContainsOrderedStrings = { ...
                '{', ... 
                '&(parmTbl),', ...
                '"parmTbl",', ...
                '"ParmTblWValidation app''s parmTbl table",', ...
                '"parmTbl.tbl",', ...
                'sizeof(parmTbl_b),', ...
                'NULL', ...
                '}'};  
            
            % check that default values for table without validation was
            % generated            
            patterns(4).FileName = [testcase.TblDataFile];          
            patterns(4).ContainsOrderedPatterns = { ...           
                '\s*parmTbl_b\s*parmTbl\s*=\s*\{', ...
                '\s*1\.0\s*,', ...
                '\s*3\.14\d*\s*',...
                '\s*\}\s*;' };    

            % check that default values for table with validation was
            % generated
            patterns(5).FileName = [testcase.TblWValDataFile];          
            patterns(5).ContainsOrderedPatterns = { ...           
                '\s*parmTbl_b\s*parmTblWVal\s*=\s*\{', ...
                '\s*1\.0\s*,', ...
                '\s*3\.14\d*\s*',...
                '\s*\}\s*;' };    
            
            % check that table validation function exists in generated code 
            % and has correct signature
            patterns(6).FileName = [testcase.TblValFile];          
            patterns(6).ContainsOrderedStrings = { ...           
                'int32_T tblValFcn_f(const parmTbl_b *rtu_tbl)', ...
                '{', ...
                'return', ...
                '}' };    
            
            testcase.checkCodeContents(patterns);
        end        

    end
end
