function git(varargin)

[~, cmdout] = system(['git ', strjoin(varargin)]);

disp(cmdout);

end