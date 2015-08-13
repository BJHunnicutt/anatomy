function varargout = jh_AllenInstituteBundleSubtraction(varargin)
% JH_ALLENINSTITUTEBUNDLESUBTRACTION MATLAB code for jh_AllenInstituteBundleSubtraction.fig
%      JH_ALLENINSTITUTEBUNDLESUBTRACTION, by itself, creates a new JH_ALLENINSTITUTEBUNDLESUBTRACTION or raises the existing
%      singleton*.
%
%      H = JH_ALLENINSTITUTEBUNDLESUBTRACTION returns the handle to a new JH_ALLENINSTITUTEBUNDLESUBTRACTION or the handle to
%      the existing singleton*.
%
%      JH_ALLENINSTITUTEBUNDLESUBTRACTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in JH_ALLENINSTITUTEBUNDLESUBTRACTION.M with the given input arguments.
%
%      JH_ALLENINSTITUTEBUNDLESUBTRACTION('Property','Value',...) creates a new JH_ALLENINSTITUTEBUNDLESUBTRACTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before jh_AllenInstituteBundleSubtraction_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to jh_AllenInstituteBundleSubtraction_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help jh_AllenInstituteBundleSubtraction

% Last Modified by GUIDE v2.5 22-Apr-2015 02:19:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @jh_AllenInstituteBundleSubtraction_OpeningFcn, ...
                   'gui_OutputFcn',  @jh_AllenInstituteBundleSubtraction_OutputFcn, ...
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

% Things to make:
% 0. Make a folder for of each brain number with:  (Do this in jh_pImport2matlab2.m)
%     -tiffs/
%     -meta (add the stuff that would be in strdata to this, like str strt, projection.L.start & stop etc.)
%     -submask
 
% 1. A stack of tiffs with the average brain and the L & R projection mask trasnparent with solid outline (also injection site!)
% 2. Open the image and the one before and after (use the composite tiffs for those?)
% 3. add/subrtract from a submask
% 

% --- Executes just before jh_AllenInstituteBundleSubtraction is made visible.

%%%%%%%%%%%%%%%%%%% "Open first images"    %%%%%%%%%%%%%%%%%
function jh_AllenInstituteBundleSubtraction_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to jh_AllenInstituteBundleSubtraction (see VARARGIN)

% Choose default command line output for jh_AllenInstituteBundleSubtraction
handles.output = hObject;

load injMeta.mat
load rotatedData.mat
load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/data3/averageBrain100um/averageTemplate100um_rotated.mat')

if ~isfield(injMeta, 'striatum')
    injMeta.striatum = [];
end
if ~isfield(injMeta.striatum, 'projections')
    injMeta.striatum.projections = [];
end
if ~isfield(injMeta.striatum.projections, 'right')
    injMeta.striatum.projections.right.start = input('What is the FIRST slice with on the RIGHT (ipsi)?');
    injMeta.striatum.projections.right.end = input('What is the LAST slice with projections on the RIGHT (ipsi)?');    
    injMeta.striatum.projections.left.start = input('What is the FIRST slice with projections on the LEFT (contra)?');
    injMeta.striatum.projections.left.end = input('What is the LAST slice with projections on the LEFT (contra)?');
    save('injMeta.mat', 'injMeta');
end


if ~exist('submask.mat','file')         %initializing the final subtraction that i will make to the AIBS masks
    submask= false(size(averageTemplate100um)); 
    save('submask.mat','submask')
else
    load submask.mat
end

k= input('which section do you want to BEGIN with? '); 
if isempty (k)
    k= injMeta.striatum.strstrt;
end


% Display main Image %
% This makes the striatum projections yellow with a green outline, non-striatal projections red, injection sites yellow with a black outline and submask a black dashed outline
avgImg(:, :, 1) = averageTemplate100um(:, :, k)/500;
avgImg(:, :, 2) = averageTemplate100um(:, :, k)/500;
avgImg(:, :, 3) = averageTemplate100um(:, :, k)/500;
avgImg(:, :, 2) = avgImg(:, :, 2)+(logical((rotatedData.striatum3d.R.densities(:, :, k)>.005)+(rotatedData.striatum3d.L.densities(:, :, k)>.005))*10);

avgImg(:, :, 2) = avgImg(:, :, 2)+(rotatedData.injection3d.mask(:, :, k)>.05)*10;
avgImg(:, :, 1) = avgImg(:, :, 1)+(rotatedData.fullDensityMap.densities(:, :, k)>.005)*50;
%          avgImg(:, :, 1) = avgImg(:, :, 1)+ logical((rotatedData.striatum3d(i).L.mask(:, :, k))*5+(rotatedData.striatum3d(i).R.mask(:, :, k))*5);
maskR = rotatedData.striatum3d.R.densities(:, :, k)>.005;
maskL = rotatedData.striatum3d.L.densities(:, :, k)>.005;
maskI = rotatedData.injection3d.mask(:, :, k)>.05;
maskS = (rotatedData.striatum3d.L.mask(:, :, k)>.05)+(rotatedData.striatum3d.R.mask(:, :, k)>.05);

