function compileIfNeeded(sFcnname)
% compiles the Sfunction if needed
%
% Inputs - 
% name - name of the sfunction
%

     fprintf('Checking status of %s... ', sFcnname);

    % its hard to determine if an sfunction exists or not because there's
    % no consistent way to store them and they have various artifacts
    % depending on how their built, so just try calling it to see if it exists 
    % on the path
    %
    % this is expected to error, but which error is thrown is useful info.
    try
        eval(sFcnname);
    catch ME             
        
        % Matlab documentation indicates that an sfunction must
        % have the same name as the file containing it, so we can
        % attempt to find the file defining the function using the
        % name of the sfunction
        sFcnFilename = [sFcnname '.c'];
        sFcnPath = which(sFcnFilename);
        
        switch ME.identifier
        case 'MATLAB:UndefinedFunction'
            % sfunction is not callable (it doesnt exist on the path) and so
            % needs to be generated
            fprintf('SFunction %s cannot be found. Attempting to build\n', sFcnname);
                
                if(isempty(sFcnPath))
                    % could not find source, so we can't build it
                    error('compileIfNeeded:SourceNotFound', ...
                        'Could not find %s, which should contain the function defintion. Make sure that its on the path.', ...
                        sFcnFilename);
                else
                    % found the source file, attempt to build
                    compileSFcn(sFcnPath)
                    return
                end
            
        case 'Simulink:SFunctions:SimStructTooFewRHSArguments'
            % sfunction is callable (ie, it exists), so now check to make sure
            % that it doesn't need to be recompiled
                
            if(sFcnIsOutOfDate(sFcnPath))
                % rebuild
                fprintf('%s source files newer than mex files, compiling... \n', sFcnname);
                compileSFcn(sFcnPath)
                return
            else
                fprintf('files present and up to date, no rebuild necessary...\n');
                return
            end
            
        otherwise
            % who knows... rethrow it
            rethrow(ME)
        end
    end
    % somehow calling sfcn directly didn't error, which is unexpected
	error('Calling sfcn didn''t cause an error like it was supposed to, contact developer!')
end

function compileSFcn(sFcnPath)
% Compiles sfunction and moves it to overwrite previous version
%

    %% Parse sFcn path
    [sFcnFullPath,sFcnName,~] = fileparts(sFcnPath);
     fprintf('Compiling %s...\n', sFcnName);

    %% Check/Compile Model
   
    % compile the sfunction, mex file will be output in current directory
    mex('-silent',sFcnPath);
    mexFullName = [sFcnName '.' mexext];
    
    %% Delete original mex file if it exists
    sFcnFilePath = fullfile(sFcnFullPath,mexFullName);
    
    if(exist(sFcnFilePath,'file'))
      delete(sFcnFilePath);
    end

    %% Move new sfcn to old sfcn's location
    moveStatus = movefile(mexFullName,sFcnFilePath,'f');

    if(moveStatus == 0)
        warning('compileIfNeeded:compileSFcn:UnableToMove',...
            'Could not move output file ''%s'' to ''%s''.',...
            mexFullName,sFcnFilePath);
    end
    
end

function isOutOfDate = sFcnIsOutOfDate(sFcnPath)
% returns true if sfcn is out of date, false otherwise
%
%

    %% Parse sFcn path
    [sFcnFullPath,sFcnName,~] = fileparts(sFcnPath);
     
    % search for files of any extention with name of sfunction
    sFcnSearchStr = [sFcnFullPath filesep sFcnName '.*'];
    fileList = dir(sFcnSearchStr);
    
    if(isempty(fileList))
        % handle case with no files found
        error('compileIfNeeded:sFcnIsOutOfDate:CouldNotFindSFcn',...
            'Couldn''t find any files matching %s to check',...
            sFcnSearchStr);
    elseif(length(fileList) == 1)
        % handle case where only one file is found (we need two to compare)
        [~,~,foundFileExt] = fileparts(fileList.name);

        % throw error if only sfcn (but no src code)
        if(strcmp(foundFileExt,['.' mexext]))
            error('compileIfNeeded:sFcnIsOutOfDate:FoundNoSFcnSrc',...
                'Found %s but couldn''t find source files to compare against.',...
                fileList.name);
        % if only src code but no sfcn, then need to recompile, return true
        else
            warning('compileIfNeeded:sFcnIsOutOfDate:FoundNoSFcn',...
                'Found %s but couldn''t find sfunction that was identified earlier... weird... trying to compile it',...
                fileList.name);
                isOutOfDate = true;
                return
        end
    else
        % if we've made it here, we have two or more files and need to
        % compare them
        foundCFile = false;
        foundMexFile = false;
        for i = 1:length(fileList)
            [~,~,foundFileExt] = fileparts(fileList(i).name);
            if(strcmp(foundFileExt,'.c'))
                foundCFile = true;
                cFileIdx = i;
                % FIXME: this will always get the last c file in the directory,
                % add logic to make sure we get the one we want (with correct
                % name)
            elseif(strcmp(foundFileExt,['.' mexext]))
                foundMexFile = true;
                mexFileIdx = i;
            end
        end
        
        if(~foundCFile || ~foundMexFile)
           fileList(1).name
           fileList(2).name
           error('compileIfNeeded:sFcnIsOutOfDate:BothFilesNotFound',...
               'Did not find files with .c and .%s as expected.',mexext);
        else
            if(fileList(cFileIdx).datenum > fileList(mexFileIdx).datenum)
                isOutOfDate = true;
            else
                % all good, nothing to do
                isOutOfDate = false;
            end
        end % if(~foundCFile || ~foundMexFile)
    end % if(isempty(fileList))
        
end
