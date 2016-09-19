%   Acoustic Calibration Applicator
%   Author: Andrew Hulva
%   Credit: Edward Zechmann for calibration proceudre that was better than
%   the author's.

%   Summary: Applies acoustic calibration to some data by way of a calibration
%   factor obtained from some calibration data. Input is some number of
%   .wav files, and output is the same number of .mat files with a 1 x n vector of %   
%   pressure data.

%   Disclaimer: This code is not well commented. It turned out more complicated
%   than originally planned.

%   To use, run mainGIU.m
%   That's it. You want more? 
%   Okay. You need to provide a calibration file that is 94 dBSPL at
%   1000Hz. This file can be any time length, it just needs to contain the
%   calibration tone. You also need to provide audio to calibrate 
%   (you can select multiple audio files by using the shift/control keys). 

%   When a window appears to save your calibrated files, it does not matter
%   what you put as a name. The naming convention is predefined. For a
%   given input file of name 'XXX.wav' the ourput is 'XXX_calPa.mat'.