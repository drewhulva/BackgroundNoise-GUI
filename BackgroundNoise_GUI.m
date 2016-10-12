function BackgroundNoise_GUI
% This GUI is the new background noise measurement interface for the
% architetural acoustics group at Virginia Tech.
%
% Features of this GUI are:
% 1. Calibrate from either microphone sensitivity or external tone
% 2. Take 5-sec ambient noise measurement and plot relevant information on
% a heatmap.

% Clean up the workspace and set all units to normalized
close all
f = figure('Visible','off','Units','Normalized','Position',[.2 .3 .6 .5]);


%%  Open new figure and 
% mh = uimenu(f,'Label','File'); 
% frh = uimenu(mh,'Label','Find and Replace ...',...
%             'Callback','disp(''goto'')');
% frh = uimenu(mh,'Label','Variable');                 
% uimenu(frh,'Label','Name...', ...
%           'Callback','disp(''variable'')');
% uimenu(frh,'Label','Value...', ...
%           'Callback','disp(''value'')');
      
% meah = uimenu(f,'Label','Measurement'); 
% uimenu(meah, 'Label','Show','Callback',@meah_Callback);
% calh = uimenu(f,'Label','Calibration'); 
% uimenu(calh,'Label','Show','Callback',@calh_Callback);

% Read icon images for toolbar
hToolbar = uitoolbar(f);
measCon = imread('measIcon.png');
calCon = imread('calIcon.png');

% Create toolbar icons
uipushtool(hToolbar, 'CData', measCon, 'ClickedCallback', @meah_Callback);
uipushtool(hToolbar, 'CData', calCon, 'ClickedCallback', @calh_Callback);


%Turn off default Menu Bar
warning('off', 'MATLAB:uitabgroup:OldVersion');
set(f, 'MenuBar', 'none', 'NumberTitle', 'off', 'Name', ...
   'Background Noise Measurement');

% Replace favicon
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe=get(f,'javaframe');
jIcon=javax.swing.ImageIcon('PATH');
jframe.setFigureIcon(jIcon);

% Make tabs panels that will be switched between
measTab = uipanel('BackgroundColor','white','Position',[0 0 1 1], ...
    'BorderType','none','Visible','on');
calTab = uipanel('BackgroundColor',[.8 .8 .8],'Position',[0 0 1 1], ...
    'BorderType','none','Visible','off');


%% Calibration tab controls
%Left side display
magText1 = uicontrol('Parent', calTab, 'Style', 'text', 'String', 'MAGNITUDE', 'Fontweight','bold', ...
    'HorizontalAlignment', 'center','Units','Normalized', 'position', [.05 .5 .1 .05]);
magText2 = uicontrol('Parent', calTab, 'Style', 'text', 'String', '94 Hz',...
    'HorizontalAlignment', 'center','Units','Normalized', 'Position', [.25 .5 .1 .05]);
magText3 = uicontrol('Parent', calTab, 'Style', 'text', 'String', '114 Hz', ...
    'HorizontalAlignment', 'center','Units','Normalized', 'Position', [.25 .35 .1 .05]);
magToggle114 = uicontrol('Parent', calTab, 'style','radio',...
    'Units','Normalized','pos',[.2 .5 .015 .03],'value',1, 'callback', @onefourteen_Callback);
magToggle94 = uicontrol('Parent', calTab, 'style','radio',...
    'Units','Normalized','pos',[.2 .35 .015 .03],'value',0, 'callback',@ninetyfour_Callback);
direct1 = uicontrol('Parent', calTab, 'Style', 'text', 'String', 'Step 1:', ...
    'HorizontalAlignment', 'center','Units','Normalized', 'position', [.05 .9 .1 .05]);
direct2 = uicontrol('Parent', calTab, 'Style', 'text', 'String', 'Step 2:', ...
    'HorizontalAlignment', 'center','Units','Normalized', 'position', [.05 .8 .1 .05]);
direct3 = uicontrol('Parent', calTab, 'Style', 'text', 'String', 'Step 3:', ...
    'HorizontalAlignment', 'center','Units','Normalized', 'position', [.05 .7 .1 .05]);
direct1Txt = uicontrol('Parent', calTab,'Style','text','String','Describe step one here.', ...
    'HorizontalAlignment', 'left','Units','Normalized', 'position', [.2 .9 .3 .05]);
direct2Txt = uicontrol('Parent', calTab,'Style','text','String','Describe step two here.', ...
    'HorizontalAlignment', 'left','Units','Normalized', 'position', [.2 .8 .3 .05]);
direct2Txt = uicontrol('Parent', calTab,'Style','text','String','Describe step three here.', ...
    'HorizontalAlignment', 'left','Units','Normalized', 'position', [.2 .7 .3 .05]);

%Right side display
calButton    = uicontrol('Style','pushbutton', 'Parent', calTab,...
             'String','Calibrate','Units','Normalized', 'Position', [.6 .5 .1 .05]);
acceptButton    = uicontrol('Style','pushbutton', 'Parent', calTab,...
             'String','Accept','Units','Normalized', 'Position', [.6 .4 .1 .05]);
