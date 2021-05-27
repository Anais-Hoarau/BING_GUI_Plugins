function y = medfilt1(x,varargin)
%MEDFILT1  One dimensional median filter.
%   Y = MEDFILT1(X) returns the output of a third-order median filtering of
%   X.  Y is the same size as X.  Zeros are assumed to the left and the
%   right of X.  If X is a matrix, then MEDFILT1 operates along the columns
%   of X.
%
%   Y = MEDFILT1(X,N) specifies the order, N, of the median filter.
%   For N odd, Y(k) is the median of X( k-(N-1)/2 : k+(N-1)/2 ).
%   For N even, Y(k) is the median of X( k-N/2 : k+N/2-1 ).
%
%   Y = MEDFILT1(...,MISSING) specifies how NaN (Not-A-Number) values
%   are treated over each segment. The default is 'includenan':
%     'includenan' - the median of a segment containing NaN values is also NaN.
%     'omitnan'    - the median of a segment containing NaN values is the
%                    median of all its non-NaN elements. If all elements
%                    are NaN, the result is NaN.
%
%   Y = MEDFILT1(...,PADDING) specifies the type of filtering at the
%   edge points.  The default is 'zeropad':
%     'zeropad'    - zeros are added to the left and right of X
%                    when computing the medians.
%     'truncate'   - the number of elements used to compute the median
%                    at the endpoints are reduced
%
%   Y = MEDFILT1(X,N,BLKSZ,DIM) or MEDFILT1(X,N,[],DIM) operates along the
%   dimension DIM.  BLKSZ is required for backwards compatibility and is
%   ignored.
%   
%   % Example:
%   %   Construct a noisy signal and apply a 10th order one-dimensional 
%   %   median filter to it.
%
%   fs = 100;                               % Sampling rate                                   
%   t = 0:1/fs:1;                           % Time vector
%   x = sin(2*pi*t*3)+.25*sin(2*pi*t*40);   % Noise Signal - Input
%   y = medfilt1(x,10);                     % Median filtering - Output
%   plot(t,x,'k',t,y,'r'); grid;            % Plot 
%   legend('Original Signal','Filtered Signal')
%
%   See also MEDFILT2, MEDIAN, HAMPEL, FILTER, SGOLAYFILT.
%
%   Note:  MEDFILT2 is in the Image Processing Toolbox.

%   Copyright 1988-2015 The MathWorks, Inc.

% Validate number of input arguments

narginchk(1,6);

% ensure X is valid
validateattributes(x, ...
  {'single','double'},{'real','nonsparse'}, mfilename, 'X', 1);

% get filter size
n = 3;
if ~isempty(varargin) && ~isempty(varargin{1}) && isnumeric(varargin{1})
  n = varargin{1};
  validateattributes(n, {'numeric'}, ...
    {'scalar','integer','nonnegative'},mfilename,'N',2);
end

% get dimension argument
dim = [];
if numel(varargin)>2 && isnumeric(varargin{3})
  dim = varargin{3};
  validateattributes(dim,{'numeric'},{'integer','scalar','positive'});
end

% process options
[padding, varargin] = getmutexclopt({'zeropad','truncate'},'zeropad',varargin);
[missing, varargin] = getmutexclopt({'includenan','omitnan'},'includenan',varargin);
chkunusedopt(varargin);

% compute central moving median with specified options
y = mvmedian(x,n,dim,'central',missing,padding);