set(handles.axes1, 'NextPlot', 'replacechildren')
axes(handles.axes1)
imshow(avgImg, 'Border','tight')
text(10,10,[num2str(injMeta.id),' - ',num2str(k)],'Color','r');
%Outline of right projections
outline = h_getNucleusOutline(maskR(:, :));
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',2)
end
%Outline of left projections
outline = h_getNucleusOutline(maskL(:, :));
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',2)
end
%Outline of Injection
outline = h_getNucleusOutline(maskI(:, :));
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',1)
end
% Plot the submask outline on the image 
subOutline = h_getNucleusOutline(submask(:,:,k));
for j = 1:length(subOutline)
    plot((subOutline{j}(:,2)), (subOutline{j}(:,1)), 'b--', 'linewidth',2)
end



%DORSAL
img = logical((squeeze(sum((rotatedData.striatum3d.R.densities>0.005), 1)))+(squeeze(sum((rotatedData.striatum3d.L.densities>0.005), 1))));
set(handles.axes2, 'NextPlot', 'replacechildren')
axes(handles.axes2)
imshow(img)
hold on
maxmask = squeeze(sum(rotatedData.striatum3d.R.mask, 1))+squeeze(sum(rotatedData.striatum3d.L.mask, 1));
outline = h_getNucleusOutline(maxmask);
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'r-', 'linewidth',1)
end
maxmask = squeeze(sum(averageTemplate100um, 1))>500;
outline = h_getNucleusOutline(maxmask);
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'w-', 'linewidth',2)
end

%LATERAL
img = logical((squeeze(sum((rotatedData.striatum3d.R.densities>0.005), 2)))+(squeeze(sum((rotatedData.striatum3d.L.densities>0.005), 2)))); 
set(handles.axes3, 'NextPlot', 'replacechildren')
axes(handles.axes3)
imshow(img)
hold on
maxmask = squeeze(sum(rotatedData.striatum3d.R.mask, 2))+squeeze(sum(rotatedData.striatum3d.L.mask, 2));
outline = h_getNucleusOutline(maxmask);
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'r-', 'linewidth',1)
end
maxmask = squeeze(sum(averageTemplate100um, 2))>500;;
outline = h_getNucleusOutline(maxmask);
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'w-', 'linewidth',2)
end

%ANTERIOR
img = logical((squeeze(sum((rotatedData.striatum3d.R.densities>0.005), 3)))+(squeeze(sum((rotatedData.striatum3d.L.densities>0.005), 3)))); 
set(handles.axes4, 'NextPlot', 'replacechildren')
axes(handles.axes4)
imshow(img)
hold on
maxmask = squeeze(sum(rotatedData.striatum3d.R.mask, 3))+squeeze(sum(rotatedData.striatum3d.L.mask, 3));
outline = h_getNucleusOutline(maxmask);
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'r-', 'linewidth',1)
end
maxmask = squeeze(sum(averageTemplate100um, 3))>500;;
outline = h_getNucleusOutline(maxmask);
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'w-', 'linewidth',2)
end


% Set remaining handles
set(handles.uipanel2, 'Title', ['Current Section: ',  num2str(k)])  % Displaying the current section number on the GUI
set(handles.edit2, 'string', num2str(injMeta.striatum.projections.left.start)); % Displaying the left green projection start
set(handles.edit3, 'string', num2str(injMeta.striatum.projections.left.end)); % Displaying the left green projection end
set(handles.edit4, 'string', num2str(injMeta.striatum.projections.right.start)); % Displaying the right green projection start
set(handles.edit5, 'string', num2str(injMeta.striatum.projections.right.end)); % Displaying the right green projection end

handles.section = k;
handles.injMeta = injMeta;
handles.submask = submask; 
handles.rotatedData = rotatedData; 
handles.averageTemplate100um = averageTemplate100um; 
handles.brain = injMeta.id;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes jh_AllenInstituteBundleSubtraction wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = jh_AllenInstituteBundleSubtraction_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%%%%%%%%%%%%   Jump to Section #    %%%%%%%%%%%%%%%
function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
k = get(handles.edit1, 'string');
k = str2num(k);

handles.section = k;
set(handles.uipanel2, 'Title', ['Current Section: ',  num2str(k)])  % Displaying the current section number on the GUI

injMeta = handles.injMeta;
submask = handles.submask;
rotatedData = handles.rotatedData; 
averageTemplate100um = handles.averageTemplate100um; 

% Update main Image %
% This makes the striatum projections yellow with a green outline, non-striatal projections red, injection sites yellow with a black outline and submask a black dashed outline
avgImg(:, :, 1) = averageTemplate100um(:, :, k)/500;
avgImg(:, :, 2) = averageTemplate100um(:, :, k)/500;
avgImg(:, :, 3) = averageTemplate100um(:, :, k)/500;
avgImg(:, :, 2) = avgImg(:, :, 2)+(logical((rotatedData.striatum3d.R.densities(:, :, k)>.005)+(rotatedData.striatum3d.L.densities(:, :, k)>.005))*10);
avgImg(:, :, 2) = avgImg(:, :, 2)+(rotatedData.injection3d.mask(:, :, k)>.05)*10;
avgImg(:, :, 1) = avgImg(:, :, 1)+(rotatedData.fullDensityMap.densities(:, :, k)>.005)*50;
%          avgImg(:, :, 1) = avgImg(:, :, 1)+ logical((rotatedData.striatum3d(i).L.mask(:, :, k))*5+(rotatedData.striatum3d(i).R.mask(:, :, k))*5);
maskR = rotatedData.striatum3d.R.densities(:, :, k)>.005;
maskL = rotatedData.striatum3d.L.densities(:, :, k)>.005;
maskI = rotatedData.injection3d.mask(:, :, k)>.05;
maskS = (rotatedData.striatum3d.L.mask(:, :, k)>.05)+(rotatedData.striatum3d.R.mask(:, :, k)>.05);

