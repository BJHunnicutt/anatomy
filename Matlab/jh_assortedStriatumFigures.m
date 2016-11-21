%% Figure 1 3D rendered projections in striatum:

cd('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3')

load('AIBS_100um.mat')
load('injGroup_data.mat') %???
load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/data3/139426984/rotatedData.mat')
load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/data3/139426984/submask.mat')


strmask = rotatedData.striatum3d.L.mask+rotatedData.striatum3d.R.mask; % AIBS Model Striatum
csmask = (rotatedData.striatum3d.Full.densities).*strmask.*~submask; %Corticostriatal projections for 139426984

csmask = flipdim(csmask, 2);

fig = figure;

% View cortical injection: 139426984 in ACAd
for v = 1:4
    fig = figure;
    
    permuted = 0;
    smoothiterations = 0;
    alpha = 0.5; 
    strmask1 = cat(3, false(size(strmask,1),size(strmask,2)), strmask); %This adds 1 section at front so there isn't a hole
    color = [1 1 1];
    strH = brl_group_render_HN(strmask1,'model striatum',color*.6, permuted, smoothiterations, 0.2);
    set(strH, 'AmbientStrength', 0.2)
    hold on

    csmask1 = cat(3, false(size(csmask,1),size(csmask,2)), csmask); %This adds 1 section at front so there isn't a hole
    csmask1 = csmask1>=0.005;
    color = [0 1 0];
    brl_group_render_HN(csmask1,'0.5%',color, permuted, smoothiterations, alpha/4);

    csmask2 = cat(3, false(size(csmask,1),size(csmask,2)), csmask); %This adds 1 section at front so there isn't a hole
    csmask2 = csmask2>=0.05;
    color = [0 0.6 0];
    brl_group_render_HN(csmask2,'5%',color, permuted, smoothiterations, alpha/2.25);

    csmask3 = cat(3, false(size(csmask,1),size(csmask,2)), csmask); %This adds 1 section at front so there isn't a hole
    csmask3 = csmask3>=0.2;
    color = [.5 1 .2];
    brl_group_render_HN(csmask3,'20%',color, permuted, smoothiterations, 1);

    set(strH, 'SpecularStrength', 0)
    set(strH, 'DiffuseStrength', 0.9)

    axis image

    xlabel('A-P')
    ylabel('M-L')
    zlabel('D-V')
    
    if v == 1
    	view(270, 0) % coronal
    elseif v == 2
    	view(-90, 90) % horizontal or view(270, 0)
    elseif v == 3 
    	 view(0, 0) % sagittal
    elseif v == 4
    	view(-45, 25) % Oblique
    end
    
    camlight
end


load('inj_thalData.mat')

% View 4 thalamic injections: 075111
for v = 1:4
    fig = figure;
 
    permuted = 0;
    smoothiterations = 0;
    alpha = 0.5; 
    strmask1 = cat(3, false(size(strmask,1),size(strmask,2)), strmask); %This adds 1 section at front so there isn't a hole
    color = [1 1 1];
    strH = brl_group_render_HN(strmask1,'model striatum',color*.6, permuted, smoothiterations, 0.2);
    set(strH, 'AmbientStrength', 0.2)
    hold on
    
    for injs = 1:4
        tsmask = inj_thalData(17).projectionMasks(injs).all>0; % 075111 projmasks
        tsmask = flipdim(tsmask, 2).*strmask; %everything is showing up on the left... put it all on the right
        tsmask1 = cat(3, false(size(tsmask,1),size(tsmask,2)), tsmask); %This adds 1 section at front so there isn't a hole
       
        if sum(injs == [1 3]) >0
            tsmask1 = flipdim(tsmask1, 2); %put the left back on the left
        end
        
        
        if sum(injs == [1 2]) >0
            color = [1 0 0];
            injColor = 'red';
            alpha = 0.3;
        elseif sum(injs == [3 4]) >0
            color = [0 1 0];
            injColor = 'green';
            alpha = 0.4;
        end
        clrH = brl_group_render_HN(tsmask1,[injColor, num2str(injs)], color, permuted, smoothiterations, alpha);
