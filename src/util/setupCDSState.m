function state = setupCDSState()
% setupCDSState() Returns a Signal object which defines a CDS state 
%
% The returned signal object must reside somewhere that the model has
% access to it (ie, base workspace or Simulink Data Dictionary)) and should
% be used within a simulink model by associating it with a signal (with the 
% 'Resolve to Simulink Signal' option selected).
%
% usage:
%   mySignalObj = setupCDSState()
%
    
    state = cfsPackage.Signal();
    state.CoderInfo.StorageClass = 'Custom';
    state.CoderInfo.CustomStorageClass = 'cfsCriticalDataStorage';
    state.CoderInfo.CustomAttributes.DataScope = 'Exported';
    
end % setupCDSState()
