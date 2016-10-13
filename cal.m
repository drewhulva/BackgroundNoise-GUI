function [ cons ] = cal()
%CAL records 5 seconds of audio and calculates the calibration constant
%   Detailed explanation goes here

% Check to make sure SpectraDAQ is connected
d=audiodevinfo;
daqnum=strfind({d.input(:).Name}, 'XMOS');
if isempty(daqnum)
    error('Please connect SpectraDAQ.')
    return
end
daqnum=find(~cellfun('isempty', daqnum));
id=d.input(daqnum).ID;

fs=48000;
recorder1 = audiorecorder(fs,16,1,id);
% Show waitbar. Doesn't move yet... but it says wait.
h=waitbar(1,'Calibrating...');
recordblocking(recorder1, 2);
stop(recorder1);
delete(h)
myRecording = getaudiodata(recorder1);
cons = mic_calib(myRecording, 48000, 50000, 1, 94, 1000, 2);

end

