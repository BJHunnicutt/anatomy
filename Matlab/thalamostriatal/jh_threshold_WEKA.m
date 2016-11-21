function varargout = jh_threshold_WEKA(varargin)
% JH_THRESHOLD_WEKA MATLAB code for jh_threshold_WEKA.fig
%      JH_THRESHOLD_WEKA, by itself, creates a new JH_THRESHOLD_WEKA or raises the existing
%      singleton*.
%
%      H = JH_THRESHOLD_WEKA returns the handle to a new JH_THRESHOLD_WEKA or the handle to
%      the existing singleton*.
%
%      JH_THRESHOLD_WEKA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in JH_THRESHOLD_WEKA.M with the given input arguments.
%
%      JH_THRESHOLD_WEKA('Property','Value',...) creates a new JH_THRESHOLD_WEKA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before jh_threshold_WEKA_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to jh_threshold_WEKA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help jh_threshold_WEKA

% Last Modified by GUIDE v2.5 16-Mar-2015 17:09:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @jh_threshold_WEKA_OpeningFcn, ...
                   'gui_OutputFcn',  @jh_threshold_WEKA_OutputFcn, ...
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


% --- Executes just before jh_threshold_WEKA is made visible.
function jh_threshold_WEKA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to jh_threshold_WEKA (see VARARGIN)

% Choose default command line output for jh_threshold_WEKA
handles.output = hObject;


% Start with section 50 and show the section image only
load masteralign2
load str/strdata.mat
load str/strmask.mat

if isfield(WEKA.threshold, 'redHigh')
    handles.redHighThresh = WEKA.threshold.redHigh;
    handles.redLowThresh = WEKA.threshold.redLow;
end
if isfield(WEKA.threshold, 'greenHigh')
    handles.greenHighThresh = WEKA.threshold.greenHigh;
    handles.greenLowThresh = WEKA.threshold.greenLow;
end

masksize = size(strmask);
k =50;
handles.newslice = k;
nano=imread(['tiffs/',masteralign(k).name]);
% nano=imread('/Users/jeaninehunnicutt/Desktop/ThalamusTestData/075917_thalamus_tiffs/075917-11_082.tiff');

set(handles.axes1, 'NextPlot', 'replacechildren')
axes(handles.axes1)
imshow(nano*6)
xlim([350 2800])
ylim([650 2200])
text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');

hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
outline = h_getNucleusOutline(strmask(:,:,k-strstrt+1));;
for j = 1:length(outline)
    plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
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
    placeholder = zeros(masksize(1:2));
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


% Create the threshold masks for the saves thresholds so they're ready whenthe view checkbox is clicked
if ~exist(['str/WEKAoutput/probabilities_maskedStr_red_', num2str(k), '.tif'])
    display('********No RED probability tiffs exist for this brain!********')
else
    probImg = imread(['str/WEKAoutput/probabilities_maskedStr_red_', num2str(k), '.tif']);
    redMaskHigh = false(2500,3500);
    redMaskLow = false(2500,3500);
    wekaPMRCropped = false((lastR-firstR+1), (lastC-firstC+1));
    mynewmask = probImg >= handles.redHighThresh/100;
    filledimg = imfill(mynewmask, 'holes');
    wekaPMRCropped(:,:,k)= filledimg;
    redMaskHigh(firstR:lastR, firstC:lastC) = wekaPMRCropped(:,:, k); 

    redMaskLow = false(2500,3500);
    wekaPMRCropped = false((lastR-firstR+1), (lastC-firstC+1));
    mynewmask = probImg >= handles.redLowThresh/100;
    filledimg = imfill(mynewmask, 'holes');
    wekaPMRCropped(:,:,k)= filledimg;
    redMaskLow(firstR:lastR, firstC:lastC) = wekaPMRCropped(:,:, k); 
    
    handles.redMaskLow = redMaskLow;
    handles.redMaskHigh = redMaskHigh;
end

if ~exist(['str/WEKAoutput/probabilities_maskedStr_green_', num2str(k), '.tif'])
    display('********No GREEN probability tiffs exist for this brain!********')
else
    probImg = imread(['str/WEKAoutput/probabilities_maskedStr_green_', num2str(k), '.tif']);
    greenMaskHigh = false(2500,3500);
    wekaPMRCropped = false((lastR-firstR+1), (lastC-firstC+1));
    mynewmask = probImg >= handles.greenHighThresh/100;
    filledimg = imfill(mynewmask, 'holes');
    wekaPMRCropped(:,:,k)= filledimg;
    greenMaskHigh(firstR:lastR, firstC:lastC) = wekaPMRCropped(:,:, k); 

    greenMaskLow = false(2500,3500);
    wekaPMRCropped = false((lastR-firstR+1), (lastC-firstC+1));
    mynewmask = probImg >= handles.greenLowThresh/100;
    filledimg = imfill(mynewmask, 'holes');
    wekaPMRCropped(:,:,k)= filledimg;
    greenMaskLow(firstR:lastR, firstC:lastC) = wekaPMRCropped(:,:, k); 

    handles.greenMaskLow = greenMaskLow;
    handles.greenMaskHigh = greenMaskHigh;
end


handles.outline = outline;


%Start be setting all progability viewing handles off with placeholder thresholds
handles.redHighStatus = 0;
handles.redLowStatus = 0;
handles.greenHighStatus = 0;
handles.greenLowStatus = 0;
% handles.redHighThresh = 90;
% handles.redLowThresh = 25;
% handles.greenHighThresh = 90;
% handles.greenLowThresh = 25;

handles.greenHighSave = 0;
handles.greenLowSave = 0;
handles.redHighSave = 0;
handles.redLowSave = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes jh_threshold_WEKA wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = jh_threshold_WEKA_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%%%%%% SECTION NUMBER SELECTION
function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.newslice= str2double(get(hObject,'String'));
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

%%%%%%% SECTION NUMBER SELECTION
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

%%%%%% SECTION NUMBER SELECTION
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load masteralign2
load str/strdata
load str/strmask

k = handles.newslice;
outline = h_getNucleusOutline(strmask(:,:,k-strstrt+1));

