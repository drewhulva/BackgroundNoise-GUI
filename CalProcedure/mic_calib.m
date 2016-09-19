function [cfa, SP, f, f_cal]=mic_calib(x, Fs, bin_size, num_averages, Level_calib, F_calib, weighting)
% % mic_calib: Uses a flat top window to calibrate using A-weighted or Linear weighting
% %
% % Syntax:
% %
% % [cfa, SP, f, f_cal]=mic_calib(x, Fs, bin_size, num_averages, Level_calib, F_calib, weighting);
% %
% % *********************************************************************
% %
% % Description
% %
% % This program calibrates an input matrix, x, and outputs the calibrated
% % time record x (Pa) and the rms sound pressure spectra SP (Pa).
% %
% % *********************************************************************
% %
% % Input Variables
% %
% % x is the calibration signal time record;  
% %                     % default is x=sqrt(2)*0.00002*10^(114/20)*sin(2*pi*250/50000*(1:100000));
% %
% % Fs=50000;           % (Hz) Sampling Frequency
% %                     % default is Fs=50000;
% %
% % bin_size=length(x); % bin_size is the number_of points in each fft
% %                     % should be divisible by 2.
% %                     % default is bin_size=min([length(x), 50000]);
% %
% % num_averages=1;     % Number of time averages.  The time record is
% %                     % separated into pieces, each piece contributes a
% %                     % spectrum, then the spectra are averaged.
% %                     % default is num_averages=1;
% %
% % Level_calib=114;    % Level of the caibration (dB) ref 20E-6 Pa.
% %                     % default is Level_calib=114;
% %
% % F_calib=250;        % (Hz) frequency of the calibrator
% %                     % default is F_calib=250;
% %
% % weighting=1;        % specifies thE type of frequency weighting to
% %                     % apply to the input signal
% %                     % default is weighting=1; %(linear weighting
% %
% %    
% %
% % *********************************************************************
% %
% % Output Variables
% %
% % Output SP is the spectra in Pa.
% %
% % cfa             % Array of calibration constants for each row or column of x.
% %
% % SP              % Pa spectra of sound pressure in frequency domain
% %
% % f               % Hz frequency array corresponding to SP
% %
% % f_cal           % Hz measured calibration frequency
% %
% % *********************************************************************
%
%
%
% Example='1';
%
% Fs=44100;         % (Hz) Sampling Frequency
%
% x=sqrt(2)*0.00002*10^(114/20)*sin(2*pi*250/Fs*(1:(2*Fs)));
%
% bin_size=2^16;    % Number of points in each bin for the fft 
%                   % shoud be a factor of 2.
%
% 
% num_averages=1;   % Number of time averages.  The time record is
%                   % separated into pieces, each piece contributes a
%                   % spectrum, then the spectra are averaged.
%
% Level_calib=114;  % (dB) SPL of the calibrator typically 94, 114, 124 dB
%
% F_calib=250;      % (Hz) frequency of the calibration signal typically
%                   % 250 or 1000 Hz
%
% weighting=1;      % 1 for linear weighting;
%                   % 2 for A-weighting
%
%
% [cfa, SP, f, f_cal]=mic_calib(x, Fs, bin_size, num_averages, Level_calib, F_calib, weighting);
%
%
% % *********************************************************************
% %
% %
% % 
% % List of Dependent Subprograms for 
% % mic_calib
% % 
% % FEX ID# is the File ID on the Matlab Central File Exchange
% % 
% % 
% % Program Name   Author   FEX ID#
% %  1) ACdsgn		Edward L. Zechmann			
% %  2) ACweight_time_filter		Edward L. Zechmann			
% %  3) bessel_antialias		Edward L. Zechmann			
% %  4) bessel_digital		Edward L. Zechmann			
% %  5) bessel_down_sample		Edward L. Zechmann			
% %  6) convert_double		Edward L. Zechmann			
% %  7) dB_to_Pa		Edward L. Zechmann			
% %  8) ellipse		Andrew Schwartz		25580	
% %  9) estimateLevel		Douglas R. Lanman			
% % 10) fastlts		Peter J. Rousseeuw		NA	
% % 11) fastmcd		Peter J. Rousseeuw		NA	
% % 12) filter_settling_data3		Edward L. Zechmann			
% % 13) filterA		Douglas R. Lanman			
% % 14) findpeaks		T. C. O'Haver		31894	
% % 15) flat_top		Edward L. Zechmann			
% % 16) geospace		Edward L. Zechmann			
% % 17) get_p_q2		Edward L. Zechmann			
% % 18) match		Sergei Koptenko		3170	
% % 19) match_height_and_slopes2		Edward L. Zechmann			
% % 20) moving		Aslak Grinsted		8251	
% % 21) number_of_averages		Edward L. Zechmann			
% % 22) parseArgs		Malcolm Wood		10670	
% % 23) peakfinder		Nate Yoder		25500	
% % 24) pressure_spectra		Edward L. Zechmann			
% % 25) rand_int		Edward L. Zechmann			
% % 26) remove_filter_settling_data		Edward L. Zechmann			
% % 27) resample_interp3		Edward L. Zechmann			
% % 28) rmean		Edward L. Zechmann			
% % 29) rms		George Scott Copeland			
% % 30) rms_val		Edward L. Zechmann			
% % 31) spectra_estimate		Edward L. Zechmann			
% % 32) sub_mean		Edward L. Zechmann			
% % 33) updateDisplay		Douglas R. Lanman			
% % 34) window_correction_factor		Edward L. Zechmann				
% %
% %
% % *********************************************************************
% %
% % 
% % mic_calib is based on spectral.m from Matlab Central FEX ID 11689
% % submitted by Alejandro Sanchez
% % 
% %
% % 
% % mic_calib is written by Edward L. Zechmann
% %
% %     date 13 November    2007
% %
% % modified 20 January     2009
% %
% % modified  19 February   2011    Removed subtracting off the running 
% %                                 average
% %
% % modified  20 April      2011    Updated example.  
% % 
% % modified  25 May        2014    Updated the error handling for the  
% %                                 frequency of the calibrator being
% %                                 out of tolerance.  
% % 
% %
% % *********************************************************************
% %
% % Feel free to modify this code.
% %
% % See Also: accel_calib, pressure_spectra, spectra_estimate
% %



