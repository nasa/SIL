function createBusFromStruct(varargin)
% createBusFromStruct() creates a bus definition from an input structure
%
% usage:
%   createBusFromStruct(struct, name);
%       where 'struct' is a structure for which to create a corresponding bus
%           object for
%       where 'name' is the desired name for that bus object as a string
%
% example:
%   createBusDef(mystruct,'MyStructBusType');
%
% Note: Currently, function will error if structure is not flat (ie, no 
%       nested structures because bus definitions will be created for each 
%       substructure and the current implementation can't track/rename them 
%       properly)
% Note: This function does not respect scoping and creates the bus definition in
%       the base workspace (because that's how Simulink.Bus.createObject()
%       operates).
%

    %% validate inputs
    p = inputParser;

    addRequired(p,'struct',@struct_validation_fcn);
    addRequired(p,'name',@ischar);

    parse(p,varargin{:});

    %% create bus and assigns in base workspace
    rtn = Simulink.Bus.createObject(p.Results.struct);
    % Note: if the structure is nested then this function will create
    % definitions for the lower layers as well, however the rtn only
    % contains the name of the top level bus object that was created, so we
    % have no way of determining what other bus objects were created in
    % order to rename them with sensible names.
    
    %% rename bus to user's desired name
    
    % rename the bus we just created to the desired name
    evalin('base',sprintf('%s = %s;',p.Results.name,rtn.busName));
    
    % delete the old bus definition
    evalin('base',sprintf('clear %s;',rtn.busName));
    
    %% set properties
    % most of the time we want to generate a header for the bus
    evalin('base',sprintf('%s.DataScope = ''Exported'';',p.Results.name));

end

function rtn = struct_validation_fcn(x)
% struct_validation_fcn - Returns true if input is flat structure

    % initalize output
    rtn = true;
    
    % ensure its a struct
    if(~isstruct(x))
        rtn = false;
        warning('Structure is not a structure');
        return
    end
    
    % ensure that no fields are structs (ie, its a flat struct)
    names = fieldnames(x);
    for i = 1:length(names)
       if(isstruct(x.(names{i})))
            rtn = false;
            warning('Field ''%s'' is a struct',x.(names{i}));
            return
        end 
    end
    
end