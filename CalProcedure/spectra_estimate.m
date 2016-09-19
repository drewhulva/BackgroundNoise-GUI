function [SP, f, num_averages_out]=spectra_estimate(x, Fs, bin_size, num_averages, win_type, flag1, flag2 )
% % spectra_estimate: Is a rough estimate of the pressure spectra 
% % 
% % Syntax:
% % 
% % [SP, f, num_averages_out]=spectra_estimate(x, Fs, bin_size, num_averages, win_type, flag1, flag2 );
% % 
% % ***********************************************************
% % 
% % Description
% % 
% % This function calculates a rough estimate of the spectra.
% % This function is used by pressure_spectra.m, which calculates a much 
% % more accurate estimate for the spectra.
% % 
% % This function estimates the root-mean-square (rms) spectra  for the 
% % time record x.  This function can be used for pressure or 
% % acceleration data so x can have units of Pa or m/s^2. 
% %
% % 
% % ***********************************************************
% % 
% % Input Variables
% % 
% % x is the input time record of sound or vibrations data.
% % 
% % Fs is the Sampling Rate (Hz).
% % 
% % bin_size is the number of data points for each average.
% %           default is bin_size=length(x);
% % 
% % num_averages is the number of time averages. 
% % 
% % win_type is the type of window for smooothing the time records to zero 
% % before computing the FFTs.
% % 
% %      List of supported windows other windows may work too.
% % 
% %           blackman
% %           chebwin
% %           flat_top
% %           flattopwin
% %           gausswin
% %           hamming
% %           hann
% %           hanning
% %           kaiser
% %           tukeywin
% % 
% % 
% % flag1=0;              % 1 calculate the maximum number of averages using
% %                       %      n_over=1;
% %                       % 0 use num_averages as the number of averages
% %                       
% % flag2=0;              % 1 force bin_size to the next higher factor of 2
% %                       % speeds up computations for large data sets
% %                       % 0 allow the bin_size to be not a factor of 2.
% % 
% % 
% % ***********************************************************
% % 
% % Output variables 
% % 
% % SP is the rms sound pressure in (Pa or m/s^2)
% % 
% % f is the frequency array corresponding to SP
% % 
% % num_averages_out is the Number of time averages. 
% % 
% % 
% % ***********************************************************
% 
% 
% Example='';
%
% x=randn(1, 100000);% Pa or m/s^2 time record of sound or vibrations
%
% Fs=44100;         % (Hz) Sampling Rate
% 
% bin_size=44100;   % number of data indexed for each fft
%                   % bin_size is not necessarily a factor of 2
%                   % set flag2=1; to force bin_size to a factor of 2
%                   % bin_size should be an even number
%                   % default is bin_size=length(x);
%
% num_averages=1;   % Number of time averages.  The time record is
%                   % separated into pieces, each piece contributes a 
%                   % spectrum, then the spectra are averaged.
%
% win_type='hann';  % window for tapering the time record to zero at the 
%                   % beginning and end of the time record to reduce
%                   % the "ringing effect" in the fft. 
% 
% [SP, f, num_averages_out]=spectra_estimate(x, Fs, bin_size, num_averages, win_type );
% 
% % 
% % ***********************************************************
% % 
% % 
% % List of Dependent Subprograms for 
% % spectra_estimate
% % 
% % FEX ID# is the File ID on the Matlab Central File Exchange
% % 
% % 
% % Program Name   Author   FEX ID#
% % 1) flat_top		Edward L. Zechmann			
% % 2) number_of_averages		Edward L. Zechmann			
% % 
% % ***********************************************************
% % 
% % spectra_estimate is based on spectral.m from Matlab Central FEX ID 11689
% % submitted by Alejandro Sanchez
% % 
% % 
% % 
% % spectra_estimate was written by Edward L. Zechmann 
% % 
% %     date  13 November   2007
% % 
% % modified  13  January   2008    updated comments
% % 
% % modified  26 February   2008    updated comments
% % 
% % modified  29 September  2008    Added a dependent function list
% %
% % modified  19 February   2011    Removed subtracting off the running 
% %                                 average
% %
% % modified  20 April      2011    Updated example.  
% % 
% % 
% % 
% % ***********************************************************
% % 
% % Feel free to modify this code.
% % 