set(handles.axes1, 'NextPlot', 'replacechildren')
axes(handles.axes1)
imshow(avgImg, 'Border','tight')
text(10,10,[num2str(injMeta.id),' - ',num2str(k)],'Color','r');
%Outline of right
outline = h_getNucleusOutline(maskR(:, :));
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',2)
end
%Outline of left
outline = h_getNucleusOutline(maskL(:, :));
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',2)
end
%Outline of Injection
outline = h_getNucleusOutline(maskI(:, :));
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',1)
end
% Plot the submask outline on the image 
subOutline = h_getNucleusOutline(submask(:,:,k));
for j = 1:length(subOutline)
    plot((subOutline{j}(:,2)), (subOutline{j}(:,1)), 'b--', 'linewidth',2)
end


guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


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


% --- Executes on button press in pushbutton1.
%%%%%%%%%%%%%%%      NEXT      %%%%%%%%%%%%%%%
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

k = handles.section + 1;

handles.section = k;
set(handles.uipanel2, 'Title', ['Current Section: ',  num2str(k)])  % Displaying the current section number on the GUI

injMeta = handles.injMeta;
submask = handles.submask;
rotatedData = handles.rotatedData; 
averageTemplate100um = handles.averageTemplate100um; 

% Update main Image %
% This makes the striatum projections yellow with a green outline, non-striatal projections red, injection sites yellow with a black outline and submask a black dashed outline
avgImg(:, :, 1) = averageTemplate100um(:, :, k)/500;
avgImg(:, :, 2) = averageTemplate100um(:, :, k)/500;
avgImg(:, :, 3) = averageTemplate100um(:, :, k)/500;
avgImg(:, :, 2) = avgImg(:, :, 2)+(logical((rotatedData.striatum3d.R.densities(:, :, k)>.005)+(rotatedData.striatum3d.L.densities(:, :, k)>.005))*10);
avgImg(:, :, 2) = avgImg(:, :, 2)+(rotatedData.injection3d.mask(:, :, k)>.05)*10;
avgImg(:, :, 1) = avgImg(:, :, 1)+(rotatedData.fullDensityMap.densities(:, :, k)>.005)*50;
%          avgImg(:, :, 1) = avgImg(:, :, 1)+ logical((rotatedData.striatum3d(i).L.mask(:, :, k))*5+(rotatedData.striatum3d(i).R.mask(:, :, k))*5);
maskR = rotatedData.striatum3d.R.densities(:, :, k)>.005;
maskL = rotatedData.striatum3d.L.densities(:, :, k)>.005;
maskI = rotatedData.injection3d.mask(:, :, k)>.05;
maskS = (rotatedData.striatum3d.L.mask(:, :, k)>.05)+(rotatedData.striatum3d.R.mask(:, :, k)>.05);

set(handles.axes1, 'NextPlot', 'replacechildren')
axes(handles.axes1)
imshow(avgImg, 'Border','tight')
text(10,10,[num2str(injMeta.id),' - ',num2str(k)],'Color','r');
%Outline of right
outline = h_getNucleusOutline(maskR(:, :));
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',2)
end
%Outline of left
outline = h_getNucleusOutline(maskL(:, :));
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',2)
end
%Outline of Injection
outline = h_getNucleusOutline(maskI(:, :));
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',1)
end
% Plot the submask outline on the image 
subOutline = h_getNucleusOutline(submask(:,:,k));
for j = 1:length(subOutline)
    plot((subOutline{j}(:,2)), (subOutline{j}(:,1)), 'b--', 'linewidth',2)
end


guidata(hObject, handles);


% --- Executes on button press in pushbutton2
%%%%%%%%%%%%%%%      PREVIOUS    %%%%%%%%%%%%%%%
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
k = handles.section - 1;

handles.section = k;
set(handles.uipanel2, 'Title', ['Current Section: ',  num2str(k)])  % Displaying the current section number on the GUI

injMeta = handles.injMeta;
submask = handles.submask;
rotatedData = handles.rotatedData; 
averageTemplate100um = handles.averageTemplate100um; 

