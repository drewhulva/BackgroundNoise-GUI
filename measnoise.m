function [ octVal, f ] = measnoise(cons)
%MEASNOISE Measures the ambient noise in a room
%   octVal = measnoise() returns the octave-band SPL
%   
%   Parameters are:
%           cons       - Calibration constant found from cal.m
%
%   Example:
%       oct = measnoise();
%
%   Dependencies: cal.m,octdsgn.m
%
%   Created: 09/26/2016, Andrew Hulva
%   Last modified: 09/26/2016, Andrew Hulva

f = [63 125 250 500 1000 2000 4000 8000 16000];

% Find SpectraDAQ
d=audiodevinfo;
daqnum=strfind({d.input(:).Name}, 'XMOS');
if isempty(daqnum)
    error('Please connect SpectraDAQ.')
    return
end
daqnum=find(~cellfun('isempty', daqnum));
id=d.input(daqnum).ID;


fs=48000; % For now, not changeable in GUI
recD = audiorecorder(fs,16,1,id); % 16 bit for now

% Show waitbar. Doesn't move yet... but it says wait.
h=waitbar(1,'Testing... Please Wait');
% Record 5 seconds of data
recordblocking(recD, 5);
stop(recD);
% Get rid of waitbar
delete(h)
% Store data in double-precision array.
dat = getaudiodata(recD);
% Apply calibration constant
% cons=4.3934; % Valid for SpectraDAQ at +-156mv
if exist('cons','var')
    calA=dat.*cons;
else
    error('Please calibrate.')
end

% Octave-band filter captured audio 
octVal=NaN(size(f));
for i=1:length(f)
    [B,A]=octdsgn(f(i),fs);
    y = filter(B,A,calA);
    octVal(i) =  10*log10((sum(y.^2)/length(y))/(2E-5)^2); 
end

end