%         set(clrH, 'FaceLighting', 'none')
        
    end

    set(strH, 'SpecularStrength', 0)
    set(strH, 'DiffuseStrength', 0.9)
    
    axis image
    xlabel('A-P')
    ylabel('M-L')
    zlabel('D-V')
    
    if v == 1
    	view(270, 0) % coronal
    elseif v == 2
    	view(-90, 90) % horizontal or view(270, 0)
    elseif v == 3 
    	 view(0, 0) % sagittal
    elseif v == 4
    	view(-45, 25) % Oblique
    end
    
    camlight
end


%% Examples for origin localization of thalamostriatal data

% figure; imagesc(squeeze(sum(inj_thalData(46).projectionMasks(2).max, 3)))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%% Load initial datasets / setting up directories %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Where is the analyzed corticostriatal data folder (jh_consolidatingAIBSdatasets.m output)?')
% likely here: '/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed4'
anaDir= uigetdir('/', 'Where is the analyzed corticostriatal data folder?');
cd(anaDir)

disp('Where are the collected masks?')
randomMasksDir = uigetdir('Where are the collected masks?');

%Some things to load first if I'm not going to redo it all:
load([anaDir, '/data_pImport.mat']) % Import variable from jh_pImport2matlab.m: data  %% Just used to get fNames then deleted
load([randomMasksDir, '/averageTemplate100umACA_rotated.mat']) % Import averageTemplate100umACA_rotated
load([randomMasksDir, '/averageTemplate100um_rotated.mat']) % Import variable from jh_pImport2matlab.m: averageTemplate100um_rotated
load([randomMasksDir, '/strmask_ic_submask.mat']) %I made a mask that removes the internal capsule
load([randomMasksDir, '/AIBS_100um.mat'])  %this was made later, but can replace a lot of missing things if needed
ic_submask = submask;

% Data generated in jh_consolidatingAIBSdatasets.m
% load([anaDir, '/injGroup_data.mat']) 
load([anaDir, '/inj_data.mat'])
% load([anaDir, '/inj_thalData.mat'])

%%%%%%%%%%%%%%%%%%%% Prep the projection data %%%%%%%%%%%%%%%%%%%%%%%%

confidenceLevels = 3;

modelStriatum = (rotatedData.striatum3d.L.mask+rotatedData.striatum3d.R.mask).*~ic_submask;
corticalGroup = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'SS', 'Vis', 'SUB_HIPP', 'Amyg', 'SNr', 'na'};

% This determines the density threshold used throughout the remaining analysis steps!
for i = 1:length(corticalGroup) %%%%%%%%%%%%% Change this if you want to view different thresholds (Using 0.5%, 5% and 15% right now) %%%%%%%%%%%%%%%%%%%%%%%
    c1 = injGroup_data(i).mask1.ipsilateral + injGroup_data(i).mask1.contralateral;
    c2 = injGroup_data(i).mask2.ipsilateral + injGroup_data(i).mask2.contralateral;  % Trying a change 5/9/15 was 2
    c3 = injGroup_data(i).mask5.ipsilateral + injGroup_data(i).mask5.contralateral;  % Trying a change 5/9/15 was 4
    if confidenceLevels == 1;     %This essentially determines the number of confidence levels used for clustering.
        cMapInModel2{i} = double(c1);
    elseif confidenceLevels == 2;
        cMapInModel2{i} = c1 + c3; 
    elseif confidenceLevels == 3;
        cMapInModel2{i} = c1 + c2 + c3;
    end
end

smallmodel = modelStriatum;
downsampledProjMask = cMapInModel2; % NOTE: Don't take this name literally, I'm now waiting to downsample until later 

%%%%%%%%%%%%%%%%%%%% Now make the images %%%%%%%%%%%%%%%%%%%%%%%%

% targetDir = ('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/');
cd(anaDir)

g = 7; % only doing this for MOp
mkdir([anaDir, '/thalamicLocalizationMethodFig/slices/',injGroup_data(g).cortical_group])
mkdir([anaDir, '/thalamicLocalizationMethodFig/data/',injGroup_data(g).cortical_group])

example_brains = [10 55];