% Create the threshold masks for the current threshold so they're ready when view checkbox is clicked
if ~exist(['str/WEKAoutput/probabilities_maskedStr_red_', num2str(k), '.tif'])
    display('********No RED probability tiffs exist for this brain!********')
else
    probImg = imread(['str/WEKAoutput/probabilities_maskedStr_red_', num2str(k), '.tif']);
    redMaskHigh = false(2500,3500);
    wekaPMRCropped = false((lastR-firstR+1), (lastC-firstC+1));
    mynewmask = probImg >= handles.redHighThresh/100;
    filledimg = imfill(mynewmask, 'holes');
    wekaPMRCropped(:,:,k)= filledimg;
    redMaskHigh(firstR:lastR, firstC:lastC) = wekaPMRCropped(:,:, k); 

    redMaskLow = false(2500,3500);
    wekaPMRCropped = false((lastR-firstR+1), (lastC-firstC+1));
    mynewmask = probImg >= handles.redLowThresh/100;
    filledimg = imfill(mynewmask, 'holes');
    wekaPMRCropped(:,:,k)= filledimg;
    redMaskLow(firstR:lastR, firstC:lastC) = wekaPMRCropped(:,:, k);         
end

if ~exist(['str/WEKAoutput/probabilities_maskedStr_green_', num2str(k), '.tif'])
    display('********No GREEN probability tiffs exist for this brain!********')
else
    probImg = imread(['str/WEKAoutput/probabilities_maskedStr_green_', num2str(k), '.tif']);
    greenMaskHigh = false(2500,3500);
    wekaPMRCropped = false((lastR-firstR+1), (lastC-firstC+1));
    mynewmask = probImg >= handles.greenHighThresh/100;
    filledimg = imfill(mynewmask, 'holes');
    wekaPMRCropped(:,:,k)= filledimg;
    greenMaskHigh(firstR:lastR, firstC:lastC) = wekaPMRCropped(:,:, k); 

    greenMaskLow = false(2500,3500);
    wekaPMRCropped = false((lastR-firstR+1), (lastC-firstC+1));
    mynewmask = probImg >= handles.greenLowThresh/100;
    filledimg = imfill(mynewmask, 'holes');
    wekaPMRCropped(:,:,k)= filledimg;
    greenMaskLow(firstR:lastR, firstC:lastC) = wekaPMRCropped(:,:, k); 

end

img=imread(['tiffs/',masteralign(k).name]);
set(handles.axes1, 'NextPlot', 'replacechildren')
axes(handles.axes1)

% Show the red if they're selected
if exist(['str/WEKAoutput/probabilities_maskedStr_red_', num2str(k), '.tif'])
    if handles.redHighStatus == 1; 
        if handles.redLowStatus == 0; 
            img(:,:,1)= img(:,:,1) + uint16(redMaskHigh)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(redMaskHigh)*2^16;
            img(:,:,3)= uint16(redMaskHigh)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High Red Threshold: ', num2str(handles.redHighThresh)], 'Color', 'White')

            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off

        elseif handles.redLowStatus == 1;
            img(:,:,1)= img(:,:,1) + uint16(redMaskLow)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(redMaskHigh)*2^16;
            img(:,:,3)= uint16(redMaskLow)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High Red Threshold: ', num2str(handles.redHighThresh)], 'Color', 'White')
            text(550, 850, ['Low Red Threshold: ', num2str(handles.redLowThresh)], 'Color', 'Magenta')

            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off

        end            
    elseif handles.redHighStatus == 0 && handles.redLowStatus == 1;
            img(:,:,1)= img(:,:,1) + uint16(redMaskLow)*2^16;
            img(:,:,2)= img(:,:,2);
            img(:,:,3)= uint16(redMaskLow)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 850, ['Low Red Threshold: ', num2str(handles.redLowThresh)], 'Color', 'Magenta')

            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off

    end
end

% Show the green if they're clicked
if exist(['str/WEKAoutput/probabilities_maskedStr_green_', num2str(k), '.tif'])
    if handles.greenHighStatus == 1; 
        if handles.greenLowStatus == 0; 
            img(:,:,1)= img(:,:,1) + uint16(greenMaskHigh)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(greenMaskHigh)*2^16;
            img(:,:,3)= uint16(greenMaskHigh)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High green Threshold: ', num2str(handles.greenHighThresh)], 'Color', 'White')
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        elseif handles.greenLowStatus == 1;
            img(:,:,1)= img(:,:,1) + uint16(greenMaskHigh)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(greenMaskLow)*2^16;
            img(:,:,3)= uint16(greenMaskLow)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High green Threshold: ', num2str(handles.greenHighThresh)], 'Color', 'White')
            text(550, 850, ['Low green Threshold: ', num2str(handles.greenLowThresh)], 'Color', 'Cyan')
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        end            
    elseif handles.greenHighStatus == 0 && handles.greenLowStatus == 1;
        img(:,:,1)= img(:,:,1);
        img(:,:,2)= img(:,:,2) + uint16(greenMaskLow)*2^16;
        img(:,:,3)= uint16(greenMaskLow)*2^16;

        imshow(img*6)
        xlim([350 2800])
        ylim([650 2200])
        text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
        text(550, 850, ['Low green Threshold: ', num2str(handles.greenLowThresh)], 'Color', 'Cyan')

        hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
        for j = 1:length(outline)
            plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
        end
        hold off
            
    end
end

if handles.redHighStatus == 0 && handles.redLowStatus == 0 && handles.greenHighStatus == 0 && handles.greenLowStatus == 0;
    imshow(img*6)
    xlim([350 2800])
    ylim([650 2200])
    text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
    hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
    for j = 1:length(outline)
        plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
    end
    hold off
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
    
    handles.redMaskLow = redMaskLow;
    handles.redMaskHigh = redMaskHigh;        
else
    masksize = [2500 3500];
    placeholder = zeros(masksize(1:2));
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

    handles.greenMaskLow = greenMaskLow;
    handles.greenMaskHigh = greenMaskHigh;
else
    placeholder = zeros(2500, 4300);
    set(handles.axes4, 'NextPlot', 'replacechildren')
    axes(handles.axes4)
    imshow(placeholder)
    colormap('jet');
    text(1000,1000,'No GREEN Probability Image','Color','w');
