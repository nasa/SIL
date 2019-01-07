%
% Abstract: A helper function to adjust the RT Model structure name
%           to remove the trailing '_'.  This is necessary since
%           the TLC LibWriteModelData() function returns a trailing
%           '_'.  
%           This function performs a regex string replace to remove the
%           trailing '_'.  'buf' is the buffer from TLC, and 'name' will be
%           the replacement string.
%    
function rbuf = cfs_rtmodel_rep(buf,name)
    targetStr = strcat(name,'_');
    rbuf = regexprep(buf,targetStr,name);
end