for b = 1:length(example_brains)
    brain = example_brains(b);
    for inj = 1:4
        for projValue = 1:3
            mkdir([anaDir, '/thalamicLocalizationMethodFig/slices/',injGroup_data(g).cortical_group, '/', num2str(inj_thalData(brain).expID), '/injection', num2str(inj)])
            for i = 35:78 %This is strstrt to strnd     %1:length(smallmodel);

            % This just makes the mask with the outline 
                if projValue == 1
                    currentSlice = inj_thalData(brain).projectionMasks(inj).all(:, :, i);
                    mkdir([anaDir, '/thalamicLocalizationMethodFig/slices/',injGroup_data(g).cortical_group, '/', num2str(inj_thalData(brain).expID), '/injection', num2str(inj), '/all'])
                    saveDir = ([anaDir, '/thalamicLocalizationMethodFig/slices/',injGroup_data(g).cortical_group, '/', num2str(inj_thalData(brain).expID), '/injection', num2str(inj), '/all']);
                elseif projValue == 2
                    currentSlice = inj_thalData(brain).projectionMasks(inj).mid(:, :, i);
                    mkdir([anaDir, '/thalamicLocalizationMethodFig/slices/',injGroup_data(g).cortical_group, '/', num2str(inj_thalData(brain).expID), '/injection', num2str(inj), '/mid']) 
                    
                    saveDir = ([anaDir, '/thalamicLocalizationMethodFig/slices/',injGroup_data(g).cortical_group, '/', num2str(inj_thalData(brain).expID), '/injection', num2str(inj), '/mid']);
                elseif projValue == 3
                    currentSlice = inj_thalData(brain).projectionMasks(inj).max(:, :, i);
                    mkdir([anaDir, '/thalamicLocalizationMethodFig/slices/',injGroup_data(g).cortical_group, '/', num2str(inj_thalData(brain).expID), '/injection', num2str(inj), '/max'])
                    saveDir = ([anaDir, '/thalamicLocalizationMethodFig/slices/',injGroup_data(g).cortical_group, '/', num2str(inj_thalData(brain).expID), '/injection', num2str(inj), '/max']);
                end
    %             currentSlice = downsampledProjMask{g}(:,:,i);
                colorImg_r = zeros(size(currentSlice));
                colorImg_g = zeros(size(currentSlice));
                colorImg_b = zeros(size(currentSlice));
            %         cmap = [0 0 1; 0 1 0; 1 0 0];  % Makes the 1:blue, 2:green, and 3:red 
            %         cmap = [0 .25 0; 0 .5 0; 0 1 0];  % Makes a scale of green
                cmap = [.25 .25 .25; .5 .5 .5; 1 1 1];  % makes a grayscale 3 channel image

                for j = 1:max(downsampledProjMask{g}(:))
    %                 BW = currentSlice==j;
                    BW = currentSlice & smallmodel(:,:,i); % Limit the thalamic projection to the boundaries of the thalamus
                    colorImg_r(BW) = cmap(j,1);
                    colorImg_g(BW) = cmap(j,2);
                    colorImg_b(BW) = cmap(j,3);
                end
                colorImg = cat(3,colorImg_r,colorImg_g,colorImg_b);
    %             fig = figure; h_imagesc(clusterMask2(:,:,i),[0,max(clusterMask2(:))]); colormap(cmap3);hold on

    %             colorImg = inj_thalData(brain).projectionMasks(inj).all(:, :, i);
    %             colormap('gray')
                fig = figure; h_imagesc(colorImg); hold on
                
                if projValue == 1
                    projOutline = h_getNucleusOutline(inj_thalData(brain).projectionMasks(inj).all(:, :, i));
                elseif projValue == 2
                    projOutline = h_getNucleusOutline(inj_thalData(brain).projectionMasks(inj).mid(:, :, i));
                elseif projValue == 3
                    projOutline = h_getNucleusOutline(inj_thalData(brain).projectionMasks(inj).max(:, :, i));
                end
                
                projOutline = h_getNucleusOutline(BW);
                    
                for j = 1:length(projOutline)
                    plot((projOutline{j}(:,2)), (projOutline{j}(:,1))+0.5, 'r-', 'linewidth',1)
                end

                outline = h_getNucleusOutline(smallmodel(:,:,i));
                for j = 1:length(outline)
                    plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',1)
                end
