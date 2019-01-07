function blkStruct = slblocks
%SLBLOCKS Defines the block library for a specific Toolbox or Blockset.

%% Information for "Blocksets and Toolboxes" subsystem
blkStruct.Name = sprintf('CFS\nBlockset');
blkStruct.OpenFcn = 'cfs_library';
blkStruct.MaskDisplay = 'disp(sprintf(''CFS\nBlock''))';

%% Information for Simulink Library Browser
Browser(1).Library = 'cfs_library';
Browser(1).Name    = 'CFS Blockset';
Browser(1).IsFlat  = 1;% Is this library "flat" (i.e. no subsystems)?

blkStruct.Browser = Browser;

% End of slblocks
