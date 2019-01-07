function str = str2regexp(str, varargin)
%STR2REGEXP  Turn a string into a regular expression for rtwgencodecheck
%   S = STR2REGEXP(STR) Returns S as a regular expression.  S can be used
%   anywhere but it is expecially intended to be used in conjunction with
%   rtwgencodecheck.  By default, STR2REGEXP will create a string that
%   is insensitive to both number of spaces and number of newlines in the
%   actual string rtwgencodecheck will be looking at. STR2REGEXP will accept
%   a cell array of strings.  It will return a cell array if passed a cell
%   array and a string if passed a string.  This is to accomodate multiple
%   coding styles.
%   S = STR2REGEXP(STR, opt1, opt2 ...) Allows use of optional arguments
%   to control the format of the generated expression.  The arguments are
%   described in the table below:
%           
%           preservespaces   - Causes the resulting regular expression to
%                              preserve the number of spaces in the original
%                              string.
%           preservenewlines - Works the same as preservespaces but with
%                              newlines.  With this option, number of carriage
%                              returns will be strictly interpreted.
%           ignorecase       - Creates a regular expression that is
%                              insensetive to case changes in the generated code. 
%



% Set up defaults for spacing, newline and case sensetivity
if ~nargin
    error('STR2REGEXP requires at least one input argument')
end

s = '\s+';
srep = '\\s\+';
n = '\n+';
nrep = '\(\\s\*\\n\+\\s\*\)';
ignorecase = false;

% look for optional arguments
for i=2:nargin
    switch varargin{i-1}
        case 'preservespaces'
            s = '\s';
            srep = '\\s';
        case 'preservenewlines'
            n = '\n';
            nrep = '\(\\s\*\\n\\s\*\)';
        case 'ignorecase'
            ignorecase = true;
        otherwise
            error('An unknown flag was specified');
    end
end

% change any non-cell input into a cell to avoid errors
if ~iscell(str)
    str = {str};
    wasCell = false;
else
    wasCell = true;
end

% run through each input string
for i = 1:length(str)
    
    % Replace any metacharacters with their escaped equivalent
    str{i} = regexptranslate('escape', str{i});
    
    if ignorecase
        
        % replace word characters with two inside brackets ie. 'a' = '[aa]'
        str{i} = regexprep(str{i},'([a-zA-Z])','\[$1$1]');
        
        % find the indices of the first of these new double-characters 
        mask = regexp(str{i},'([a-zA-Z])(?=[a-zA-Z]\])');
        
        % now find the indices of the second...
        mask2 = mask+1;
        
        % change the first to uppercase and the second to lowercase 
        str{i}(mask) = upper(str{i}(mask));
        str{i}(mask2) = lower(str{i}(mask2));
    end
    
    % handle commas and double quotes
    str{i} = strrep(str{i}, '"', '\042');
    str{i} = strrep(str{i}, ',', '\054');
    
    % collapse (or preserve depending on args) spaces and newlines
    str{i} = regexprep(str{i},n,nrep);
    str{i} = regexprep(str{i},s,srep);
end

if ~wasCell
    str = str{1};
end