% Update main Image %
% This makes the striatum projections yellow with a green outline, non-striatal projections red, injection sites yellow with a black outline and submask a black dashed outline
avgImg(:, :, 1) = averageTemplate100um(:, :, k)/500;
avgImg(:, :, 2) = averageTemplate100um(:, :, k)/500;
avgImg(:, :, 3) = averageTemplate100um(:, :, k)/500;
avgImg(:, :, 2) = avgImg(:, :, 2)+(logical((rotatedData.striatum3d.R.densities(:, :, k)>.005)+(rotatedData.striatum3d.L.densities(:, :, k)>.005))*10);
avgImg(:, :, 2) = avgImg(:, :, 2)+(rotatedData.injection3d.mask(:, :, k)>.05)*10;
avgImg(:, :, 1) = avgImg(:, :, 1)+(rotatedData.fullDensityMap.densities(:, :, k)>.005)*50;
%          avgImg(:, :, 1) = avgImg(:, :, 1)+ logical((rotatedData.striatum3d(i).L.mask(:, :, k))*5+(rotatedData.striatum3d(i).R.mask(:, :, k))*5);
maskR = rotatedData.striatum3d.R.densities(:, :, k)>.005;
maskL = rotatedData.striatum3d.L.densities(:, :, k)>.005;
maskI = rotatedData.injection3d.mask(:, :, k)>.05;
maskS = (rotatedData.striatum3d.L.mask(:, :, k)>.05)+(rotatedData.striatum3d.R.mask(:, :, k)>.05);

set(handles.axes1, 'NextPlot', 'replacechildren')
axes(handles.axes1)
imshow(avgImg, 'Border','tight')
text(10,10,[num2str(injMeta.id),' - ',num2str(k)],'Color','r');
%Outline of right
outline = h_getNucleusOutline(maskR(:, :));
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',2)
end
%Outline of left
outline = h_getNucleusOutline(maskL(:, :));
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',2)
end
%Outline of Injection
outline = h_getNucleusOutline(maskI(:, :));
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',1)
end
% Plot the submask outline on the image 
subOutline = h_getNucleusOutline(submask(:,:,k));
for j = 1:length(subOutline)
    plot((subOutline{j}(:,2)), (subOutline{j}(:,1)), 'b--', 'linewidth',2)
end


guidata(hObject, handles);


%%%%%%%%%%%%%%% Projection: left.start
function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
i = get(handles.edit2, 'string');
i = str2num(i);
injMeta = handles.injMeta;

injMeta.striatum.projections.left.start = i;

handles.injMeta = injMeta;

save('injMeta.mat', 'injMeta');

guidata(hObject, handles);
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


%%%%%%%%%%%%%%% Projection: left.end
function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
i = get(handles.edit3, 'string');
i = str2num(i);
injMeta = handles.injMeta;

injMeta.striatum.projections.left.end = i;

handles.injMeta = injMeta;

save('injMeta.mat', 'injMeta');

guidata(hObject, handles);
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


%%%%%%%%%%%%%%% Projection: right.start
function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
i = get(handles.edit4, 'string');
i = str2num(i);
injMeta = handles.injMeta;

injMeta.striatum.projections.right.start = i;

handles.injMeta = injMeta;

save('injMeta.mat', 'injMeta');

guidata(hObject, handles);
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


%%%%%%%%%%%%%%% Projection: right.end
function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
i = get(handles.edit5, 'string');
i = str2num(i);
injMeta = handles.injMeta;

injMeta.striatum.projections.right.end = i;

handles.injMeta = injMeta;

save('injMeta.mat', 'injMeta');

guidata(hObject, handles);
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


% --- Executes on button press in pushbutton3.
%%%%%%%%%%%%%%%    SUBTRACT from submask    %%%%%%%%%%%%%%%
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
k = handles.section;

injMeta = handles.injMeta;
submask = handles.submask;
rotatedData = handles.rotatedData; 
averageTemplate100um = handles.averageTemplate100um; 

% This makes the striatum projections yellow with a green outline, non-striatal projections red, injection sites yellow with a black outline and submask a black dashed outline
avgImg(:, :, 1) = averageTemplate100um(:, :, k)/500;
avgImg(:, :, 2) = averageTemplate100um(:, :, k)/500;
avgImg(:, :, 3) = averageTemplate100um(:, :, k)/500;
avgImg(:, :, 2) = avgImg(:, :, 2)+(logical((rotatedData.striatum3d.R.densities(:, :, k)>.005)+(rotatedData.striatum3d.L.densities(:, :, k)>.005))*10);
avgImg(:, :, 2) = avgImg(:, :, 2)+(rotatedData.injection3d.mask(:, :, k)>.05)*10;
avgImg(:, :, 1) = avgImg(:, :, 1)+(rotatedData.fullDensityMap.densities(:, :, k)>.005)*50;

% Select an ROI %
roi1= imfreehand(gca);
roiapi=iptgetapi(roi1);
roipoints= roiapi.getPosition();
selection= roipoly(avgImg, roipoints(:,1), roipoints(:,2));
submask(:,:,k)= submask(:,:,k).*~selection; %%%% This is the subtraction bit

delete(roi1)

handles.submask = submask; 

% Update main Image %
maskR = rotatedData.striatum3d.R.densities(:, :, k)>.005;
maskL = rotatedData.striatum3d.L.densities(:, :, k)>.005;
maskI = rotatedData.injection3d.mask(:, :, k)>.05;
maskS = (rotatedData.striatum3d.L.mask(:, :, k)>.05)+(rotatedData.striatum3d.R.mask(:, :, k)>.05);

