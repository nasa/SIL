function pkt = setupCFSPkt(type)
% setupCFSPkt() Returns a cfsPackage Signal object which defines a cFS 
% packet
%
% The returned signal object must reside somewhere that the model has
% access to it (ie, base workspace or Simulink Data Dictionary)) and should
% be used within a simulink model by associating it with a signal (with the 
% 'Resolve to Simulink Signal' option selected).
%
% usage:
%   myPktObj = setupCFSPkt(pktType)
%   	pktType may be either 'Cmd' or 'Tlm'
%
    
    pkt = cfsPackage.Signal();
    pkt.CoderInfo.StorageClass = 'Custom';
    
    if(strcmpi(type,'tlm'))
      pkt.CoderInfo.CustomStorageClass = 'cfsTlmMessage';
    elseif(strcmpi(type,'cmd'))
      pkt.CoderInfo.CustomStorageClass = 'cfsCmdMessage';
    else
      error('setupCFSPkt:UnrecognizedType',...
          'Unrecognized packet type ''%d'' provided. Use ''Cmd'' or ''Tlm''.',...
          type);
    end

end