magText4 = uicontrol('Parent', calTab, 'Style', 'text', 'String', 'Current Calibration', 'Fontweight','bold',...
    'HorizontalAlignment', 'center','Units','Normalized', 'position', [.8 .5 .15 .05]);
magText4 = uicontrol('Parent', calTab, 'Style', 'text', 'String', 'Previous Calibration', 'Fontweight','bold',...
    'HorizontalAlignment', 'center','Units','Normalized', 'position', [.8 .3 .15 .05]);
currentCal = uicontrol('Parent', calTab,'Style','text','String','0','HorizontalAlignment', 'right', ...
                'Units','Normalized','position', [.8 .4 .15 .05]);
previousCal = uicontrol('Parent', calTab,'Style','text','String','0','HorizontalAlignment', 'right',...
                'Units','Normalized','position', [.8 .2 .15 .05]);
            

%% Measurement tab controls
pointPanel = uipanel('Parent',measTab','FontSize',12,...
             'BackgroundColor',[.8 .8 .8],...
              'Units', 'Normalized', ...
             'Position',[.0 .0 .2 1]);
mapPanel = uipanel('Parent',measTab','FontSize',12,...
             'BackgroundColor',[.8 .8 .8],...
              'Units', 'Normalized', ...
             'Position',[.2 0 .8 .6]);
         
measPanel = uipanel('Parent',measTab','FontSize',12,...
             'BackgroundColor',[.8 .8 .8],...
             'Units', 'Normalized', ...
             'Position',[.2 .6 .8 .4]);
         
uicontrol('Parent', pointPanel, 'Style', 'text', 'String', 'X Value', ...
    'HorizontalAlignment', 'center','Units','Normalized', 'position', [.05 .875 .25 .05]);

xInput = uicontrol('Parent', pointPanel, 'style','edit',...
            'Units','Normalized','position',[.05 .8 .25 .05]);
        
uicontrol('Parent', pointPanel, 'Style', 'text', 'String', 'Y Value', ...
    'HorizontalAlignment', 'center','Units','Normalized', 'position', [.4 .875 .25 .05]);
        
yInput = uicontrol('Parent', pointPanel, 'style','edit',...
            'Units','Normalized','position',[.4 .8 .25 .05]);
        
uicontrol('Style','pushbutton', 'Parent', pointPanel,...
             'String','TEST','Units','Normalized', 'Position', [.7 .8 .25 .1], 'callback', @test_Callback);
         
      
pointTable = uitable('Parent', pointPanel, 'Units', 'norm', 'Position',...
    [.05 .05 .9 .7], 'ColumnName',{'X', 'Y'},...
    'ColumnFormat', {'bank', 'bank'});

freqTable = uitable('Parent', measPanel, 'Units', 'norm', 'Position',...
    [.05 .25 .9 .5], 'ColumnName', {'63', '125', '250', '500', '1000',...
    '2000', '4000', '8000', '16000'}, ...
    'ColumnFormat', {'numeric', 'numeric', 'numeric', 'numeric', 'numeric','numeric','numeric','numeric','numeric'});

mapPlot = axes('Parent', mapPanel, 'Units', 'Normalized', 'Position',...
    [0.05 0.1 0.9 0.85], 'Visible', 'on');
axis([0 50 0 75])
axis square
box off

         
% Make the UI visible.
set(f, 'visible', 'on')


%% Callbacks
function ninetyfour_Callback(hObject, eventdata)
set(magToggle114,'Value',0)
end


function onefourteen_Callback(hObject, eventdata)
set(magToggle94, 'value', 0)
%swap
end

function swap
if strcmp(get(measTab, 'Visible'),'off')
    set(measTab, 'Visible','on')
    set(calTab, 'Visible','off')
else
    set(measTab, 'Visible','off')
    set(calTab, 'Visible','on')
end  
end



function meah_Callback(hObject, eventdata)
set(measTab, 'Visible','on')
set(calTab, 'Visible','off')
drawnow
end

function calh_Callback(hObject, eventdata)
set(measTab, 'Visible','off')
set(calTab, 'Visible','on')
drawnow
end


 function test_Callback(hObject, eventdata)
x = str2double(get(xInput, 'String'));
y = str2double(get(yInput, 'String'));
% Check coordinate input
if isnan(x)||isnan(y)
    errordlg('Input not formatted properly.', 'Error!')
    return
else
    % Format coordinates and place in table
    x = round(x*100)/100;
    y = round(y*100)/100;
    % Add new row to point list
    oldPoints = get(pointTable,'Data');
    newPoints = [oldPoints; [x y]];
    set(pointTable,'Data',newPoints)
    set(xInput, 'String', [])
    set(yInput, 'String', [])
    % Execute test
    newOctVals = measnoise();
    % Add results to table
    oldOctVals = get(freqTable,'Data');
    newOctVals = [oldOctVals;newOctVals];
    set(freqTable, 'Data', newOctVals)
    % Add point to heatmap
    hold on
    plot(x, y, 'blacko')
    
end


 
 end

end