if nargin < 1 || isempty(x) || ~isnumeric(x)
    x=sqrt(2)*0.00002*10^(114/20)*sin(2*pi*250/50000*(1:100000));
end

[x]=convert_double(x);

% Make sure that the time records are in the row space
[m1, n1]=size(x);

if m1 > n1
    x=x';
    [m1, n1]=size(x);
end

if nargin < 2 || isempty(Fs) || ~isnumeric(Fs)
    Fs=50000;
end

if nargin < 3 || isempty(bin_size) || ~isnumeric(bin_size)
    bin_size=min([length(x), 50000]);
end

if nargin < 4 || isempty(num_averages) || ~isnumeric(num_averages)
    num_averages=1;
end

if nargin < 5 || isempty(Level_calib) || ~isnumeric(Level_calib)
    Level_calib=114;
end

if nargin < 6 || isempty(F_calib) || ~isnumeric(F_calib)
    F_calib=250;
end

if nargin < 7 || isempty(weighting) || ~isnumeric(weighting)
    weighting=1;
end

if ~isequal(weighting, 1)
    weighting=2;
end




% implement A-weighting if weighting == 2
% user can specify an A-weighted calibration
if isequal(weighting, 2)

    settling_time=0.1;
    type=0;

    [x]=ACweight_time_filter(type, x, Fs, settling_time);

end



% Filter each row of of the time record
% This will eliminate aliasing from the calibration
% check if the butter function exists
% if butter function exists, then implement the butterworth anti-alliasing
% filter
if isequal(exist('butter'), 2)
    % Filter the signal
    % Code borrowed from
    % spectral.m from Matlab Central FEX ID 11689
    % submitted by Alejandro Sanchez
    dt=1/Fs;

    % set the anti-aliasing filter greater than the calibration frequency
    % if possible
    Wn=4*F_calib;
    if Wn > Fs/2.5
        Wn = Fs/2.5;
    end

    % Choose a five point butterworth low pass filter
    ftype='low';
    n=5;

    % Filter each row of of the time record
    % This will eliminate aliasing from the calibration
    [b, a] = butter(n,Wn*2*dt,ftype); %Wn/nyquist = Wn*2*dt
    for e1=1:m1;
        x(e1, :) = filtfilt(b, a, x(e1, :)); % forward and reverse filtering
    end
end



% flat_top window is very accurate for calibration
win_type='flat_top';

% is a column vector of calibration factors
cfa=zeros(m1, 1);

for e1=1:m1;

    % Calculate the root-mean-square sound pressure spectra in Pa
    [a2, f]=pressure_spectra(x(e1, :), Fs, bin_size, num_averages, win_type);
    
    
    [val, ix_calib]=min(abs(f-F_calib));
    [val2, ix_calib2]=max(a2);

        
    % make sure the frequency is iwthin 2 percent tolerance  
    f_tolerance=0.02;
    
    if abs(ix_calib2-ix_calib)*(f(2)-f(1))/F_calib <= f_tolerance
        % within 2 percent tolernance
        cal_val2=val2;
        f_cal=f(ix_calib2);
    else
        % Return a warning outside of 2 percent frequency tolerance.  
        % using an expanded 20 percent tolernace to find a peak.  
        warning('Detected Frequency outside of 2 percent tolerance');
        limits=round(ix_calib.*[0.8 1.2]);
        [cal_val2, ix_calib]=max(a2(limits(1):limits(2)));
        ix_calib=ix_calib+limits(1)-1;
        f_cal=f(ix_calib);
    end


    % Calibration factors are appended to an array
    cf=dB_to_Pa(Level_calib)./cal_val2;
    cfa(e1)=cf;
    
    if nargout > 1
        % Append all of the calibrated sound pressure spectra into a matrix.
        % Allocate a matrix for the sound spectra
        if isequal(e1, 1)
            SP=zeros(m1, length(a2));
        end

        % Multiply the calibration factor by the estimated sound pressure
        % spectrum and append it to the matrix.
        SP(e1, :)=cf.*a2;

    end

end
