function compileSilSfcn()
% compileSilSfcn() - Compiles all SIL sfunctions if needed
%
% Usage:
% compileSilSfcn()

    compileIfNeeded('cfs_conditional_msg')
    compileIfNeeded('cfs_event')
    compileIfNeeded('cfs_fdc')
    compileIfNeeded('cfs_gnc_time')
    
end % compileAll()