%                 oAIBS = h_getNucleusOutline(logical(imfill(averageTemplate100um(:, :, i)>50, 'holes')));
%                 for j = 1:length(oAIBS)
%                     plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1))+0.5, 'w-', 'linewidth',1.25)
%                 end
                oACA = h_getNucleusOutline(averageTemplateACA(:,:,i));
                for j = 1:length(oACA)
                    plot((oACA{j}(:,2)), (oACA{j}(:,1))+0.5, 'w-', 'linewidth',0.5)
                end
            %         for w = 1:length(injGroup_data(g).expID)
            %             oInj = h_getNucleusOutline(injGroup_data(g).individualInjectionMasks(w).mask(:, :, i));
            %             for j = 1:length(oInj)
            %                 plot((oInj{j}(:,2)), (oInj{j}(:,1))+0.5, 'Color', injGroup_data(g).color, 'linewidth',0.5)
            %             end
            %         end
                hold off
                if saveFlag == 1
                    saveas(fig, [saveDir, '/thalamostriatalProjection_',num2str(inj_thalData(brain).expID), '_slice',num2str(i),'.fig'], 'fig');
                    print(fig, [saveDir, '/thalamostriatalProjection_', num2str(inj_thalData(brain).expID), '_slice',num2str(i), '.eps'], '-depsc2');
                    close(fig)
                end
    %             close(fig)
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Examples for origin localization of corticostriatal data

saveFlag = 1;

disp('Where is the analyzed corticostriatal data folder (jh_consolidatingAIBSdatasets.m output)?')
% likely here: '/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed4'
anaDir= uigetdir('/', 'Where is the analyzed corticostriatal data folder?');
cd(anaDir)
% load('injGroup_data.mat')

cd ..
cd 'data3'
dataDir = cd;


disp('Where are the collected masks?')
randomMasksDir = uigetdir('Where are the collected masks?');

thresholds = [0.005 0.05 0.2];
group = 8;

for inj = 1:length(injGroup_data(group).expID)
    load([dataDir, '/', num2str(injGroup_data(group).expID(inj)), '/rotatedData.mat'])
    load([dataDir, '/', num2str(injGroup_data(group).expID(inj)), '/injMeta.mat'])
    load([dataDir, '/', num2str(injGroup_data(group).expID(inj)), '/submask.mat'])
    mkdir([anaDir, '/Other/corticostriatal_individual/', num2str(injGroup_data(group).cortical_group), '/', num2str(injGroup_data(group).expID(inj))])

    for i = 35:78 %This is strstrt to strnd     %1:length(smallmodel);

    % This just makes the mask with the outline 
        currentSlice = (rotatedData.striatum3d.R.densities(:, :, i)+rotatedData.striatum3d.L.densities(:, :, i)).*~submask(:, :, i);
        
%             currentSlice = downsampledProjMask{g}(:,:,i);
        colorImg_r = zeros(size(currentSlice));
        colorImg_g = zeros(size(currentSlice));
        colorImg_b = zeros(size(currentSlice));
    %         cmap = [0 0 1; 0 1 0; 1 0 0];  % Makes the 1:blue, 2:green, and 3:red 
    %         cmap = [0 .25 0; 0 .5 0; 0 1 0];  % Makes a scale of green
        cmap = [.25 .25 .25; .5 .5 .5; 1 1 1];  % makes a grayscale 3 channel image
        
        for j = 1:3
            BW = currentSlice >= thresholds(j);
            BW = BW & (rotatedData.striatum3d.R.mask(:,:,i)+rotatedData.striatum3d.L.mask(:, :, i)); % Limit the projection to the boundaries of the striatum
            colorImg_r(BW) = cmap(j,1);
            colorImg_g(BW) = cmap(j,2);
            colorImg_b(BW) = cmap(j,3);
        end
        colorImg = cat(3,colorImg_r,colorImg_g,colorImg_b);
%             fig = figure; h_imagesc(clusterMask2(:,:,i),[0,max(clusterMask2(:))]); colormap(cmap3);hold on

%             colorImg = inj_thalData(brain).projectionMasks(inj).all(:, :, i);
%             colormap('gray')
        fig = figure; h_imagesc(colorImg); hold on

