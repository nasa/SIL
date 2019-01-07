function status = cfs_add_path(varargin)
%CFS_ADD_PATH
%Add directories to the path for CFS Code Generation Target.
%
% Note: this will permenently add the SIL to your matlab path. Only use
% this if youre doing a permenent installation of the SIL for a machine.

this = which('cfs_add_path');
[tpath,~,~] = fileparts(this);
addpath(tpath);
addpath([tpath, filesep, 'mex']);
addpath([tpath, filesep, 'mex', filesep, 'tlc_c']);

status = savepath;
rehash toolboxreset;
rehash toolboxcache;
if nargin > 0
  if varargin{1}== 0
     exit;
  end
end
