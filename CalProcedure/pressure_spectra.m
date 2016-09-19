function [SP, f, bin_size, num_averages, ftwcf]=pressure_spectra(x, Fs, bin_size, num_averages, win_type, flag1, flag2 )
% % pressure_spectra: Calculates an accurate estimate of the pressure spectra
% % 
% % Syntax: 
% % 
% % [SP, f, bin_size, num_averages, ftwcf]=pressure_spectra(x, Fs, bin_size, num_averages, win_type, flag1 );
% % 
% % ***********************************************************
% % 
% % Description
% % 
% % This function calculates an accurate estimate for the spectra.
% % 
% % spectra_estimate is a sub program, which calculates a rough estimate of
% % the spectra.
% % 
% % This program calculates the root-mean-square (rms) sound pressure 
% % spectra and applies an fft calibration factor, such that the amplitude 
% % of a pure tone test signal is the same in the time domain and in the 
% % frequency domain.  The frequency of the test signal corresponds exactly
% % to a frequency in the fft.  The specific frequency is automatically 
% % chosen by the program. 
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
% % bin_size is the number_of points in each fft should be divisible by 2.
% % 
% % num_averages is the Number of time averages. 
% % 
% % win_type is the type of window for tapering the beginning and ending 
% %      of the time records to zero before computings the FFTs.
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
% % flag1 forces the progrmam to calculate the maximum number of averages 
% % using an overlap of one data point.
% % 
% % flag2=0;  % 1 force bin_size to the next higher factor of 2
% %           % speeds up computations for large data sets
% %           % 0 allow the bin_size to be not a factor of 2.
% % 
% % 
% % ***********************************************************
% % 
% % Output Variables
% % 
% % SP is the rms vibrations in Arms or sound pressure in (Pa)
% % 
% % f is the frequency array corresponding to SP
% % 
% % bin_size=length(x); % bin_size is the number_of points in each fft
% %                     % should be divisible by 2.
% % 
% % num_averages=1;  % Number of time averages.  The time record is
% %                  % separated into pieces, each piece contributes a 
% %                  % spectrum, then the spectra are averaged.
% % 
% % ftwcf an acronym stand for "Fourier Transform Window Correction Factor"
% % 
% % 
% % 
% % ***********************************************************
% 
%
% Example='';
%
% x=randn(1, 100000);% (Pa) sound pressure time record.
%
% Fs=44100;         % (Hz) Sampling Rate
%
% bin_size=2^16;    % Number of points in each bin for the fft 
%                   % shoud be a factor of 2.
%
% num_averages=10;  % number of averages.
%
% win_type='hann';  % window for tapering the time record to zero at the 
%                   % beginning and end of the time record to reduce
%                   % the "ringing effect" in the fft. 
% 
% flag1=0;          % 1 calculate the maximum number of averages using
%                   %      n_over=1;
%                   % 0 use num_averages as the number of averages
% 
% 
% flag2=0;          % 1 force bin_size to the next higher factor of 2
%                   % speeds up computations for large data sets
%                   % 0 allow the bin_size to be not a factor of 2.
% 
% [SP, f, bin_size, num_averages, ftwcf]=pressure_spectra(x, Fs, bin_size, num_averages, win_type, flag1, flag2 );
% 
% semilogx(f, SP');
% 
% % ***********************************************************
% % 
% % 
% % 
% % List of Dependent Subprograms for 
% % pressure_spectra
% % 
% % FEX ID# is the File ID on the Matlab Central File Exchange
% % 
% % 
% % Program Name   Author   FEX ID#
% % 1) flat_top		Edward L. Zechmann			
% % 2) number_of_averages		Edward L. Zechmann			
% % 3) spectra_estimate		Edward L. Zechmann			
% % 4) window_correction_factor		Edward L. Zechmann				
% % 
% % 
% % ***********************************************************
% % 
% % pressure_spectra is based on spectral.m from Matlab Central FEX ID 11689
% % submitted by Alejandro Sanchez
% % 
% % 
% % pressure_spectra was written by Edward L. Zechmann 
% % 
% %     date  13 November   2007
% % 
% % modified  13 January    2008    Updated comments
% % 
% % modified  23 September  2008    Updated comments
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
% % See Also: spectra_estimate, fft, Aweight_time_filter, Cweight_time_filter, AC_weight_NB
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


% % Calculate an estimate of the root-mean-square pressure spectra in (Pa)

[SP, f, num_averages]=spectra_estimate(x, Fs, bin_size, num_averages, win_type, flag1, flag2 );


% The amplitude in the frequency domain should be equal to the 
% amplitude in the time domain.  The window_corrrection factor calculates 
% the correction factor to make these two amplitudes equal within 
% machine precision.
%
% Calculate the fft calibration factor:
%
% The function creates a test signal with a frequency that is
% equal to one of the elements of the array f.
% Then a calibration factor is calculated which makes the amplitude in 
% the frequency domain equal to the amplitude in the time domain.  
%  

ix=floor(length(f)/25);

[ftwcf]=window_correction_factor(Fs, bin_size, win_type, f(ix));

% Apply the window correction factor to the sound pressure spectra
SP=ftwcf*SP;

