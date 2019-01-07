classdef Signal < Simulink.Signal
%ECoderDemos.Signal  Class definition.

  methods
    %---------------------------------------------------------------------------
    function setupCoderInfo(h)
      % Use custom storage classes from this package
      useLocalCustomStorageClasses(h, 'cfsPackage');

      % Set up object to use custom storage classes by default
      h.CoderInfo.StorageClass = 'Custom';
    end
    
    function h = Signal()
      % SIGNAL  Class constructor.
    end % End of constructor

  end % methods
end % classdef
