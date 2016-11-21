function varargout = jh_finalProjMaskAdjustments_red_forKatrina(varargin)
% JH_FINALPROJMASKADJUSTMENTS2 MATLAB code for jh_finalProjMaskAdjustments2.fig
%      JH_FINALPROJMASKADJUSTMENTS2, by itself, creates a new JH_FINALPROJMASKADJUSTMENTS2 or raises the existing
%      singleton*.
%
%      H = JH_FINALPROJMASKADJUSTMENTS2 returns the handle to a new JH_FINALPROJMASKADJUSTMENTS2 or the handle to
%      the existing singleton*.
%
%      JH_FINALPROJMASKADJUSTMENTS2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in JH_FINALPROJMASKADJUSTMENTS2.M with the given input arguments.
%
%      JH_FINALPROJMASKADJUSTMENTS2('Property','Value',...) creates a new JH_FINALPROJMASKADJUSTMENTS2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before jh_finalProjMaskAdjustments2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to jh_finalProjMaskAdjustments2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help jh_finalProjMaskAdjustments2

% Last Modified by GUIDE v2.5 17-Jan-2015 23:30:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @jh_finalProjMaskAdjustments2_OpeningFcn, ...
                   'gui_OutputFcn',  @jh_finalProjMaskAdjustments2_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT



% --- Executes just before jh_finalProjMaskAdjustments2 is made visible.
%           "Open first images"
function jh_finalProjMaskAdjustments2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to jh_finalProjMaskAdjustments2 (see VARARGIN)

% Choose default command line output for jh_finalProjMaskAdjustments2
handles.output = hObject;

% Show the section image 
load masteralign2
load str/strdata.mat
load str/strmask.mat
% % % load str/red_str_MaskedOutProjections.mat %JH - Removed For Katrina's step

b = pwd;
brain = b(end-5:end);

if ~isfield(projections, 'left')
    projections.left = [];
end
if ~isfield(projections.left, 'red')
    projections.left.red.start = input('What is the FIRST slice with RED projections on the LEFT?');
    projections.left.red.end = input('What is the LAST slice with RED projections on the LEFT?');    
    projections.right.red.start = input('What is the FIRST slice with RED projections on the RIGHT?');
    projections.right.red.end = input('What is the LAST slice with RED projections on the RIGHT?');
    save('str/strdata','projections','-append');
end



if exist(['str/wekaProbMaskRed','_Threshold', num2str(WEKA.threshold.redHigh,'%02i'), '.mat']);   % loading the probability masks
    load (['str/wekaProbMaskRed','_Threshold', num2str(WEKA.threshold.redHigh,'%02i'), '.mat'], 'wekaProbMaskRed');
    wekaProbMaskHigh = wekaProbMaskRed;
    load (['str/wekaProbMaskRed','_Threshold', num2str(WEKA.threshold.redLow,'%02i'),'.mat'], 'wekaProbMaskRed');
    wekaProbMaskLow = wekaProbMaskRed;
    handles.probStatus = 1;   % storing a handle to say whether or not red projections exist for this brain
else
    handles.probStatus = 0;
end

% % % wekaProbMaskLow = wekaProbMaskLow.*~colormask.*strmask; %JH - Removed For Katrina's step
% % % wekaProbMaskHigh = wekaProbMaskHigh.*~colormask.*strmask; %JH - Removed For Katrina's step


masksize = size(strmask);
illum = 2000;

if ~exist('str/red_addmask.mat','file')         %initializing the final additions/subtractions that i will make to the masks
    addmask(2500,3500,strnd-strstrt+1)= false; 
    save('str/red_addmask.mat','addmask')
else
    load str/red_addmask.mat
end

if ~exist('str/red_str_MaskedOutProjections.mat','file')         %initializing the final additions/subtractions that i will make to the masks
    colormask(2500,3500,strnd-strstrt+1)= false; 
    save('str/red_str_MaskedOutProjections.mat','colormask')
else 
    load str/red_str_MaskedOutProjections.mat
end

k= input('which striatum section do you wish to BEGIN with? '); %allows you to input the front and end of projections
if isempty (k)
    k= strstrt;
end

nd= input('which striatum section do you wish to END with? ');
if isempty (nd)
    nd= strnd;
end


set(handles.uipanel2, 'Title', ['Current Section: ',  num2str(k)])  % Displaying the current section number on the GUI
set(handles.checkbox1, 'string', ['High Red Threshold: ', num2str(WEKA.threshold.redHigh)]) % Displaying the low threshold
set(handles.checkbox2, 'string', ['LOW Red Threshold: ', num2str(WEKA.threshold.redLow)]) % Displaying the low threshold
set(handles.edit2, 'string', num2str(projections.left.red.start)); % Displaying the left red projection start
set(handles.edit3, 'string', num2str(projections.left.red.end)); % Displaying the left red projection end
set(handles.edit4, 'string', num2str(projections.right.red.start)); % Displaying the right red projection start
set(handles.edit5, 'string', num2str(projections.right.red.end)); % Displaying the right red projection end

nano=imread(['tiffs/',masteralign(k).name]);

nano(:,:,1)= nano(:,:,1) + uint16(wekaProbMaskLow(:, :, k-strstrt+1))*2^16;   % Plot the low threshold magenta and high white
nano(:,:,2)= nano(:,:,2) + uint16(wekaProbMaskHigh(:, :, k-strstrt+1))*2^16;
nano(:,:,3)= nano(:,:,3) + uint16(wekaProbMaskLow(:, :, k-strstrt+1))*2^16;

