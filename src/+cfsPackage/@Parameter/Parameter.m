classdef Parameter < Simulink.Parameter  
    methods
        function setupCoderInfo(h)
            useLocalCustomStorageClasses(h, 'cfsPackage');
        end
        
        function h = Parameter(varargin)          
            % Call superclass constructor with variable arguments
            h@Simulink.Parameter(varargin{:});
        end
    end
end