end

handles.outline = outline;

guidata(hObject,handles);       %%% This is super important: you have to do this after updating a handle or it wont save!





%%%%%% RED HIGH THRESHOLD (Text input)
function edit16_Callback(hObject, eventdata, handles)   
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles.redHighThresh= str2double(get(hObject,'String'));

load str/strdata
load masteralign2

handles.viewingRedHigh = handles.redHighThresh;
k = handles.newslice;

redMaskLow = handles.redMaskLow;
outline = handles.outline;

if ~exist(['str/WEKAoutput/probabilities_maskedStr_red_', num2str(k), '.tif'])
    display('********No RED probability tiffs exist for this brain!********')
else
    probImg = imread(['str/WEKAoutput/probabilities_maskedStr_red_', num2str(k), '.tif']);
    redMaskHigh = false(2500,3500);
    wekaPMRCropped = false((lastR-firstR+1), (lastC-firstC+1));
    mynewmask = probImg >= handles.redHighThresh/100;
    filledimg = imfill(mynewmask, 'holes');
    wekaPMRCropped(:,:,k)= filledimg;
    redMaskHigh(firstR:lastR, firstC:lastC) = wekaPMRCropped(:,:, k); 
    
    img=imread(['tiffs/',masteralign(k).name]);
    set(handles.axes1, 'NextPlot', 'replacechildren')
    axes(handles.axes1)

    if handles.redHighStatus == 1; 
        if handles.redLowStatus == 0; 
            img(:,:,1)= img(:,:,1) + uint16(redMaskHigh)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(redMaskHigh)*2^16;
            img(:,:,3)= uint16(redMaskHigh)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High Red Threshold: ', num2str(handles.redHighThresh)], 'Color', 'White')
            
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        elseif handles.redLowStatus == 1;

            img(:,:,1)= img(:,:,1) + uint16(redMaskLow)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(redMaskHigh)*2^16;
            img(:,:,3)= uint16(redMaskLow)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High Red Threshold: ', num2str(handles.redHighThresh)], 'Color', 'White')
            text(550, 850, ['Low Red Threshold: ', num2str(handles.redLowThresh)], 'Color', 'Magenta')
            
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        end            
    elseif handles.redHighStatus == 0;
        if handles.redLowStatus == 0; 

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        elseif handles.redLowStatus == 1;
            
            img(:,:,1)= img(:,:,1) + uint16(redMaskLow)*2^16;
            img(:,:,2)= img(:,:,2);
            img(:,:,3)= uint16(redMaskLow)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 850, ['Low Red Threshold: ', num2str(handles.redLowThresh)], 'Color', 'Magenta')
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        end
    end
end

handles.redMaskHigh = redMaskHigh;

guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double


%%%%%% RED HIGH THRESHOLD (Text box format)
% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%% RED HIGH THRESHOLD (View Checkbox)
% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)       
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load str/strdata
load masteralign2


k = handles.newslice;
handles.redHighStatus = get(hObject,'Value');
handles.viewingRedHigh = handles.redHighThresh;
outline = handles.outline;

redMaskLow = handles.redMaskLow;
redMaskHigh = handles.redMaskHigh;

img=imread(['tiffs/',masteralign(k).name]);
set(handles.axes1, 'NextPlot', 'replacechildren')
axes(handles.axes1)

if ~exist(['str/WEKAoutput/probabilities_maskedStr_red_', num2str(k), '.tif'])
    display('********No RED probability tiffs exist for this brain!********')
else
    if handles.redHighStatus == 1; 
       set(handles.checkbox2,'Value',0); %Turn off green checkboxes
       handles.greenHighStatus = 0;
       set(handles.checkbox3,'Value',0);
       handles.greenLowStatus = 0;
       
        if handles.redLowStatus == 0; 
            img(:,:,1)= img(:,:,1) + uint16(redMaskHigh)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(redMaskHigh)*2^16;
            img(:,:,3)= uint16(redMaskHigh)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High Red Threshold: ', num2str(handles.redHighThresh)], 'Color', 'White')
            
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        elseif handles.redLowStatus == 1;
            img(:,:,1)= img(:,:,1) + uint16(redMaskLow)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(redMaskHigh)*2^16;
            img(:,:,3)= uint16(redMaskLow)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High Red Threshold: ', num2str(handles.redHighThresh)], 'Color', 'White')
            text(550, 850, ['Low Red Threshold: ', num2str(handles.redLowThresh)], 'Color', 'Magenta')
            
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        end            
    elseif handles.redHighStatus == 0;
        if handles.redLowStatus == 0; 

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        elseif handles.redLowStatus == 1;
            img(:,:,1)= img(:,:,1) + uint16(redMaskLow)*2^16;
            img(:,:,2)= img(:,:,2);
            img(:,:,3)= uint16(redMaskLow)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 850, ['Low Red Threshold: ', num2str(handles.redLowThresh)], 'Color', 'Magenta')
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        end
    end
end


guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox7


%%%%%% RED LOW THRESHOLD (Text input)
function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.redLowThresh= str2double(get(hObject,'String'));

load str/strdata
load masteralign2

handles.viewingRedLow = handles.redLowThresh;
k = handles.newslice;
redMaskHigh = handles.redMaskHigh;
outline = handles.outline;

img=imread(['tiffs/',masteralign(k).name]);
set(handles.axes1, 'NextPlot', 'replacechildren');
axes(handles.axes1)

if ~exist(['str/WEKAoutput/probabilities_maskedStr_red_', num2str(k), '.tif'])
    display('********No RED probability tiffs exist for this brain!********')