set(handles.axes1, 'NextPlot', 'replacechildren')
axes(handles.axes1)
imshow(avgImg, 'Border','tight')
text(10,10,[num2str(injMeta.id),' - ',num2str(k)],'Color','r');
%Outline of right projections
outline = h_getNucleusOutline(maskR(:, :));
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',2)
end
%Outline of left projections
outline = h_getNucleusOutline(maskL(:, :));
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',2)
end
%Outline of Injection
outline = h_getNucleusOutline(maskI(:, :));
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',1)
end
% Plot the submask outline on the image 
subOutline = h_getNucleusOutline(submask(:,:,k));
for j = 1:length(subOutline)
    plot((subOutline{j}(:,2)), (subOutline{j}(:,1)), 'b--', 'linewidth',2)
end



guidata(hObject,handles);       %%% This is super important: you have to do this after updating a handle or it wont save!



% --- Executes on button press in pushbutton4.
%%%%%% SAVE submask (& update max projection views)  %%%%%%%%%%%%%%%
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

k = handles.section;

injMeta = handles.injMeta;
submask = handles.submask;
rotatedData = handles.rotatedData; 
averageTemplate100um = handles.averageTemplate100um; 
submask = handles.submask;

% SAVE submask
save('submask.mat','submask')
c = clock;
display(['**SAVED submask on section ', num2str(k), ' of ', num2str(handles.brain), ' at: ', (datestr(datenum(c(1),c(2),c(3),c(4),c(5),c(6))))]);

% Update the maximun intensity projection images


rotatedData.striatum3d.R.densities = rotatedData.striatum3d.R.densities.*~submask;
rotatedData.striatum3d.L.densities = rotatedData.striatum3d.L.densities.*~submask;

%DORSAL
img = logical((squeeze(sum((rotatedData.striatum3d.R.densities>0.005), 1)))+(squeeze(sum((rotatedData.striatum3d.L.densities>0.005), 1))));  
set(handles.axes2, 'NextPlot', 'replacechildren')
axes(handles.axes2)
imshow(img)
hold on
maxmask = squeeze(sum(rotatedData.striatum3d.R.mask, 1))+squeeze(sum(rotatedData.striatum3d.L.mask, 1));
outline = h_getNucleusOutline(maxmask);
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'r-', 'linewidth',1)
end
maxmask = squeeze(sum(averageTemplate100um, 1))>500;;
outline = h_getNucleusOutline(maxmask);
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'w-', 'linewidth',2)
end

%LATERAL
img = logical((squeeze(sum((rotatedData.striatum3d.R.densities>0.005), 2)))+(squeeze(sum((rotatedData.striatum3d.L.densities>0.005), 2))));  
set(handles.axes3, 'NextPlot', 'replacechildren')
axes(handles.axes3)
imshow(img)
hold on
maxmask = squeeze(sum(rotatedData.striatum3d.R.mask, 2))+squeeze(sum(rotatedData.striatum3d.L.mask, 2));
outline = h_getNucleusOutline(maxmask);
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'r-', 'linewidth',1)
end
maxmask = squeeze(sum(averageTemplate100um, 2))>500;;
outline = h_getNucleusOutline(maxmask);
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'w-', 'linewidth',2)
end

%ANTERIOR
img = logical((squeeze(sum((rotatedData.striatum3d.R.densities>0.005), 3)))+(squeeze(sum((rotatedData.striatum3d.L.densities>0.005), 3))));  
set(handles.axes4, 'NextPlot', 'replacechildren')
axes(handles.axes4)
imshow(img)
hold on
maxmask = squeeze(sum(rotatedData.striatum3d.R.mask, 3))+squeeze(sum(rotatedData.striatum3d.L.mask, 3));
outline = h_getNucleusOutline(maxmask);
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'r-', 'linewidth',1)
end
maxmask = squeeze(sum(averageTemplate100um, 3))>500;;
outline = h_getNucleusOutline(maxmask);
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'w-', 'linewidth',2)
end


guidata(hObject,handles);  
    


% --- Executes on button press in pushbutton5.
%%%%%%%%%%%%%%%    ADD to submask    %%%%%%%%%%%%%%%
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
k = handles.section;

injMeta = handles.injMeta;
submask = handles.submask;
rotatedData = handles.rotatedData; 
averageTemplate100um = handles.averageTemplate100um; 

% This makes the striatum projections yellow with a green outline, non-striatal projections red, injection sites yellow with a black outline and submask a black dashed outline
avgImg(:, :, 1) = averageTemplate100um(:, :, k)/500;
avgImg(:, :, 2) = averageTemplate100um(:, :, k)/500;
avgImg(:, :, 3) = averageTemplate100um(:, :, k)/500;
avgImg(:, :, 2) = avgImg(:, :, 2)+(logical((rotatedData.striatum3d.R.densities(:, :, k)>.005)+(rotatedData.striatum3d.L.densities(:, :, k)>.005))*10);
avgImg(:, :, 2) = avgImg(:, :, 2)+(rotatedData.injection3d.mask(:, :, k)>.05)*10;
avgImg(:, :, 1) = avgImg(:, :, 1)+(rotatedData.fullDensityMap.densities(:, :, k)>.005)*50;