set(handles.axes1, 'NextPlot', 'replacechildren')
axes(handles.axes1)
nano(:, :, 3) = nano(:, :, 3)*0.5 + uint16(addmask(:,:,k-strstrt+1))*illum;   % plot addmask as blue shaded area
imshow(nano*3)
xlim([firstC lastC])
ylim([firstR lastR])
text(firstC +100,firstR +100,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');

hold on     % This will plot the striatum mask outline on the image 
outline = h_getNucleusOutline(strmask(:,:,k-strstrt+1));
for j = 1:length(outline)
    plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',1)
end

            % This will plot the colormask outline on the image 
subOutline = h_getNucleusOutline(colormask(:,:,k-strstrt+1));
for j = 1:length(subOutline)
    plot((subOutline{j}(:,2)), (subOutline{j}(:,1))+0.5, 'k--', 'linewidth',2)
end

            % This will plot addmask outline on the image
addOutline = h_getNucleusOutline(addmask(:,:,k-strstrt+1));      
for j = 1:length(addOutline)
    plot((addOutline{j}(:,2)), (addOutline{j}(:,1))+0.5, 'r--', 'linewidth',2)
end
hold off

% Then show a little thumbnail of the probability image with a jet colorbar (RED)
if exist(['str/WEKAoutput/probabilities_maskedStr_red_', num2str(k), '.tif'])
    probImgR= imread(['str/WEKAoutput/probabilities_maskedStr_red_', num2str(k), '.tif'],1);
    set(handles.axes2, 'NextPlot', 'replacechildren')
    axes(handles.axes2)
    imshow(probImgR)
    colormap('jet');
    colorbar
    axis image
    text(100,100,'RED','Color','w');
else
    placeholder = zeros([2500 3500]);
    set(handles.axes2, 'NextPlot', 'replacechildren')
    axes(handles.axes2)
    imshow(placeholder)
    colormap('jet');
    text(1000,1000,'No RED Probability Image','Color','w');
end
% Then show a little thumbnail of the probability image with a jet colorbar (GREEN)
if exist(['str/WEKAoutput/probabilities_maskedStr_green_', num2str(k), '.tif'])
    probImgG= imread(['str/WEKAoutput/probabilities_maskedStr_green_', num2str(k), '.tif'],1);
    set(handles.axes4, 'NextPlot', 'replacechildren')
    axes(handles.axes4)
    imshow(probImgG)
    colormap('jet');
    colorbar
    axis image
    text(100,100,'GREEN','Color','w');
else
    placeholder = zeros(2500, 4300);
    set(handles.axes4, 'NextPlot', 'replacechildren')
    axes(handles.axes4)
    imshow(placeholder)
    colormap('jet');
    text(1000,1000,'No GREEN Probability Image','Color','w');
end


%Start be setting all viewing handles off with placeholder thresholds
handles.section = k;
handles.lastsection = nd;

handles.HighThresh= WEKA.threshold.redHigh;
handles.LowThresh = WEKA.threshold.redLow;
handles.HighMask= wekaProbMaskHigh;
handles.LowMask = wekaProbMaskLow;
handles.strmask = strmask;
handles.brain = brain;

handles.addmask = addmask; 
handles.colormask = colormask; 
handles.viewResult = 0;

% Create a variabe in strdata that lists if a slice should be skipped and why (checkboxxes 4-9 will set it to 1)
if ~exist('sliceDamage', 'var')
    for i = 1:length(masteralign)
        sliceDamage(i).left.index = 0;
        sliceDamage(i).right.index = 0;
        sliceDamage(i).left.reason = 0; % 1: missing/torn
        sliceDamage(i).right.reason = 0;
        sliceDamage(i).flip = 0;
        sliceDamage(i).projSkip = 0;
    end
end
if ~isfield(sliceDamage, 'projSkip')
    for i = 1:length(masteralign)
        sliceDamage(i).projSkip = 0;
    end
end

if sliceDamage(k).left.reason == 0;
    set(handles.checkbox4,'Value',0); % missing/torn Checkbox OFF
    set(handles.checkbox5,'Value',0); % squished Checkbox OFF
    set(handles.checkbox6,'Value',0); % tissue issue Checkbox OFF
elseif sliceDamage(k).left.reason == 1;
    set(handles.checkbox4,'Value',1); % missing/torn Checkbox ON
    set(handles.checkbox5,'Value',0); % squished Checkbox OFF
    set(handles.checkbox6,'Value',0); % tissue issue Checkbox OFF
elseif sliceDamage(k).left.reason == 2;
    set(handles.checkbox4,'Value',0); % missing/torn Checkbox OFF
    set(handles.checkbox5,'Value',1); % squished Checkbox ON
    set(handles.checkbox6,'Value',0); % tissue issue Checkbox OFF
elseif sliceDamage(k).left.reason == 3;
    set(handles.checkbox4,'Value',0); % missing/torn Checkbox OFF
    set(handles.checkbox5,'Value',0); % squished Checkbox OFF
    set(handles.checkbox6,'Value',1); % tissue issue Checkbox ON
else
    display(['The damage state of section ', num2str(k), ' left is confused'])
end
if sliceDamage(k).right.reason == 0;
    set(handles.checkbox7,'Value',0); % missing/torn Checkbox OFF
    set(handles.checkbox8,'Value',0); % squished Checkbox OFF
    set(handles.checkbox9,'Value',0); % tissue issue Checkbox OFF
elseif sliceDamage(k).right.reason == 1;
    set(handles.checkbox7,'Value',1); % missing/torn Checkbox ON
    set(handles.checkbox8,'Value',0); % squished Checkbox OFF
    set(handles.checkbox9,'Value',0); % tissue issue Checkbox OFF
elseif sliceDamage(k).right.reason == 2;
    set(handles.checkbox7,'Value',0); % missing/torn Checkbox OFF
    set(handles.checkbox8,'Value',1); % squished Checkbox ON
    set(handles.checkbox9,'Value',0); % tissue issue Checkbox OFF
elseif sliceDamage(k).right.reason == 3;
    set(handles.checkbox7,'Value',0); % missing/torn Checkbox OFF
    set(handles.checkbox8,'Value',0); % squished Checkbox OFF
    set(handles.checkbox9,'Value',1); % tissue issue Checkbox ON
else
    display(['The damage state of section ', num2str(k), ' right is confused'])
end
if sliceDamage(k).flip == 1;
    set(handles.checkbox10,'Value',1); % Flip Checkbox ON
else
    set(handles.checkbox10,'Value',0); % Flip Checkbox OFF
end
if sliceDamage(k).projSkip == 1;
    set(handles.checkbox11,'Value',1); % Flip Checkbox ON
else 
    set(handles.checkbox11,'Value',0); % Flip Checkbox OFF
end
handles.sliceDamage = sliceDamage;


% By default start saving the low threshold as the one to use (unless checkbox 2 overrides it)
if ~isfield(WEKA, 'thresholdBySlice')
    WEKA.thresholdBySlice = [];
end
if ~isfield(WEKA.thresholdBySlice, 'red')
    WEKA.thresholdBySlice.red = zeros(1, length(masteralign));
    WEKA.thresholdBySlice.red(:) = WEKA.threshold.redLow;
end
if WEKA.thresholdBySlice.red(k) == handles.LowThresh;
    set(handles.checkbox2,'Value',1); % Low Threshold Checkbox ON
    set(handles.checkbox1,'Value',0); % High Threshold Checkbox OFF
elseif WEKA.thresholdBySlice.red(k) == handles.HighThresh;
    set(handles.checkbox2,'Value',0); % Low Threshold Checkbox OFF
    set(handles.checkbox1,'Value',1); % High Threshold Checkbox ON
else
    display(['The threshold set to use for section ', num2str(k), ' doesnt match either the high or low threshold chose'])
end
handles.thresholdBySlice = WEKA.thresholdBySlice.red;
save('str/strdata','WEKA', '-append')

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes jh_finalProjMaskAdjustments2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = jh_finalProjMaskAdjustments2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1. 
%               "ADD to projmask"
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
k = handles.section;
load masteralign2
load str/strdata.mat

strmask = handles.strmask;
addmask = handles.addmask; 
colormask = handles.colormask; 
wekaProbMaskHigh = handles.HighMask;
wekaProbMaskLow = handles.LowMask;


illum=2000; % this sets the illumination level of the masked area.. so change it if you don't like it.
        
nano=imread(['tiffs/',masteralign(k).name]);
set(handles.axes1, 'NextPlot', 'replacechildren')
axes(handles.axes1)

roi1= imfreehand(gca);
roiapi=iptgetapi(roi1);
roipoints= roiapi.getPosition();
selection= roipoly(nano, roipoints(:,1), roipoints(:,2));
addmask(:,:,k-strstrt+1)= addmask(:,:,k-strstrt+1)+selection;

delete(roi1)

nano(:,:,3)= nano(:,:,3)*0.5 + uint16(addmask(:,:,k-strstrt+1))*illum;   % plot addmask as blue shaded area

handles.addmask = addmask; 

nano(:,:,1)= nano(:,:,1) + uint16(wekaProbMaskLow(:, :, k-strstrt+1))*2^16;   % Plot the low threshold magenta and high white
nano(:,:,2)= nano(:,:,2) + uint16(wekaProbMaskHigh(:, :, k-strstrt+1))*2^16;
nano(:,:,3)= nano(:,:,3) + uint16(wekaProbMaskLow(:, :, k-strstrt+1))*2^16;

imshow(nano*3)
xlim([firstC lastC])
ylim([firstR lastR])
text(firstC +100,firstR +100,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');


hold on     % This will plot the striatum mask outline on the image 
outline = h_getNucleusOutline(strmask(:,:,k-strstrt+1));
for j = 1:length(outline)
    plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',1)
end

            % This will plot the colormask outline on the image 
subOutline = h_getNucleusOutline(colormask(:,:,k-strstrt+1));
for j = 1:length(subOutline)
    plot((subOutline{j}(:,2)), (subOutline{j}(:,1))+0.5, 'k--', 'linewidth',2)
end

            % This will plot the add mask outline on the image 
addOutline = h_getNucleusOutline(addmask(:,:,k-strstrt+1));
for j = 1:length(addOutline)
    plot((addOutline{j}(:,2)), (addOutline{j}(:,1))+0.5, 'r--', 'linewidth',2)
end

hold off

guidata(hObject,handles);       %%% This is super important: you have to do this after updating a handle or it wont save!




% --- Executes on button press in pushbutton2. 
%           "SUBTRACT from projmask"
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
k = handles.section;
load masteralign2
load str/strdata.mat


strmask = handles.strmask;
addmask = handles.addmask; 
colormask = handles.colormask; 
wekaProbMaskHigh = handles.HighMask;
wekaProbMaskLow = handles.LowMask;

illum=2000; % this sets the illumination level of the masked area.. so change it if you don't like it.
        
nano=imread(['tiffs/',masteralign(k).name]);
set(handles.axes1, 'NextPlot', 'replacechildren')
axes(handles.axes1)


roi1= imfreehand(gca);
roiapi=iptgetapi(roi1);
roipoints= roiapi.getPosition();
selection= roipoly(nano, roipoints(:,1), roipoints(:,2));
addmask(:,:,k-strstrt+1)= addmask(:,:,k-strstrt+1).*~selection;
delete(roi1)

nano(:,:,3)= nano(:,:,3)*0.5 + uint16(addmask(:,:,k-strstrt+1))*illum;   % plot addmask as blue shaded area

handles.addmask = addmask; 

nano(:,:,1)= nano(:,:,1) + uint16(wekaProbMaskLow(:, :, k-strstrt+1))*2^16;   % Plot the low threshold magenta and high white
nano(:,:,2)= nano(:,:,2) + uint16(wekaProbMaskHigh(:, :, k-strstrt+1))*2^16;
nano(:,:,3)= nano(:,:,3) + uint16(wekaProbMaskLow(:, :, k-strstrt+1))*2^16;

imshow(nano*3)
xlim([firstC lastC])
ylim([firstR lastR])
text(firstC +100,firstR +100,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');


hold on     % This will plot the striatum mask outline on the image 
outline = h_getNucleusOutline(strmask(:,:,k-strstrt+1));
for j = 1:length(outline)
    plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',1)
end

            % This will plot the colormask outline on the image 
subOutline = h_getNucleusOutline(colormask(:,:,k-strstrt+1));
for j = 1:length(subOutline)
    plot((subOutline{j}(:,2)), (subOutline{j}(:,1))+0.5, 'k--', 'linewidth',2)
end

            % This will plot the add mask outline on the image 
addOutline = h_getNucleusOutline(addmask(:,:,k-strstrt+1));
for j = 1:length(addOutline)
    plot((addOutline{j}(:,2)), (addOutline{j}(:,1))+0.5, 'r--', 'linewidth',2)
end

hold off

guidata(hObject,handles); 


% --- Executes on button press in pushbutton3.
%        "SAVE and move to NEXT SECTION"
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

k = handles.section + 1;
handles.section = k;

load masteralign2
load str/strdata.mat

set(handles.uipanel2, 'Title', ['Current Section: ',  num2str(k)])  % Displaying the current section number on the GUI

strmask = handles.strmask;
addmask = handles.addmask; 
colormask = handles.colormask; 
wekaProbMaskHigh = handles.HighMask;
wekaProbMaskLow = handles.LowMask;

if k > strnd
    save('str/red_addmask.mat', 'addmask')
    save('str/red_str_MaskedOutProjections.mat', 'colormask') %Save up here, so if there is an error in the slice number it saves first!
    c = clock;
    display(['*****SAVED addmask and submask(colormask) on section ', num2str(handles.section), ' of ', handles.brain, ' at: ', (datestr(datenum(c(1),c(2),c(3),c(4),c(5),c(6))))]);
end

% Set the Threshold checkboxes
WEKA.thresholdBySlice.red = handles.thresholdBySlice;
if WEKA.thresholdBySlice.red(k) == handles.HighThresh 
    set(handles.checkbox1,'Value',1); % Turn the HIGH Threshold Checkbox ON
    set(handles.checkbox2,'Value',0); % Turn the LOW Threshold Checkbox OFF
elseif WEKA.thresholdBySlice.red(k) == handles.LowThresh 
    set(handles.checkbox1,'Value',0); % Turn the HIGH Threshold Checkbox OFF
    set(handles.checkbox2,'Value',1); % Turn the LOW Threshold Checkbox ON
else
    display(['The threshold set to use for section ', num2str(k), ' doesnt match either the high or low threshold chosed'])
end


% Set the Slice Damage checkboxes
sliceDamage = handles.sliceDamage;
if sliceDamage(k).left.reason == 0;
    set(handles.checkbox4,'Value',0); % missing/torn Checkbox OFF
    set(handles.checkbox5,'Value',0); % squished Checkbox OFF
    set(handles.checkbox6,'Value',0); % tissue issue Checkbox OFF
elseif sliceDamage(k).left.reason == 1;
    set(handles.checkbox4,'Value',1); % missing/torn Checkbox ON
    set(handles.checkbox5,'Value',0); % squished Checkbox OFF
    set(handles.checkbox6,'Value',0); % tissue issue Checkbox OFF
elseif sliceDamage(k).left.reason == 2;
    set(handles.checkbox4,'Value',0); % missing/torn Checkbox OFF
    set(handles.checkbox5,'Value',1); % squished Checkbox ON
    set(handles.checkbox6,'Value',0); % tissue issue Checkbox OFF
elseif sliceDamage(k).left.reason == 3;
    set(handles.checkbox4,'Value',0); % missing/torn Checkbox OFF
    set(handles.checkbox5,'Value',0); % squished Checkbox OFF
    set(handles.checkbox6,'Value',1); % tissue issue Checkbox ON
else
    display(['The damage state of section ', num2str(k), ' left is confused'])
end
if sliceDamage(k).right.reason == 0;
    set(handles.checkbox7,'Value',0); % missing/torn Checkbox OFF
    set(handles.checkbox8,'Value',0); % squished Checkbox OFF
    set(handles.checkbox9,'Value',0); % tissue issue Checkbox OFF
elseif sliceDamage(k).right.reason == 1;
    set(handles.checkbox7,'Value',1); % missing/torn Checkbox ON
    set(handles.checkbox8,'Value',0); % squished Checkbox OFF
    set(handles.checkbox9,'Value',0); % tissue issue Checkbox OFF
elseif sliceDamage(k).right.reason == 2;
    set(handles.checkbox7,'Value',0); % missing/torn Checkbox OFF
    set(handles.checkbox8,'Value',1); % squished Checkbox ON
    set(handles.checkbox9,'Value',0); % tissue issue Checkbox OFF
elseif sliceDamage(k).right.reason == 3;
    set(handles.checkbox7,'Value',0); % missing/torn Checkbox OFF
    set(handles.checkbox8,'Value',0); % squished Checkbox OFF
    set(handles.checkbox9,'Value',1); % tissue issue Checkbox ON
else
    display(['The damage state of section ', num2str(k), ' right is confused'])
end
if sliceDamage(k).flip == 1;
    set(handles.checkbox10,'Value',1); % Flip Checkbox ON
else
    set(handles.checkbox10,'Value',0); % Flip Checkbox OFF
end
if sliceDamage(k).projSkip == 1;
    set(handles.checkbox11,'Value',1); % Flip Checkbox ON
else 
    set(handles.checkbox11,'Value',0); % Flip Checkbox OFF
end

% Then show a little thumbnail of the probability image with a jet colorbar (RED)
if exist(['str/WEKAoutput/probabilities_maskedStr_red_', num2str(k), '.tif'])
    probImgR= imread(['str/WEKAoutput/probabilities_maskedStr_red_', num2str(k), '.tif'],1);
    set(handles.axes2, 'NextPlot', 'replacechildren')
    axes(handles.axes2)
    imshow(probImgR)
    colormap('jet');
    colorbar
    axis image
    text(100,100,'RED','Color','w');
else
    placeholder = zeros([2500 3500]);
    set(handles.axes2, 'NextPlot', 'replacechildren')
    axes(handles.axes2)
    imshow(placeholder)
    colormap('jet');
    text(1000,1000,'No RED Probability Image','Color','w');
end
% Then show a little thumbnail of the probability image with a jet colorbar (GREEN)
if exist(['str/WEKAoutput/probabilities_maskedStr_green_', num2str(k), '.tif'])
    probImgG= imread(['str/WEKAoutput/probabilities_maskedStr_green_', num2str(k), '.tif'],1);
    set(handles.axes4, 'NextPlot', 'replacechildren')
    axes(handles.axes4)
    imshow(probImgG)
    colormap('jet');
    colorbar
    axis image
    text(100,100,'GREEN','Color','w');
else
    placeholder = zeros(2500, 4300);
    set(handles.axes4, 'NextPlot', 'replacechildren')
    axes(handles.axes4)
    imshow(placeholder)
    colormap('jet');
    text(1000,1000,'No GREEN Probability Image','Color','w');
end

illum=2000; % this sets the illumination level of the masked area.. so change it if you don't like it.
        

nano=imread(['tiffs/',masteralign(k).name]);
set(handles.axes1, 'NextPlot', 'replacechildren')
axes(handles.axes1)

nano(:,:,3)= nano(:,:,3)*0.5 + uint16(addmask(:,:,k-strstrt+1))*illum;   % plot addmask as blue shaded area

nano(:,:,1)= nano(:,:,1) + uint16(wekaProbMaskLow(:, :, k-strstrt+1))*2^16;   % Plot the low threshold magenta and high white
nano(:,:,2)= nano(:,:,2) + uint16(wekaProbMaskHigh(:, :, k-strstrt+1))*2^16;
nano(:,:,3)= nano(:,:,3) + uint16(wekaProbMaskLow(:, :, k-strstrt+1))*2^16;

imshow(nano*3)
xlim([firstC lastC])
ylim([firstR lastR])
text(firstC +100,firstR +100,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');


hold on     % This will plot the striatum mask outline on the image 
outline = h_getNucleusOutline(strmask(:,:,k-strstrt+1));
for j = 1:length(outline)
    plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',1)
end

            % This will plot the colormask outline on the image 
subOutline = h_getNucleusOutline(colormask(:,:,k-strstrt+1));
for j = 1:length(subOutline)
    plot((subOutline{j}(:,2)), (subOutline{j}(:,1))+0.5, 'k--', 'linewidth',2)
end

            % This will plot the add mask outline on the image 
addOutline = h_getNucleusOutline(addmask(:,:,k-strstrt+1));
for j = 1:length(addOutline)
    plot((addOutline{j}(:,2)), (addOutline{j}(:,1))+0.5, 'r--', 'linewidth',2)
end

hold off



% 
% save('str/red_addmask.mat', 'addmask')
% save('str/red_str_MaskedOutProjections.mat', 'colormask')
% save('str/strdata','WEKA', '-append')


guidata(hObject,handles);       %%% This is super important: you have to do this after updating a handle or it wont save!




%   Executes "Edit Text" box and will move to the given section***
%        this will update: Text2 and Panel 2
function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

k = get(handles.edit1, 'string');
k = str2num(k);

load masteralign2
load str/strdata.mat

handles.section = k;
set(handles.uipanel2, 'Title', ['Current Section: ',  num2str(k)])  % Displaying the current section number on the GUI

strmask = handles.strmask;
addmask = handles.addmask; 
colormask = handles.colormask; 
wekaProbMaskHigh = handles.HighMask;
wekaProbMaskLow = handles.LowMask;

if k < strstrt || k > strnd
    save('str/red_addmask.mat', 'addmask')
    save('str/red_str_MaskedOutProjections.mat', 'colormask') %Save up here, so if there is an error in the slice number it saves first!
    c = clock;
    display(['*****SAVED addmask and submask(colormask) on section ', num2str(handles.section), ' of ', handles.brain, ' at: ', (datestr(datenum(c(1),c(2),c(3),c(4),c(5),c(6))))]);
end

% Set the Treshold checkboxes
WEKA.thresholdBySlice.red = handles.thresholdBySlice;
if WEKA.thresholdBySlice.red(k) == handles.HighThresh 
    set(handles.checkbox1,'Value',1); % Turn the HIGH Threshold Checkbox ON
    set(handles.checkbox2,'Value',0); % Turn the LOW Threshold Checkbox OFF
elseif WEKA.thresholdBySlice.red(k) == handles.LowThresh 
    set(handles.checkbox1,'Value',0); % Turn the HIGH Threshold Checkbox OFF
    set(handles.checkbox2,'Value',1); % Turn the LOW Threshold Checkbox ON
else
    display(['The threshold set to use for section ', num2str(k), ' doesnt match either the high or low threshold chosed'])
end

% Set the Slice Damage checkboxes
sliceDamage = handles.sliceDamage;
if sliceDamage(k).left.reason == 0;
    set(handles.checkbox4,'Value',0); % missing/torn Checkbox OFF
    set(handles.checkbox5,'Value',0); % squished Checkbox OFF
    set(handles.checkbox6,'Value',0); % tissue issue Checkbox OFF
elseif sliceDamage(k).left.reason == 1;
    set(handles.checkbox4,'Value',1); % missing/torn Checkbox ON
    set(handles.checkbox5,'Value',0); % squished Checkbox OFF
    set(handles.checkbox6,'Value',0); % tissue issue Checkbox OFF
elseif sliceDamage(k).left.reason == 2;
    set(handles.checkbox4,'Value',0); % missing/torn Checkbox OFF
    set(handles.checkbox5,'Value',1); % squished Checkbox ON
    set(handles.checkbox6,'Value',0); % tissue issue Checkbox OFF
elseif sliceDamage(k).left.reason == 3;
    set(handles.checkbox4,'Value',0); % missing/torn Checkbox OFF
    set(handles.checkbox5,'Value',0); % squished Checkbox OFF
    set(handles.checkbox6,'Value',1); % tissue issue Checkbox ON
else
    display(['The damage state of section ', num2str(k), ' left is confused'])
end
if sliceDamage(k).right.reason == 0;
    set(handles.checkbox7,'Value',0); % missing/torn Checkbox OFF
    set(handles.checkbox8,'Value',0); % squished Checkbox OFF
    set(handles.checkbox9,'Value',0); % tissue issue Checkbox OFF
elseif sliceDamage(k).right.reason == 1;
    set(handles.checkbox7,'Value',1); % missing/torn Checkbox ON
    set(handles.checkbox8,'Value',0); % squished Checkbox OFF
    set(handles.checkbox9,'Value',0); % tissue issue Checkbox OFF
elseif sliceDamage(k).right.reason == 2;
    set(handles.checkbox7,'Value',0); % missing/torn Checkbox OFF
    set(handles.checkbox8,'Value',1); % squished Checkbox ON
    set(handles.checkbox9,'Value',0); % tissue issue Checkbox OFF
elseif sliceDamage(k).right.reason == 3;
    set(handles.checkbox7,'Value',0); % missing/torn Checkbox OFF
    set(handles.checkbox8,'Value',0); % squished Checkbox OFF
    set(handles.checkbox9,'Value',1); % tissue issue Checkbox ON
else
    display(['The damage state of section ', num2str(k), ' right is confused'])
end
if sliceDamage(k).flip == 1;
    set(handles.checkbox10,'Value',1); % Flip Checkbox ON
else
    set(handles.checkbox10,'Value',0); % Flip Checkbox OFF
end
if sliceDamage(k).projSkip == 1;
    set(handles.checkbox11,'Value',1); % Flip Checkbox ON
else 
    set(handles.checkbox11,'Value',0); % Flip Checkbox OFF
end

% Then show a little thumbnail of the probability image with a jet colorbar (RED)
if exist(['str/WEKAoutput/probabilities_maskedStr_red_', num2str(k), '.tif'])
    probImgR= imread(['str/WEKAoutput/probabilities_maskedStr_red_', num2str(k), '.tif'],1);
    set(handles.axes2, 'NextPlot', 'replacechildren')
    axes(handles.axes2)
    imshow(probImgR)
    colormap('jet');
    colorbar
    axis image
    text(100,100,'RED','Color','w');
else
    placeholder = zeros([2500 3500]);
    set(handles.axes2, 'NextPlot', 'replacechildren')
    axes(handles.axes2)
    imshow(placeholder)
    colormap('jet');
    text(1000,1000,'No RED Probability Image','Color','w');
end
% Then show a little thumbnail of the probability image with a jet colorbar (GREEN)
if exist(['str/WEKAoutput/probabilities_maskedStr_green_', num2str(k), '.tif'])
    probImgG= imread(['str/WEKAoutput/probabilities_maskedStr_green_', num2str(k), '.tif'],1);
    set(handles.axes4, 'NextPlot', 'replacechildren')
    axes(handles.axes4)
    imshow(probImgG)
    colormap('jet');
    colorbar
    axis image
    text(100,100,'GREEN','Color','w');
else
    placeholder = zeros(2500, 4300);
    set(handles.axes4, 'NextPlot', 'replacechildren')
    axes(handles.axes4)
    imshow(placeholder)
    colormap('jet');
    text(1000,1000,'No GREEN Probability Image','Color','w');
end


illum=2000; % this sets the illumination level of the masked area.. so change it if you don't like it.
     
nano=imread(['tiffs/',masteralign(k).name]);
set(handles.axes1, 'NextPlot', 'replacechildren')
axes(handles.axes1)

nano(:,:,3)= nano(:,:,3)*0.5 + uint16(addmask(:,:,k-strstrt+1))*illum;   % plot addmask as blue shaded area

nano(:,:,1)= nano(:,:,1) + uint16(wekaProbMaskLow(:, :, k-strstrt+1))*2^16;   % Plot the low threshold magenta and high white
nano(:,:,2)= nano(:,:,2) + uint16(wekaProbMaskHigh(:, :, k-strstrt+1))*2^16;
nano(:,:,3)= nano(:,:,3) + uint16(wekaProbMaskLow(:, :, k-strstrt+1))*2^16;

imshow(nano*3)
xlim([firstC lastC])
ylim([firstR lastR])
text(firstC +100,firstR +100,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');


hold on     % This will plot the striatum mask outline on the image 
outline = h_getNucleusOutline(strmask(:,:,k-strstrt+1));
for j = 1:length(outline)
    plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',1)
end

            % This will plot the colormask outline on the image 
subOutline = h_getNucleusOutline(colormask(:,:,k-strstrt+1));
for j = 1:length(subOutline)
    plot((subOutline{j}(:,2)), (subOutline{j}(:,1))+0.5, 'k--', 'linewidth',2)
end

            % This will plot the add mask outline on the image 
addOutline = h_getNucleusOutline(addmask(:,:,k-strstrt+1));
for j = 1:length(addOutline)
    plot((addOutline{j}(:,2)), (addOutline{j}(:,1))+0.5, 'r--', 'linewidth',2)
end
hold off



% save('str/red_addmask.mat', 'addmask')
% save('str/red_str_MaskedOutProjections.mat', 'colormask')
% save('str/strdata','WEKA', '-append')

guidata(hObject,handles);       %%% This is super important: you have to do this after updating a handle or it wont save!


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
%           SAVE addmask
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

addmask = handles.addmask;
save('str/red_addmask.mat', 'addmask')
    c = clock;
    display(['*****SAVED addmask on section ', num2str(handles.section), ' of ', handles.brain, ' at: ', (datestr(datenum(c(1),c(2),c(3),c(4),c(5),c(6))))]);


% --- Executes on button press in pushbutton5.
%           Subtract from colormask
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

k = handles.section;
load masteralign2
load str/strdata.mat

strmask = handles.strmask;
addmask = handles.addmask; 
colormask = handles.colormask; 
wekaProbMaskHigh = handles.HighMask;
wekaProbMaskLow = handles.LowMask;

illum=2000; % this sets the illumination level of the masked area.. so change it if you don't like it.
        
nano=imread(['tiffs/',masteralign(k).name]);
set(handles.axes1, 'NextPlot', 'replacechildren')
axes(handles.axes1)


roi1= imfreehand(gca);
roiapi=iptgetapi(roi1);
roipoints= roiapi.getPosition();
selection= roipoly(nano, roipoints(:,1), roipoints(:,2));
colormask(:,:,k-strstrt+1)= colormask(:,:,k-strstrt+1).*~selection;
delete(roi1)

nano(:,:,3)= nano(:,:,3)*0.5 + uint16(addmask(:,:,k-strstrt+1))*illum;  % plot addmask as blue shaded area

handles.colormask = colormask; 

nano(:,:,1)= nano(:,:,1) + uint16(wekaProbMaskLow(:, :, k-strstrt+1))*2^16;   % Plot the low threshold magenta and high white
nano(:,:,2)= nano(:,:,2) + uint16(wekaProbMaskHigh(:, :, k-strstrt+1))*2^16;
nano(:,:,3)= nano(:,:,3) + uint16(wekaProbMaskLow(:, :, k-strstrt+1))*2^16;

imshow(nano*3)
xlim([firstC lastC])
ylim([firstR lastR])
text(firstC +100,firstR +100,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');


hold on     % This will plot the striatum mask outline on the image 
outline = h_getNucleusOutline(strmask(:,:,k-strstrt+1));
for j = 1:length(outline)
    plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',1)
end

            % This will plot the colormask outline on the image 
subOutline = h_getNucleusOutline(colormask(:,:,k-strstrt+1));
for j = 1:length(subOutline)
    plot((subOutline{j}(:,2)), (subOutline{j}(:,1))+0.5, 'k--', 'linewidth',2)
end

            % This will plot the add mask outline on the image 
addOutline = h_getNucleusOutline(addmask(:,:,k-strstrt+1));
for j = 1:length(addOutline)
    plot((addOutline{j}(:,2)), (addOutline{j}(:,1))+0.5, 'r--', 'linewidth',2)
end

hold off

guidata(hObject,handles); 


% --- Executes on button press in pushbutton6.
%           SAVE colormask
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

colormask = handles.colormask;
save('str/red_str_MaskedOutProjections.mat', 'colormask')
c = clock;
    display(['*****SAVED submask(colormask) on section ', num2str(handles.section), ' of ', handles.brain, ' at: ', (datestr(datenum(c(1),c(2),c(3),c(4),c(5),c(6))))]);


% --- Executes on button press in pushbutton7.
%           ADD to colormask
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

k = handles.section;
load masteralign2
load str/strdata.mat

strmask = handles.strmask;
colormask = handles.colormask; 
addmask = handles.addmask; 
wekaProbMaskHigh = handles.HighMask;
wekaProbMaskLow = handles.LowMask;

illum=2000; % this sets the illumination level of the masked area.. so change it if you don't like it.
        
nano=imread(['tiffs/',masteralign(k).name]);
set(handles.axes1, 'NextPlot', 'replacechildren')
axes(handles.axes1)



roi1= imfreehand(gca);
roiapi=iptgetapi(roi1);
roipoints= roiapi.getPosition();
selection= roipoly(nano, roipoints(:,1), roipoints(:,2));
colormask(:,:,k-strstrt+1)= colormask(:,:,k-strstrt+1)+selection;

delete(roi1)

nano(:,:,3)= nano(:,:,3)*0.5 + uint16(addmask(:,:,k-strstrt+1))*illum; % plot addmask as blue shaded area

handles.colormask = colormask; 

nano(:,:,1)= nano(:,:,1) + uint16(wekaProbMaskLow(:, :, k-strstrt+1))*2^16;   % Plot the low threshold magenta and high white
nano(:,:,2)= nano(:,:,2) + uint16(wekaProbMaskHigh(:, :, k-strstrt+1))*2^16;
nano(:,:,3)= nano(:,:,3) + uint16(wekaProbMaskLow(:, :, k-strstrt+1))*2^16;

imshow(nano*3)
xlim([firstC lastC])
ylim([firstR lastR])
text(firstC +100,firstR +100,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');


hold on     % This will plot the striatum mask outline on the image 
outline = h_getNucleusOutline(strmask(:,:,k-strstrt+1));
for j = 1:length(outline)
    plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',1)
end

            % This will plot addmask outline on the image 
addOutline = h_getNucleusOutline(addmask(:,:,k-strstrt+1));     
for j = 1:length(addOutline)
    plot((addOutline{j}(:,2)), (addOutline{j}(:,1))+0.5, 'r--', 'linewidth',2)
end

            % This will plot the colormask outline on the image 
subOutline = h_getNucleusOutline(colormask(:,:,k-strstrt+1));
for j = 1:length(subOutline)
    plot((subOutline{j}(:,2)), (subOutline{j}(:,1))+0.5, 'k--', 'linewidth',2)
end

hold off

guidata(hObject,handles);       %%% This is super important: you have to do this after updating a handle or it wont save!


% --- Executes on button press in checkbox1.
          % High Threshold Checkbox %
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load str/strdata.mat
k = handles.section;
WEKA.thresholdBySlice.red = handles.thresholdBySlice;

if get(hObject,'Value') == 1  % If HIGH Threshold Checkbox is turned ON
    set(handles.checkbox2,'Value',0); % Turn LOW Threshold Checkbox OFF
    WEKA.thresholdBySlice.red(k) = handles.HighThresh;
else   % If HIGH Threshold Checkbox is turned OFF
    set(handles.checkbox2,'Value',1); % Turn LOW Threshold Checkbox ON
    WEKA.thresholdBySlice.red(k) = handles.LowThresh;
end

handles.thresholdBySlice = WEKA.thresholdBySlice.red;
save('str/strdata','WEKA', '-append')

guidata(hObject,handles);       %%% This is super important: you have to do this after updating a handle or it wont save!
% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2.
          % Low Threshold Checkbox %
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load str/strdata.mat
k = handles.section;
WEKA.thresholdBySlice.red = handles.thresholdBySlice;

if get(hObject,'Value') == 1  % If LOW Threshold Checkbox is turned ON
    set(handles.checkbox1,'Value',0); % Turn HIGH Threshold Checkbox OFF
    WEKA.thresholdBySlice.red(k) = handles.LowThresh;
else   % If LOW Threshold Checkbox is turned OFF
    set(handles.checkbox1,'Value',1); % Turn HIGH Threshold Checkbox ON
    WEKA.thresholdBySlice.red(k) = handles.HighThresh;
end

handles.thresholdBySlice = WEKA.thresholdBySlice.red;
save('str/strdata','WEKA', '-append')

guidata(hObject,handles);       %%% This is super important: you have to do this after updating a handle or it wont save!
% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox3.
%            "VIEW RESULT" Checkbox
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

k = handles.section;
load masteralign2
load str/strdata.mat
WEKA.thresholdBySlice.red = handles.thresholdBySlice;
strmask = handles.strmask;
addmask = handles.addmask; 
colormask = handles.colormask; 
wekaProbMaskHigh = handles.HighMask;
wekaProbMaskLow = handles.LowMask;
illum=2000; % this sets the illumination level of the masked area.. so change it if you don't like it.


if get(hObject,'Value') == 1  % If "View Result" checkbox is turned ON
    
    nano=imread(['tiffs/',masteralign(k).name]);
    set(handles.axes1, 'NextPlot', 'replacechildren')
    axes(handles.axes1)
    hold on
    
    if WEKA.thresholdBySlice.red(k) == WEKA.threshold.redHigh;
        
        wekaProbMaskHigh_Final = logical(wekaProbMaskHigh(:, :, k-strstrt+1).*~colormask(:, :, k-strstrt+1) + addmask(:, :, k-strstrt+1));

        nano(:,:,3)= nano(:,:,3)*0.5 + uint16(wekaProbMaskHigh_Final)*illum;   % plot addmask as blue shaded area
        imshow(nano*3)
        xlim([firstC lastC])
        ylim([firstR lastR])
        text(firstC +100,firstR +100,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');

        outline = h_getNucleusOutline(wekaProbMaskHigh_Final);
        for j = 1:length(outline)
            plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w--', 'linewidth',1)
        end
    elseif WEKA.thresholdBySlice.red(k) == WEKA.threshold.redLow;
        
        wekaProbMaskLow_Final = logical(wekaProbMaskLow(:, :, k-strstrt+1).*~colormask(:, :, k-strstrt+1) + addmask(:, :, k-strstrt+1));
        
        nano(:,:,3)= nano(:,:,3)*0.5 + uint16(wekaProbMaskLow_Final)*illum;   % plot addmask as blue shaded area
        imshow(nano*3)
        xlim([firstC lastC])
        ylim([firstR lastR])
        text(firstC +100,firstR +100,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
        
        outline = h_getNucleusOutline(wekaProbMaskLow_Final);
        for j = 1:length(outline)
            plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w--', 'linewidth',1)
        end
        
        outline = h_getNucleusOutline(strmask(:,:,k-strstrt+1));
        for j = 1:length(outline)
            plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',1)
        end
    else
        display(['The threshold set to use for section ', num2str(k), ' doesnt match either the high or low threshold chosed'])
    end
    hold off
    
    handles.viewResult = 1;

else   % If "View Result" checkbox is turned OFF

    illum=2000; % this sets the illumination level of the masked area.. so change it if you don't like it.
    nano=imread(['tiffs/',masteralign(k).name]);
    set(handles.axes1, 'NextPlot', 'replacechildren')
    axes(handles.axes1)

    nano(:,:,3)= nano(:,:,3)*0.5 + uint16(addmask(:,:,k-strstrt+1))*illum;   % plot addmask as blue shaded area
    nano(:,:,1)= nano(:,:,1) + uint16(wekaProbMaskLow(:, :, k-strstrt+1))*2^16;   % Plot the low threshold magenta and high white
    nano(:,:,2)= nano(:,:,2) + uint16(wekaProbMaskHigh(:, :, k-strstrt+1))*2^16;
    nano(:,:,3)= nano(:,:,3) + uint16(wekaProbMaskLow(:, :, k-strstrt+1))*2^16;

    imshow(nano*3)
    xlim([firstC lastC])
    ylim([firstR lastR])
    text(firstC +100,firstR +100,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');

    hold on     % This will plot the striatum mask outline on the image 
    outline = h_getNucleusOutline(strmask(:,:,k-strstrt+1));
    for j = 1:length(outline)
        plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',1)
    end
                % This will plot the colormask outline on the image 
    subOutline = h_getNucleusOutline(colormask(:,:,k-strstrt+1));
    for j = 1:length(subOutline)
        plot((subOutline{j}(:,2)), (subOutline{j}(:,1))+0.5, 'k--', 'linewidth',2)
    end
                % This will plot the add mask outline on the image 
    addOutline = h_getNucleusOutline(addmask(:,:,k-strstrt+1));
    for j = 1:length(addOutline)
        plot((addOutline{j}(:,2)), (addOutline{j}(:,1))+0.5, 'r--', 'linewidth',2)
    end
    hold off
    handles.viewResult = 0;
end

guidata(hObject,handles);       %%% This is super important: you have to do this after updating a handle or it wont save! 
% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in checkbox4.
%           LEFT missing/torn
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load str/strdata.mat
k = handles.section;
sliceDamage = handles.sliceDamage;

if get(hObject,'Value') == 1  % If Checkbox is turned ON
    set(handles.checkbox5,'Value',0); % squished Checkbox OFF
    set(handles.checkbox6,'Value',0); % tissue issue Checkbox OFF
    sliceDamage(k).left.reason = 1;
    sliceDamage(k).left.index = 1;
else   % If Checkbox is turned OFF
    set(handles.checkbox4,'Value',0); % Turn missing/torn Checkbox OFF
    sliceDamage(k).left.reason = 0;
    sliceDamage(k).left.index = 0;
end

handles.sliceDamage = sliceDamage;
save('str/strdata','sliceDamage', '-append')

guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox4



% --- Executes on button press in checkbox5.
%            LEFT squished
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load str/strdata.mat
k = handles.section;
sliceDamage = handles.sliceDamage;

if get(hObject,'Value') == 1  % If Checkbox is turned ON
    set(handles.checkbox4,'Value',0); 
    set(handles.checkbox6,'Value',0); 
    sliceDamage(k).left.reason = 2;
    sliceDamage(k).left.index = 1;
else   % If Checkbox is turned OFF
    set(handles.checkbox5,'Value',0); 
    sliceDamage(k).left.reason = 0;
    sliceDamage(k).left.index = 0;
end

handles.sliceDamage = sliceDamage;
save('str/strdata','sliceDamage', '-append')

guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox5


% --- Executes on button press in checkbox6.
%               LEFT tissue issue
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load str/strdata.mat
k = handles.section;
sliceDamage = handles.sliceDamage;

if get(hObject,'Value') == 1  % If Checkbox is turned ON
    set(handles.checkbox4,'Value',0); 
    set(handles.checkbox5,'Value',0); 
    sliceDamage(k).left.reason = 3;
    sliceDamage(k).left.index = 1;
else   % If Checkbox is turned OFF
    set(handles.checkbox6,'Value',0); 
    sliceDamage(k).left.reason = 0;
    sliceDamage(k).left.index = 0;
end

handles.sliceDamage = sliceDamage;
save('str/strdata','sliceDamage', '-append')

guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox6


% --- Executes on button press in checkbox7.
%               RIGHT missing/torn
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load str/strdata.mat
k = handles.section;
sliceDamage = handles.sliceDamage;

if get(hObject,'Value') == 1  % If Checkbox is turned ON
    set(handles.checkbox8,'Value',0); % squished Checkbox OFF
    set(handles.checkbox9,'Value',0); % tissue issue Checkbox OFF
    sliceDamage(k).right.reason = 1;
    sliceDamage(k).right.index = 1;
else   % If Checkbox is turned OFF
    set(handles.checkbox7,'Value',0); % Turn missing/torn Checkbox OFF
    sliceDamage(k).right.reason = 0;
    sliceDamage(k).right.index = 0;
end

handles.sliceDamage = sliceDamage;
save('str/strdata','sliceDamage', '-append')

guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox7


% --- Executes on button press in checkbox8.
%           RIGHT squished
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load str/strdata.mat
k = handles.section;
sliceDamage = handles.sliceDamage;

if get(hObject,'Value') == 1  % If Checkbox is turned ON
    set(handles.checkbox7,'Value',0); % Checkbox OFF
    set(handles.checkbox9,'Value',0); % Checkbox OFF
    sliceDamage(k).right.reason = 2;
    sliceDamage(k).right.index = 1;
else   % If Checkbox is turned OFF
    set(handles.checkbox8,'Value',0); % Checkbox OFF
    sliceDamage(k).right.reason = 0;
    sliceDamage(k).right.index = 0;
end

handles.sliceDamage = sliceDamage;
save('str/strdata','sliceDamage', '-append')

guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox8


% --- Executes on button press in checkbox9.
%           RIGHT tissue issue
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load str/strdata.mat
k = handles.section;
sliceDamage = handles.sliceDamage;

if get(hObject,'Value') == 1  % If Checkbox is turned ON
    set(handles.checkbox7,'Value',0); % Checkbox OFF
    set(handles.checkbox8,'Value',0); % Checkbox OFF
    sliceDamage(k).right.reason = 3;
    sliceDamage(k).right.index = 1;
else   % If Checkbox is turned OFF
    set(handles.checkbox9,'Value',0); % Checkbox OFF
    sliceDamage(k).right.reason = 0;
    sliceDamage(k).right.index = 0;
end

handles.sliceDamage = sliceDamage;
save('str/strdata','sliceDamage', '-append')

guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox9


% --- Change the START section for LEFT Red Projections
function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
k = get(handles.edit2, 'string');
k = str2num(k);
load str/strdata.mat

projections.left.red.start = k;

save('str/strdata','projections', '-append')
% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Change the END section for LEFT Red Projections
function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
k = get(handles.edit3, 'string');
k = str2num(k);
load str/strdata.mat

projections.left.red.end = k;

save('str/strdata','projections', '-append')
% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Change the START section for RIGHT Red Projections
function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
k = get(handles.edit4, 'string');
k = str2num(k);
load str/strdata.mat

projections.right.red.start = k;

save('str/strdata','projections', '-append')
% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Change the END section for RIGHT Red Projections
function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
k = get(handles.edit5, 'string');
k = str2num(k);
load str/strdata.mat

projections.right.red.end = k;

save('str/strdata','projections', '-append')
% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox10.
function checkbox10_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load str/strdata.mat
k = handles.section;
sliceDamage = handles.sliceDamage;

if get(hObject,'Value') == 1  % If Checkbox is turned ON
    sliceDamage(k).flip = 1;
else   % If Checkbox is turned OFF
    set(handles.checkbox10,'Value',0); % Checkbox OFF
    sliceDamage(k).flip = 0;
end

handles.sliceDamage = sliceDamage;
save('str/strdata','sliceDamage', '-append')

guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox10


% --- Executes on button press in checkbox11.
function checkbox11_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load str/strdata.mat
k = handles.section;
sliceDamage = handles.sliceDamage;

if get(hObject,'Value') == 1  % If Checkbox is turned ON
    sliceDamage(k).projSkip = 1;
else   % If Checkbox is turned OFF
    set(handles.checkbox10,'Value',0); % Checkbox OFF
    sliceDamage(k).projSkip = 0;
end

handles.sliceDamage = sliceDamage;
save('str/strdata','sliceDamage', '-append')

guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox11
% Hint: get(hObject,'Value') returns toggle state of checkbox11


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
k = handles.section - 1;
handles.section = k;

load masteralign2
load str/strdata.mat

set(handles.uipanel2, 'Title', ['Current Section: ',  num2str(k)])  % Displaying the current section number on the GUI

strmask = handles.strmask;
addmask = handles.addmask; 
colormask = handles.colormask; 
wekaProbMaskHigh = handles.HighMask;
wekaProbMaskLow = handles.LowMask;

if k > strnd
    save('str/red_addmask.mat', 'addmask')
    save('str/red_str_MaskedOutProjections.mat', 'colormask') %Save up here, so if there is an error in the slice number it saves first!
    c = clock;
    display(['*****SAVED addmask and submask(colormask) on section ', num2str(handles.section), ' of ', handles.brain, ' at: ', (datestr(datenum(c(1),c(2),c(3),c(4),c(5),c(6))))]);
end

% Set the Threshold checkboxes
WEKA.thresholdBySlice.red = handles.thresholdBySlice;
if WEKA.thresholdBySlice.red(k) == handles.HighThresh 
    set(handles.checkbox1,'Value',1); % Turn the HIGH Threshold Checkbox ON
    set(handles.checkbox2,'Value',0); % Turn the LOW Threshold Checkbox OFF
elseif WEKA.thresholdBySlice.red(k) == handles.LowThresh 
    set(handles.checkbox1,'Value',0); % Turn the HIGH Threshold Checkbox OFF
    set(handles.checkbox2,'Value',1); % Turn the LOW Threshold Checkbox ON
else
    display(['The threshold set to use for section ', num2str(k), ' doesnt match either the high or low threshold chosed'])
end


% Set the Slice Damage checkboxes
sliceDamage = handles.sliceDamage;
if sliceDamage(k).left.reason == 0;
    set(handles.checkbox4,'Value',0); % missing/torn Checkbox OFF
    set(handles.checkbox5,'Value',0); % squished Checkbox OFF
    set(handles.checkbox6,'Value',0); % tissue issue Checkbox OFF
elseif sliceDamage(k).left.reason == 1;
    set(handles.checkbox4,'Value',1); % missing/torn Checkbox ON
    set(handles.checkbox5,'Value',0); % squished Checkbox OFF
    set(handles.checkbox6,'Value',0); % tissue issue Checkbox OFF
elseif sliceDamage(k).left.reason == 2;
    set(handles.checkbox4,'Value',0); % missing/torn Checkbox OFF
    set(handles.checkbox5,'Value',1); % squished Checkbox ON
    set(handles.checkbox6,'Value',0); % tissue issue Checkbox OFF
elseif sliceDamage(k).left.reason == 3;
    set(handles.checkbox4,'Value',0); % missing/torn Checkbox OFF
    set(handles.checkbox5,'Value',0); % squished Checkbox OFF
    set(handles.checkbox6,'Value',1); % tissue issue Checkbox ON
else
    display(['The damage state of section ', num2str(k), ' left is confused'])
end
if sliceDamage(k).right.reason == 0;
    set(handles.checkbox7,'Value',0); % missing/torn Checkbox OFF
    set(handles.checkbox8,'Value',0); % squished Checkbox OFF
    set(handles.checkbox9,'Value',0); % tissue issue Checkbox OFF
elseif sliceDamage(k).right.reason == 1;
    set(handles.checkbox7,'Value',1); % missing/torn Checkbox ON
    set(handles.checkbox8,'Value',0); % squished Checkbox OFF
    set(handles.checkbox9,'Value',0); % tissue issue Checkbox OFF
elseif sliceDamage(k).right.reason == 2;
    set(handles.checkbox7,'Value',0); % missing/torn Checkbox OFF
    set(handles.checkbox8,'Value',1); % squished Checkbox ON
    set(handles.checkbox9,'Value',0); % tissue issue Checkbox OFF
elseif sliceDamage(k).right.reason == 3;
    set(handles.checkbox7,'Value',0); % missing/torn Checkbox OFF
    set(handles.checkbox8,'Value',0); % squished Checkbox OFF
    set(handles.checkbox9,'Value',1); % tissue issue Checkbox ON
else
    display(['The damage state of section ', num2str(k), ' right is confused'])
end
if sliceDamage(k).flip == 1;
    set(handles.checkbox10,'Value',1); % Flip Checkbox ON
else
    set(handles.checkbox10,'Value',0); % Flip Checkbox OFF
end
if sliceDamage(k).projSkip == 1;
    set(handles.checkbox11,'Value',1); % Flip Checkbox ON
else 
    set(handles.checkbox11,'Value',0); % Flip Checkbox OFF
end

illum=2000; % this sets the illumination level of the masked area.. so change it if you don't like it.
        
nano=imread(['tiffs/',masteralign(k).name]);
set(handles.axes1, 'NextPlot', 'replacechildren')
axes(handles.axes1)

nano(:,:,3)= nano(:,:,3)*0.5 + uint16(addmask(:,:,k-strstrt+1))*illum;   % plot addmask as blue shaded area

nano(:,:,1)= nano(:,:,1) + uint16(wekaProbMaskLow(:, :, k-strstrt+1))*2^16;   % Plot the low threshold magenta and high white
nano(:,:,2)= nano(:,:,2) + uint16(wekaProbMaskHigh(:, :, k-strstrt+1))*2^16;
nano(:,:,3)= nano(:,:,3) + uint16(wekaProbMaskLow(:, :, k-strstrt+1))*2^16;

imshow(nano*3)
xlim([firstC lastC])
ylim([firstR lastR])
text(firstC +100,firstR +100,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');


hold on     % This will plot the striatum mask outline on the image 
outline = h_getNucleusOutline(strmask(:,:,k-strstrt+1));
for j = 1:length(outline)
    plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',1)
end

            % This will plot the colormask outline on the image 
subOutline = h_getNucleusOutline(colormask(:,:,k-strstrt+1));
for j = 1:length(subOutline)
    plot((subOutline{j}(:,2)), (subOutline{j}(:,1))+0.5, 'k--', 'linewidth',2)
end

            % This will plot the add mask outline on the image 
addOutline = h_getNucleusOutline(addmask(:,:,k-strstrt+1));
for j = 1:length(addOutline)
    plot((addOutline{j}(:,2)), (addOutline{j}(:,1))+0.5, 'r--', 'linewidth',2)
end

hold off

% Then show a little thumbnail of the probability image with a jet colorbar (RED)
if exist(['str/WEKAoutput/probabilities_maskedStr_red_', num2str(k), '.tif'])
    probImgR= imread(['str/WEKAoutput/probabilities_maskedStr_red_', num2str(k), '.tif'],1);
    set(handles.axes2, 'NextPlot', 'replacechildren')
    axes(handles.axes2)
    imshow(probImgR)
    colormap('jet');
    colorbar
    axis image
    text(100,100,'RED','Color','w');
else
    placeholder = zeros([2500 3500]);
    set(handles.axes2, 'NextPlot', 'replacechildren')
    axes(handles.axes2)
    imshow(placeholder)
    colormap('jet');
    text(1000,1000,'No RED Probability Image','Color','w');
end
% Then show a little thumbnail of the probability image with a jet colorbar (GREEN)
if exist(['str/WEKAoutput/probabilities_maskedStr_green_', num2str(k), '.tif'])
    probImgG= imread(['str/WEKAoutput/probabilities_maskedStr_green_', num2str(k), '.tif'],1);
    set(handles.axes4, 'NextPlot', 'replacechildren')
    axes(handles.axes4)
    imshow(probImgG)
    colormap('jet');
    colorbar
    axis image
    text(100,100,'GREEN','Color','w');
else
    placeholder = zeros(2500, 4300);
    set(handles.axes4, 'NextPlot', 'replacechildren')
    axes(handles.axes4)
    imshow(placeholder)
    colormap('jet');
    text(1000,1000,'No GREEN Probability Image','Color','w');
end

% 
% save('str/red_addmask.mat', 'addmask')
% save('str/red_str_MaskedOutProjections.mat', 'colormask')
% save('str/strdata','WEKA', '-append')


guidata(hObject,handles);       %%% This is super important: you have to do this after updating a handle or it wont save!