else
    probImg = imread(['str/WEKAoutput/probabilities_maskedStr_red_', num2str(k), '.tif']);
    redMaskLow = false(2500,3500);
    wekaPMRCropped = false((lastR-firstR+1), (lastC-firstC+1));
    mynewmask = probImg >= handles.redLowThresh/100;
    filledimg = imfill(mynewmask, 'holes');
    wekaPMRCropped(:,:,k)= filledimg;
    redMaskLow(firstR:lastR, firstC:lastC) = wekaPMRCropped(:,:, k); 

    if handles.redLowStatus == 1; 
        if handles.redHighStatus == 0; 
            img(:,:,1)= img(:,:,1) + uint16(redMaskLow)*2^16;
            img(:,:,2)= img(:,:,2);
            img(:,:,3)= uint16(redMaskLow)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High Red Threshold: ', num2str(handles.redHighThresh)], 'Color', 'White')
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        elseif handles.redHighStatus == 1;            
            img(:,:,1)= img(:,:,1) + uint16(redMaskLow)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(redMaskHigh)*2^16;
            img(:,:,3)= uint16(redMaskLow)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High Red Threshold: ', num2str(handles.redHighThresh)], 'Color', 'White')
            text(550, 850, ['Low Red Threshold: ', num2str(handles.redLowThresh)], 'Color', 'Magenta')
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        end            
    elseif handles.redLowStatus == 0;
        if handles.redHighStatus == 0; 
            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        elseif handles.redHighStatus == 1; 
            img(:,:,1)= img(:,:,1) + uint16(redMaskHigh)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(redMaskHigh)*2^16;
            img(:,:,3)= uint16(redMaskHigh)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High Red Threshold: ', num2str(handles.redHighThresh)], 'Color', 'White')
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        end
    end
end

handles.redMaskLow = redMaskLow;


guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double


%%%%%% RED LOW THRESHOLD (Text box format)
% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%% RED LOW THRESHOLD (View Checkbox)
% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


load str/strdata
load masteralign2
handles.viewingRedLow = handles.redLowThresh;
k = handles.newslice;
handles.redLowStatus = get(hObject,'Value');
outline = handles.outline;
redMaskLow = handles.redMaskLow;
redMaskHigh = handles.redMaskHigh;


img=imread(['tiffs/',masteralign(k).name]);
set(handles.axes1, 'NextPlot', 'replacechildren');
axes(handles.axes1)

if ~exist(['str/WEKAoutput/probabilities_maskedStr_red_', num2str(k), '.tif'])
    display('********No RED probability tiffs exist for this brain!********')
else
    if handles.redLowStatus == 1; 
       set(handles.checkbox2,'Value',0); %Turn off green checkboxes
       handles.greenHighStatus = 0;
       set(handles.checkbox3,'Value',0);
       handles.greenLowStatus = 0;
       
        if handles.redHighStatus == 0; 
            img(:,:,1)= img(:,:,1) + uint16(redMaskLow)*2^16;
            img(:,:,2)= img(:,:,2);
            img(:,:,3)= uint16(redMaskLow)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High Red Threshold: ', num2str(handles.redHighThresh)], 'Color', 'White')
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        elseif handles.redHighStatus == 1;            
            img(:,:,1)= img(:,:,1) + uint16(redMaskLow)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(redMaskHigh)*2^16;
            img(:,:,3)= uint16(redMaskLow)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High Red Threshold: ', num2str(handles.redHighThresh)], 'Color', 'White')
            text(550, 850, ['Low Red Threshold: ', num2str(handles.redLowThresh)], 'Color', 'Magenta')
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        end            
    elseif handles.redLowStatus == 0;
        if handles.redHighStatus == 0; 
            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        elseif handles.redHighStatus == 1; 
            img(:,:,1)= img(:,:,1) + uint16(redMaskHigh)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(redMaskHigh)*2^16;
            img(:,:,3)= uint16(redMaskHigh)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High Red Threshold: ', num2str(handles.redHighThresh)], 'Color', 'White')
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        end
    end
end

guidata(hObject, handles);
    
% Hint: get(hObject,'Value') returns toggle state of checkbox6







%%%%%% GREEN HIGH THRESHOLD (Text input)
function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.greenHighThresh= str2double(get(hObject,'String'));


load str/strdata
load masteralign2

handles.viewingGreenHigh = handles.greenHighThresh;
k = handles.newslice;
greenMaskLow = handles.greenMaskLow;

outline = handles.outline;
img=imread(['tiffs/',masteralign(k).name]);
set(handles.axes1, 'NextPlot', 'replacechildren')
axes(handles.axes1)

if ~exist(['str/WEKAoutput/probabilities_maskedStr_green_', num2str(k), '.tif'])
    display('********No GREEN probability tiffs exist for this brain!********')
else
    probImg = imread(['str/WEKAoutput/probabilities_maskedStr_green_', num2str(k), '.tif']);
    greenMaskHigh = false(2500,3500);
    wekaPMRCropped = false((lastR-firstR+1), (lastC-firstC+1));
    mynewmask = probImg >= handles.greenHighThresh/100;
    filledimg = imfill(mynewmask, 'holes');
    wekaPMRCropped(:,:,k)= filledimg;
    greenMaskHigh(firstR:lastR, firstC:lastC) = wekaPMRCropped(:,:, k); 

    if handles.greenHighStatus == 1; 
        if handles.greenLowStatus == 0; 
            img(:,:,1)= img(:,:,1) + uint16(greenMaskHigh)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(greenMaskHigh)*2^16;
            img(:,:,3)= uint16(greenMaskHigh)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High green Threshold: ', num2str(handles.greenHighThresh)], 'Color', 'White')
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        elseif handles.greenLowStatus == 1;
            img(:,:,1)= img(:,:,1) + uint16(greenMaskHigh)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(greenMaskLow)*2^16;
            img(:,:,3)= uint16(greenMaskLow)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High green Threshold: ', num2str(handles.greenHighThresh)], 'Color', 'White')
            text(550, 850, ['Low green Threshold: ', num2str(handles.greenLowThresh)], 'Color', 'Cyan')
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        end            
    elseif handles.greenHighStatus == 0;
        if handles.greenLowStatus == 0; 
            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        elseif handles.greenLowStatus == 1;
            img(:,:,1)= img(:,:,1);
            img(:,:,2)= img(:,:,2) + uint16(greenMaskLow)*2^16;
            img(:,:,3)= uint16(greenMaskLow)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 850, ['Low green Threshold: ', num2str(handles.greenLowThresh)], 'Color', 'Cyan')
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        end
    end
end

handles.greenMaskHigh = greenMaskHigh;

guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double


