%--------------------------------------------------------------------------
% 
%  Abstract:
%   NASA Core Flight Software (CFS) callback functions to set configuration
%   for cfs_ert.tlc system target
% 
%--------------------------------------------------------------------------

function cfs_selectcallback(hDlg, hSrc)

% Set the Model Reference Compliant flag to on.
slConfigUISetVal(hDlg, hSrc,'ModelReferenceCompliant','on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Optimizations pane
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Disallow all parameters tunable setting (user must specify one
%% parameter structure for tuning).

%slConfigUISetVal(hDlg, hSrc, 'InlineParams', 'on');
%slConfigUISetEnabled(hDlg, hSrc, 'InlineParams', false);

slConfigUISetVal(hDlg, hSrc, 'DefaultParameterBehavior', 'Inlined');
slConfigUISetEnabled(hDlg, hSrc, 'DefaultParameterBehavior', false);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Code Generation top pane
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set language to C only.  No C++ support
slConfigUISetVal(hDlg, hSrc, 'TargetLang', 'C');
slConfigUISetEnabled(hDlg, hSrc, 'TargetLang', false);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Code Generation Interface pane
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set code interface such that Function Prototype control is disallowed
%% and packaging is non-reusable (model inteface is void-void)
slConfigUISetVal(hDlg, hSrc, 'ModelStepFunctionPrototypeControlCompliant', 'off');
slConfigUISetEnabled(hDlg, hSrc, 'ModelStepFunctionPrototypeControlCompliant', false);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Code Generation Templates pane
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
slConfigUISetVal(hDlg, hSrc, 'ERTCustomFileTemplate', 'cfs_interface.tlc');
slConfigUISetEnabled(hDlg, hSrc, 'ERTCustomFileTemplate', true);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set Toolchain compilance on.  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hCS = hSrc.getConfigSet();
  
% The following parameters enable toolchain compliance.
slConfigUISetVal(hDlg, hSrc, 'UseToolchainInfoCompliant', 'on');
hCS.setProp('GenerateMakefile','on');
  
% The following parameters are not required for toolchain compliance.
% But, it is recommended practice to set these default values and 
% disable the parameters (as shown).
hCS.setProp('RTWCompilerOptimization','off');
hCS.setProp('MakeCommand','make_rtw');
hCS.setPropEnabled('RTWCompilerOptimization',false);
hCS.setPropEnabled('MakeCommand',false);

% EOF