% Select an ROI %
roi1= imfreehand(gca);
roiapi=iptgetapi(roi1);
roipoints= roiapi.getPosition();
selection= roipoly(avgImg, roipoints(:,1), roipoints(:,2));
submask(:,:,k)= submask(:,:,k)+selection; %%%% This is the addition bit

delete(roi1)

handles.submask = submask; 

% Update main Image %
maskR = rotatedData.striatum3d.R.densities(:, :, k)>.005;
maskL = rotatedData.striatum3d.L.densities(:, :, k)>.005;
maskI = rotatedData.injection3d.mask(:, :, k)>.05;
maskS = (rotatedData.striatum3d.L.mask(:, :, k)>.05)+(rotatedData.striatum3d.R.mask(:, :, k)>.05);

set(handles.axes1, 'NextPlot', 'replacechildren')
axes(handles.axes1)
imshow(avgImg, 'Border','tight')
text(10,10,[num2str(injMeta.id),' - ',num2str(k)],'Color','r');
%Outline of right projections
outline = h_getNucleusOutline(maskR(:, :));
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',2)
end
%Outline of left projections
outline = h_getNucleusOutline(maskL(:, :));
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',2)
end
%Outline of Injection
outline = h_getNucleusOutline(maskI(:, :));
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',1)
end
% Plot the submask outline on the image 
subOutline = h_getNucleusOutline(submask(:,:,k));
for j = 1:length(subOutline)
    plot((subOutline{j}(:,2)), (subOutline{j}(:,1)), 'b--', 'linewidth',2)
end



guidata(hObject,handles);       %%% This is super important: you have to do this after updating a handle or it wont save!


% --- Executes on button press in pushbutton6.
%%%%%%%%  ADD to submask: All ANTERIOR slices   %%%%%%%%%%%%%%%
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
k = handles.section;

injMeta = handles.injMeta;
submask = handles.submask;
rotatedData = handles.rotatedData; 
averageTemplate100um = handles.averageTemplate100um; 


img = logical((squeeze(sum((rotatedData.striatum3d.R.densities>0.005), 3)))+(squeeze(sum((rotatedData.striatum3d.L.densities>0.005), 3))));  
set(handles.axes4, 'NextPlot', 'replacechildren')
axes(handles.axes4)

% Select an ROI %
roi1= imfreehand(gca);
roiapi=iptgetapi(roi1);
roipoints= roiapi.getPosition();
selection= roipoly(img, roipoints(:,1), roipoints(:,2));
for j = 1:length(submask)
    submask(:,:,j)= submask(:,:,j)+selection; %%%% This is the addition bit
end

delete(roi1)

handles.submask = submask; 

rotatedData.striatum3d.R.densities = rotatedData.striatum3d.R.densities.*~submask;
rotatedData.striatum3d.L.densities = rotatedData.striatum3d.L.densities.*~submask;

%ANTERIOR
img = logical((squeeze(sum((rotatedData.striatum3d.R.densities>0.005), 3)))+(squeeze(sum((rotatedData.striatum3d.L.densities>0.005), 3))));  
imshow(img)
hold on
maxmask = squeeze(sum(rotatedData.striatum3d.R.mask, 3))+squeeze(sum(rotatedData.striatum3d.L.mask, 3));
outline = h_getNucleusOutline(maxmask);
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'r-', 'linewidth',1)
end
maxmask = squeeze(sum(averageTemplate100um, 3))>500;;
outline = h_getNucleusOutline(maxmask);
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'w-', 'linewidth',2)
end
maxmask = selection;%%%%%%%%%%%% test
outline = h_getNucleusOutline(maxmask);
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'b-', 'linewidth',1)
end



% Update main Image %
% This makes the striatum projections yellow with a green outline, non-striatal projections red, injection sites yellow with a black outline and submask a black dashed outline
avgImg(:, :, 1) = averageTemplate100um(:, :, k)/500;
avgImg(:, :, 2) = averageTemplate100um(:, :, k)/500;
avgImg(:, :, 3) = averageTemplate100um(:, :, k)/500;
avgImg(:, :, 2) = avgImg(:, :, 2)+(logical((rotatedData.striatum3d.R.densities(:, :, k)>.005)+(rotatedData.striatum3d.L.densities(:, :, k)>.005))*10);
avgImg(:, :, 2) = avgImg(:, :, 2)+(rotatedData.injection3d.mask(:, :, k)>.05)*10;
avgImg(:, :, 1) = avgImg(:, :, 1)+(rotatedData.fullDensityMap.densities(:, :, k)>.005)*50;

maskR = rotatedData.striatum3d.R.densities(:, :, k)>.005;
maskL = rotatedData.striatum3d.L.densities(:, :, k)>.005;
maskI = rotatedData.injection3d.mask(:, :, k)>.05;
maskS = (rotatedData.striatum3d.L.mask(:, :, k)>.05)+(rotatedData.striatum3d.R.mask(:, :, k)>.05);