%         projOutline = h_getNucleusOutline(BW); % this will be for the diffuse mask (last value in thresholds)
% 
%         for j = 1:length(projOutline)
%             plot((projOutline{j}(:,2)), (projOutline{j}(:,1))+0.5, 'r-', 'linewidth',1)
%         end

        outline = h_getNucleusOutline(AIBS_100um.striatum.myMask.R.mask(:, :, i)); %Striatum outline (right)
        for j = 1:length(outline)
            plot((outline{j}(:,2)), (outline{j}(:,1)), 'w-', 'linewidth',1)
        end
        outline = h_getNucleusOutline(AIBS_100um.striatum.myMask.L.mask(:, :, i)); %Striatum outline (left)
        for j = 1:length(outline)
            plot((outline{j}(:,2)), (outline{j}(:,1)), 'w-', 'linewidth',1)
        end
        
        oACA = h_getNucleusOutline(averageTemplateACA(:,:,i));
        for j = 1:length(oACA)
            plot((oACA{j}(:,2)), (oACA{j}(:,1)), 'w-', 'linewidth',0.5)
        end

        hold off
        if saveFlag == 1
            saveas(fig, [anaDir, '/Other/corticostriatal_individual/', num2str(injGroup_data(group).cortical_group), '/', num2str(injGroup_data(group).expID(inj)), '/corticostriatalProjection_',num2str(injGroup_data(group).expID(inj)), '_slice',num2str(i),'.fig'], 'fig');
            print(fig, [anaDir, '/Other/corticostriatal_individual/', num2str(injGroup_data(group).cortical_group), '/', num2str(injGroup_data(group).expID(inj)), '/corticostriatalProjection_', num2str(injGroup_data(group).expID(inj)), '_slice',num2str(i), '.eps'], '-depsc2');
            close(fig)
        end
    end
end


%% THalamostriatal example images (FIGURE) brain 076010: 

cd('/Users/jeaninehunnicutt/Desktop/Striatum Project/Initial_Tests/StriatumTestData/76010/')

load('str/greenProjectionMask.mat')
load('str/redProjectionMask.mat')
load('str/strdata.mat')


load masteralign2
load str/strmask.mat


