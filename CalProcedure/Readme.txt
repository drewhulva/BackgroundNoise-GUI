Last Modified 25 May 2014

The programs in this package are for spectral analysis.  
The main program is pressure spectra.  If the waveforms to be analyzed 
need to be calibrated, then process the calibration signal with the program mic_calib. 
A bugt in mic_calib was fixed on May 25 2014 the error handing of an out of frequency tolerance 
calibrator was fixed adn checked with an out of frequency tolerance calibrator.   
Teh default tolearnce is 2 percent.  The program mic_calib now handles a 20 percent out of tolerance and returns a warning when the frequency tolerance of 2 percent is exceeded.  
The program mic_calib.m calculates the calibration factors for a sinusoidal calibration signal.

Multiply the waveforms by the calibration factors in cfa.  

Process the waveforms with the main program pressure_spectra. 

Pressure spectra was programmed for analyzing sound signals, but it can also be used for 
vibration signals especially acceleration data.  

Edward L. zechmann is the Author of the following programs 

	
	pressure_spectra
	mic_calib
	test_spectra_estimate



The program also includes fastlts and fastmcd by Peter J. Rousseeuw 
and moving.m by Aslak Grinsted jan2004. FEX ID 8251

The Aweighting filter was based on adsgn.
The program adsgn (no longer included) was written by Christophe Couvreur, Faculte Polytechnique de Mons (Belgium)
couvreur@thor.fpms.ac.be


The mic_calibration program only requires the Signal Processing toolbox fi the Aweighting option is used; modifying the code 
will remove any need for the signal proecessign toolbox.   

Removing the option for an A-weighting the calibration signal and removing the anti-aliasing
filter will allow the program to run without the signal processing toolbox.  



