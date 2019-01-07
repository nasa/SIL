classdef (Abstract) Buffer < handle
    % This class is used in the handling of text buffers.
    properties (SetAccess = private)
        Content;    % Text in the Buffer
        FileName;   % File that the buffer belongs to
    end
    
    properties (SetAccess = private, Hidden)
        IsSpared;   % This tells us whether the buffer has been spared.
        SparedDirectory;   % Directory where the file is spared.
    end
    methods (Access = protected)
        function obj = Buffer(theFileName,theContent)
            
            parser = inputParser();
            parser.addRequired('FileName', @(x) (~isempty(x) && ischar(x)));
            parser.addRequired('Content', @ischar);
            parser.parse(theFileName,theContent);
            obj.Content = parser.Results.Content;
            obj.FileName = parser.Results.FileName;
            obj.IsSpared = false;
            obj.SparedDirectory = '';
        end
    end
    
    methods(Abstract, Hidden)
        % getDiagnostic: This method provides us the right diagnostic
        % message for the concrete classes.
        diagString = getDiagnostic(obj);
    end
    
    methods(Hidden)
        function setSparedOn(obj, sparedDir)
            obj.IsSpared = true;
            obj.SparedDirectory = sparedDir;
        end
        function spareFile(obj)  % FIXME This needs to be tested
            import matlab.unittest.fixtures.TemporaryFolderFixture
            % Check if the file has been spared already
            if ~obj.IsSpared
                % Save the file
                % FIXME td = qeTempDir;
                td = testCase.applyFixture(TemporaryFolderFixture);
                % FIXME td.setSparedOn();
                copyfile(obj.FileName, td.Folder);
                
                % Set the sparedOn property of the buffer
                obj.setSparedOn(td.Folder)
                
                % In order to suppress diagnostics which are redundant.
                evalc('delete(td)');
            end
        end
        
    end
    
end


