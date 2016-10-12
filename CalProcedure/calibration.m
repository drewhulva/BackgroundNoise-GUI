%%  Applies calibration to some audio 
%   Written by Andrew Hulva 7/25/2015

audioPath = getappdata(0, 'audioPaths');
calPath = getappdata(0, 'calFull');

calAudio = audioread(calPath);

[cfa, SP, ~, fcal] = mic_calib(calAudio, 44100, 2^16, 1, 94, 1000, 1);

for i = 1:length(audioPath)
    temp = audioread(audioPath{i});
    temp = temp(:,1);
    temp = temp.*cfa;
    temp(find(temp == 0)) = 1e-17;% Add offset to prevent taking the log of zero.
    audio{i} = temp;
end
for k = 1:length(audioPath)
    tempStr = getappdata(0, 'audioNames');
    tempStr = strrep(tempStr{k},'.wav','');
    audioPath{k} = strcat(tempStr, '_calPa.mat');
end
[~, PathName] = uiputfile('*.mat', 'Choose a save directory...', 'Files will be saved in the folder you choose with _calPa appended to the original name'); %# <-- dot
if PathName==0 % or display an error message
    msgbox('You did not choose a save directory. Aborting!');
    return;
    else 
    finalAudioPath = fullfile(PathName,audioPath);
    for h = 1:length(audioPath)
        calAudio = audio{h};
        save(audioPath{h}, 'calAudio', '-mat');
        tempagain = audioPath{h};
        movefile(tempagain, PathName);
    end
    msgbox('Done!');
end

