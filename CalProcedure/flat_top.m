function [w]=flat_top(N, type)
% % Flat top windows are used for calibration, because the wide main lobe
% % has very little spectra leakage.  
% N=100;    % Number of data points in the window
% type=3;   % Selection number of the flat_top window from the list below
% %
% % Table of Basic Properties of the Flat Top Windows
% % 
% %                                   Peak      Asymptotic  Maximum
% %                                 Sidelobe      Decay      Error
% % type         Behavior              dB       dB/octave  Percentage
% %  1  % Fast deacaying 3-term      -31.85        18        0.094
% %  2  % Fast deacaying 4-term      -44.84        30        0.047
% %  3  % Fast deacaying 5-term      -57.20        42        0.028
% %  4  % minimum side-lobe 3-term   -43.19         6        0.13
% %  5  % minimum side-lobe 4-term   -66.75         6        0.078
% %  6  % minimum side-lobe 5-term   -90.5         18        0.045
% % 
% % Reference "Flat Top Windows for PWMM waveform processing viw DFT"
% % Prof. Luigi Salvator and Dr. Amerigo Trotta IEE Proceedings Vol. 135,
% % Pt. B No 6, November 1998
% %
% %
% % This program was written by Edward L. Zechmann 
% %                               10 November 2007
% %                      modified 13 November 2007 (updated comments)
% % 
% % Feel free to modify this code.
% % 
% % [w]=flat_top(N, type);


% The default type is #3
% Fast decaying 5-term
if nargin < 2
    type=3;
end

% The default number of elements is 100;
if nargin < 1
    N=100;
end

switch type
    case 1
        coef=[0.266526 0.5 0.23474];
    case 2
        coef=[0.21706 0.42103 0.28294 0.07897];
    case 3
        coef=[0.1881 0.36923 0.28702 0.13077 0.02488];
    case 4
        coef=[0.28235 0.52105 0.19659];
    case 5
        coef=[0.241906 0.460841 0.255381 0.041872];
    case 6
        coef=[0.209671 0.407331 0.281225 0.092669 0.0091036];
    otherwise
        coef=[0.266526 0.5 0.23474];
end

M=length(coef)-1;
dt=1/(N-1);
w=zeros(N, 1);

for e2=0:(N-1);
    g=zeros(size(coef));
    
    for m=0:M;
        e1=m+1;
        g(e1)=coef(e1)*(-1)^m*cos(2*pi*m*dt*e2);
    end
    w(e2+1)=sum(g);
    
end

% Calculate the coherent gain, processing gain, and the incoherent gain.
% CG=sum(w)/N;                  % Coherent Gain
% PG=sum(w)^2/sum(w.^2)/N;      % Processing Gain
% K=sqrt(PG);                   % Incoherent Gain

