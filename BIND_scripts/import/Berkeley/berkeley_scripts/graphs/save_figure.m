% save_figure.m
% 
% Written by Christopher Nowakowski
% v.1 12/23/08
%
% This function saves a figure to a specified graphics file.
%
% -jpg and -png work fine.  However, the others are suspect.  The commands
% are correct, but the output file that MatLab produces generally cannot be
% opened, at least by anything I have on my mac.
% 
% Resolution is currently fixed at 150 dpi if you set Width & Height.
% 
% If you do not set Width & Height, MatLab does some autoscaling which gives
% you something close to what you see on the screen, but the resolution of the
% graphic image will vary because MatLab will pick some optimum size.
% 

function [FileName] = save_figure(h,width,height,output,FileName)

% -------------------------------------------------------------------------------------------------
% Check Input Arguments
% -------------------------------------------------------------------------------------------------

% Set Help Messages
usage_msg = 'Usage: [SavedFileName] = save_figure(FigureHandle,[opt Width{in},Height{in}],[opt OutputFormat],[opt FilePath&Name]);';
valid_outputs = {'-jpg' '-eps' '-png' '-pdf' '-ai'};

% Set Defaults
set_figure_size = 0;
ask_user_for_filename = 1;

% Check for Help Request
if (nargin == 1 && strcmpi(h,'?')),
    disp(usage_msg);
    disp('Valid Output Formats: -jpg -eps -png -pdf -ai');
    return;
end;

if (nargin == 1),
    % Minimum Input Argument is Figure Handle: Use Defaults
    
    % set_figure_size = 0;
    output = '-jpg';
    % ask_user_for_filename = 1;
    
elseif (nargin == 2 && ischar(width)),
    
    % If 2 arguments are given: The second could be OutputFormat or FileName
    if (nnz(strcmpi(width,valid_outputs))),
        
        % Width is OutputFormat
        
        % set_figure_size = 0;
        output = width;
        width = [];
        % ask_user_for_filename = 1;
        
    else,
        % Width is FileName
        
        % set_figure_size = 0;
        output = '-jpg';
        FileName = width;
        width = [];
        ask_user_for_filename = 0;
    end;
    
elseif (nargin == 3 && isnumeric(width) && isnumeric(height)),
    
    % 3 arguments are given & the second and third are figure sizes
    set_figure_size = 1;
    output = '-jpg';
    %ask_user_for_filename = 1;
    
elseif (nargin == 3 && ischar(width) && ischar(height)),
    
    % 3 arguments are given & the second and third are Output Format and FileName
    % set_figure_size = 0;
    output = width;
    width = [];
    FileName = height;
    height = [];
    ask_user_for_filename = 0;
    
elseif (nargin == 4 && isnumeric(width) && isnumeric(height) && ischar(output)),
    
    % If 4 arguments are given: the 4th argument could be Output Format or FileName
    if (nnz(strcmpi(output,valid_outputs))),
        
        % Output is OutputFormat
        
        set_figure_size = 1;
        % output = output;
        % ask_user_for_filename = 1;
        
    else,
        % Output is FileName
        
        set_figure_size = 1;
        FileName = output;
        output = '-jpg';
        ask_user_for_filename = 0;
    end;

elseif (nargin == 5 && isnumeric(width) && isnumeric(height) && ischar(output) && ischar(FileName)),
    
    % All 5 input arguments are given
    set_figure_size = 1;
    ask_user_for_filename = 0;
    
else,
    % Invalid number or types of input arguments
    error(usage_msg);
end;


% -------------------------------------------------------------------------------------------------
% Get/Verfiy Output Filename
% -------------------------------------------------------------------------------------------------
if (ask_user_for_filename),
    FileName = ui_get_save_as_filename('-figure');
    if isempty(FileName),
        return;
    end;
else,
    if exist(FileName,'file') == 0,
        disp(['Saving ' FileName]);
    elseif exist(FileName,'file') == 2,
        disp(['Overwriting ' FileName]);
    else,
        error('%s%s\n%s','Attempted to save ',FileName,...
            'Specified FileName is invalid.');
    end;
end;



% -------------------------------------------------------------------------------------------------
% Set Output Format
% -------------------------------------------------------------------------------------------------
if(strcmpi(output,'-eps')),
    output = '-depsc';

elseif(strcmpi(output,'-png')),
    output = '-dpng';
    
elseif(strcmpi(output,'-pdf')),
    output = '-dpdf';
    
elseif (strcmpi(output,'-ill')),
    output = '-dill';
    
else,
    % Default
    output = '-djpeg';
end;



% -------------------------------------------------------------------------------------------------
% Print Figure
% -------------------------------------------------------------------------------------------------

% Set Figure Size
if (set_figure_size),
    set(h,'PaperUnits','inches','PaperSize',[width height],'PaperPosition',[0 height width height]);
else,
    set(h,'PaperPositionMode','auto');
end;

% Set Print Flag to Indicate Passed Figure Number
figure_flag = ['-f' num2str(h)];

% Print with a specific resolution
if (strcmpi(output,'-dill')),
    print(figure_flag,output,FileName);
else,
    print(figure_flag,output,'-r150',FileName);
end;

end