% Display section       % strstrt is 34, so sections 41 and 58 are 8 and 25
masksize = size(strmask);
% k = 41;
slices = [41, 58];
for i = 1:length(slices);
    k = slices(i);
    nano=imread(['str/tiffs/',masteralign(k).name]);
    % imshow(nano*30)
    % xlim([350 2800])
    % ylim([650 2200])
    % text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');

    % Plot greenmask outline - filled
    % imagesc(greenProjectionMask(:, :, k-strstrt+1)) %strstrt is 34, so sections 41 and 58 are 8 and 25
    % hold on
    % oAIBS = h_getNucleusOutline(logical(imfill(greenProjectionMask(:, :, k-strstrt+1).*strmask(:,:,k-strstrt+1), 'holes')));  %limiting the mask to the boundaries of the str
    % for j = 1:length(oAIBS)
    %     plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1))+0.5, 'g-', 'linewidth',1.25)
    % end

    % imagesc(redProjectionMask(:, :, k-strstrt+1))
    % hold on
    % oAIBS = h_getNucleusOutline(logical(imfill(redProjectionMask(:, :, k-strstrt+1).*strmask(:,:,k-strstrt+1), 'holes'))); % holes fills in the bundle holes
    % for j = 1:length(oAIBS)
    %     plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1))+0.5, 'r-', 'linewidth',1.25)
    % end

    % This will plot the striatum mask on the image too... kind of just to double check for weird problems.
    % outline = h_getNucleusOutline(strmask(:,:,k-strstrt+1));
    % for j = 1:length(outline)
    %     plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
    % end




    % Plot the low red threshold mask %%%%%%% This was the low threshold, but what was used, just did this to test making a bundle probability mask
    probImg = imread(['str/WEKAoutput/probabilities_maskedStr_red_', num2str(k), '.tif'], 1);
    redMaskLow = false(2500,3500);
    wekaPMRCropped = false((lastR-firstR+1), (lastC-firstC+1));
    mynewmask = probImg >= 50/100; % handles.redHighThresh/100;
    filledimg = imfill(mynewmask, 'holes');
    wekaPMRCropped(:,:,k)= filledimg;
    redMaskLow(firstR:lastR, firstC:lastC) = wekaPMRCropped(:,:, k); 

    % oAIBS = h_getNucleusOutline(logical(imfill((redMaskLow(:, :)+redProjectionMask(:, :, k-strstrt+1)).*strmask(:,:,k-strstrt+1))));
    % for j = 1:length(oAIBS)
    %     plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1))+0.5, 'b-', 'linewidth',1.25)
    % end


    % Plot the low green threshold mask %%%%%%% This was the low threshold, but what was used, just did this to test making a bundle probability mask
    probImg = imread(['str/WEKAoutput/probabilities_maskedStr_green_', num2str(k), '.tif'], 1);
    greenMaskLow = false(2500,3500);
    wekaPMRCropped = false((lastR-firstR+1), (lastC-firstC+1));
    mynewmask = probImg >= 30/100; % handles.redHighThresh/100;
    filledimg = imfill(mynewmask, 'holes');
    wekaPMRCropped(:,:,k)= filledimg;
    greenMaskLow(firstR:lastR, firstC:lastC) = wekaPMRCropped(:,:, k); 
    % 
    % oAIBS = h_getNucleusOutline(logical(imfill((greenMaskLow(:, :)+greenProjectionMask(:, :, k-strstrt+1)).*strmask(:,:,k-strstrt+1))));
    % for j = 1:length(oAIBS)
    %     plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1))+0.5, 'y-', 'linewidth',1.25)
    % end


    % Plot the red BUNDLE threshold mask
    probImg = imread(['str/WEKAoutput/probabilities_maskedStr_red_', num2str(k), '.tif'], 2); % 2 = Bundle prob mask
    redMaskLowBundles = false(2500,3500);
    wekaPMRCropped = false((lastR-firstR+1), (lastC-firstC+1));
    mynewmask = probImg >= 50/100; % handles.redHighThresh/100;
    filledimg = imfill(mynewmask, 'holes');
    wekaPMRCropped(:,:,k)= filledimg;
    redMaskLowBundles(firstR:lastR, firstC:lastC) = wekaPMRCropped(:,:, k); 

    % Plot the green BUNDLE threshold mask
    probImg = imread(['str/WEKAoutput/probabilities_maskedStr_green_', num2str(k), '.tif'], 2); % 2 = Bundle prob mask
    greenMaskLowBundles = false(2500,3500);
    wekaPMRCropped = false((lastR-firstR+1), (lastC-firstC+1));
    mynewmask = probImg >= 50/100; % handles.redHighThresh/100;
    filledimg = imfill(mynewmask, 'holes');
    wekaPMRCropped(:,:,k)= filledimg;
    greenMaskLowBundles(firstR:lastR, firstC:lastC) = wekaPMRCropped(:,:, k); 



    %%%%%%%%%%% Output: 
    % RED
    clr = 'red';
    fig = figure;
    imshow(nano*30); hold on;
    text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');

    oAIBS = h_getNucleusOutline(logical(redMaskLowBundles(:, :).*strmask(:,:,k-strstrt+1)));
    for j = 1:length(oAIBS)
        plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1))+0.5, 'g-', 'linewidth',1.25)
    end

    oAIBS = h_getNucleusOutline(logical(imfill((redMaskLow(:, :)+redProjectionMask(:, :, k-strstrt+1)).*strmask(:,:,k-strstrt+1), 'holes')));
    for j = 1:length(oAIBS)
        plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1))+0.5, 'b-', 'linewidth',1.25)
    end

    oAIBS = h_getNucleusOutline(logical(imfill(redProjectionMask(:, :, k-strstrt+1).*strmask(:,:,k-strstrt+1), 'holes'))); % holes fills in the bundle holes
    for j = 1:length(oAIBS)
        plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1))+0.5, 'r-', 'linewidth',1.25)
    end
    
    outline = h_getNucleusOutline(strmask(:,:,k-strstrt+1));
    for j = 1:length(outline)
        plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
    end

    hold off

    if saveFlag == 1
        saveas(fig, ['/Users/jeaninehunnicutt/Desktop/Thal_example/076010_bundleSubtractionExample_', clr,'_slice',num2str(k),'.fig'], 'fig');
        print(fig, ['/Users/jeaninehunnicutt/Desktop/Thal_example/076010_bundleSubtractionExample_', clr,'_slice',num2str(k),'.eps'], '-depsc2');
    %     close(fig)
    end

    % GREEN
    clr = 'green';
    fig2 = figure;
    imshow(nano*30); hold on;
    text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');

    oAIBS = h_getNucleusOutline(logical(greenMaskLowBundles(:, :).*strmask(:,:,k-strstrt+1)));
    for j = 1:length(oAIBS)
        plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1))+0.5, 'g-', 'linewidth',1.25)
    end

    oAIBS = h_getNucleusOutline(logical(imfill((greenMaskLow(:, :)+greenProjectionMask(:, :, k-strstrt+1)).*strmask(:,:,k-strstrt+1), 'holes')));
    for j = 1:length(oAIBS)
        plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1))+0.5, 'b-', 'linewidth',1.25)
    end

    oAIBS = h_getNucleusOutline(logical(imfill(greenProjectionMask(:, :, k-strstrt+1).*strmask(:,:,k-strstrt+1), 'holes'))); % holes fills in the bundle holes
    for j = 1:length(oAIBS)
        plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1))+0.5, 'r-', 'linewidth',1.25)
    end
    
    outline = h_getNucleusOutline(strmask(:,:,k-strstrt+1));
    for j = 1:length(outline)
        plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',2)
    end
    hold off

    if saveFlag == 1
        saveas(fig2, ['/Users/jeaninehunnicutt/Desktop/Thal_example/076010_bundleSubtractionExample_', clr,'_slice',num2str(k),'.fig'], 'fig');
        print(fig2, ['/Users/jeaninehunnicutt/Desktop/Thal_example/076010_bundleSubtractionExample_', clr,'_slice',num2str(k),'.eps'], '-depsc2');
    %     close(fig2)
    end
