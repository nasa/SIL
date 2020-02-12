function cfsParamTblObj = createCfsTbl(userStruct, paramName, varargin)
% createCfsTbl() Creates a cfsPackage Parameter object which defines a cFS table
%
% Automatically creates a bus definition for the structure supplied and uses 
% that to create a cfsParameter object for use as a cFS table within a model 
% destined for code generation.
%
% Uses the convention of appending '_b' to the name of the parameter to denote
% the bus which defines its structure.
%
% Structure must be flat (ie, no nested structures). Requires that cfsPackage 
% package be on the matlab path.
%
% usage:
%   myparam = createCfsTbl(mystruct, 'myParamName')
%       Creates a bus definition and table object from mystruct using 
%       myParamName for the bus name and definition file 
%   myparam = createCfsTbl(mystruct, 'myParamName', 'myValidationFcn')
%       Same as above, but specifies myValidationFcn as the table
%       validation function used by table services. myValidationFcn must be
%       present in the generated code with the proper signature for a table
%       services table validation function.
%
        
    busName = [paramName '_b'];
    createBusFromStruct(userStruct, busName);
    % Note: bus called busName now exists in base workspace
    
    % create the cfsPackage.parameter object
    cfsParamTblObj = cfsPackage.Parameter(userStruct);
    cfsParamTblObj.CoderInfo.StorageClass = 'Custom';
    cfsParamTblObj.CoderInfo.CustomStorageClass = 'cfsParmTable';
    cfsParamTblObj.CoderInfo.CustomAttributes.DefinitionFile = [paramName '.c'];

    % setup table validation function (if specified)
    if nargin > 2
        cfsParamTblObj.CoderInfo.CustomAttributes.ValidationFcn = varargin{1};
    end
    
    % assign the bus just created as the datatype
    cfsParamTblObj.DataType = ['Bus: ' busName];

end