if nargin < 1 || isempty(x) || ~isnumeric(x)
    x=randn(1,100000);
end

if nargin < 2 || isempty(Fs) || ~isnumeric(Fs)
    Fs=44100; 
end

if nargin < 3 || isempty(bin_size) || ~isnumeric(bin_size)
    bin_size=length(x);
end

if nargin < 4|| isempty(num_averages) || ~isnumeric(num_averages)
    num_averages=1;
end

if nargin < 5 || isempty(win_type) || ~ischar(win_type)
    win_type='hann';
end

if nargin < 6 || isempty(flag1) || ~isnumeric(flag1)
    flag1=0;
end

if nargin < 7 || isempty(flag2) || ~isnumeric(flag2)
    flag2=0;
end



[m1 n1]=size(x);

if m1 > n1
    x=x';
    [m1 n1]=size(x);
end


% The number_of_averages program determines how to break up the 
% data into equal sized bins.
%
% Break up the time record into pieces of length N, then perform averaging 
% in the frequency domain.
% 
[bin_size, num_averages_out, n_over]=number_of_averages(n1, bin_size, num_averages, flag1, flag2);

% N is the number of points in the array f
N=floor(bin_size/2);
% The 0 Hz frequency component has been removed 
f = Fs/2/N*(1:N); % Frequency array.  

[m2 n2]=size(f);

if m2 > n2
    f=f';
    [m2, n2]=size(f);
end


% Make the window for tapering the time record
if isequal(win_type, 'flat_top')
    [w]=flat_top(bin_size, 3);
else
    % try the window selected for the input
    % If it does not work coreclty then use a hanning window
    % warn the user if the hanning window is used as a catch.
    try
        w = eval([win_type,'(',num2str(bin_size),')']);
    catch
        warning('Invalid Window: Using the default Hanning Window'); 
        w=hann(bin_size);
    end
end

% Make sure that the window is a row vector
[m3 n3]=size(w);

if m3 > n3
    w=w';
    [m3, n3]=size(w);
end

% Calculate the Processing Gain and the Coherent Gain
PG=sum(w).^2/sum(w.^2)./bin_size;   % Processing Gain
K=sqrt(PG);                         % Incoherent Gain
CG=sum(w.^2)/bin_size;              % Coherent Gain

for e2=1:m1;
    
    for e1=1:num_averages_out;
        
        % Break up the time record for spectral averaging
        % of the time record
        x1=x(e2, ((1+n_over*(e1-1)):(bin_size+n_over*(e1-1))) );
        
        % Apply the window
        x1 = w.*x1;
        
        
        % Calculate the complex fft.
        cfft = fft(x1);
        
        % Calculate the Amplitude of the spectrum
        % Correct for the incoherent gain (i.e. sqrt(processing gain) )
        % Correct for the coherent gain
        a = 2/bin_size/CG*K*abs(cfft(2:(bin_size/2+1))); 
        
        % Calculate the average by summing the squares of the spectra
        % add dividing by the number of spectra (m1), then computing
        % the square root
        if isequal(e1, 1)
            a2=zeros(size(a));
        end
        
        % add squares of spectra together
        a2=a.^2+a2;
        
    end
    
    % square root and divide by number of spectra
    a2=sqrt(1./num_averages_out.*a2);
    
    if isequal(e2, 1)
        SP=zeros(m1, length(a2));
    end
    
    % append the spectrum to an array of spectra
    % one row per channel
    SP(e2, :)=a2;
end

% Divide by sqrt(2) to calculate the root-mean-square spectra
SP=1/sqrt(2)*SP;


