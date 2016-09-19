function [ftwcf]=window_correction_factor(Fs, bin_size, win_type, f_cal)
% % window_correction_factor: Computes the factor for calibrating a Fourier Transform given specific processing parameters
% % 
% % Syntax:
% % 
% % [ftwcf]=window_correction_factor(Fs, bin_size, win_type, f_cal);
% % 
% % ***********************************************************
% % 
% % Description
% %
% % The amplitude in the frequency domain should be equal to the 
% % amplitude in the time domain.  The window_corrrection factor calculates 
% % the correction factor to make these two amplitudes equal within 
% % machine precision.  
% % 
% % The function creates a test signal with a frequency that is
% % equal to one of the elements of the array f.
% % Using a test signal which lies directly on a spectral line 
% % eliminates spectral leakage and ensures full amplitude in the
% % frequency domain.  The test signal is given an amplitude of unity,
% % so the rms amplitude is sqrt(0.5).
% % 
% % The other processing controls must have the same value as well.
% % The same sampling rate, number of data points, and window are also
% % used.
% % 
% % 
% % ***********************************************************
% % 
% % Input Variables
% % 
% % Fs=44100;               % (Hz) Sampling Rate
% % 
% % bin_size=length(x);     % bin_size is the number_of points in each fft
% %                         % should be divisible by 2.
% % 
% % win_type='hann'         % window for tapering the time record to zero at 
% %                         % the beginning and end of the time record to 
% %                         % reduce the "ringing effect" in the fft. 
% % 
% % f_cal=250;              % (Hz) frequency of the calibration signal 
% %                         % typically 250 or 1000 Hz
% % 
% % ***********************************************************
% %
% % Output Variables
% % 
% % ftwcf an acronym stand for "Fourier Transform Window Correction Factor"
% % even Fourier Transforms need to be calibrated
% % 
% % ***********************************************************
% 
% 
% Example='1';
% 
% Fs=44100;      % (Hz) Sampling Rate
% 
% bin_size=length(x);   % bin_size is the number_of points in each fft
%                       % should be divisible by 2.
% 
% win_type='hann'       % window for tapering the time record to zero at 
%                       % the beginning and end of the time record to 
%                       % reduce the "ringing effect" in the fft. 
% 
% f_cal=250;            % (Hz) frequency of the calibration signal 
%                       % typically 250 or 1000 Hz
% 
% [ftwcf]=window_correction_factor(Fs, bin_size, win_type, f_cal);
% 
% 
% % ***********************************************************
% % 
% % 
% % List of Dependent Subprograms for 
% % window_correction_factor
% % 
% % 
% % Program Name   Author   FEX ID#
% % 1) flat_top		
% % 2) number_of_averages		
% % 3) spectra_estimate		
% % 4) sub_mean	
% % 
% % ***********************************************************
% % 
% % This program was written by Edward L. Zechmann 
% % 
% %    date  13 November    2007
% % 
% % modified 23 September   2008
% % 
% % modified 29 September   2008  Added a dependent function list
% %
% % ***********************************************************
% % 
% % Feel free to modify this code.
% %   
% % See Also: spectra_estimate, fft, Aweight_time_filter, Cweight_time_filter, AC_weight_NB
% %   

if (nargin < 1 || isempty(Fs)) || ~isnumeric(Fs)
    Fs=50000;
end

if (nargin < 2 || isempty(bin_size)) || ~isnumeric(bin_size)
    bin_size=50000;
end

if (nargin < 3 || isempty(win_type)) || ~ischar(win_type)
    win_type='hann';
end

if (nargin < 4 || isempty(f_cal)) || ~isnumeric(f_cal)
    
    % N is the number of points in the array f
    N=floor(bin_size/2);
    % The 0 Hz frequency componenet has been removed 
    f = Fs/2/N*(1:N); % Frequency array.  

    ix=floor(length(f)/25);
    f_cal=f(ix);
end



% Force bin_size to be even
if isequal(mod(bin_size,2), 1)
    bin_size=2*floor(bin_size/2);
end


% Calculate the fft calibration correction factor
% create a test sin wave
y2=sin(f_cal*2*pi/Fs*(1:bin_size)); 

% % **********************************************************************
%
% estimate the spectrum of the sin wave         
%
% % **********************************************************************
[ac, fc]=spectra_estimate(y2, Fs, bin_size, 1, win_type );

[val ix_calib]=min(abs(fc-f_cal));
[val2 ix_calib2]=max(ac);

if abs(ix_calib2-ix_calib)*(fc(2)-fc(1))/f_cal < 0.02
    cal_val=val2;
else
    cal_val=val;
end

ftwcf=1/sqrt(2)/cal_val;

