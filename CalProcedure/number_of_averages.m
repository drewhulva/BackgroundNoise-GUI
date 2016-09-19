function [bin_size, num_averages_out, n_over]=number_of_averages(n1, bin_size, num_averages, flag1, flag2)
% % number_of_averages: Calculates the number of points not overlapped from the array size, bin size, and number of averages
% % 
% % Syntax;
% % 
% % [bin_size, num_averages_out, n_over]=number_of_averages(n1, bin_size, num_averages, flag1, flag2);
% % 
% % ***********************************************************************
% % 
% % Description
% % 
% % This program computes the number of averages and number of points for
% % overlap averaging for the fft program spectral analysis.
% % 
% % 
% % ***********************************************************************
% % 
% % Input Variables
% % 
% % n1 is the length of the input time record (i.e. the number of data 
% % points in the input data record).
% % 
% % bin_size is the number_of points in each fft should be divisible by 2.
% % 
% % num_averages is the desired number of averages.
% % 
% % flag1 forces the progrmam to calculate the maximum number of averages 
% % using only one point not overlapped.
% % 
% % flag2 forces the bin_size to the next higher factor of 2.
% %  
% % ***********************************************************************
% % 
% % Output variables
% % 
% % bin_size            % number of data indexed for each fft
% %                     % bin_size is not necessarily a factor of 2
% %                     % set flag2=1; to force bin_size to a factor of 2
% %                     % bin_size should be an even number
% % 
% % num_averages_out    % number of averages calculated the program given
% %                     % the input values.  
% % 
% % n_over              % Number of points not overlapped. 
% %                     % the number of overlapped data points is 
% %                     % bin_size-n_over
% %  
% %  
% % ***********************************************************************
% 
% Example='1';
% 
% n1=50000;             % length of data vector for overlap averaging
%
% bin_size=length(x)    % bin_size is the number_of points in each fft
%                       % should be divisible by 2.
%
% num_averages=1;       % Desired Number of Averages
%                       % the number of averages is computed then
%                       % the incremental number of data points to overlap 
%                       % (n_over) is adjusted to accomodate the desired 
%                       % number of averages if possible.
%                       % The actual number of averages is the output
%                       % variable num_averages and is typically larger than
%                       % the input number_of_averages.
%
% flag1=0;              % 1 calculate the maximum number of averages using
%                       %      n_over=1;
%                       % 0 use num_averages as the number of averages
%                       
% flag2=0;              % 1 force bin_size to the next higher factor of 2
%                       % speeds up computations for large data sets
%                       % 0 allow the bin_size to be not a factor of 2.
%
% [bin_size, num_averages_out, n_over]=number_of_averages(n1, bin_size, num_averages, flag1, flag2);
% 
% 
% % ***********************************************************************
% % 
% % 
% % This program was written by Edward L. Zechmann 
% % 
% %     date  12 November 2007
% % 
% % modified  13 January  2008      update comments
% % 
% % modified  26 February 2008
% % 
% % modified  19 February 2009
% % 
% % modified  20 April    2011      Renamed the output variable 
% %                                 from num_averages to num_averages_out
% % 
% % 
% % 
% % ***********************************************************************
% % 
% % 
% % Feel free to modify this code.
% % 
% % see also: 
% % 


if nargin < 1 || isempty(n1) || ~isnumeric(n1)
    n1=50000;
end

if nargin < 2 || isempty(bin_size) || ~isnumeric(bin_size)
    bin_size=n1;
end

if nargin < 3 || isempty(num_averages) || ~isnumeric(num_averages)
    num_averages=0;
end

if nargin < 4 || isempty(flag1) || ~isnumeric(flag1)
    flag1=0;
end

if nargin < 5 || isempty(flag2) || ~isnumeric(flag2)
    flag2=0;
end





% Force bin_size to be the next high factor of 2
if isequal(flag2, 1);
    bin_size=2^round(log(bin_size)/log(2));
end

% Make sure bin_size is smaller than length of x 
if n1 < bin_size
    % Set bin_size equal to the length of x 
    bin_size=n1;
    % Set bin_size equal to the next smaller factor of 2
    if isequal(flag2, 1);
        bin_size=2^floor(log(bin_size)/log(2));
    end
end

% Make sure bin_size is reasonable, currently 2^19 is supported. 
if bin_size > 2^19
    bin_size=2^19;
end

% Force bin_size to be even
if isequal(mod(bin_size,2), 1)
    bin_size=2*floor(bin_size/2);
end


num_averages=floor(num_averages);

if num_averages < 1
    num_averages=1;
end

if isequal(flag1, 1);
    n_over=1;
    num_averages=floor((n1-bin_size)/n_over)+1;
else
    if num_averages > 1
        n_over=floor((n1-bin_size)/(num_averages-1));
        if ~isequal(n_over, 0)
            num_averages=floor((n1-bin_size)/n_over)+1;
        else
            n_over=0;
            num_averages=1;
        end
    else
        n_over=n1-bin_size+1;
        num_averages=1;
    end
end

num_averages_out=num_averages;