set(handles.axes1, 'NextPlot', 'replacechildren')
axes(handles.axes1)
imshow(avgImg, 'Border','tight')
text(10,10,[num2str(injMeta.id),' - ',num2str(k)],'Color','r');
%Outline of right projections
outline = h_getNucleusOutline(maskR(:, :));
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',2)
end
%Outline of left projections
outline = h_getNucleusOutline(maskL(:, :));
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',2)
end
%Outline of Injection
outline = h_getNucleusOutline(maskI(:, :));
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',1)
end
% Plot the submask outline on the image 
subOutline = h_getNucleusOutline(submask(:,:,k));
for j = 1:length(subOutline)
    plot((subOutline{j}(:,2)), (subOutline{j}(:,1)), 'b--', 'linewidth',2)
end


guidata(hObject,handles);       %%% This is super important: you have to do this after updating a handle or it wont save!


% --- Executes on button press in pushbutton7.
%%%%%%%%  ADD to submask: all LATERAL slices   %%%%%%%%%%%%%%%
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
k = handles.section;

injMeta = handles.injMeta;
submask = handles.submask;
rotatedData = handles.rotatedData; 
averageTemplate100um = handles.averageTemplate100um; 


img = logical((squeeze(sum((rotatedData.striatum3d.R.densities>0.005), 2)))+(squeeze(sum((rotatedData.striatum3d.L.densities>0.005), 2))));  
set(handles.axes3, 'NextPlot', 'replacechildren')
axes(handles.axes3)

% Select an ROI %
roi1= imfreehand(gca);
roiapi=iptgetapi(roi1);
roipoints= roiapi.getPosition();
selection= roipoly(img, roipoints(:,1), roipoints(:,2));

% Rotate the submask, apply the ROI to all section, then rotate back
temp = submask; 
X = temp; % ROTATE
s = size(X); % size vector
v = [1, 3, 2]; 
Y = reshape( X(:,:), s);
Y = permute( Y, v );
temp = Y;
for j = 1:size(temp, 3) %APPLY ROI
    temp(:,:,j)= temp(:,:,j)+selection; %%%% This is the addition bit
end
X = temp; % ROTATE BACK
s = size(X); % size vector
v = [1, 3, 2]; 
Y = reshape( X(:,:), s);
Y = permute( Y, v );
temp = Y;

submask = temp;

delete(roi1)

handles.submask = submask; 

rotatedData.striatum3d.R.densities = rotatedData.striatum3d.R.densities.*~submask;
rotatedData.striatum3d.L.densities = rotatedData.striatum3d.L.densities.*~submask;


%LATERAL
img = logical((squeeze(sum((rotatedData.striatum3d.R.densities>0.005), 2)))+(squeeze(sum((rotatedData.striatum3d.L.densities>0.005), 2))));  
imshow(img)
hold on
maxmask = squeeze(sum(rotatedData.striatum3d.R.mask, 2))+squeeze(sum(rotatedData.striatum3d.L.mask, 2));
outline = h_getNucleusOutline(maxmask);
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'r-', 'linewidth',1)
end
maxmask = squeeze(sum(averageTemplate100um, 2))>500;;
outline = h_getNucleusOutline(maxmask);
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'w-', 'linewidth',2)
end
maxmask = selection;%%%%%%%%%%%% test
outline = h_getNucleusOutline(maxmask);
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'b-', 'linewidth',1)
end


% Update main Image %
% This makes the striatum projections yellow with a green outline, non-striatal projections red, injection sites yellow with a black outline and submask a black dashed outline
avgImg(:, :, 1) = averageTemplate100um(:, :, k)/500;
avgImg(:, :, 2) = averageTemplate100um(:, :, k)/500;
avgImg(:, :, 3) = averageTemplate100um(:, :, k)/500;
avgImg(:, :, 2) = avgImg(:, :, 2)+(logical((rotatedData.striatum3d.R.densities(:, :, k)>.005)+(rotatedData.striatum3d.L.densities(:, :, k)>.005))*10);
avgImg(:, :, 2) = avgImg(:, :, 2)+(rotatedData.injection3d.mask(:, :, k)>.05)*10;
avgImg(:, :, 1) = avgImg(:, :, 1)+(rotatedData.fullDensityMap.densities(:, :, k)>.005)*50;

maskR = rotatedData.striatum3d.R.densities(:, :, k)>.005;
maskL = rotatedData.striatum3d.L.densities(:, :, k)>.005;
maskI = rotatedData.injection3d.mask(:, :, k)>.05;
maskS = (rotatedData.striatum3d.L.mask(:, :, k)>.05)+(rotatedData.striatum3d.R.mask(:, :, k)>.05);

set(handles.axes1, 'NextPlot', 'replacechildren')
axes(handles.axes1)
imshow(avgImg, 'Border','tight')
text(10,10,[num2str(injMeta.id),' - ',num2str(k)],'Color','r');
%Outline of right projections
outline = h_getNucleusOutline(maskR(:, :));
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',2)
end
%Outline of left projections
outline = h_getNucleusOutline(maskL(:, :));
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',2)
end
%Outline of Injection
outline = h_getNucleusOutline(maskI(:, :));
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',1)
end
% Plot the submask outline on the image 
subOutline = h_getNucleusOutline(submask(:,:,k));
for j = 1:length(subOutline)
    plot((subOutline{j}(:,2)), (subOutline{j}(:,1)), 'b--', 'linewidth',2)