%%%%%% GREEN HIGH THRESHOLD (Text box format)
% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%% GREEN HIGH THRESHOLD (View Checkbox)
% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


load str/strdata
load masteralign2

handles.viewingGreenHigh = handles.greenHighThresh;
k = handles.newslice;
greenMaskLow = handles.greenMaskLow;
greenMaskHigh = handles.greenMaskHigh;

outline = handles.outline;
handles.greenHighStatus = get(hObject,'Value');

img=imread(['tiffs/',masteralign(k).name]);
set(handles.axes1, 'NextPlot', 'replacechildren')
axes(handles.axes1)

if ~exist(['str/WEKAoutput/probabilities_maskedStr_green_', num2str(k), '.tif'])
    display('********No GREEN probability tiffs exist for this brain!********')
else
    if handles.greenHighStatus == 1;     
       set(handles.checkbox6,'Value',0); % Turn off the view red checkboxes
       handles.redHighStatus = 0;
       set(handles.checkbox7,'Value',0);
       handles.redLowStatus = 0;
       
        if handles.greenLowStatus == 0; 
            img(:,:,1)= img(:,:,1) + uint16(greenMaskHigh)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(greenMaskHigh)*2^16;
            img(:,:,3)= uint16(greenMaskHigh)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High green Threshold: ', num2str(handles.greenHighThresh)], 'Color', 'White')
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        elseif handles.greenLowStatus == 1;
            img(:,:,1)= img(:,:,1) + uint16(greenMaskHigh)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(greenMaskLow)*2^16;
            img(:,:,3)= uint16(greenMaskLow)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High green Threshold: ', num2str(handles.greenHighThresh)], 'Color', 'White')
            text(550, 850, ['Low green Threshold: ', num2str(handles.greenLowThresh)], 'Color', 'Cyan')
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        end            
    elseif handles.greenHighStatus == 0;
        if handles.greenLowStatus == 0; 
            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        elseif handles.greenLowStatus == 1;
            img(:,:,1)= img(:,:,1);
            img(:,:,2)= img(:,:,2) + uint16(greenMaskLow)*2^16;
            img(:,:,3)= uint16(greenMaskLow)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 850, ['Low green Threshold: ', num2str(handles.greenLowThresh)], 'Color', 'Cyan')
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        end
    end
end

guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of checkbox3



%%%%%% GREEN LOW THRESHOLD (Text input)
function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.greenLowThresh= str2double(get(hObject,'String'));

load str/strdata
load masteralign2

handles.viewingGreenLow = handles.greenLowThresh;
k = handles.newslice;
outline = handles.outline;

greenMaskHigh = handles.greenMaskHigh;

img=imread(['tiffs/',masteralign(k).name]);
set(handles.axes1, 'NextPlot', 'replacechildren')
axes(handles.axes1)
            
if ~exist(['str/WEKAoutput/probabilities_maskedStr_green_', num2str(k), '.tif'])
    display('********No GREEN probability tiffs exist for this brain!********')
else
    probImg = imread(['str/WEKAoutput/probabilities_maskedStr_green_', num2str(k), '.tif']);
    greenMaskLow = false(2500,3500);
    wekaPMRCropped = false((lastR-firstR+1), (lastC-firstC+1));
    mynewmask = probImg >= handles.greenLowThresh/100;
    filledimg = imfill(mynewmask, 'holes');
    wekaPMRCropped(:,:,k)= filledimg;
    greenMaskLow(firstR:lastR, firstC:lastC) = wekaPMRCropped(:,:, k); 

    if handles.greenLowStatus == 1; 
        if handles.greenHighStatus == 0; 
            img(:,:,1)= img(:,:,1);
            img(:,:,2)= img(:,:,2) + uint16(greenMaskLow)*2^16;
            img(:,:,3)= uint16(greenMaskLow)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High green Threshold: ', num2str(handles.greenHighThresh)], 'Color', 'White')
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        elseif handles.greenHighStatus == 1;
            img(:,:,1)= img(:,:,1) + uint16(greenMaskHigh)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(greenMaskLow)*2^16;
            img(:,:,3)= uint16(greenMaskLow)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High green Threshold: ', num2str(handles.greenHighThresh)], 'Color', 'White')
            text(550, 850, ['Low green Threshold: ', num2str(handles.greenLowThresh)], 'Color', 'Cyan')
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        end            
    elseif handles.greenLowStatus == 0;
        if handles.greenHighStatus == 0; 
            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        elseif handles.greenHighStatus == 1; 
            img(:,:,1)= img(:,:,1) + uint16(greenMaskHigh)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(greenMaskHigh)*2^16;
            img(:,:,3)= uint16(greenMaskHigh)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High green Threshold: ', num2str(handles.greenHighThresh)], 'Color', 'White')
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        end
    end
end

handles.greenMaskLow = greenMaskLow;

guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double


%%%%%% GREEN LOW THRESHOLD (Text box format)
% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%% GREEN LOW THRESHOLD (View Checkbox)
% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load str/strdata
load masteralign2

handles.viewingGreenLow = handles.greenLowThresh;
k = handles.newslice;
handles.greenLowStatus = get(hObject,'Value');
outline = handles.outline;
greenMaskLow = handles.greenMaskLow;
greenMaskHigh = handles.greenMaskHigh;

img=imread(['tiffs/',masteralign(k).name]);
set(handles.axes1, 'NextPlot', 'replacechildren')
axes(handles.axes1)

if ~exist(['str/WEKAoutput/probabilities_maskedStr_green_', num2str(k), '.tif'])
    display('********No GREEN probability tiffs exist for this brain!********')