end


% THALAMIC INJECTIONS

load('/Users/jeaninehunnicutt/Desktop/Thal_example/InjectionSites/greenmask_skip.mat')
load('/Users/jeaninehunnicutt/Desktop/Thal_example/InjectionSites/redmask_skip.mat')
load('/Users/jeaninehunnicutt/Desktop/Thal_example/InjectionSites/thaldata.mat')


slices = [70, 86, 95];
for i = 1:length(slices);
    k = slices(i);
    nano=imread(['/Users/jeaninehunnicutt/Desktop/Striatum Project/Initial_Tests/StriatumTestData/76010/str/tiffs/',masteralign(k).name]);
    
    se = strel('disk', 25, 0);  % To erode the binary injection site mask by 100um, since the images are 8x downsampled from 0.5um/pixel => 4um/pixel & 100/4 = 25
    redmask_eroded = imerode(redmask(:, :, k-thalstrt+1), se);
    greenmask_eroded = imerode(greenmask(:, :, k-thalstrt+1), se);
    
    fig = figure;
    imshow(nano); hold on;
    text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
    p1 = [50,50]; p2 = [50,300]; % to get a 100um line, since the images are 8x downsampled from 0.5um/pixel => 4um/pixel & 1000um/4 = 250 (+50 so I don'e start the line at the very edge)
    plot([p1(2),p2(2)],[p1(1),p2(1)],'Color','w','LineWidth',2) % 1mm scale bar
    
    % Green Shell
    oAIBS = h_getNucleusOutline(logical(imfill(greenmask(:, :, k-thalstrt+1),  'holes')));
    for j = 1:length(oAIBS)
        plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1))+0.5, 'b-', 'linewidth',1.25)
    end
    % Green Core
    oAIBS = h_getNucleusOutline(logical(imfill(greenmask_eroded(:, :),  'holes')));
    for j = 1:length(oAIBS)
        plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1))+0.5, 'w-', 'linewidth',1.25)
    end
    
    % Red Shell
    oAIBS = h_getNucleusOutline(logical(imfill(redmask(:, :, k-thalstrt+1),  'holes')));
    for j = 1:length(oAIBS)
        plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1))+0.5, 'y-', 'linewidth',1.25)
    end
    % Red Core
    oAIBS = h_getNucleusOutline(logical(imfill(redmask_eroded(:, :),  'holes')));
    for j = 1:length(oAIBS)
        plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1))+0.5, 'w-', 'linewidth',1.25)
    end
    
    %%%%%%%%% Should plot thalmask too but i dont have it
    
    fig2 = figure;
    imshow(nano*10); hold on;
    text(450,750,[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)],'Color','r');
    p1 = [50,50]; p2 = [50,300]; % to get a 100um line, since the images are 8x downsampled from 0.5um/pixel => 4um/pixel & 1000um/4 = 250 (+50 so I don'e start the line at the very edge)
    plot([p1(2),p2(2)],[p1(1),p2(1)],'Color','w','LineWidth',2)
    
    if saveFlag == 1
        saveas(fig, ['/Users/jeaninehunnicutt/Desktop/Thal_example/InjectionSites/076010_injectionSites_slice',num2str(k),'.fig'], 'fig');
        print(fig, ['/Users/jeaninehunnicutt/Desktop/Thal_example/InjectionSites/076010_injectionSites_slice',num2str(k),'.eps'], '-depsc2');
        print(fig2, ['/Users/jeaninehunnicutt/Desktop/Thal_example/InjectionSites/076010_injectionSites_slice',num2str(k),'_brightImage.eps'], '-depsc2');
        
        close(fig2)
    end
    
end

% Thalamic Injection Sections:

load([anaDir, '/inj_thalData.mat']) %Loading the thalamostriatal data (it's large)

saveDir = (['/Users/jeaninehunnicutt/Desktop/Thal_example/InjectionSites/aligned_injection_slices/']);

    avgThal = false(size(inj_thalData(2).injections(2).mask)); 
    avgThal(:, :, 1:size(betteraveragethalamus, 3)) = betteraveragethalamus; 
    
    exp = 55; % This is 076010
    g = 7; % This is M1/2 i.e. MOp
    
%     group = (thalamusInj_groups(g).anyOverlap5_25.cores + thalamusInj_groups(g).anyOverlap5_25.shells + thalamusInj_groups(g).anyOverlap5.cores + thalamusInj_groups(g).anyOverlap5.shells + thalamusInj_groups(g).anyOverlap.cores + thalamusInj_groups(g).anyOverlap.shells - thalamusInj_groups(g).noOverlap.shells - thalamusInj_groups(g).noOverlap5.cores - thalamusInj_groups(g).noOverlap5.shells - thalamusInj_groups(g).noOverlap5_25.cores).*~thalamusInj_groups(g).noOverlap.cores; 
%     a = (group <= 0); % If subtraction makes it less than zero... 
%     group = group.*~a.*avgThal;
% 
%     groupFlip = flipdim(group, 2);
%     group = group + groupFlip;
    
    % Or Just...
    group = thalCtx_StriatalConvergenceOrigins(g).mask;

    for i = 1:length(inj_thalData(exp).inj_INDEX)  % Loop through injections 
        for k = 1:size(betteraveragethalamus, 3) % Look through A-P sections
            fig = figure;
            set(fig, 'Position', [1570 790 350 250])
            imshow(group(:, :, k), 'Border', 'tight')
            hold on
            title(['076010', inj_thalData(exp).inj_INDEX(i), ' Injection: section ', num2str(k)])
            colormap(gray)
            caxis([0 6]) %max(group(:))])   % ***** I had the max group when I made these the first time, i think it's ok, but I should check... 

      
            core = (inj_thalData(exp).injections(i).mask(:, :, k) > 1).*betteraveragethalamus(:, :, k);
            shell = (inj_thalData(exp).injections(i).mask(:, :, k) > 0).*betteraveragethalamus(:, :, k);
            
            se = strel('disk', 2, 0);  % To erode the binary injection site mask by 100um, since the thalamus data is downsampled from 50um/pixel & 100/50 = 2
            core_remade = imerode(shell, se);
            
           
            outline = h_getNucleusOutline(betteraveragethalamus(:, :, k)); % Thalamus
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1)), 'c-', 'linewidth',1)
            end
            
            outline = h_getNucleusOutline(shell(:, :)); % Shell
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1)), 'r-', 'linewidth',1)
            end
            
            outline = h_getNucleusOutline(core(:, :)); % Core
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1)), 'm-', 'linewidth',1)
            end
            
            outline = h_getNucleusOutline(core_remade(:, :)); % Core Re-eroded to match figure...
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1)), 'b-', 'linewidth',1)
            end
            
            hold off

            if saveFlag == 1
                saveas(fig, [saveDir,'/', num2str(i), '/thalInjs_', num2str(inj_thalData(exp).expID), '_', injGroup_data(g).cortical_group, '_section_', num2str(k), '.fig'], 'fig');
                print(fig, [saveDir,'/', num2str(i), '/thalInjs_', num2str(inj_thalData(exp).expID), '_', injGroup_data(g).cortical_group, '_section_', num2str(k), '.eps'], '-depsc2');
            end
            close(fig)
       
        end
    end
