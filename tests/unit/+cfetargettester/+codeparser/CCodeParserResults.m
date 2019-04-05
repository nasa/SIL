% This class encapsulates the results obtained from the CCodeParser
classdef(Sealed = true) CCodeParserResults < handle
    properties(SetAccess = private)
        AnalyzedFiles = []; % Property to hold the analyzed file data structure
    end
    
    methods (Access = ?cfetargettester.codeparser.CCodeParser)
        function obj = CCodeParserResults(aFileObj)
            % Object passed must be of type CFile
            if ~isa(aFileObj,'cfetargettester.codeparser.CFile')
                throw(MException('CfeTargetTester:CCodeParserResults:InvalidInput', ...
                'Input passed is not a CFile'));
            end
            obj.AnalyzedFiles = aFileObj;
        end
    end
    
end