else
    if handles.greenLowStatus == 1; 
       set(handles.checkbox6,'Value',0); % Turn off the view red checkboxes
       handles.redHighStatus = 0;
       set(handles.checkbox7,'Value',0);
       handles.redLowStatus = 0;
        if handles.greenHighStatus == 0; 
            img(:,:,1)= img(:,:,1);
            img(:,:,2)= img(:,:,2) + uint16(greenMaskLow)*2^16;
            img(:,:,3)= uint16(greenMaskLow)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High green Threshold: ', num2str(handles.greenHighThresh)], 'Color', 'White')
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        elseif handles.greenHighStatus == 1;
            img(:,:,1)= img(:,:,1) + uint16(greenMaskHigh)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(greenMaskLow)*2^16;
            img(:,:,3)= uint16(greenMaskLow)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High green Threshold: ', num2str(handles.greenHighThresh)], 'Color', 'White')
            text(550, 850, ['Low green Threshold: ', num2str(handles.greenLowThresh)], 'Color', 'Cyan')
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        end            
    elseif handles.greenLowStatus == 0;
        if handles.greenHighStatus == 0; 
            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        elseif handles.greenHighStatus == 1; 
            img(:,:,1)= img(:,:,1) + uint16(greenMaskHigh)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(greenMaskHigh)*2^16;
            img(:,:,3)= uint16(greenMaskHigh)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High green Threshold: ', num2str(handles.greenHighThresh)], 'Color', 'White')
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        end
    end
end

guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox2



%%%%%% GREEN HIGH save (Checkbox)
% --- Executes on button press in checkbox12.
function checkbox12_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.greenHighSave = get(hObject,'Value');
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox12

%%%%%% GREEN LOW save (Checkbox)
% --- Executes on button press in checkbox13.
function checkbox13_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.greenLowSave = get(hObject,'Value');
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox13

%%%%%% RED HIGH save (Checkbox)
% --- Executes on button press in checkbox14.
function checkbox14_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.redHighSave = get(hObject,'Value');
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox14

%%%%%% RED LOW save (Checkbox)
% --- Executes on button press in checkbox15.
function checkbox15_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.redLowSave = get(hObject,'Value');
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of checkbox15

%%%% no idea what this is... 
% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%% SAVES the thresholds currently set for the red/green, high/low checkboxes (#12, 13, 14, 15 above)
% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)          %%%%% Make sure to print out what was saved in the command window
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load str/strdata

display(' ')
display(' ')
display(' ')
display(' ')
display('Saving... ')

if handles.redHighSave ==1
    WEKA.threshold.redHigh = handles.redHighThresh;
    display(['RED High Saved! (', num2str(handles.redHighThresh), ')'])
end
if handles.redLowSave ==1
    WEKA.threshold.redLow = handles.redLowThresh;
    display(['RED Low Saved! (', num2str(handles.redLowThresh), ')'])
end
if handles.greenHighSave ==1
    WEKA.threshold.greenHigh = handles.greenHighThresh;
    display(['GREEN High Saved! (', num2str(handles.greenHighThresh), ')'])
end
if handles.greenLowSave ==1
    WEKA.threshold.greenLow = handles.greenLowThresh;
    display(['GREEN Low Saved (', num2str(handles.greenLowThresh), ')'])
end   
save('str/strdata','WEKA','-append');



%%%%%%%%%%%%%%%%%% WHAT WILL SAVE? BUTTON %%%%%%%%%%%%%%%%%%%
% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.checkSave = get(hObject,'Value');
if handles.redHighSave ==1 || handles.redLowSave ==1 || handles.greenHighSave ==1 || handles.greenLowSave ==1
    display(' ')
    display(' ')
    display(' ')
    display(' ')
    display('Will Save...')
end
if handles.redHighSave ==1
    display(['RED High Threshold ', num2str(handles.redHighThresh)])
    if handles.viewingRedHigh ~= handles.redHighThresh;
        display(['!! The last threshold viewed is not what will be saved !! (', num2str(handles.viewingRedHigh), ' viewed, ', num2str(handles.redHighThresh), ' saved -Red High)'])
        display(' ')
    end
end
if handles.redLowSave ==1
    display(['RED Low Threshold ', num2str(handles.redLowThresh)])    
    if handles.viewingRedLow ~= handles.redLowThresh;
        display(['!! The last threshold viewed is not what will be saved !! (', num2str(handles.viewingRedLow), ' viewed, ', num2str(handles.redLowThresh), ' saved -Red Low)'])
        display(' ')
    end
end
if handles.greenHighSave ==1
    display(['GREEN High Threshold ', num2str(handles.greenHighThresh)])
    if handles.viewingGreenHigh ~= handles.greenHighThresh;
        display(['!! The last threshold viewed is not what will be saved !! (', num2str(handles.viewingGreenHigh), ' viewed, ', num2str(handles.greenHighThresh), ' saved -Green High)'])
        display(' ')
    end
end
if handles.greenLowSave ==1
    display(['GREEN Low Threshold ', num2str(handles.greenLowThresh)])
    if handles.viewingGreenLow ~= handles.greenLowThresh;
        display(['!! The last threshold viewed is not what will be saved !! (', num2str(handles.viewingGreenLow), ' viewed, ', num2str(handles.greenLowThresh), ' saved -Green Low)'])
        display(' ')
    end
end


%%%%%%%%%%%%%%%%%% PREVIOUS BUTTON %%%%%%%%%%%%%%%%%%%
% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load masteralign2
load str/strdata
load str/strmask

k = handles.newslice-1;
outline = h_getNucleusOutline(strmask(:,:,k-strstrt+1));

% Create the threshold masks for the current threshold so they're ready when view checkbox is clicked
if ~exist(['str/WEKAoutput/probabilities_maskedStr_red_', num2str(k), '.tif'])
    display('********No RED probability tiffs exist for this brain!********')
else
    probImg = imread(['str/WEKAoutput/probabilities_maskedStr_red_', num2str(k), '.tif']);
    redMaskHigh = false(2500,3500);
    wekaPMRCropped = false((lastR-firstR+1), (lastC-firstC+1));
    mynewmask = probImg >= handles.redHighThresh/100;
    filledimg = imfill(mynewmask, 'holes');
    wekaPMRCropped(:,:,k)= filledimg;
    redMaskHigh(firstR:lastR, firstC:lastC) = wekaPMRCropped(:,:, k); 

    redMaskLow = false(2500,3500);
    wekaPMRCropped = false((lastR-firstR+1), (lastC-firstC+1));
    mynewmask = probImg >= handles.redLowThresh/100;
    filledimg = imfill(mynewmask, 'holes');
    wekaPMRCropped(:,:,k)= filledimg;
    redMaskLow(firstR:lastR, firstC:lastC) = wekaPMRCropped(:,:, k);         
