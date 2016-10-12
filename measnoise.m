function [ octVal, f ] = measnoise( )
%MEASNOISE Measures the ambient noise in a room
%   octVal = measnoise() returns the octave-band SPL
%   
%   Parameters are:
%           X       - Description of variable
%
%   Example:
%       oct = measnoise();
%
%   Dependencies: None yet...
%
%   Created: 09/26/2016, Andrew Hulva
%   Last modified: 09/26/2016, Andrew Hulva

% Check to make sure SpectraDAQ is connected
d=audiodevinfo;
daqnum=strfind({d.input(:).Name}, 'XMOS');
if isempty(daqnum)
    error('Please connect SpectraDAQ.')
    return
end
daqnum=find(~cellfun('isempty', daqnum));
id=d.input(daqnum).ID

recObj = audiorecorder;
recorder1 = audiorecorder(44100,16,1,id);
record(recorder1);
pause(5);
stop(recorder1);

% Waitbar
h = waitbar(0,'Loading...','Background Noise Testing','Please Wait');
steps = 1000;
% Update waitbar
for step = 1:steps
    waitbar(step/steps,h,sprintf('Testing',step/steps*100));
end
%Delete waitbar
delete(h)
% Dummy output
f = [63 125 250 500 1000 2000 4000 8000 16000];
octVal = [40 37 34 31 29 26 23 20 17];

end