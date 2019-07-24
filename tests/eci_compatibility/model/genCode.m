%% add SIL to the path for code generation
fprintf('Adding SIL src code to the path...\n')
addpath(genpath(fullfile('..','..','..','src')))

%% generate code from the model
fprintf('Initalizing model...\n')
init

fprintf('Generating code...\n')
rtwbuild('SILTest', 'ForceTopModelBuild', true)

%% cache generated code for testing

dest = fullfile('..','generatedCode');
src = 'SILTest_cfs_ert_rtw';

if isfile(dest)
    delete(dest);
end
zip(dest,{'*.c', '*.h'}, src);

fprintf('Wrote "%s.zip" containing generated code!\n', dest)