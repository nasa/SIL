function bool = checkBuildDirectory(aBuildDirectory)
% Convert the build directory name to the platform specific
% name containing the correct file separators

validateattributes(aBuildDirectory, ...
    {'char'}, ...
    {'nonempty'}, ...
    '', ...
    'BuildDirectory');

% check if the directory exists
if exist(aBuildDirectory, 'dir') ~= 7
    exception = MException('CfeTargetTester:BuildDirectoryNotFound', 'Directory passed to CCodeExtractor was not found on the path');
    throw(exception);
end

% Get the buildInfo
buildInfoFiles = fullfile(aBuildDirectory, 'buildInfo.mat');

% Read all the mat files
if ~exist(buildInfoFiles, 'file')
    error('CfeTargetTester:BuildInfoNotFound','BuildDirectory does not contain a buildInfo.mat file');
end

bool = true;
end