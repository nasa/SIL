%% add SIL to the path for code generation
addpath(genpath(fullfile('..','..','src')))

%% generate code from the model

init
rtwbuild('SILTest', 'ForceTopModelBuild', true)

%% cache generated code for testing

dest = fullfile('..','generatedCode');
src = 'SILTest_cfs_ert_rtw';

if isfile(dest)
    delete(dest);
end
zip(dest,{'*.c', '*.h'}, src);