end


guidata(hObject,handles);       %%% This is super important: you have to do this after updating a handle or it wont save!


% --- Executes on button press in pushbutton8.
%%%%%%%%  ADD to submask: all DORSAL slices   %%%%%%%%%%%%%%%
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
k = handles.section;

injMeta = handles.injMeta;
submask = handles.submask;
rotatedData = handles.rotatedData; 
averageTemplate100um = handles.averageTemplate100um; 


img = logical((squeeze(sum((rotatedData.striatum3d.R.densities>0.005), 1)))+(squeeze(sum((rotatedData.striatum3d.L.densities>0.005), 1))));  
set(handles.axes2, 'NextPlot', 'replacechildren')
axes(handles.axes2)

% Select an ROI %
roi1= imfreehand(gca);
roiapi=iptgetapi(roi1);
roipoints= roiapi.getPosition();
selection= roipoly(img, roipoints(:,1), roipoints(:,2));

% Rotate the submask, apply the ROI to all section, then rotate back
temp = submask; 
X = temp; % ROTATE
s = size(X); % size vector
v = [2, 3, 1]; 
Y = reshape( X(:,:), s);
Y = permute( Y, v );
temp = Y;
for j = 1:size(temp, 3) %APPLY ROI
    temp(:,:,j)= temp(:,:,j)+selection; %%%% This is the addition bit
end
X = temp; % ROTATE BACK
s = size(X); % size vector
v = [3, 1, 2]; 
Y = reshape( X(:,:), s);
Y = permute( Y, v );
temp = Y;

submask = temp;

delete(roi1)

handles.submask = submask; 

rotatedData.striatum3d.R.densities = rotatedData.striatum3d.R.densities.*~submask;
rotatedData.striatum3d.L.densities = rotatedData.striatum3d.L.densities.*~submask;


%DORSAL
img = logical((squeeze(sum((rotatedData.striatum3d.R.densities>0.005), 1)))+(squeeze(sum((rotatedData.striatum3d.L.densities>0.005), 1))));  
imshow(img)
hold on
maxmask = squeeze(sum(rotatedData.striatum3d.R.mask, 1))+squeeze(sum(rotatedData.striatum3d.L.mask, 1));
outline = h_getNucleusOutline(maxmask);
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'r-', 'linewidth',1)
end
maxmask = squeeze(sum(averageTemplate100um, 1))>500;
outline = h_getNucleusOutline(maxmask);
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'w-', 'linewidth',2)
end
maxmask = selection;%%%%%%%%%%%% test
outline = h_getNucleusOutline(maxmask);
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'b-', 'linewidth',1)
end

% Update main Image %
% This makes the striatum projections yellow with a green outline, non-striatal projections red, injection sites yellow with a black outline and submask a black dashed outline
avgImg(:, :, 1) = averageTemplate100um(:, :, k)/500;
avgImg(:, :, 2) = averageTemplate100um(:, :, k)/500;
avgImg(:, :, 3) = averageTemplate100um(:, :, k)/500;
avgImg(:, :, 2) = avgImg(:, :, 2)+(logical((rotatedData.striatum3d.R.densities(:, :, k)>.005)+(rotatedData.striatum3d.L.densities(:, :, k)>.005))*10);
avgImg(:, :, 2) = avgImg(:, :, 2)+(rotatedData.injection3d.mask(:, :, k)>.05)*10;
avgImg(:, :, 1) = avgImg(:, :, 1)+(rotatedData.fullDensityMap.densities(:, :, k)>.005)*50;

maskR = rotatedData.striatum3d.R.densities(:, :, k)>.005;
maskL = rotatedData.striatum3d.L.densities(:, :, k)>.005;
maskI = rotatedData.injection3d.mask(:, :, k)>.05;
maskS = (rotatedData.striatum3d.L.mask(:, :, k)>.05)+(rotatedData.striatum3d.R.mask(:, :, k)>.05);

set(handles.axes1, 'NextPlot', 'replacechildren')
axes(handles.axes1)
imshow(avgImg, 'Border','tight')
text(10,10,[num2str(injMeta.id),' - ',num2str(k)],'Color','r');
%Outline of right projections
outline = h_getNucleusOutline(maskR(:, :));
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',2)
end
%Outline of left projections
outline = h_getNucleusOutline(maskL(:, :));
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',2)
end
%Outline of Injection
outline = h_getNucleusOutline(maskI(:, :));
hold on
for j = 1:length(outline)
plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',1)
end
% Plot the submask outline on the image 
subOutline = h_getNucleusOutline(submask(:,:,k));
for j = 1:length(subOutline)
    plot((subOutline{j}(:,2)), (subOutline{j}(:,1)), 'b--', 'linewidth',2)
end


guidata(hObject,handles);       %%% This is super important: you have to do this after updating a handle or it wont save!