end

if ~exist(['str/WEKAoutput/probabilities_maskedStr_green_', num2str(k), '.tif'])
    display('********No GREEN probability tiffs exist for this brain!********')
else
    probImg = imread(['str/WEKAoutput/probabilities_maskedStr_green_', num2str(k), '.tif']);
    greenMaskHigh = false(2500,3500);
    wekaPMRCropped = false((lastR-firstR+1), (lastC-firstC+1));
    mynewmask = probImg >= handles.greenHighThresh/100;
    filledimg = imfill(mynewmask, 'holes');
    wekaPMRCropped(:,:,k)= filledimg;
    greenMaskHigh(firstR:lastR, firstC:lastC) = wekaPMRCropped(:,:, k); 

    greenMaskLow = false(2500,3500);
    wekaPMRCropped = false((lastR-firstR+1), (lastC-firstC+1));
    mynewmask = probImg >= handles.greenLowThresh/100;
    filledimg = imfill(mynewmask, 'holes');
    wekaPMRCropped(:,:,k)= filledimg;
    greenMaskLow(firstR:lastR, firstC:lastC) = wekaPMRCropped(:,:, k); 

end

img=imread(['tiffs/',masteralign(k).name]);
set(handles.axes1, 'NextPlot', 'replacechildren')
axes(handles.axes1)

% Show the red if they're selected
if exist(['str/WEKAoutput/probabilities_maskedStr_red_', num2str(k), '.tif'])
    if handles.redHighStatus == 1; 
        if handles.redLowStatus == 0; 
            img(:,:,1)= img(:,:,1) + uint16(redMaskHigh)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(redMaskHigh)*2^16;
            img(:,:,3)= uint16(redMaskHigh)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High Red Threshold: ', num2str(handles.redHighThresh)], 'Color', 'White')

            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off

        elseif handles.redLowStatus == 1;
            img(:,:,1)= img(:,:,1) + uint16(redMaskLow)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(redMaskHigh)*2^16;
            img(:,:,3)= uint16(redMaskLow)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High Red Threshold: ', num2str(handles.redHighThresh)], 'Color', 'White')
            text(550, 850, ['Low Red Threshold: ', num2str(handles.redLowThresh)], 'Color', 'Magenta')

            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off

        end            
    elseif handles.redHighStatus == 0 && handles.redLowStatus == 1;
            img(:,:,1)= img(:,:,1) + uint16(redMaskLow)*2^16;
            img(:,:,2)= img(:,:,2);
            img(:,:,3)= uint16(redMaskLow)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 850, ['Low Red Threshold: ', num2str(handles.redLowThresh)], 'Color', 'Magenta')

            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off

    end
end

% Show the green if they're clicked
if exist(['str/WEKAoutput/probabilities_maskedStr_green_', num2str(k), '.tif'])
    if handles.greenHighStatus == 1; 
        if handles.greenLowStatus == 0; 
            img(:,:,1)= img(:,:,1) + uint16(greenMaskHigh)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(greenMaskHigh)*2^16;
            img(:,:,3)= uint16(greenMaskHigh)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High green Threshold: ', num2str(handles.greenHighThresh)], 'Color', 'White')
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        elseif handles.greenLowStatus == 1;
            img(:,:,1)= img(:,:,1) + uint16(greenMaskHigh)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(greenMaskLow)*2^16;
            img(:,:,3)= uint16(greenMaskLow)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High green Threshold: ', num2str(handles.greenHighThresh)], 'Color', 'White')
            text(550, 850, ['Low green Threshold: ', num2str(handles.greenLowThresh)], 'Color', 'Cyan')
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        end            
    elseif handles.greenHighStatus == 0 && handles.greenLowStatus == 1;
        img(:,:,1)= img(:,:,1);
        img(:,:,2)= img(:,:,2) + uint16(greenMaskLow)*2^16;
        img(:,:,3)= uint16(greenMaskLow)*2^16;

        imshow(img*6)
        xlim([350 2800])
        ylim([650 2200])
        text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
        text(550, 850, ['Low green Threshold: ', num2str(handles.greenLowThresh)], 'Color', 'Cyan')

        hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
        for j = 1:length(outline)
            plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
        end
        hold off
            
    end
end

if handles.redHighStatus == 0 && handles.redLowStatus == 0 && handles.greenHighStatus == 0 && handles.greenLowStatus == 0;
    imshow(img*6)
    xlim([350 2800])
    ylim([650 2200])
    text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
    hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
    for j = 1:length(outline)
        plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
    end
    hold off
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
    
    handles.redMaskLow = redMaskLow;
    handles.redMaskHigh = redMaskHigh;        
else
    masksize = [2500 3500];
    placeholder = zeros(masksize(1:2));
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
    
    handles.greenMaskLow = greenMaskLow;
    handles.greenMaskHigh = greenMaskHigh;
else
    placeholder = zeros(2500, 4300);
    set(handles.axes4, 'NextPlot', 'replacechildren')
    axes(handles.axes4)
    imshow(placeholder)
    colormap('jet');
    text(1000,1000,'No GREEN Probability Image','Color','w');
end

handles.outline = outline;

handles.newslice = double(k);

guidata(hObject,handles);       %%% This is super important: you have to do this after updating a handle or it wont save!


%%%%%%%%%%%%%%%%%% NEXT BUTTON %%%%%%%%%%%%%%%%%%%
% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load masteralign2
load str/strdata
load str/strmask

k = handles.newslice+1;
outline = h_getNucleusOutline(strmask(:,:,k-strstrt+1));

% Create the threshold masks for the current threshold so they're ready when view checkbox is clicked
if ~exist(['str/WEKAoutput/probabilities_maskedStr_red_', num2str(k), '.tif'])
    display('********No RED probability tiffs exist for this brain!********')
else
    probImg = imread(['str/WEKAoutput/probabilities_maskedStr_red_', num2str(k), '.tif']);
    redMaskHigh = false(2500,3500);
    wekaPMRCropped = false((lastR-firstR+1), (lastC-firstC+1));
    mynewmask = probImg >= handles.redHighThresh/100;
    filledimg = imfill(mynewmask, 'holes');
    wekaPMRCropped(:,:,k)= filledimg;
    redMaskHigh(firstR:lastR, firstC:lastC) = wekaPMRCropped(:,:, k); 

    redMaskLow = false(2500,3500);
    wekaPMRCropped = false((lastR-firstR+1), (lastC-firstC+1));
    mynewmask = probImg >= handles.redLowThresh/100;
    filledimg = imfill(mynewmask, 'holes');
    wekaPMRCropped(:,:,k)= filledimg;
    redMaskLow(firstR:lastR, firstC:lastC) = wekaPMRCropped(:,:, k);         
end

if ~exist(['str/WEKAoutput/probabilities_maskedStr_green_', num2str(k), '.tif'])
    display('********No GREEN probability tiffs exist for this brain!********')
else
    probImg = imread(['str/WEKAoutput/probabilities_maskedStr_green_', num2str(k), '.tif']);
    greenMaskHigh = false(2500,3500);
    wekaPMRCropped = false((lastR-firstR+1), (lastC-firstC+1));
    mynewmask = probImg >= handles.greenHighThresh/100;
    filledimg = imfill(mynewmask, 'holes');
    wekaPMRCropped(:,:,k)= filledimg;
    greenMaskHigh(firstR:lastR, firstC:lastC) = wekaPMRCropped(:,:, k); 

    greenMaskLow = false(2500,3500);
    wekaPMRCropped = false((lastR-firstR+1), (lastC-firstC+1));
    mynewmask = probImg >= handles.greenLowThresh/100;
    filledimg = imfill(mynewmask, 'holes');
    wekaPMRCropped(:,:,k)= filledimg;
    greenMaskLow(firstR:lastR, firstC:lastC) = wekaPMRCropped(:,:, k); 

end

img=imread(['tiffs/',masteralign(k).name]);
set(handles.axes1, 'NextPlot', 'replacechildren')
axes(handles.axes1)

% Show the red if they're selected
if exist(['str/WEKAoutput/probabilities_maskedStr_red_', num2str(k), '.tif'])
    if handles.redHighStatus == 1; 
        if handles.redLowStatus == 0; 
            img(:,:,1)= img(:,:,1) + uint16(redMaskHigh)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(redMaskHigh)*2^16;
            img(:,:,3)= uint16(redMaskHigh)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High Red Threshold: ', num2str(handles.redHighThresh)], 'Color', 'White')

            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off

        elseif handles.redLowStatus == 1;
            img(:,:,1)= img(:,:,1) + uint16(redMaskLow)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(redMaskHigh)*2^16;
            img(:,:,3)= uint16(redMaskLow)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High Red Threshold: ', num2str(handles.redHighThresh)], 'Color', 'White')
            text(550, 850, ['Low Red Threshold: ', num2str(handles.redLowThresh)], 'Color', 'Magenta')

            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off

        end            
    elseif handles.redHighStatus == 0 && handles.redLowStatus == 1;
            img(:,:,1)= img(:,:,1) + uint16(redMaskLow)*2^16;
            img(:,:,2)= img(:,:,2);
            img(:,:,3)= uint16(redMaskLow)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 850, ['Low Red Threshold: ', num2str(handles.redLowThresh)], 'Color', 'Magenta')

            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off

    end
end

% Show the green if they're clicked
if exist(['str/WEKAoutput/probabilities_maskedStr_green_', num2str(k), '.tif'])
    if handles.greenHighStatus == 1; 
        if handles.greenLowStatus == 0; 
            img(:,:,1)= img(:,:,1) + uint16(greenMaskHigh)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(greenMaskHigh)*2^16;
            img(:,:,3)= uint16(greenMaskHigh)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High green Threshold: ', num2str(handles.greenHighThresh)], 'Color', 'White')
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        elseif handles.greenLowStatus == 1;
            img(:,:,1)= img(:,:,1) + uint16(greenMaskHigh)*2^16;
            img(:,:,2)= img(:,:,2) + uint16(greenMaskLow)*2^16;
            img(:,:,3)= uint16(greenMaskLow)*2^16;

            imshow(img*6)
            xlim([350 2800])
            ylim([650 2200])
            text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
            text(550, 800, ['High green Threshold: ', num2str(handles.greenHighThresh)], 'Color', 'White')
            text(550, 850, ['Low green Threshold: ', num2str(handles.greenLowThresh)], 'Color', 'Cyan')
                        
            hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
            end
            hold off
            
        end            
    elseif handles.greenHighStatus == 0 && handles.greenLowStatus == 1;
        img(:,:,1)= img(:,:,1);
        img(:,:,2)= img(:,:,2) + uint16(greenMaskLow)*2^16;
        img(:,:,3)= uint16(greenMaskLow)*2^16;

        imshow(img*6)
        xlim([350 2800])
        ylim([650 2200])
        text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
        text(550, 850, ['Low green Threshold: ', num2str(handles.greenLowThresh)], 'Color', 'Cyan')

        hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
        for j = 1:length(outline)
            plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
        end
        hold off
            
    end
end

if handles.redHighStatus == 0 && handles.redLowStatus == 0 && handles.greenHighStatus == 0 && handles.greenLowStatus == 0;
    imshow(img*6)
    xlim([350 2800])
    ylim([650 2200])
    text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
    hold on     % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
    for j = 1:length(outline)
        plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
    end
    hold off
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
    
    handles.redMaskLow = redMaskLow;
    handles.redMaskHigh = redMaskHigh;    
else
    masksize = [2500 3500];
    placeholder = zeros(masksize(1:2));
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
    
    
    handles.greenMaskLow = greenMaskLow;
    handles.greenMaskHigh = greenMaskHigh;
else
    placeholder = zeros(2500, 4300);
    set(handles.axes4, 'NextPlot', 'replacechildren')
    axes(handles.axes4)
    imshow(placeholder)
    colormap('jet');
    text(1000,1000,'No GREEN Probability Image','Color','w');
end

handles.outline = outline;

handles.newslice = double(k);

guidata(hObject,handles);       %%% This is super important: you have to do this after updating a handle or it wont save!
