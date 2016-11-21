function jh_consolidatingThalamusData(figFlag, saveFlag)
% [vargout] = JH_CONSOLIDATINGTHALAMUSDATA(figFlag, saveFlag) 
% 
% INPUTS: figFlag (1 or 2) 
%           1. Generate section images with striatal mask outlines (alignment check) 
%           2. Create inj_thalData : has all the thalamostriatal data in it, downsampled and aligned to the corticostriatal data
%           3. Create test figures to decide on grouping method and thalamusInj_groups.mat data 
%           4. All thalamus images for the cortical convergence group  (FIGURE)
%           5. Sections showing the thalamic origins of 1. thalamocortical (cyan), 2. cortically convergent thalamostriatal (magenta), and 3. their overlay (outlne/white) (FIGURE)
%           6. Sections showing the thalamic origins of projections convergent with striatal clusters (FIGURE)
%           7. Sections showing the thalamic origins of projections convergent with allo/meso/neo & HOTSPOT areas (FIGURE)
%           8. Calculating coverage
%           9. Determine the nuclear origins of projections from the thalamus - this generates the large array plot in thesis fig 3 and the base data for the next few plots (FIGURE)
%           10. Determine the nuclear origins of projections from the thalamus - (thalamocortical only / thalamostriatal only/ convergent) (FIGURE)
%           11. Determine the nuclear origins of projections from the thalamus - (clusters) (FIGURE)
%           12. Determine the nuclear origins of projections from the thalamus - (allo/meso/neo and hotspots) (FIGURE)
%         saveFlag (0 or 1) do you want to save all the outputs from this 
% 
% OUTPUT: all cluster related data and figures
% 
% PURPOSE: This is a series of steps to import and analyze the aligned thalamostriatal data
% 
% DEPENDENCIES: 
%     /auxillary_funcitonsAndScripts/h_getNucleusOutline.m
%     'Image Processing Toolbox' ; 'Statistics and Machine Learning Toolbox'
% 

% Load initial datasets / setting up directories %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Where is the analyzed corticostriatal data folder (jh_consolidatingAIBSdatasets.m output)?')
% likely here: '/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed4'
anaDir= uigetdir('/', 'Where is the analyzed corticostriatal data folder?');
cd(anaDir)

% cd('ThalamostriatalData_processed/')
% if ~exist('clustering/')
%     mkdir('clustering/')
% end
% saveDir = ([cd, '/clustering/']); 

% Random Manual masks that need to be collected for this to work:
disp('Where are the collected masks?')
randomMasksDir = uigetdir('/', 'Where are the collected masks?');
% randomMasksDir = '/Users/jeaninehunnicutt/Desktop/github/anatomy/Matlab/masks'; %%%%%%%%%% change to above after testing %%%%%%%%%%%%%%%%
        
load([randomMasksDir, '/AIBS_100um.mat'])
load([anaDir, '/injGroup_data.mat'])
load([anaDir, '/ThalamostriatalData_processed/ABA_average_brain/str/rotatedBrainImgLibrary/rotatedBrainImg_0_0.mat'])
load([anaDir, '/ThalamostriatalData_processed/ABA_average_brain/str/rotatedStrLibrary/rotatedMask_0_0.mat'])

currentFolder = ([anaDir, '/ThalamostriatalData_processed/processed data/']);

corticalGroup = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'SS', 'Vis', 'SUB_HIPP', 'Amyg', 'SNr', 'na'};
projAreasToKeep = corticalGroup(~ismember(corticalGroup,{'SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'na', 'SNr'}));

load([randomMasksDir, '/std thal w traced nuclei & final adj atlas_2014-03-06.mat']) %Loading the injection site thalamus data from the thalamocortical paper
% There is a 'brains' variable in the thalamus data that is loaded above, so I'm naming the next variable something other than 'brains'
finalBrains = [060536, 075019, 075032, 075034, 075036, 075074, 075075, 075077, 075078, 075083, 075086, 075106, 075107, 075108, 075109, 075110, 075111, 075112, 075115, 075117, 075118, 075120, 075121, 075122, 075123, 075124, 075126, 075127, 075128, 075129, 075130, 075131, 075132, 075133, 075087, 075912, 075914, 075915, 075916, 075917, 075918, 075919, 075920, 075924, 075925, 076001, 076002, 076003, 076004, 076005, 076006, 076007, 076008, 076009, 076010, 076012, 076013, 076014, 076015, 076016, 076018, 076019, 076020, 076024, 076025, 076027, 076028, 076029];

%% 1. Generate section images with striatal mask outlines to check the alignment of all the individual brains (FIGURE)

if figFlag == 1
    
    % When nucleus data loads at the begining it has a brains variable too, but I need this 'brains' here
    brains = [060536, 075019, 075032, 075034, 075036, 075074, 075075, 075077, 075078, 075083, 075086, 075106, 075107, 075108, 075109, 075110, 075111, 075112, 075115, 075117, 075118, 075120, 075121, 075122, 075123, 075124, 075126, 075127, 075128, 075129, 075130, 075131, 075132, 075133, 075087, 075912, 075914, 075915, 075916, 075917, 075918, 075919, 075920, 075924, 075925, 076001, 076002, 076003, 076004, 076005, 076006, 076007, 076008, 076009, 076010, 076012, 076013, 076014, 076015, 076016, 076018, 076019, 076020, 076024, 076025, 076027, 076028, 076029];

    for k = 65:5:225; % plot through every 5th striatum section
        fig = figure;
    %     imshow(rotatedBrainImg(:, :, k), 'Border','tight','InitialMagnification', 100)
        imshow(rotatedBrainImg(:, :, k),'InitialMagnification', 100)
        title(['VarScale: Section ', num2str(k)])
        hold on

        for i = 1:length(brains)
            b = brains(i);
            cd([currentFolder, '/', num2str(brains(i), '%06i')])
            load fifthAlignedMask.mat

            outline = h_getNucleusOutline(finalAdjStr(:, :, k));
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1)), 'r-', 'linewidth',1)
            end

            outline = h_getNucleusOutline(finalAdjACA(:, :, k));
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1)), 'm-', 'linewidth',1)
            end
            disp('.')
        end


        outline = h_getNucleusOutline(rotatedStrMask(:, :, k));
        hold on
        for j = 1:length(outline)
            plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',1)
        end

        if saveFlag == 1
            saveas(fig, [anaDir, '/ThalamostriatalData_processed/Thalamostriatal_testFigures/Alignment/strMaskOverlayImage_Section', num2str(k, '%03i'), '.fig'], 'fig');
            print(fig, [anaDir, '/ThalamostriatalData_processed/Thalamostriatal_testFigures/Alignment/strMaskOverlayImage_Section', num2str(k, '%03i'), '.eps'], '-depsc2');
        end
        close(fig)
    end
end


%% 2. Create a variable with all of the thalamostriatal data in it, downsampled and aligned to the corticostriatal data

if figFlag == 2
    
    % When nucleus data loads at the begining it has a brains variable too, but I need this 'brains' here
    brains = [060536, 075019, 075032, 075034, 075036, 075074, 075075, 075077, 075078, 075083, 075086, 075106, 075107, 075108, 075109, 075110, 075111, 075112, 075115, 075117, 075118, 075120, 075121, 075122, 075123, 075124, 075126, 075127, 075128, 075129, 075130, 075131, 075132, 075133, 075087, 075912, 075914, 075915, 075916, 075917, 075918, 075919, 075920, 075924, 075925, 076001, 076002, 076003, 076004, 076005, 076006, 076007, 076008, 076009, 076010, 076012, 076013, 076014, 076015, 076016, 076018, 076019, 076020, 076024, 076025, 076027, 076028, 076029];

    ic_submask = AIBS_100um.striatum.ic_submask; % I'll need to apply this to the thalamus data
    strMask_AIBS = AIBS_100um.striatum.myMask.Full.mask;
    brainMask_AIBS = AIBS_100um.brain.mask; % this is perfect, I can just look at this overlaid on the aligned image to check


    %%%%%%%%%%%%%%%%%%%%%%%%% % (TESTING & NOTES: Check the alignment by importing & downsampling the rotated averageAIBS brain
    %     load('/Users/jeaninehunnicutt/Desktop/ThalamostriatalData_processed/ABA_average_brain/str/rotatedBrainImgLibrary/rotatedBrainImg_0_0.mat')
    %     load('/Users/jeaninehunnicutt/Desktop/ThalamostriatalData_processed/ABA_average_brain/str/rotatedStrLibrary/rotatedMask_0_0.mat')
    %     load('/Users/jeaninehunnicutt/Desktop/ThalamostriatalData_processed/ABA_average_brain/str/rotatedACALibrary/rotatedACAMask_0_0.mat')
    % 
    %     [x, y, z]= meshgrid(1:456, 1:320, 1:282);  % This is the full brain
    %     [xi, yi, zi] = meshgrid(1:4:456, 1:4:320, 1:4:282); %100x100x100um voxels
    %     downsampledStrMask = round(interp3(x, y,z, double(rotatedStrMask), xi, yi, zi));  % added 'round' here to put data back to initial space.  
    %     downsampledACAMask = round(interp3(x, y,z, double(rotatedACAMask), xi, yi, zi));  % added 'round' here to put data back to initial space.  
    % 
    %     brainOutline = imfill(rotatedBrainImg(:, :, :)>10, 'holes');
    %     downsampledBrainOutline = round(interp3(x, y,z, double(brainOutline), xi, yi, zi));
    % 
    % 
    %     Hainings mask is cropped I need to place it in mine
    %         Top is in the same spot (highest point at 4)
    %         The bottom of mine is 81 and his is 80, not a big deal but need to know
    %         Haining cropped his in A-P: 
    %            -His 1 is my 22, 
    %            -his end is 71, which is my 92 (makes sense, 92-22 +1(since 22 is actually slice 1) = 71)
    %         His leftmost brain point is 7 as is mine
    %         His rightmost brain point is 109 as is mine but his mask stops at 114 and mine goes to 115
    % 
    %     full_dStrMask = false(size(strMask_AIBS));
    %     full_dBrainOutline = false(size(strMask_AIBS));
    %     full_dACAMask = false(size(strMask_AIBS));
    % 
    %     full_dStrMask(1:80, 1:114, 22:92) = downsampledStrMask;
    %     full_dBrainOutline(1:80, 1:114, 22:92) = downsampledBrainOutline;
    %     full_dACAMask(1:80, 1:114, 22:92) = downsampledACAMask;
    % 
    %     Looking at sections to compare my data (red/magenta) and Hainings data (blue/cyan)
    %     for k = 40 %:45; %size(strMask_AIBS, 3)
    %         fig = figure; 
    %         imshow(AIBS_100um.brain.images(:, :, k)./512,'InitialMagnification', 700);
    %         hold on
    %         title('My brain, mask and outlines + Hainings in blue')
    %         outline = h_getNucleusOutline(strMask_AIBS(:,:,k).*~ic_submask(:,:,k));
    %         for j = 1:length(outline)
    %             plot((outline{j}(:,2)), (outline{j}(:,1)), 'm-', 'linewidth',1)
    %         end
    %         oAIBS = h_getNucleusOutline(brainMask_AIBS(:, :, k));
    %         for j = 1:length(oAIBS)
    %             plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1)), 'r-', 'linewidth',1.1)
    %         end
    %         oAIBS = h_getNucleusOutline(full_dStrMask(:, :, k));
    %         for j = 1:length(oAIBS)
    %             plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1)), 'c-', 'linewidth',1.1)
    %         end
    %         oAIBS = h_getNucleusOutline(full_dBrainOutline(:, :, k));
    %         for j = 1:length(oAIBS)
    %             plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1)), 'b-', 'linewidth',1.1)
    %         end
    %         oAIBS = h_getNucleusOutline(full_dACAMask(:, :, k));
    %         for j = 1:length(oAIBS)
    %             plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1)), 'c-', 'linewidth',1.1)
    %         end
    %     end
    %     
    %     test2 = flipdim(strMask_AIBS&~ic_submask, 2);
    %     test2(:, 1:57, :) = 0;
    %     
    %     testACA =  flipdim(full_dACAMask, 2);
    %     testACA(:,1:57, :) = 0;
    %     
    %     Now flipping the left data across the midline... right (red/magenta) and left flipped (blue/cyan)
    %     for k = 40:45; %size(strMask_AIBS, 3)
    %         fig = figure; 
    %         imshow(AIBS_100um.brain.images(:, :, k)./512,'InitialMagnification', 700);
    %         hold on
    %         title('My brain, mask and outlines + Hainings in blue')
    %         outline = h_getNucleusOutline(strMask_AIBS(:,:,k).*~ic_submask(:,:,k));
    %         for j = 1:length(outline)
    %             plot((outline{j}(:,2)), (outline{j}(:,1)), 'm-', 'linewidth',1)
    %         end
    %         oAIBS = h_getNucleusOutline(full_dACAMask(:, :, k));
    %         for j = 1:length(oAIBS)
    %             plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1)), 'r-', 'linewidth',1.1)
    %         end
    %         oAIBS = h_getNucleusOutline(test2(:, :, k));
    %         for j = 1:length(oAIBS)
    %             plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1)), 'c-', 'linewidth',1.1)
    %         end
    %         oAIBS = h_getNucleusOutline(testACA(:, :, k));
    %         for j = 1:length(oAIBS)
    %             plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1)), 'b-', 'linewidth',1.1)
    %         end
    %     end
    %     
    %%%%%%%%%%%%%%%%%%%%%%%%%% End of checking the alignment %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Downsample and Consolidate the thalamostriatal data
    inj_thalData = []; %This will be the master variable
    for i = 1:length(brains)
        b = brains(i);
        cd([currentFolder, '/', num2str(brains(i), '%06i')])
        load fifthAlignedMask.mat

        [x, y, z]= meshgrid(1:456, 1:320, 1:282);  % This is the full brain
        [xi, yi, zi] = meshgrid(1:4:456, 1:4:320, 1:4:282); %100x100x100um voxels

        % I have no idea what threshold I will want to use, but I have to make them masks to downsample them, so I am making 3: anything, 50% and 100%
        downsampledRed_max = round(interp3(x, y,z, double(finalAdjProjR == 100), xi, yi, zi));  % added 'round' here to put data back to initial space.  
        downsampledRed_all = round(interp3(x, y,z, double(finalAdjProjR > 0), xi, yi, zi));  % added 'round' here to put data back to initial space.  
        downsampledRed_mid = round(interp3(x, y,z, double(finalAdjProjR >= 50), xi, yi, zi));  % added 'round' here to put data back to initial space.  
        downsampledGreen_max = round(interp3(x, y,z, double(finalAdjProjG == 100), xi, yi, zi));  % added 'round' here to put data back to initial space.  
        downsampledGreen_all = round(interp3(x, y,z, double(finalAdjProjG > 0), xi, yi, zi));  % added 'round' here to put data back to initial space.  
        downsampledGreen_mid = round(interp3(x, y,z, double(finalAdjProjG >= 50), xi, yi, zi));  % added 'round' here to put data back to initial space.  
        downsampledACAMask = round(interp3(x, y,z, double(finalAdjACA), xi, yi, zi));  % added 'round' here to put data back to initial space.  
        downsampledStrMask = round(interp3(x, y,z, double(finalAdjStr), xi, yi, zi));  % added 'round' here to put data back to initial space.  

        full_Red_max = zeros(size(strMask_AIBS));
        full_Red_all = zeros(size(strMask_AIBS));
        full_Red_mid = zeros(size(strMask_AIBS));
        full_Green_max = zeros(size(strMask_AIBS));
        full_Green_all = zeros(size(strMask_AIBS));
        full_Green_mid = zeros(size(strMask_AIBS));
        full_ACAMask = zeros(size(strMask_AIBS));
        full_StrMask = zeros(size(strMask_AIBS));

        rightRed.all = zeros(size(strMask_AIBS));
        rightRed.max = zeros(size(strMask_AIBS));
        rightRed.mid = zeros(size(strMask_AIBS));
        rightGreen.all = zeros(size(strMask_AIBS));
        rightGreen.max = zeros(size(strMask_AIBS));
        rightGreen.mid = zeros(size(strMask_AIBS));
        leftRed.all = zeros(size(strMask_AIBS));
        leftRed.max = zeros(size(strMask_AIBS));
        leftRed.mid = zeros(size(strMask_AIBS));
        leftGreen.all = zeros(size(strMask_AIBS));
        leftGreen.max = zeros(size(strMask_AIBS));
        leftGreen.mid = zeros(size(strMask_AIBS));


        full_Red_max(1:80, 1:114, 22:92) = downsampledRed_max;
        full_Red_all(1:80, 1:114, 22:92) = downsampledRed_all;
        full_Red_mid(1:80, 1:114, 22:92) = downsampledRed_mid;
        full_Green_max(1:80, 1:114, 22:92) = downsampledGreen_max; 
        full_Green_all(1:80, 1:114, 22:92) = downsampledGreen_all; 
        full_Green_mid(1:80, 1:114, 22:92) = downsampledGreen_mid;
        full_ACAMask(1:80, 1:114, 22:92) = downsampledACAMask; 
        full_StrMask(1:80, 1:114, 22:92) = downsampledStrMask; 

        inj_thalData(i).expID = brains(i);
        inj_thalData(i).parameters = parameters;
    %     inj_thalData(i).redMask_all = full_Red_all;  % The variable was 200mb without injections, I'm going to exclude this, since I will only use the unilateral data
    %     inj_thalData(i).redMask_max = full_Red_max;
    %     inj_thalData(i).redMask_mid = full_Red_mid;
    %     inj_thalData(i).greenMask_all = full_Green_all;
    %     inj_thalData(i).greenMask_max = full_Green_max;
    %     inj_thalData(i).greenMask_mid = full_Green_mid;
        inj_thalData(i).acaMask = full_ACAMask;
        inj_thalData(i).strMask = full_StrMask;

        for m = 1:4; 
            inj_thalData(i).projectionMasks(m).max = zeros(size(strMask_AIBS));
            inj_thalData(i).projectionMasks(m).all = zeros(size(strMask_AIBS));
            inj_thalData(i).projectionMasks(m).mid = zeros(size(strMask_AIBS));
        end

        % Flags for which injections to use & unilateral projection masks 

            % Left Red
            inj_thalData(i).projection_INDEX = {'Left Red', 'Right Red', 'Left Green', 'Right Green'}; 
            if parameters.originalStrData.projections.left.red.start == 0
                inj_thalData(i).projections(1, 1) = 0; % Subtract
            elseif parameters.originalStrData.projections.left.red.start == -1
                inj_thalData(i).projections(1, 1) = -1; % Ignore (don't add or subtract)
            else 
                inj_thalData(i).projections(1, 1) = 1; % Add or subtract based on projections

                leftRed.all = flipdim(full_Red_all, 2);  % Flip the left mask across the midline
                leftRed.all(:, 1:57, :) = 0;            % And make the contra mask blank
                leftRed.max = flipdim(full_Red_max, 2);
                leftRed.max(:, 1:57, :) = 0;
                leftRed.mid = flipdim(full_Red_mid, 2);
                leftRed.mid(:, 1:57, :) = 0;
                inj_thalData(i).projectionMasks(1).max = leftRed.max;
                inj_thalData(i).projectionMasks(1).all = leftRed.all;
                inj_thalData(i).projectionMasks(1).mid = leftRed.mid;
            end

            % Right Red
            if parameters.originalStrData.projections.right.red.start == 0
                inj_thalData(i).projections(1, 2) = 0;
            elseif parameters.originalStrData.projections.right.red.start == -1
                inj_thalData(i).projections(1, 2) = -1;
            else 
                inj_thalData(i).projections(1, 2) = 1;

                rightRed.all = full_Red_all;  
                rightRed.all(:, 1:57, :) = 0; % And make the contra mask blank
                rightRed.max = full_Red_max;
                rightRed.max(:, 1:57, :) = 0;
                rightRed.mid = full_Red_mid;
                rightRed.mid(:, 1:57, :) = 0;
                inj_thalData(i).projectionMasks(2).max = rightRed.max;
                inj_thalData(i).projectionMasks(2).all = rightRed.all;
                inj_thalData(i).projectionMasks(2).mid = rightRed.mid;
            end

            % Left Green
            if parameters.originalStrData.projections.left.green.start == 0
                inj_thalData(i).projections(1, 3) = 0;
            elseif parameters.originalStrData.projections.left.green.start == -1
                inj_thalData(i).projections(1, 3) = -1;
            else 
                inj_thalData(i).projections(1, 3) = 1;

                leftGreen.all = flipdim(full_Green_all, 2);  % Flip the left mask across the midline
                leftGreen.all(:, 1:57, :) = 0;            % And make the contra mask blank
                leftGreen.max = flipdim(full_Green_max, 2);
                leftGreen.max(:, 1:57, :) = 0;
                leftGreen.mid = flipdim(full_Green_mid, 2);
                leftGreen.mid(:, 1:57, :) = 0;
                inj_thalData(i).projectionMasks(3).max = leftGreen.max;
                inj_thalData(i).projectionMasks(3).all = leftGreen.all;
                inj_thalData(i).projectionMasks(3).mid = leftGreen.mid;
            end

            % Right Green
            if parameters.originalStrData.projections.right.green.start == 0
                inj_thalData(i).projections(1, 4) = 0;
            elseif parameters.originalStrData.projections.right.green.start == -1
                inj_thalData(i).projections(1, 4) = -1;
            else 
                inj_thalData(i).projections(1, 4) = 1;

                rightGreen.all = full_Green_all;  
                rightGreen.all(:, 1:57, :) = 0; % And make the contra mask blank
                rightGreen.max = full_Green_max;
                rightGreen.max(:, 1:57, :) = 0;
                rightGreen.mid = full_Green_mid;
                rightGreen.mid(:, 1:57, :) = 0;
                inj_thalData(i).projectionMasks(4).max = rightGreen.max;
                inj_thalData(i).projectionMasks(4).all = rightGreen.all;
                inj_thalData(i).projectionMasks(4).mid = rightGreen.mid;
            end

    %     clearvars -except i brains currentFolder inj_thalData 
    end

    % 
    % for k = 40:45; %size(strMask_AIBS, 3)
    %         fig = figure; 
    %         imshow(AIBS_100um.brain.images(:, :, k)./512,'InitialMagnification', 700);
    %         hold on
    %         title('My brain, mask and outlines + Hainings in blue')
    %         outline = h_getNucleusOutline(strMask_AIBS(:,:,k).*~ic_submask(:,:,k));
    %         for j = 1:length(outline)
    %             plot((outline{j}(:,2)), (outline{j}(:,1)), 'w-', 'linewidth',1)
    %         end
    %         oAIBS = h_getNucleusOutline(inj_thalData(i).projectionMasks(4).max(:, :, k));
    %         for j = 1:length(oAIBS)
    %             plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1)), 'b-', 'linewidth',1.1)
    %         end
    %         oAIBS = h_getNucleusOutline(inj_thalData(i).projectionMasks(4).all(:, :, k));
    %         for j = 1:length(oAIBS)
    %             plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1)), 'c-', 'linewidth',1.1)
    %         end
    %         oAIBS = h_getNucleusOutline(inj_thalData(i).projectionMasks(3).max(:, :, k));
    %         for j = 1:length(oAIBS)
    %             plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1)), 'r-', 'linewidth',1.1)
    %         end
    %         oAIBS = h_getNucleusOutline(inj_thalData(i).projectionMasks(3).all(:, :, k));
    %         for j = 1:length(oAIBS)
    %             plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1)), 'm-', 'linewidth',1.1)
    %         end
    %         oAIBS = h_getNucleusOutline(inj_thalData(i).strMask(:, :, k));
    %         for j = 1:length(oAIBS)
    %             plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1)), 'k-', 'linewidth',1.1)
    %         end
    %         oAIBS = h_getNucleusOutline(flipdim(inj_thalData(i).strMask(:, :, k), 2));
    %         for j = 1:length(oAIBS)
    %             plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1)), 'g-', 'linewidth',.5)
    %         end
    %     end


    %% 2++. Now I want to get the injection sites into this file

    % load([anaDir, '/inj_thalData.mat']) %Loading the thalamostriatal data from above

    load([randomMasksDir, '/std thal w traced nuclei & final adj atlas_2014-03-06.mat']) %Loading the injection site thalamus data from the thalamocortical paper
    % There is a 'brains' variable in the thalamus data that is loaded above, so I'm naming the next variable something other than 'brains'
    finalBrains = [060536, 075019, 075032, 075034, 075036, 075074, 075075, 075077, 075078, 075083, 075086, 075106, 075107, 075108, 075109, 075110, 075111, 075112, 075115, 075117, 075118, 075120, 075121, 075122, 075123, 075124, 075126, 075127, 075128, 075129, 075130, 075131, 075132, 075133, 075087, 075912, 075914, 075915, 075916, 075917, 075918, 075919, 075920, 075924, 075925, 076001, 076002, 076003, 076004, 076005, 076006, 076007, 076008, 076009, 076010, 076012, 076013, 076014, 076015, 076016, 076018, 076019, 076020, 076024, 076025, 076027, 076028, 076029];
    % Damnit... we dont have 060536 in the thalamus dataset... 

    for b = 1:length(brains)
        thalbrains(b) = str2num(brains(b).name);
    end


    for i = 1:length(finalBrains)
        ind = find(thalbrains(:, :) == finalBrains(i));
        if ind > 0
            inj_thalData(i).bilateralRedInjections = zeros(250, 350, 70);
            inj_thalData(i).bilateralGreenInjections = zeros(250, 350, 70);
            inj_thalData(i).injections(1).mask = zeros(250, 350, 70);
            inj_thalData(i).injections(2).mask = zeros(250, 350, 70);
            inj_thalData(i).injections(3).mask = zeros(250, 350, 70);
            inj_thalData(i).injections(4).mask = zeros(250, 350, 70);


            inj_thalData(i).bilateralRedInjections(:, :, 1:size(nred{ind}, 3))  = nred{ind};
            inj_thalData(i).bilateralGreenInjections(:, :, 1:size(ngreen{ind}, 3)) = ngreen{ind};
            inj_thalData(i).thalamus = betteraveragethalamus;


            % And also have them in a unilateral format for ease of analysis
            inj_thalData(i).inj_INDEX = {'Left Red', 'Right Red', 'Left Green', 'Right Green'};

            leftRedInj = flipdim(nred{ind}, 2);  % Flip the left mask across the midline
            leftRedInj(:, 1:175, :) = 0; % Make contra side blank
            inj_thalData(i).injections(1).mask(:, :, 1:size(leftRedInj, 3)) = leftRedInj;

            rightRedInj = nred{ind};  
            rightRedInj(:, 1:175, :) = 0; % Make contra side blank
            inj_thalData(i).injections(2).mask(:, :, 1:size(rightRedInj, 3)) = rightRedInj;

            leftGreenInj = flipdim(ngreen{ind}, 2);  % Flip the left mask across the midline
            leftGreenInj(:, 1:175, :) = 0; % Make contra side blank
            inj_thalData(i).injections(3).mask(:, :, 1:size(leftGreenInj, 3)) = leftGreenInj;

            rightGreenInj = ngreen{ind};  
            rightGreenInj(:, 1:175, :) = 0; % Make contra side blank
            inj_thalData(i).injections(4).mask(:, :, 1:size(rightGreenInj, 3)) = rightGreenInj;
        else
            display(['There doesnt seem to be thalamus data for ', num2str(finalBrains(i))])
        end
    end 
    
    if saveFlag == 1
        cd(anaDir); %('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/')
        save('inj_thalData.mat', 'inj_thalData', '-v7.3')
    end
end


%% 3. OK, now thatI have all the orderly thalamus data, lets start grouping... and creating test figures to decide on grouping method

if figFlag == 3
    
    % First: Convergence with corticostriatal fields. 
    load([anaDir, '/inj_thalData.mat']) %Loading the thalamostriatal data from above
    ic_submask = AIBS_100um.striatum.ic_submask; % I'll need to apply this to the thalamus data

    saveDir = ([anaDir, '/ThalamostriatalData_processed/Thalamostriatal_testFigures/']);
    mkdir([saveDir, '/GroupingMethods']) %for test groups

    for g = 1:length(injGroup_data) % Loop the cortical groups
        if sum(ismember(projAreasToKeep, injGroup_data(g).cortical_group)) > 0
            thalamusInj_groups(g).anyOverlap.cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_groups(g).anyOverlap.shells = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_groups(g).noOverlap.cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_groups(g).noOverlap.shells = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_groups(g).maxOverlap.cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_groups(g).maxOverlap.shells = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_groups(g).noMaxOverlap.cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_groups(g).noMaxOverlap.shells = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_groups(g).anyOverlap5.cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_groups(g).anyOverlap5.shells = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_groups(g).noOverlap5.cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_groups(g).noOverlap5.shells = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_groups(g).anyOverlap5_25.cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_groups(g).anyOverlap5_25.shells = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_groups(g).noOverlap5_25.cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_groups(g).noOverlap5_25.shells = false(size(inj_thalData(2).injections(1).mask));

            thalamusInj_groups(1).TotalWithLevel10.cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_groups(1).TotalWithLevel10.shells = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_groups(1).noTotalWithLevel10.cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_groups(1).noTotalWithLevel10.shells = false(size(inj_thalData(2).injections(1).mask));
            
            % Tracking Injections
            thalamusInj_groups(g).anyOverlap.injections = [];
            thalamusInj_groups(g).noOverlap.injections = [];
            thalamusInj_groups(g).anyOverlap5.injections = [];
            thalamusInj_groups(g).noOverlap5.injections = [];
            thalamusInj_groups(g).anyOverlap5_25.injections = [];
            thalamusInj_groups(g).noOverlap5_25.injections = [];
            thalamusInj_groups(g).TotalWithLevel10.injections = [];
                            


            for t = 2:length(inj_thalData) % Loop the thalamus brains *no injection site for 1...
                for i = 1:4 % Loop the 4 possible injections per brain
                    if inj_thalData(t).projections(i) == 1; % if theres an injection to add

        % Level 4:  any diffuse cortical is covered by 10% of any thalamus
        %                 if sum(injGroup_data(g).mask1.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(inj_thalData(t).projectionMasks(i).all(:)) >= 0.1; 
        %                     thalamusInj_groups(g).anyOverlap.cores = thalamusInj_groups(g).anyOverlap.cores | (inj_thalData(t).injections(i).mask > 1);
        %                     thalamusInj_groups(g).anyOverlap.shells = logical(thalamusInj_groups(g).anyOverlap.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 elseif sum(injGroup_data(g).mask1.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(inj_thalData(t).projectionMasks(i).all(:)) < 0.1
        %                     thalamusInj_groups(g).noOverlap.cores = logical(thalamusInj_groups(g).noOverlap.cores + (inj_thalData(t).injections(i).mask > 1));
        %                     thalamusInj_groups(g).noOverlap.shells = logical(thalamusInj_groups(g).noOverlap.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 end
        %                 
        %                 % any dense cortical is covered by 10% of any thalamus 
        %                 if sum(injGroup_data(g).mask5.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(inj_thalData(t).projectionMasks(i).all(:)) >= 0.1; 
        %                     thalamusInj_groups(g).anyOverlap5.cores = thalamusInj_groups(g).anyOverlap5.cores | (inj_thalData(t).injections(i).mask > 1);
        %                     thalamusInj_groups(g).anyOverlap5.shells = logical(thalamusInj_groups(g).anyOverlap5.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 elseif sum(injGroup_data(g).mask5.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(inj_thalData(t).projectionMasks(i).all(:)) < 0.1
        %                     thalamusInj_groups(g).noOverlap5.cores = logical(thalamusInj_groups(g).noOverlap5.cores + (inj_thalData(t).injections(i).mask > 1));
        %                     thalamusInj_groups(g).noOverlap5.shells = logical(thalamusInj_groups(g).noOverlap5.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 end

        % Level 5: 10%      diffuse cortical is covered by any thalamus 
        %                 if sum(injGroup_data(g).mask1.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(injGroup_data(g).mask1.ipsilateral(:)) >= 0.1; 
        %                     thalamusInj_groups(g).anyOverlap.cores = thalamusInj_groups(g).anyOverlap.cores | (inj_thalData(t).injections(i).mask > 1);
        %                     thalamusInj_groups(g).anyOverlap.shells = logical(thalamusInj_groups(g).anyOverlap.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 elseif sum(injGroup_data(g).mask1.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(injGroup_data(g).mask1.ipsilateral(:)) < 0.1
        %                     thalamusInj_groups(g).noOverlap.cores = logical(thalamusInj_groups(g).noOverlap.cores + (inj_thalData(t).injections(i).mask > 1));
        %                     thalamusInj_groups(g).noOverlap.shells = logical(thalamusInj_groups(g).noOverlap.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 end
        %                 
        %                 % 10 dense cortical is covered by any thalamus
        %                 if sum(injGroup_data(g).mask5.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(injGroup_data(g).mask5.ipsilateral(:)) >= 0.1; 
        %                     thalamusInj_groups(g).anyOverlap5.cores = thalamusInj_groups(g).anyOverlap5.cores | (inj_thalData(t).injections(i).mask > 1);
        %                     thalamusInj_groups(g).anyOverlap5.shells = logical(thalamusInj_groups(g).anyOverlap5.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 elseif sum(injGroup_data(g).mask5.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(injGroup_data(g).mask5.ipsilateral(:)) < 0.1
        %                     thalamusInj_groups(g).noOverlap5.cores = logical(thalamusInj_groups(g).noOverlap5.cores + (inj_thalData(t).injections(i).mask > 1));
        %                     thalamusInj_groups(g).noOverlap5.shells = logical(thalamusInj_groups(g).noOverlap5.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 end

        % XX Level 6:   either diffuse cortical is covered by 80% of any thalamus  (Weird one just to see)
        %                 if sum(injGroup_data(g).mask1.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(inj_thalData(t).projectionMasks(i).all(:)) >= 0.80; 
        %                     thalamusInj_groups(g).anyOverlap.cores = thalamusInj_groups(g).anyOverlap.cores | (inj_thalData(t).injections(i).mask > 1);
        %                     thalamusInj_groups(g).anyOverlap.shells = logical(thalamusInj_groups(g).anyOverlap.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 elseif sum(injGroup_data(g).mask1.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(inj_thalData(t).projectionMasks(i).all(:)) < 0.8
        %                     thalamusInj_groups(g).noOverlap.cores = logical(thalamusInj_groups(g).noOverlap.cores + (inj_thalData(t).injections(i).mask > 1));
        %                     thalamusInj_groups(g).noOverlap.shells = logical(thalamusInj_groups(g).noOverlap.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 end
        %                 
        %                 % or 80% dense cortical is covered by any thalamus  
        %                 if sum(injGroup_data(g).mask5.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(injGroup_data(g).mask5.ipsilateral(:)) >= 0.8; 
        %                     thalamusInj_groups(g).anyOverlap5.cores = thalamusInj_groups(g).anyOverlap5.cores | (inj_thalData(t).injections(i).mask > 1);
        %                     thalamusInj_groups(g).anyOverlap5.shells = logical(thalamusInj_groups(g).anyOverlap5.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 elseif sum(injGroup_data(g).mask5.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(injGroup_data(g).mask5.ipsilateral(:)) < 0.8
        %                     thalamusInj_groups(g).noOverlap5.cores = logical(thalamusInj_groups(g).noOverlap5.cores + (inj_thalData(t).injections(i).mask > 1));
        %                     thalamusInj_groups(g).noOverlap5.shells = logical(thalamusInj_groups(g).noOverlap5.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 end

        % % Level 7:      10% diffuse cortical is covered by any thalamus 
        %                 if sum(injGroup_data(g).mask1.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(injGroup_data(g).mask1.ipsilateral(:)) >= 0.1; 
        %                     thalamusInj_groups(g).anyOverlap.cores = thalamusInj_groups(g).anyOverlap.cores | (inj_thalData(t).injections(i).mask > 1);
        %                     thalamusInj_groups(g).anyOverlap.shells = logical(thalamusInj_groups(g).anyOverlap.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 elseif sum(injGroup_data(g).mask1.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(injGroup_data(g).mask1.ipsilateral(:)) < 0.1
        %                     thalamusInj_groups(g).noOverlap.cores = logical(thalamusInj_groups(g).noOverlap.cores + (inj_thalData(t).injections(i).mask > 1));
        %                     thalamusInj_groups(g).noOverlap.shells = logical(thalamusInj_groups(g).noOverlap.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 end
        %                 
        %                 % any dense cortical is covered by any thalamus
        %                 if sum(injGroup_data(g).mask5.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:)) > 0; 
        %                     thalamusInj_groups(g).anyOverlap5.cores = thalamusInj_groups(g).anyOverlap5.cores | (inj_thalData(t).injections(i).mask > 1);
        %                     thalamusInj_groups(g).anyOverlap5.shells = logical(thalamusInj_groups(g).anyOverlap5.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 elseif sum(injGroup_data(g).mask5.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:)) > 0
        %                     thalamusInj_groups(g).noOverlap5.cores = logical(thalamusInj_groups(g).noOverlap5.cores + (inj_thalData(t).injections(i).mask > 1));
        %                     thalamusInj_groups(g).noOverlap5.shells = logical(thalamusInj_groups(g).noOverlap5.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 end                  

        % Level 8:Love it  % 10% diffuse cortical is covered by any thalamus 
        %                 if sum(injGroup_data(g).mask1.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(injGroup_data(g).mask1.ipsilateral(:)) >= 0.1; 
        %                     thalamusInj_groups(g).anyOverlap.cores = thalamusInj_groups(g).anyOverlap.cores | (inj_thalData(t).injections(i).mask > 1);
        %                     thalamusInj_groups(g).anyOverlap.shells = logical(thalamusInj_groups(g).anyOverlap.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 elseif sum(injGroup_data(g).mask1.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(injGroup_data(g).mask1.ipsilateral(:)) < 0.1
        %                     thalamusInj_groups(g).noOverlap.cores = logical(thalamusInj_groups(g).noOverlap.cores + (inj_thalData(t).injections(i).mask > 1));
        %                     thalamusInj_groups(g).noOverlap.shells = logical(thalamusInj_groups(g).noOverlap.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 end
        %                 
        %                 % 5% dense cortical is covered by any thalamus
        %                 if sum(injGroup_data(g).mask5.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(injGroup_data(g).mask5.ipsilateral(:)) >= 0.05; 
        %                     thalamusInj_groups(g).anyOverlap5.cores = thalamusInj_groups(g).anyOverlap5.cores | (inj_thalData(t).injections(i).mask > 1);
        %                     thalamusInj_groups(g).anyOverlap5.shells = logical(thalamusInj_groups(g).anyOverlap5.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 elseif sum(injGroup_data(g).mask5.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(injGroup_data(g).mask5.ipsilateral(:)) < 0.05
        %                     thalamusInj_groups(g).noOverlap5.cores = logical(thalamusInj_groups(g).noOverlap5.cores + (inj_thalData(t).injections(i).mask > 1));
        %                     thalamusInj_groups(g).noOverlap5.shells = logical(thalamusInj_groups(g).noOverlap5.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 end
        %                 
        %                 % 25% dense cortical is covered by any thalamus
        %                 if sum(injGroup_data(g).mask5.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(injGroup_data(g).mask5.ipsilateral(:)) >= 0.25; 
        %                     thalamusInj_groups(g).anyOverlap5_25.cores = thalamusInj_groups(g).anyOverlap5_25.cores | (inj_thalData(t).injections(i).mask > 1);
        %                     thalamusInj_groups(g).anyOverlap5_25.shells = logical(thalamusInj_groups(g).anyOverlap5_25.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 elseif sum(injGroup_data(g).mask5.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(injGroup_data(g).mask5.ipsilateral(:)) < 0.25
        %                     thalamusInj_groups(g).noOverlap5_25.cores = logical(thalamusInj_groups(g).noOverlap5_25.cores + (inj_thalData(t).injections(i).mask > 1));
        %                     thalamusInj_groups(g).noOverlap5_25.shells = logical(thalamusInj_groups(g).noOverlap5_25.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 end

        % % Level 9:      % (dense only) 5% dense cortical is covered by any thalamus 
        %   not different enough, just harsher
        %                 if sum(injGroup_data(g).mask5.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(injGroup_data(g).mask5.ipsilateral(:)) >= 0.05; 
        %                     thalamusInj_groups(g).anyOverlap5.cores = thalamusInj_groups(g).anyOverlap5.cores | (inj_thalData(t).injections(i).mask > 1);
        %                     thalamusInj_groups(g).anyOverlap5.shells = logical(thalamusInj_groups(g).anyOverlap5.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 elseif sum(injGroup_data(g).mask5.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(injGroup_data(g).mask5.ipsilateral(:)) < 0.05
        %                     thalamusInj_groups(g).noOverlap5.cores = logical(thalamusInj_groups(g).noOverlap5.cores + (inj_thalData(t).injections(i).mask > 1));
        %                     thalamusInj_groups(g).noOverlap5.shells = logical(thalamusInj_groups(g).noOverlap5.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 end
        %                 
        %                 % 25% dense cortical is covered by any thalamus
        %                 if sum(injGroup_data(g).mask5.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(injGroup_data(g).mask5.ipsilateral(:)) >= 0.25; 
        %                     thalamusInj_groups(g).anyOverlap5_25.cores = thalamusInj_groups(g).anyOverlap5_25.cores | (inj_thalData(t).injections(i).mask > 1);
        %                     thalamusInj_groups(g).anyOverlap5_25.shells = logical(thalamusInj_groups(g).anyOverlap5_25.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 elseif sum(injGroup_data(g).mask5.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(injGroup_data(g).mask5.ipsilateral(:)) < 0.25
        %                     thalamusInj_groups(g).noOverlap5_25.cores = logical(thalamusInj_groups(g).noOverlap5_25.cores + (inj_thalData(t).injections(i).mask > 1));
        %                     thalamusInj_groups(g).noOverlap5_25.shells = logical(thalamusInj_groups(g).noOverlap5_25.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 end

        % Level 10:    % (Adjustment to Level 8: 5/5/50% instead of 10/5/25%) 5% diffuse cortical is covered by any thalamus 
                        if sum(injGroup_data(g).mask1.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(injGroup_data(g).mask1.ipsilateral(:)) >= 0.1; 
                            thalamusInj_groups(g).anyOverlap.cores = thalamusInj_groups(g).anyOverlap.cores | (inj_thalData(t).injections(i).mask > 1);
                            thalamusInj_groups(g).anyOverlap.shells = logical(thalamusInj_groups(g).anyOverlap.shells + (inj_thalData(t).injections(i).mask > 0));

                            thalamusInj_groups(1).TotalWithLevel10.cores = thalamusInj_groups(1).TotalWithLevel10.cores | (inj_thalData(t).injections(i).mask > 1);% Testing how inclusive I'm being
                            thalamusInj_groups(1).TotalWithLevel10.shells = thalamusInj_groups(1).TotalWithLevel10.shells | (inj_thalData(t).injections(i).mask > 0);% Testing how inclusive I'm being
                            
                            %Tracking Injections
                            thalamusInj_groups(g).anyOverlap.injections = cat(1, thalamusInj_groups(g).anyOverlap.injections, [inj_thalData(t).expID, i]);
                            thalamusInj_groups(g).TotalWithLevel10.injections = cat(1, thalamusInj_groups(g).TotalWithLevel10.injections, [inj_thalData(t).expID, i]);
                        
                        elseif sum(injGroup_data(g).mask1.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(injGroup_data(g).mask1.ipsilateral(:)) < 0.1
                            thalamusInj_groups(g).noOverlap.cores = logical(thalamusInj_groups(g).noOverlap.cores + (inj_thalData(t).injections(i).mask > 1));
                            thalamusInj_groups(g).noOverlap.shells = logical(thalamusInj_groups(g).noOverlap.shells + (inj_thalData(t).injections(i).mask > 0));
                            
                            %Tracking Injections
                            thalamusInj_groups(g).noOverlap.injections = cat(1, thalamusInj_groups(g).noOverlap.injections, [inj_thalData(t).expID, i]);
                        end

                        % 5% dense cortical is covered by any thalamus
                        if sum(injGroup_data(g).mask5.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(injGroup_data(g).mask5.ipsilateral(:)) >= 0.05; 
                            thalamusInj_groups(g).anyOverlap5.cores = thalamusInj_groups(g).anyOverlap5.cores | (inj_thalData(t).injections(i).mask > 1);
                            thalamusInj_groups(g).anyOverlap5.shells = logical(thalamusInj_groups(g).anyOverlap5.shells + (inj_thalData(t).injections(i).mask > 0));

                            thalamusInj_groups(1).TotalWithLevel10.cores = thalamusInj_groups(1).TotalWithLevel10.cores | (inj_thalData(t).injections(i).mask > 1); % Testing how inclusive I'm being
                            thalamusInj_groups(1).TotalWithLevel10.shells = thalamusInj_groups(1).TotalWithLevel10.shells | (inj_thalData(t).injections(i).mask > 0);% Testing how inclusive I'm being
                        
                            %Tracking Injections
                            thalamusInj_groups(g).anyOverlap5.injections = cat(1, thalamusInj_groups(g).anyOverlap5.injections, [inj_thalData(t).expID, i]);
                            thalamusInj_groups(g).TotalWithLevel10.injections = cat(1, thalamusInj_groups(g).TotalWithLevel10.injections, [inj_thalData(t).expID, i]);
                            
                        elseif sum(injGroup_data(g).mask5.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(injGroup_data(g).mask5.ipsilateral(:)) < 0.05
                            thalamusInj_groups(g).noOverlap5.cores = logical(thalamusInj_groups(g).noOverlap5.cores + (inj_thalData(t).injections(i).mask > 1));
                            thalamusInj_groups(g).noOverlap5.shells = logical(thalamusInj_groups(g).noOverlap5.shells + (inj_thalData(t).injections(i).mask > 0));
                            
                            %Tracking Injections
                            thalamusInj_groups(g).noOverlap5.injections = cat(1, thalamusInj_groups(g).noOverlap5.injections, [inj_thalData(t).expID, i]);
                        end

                        % 50% dense cortical is covered by any thalamus
                        if sum(injGroup_data(g).mask5.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(injGroup_data(g).mask5.ipsilateral(:)) >= 0.5; 
                            thalamusInj_groups(g).anyOverlap5_25.cores = thalamusInj_groups(g).anyOverlap5_25.cores | (inj_thalData(t).injections(i).mask > 1);
                            thalamusInj_groups(g).anyOverlap5_25.shells = logical(thalamusInj_groups(g).anyOverlap5_25.shells + (inj_thalData(t).injections(i).mask > 0));

                            thalamusInj_groups(1).TotalWithLevel10.cores = thalamusInj_groups(1).TotalWithLevel10.cores | (inj_thalData(t).injections(i).mask > 1);% Testing how inclusive I'm being
                            thalamusInj_groups(1).TotalWithLevel10.shells = thalamusInj_groups(1).TotalWithLevel10.shells | (inj_thalData(t).injections(i).mask > 0);% Testing how inclusive I'm being
                            
                            %Tracking Injections
                            thalamusInj_groups(g).anyOverlap5_25.injections = cat(1, thalamusInj_groups(g).anyOverlap5_25.injections, [inj_thalData(t).expID, i]);
                            thalamusInj_groups(g).TotalWithLevel10.injections = cat(1, thalamusInj_groups(g).TotalWithLevel10.injections, [inj_thalData(t).expID, i]);
                            
                        elseif sum(injGroup_data(g).mask5.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(injGroup_data(g).mask5.ipsilateral(:)) < 0.5
                            thalamusInj_groups(g).noOverlap5_25.cores = logical(thalamusInj_groups(g).noOverlap5_25.cores + (inj_thalData(t).injections(i).mask > 1));
                            thalamusInj_groups(g).noOverlap5_25.shells = logical(thalamusInj_groups(g).noOverlap5_25.shells + (inj_thalData(t).injections(i).mask > 0));
                            
                            %Tracking Injections
                            thalamusInj_groups(g).noOverlap5_25.injections = cat(1, thalamusInj_groups(g).noOverlap5_25.injections, [inj_thalData(t).expID, i]);
                        end

        %                 % any diffuse cortical and any thalamus
        %                 if sum(injGroup_data(g).mask1.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:)) > 0 % diffuse cortical and all thalamus
        %                     thalamusInj_groups(g).anyOverlap.cores = thalamusInj_groups(g).anyOverlap.cores | (inj_thalData(t).injections(i).mask > 1);
        %                     thalamusInj_groups(g).anyOverlap.shells = logical(thalamusInj_groups(g).anyOverlap.shells + (inj_thalData(t).injections(i).mask > 0));
        % %                     sum(injGroup_data(g).mask1.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(inj_thalData(t).projectionMasks(i).all(:))
        %                 elseif sum(injGroup_data(g).mask1.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:)) == 0
        %                     thalamusInj_groups(g).noOverlap.cores = logical(thalamusInj_groups(g).noOverlap.cores + (inj_thalData(t).injections(i).mask > 1));
        %                     thalamusInj_groups(g).noOverlap.shells = logical(thalamusInj_groups(g).noOverlap.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 end
        %                 
        %                 % any diffuse cortical and max thalamus
        %                 if sum(injGroup_data(g).mask1.ipsilateral(:) & inj_thalData(t).projectionMasks(i).max(:)) > 0
        %                     thalamusInj_groups(g).maxOverlap.cores = thalamusInj_groups(g).maxOverlap.cores | (inj_thalData(t).injections(i).mask > 1);
        %                     thalamusInj_groups(g).maxOverlap.shells = logical(thalamusInj_groups(g).maxOverlap.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 elseif sum(injGroup_data(g).mask1.ipsilateral(:) & inj_thalData(t).projectionMasks(i).max(:)) == 0
        %                     thalamusInj_groups(g).noMaxOverlap.cores = logical(thalamusInj_groups(g).noMaxOverlap.cores + (inj_thalData(t).injections(i).mask > 1));
        %                     thalamusInj_groups(g).noMaxOverlap.shells = logical(thalamusInj_groups(g).noMaxOverlap.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 end
        %                 
        %                 % any dense cortical and any thalamus
        %                 if sum(injGroup_data(g).mask5.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:)) > 0 
        %                     thalamusInj_groups(g).anyOverlap5.cores = thalamusInj_groups(g).anyOverlap5.cores | (inj_thalData(t).injections(i).mask > 1);
        %                     thalamusInj_groups(g).anyOverlap5.shells = logical(thalamusInj_groups(g).anyOverlap5.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 elseif sum(injGroup_data(g).mask5.ipsilateral(:) & inj_thalData(t).projectionMasks(i).all(:)) == 0
        %                     thalamusInj_groups(g).noOverlap5.cores = logical(thalamusInj_groups(g).noOverlap5.cores + (inj_thalData(t).injections(i).mask > 1));
        %                     thalamusInj_groups(g).noOverlap5.shells = logical(thalamusInj_groups(g).noOverlap5.shells + (inj_thalData(t).injections(i).mask > 0));
        %                 end

                    elseif inj_thalData(t).projections(i) == 0; % if theres an injection to subtract
                        thalamusInj_groups(g).noOverlap.cores = logical(thalamusInj_groups(g).noOverlap.cores + (inj_thalData(t).injections(i).mask > 1));
                        thalamusInj_groups(g).noOverlap.shells = logical(thalamusInj_groups(g).noOverlap.shells + (inj_thalData(t).injections(i).mask > 0));

                        thalamusInj_groups(1).noTotalWithLevel10.cores = thalamusInj_groups(1).noTotalWithLevel10.cores | (inj_thalData(t).injections(i).mask > 1);% Testing how inclusive I'm being
                        thalamusInj_groups(1).noTotalWithLevel10.shells = thalamusInj_groups(1).noTotalWithLevel10.shells | (inj_thalData(t).injections(i).mask > 0);% Testing how inclusive I'm being
                    end
                end
            end
% % % %             %show images
% % % %             sp = 1; 
% % % %             fig = figure;
% % % %             set(fig, 'Position', [1691 56 231 1050])
% % % %             for k = 5:10:45
% % % %                 subplot(5, 1, sp)
% % % %                 sp = sp+1; 
% % % % 
% % % %                 % Level 1
% % % %         %         group = (thalamusInj_groups(g).anyOverlap.cores + thalamusInj_groups(g).anyOverlap.shells + thalamusInj_groups(g).maxOverlap.cores + thalamusInj_groups(g).maxOverlap.shells - thalamusInj_groups(g).noMaxOverlap.cores - thalamusInj_groups(g).noMaxOverlap.shells - thalamusInj_groups(g).noOverlap.shells).*~thalamusInj_groups(g).noOverlap.cores; 
% % % %                 % Level 2
% % % %         %         group = (thalamusInj_groups(g).anyOverlap.cores + thalamusInj_groups(g).anyOverlap5.cores + thalamusInj_groups(g).anyOverlap5.shells + thalamusInj_groups(g).maxOverlap.shells - thalamusInj_groups(g).noOverlap5.shells - thalamusInj_groups(g).noMaxOverlap.shells - thalamusInj_groups(g).noOverlap.shells).*~thalamusInj_groups(g).noOverlap.cores; 
% % % %                 % Level 3  *this is for 10% of any thal proj overlapping any cortical
% % % %         %         group = (thalamusInj_groups(g).anyOverlap.cores + thalamusInj_groups(g).anyOverlap.shells - thalamusInj_groups(g).noOverlap.shells).*~thalamusInj_groups(g).noOverlap.cores; 
% % % %                 % Level 4  *this is for 10% of any thal proj overlapping any and dense cortical
% % % %                     % x this does really underselecting thal with AUD and ECT, but big for AUD and AI
% % % %         %         group = (thalamusInj_groups(g).anyOverlap5.cores + thalamusInj_groups(g).anyOverlap5.shells + thalamusInj_groups(g).anyOverlap.cores + thalamusInj_groups(g).anyOverlap.shells - thalamusInj_groups(g).noOverlap.shells - thalamusInj_groups(g).noOverlap5.cores - thalamusInj_groups(g).noOverlap5.shells).*~thalamusInj_groups(g).noOverlap.cores; 
% % % %                 % Level 5  *this is for any thal proj overlapping 10% of diffuse and 10% dense cortical
% % % %                     % (good) This one is pretty good, some obvious differences between them
% % % %         %         group = (thalamusInj_groups(g).anyOverlap5.cores + thalamusInj_groups(g).anyOverlap5.shells + thalamusInj_groups(g).anyOverlap.cores + thalamusInj_groups(g).anyOverlap.shells - thalamusInj_groups(g).noOverlap.shells - thalamusInj_groups(g).noOverlap5.cores - thalamusInj_groups(g).noOverlap5.shells).*~thalamusInj_groups(g).noOverlap.cores; 
% % % %                 % Level 6  *this is for the weird 80% of the injection or projection
% % % %                     % x pretty terrible, nothing like 5... 
% % % %         %         group = (thalamusInj_groups(g).anyOverlap5.cores + thalamusInj_groups(g).anyOverlap5.shells + thalamusInj_groups(g).anyOverlap.cores + thalamusInj_groups(g).anyOverlap.shells - thalamusInj_groups(g).noOverlap5.cores - thalamusInj_groups(g).noOverlap.cores); 
% % % %                 % Level 7  *this is for any thal proj overlapping 10% of diffuse or any dense cortical
% % % %                     % Not too bad but proably too much to ever use ANY overlap
% % % %         %         group = (thalamusInj_groups(g).anyOverlap5.cores + thalamusInj_groups(g).anyOverlap5.shells + thalamusInj_groups(g).anyOverlap.cores + thalamusInj_groups(g).anyOverlap.shells - thalamusInj_groups(g).noOverlap.shells - thalamusInj_groups(g).noOverlap5.cores - thalamusInj_groups(g).noOverlap5.shells).*~thalamusInj_groups(g).noOverlap.cores; 
% % % %                 % Level 8  *this is for any thal proj overlapping 10% of diffuse and dense cortical
% % % %                     % (great) I really like this one, seems like a crisper level 5
% % % %         %         group = (thalamusInj_groups(g).anyOverlap5_25.cores + thalamusInj_groups(g).anyOverlap5_25.shells + thalamusInj_groups(g).anyOverlap5.cores + thalamusInj_groups(g).anyOverlap5.shells + thalamusInj_groups(g).anyOverlap.cores + thalamusInj_groups(g).anyOverlap.shells - thalamusInj_groups(g).noOverlap.shells - thalamusInj_groups(g).noOverlap5.cores - thalamusInj_groups(g).noOverlap5.shells - thalamusInj_groups(g).noOverlap5_25.cores).*~thalamusInj_groups(g).noOverlap.cores; 
% % % %                 % Level 10  *10 is slight adjustment to 8 
% % % %                     % 
% % % %                 group = (thalamusInj_groups(g).anyOverlap5_25.cores + thalamusInj_groups(g).anyOverlap5_25.shells + thalamusInj_groups(g).anyOverlap5.cores + thalamusInj_groups(g).anyOverlap5.shells + thalamusInj_groups(g).anyOverlap.cores + thalamusInj_groups(g).anyOverlap.shells - thalamusInj_groups(g).noOverlap.shells - thalamusInj_groups(g).noOverlap5.cores - thalamusInj_groups(g).noOverlap5.shells - thalamusInj_groups(g).noOverlap5_25.cores).*~thalamusInj_groups(g).noOverlap.cores; 
% % % % 
% % % % 
% % % %                 a = (group <= 0);% If subtraction makes it less than zero... 
% % % %                 group = group.*~a;
% % % %                 imshow(group(:, :, k), 'InitialMagnification', 1000)
% % % %                 hold on
% % % %                 outline = h_getNucleusOutline(betteraveragethalamus(:, :, k)>0);
% % % %                 for j = 1:length(outline)
% % % %                     plot((outline{j}(:,2)), (outline{j}(:,1)), 'R-', 'linewidth',1)
% % % %                 end
% % % %                 hold off
% % % %                 title([injGroup_data(g).cortical_group, ': section ', num2str(k), ' (Level 10)'])
% % % %                 colormap(gray)
% % % %                 caxis([0 max(group(:))])
% % % %             end
% % % % 
% % % %             if saveFlag == 1
% % % %                 saveas(fig, [saveDir, '/GroupingMethods/testingThalamusGrouping', injGroup_data(g).cortical_group, '_Level10.fig'], 'fig');
% % % %                 print(fig, [saveDir, '/GroupingMethods/testingThalamusGrouping', injGroup_data(g).cortical_group, '_Level10.eps'], '-depsc2');
% % % %             end
    %         close(fig)
        end
    end


% % % %     %show test coverage images too
% % % %     sp = 1; 
% % % %     fig = figure;
% % % %     set(fig, 'Position', [1691 56 231 1050])
% % % %     for k = 5:10:45
% % % %         subplot(5, 1, sp)
% % % %         sp = sp+1;
% % % %         group = (thalamusInj_groups(1).TotalWithLevel10.cores + thalamusInj_groups(1).TotalWithLevel10.shells);
% % % %         imshow(group(:, :, k), 'InitialMagnification', 1000)
% % % %         hold on
% % % %         outline = h_getNucleusOutline(betteraveragethalamus(:, :, k)>0);
% % % %         for j = 1:length(outline)
% % % %             plot((outline{j}(:,2)), (outline{j}(:,1)), 'R-', 'linewidth',1)
% % % %         end
% % % %         hold off
% % % %         title(['Test positive: section ', num2str(k), ' (Level 10)'])
% % % %         colormap(gray)
% % % %         caxis([0 max(group(:))])
% % % %     end
% % % % 
% % % %     % All positives
% % % %     group = (thalamusInj_groups(1).TotalWithLevel10.cores + thalamusInj_groups(1).TotalWithLevel10.shells);
% % % %     groupFlip = flipdim(group, 2);
% % % %     group = group + groupFlip;
% % % %     mkdir([saveDir, 'thalamo_corticostriatalConvergence/Level10/allPositive']) %for thal images
% % % %     for k = 1:size(betteraveragethalamus, 3) %k = 5:10:45
% % % %         fig = figure;
% % % %         set(fig, 'Position', [1570 790 350 250])
% % % %         imshow(group(:, :, k), 'Border', 'tight')
% % % %         hold on
% % % %     %        title(['Test Positive: section ', num2str(k), ' (Level *all*)'])
% % % %         colormap(gray)
% % % %         caxis([0 max(group(:))])
% % % %         outline = h_getNucleusOutline(betteraveragethalamus(:, :, k));
% % % %         for j = 1:length(outline)
% % % %             plot((outline{j}(:,2)), (outline{j}(:,1)), 'r-', 'linewidth',1)
% % % %         end
% % % %         hold off
% % % %         if saveFlag == 1
% % % %             saveas(fig, [saveDir, '/thalamo_corticostriatalConvergence/Level10/allPositive/thalCtxConvergence_allPositive_section', num2str(k), '.fig'], 'fig');
% % % %             print(fig, [saveDir, '/thalamo_corticostriatalConvergence/Level10/allPositive/thalCtxConvergence_allPositive_section', num2str(k), '.eps'], '-depsc2');
% % % %         
% % % %         end
% % % %         close(fig)
% % % %     end
    
    if saveFlag == 1
        cd(anaDir); 
        save('thalamusInj_group_Level10.mat', 'thalamusInj_groups', '-v7.3')
    end
end
% mkdir([saveDir, 'thalamo_corticostriatalConvergence/Level10']) %for thal images
% avgThal = false(size(inj_thalData(2).injections(2).mask)); 
% avgThal(:, :, 1:size(betteraveragethalamus, 3)) = betteraveragethalamus; 



%% 4. All thalamus images for the above group  (FIGURE)

if figFlag == 4
    
    load([anaDir, '/inj_thalData.mat']) %Loading the thalamostriatal data from above
    load([anaDir, '/thalamusInj_group_Level10.mat'])
    
    saveDir = ([anaDir, '/ThalamostriatalData_processed/Thalamostriatal_testFigures/']);

    avgThal = false(size(inj_thalData(2).injections(2).mask)); 
    avgThal(:, :, 1:size(betteraveragethalamus, 3)) = betteraveragethalamus; 

    for g = 1:length(injGroup_data) % Loop the cortical groups
        group = []; 
        if sum(ismember(projAreasToKeep, injGroup_data(g).cortical_group)) > 0
            mkdir([saveDir, 'thalamo_corticostriatalConvergence/Level10/', injGroup_data(g).cortical_group]) %for thal images
            group = (thalamusInj_groups(g).anyOverlap5_25.cores + thalamusInj_groups(g).anyOverlap5_25.shells + thalamusInj_groups(g).anyOverlap5.cores + thalamusInj_groups(g).anyOverlap5.shells + thalamusInj_groups(g).anyOverlap.cores + thalamusInj_groups(g).anyOverlap.shells - thalamusInj_groups(g).noOverlap.shells - thalamusInj_groups(g).noOverlap5.cores - thalamusInj_groups(g).noOverlap5.shells - thalamusInj_groups(g).noOverlap5_25.cores).*~thalamusInj_groups(g).noOverlap.cores; 
            a = (group <= 0); % If subtraction makes it less than zero... 
            group = group.*~a.*avgThal;

            groupFlip = flipdim(group, 2);
            group = group + groupFlip;
            for k = 1:size(betteraveragethalamus, 3)
                fig = figure;
                set(fig, 'Position', [1570 790 350 250])
                imshow(group(:, :, k), 'Border', 'tight')
                hold on
        %         title([injGroup_data(g).cortical_group, ': section ', num2str(k), ' (Level 10)'])
                colormap(gray)
                caxis([0 6]) %max(group(:))])   % ***** I had the max group when I made these the first time, i think it's ok, but I should check... 

                outline = h_getNucleusOutline(betteraveragethalamus(:, :, k));
                for j = 1:length(outline)
                    plot((outline{j}(:,2)), (outline{j}(:,1)), 'c-', 'linewidth',1)
                end
                hold off
                
                if saveFlag == 1
                    saveas(fig, [saveDir, '/thalamo_corticostriatalConvergence/Level10/', injGroup_data(g).cortical_group, '/thalCtxConvergence_', injGroup_data(g).cortical_group, '_section', num2str(k), '.fig'], 'fig');
                    print(fig, [saveDir, '/thalamo_corticostriatalConvergence/Level10/', injGroup_data(g).cortical_group, '/thalCtxConvergence_', injGroup_data(g).cortical_group, '_section', num2str(k), '.eps'], '-depsc2');
                end
                close(fig)
            end
        end
        thalCtx_StriatalConvergenceOrigins(g).mask = group; 
    end



    %forgot to add the name in there...
    for g = 1:length(injGroup_data) % Loop the cortical groups
        thalamusInj_groups(g).group = injGroup_data(g).cortical_group; 
        if sum(ismember(projAreasToKeep, injGroup_data(g).cortical_group)) > 0
            thalamusInj_groups(g).calculated = 1; 
        else 
            thalamusInj_groups(g).calculated = 0; 
        end
    end
    cd(anaDir); 
    save('thalamusInj_group_Level10.mat', 'thalamusInj_groups', '-v7.3')
    save('thalCtx_StriatalConvergenceOrigins.mat', 'thalCtx_StriatalConvergenceOrigins', '-v7.3')
end


%% 5. Create a comparison plot of the thalamic origin of convergence with corticostriatal data and the thalamocortical origins (FIGURE)

if figFlag == 5
    saveDir = ([anaDir, '/ThalamostriatalData_processed/Thalamostriatal_testFigures/']);

    %Load the thalamocortical confidence map data:   confidenceMap is a <1x25 cell> with int8 matrices of the final confidence maps & targerRegions with is a <25x1 cell with the region names
    targetRegions = {'AI';'Amyg';'Aud';'FRA';'IL';'Ins';'LO';'M1';'M2';'MO';'NAc';'Piri';'PrL';'Pt';'RS';'Rhi';'Sens';'Str';'Tem';'VO';'Vis';'dACC';'eDM';'vACC';'vM1'}; 
    load([randomMasksDir, '/confidenceMap_2014-03-06.mat']); % was : '/Users/jeaninehunnicutt/Desktop/Mao Lab/Matlab /Anatomy_Analysis/relevant data/confidenceMap_2014-03-06.mat'

    %Load the thalamostriatal convergence origin maps
    corticalGroup = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'SS', 'Vis', 'SUB_HIPP', 'Amyg', 'SNr', 'na'};
    load([anaDir, '/thalCtx_StriatalConvergenceOrigins.mat']);

    % Set the correspondance between those 2 datasets
    for i = 1:length(corticalGroup)
        corticalGroupNames(i).thalamostriatalName = corticalGroup(i);
    end
    corticalGroupNames(1).corticostriatalHomologue = {'vACC', 'dACC'};
    corticalGroupNames(2).corticostriatalHomologue = {'AI', 'Ins'};
    corticalGroupNames(3).corticostriatalHomologue = {'Aud'};
    corticalGroupNames(4).corticostriatalHomologue = {'Rhi', 'Tem'};
    corticalGroupNames(5).corticostriatalHomologue = {'FRA'};
    corticalGroupNames(6).corticostriatalHomologue = {'IL'};
    corticalGroupNames(7).corticostriatalHomologue = {'M1', 'M2'};
    corticalGroupNames(8).corticostriatalHomologue = {'LO', 'VO'};
    corticalGroupNames(9).corticostriatalHomologue = {'MO', 'PrL'};
    corticalGroupNames(10).corticostriatalHomologue = {'Pt'};
    corticalGroupNames(11).corticostriatalHomologue = {'RS'};
    corticalGroupNames(18).corticostriatalHomologue = {'Sens'};
    corticalGroupNames(19).corticostriatalHomologue = {'Vis'};
    corticalGroupNames(21).corticostriatalHomologue = {'Amyg'};

    % Add together some confidence maps that were grouped areas in the corticostratal data.. 
    projAreas_withThalamocorticalMaps = corticalGroup(~ismember(corticalGroup,{'SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'na', 'SNr',  'SUB_HIPP'}));
    for g = 1:length(corticalGroupNames)
        if sum(ismember(projAreas_withThalamocorticalMaps, injGroup_data(g).cortical_group)) > 0
            ind = find(ismember(targetRegions, corticalGroupNames(g).corticostriatalHomologue) == 1); % Find the maps to sum
            if length(ind) == 1
                thalCtx_StriatalConvergenceOrigins(g).correspondingThalamoCorticalConfidenceMap = confidenceMap{ind};
            elseif length(ind) == 2
                thalCtx_StriatalConvergenceOrigins(g).correspondingThalamoCorticalConfidenceMap = bsxfun(@max, confidenceMap{ind(1)}, confidenceMap{ind(2)});
            end

        end
    end

    % Add in the names to the variable 
    for g = 1:length(corticalGroupNames)
        if sum(ismember(projAreas_withThalamocorticalMaps, injGroup_data(g).cortical_group)) > 0
            thalCtx_StriatalConvergenceOrigins(g).thalamostriatalGroup = injGroup_data(g).cortical_group;
            thalCtx_StriatalConvergenceOrigins(g).thalamocorticalHomologue = corticalGroupNames(g).corticostriatalHomologue;
        end
    end     


    % Make the composite images and save them
    for g = 1:length(corticalGroupNames) % Loop through all cortical groups
        if sum(ismember(projAreas_withThalamocorticalMaps, injGroup_data(g).cortical_group)) > 0 %find the cortical groups I have thalamocortical data for
            mkdir([saveDir, 'thalamo_corticostriatalOriginOverlap/', injGroup_data(g).cortical_group]) %for thal images
            mkdir([saveDir, 'thalamo_corticostriatalOriginOverlap/', injGroup_data(g).cortical_group, '/backupConvergenceMask'])
            % Making arrays condusive to turning into rgb images
            ThalStrMap = thalCtx_StriatalConvergenceOrigins(g).mask(:, :, 1:65)./max(thalCtx_StriatalConvergenceOrigins(g).mask(:));  %normalizing them all to a max of 1
            thalCtxMap = double(thalCtx_StriatalConvergenceOrigins(g).correspondingThalamoCorticalConfidenceMap)./double(max(thalCtx_StriatalConvergenceOrigins(g).correspondingThalamoCorticalConfidenceMap(:))); 
            TCTS_convergence = ThalStrMap & thalCtxMap; 
            bothMap = thalCtxMap | ThalStrMap; 
            TC_only = thalCtxMap &~ThalStrMap; 
            TS_only = ThalStrMap &~ thalCtxMap; 

            for k = 1:size(TCTS_convergence, 3)
                % #WINNER I think, or at least it's the best I can figure out to look at convergence, i need to sleep -I can fill in the convergence outline in illustrator if needed
                rgb_test(:, :, 1) = ThalStrMap(:, :, k)*256.*(betteraveragethalamus(:, :, k)); % Also limiting the image to the size of the model striatum
                rgb_test(:, :, 2) = thalCtxMap(:, :, k)*256.*(betteraveragethalamus(:, :, k)); 
                rgb_test(:, :, 3) = ThalStrMap(:, :, k)*256+thalCtxMap(:, :, k)*256.*(betteraveragethalamus(:, :, k)); %Makes them cyan and magenta
                rgb_test = uint8(rgb_test);

                fig = figure; 
                set(fig, 'Position', [1570 790 350 250])

                imshow(rgb_test);
                hold on
                outline = h_getNucleusOutline(TCTS_convergence(:, :, k));
                for j = 1:length(outline)
                    plot((outline{j}(:,2)), (outline{j}(:,1)), 'c-', 'linewidth',1);
                end
                outline = h_getNucleusOutline(betteraveragethalamus(:, :, k));
                for j = 1:length(outline)
                    plot((outline{j}(:,2)), (outline{j}(:,1)), 'r-', 'linewidth',1.2);
                end

                if saveFlag == 1
                    saveas(fig, [saveDir, '/thalamo_corticostriatalOriginOverlap/', injGroup_data(g).cortical_group, '/thalCtxOriginOverlap_', injGroup_data(g).cortical_group, '_section', num2str(k), '.fig'], 'fig');
                    print(fig, [saveDir, '/thalamo_corticostriatalOriginOverlap/', injGroup_data(g).cortical_group, '/thalCtxOriginOverlap_', injGroup_data(g).cortical_group, '_section', num2str(k), '.eps'], '-depsc2');
                end
                close(fig)

                % Sometimes the outline thing fails when there are lots of  little bits so I'm saving that mask too to fix errors... 
                fig2 = figure; 
                set(fig2, 'Position', [1570 790 350 250])
                imshow(TCTS_convergence(:, :, k));
                
                if saveFlag == 1
                    saveas(fig2, [saveDir, '/thalamo_corticostriatalOriginOverlap/', injGroup_data(g).cortical_group, '/backupConvergenceMask/maskOnly_thalCtxOriginOverlap_', injGroup_data(g).cortical_group, '_section', num2str(k), '.fig'], 'fig');
                    print(fig2, [saveDir, '/thalamo_corticostriatalOriginOverlap/', injGroup_data(g).cortical_group, '/backupConvergenceMask/maskOnly_thalCtxOriginOverlap_', injGroup_data(g).cortical_group, '_section', num2str(k), '.eps'], '-depsc2');
                end
                close(fig2)


            end
        end
    end


    %TESTIGN FIGURES
    figure, imagesc(squeeze(sum(thalCtxMap, 1)))
    title('Thalamocortical Confidence Map: AI')
    figure, imagesc(squeeze(sum(ThalStrMap, 1)))
    title('Thalamostriatal convergence Map: AI')
    figure, imagesc(squeeze(sum(TCTS_convergence, 1)))
    title('Thalamostriatal-Thalamocotrical Origin Convergence Map: AI')

    figure, imshow(thalCtxMap(:, :, 17), 'InitialMagnification', 500)
    caxis('auto')
    title('Thalamocortical Confidence Map: AI')
    figure, imshow(ThalStrMap(:, :, 17), 'InitialMagnification', 500)
    caxis('auto')
    title('Thalamostriatal convergence Map: AI')
    figure, imshow(TCTS_convergence(:, :, 17), 'InitialMagnification', 500)
    caxis('auto')
    title('Thalamostriatal-Thalamocotrical Origin Convergence Map: AI')

    %this one is terrible, but gets the point across
    rgb_test2 = [];
    rgb_test2(:, :, 1) = uint8(TC_only(:, :, 17)).*256; 
    rgb_test2(:, :, 2) = uint8(TS_only(:, :, 17)).*256; 
    rgb_test2(:, :, 3) = uint8(TCTS_convergence(:, :, 17)).*256; 
    figure, imshow(rgb_test2)

    % this one isn't bad but the thalamocortical confidence map is a mess without gradataion
    rgb_test2 = [];
    rgb_test2(:, :, 1) = uint8(ThalStrMap(:, :, 17)>0).*256; 
    rgb_test2(:, :, 2) = uint8(thalCtxMap(:, :, 17)>0).*256; 
    rgb_test2(:, :, 3) = uint8(bothMap(:, :, 17)>0).*256; 
    figure, imshow(rgb_test2)
    
    if saveFlag == 1
        cd(anaDir); 
        save('thalCtx_StriatalConvergenceOrigins.mat', 'thalCtx_StriatalConvergenceOrigins', '-v7.3') % because this was updated in here too
    end
end


%% 6. Now redo the above thalamus grouping for the striatum clusters (FIGURE) *Beautiful

% ************************** NOT cleaned up yet ***************************

if figFlag == 6
    % specialStriatalGroups = {};

    % Load the cluster masks in the striatum
    load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/clustering4/spearmanDetailed_Clustering_3levels/data/clusterMasks_2clusters.mat')
    specialStriatalGroups{1} = clusterMasks;   
    load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/clustering4/spearmanDetailed_Clustering_3levels/data/clusterMasks_3clusters.mat')
    specialStriatalGroups{2} = clusterMasks;    
    load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/clustering4/spearmanDetailed_Clustering_3levels/data/clusterMasks_4clusters.mat')
    specialStriatalGroups{3} = clusterMasks;
    load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/clustering4/spearmanDetailed_Clustering_3levels/data/clusterMasks_15clusters.mat')
    specialStriatalGroups{4} = clusterMasks;


    % Update 6/23/15
    load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/specialStriatalGroups.mat')
    load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/thalamusInj_specialGroups.mat')

    load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/clustering4/spearmanDetailed_Clustering_3levels/data/clusterMasks_11clusters.mat')
    specialStriatalGroups{5} = clusterMasks;   
    load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/clustering4/spearmanDetailed_Clustering_3levels/data/clusterMasks_12clusters.mat')
    specialStriatalGroups{6} = clusterMasks;    
    load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/clustering4/spearmanDetailed_Clustering_3levels/data/clusterMasks_13clusters.mat')
    specialStriatalGroups{7} = clusterMasks;
    load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/clustering4/spearmanDetailed_Clustering_3levels/data/clusterMasks_14clusters.mat')
    specialStriatalGroups{8} = clusterMasks;


    %Load the thalamostriatal data and the average brain
    load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/inj_thalData.mat') %Loading the thalamostriatal data from above
    load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/AIBS_100um.mat')
    ic_submask = AIBS_100um.striatum.ic_submask; % I'll need to apply this to the thalamus data

    saveDir = ('/Users/jeaninehunnicutt/Desktop/ThalamostriatalData_processed/Thalamostriatal_testFigures');
    mkdir([saveDir, '/specialGroups'])

    for g = 5:length(specialStriatalGroups) %1:length(specialStriatalGroups) % Loop the cortical groups
        for c = 1: length(specialStriatalGroups{g})
            mkdir([saveDir, '/specialGroups/Cluster', num2str(c), 'of', num2str(length(specialStriatalGroups{g}))])


            cluster150um = specialStriatalGroups{g}(c).mask; 
            % I need to resample and uncrop the cluster masks... they are 150x150x150um and limited to the size of the striatum
            [x, y, z]= meshgrid(1:23, 1:29, 1:29);
            [xi, yi, zi] = meshgrid(1:0.6666:23, 1:0.6666:29, 1:0.6666:29); %150x150x150um voxels -->100um
            upsampledMask = round(interp3(x, y, z, double(cluster150um), xi, yi, zi));  % so far so good, but its 43x34x43 and I want to put it back into the 43x35x44 it was
            upsampledReplacedMask = zeros(size(AIBS_100um.striatum.myMask.Full.mask));
            upsampledReplacedMask(26:68, 62:95 ,35:77) = upsampledMask; %(testing placing it with a short y and z) -ipsilateral only 


            thalamusInj_specialGroups(g).anyOverlap(c).cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_specialGroups(g).anyOverlap(c).shells = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_specialGroups(g).noOverlap(c).cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_specialGroups(g).noOverlap(c).shells = false(size(inj_thalData(2).injections(1).mask));

            thalamusInj_specialGroups(g).noOverlap5thal(c).cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_specialGroups(g).noOverlap5thal(c).shells = false(size(inj_thalData(2).injections(1).mask));

            thalamusInj_specialGroups(g).anyOverlap50(c).cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_specialGroups(g).anyOverlap50(c).shells = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_specialGroups(g).noOverlap50(c).cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_specialGroups(g).noOverlap50(c).shells = false(size(inj_thalData(2).injections(1).mask));

            thalamusInj_specialGroups(g).anyOverlap50thal(c).cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_specialGroups(g).anyOverlap50thal(c).shells = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_specialGroups(g).noOverlap50thal(c).cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_specialGroups(g).noOverlap50thal(c).shells = false(size(inj_thalData(2).injections(1).mask));

            thalamusInj_specialGroups(g).midOverlap5(c).cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_specialGroups(g).midOverlap5(c).shells = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_specialGroups(g).noOverlap5(c).cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_specialGroups(g).noOverlap5(c).shells = false(size(inj_thalData(2).injections(1).mask));


            for t = 2:length(inj_thalData) % Loop the thalamus brains *no injection site for 1...
                for i = 1:4 % Loop the 4 possible injections per brain
                    if inj_thalData(t).projections(i) == 1; % if theres an injection to add

    %                 % Level 1:
    %                     % 10% of thalamus proj is within striatal cluster 
    %                     if sum(upsampledReplacedMask(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(inj_thalData(t).projectionMasks(i).all(:)) >= 0.1; 
    %                         thalamusInj_specialGroups(g).anyOverlap(c).cores = thalamusInj_specialGroups(g).anyOverlap(c).cores | (inj_thalData(t).injections(i).mask > 1);
    %                         thalamusInj_specialGroups(g).anyOverlap(c).shells = logical(thalamusInj_specialGroups(g).anyOverlap(c).shells + (inj_thalData(t).injections(i).mask > 0));
    % 
    %                     elseif sum(upsampledReplacedMask(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(inj_thalData(t).projectionMasks(i).all(:)) < 0.1
    %                         thalamusInj_specialGroups(g).noOverlap(c).cores = logical(thalamusInj_specialGroups(g).noOverlap(c).cores + (inj_thalData(t).injections(i).mask > 1));
    %                         thalamusInj_specialGroups(g).noOverlap(c).shells = logical(thalamusInj_specialGroups(g).noOverlap(c).shells + (inj_thalData(t).injections(i).mask > 0));
    %                     end
    % 
    %                     % 5% of striatal cluster is covered by mid thalamus proj
    %                     if sum(upsampledReplacedMask(:) & inj_thalData(t).projectionMasks(i).mid(:))/sum(upsampledReplacedMask(:)) >= 0.05; 
    %                         thalamusInj_specialGroups(g).midOverlap5(c).cores = thalamusInj_specialGroups(g).midOverlap5(c).cores | (inj_thalData(t).injections(i).mask > 1);
    %                         thalamusInj_specialGroups(g).midOverlap5(c).shells = logical(thalamusInj_specialGroups(g).midOverlap5(c).shells + (inj_thalData(t).injections(i).mask > 0));
    %                      elseif sum(injGroup_data(g).mask5.ipsilateral(:) & inj_thalData(t).projectionMasks(i).mid(:))/sum(injGroup_data(g).mask5.ipsilateral(:)) < 0.05
    %                         thalamusInj_specialGroups(g).noOverlap5(c).cores = logical(thalamusInj_specialGroups(g).noOverlap5(c).cores + (inj_thalData(t).injections(i).mask > 1));
    %                         thalamusInj_specialGroups(g).noOverlap5(c).shells = logical(thalamusInj_specialGroups(g).noOverlap5(c).shells + (inj_thalData(t).injections(i).mask > 0));
    %                     end
    % 
    %                     % 50% of striatal cluster is covered by any thalamus proj
    %                     if sum(upsampledReplacedMask(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(upsampledReplacedMask(:)) >= 0.5; 
    %                         thalamusInj_specialGroups(g).anyOverlap50(c).cores = thalamusInj_specialGroups(g).anyOverlap50(c).cores | (inj_thalData(t).injections(i).mask > 1);
    %                         thalamusInj_specialGroups(g).anyOverlap50(c).shells = logical(thalamusInj_specialGroups(g).anyOverlap50(c).shells + (inj_thalData(t).injections(i).mask > 0));
    % 
    %                      elseif sum(upsampledReplacedMask(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(upsampledReplacedMask(:)) < 0.5
    %                         thalamusInj_specialGroups(g).noOverlap50(c).cores = logical(thalamusInj_specialGroups(g).noOverlap50(c).cores + (inj_thalData(t).injections(i).mask > 1));
    %                         thalamusInj_specialGroups(g).noOverlap50(c).shells = logical(thalamusInj_specialGroups(g).noOverlap50(c).shells + (inj_thalData(t).injections(i).mask > 0));
    %                     end
    %                     
    %                     % 50% of thalamus proj is within striatal cluster 
    %                     if sum(upsampledReplacedMask(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(inj_thalData(t).projectionMasks(i).all(:)) >= 0.5; 
    %                         thalamusInj_specialGroups(g).anyOverlap50thal(c).cores = thalamusInj_specialGroups(g).anyOverlap50thal(c).cores | (inj_thalData(t).injections(i).mask > 1);
    %                         thalamusInj_specialGroups(g).anyOverlap50thal(c).shells = logical(thalamusInj_specialGroups(g).anyOverlap50thal(c).shells + (inj_thalData(t).injections(i).mask > 0));
    % 
    %                      elseif sum(upsampledReplacedMask(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(inj_thalData(t).projectionMasks(i).all(:)) < 0.5
    %                         thalamusInj_specialGroups(g).noOverlap50thal(c).cores = logical(thalamusInj_specialGroups(g).noOverlap50thal(c).cores + (inj_thalData(t).injections(i).mask > 1));
    %                         thalamusInj_specialGroups(g).noOverlap50thal(c).shells = logical(thalamusInj_specialGroups(g).noOverlap50thal(c).shells + (inj_thalData(t).injections(i).mask > 0));
    %                     end
    % Level 2:
                        % 10% of thalamus proj is within striatal cluster 
                        if sum(upsampledReplacedMask(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(inj_thalData(t).projectionMasks(i).all(:)) >= 0.1; 
                            thalamusInj_specialGroups(g).anyOverlap(c).cores = thalamusInj_specialGroups(g).anyOverlap(c).cores | (inj_thalData(t).injections(i).mask > 1);
                            thalamusInj_specialGroups(g).anyOverlap(c).shells = logical(thalamusInj_specialGroups(g).anyOverlap(c).shells + (inj_thalData(t).injections(i).mask > 0));

                        elseif sum(upsampledReplacedMask(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(inj_thalData(t).projectionMasks(i).all(:)) < 0.1
                            thalamusInj_specialGroups(g).noOverlap5thal(c).cores = logical(thalamusInj_specialGroups(g).noOverlap5thal(c).cores + (inj_thalData(t).injections(i).mask > 1));
                            thalamusInj_specialGroups(g).noOverlap5thal(c).shells = logical(thalamusInj_specialGroups(g).noOverlap5thal(c).shells + (inj_thalData(t).injections(i).mask > 0));
                        end

                        % 10% of striatal cluster is covered by mid thalamus proj
                        if sum(upsampledReplacedMask(:) & inj_thalData(t).projectionMasks(i).mid(:))/sum(upsampledReplacedMask(:)) >= 0.1; 
                            thalamusInj_specialGroups(g).midOverlap5(c).cores = thalamusInj_specialGroups(g).midOverlap5(c).cores | (inj_thalData(t).injections(i).mask > 1);
                            thalamusInj_specialGroups(g).midOverlap5(c).shells = logical(thalamusInj_specialGroups(g).midOverlap5(c).shells + (inj_thalData(t).injections(i).mask > 0));
                         elseif sum(injGroup_data(g).mask5.ipsilateral(:) & inj_thalData(t).projectionMasks(i).mid(:))/sum(injGroup_data(g).mask5.ipsilateral(:)) < 0.1
                            thalamusInj_specialGroups(g).noOverlap5(c).cores = logical(thalamusInj_specialGroups(g).noOverlap5(c).cores + (inj_thalData(t).injections(i).mask > 1));
                            thalamusInj_specialGroups(g).noOverlap5(c).shells = logical(thalamusInj_specialGroups(g).noOverlap5(c).shells + (inj_thalData(t).injections(i).mask > 0));
                        end

                        % For absolute subtraction... 
                        if (sum(upsampledReplacedMask(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(inj_thalData(t).projectionMasks(i).all(:)) < 0.1) && (sum(injGroup_data(g).mask5.ipsilateral(:) & inj_thalData(t).projectionMasks(i).mid(:))/sum(injGroup_data(g).mask5.ipsilateral(:)) < 0.1);
                             thalamusInj_specialGroups(g).noOverlap(c).cores = logical(thalamusInj_specialGroups(g).noOverlap(c).cores + (inj_thalData(t).injections(i).mask > 1));
                            thalamusInj_specialGroups(g).noOverlap(c).shells = logical(thalamusInj_specialGroups(g).noOverlap(c).shells + (inj_thalData(t).injections(i).mask > 0));
                        end

                        % 25% of striatal cluster is covered by any thalamus proj
                        if sum(upsampledReplacedMask(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(upsampledReplacedMask(:)) >= 0.25; 
                            thalamusInj_specialGroups(g).anyOverlap50(c).cores = thalamusInj_specialGroups(g).anyOverlap50(c).cores | (inj_thalData(t).injections(i).mask > 1);
                            thalamusInj_specialGroups(g).anyOverlap50(c).shells = logical(thalamusInj_specialGroups(g).anyOverlap50(c).shells + (inj_thalData(t).injections(i).mask > 0));

                         elseif sum(upsampledReplacedMask(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(upsampledReplacedMask(:)) < 0.25
                            thalamusInj_specialGroups(g).noOverlap50(c).cores = logical(thalamusInj_specialGroups(g).noOverlap50(c).cores + (inj_thalData(t).injections(i).mask > 1));
                            thalamusInj_specialGroups(g).noOverlap50(c).shells = logical(thalamusInj_specialGroups(g).noOverlap50(c).shells + (inj_thalData(t).injections(i).mask > 0));
                        end

                        % 25% of thalamus proj is within striatal cluster 
                        if sum(upsampledReplacedMask(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(inj_thalData(t).projectionMasks(i).all(:)) >= 0.25; 
                            thalamusInj_specialGroups(g).anyOverlap50thal(c).cores = thalamusInj_specialGroups(g).anyOverlap50thal(c).cores | (inj_thalData(t).injections(i).mask > 1);
                            thalamusInj_specialGroups(g).anyOverlap50thal(c).shells = logical(thalamusInj_specialGroups(g).anyOverlap50thal(c).shells + (inj_thalData(t).injections(i).mask > 0));

                         elseif sum(upsampledReplacedMask(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(inj_thalData(t).projectionMasks(i).all(:)) < 0.25
                            thalamusInj_specialGroups(g).noOverlap50thal(c).cores = logical(thalamusInj_specialGroups(g).noOverlap50thal(c).cores + (inj_thalData(t).injections(i).mask > 1));
                            thalamusInj_specialGroups(g).noOverlap50thal(c).shells = logical(thalamusInj_specialGroups(g).noOverlap50thal(c).shells + (inj_thalData(t).injections(i).mask > 0));
                        end

                    elseif inj_thalData(t).projections(i) == 0; % if theres an injection to subtract
                        thalamusInj_specialGroups(g).noOverlap(c).cores = logical(thalamusInj_specialGroups(g).noOverlap(c).cores + (inj_thalData(t).injections(i).mask > 1));
                        thalamusInj_specialGroups(g).noOverlap(c).shells = logical(thalamusInj_specialGroups(g).noOverlap(c).shells + (inj_thalData(t).injections(i).mask > 0));
                    end
               end
            end

            % Create confidence map and show images
            sp = 1; 
            fig = figure;
            set(fig, 'Position', [1691 56 231 1050])
            group = []; 
            % Level 1
    %         group = (thalamusInj_specialGroups(g).anyOverlap50thal(c).cores + thalamusInj_specialGroups(g).anyOverlap50thal(c).shells + thalamusInj_specialGroups(g).anyOverlap50(c).cores + thalamusInj_specialGroups(g).anyOverlap50(c).shells + thalamusInj_specialGroups(g).midOverlap5(c).cores + thalamusInj_specialGroups(g).midOverlap5(c).shells + thalamusInj_specialGroups(g).anyOverlap(c).cores + thalamusInj_specialGroups(g).anyOverlap(c).shells - thalamusInj_specialGroups(g).noOverlap(c).shells - thalamusInj_specialGroups(g).noOverlap5(c).cores - thalamusInj_specialGroups(g).noOverlap5(c).shells - thalamusInj_specialGroups(g).noOverlap50(c).cores - thalamusInj_specialGroups(g).noOverlap50thal(c).cores - thalamusInj_specialGroups(g).noOverlap50thal(c).cores).*~thalamusInj_specialGroups(g).noOverlap(c).cores; 
            % Level 2
            group = (thalamusInj_specialGroups(g).anyOverlap50thal(c).cores + thalamusInj_specialGroups(g).anyOverlap50thal(c).shells + thalamusInj_specialGroups(g).anyOverlap50(c).cores + thalamusInj_specialGroups(g).anyOverlap50(c).shells + thalamusInj_specialGroups(g).midOverlap5(c).cores + thalamusInj_specialGroups(g).midOverlap5(c).shells + thalamusInj_specialGroups(g).anyOverlap(c).cores + thalamusInj_specialGroups(g).anyOverlap(c).shells - thalamusInj_specialGroups(g).noOverlap(c).shells - thalamusInj_specialGroups(g).noOverlap5(c).cores - thalamusInj_specialGroups(g).noOverlap5(c).shells - thalamusInj_specialGroups(g).noOverlap50(c).cores - thalamusInj_specialGroups(g).noOverlap50thal(c).cores).*~thalamusInj_specialGroups(g).noOverlap(c).cores; 

            a = (group <= 0);% If subtraction makes it less than zero... 
            group = group.*~a.*avgThal;
            groupFlip = flipdim(group, 2);
            group = group + groupFlip;

            % 5-image overview
            for k = 5:10:45
                subplot(5, 1, sp)
                sp = sp+1;
                imshow(group(:, :, k), 'InitialMagnification', 1000)
                hold on
                outline = h_getNucleusOutline(betteraveragethalamus(:, :, k)>0);
                for j = 1:length(outline)
                    plot((outline{j}(:,2)), (outline{j}(:,1)), 'R-', 'linewidth',1);
                end
                hold off
                title(['Cluster ',num2str(c), ' of ', num2str(length(specialStriatalGroups{g})), ': section ', num2str(k), ' (Level 2)'])
                colormap(gray)
                caxis([0 8]) %max(group(:))])
            end
            saveas(fig, [saveDir, '/specialGroups/testingThalamusGroupingforClusters_', 'cluster',num2str(c), '_of_', num2str(length(specialStriatalGroups{g})), '_Level2.fig'], 'fig');
            print(fig, [saveDir, '/specialGroups/testingThalamusGroupingforClusters_', 'cluster',num2str(c), '_of_', num2str(length(specialStriatalGroups{g})), '_Level2.eps'], '-depsc2');
            close(fig)

            % All individual sections
            for k = 1:size(betteraveragethalamus, 3)
                fig = figure;
                set(fig, 'Position', [1570 790 350 250])
                imshow(group(:, :, k), 'Border', 'tight')
                hold on
        %         title([injGroup_data(g).cortical_group, ': section ', num2str(k), ' (Level 10)'])
                colormap(gray)
                caxis([0 8]) % max(group(:))])

                outline = h_getNucleusOutline(betteraveragethalamus(:, :, k));
                for j = 1:length(outline)
                    plot((outline{j}(:,2)), (outline{j}(:,1)), 'c-', 'linewidth',1)
                end
                hold off
                saveas(fig, [saveDir, '/specialGroups/Cluster', num2str(c), 'of', num2str(length(specialStriatalGroups{g})), '/thalamicProjToClusters_', 'cluster',num2str(c), '_of_', num2str(length(specialStriatalGroups{g})), '_section', num2str(k), '.fig'], 'fig');
                print(fig, [saveDir, '/specialGroups/Cluster', num2str(c), 'of', num2str(length(specialStriatalGroups{g})), '/thalamicProjToClusters_', 'cluster',num2str(c), '_of_', num2str(length(specialStriatalGroups{g})), '_section', num2str(k), '.eps'], '-depsc2');
                close(fig)
            end

        thalamusInj_specialGroups(g).cluster(c).cmap = group;
        end 
    end

    save('thalamusInj_specialGroups.mat', 'thalamusInj_specialGroups', '-v7.3')

    % update: 06-24-2015
    save('thalamusInj_specialGroups_20150624.mat', 'thalamusInj_specialGroups', '-v7.3')
    save('inj_thalData_20150624.mat', 'inj_thalData', '-v7.3')
    save('specialStriatalGroups_20150624.mat', 'specialStriatalGroups', '-v7.3')
end
    
    
%% 7. And redo the thalamus grouping for the clustered striatal allo/meso/neo & convergence areas

% ************************** NOT cleaned up yet ***************************

if figFlag == 7

    % ALLO/MESO/NEO: Load the allo/meso/neo maps (they load as the variable ctx for some dumb reason on my part)
    load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/injGroups_AlloMesoNeo.mat')
    % For reference: 
    % ctx(1).name = 'allocortex'; 
    % ctx(1).regions = {'SUB_HIPP', 'Amyg'};
    % ctx(2).name = 'mesocortex'; 
    % ctx(2).regions = {'ACA','AI_GU_VISC','ECT_PERI_TE','IL','ORBl','PL_MO','RSP'};
    % ctx(3).name = 'neocortex'; 
    % ctx(3).regions = {'AUD','FRA','MOp','PTL','SS', 'Vis'};


    % CONVERGENCE: The convergence data wasn't saved, so it needs to be remade:
    allRegions = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP', 'SS', 'Vis', 'SUB_HIPP', 'Amyg'};
    corticalGroup = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'SS', 'Vis', 'SUB_HIPP', 'Amyg', 'SNr', 'na'};
    for i = 1:3 %make sure to always do this step with the next one
        densityLevel{i} = zeros(size(injGroup_data(i).mask1.ipsilateral));
        numAreas = 0;
    end  
    for i = 1:length(corticalGroup)
        if ismember(injGroup_data(i).cortical_group, allRegions)

            c1 = injGroup_data(i).mask1.ipsilateral + injGroup_data(i).mask1.contralateral;
            c2 = injGroup_data(i).mask2.ipsilateral + injGroup_data(i).mask2.contralateral;  % Trying a change 5/9/15 was 2
            c3 = injGroup_data(i).mask5.ipsilateral + injGroup_data(i).mask5.contralateral;  % Trying a change 5/9/15 was 4

            densityLevel{1} = densityLevel{1} + c1;
            densityLevel{2} = densityLevel{2} + c2; 
            densityLevel{3} = densityLevel{3} + c3;
            numAreas = numAreas+1;
        end
    end
    level = 1; % The projection density you want to sum across (1 = diffuse, 2 = intermediate, 3 = dense)
    for l = 1:max(densityLevel{level}(:))
        convergenceSubregions(l).mask = densityLevel{level}(:, :, :) >= l;
        convergenceSubregions(l).mask(:, 1:57, :) = 0; %get rid of contralateral
    end
    for l = 1:max(densityLevel{level}(:))
        convergenceSubregions_lessThan(l).mask = (densityLevel{level}(:, :, :) <= l) & densityLevel{level}(:, :, :) > 0 ;
        convergenceSubregions_lessThan(l).mask(:, 1:57, :) = 0; %get rid of contralateral
    end



    specialStriatalGroups2 = {};

    % THALAMUS: Then group injections in the thalamus
    specialStriatalGroups2{1} = ctx;
    for i = 1:length(ctx)
        specialStriatalGroups2{1}(i).mask = specialStriatalGroups2{1}(i).mask3alone; %I am useing .mask below, and I only want dense allo/meso/neo
    end
    specialStriatalGroups2{1}(4).mask = specialStriatalGroups2{1}(1).mask3alone &~specialStriatalGroups2{1}(3).mask3alone;
    specialStriatalGroups2{1}(5).mask = specialStriatalGroups2{1}(3).mask3alone &~specialStriatalGroups2{1}(1).mask3alone;

    specialStriatalGroups2{2} = convergenceSubregions;
    specialStriatalGroups2{3} = convergenceSubregions_lessThan;

    thalamusInj_specialGroups2(1).groupings = 'allo/meso/neo/alloOnly/mesoOnly';
    thalamusInj_specialGroups2(2).groupings = 'convergenceSubregions';
    thalamusInj_specialGroups2(3).groupings = 'convergenceSubregions_lessThan';

    %Load the thalamostriatal data and the average brain
    load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/inj_thalData.mat') %Loading the thalamostriatal data from above
    load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/AIBS_100um.mat')
    ic_submask = AIBS_100um.striatum.ic_submask; % I'll need to apply this to the thalamus data

    saveDir = ('/Users/jeaninehunnicutt/Desktop/ThalamostriatalData_processed/Thalamostriatal_testFigures');
    mkdir([saveDir, '/specialGroups2'])

    %to get the average thalamus
    load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/std thal w traced nuclei & final adj atlas_2014-03-06.mat')
    avgThal = false(size(inj_thalData(2).injections(2).mask)); 
    avgThal(:, :, 1:size(betteraveragethalamus, 3)) = betteraveragethalamus; 

    for g = 3 %:length(specialStriatalGroups2) % Loop the cortical groups
        for c = 1: length(specialStriatalGroups2{g})
            mkdir([saveDir, '/specialGroups2/Cluster', num2str(c), 'of', num2str(length(specialStriatalGroups2{g}))])


            upsampledReplacedMask = specialStriatalGroups2{g}(c).mask;  %I am leavign the name upsampledReplacedMask out of laziness because this was copied from the clusters


            thalamusInj_specialGroups2(g).anyOverlap(c).cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_specialGroups2(g).anyOverlap(c).shells = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_specialGroups2(g).noOverlap(c).cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_specialGroups2(g).noOverlap(c).shells = false(size(inj_thalData(2).injections(1).mask));

            thalamusInj_specialGroups2(g).noOverlap5thal(c).cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_specialGroups2(g).noOverlap5thal(c).shells = false(size(inj_thalData(2).injections(1).mask));

            thalamusInj_specialGroups2(g).anyOverlap50(c).cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_specialGroups2(g).anyOverlap50(c).shells = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_specialGroups2(g).noOverlap50(c).cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_specialGroups2(g).noOverlap50(c).shells = false(size(inj_thalData(2).injections(1).mask));

            thalamusInj_specialGroups2(g).anyOverlap50thal(c).cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_specialGroups2(g).anyOverlap50thal(c).shells = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_specialGroups2(g).noOverlap50thal(c).cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_specialGroups2(g).noOverlap50thal(c).shells = false(size(inj_thalData(2).injections(1).mask));

            thalamusInj_specialGroups2(g).midOverlap5(c).cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_specialGroups2(g).midOverlap5(c).shells = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_specialGroups2(g).noOverlap5(c).cores = false(size(inj_thalData(2).injections(1).mask));
            thalamusInj_specialGroups2(g).noOverlap5(c).shells = false(size(inj_thalData(2).injections(1).mask));


            for t = 2:length(inj_thalData) % Loop the thalamus brains *no injection site for 1...
                for i = 1:4 % Loop the 4 possible injections per brain
                    if size(inj_thalData(t).injections(i).mask, 3) <65
                        makeThalLonger = false(size(inj_thalData(2).injections(1).mask));
                        makeThalLonger(:, :, 1:size(inj_thalData(t).injections(i).mask, 3)) = inj_thalData(t).injections(i).mask; 
                        inj_thalData(t).injections(i).mask = makeThalLonger; 
                        display(['Brain ', num2str(t), ' Injection ', num2str(i), ' ...fixed'])
                    end
                    if inj_thalData(t).projections(i) == 1; % if theres an injection to add
    % Level 2:
                        % 10% of thalamus proj is within striatal cluster 
                        if sum(upsampledReplacedMask(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(inj_thalData(t).projectionMasks(i).all(:)) >= 0.1; 
                            thalamusInj_specialGroups2(g).anyOverlap(c).cores = thalamusInj_specialGroups2(g).anyOverlap(c).cores | (inj_thalData(t).injections(i).mask(:, :, 1:65)  > 1);
                            thalamusInj_specialGroups2(g).anyOverlap(c).shells = logical(thalamusInj_specialGroups2(g).anyOverlap(c).shells + (inj_thalData(t).injections(i).mask(:, :, 1:65) > 0));

                        elseif sum(upsampledReplacedMask(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(inj_thalData(t).projectionMasks(i).all(:)) < 0.1
                            thalamusInj_specialGroups2(g).noOverlap5thal(c).cores = logical(thalamusInj_specialGroups2(g).noOverlap5thal(c).cores + (inj_thalData(t).injections(i).mask(:, :, 1:65) > 1));
                            thalamusInj_specialGroups2(g).noOverlap5thal(c).shells = logical(thalamusInj_specialGroups2(g).noOverlap5thal(c).shells + (inj_thalData(t).injections(i).mask(:, :, 1:65) > 0));
                        end

                        % 10% of striatal cluster is covered by mid thalamus proj
                        if sum(upsampledReplacedMask(:) & inj_thalData(t).projectionMasks(i).mid(:))/sum(upsampledReplacedMask(:)) >= 0.1; 
                            thalamusInj_specialGroups2(g).midOverlap5(c).cores = thalamusInj_specialGroups2(g).midOverlap5(c).cores | (inj_thalData(t).injections(i).mask(:, :, 1:65) > 1);
                            thalamusInj_specialGroups2(g).midOverlap5(c).shells = logical(thalamusInj_specialGroups2(g).midOverlap5(c).shells + (inj_thalData(t).injections(i).mask(:, :, 1:65) > 0));
                         elseif sum(injGroup_data(g).mask5.ipsilateral(:) & inj_thalData(t).projectionMasks(i).mid(:))/sum(injGroup_data(g).mask5.ipsilateral(:)) < 0.1
                            thalamusInj_specialGroups2(g).noOverlap5(c).cores = logical(thalamusInj_specialGroups2(g).noOverlap5(c).cores + (inj_thalData(t).injections(i).mask(:, :, 1:65) > 1));
                            thalamusInj_specialGroups2(g).noOverlap5(c).shells = logical(thalamusInj_specialGroups2(g).noOverlap5(c).shells + (inj_thalData(t).injections(i).mask(:, :, 1:65) > 0));
                        end

                        % For absolute subtraction... 
                        if (sum(upsampledReplacedMask(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(inj_thalData(t).projectionMasks(i).all(:)) < 0.1) && (sum(injGroup_data(g).mask5.ipsilateral(:) & inj_thalData(t).projectionMasks(i).mid(:))/sum(injGroup_data(g).mask5.ipsilateral(:)) < 0.1);
                             thalamusInj_specialGroups2(g).noOverlap(c).cores = logical(thalamusInj_specialGroups2(g).noOverlap(c).cores + (inj_thalData(t).injections(i).mask(:, :, 1:65) > 1));
                            thalamusInj_specialGroups2(g).noOverlap(c).shells = logical(thalamusInj_specialGroups2(g).noOverlap(c).shells + (inj_thalData(t).injections(i).mask(:, :, 1:65) > 0));
                        end

                        % 25% of striatal cluster is covered by any thalamus proj
                        if sum(upsampledReplacedMask(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(upsampledReplacedMask(:)) >= 0.25; 
                            thalamusInj_specialGroups2(g).anyOverlap50(c).cores = thalamusInj_specialGroups2(g).anyOverlap50(c).cores | (inj_thalData(t).injections(i).mask(:, :, 1:65) > 1);
                            thalamusInj_specialGroups2(g).anyOverlap50(c).shells = logical(thalamusInj_specialGroups2(g).anyOverlap50(c).shells + (inj_thalData(t).injections(i).mask(:, :, 1:65) > 0));

                         elseif sum(upsampledReplacedMask(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(upsampledReplacedMask(:)) < 0.25
                            thalamusInj_specialGroups2(g).noOverlap50(c).cores = logical(thalamusInj_specialGroups2(g).noOverlap50(c).cores + (inj_thalData(t).injections(i).mask(:, :, 1:65) > 1));
                            thalamusInj_specialGroups2(g).noOverlap50(c).shells = logical(thalamusInj_specialGroups2(g).noOverlap50(c).shells + (inj_thalData(t).injections(i).mask(:, :, 1:65) > 0));
                        end

                        % 25% of thalamus proj is within striatal cluster 
                        if sum(upsampledReplacedMask(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(inj_thalData(t).projectionMasks(i).all(:)) >= 0.25; 
                            thalamusInj_specialGroups2(g).anyOverlap50thal(c).cores = thalamusInj_specialGroups2(g).anyOverlap50thal(c).cores | (inj_thalData(t).injections(i).mask(:, :, 1:65) > 1);
                            thalamusInj_specialGroups2(g).anyOverlap50thal(c).shells = logical(thalamusInj_specialGroups2(g).anyOverlap50thal(c).shells + (inj_thalData(t).injections(i).mask(:, :, 1:65) > 0));

                         elseif sum(upsampledReplacedMask(:) & inj_thalData(t).projectionMasks(i).all(:))/sum(inj_thalData(t).projectionMasks(i).all(:)) < 0.25
                            thalamusInj_specialGroups2(g).noOverlap50thal(c).cores = logical(thalamusInj_specialGroups2(g).noOverlap50thal(c).cores + (inj_thalData(t).injections(i).mask(:, :, 1:65) > 1));
                            thalamusInj_specialGroups2(g).noOverlap50thal(c).shells = logical(thalamusInj_specialGroups2(g).noOverlap50thal(c).shells + (inj_thalData(t).injections(i).mask(:, :, 1:65) > 0));
                        end

                    elseif inj_thalData(t).projections(i) == 0; % if theres an injection to subtract
                        thalamusInj_specialGroups2(g).noOverlap(c).cores = logical(thalamusInj_specialGroups2(g).noOverlap(c).cores + (inj_thalData(t).injections(i).mask(:, :, 1:65) > 1));
                        thalamusInj_specialGroups2(g).noOverlap(c).shells = logical(thalamusInj_specialGroups2(g).noOverlap(c).shells + (inj_thalData(t).injections(i).mask(:, :, 1:65) > 0));
                    end
                end
            end

            % Create confidence map and show images
            sp = 1; 
            fig = figure;
            set(fig, 'Position', [1691 56 231 1050])
            group = []; 
            % Level 1
    %         group = (thalamusInj_specialGroups2(g).anyOverlap50thal(c).cores + thalamusInj_specialGroups2(g).anyOverlap50thal(c).shells + thalamusInj_specialGroups2(g).anyOverlap50(c).cores + thalamusInj_specialGroups2(g).anyOverlap50(c).shells + thalamusInj_specialGroups2(g).midOverlap5(c).cores + thalamusInj_specialGroups2(g).midOverlap5(c).shells + thalamusInj_specialGroups2(g).anyOverlap(c).cores + thalamusInj_specialGroups2(g).anyOverlap(c).shells - thalamusInj_specialGroups2(g).noOverlap(c).shells - thalamusInj_specialGroups2(g).noOverlap5(c).cores - thalamusInj_specialGroups2(g).noOverlap5(c).shells - thalamusInj_specialGroups2(g).noOverlap50(c).cores - thalamusInj_specialGroups2(g).noOverlap50thal(c).cores - thalamusInj_specialGroups2(g).noOverlap50thal(c).cores).*~thalamusInj_specialGroups2(g).noOverlap(c).cores; 
            % Level 2
            group = (thalamusInj_specialGroups2(g).anyOverlap50thal(c).cores + thalamusInj_specialGroups2(g).anyOverlap50thal(c).shells + thalamusInj_specialGroups2(g).anyOverlap50(c).cores + thalamusInj_specialGroups2(g).anyOverlap50(c).shells + thalamusInj_specialGroups2(g).midOverlap5(c).cores + thalamusInj_specialGroups2(g).midOverlap5(c).shells + thalamusInj_specialGroups2(g).anyOverlap(c).cores + thalamusInj_specialGroups2(g).anyOverlap(c).shells - thalamusInj_specialGroups2(g).noOverlap(c).shells - thalamusInj_specialGroups2(g).noOverlap5(c).cores - thalamusInj_specialGroups2(g).noOverlap5(c).shells - thalamusInj_specialGroups2(g).noOverlap50(c).cores - thalamusInj_specialGroups2(g).noOverlap50thal(c).cores).*~thalamusInj_specialGroups2(g).noOverlap(c).cores; 

            a = (group <= 0);% If subtraction makes it less than zero... 
            group = group.*~a.*avgThal;
            groupFlip = flipdim(group, 2);
            group = group + groupFlip;

            % 5-image overview
            for k = 5:10:45
                subplot(5, 1, sp)
                sp = sp+1;
                imshow(group(:, :, k), 'InitialMagnification', 1000)
                hold on
                outline = h_getNucleusOutline(betteraveragethalamus(:, :, k)>0);
                for j = 1:length(outline)
                    plot((outline{j}(:,2)), (outline{j}(:,1)), 'R-', 'linewidth',1);
                end
                hold off
                title(['Cluster ',num2str(c), ' of ', num2str(length(specialStriatalGroups2{g})), ': section ', num2str(k), ' (Level 2)'])
                colormap(gray)
                caxis([0 8]) %max(group(:))])
            end
            set(fig,'PaperPositionMode','auto')
            saveas(fig, [saveDir, '/specialGroups2/testingThalamusGroupingforClusters_', 'cluster',num2str(c), '_of_', num2str(length(specialStriatalGroups2{g})), '_Level2.fig'], 'fig');
            print(fig, [saveDir, '/specialGroups2/testingThalamusGroupingforClusters_', 'cluster',num2str(c), '_of_', num2str(length(specialStriatalGroups2{g})), '_Level2.eps'], '-depsc2');
            close(fig)

            % All individual sections
            for k = 1:size(betteraveragethalamus, 3)
                fig = figure;
                set(fig, 'Position', [1570 790 350 250])
                imshow(group(:, :, k), 'Border', 'tight')
                hold on
        %         title([injGroup_data(g).cortical_group, ': section ', num2str(k), ' (Level 10)'])
                colormap(gray)
                caxis([0 8]) % max(group(:))])

                outline = h_getNucleusOutline(betteraveragethalamus(:, :, k));
                for j = 1:length(outline)
                    plot((outline{j}(:,2)), (outline{j}(:,1)), 'c-', 'linewidth',1)
                end
                hold off
                set(fig,'PaperPositionMode','auto')
                saveas(fig, [saveDir, '/specialGroups2/Cluster', num2str(c), 'of', num2str(length(specialStriatalGroups2{g})), '/thalamicProjToClusters_', 'cluster',num2str(c), '_of_', num2str(length(specialStriatalGroups2{g})), '_section', num2str(k), '.fig'], 'fig');
                print(fig, [saveDir, '/specialGroups2/Cluster', num2str(c), 'of', num2str(length(specialStriatalGroups2{g})), '/thalamicProjToClusters_', 'cluster',num2str(c), '_of_', num2str(length(specialStriatalGroups2{g})), '_section', num2str(k), '.eps'], '-depsc2');
                close(fig)
            end

        thalamusInj_specialGroups2(g).cluster(c).cmap = group;
        end 
    end


    save('thalamusInj_specialGroups2.mat', 'thalamusInj_specialGroups2', '-v7.3')
    save('specialStriatalGroups2.mat', 'specialStriatalGroups2', '-v7.3')
end


%% 8. Count the total number of injections coverage, and overlap... (Methods Figure?)

% ************************** NOT cleaned up yet ***************************

if figFlag == 8
    a = 0; 
    coverage = false(size(inj_thalData(2).injections(1).mask));
    sumcoverage = zeros(size(inj_thalData(2).injections(1).mask));
    b = 0;
    for t = 2:length(inj_thalData) % Loop the thalamus brains *no injection site for 1...
        for i = 1:4 % Loop the 4 possible injections per brain
            if inj_thalData(t).projections(i) == 1; % if theres an injection to add
                a = a+1;
                coverage = logical(coverage + (inj_thalData(t).injections(i).mask > 0));
                sumcoverage = sumcoverage + double(inj_thalData(t).injections(i).mask > 0);
            elseif inj_thalData(t).projections(i) == 0; % if theres an injection to subtract
                a = a+1;
                coverage = logical(coverage + (inj_thalData(t).injections(i).mask > 0));
                sumcoverage = sumcoverage + double(inj_thalData(t).injections(i).mask > 0);
            elseif inj_thalData(t).projections(i) == -1; % if theres no/bad injection
                b = b+1;
            end
        end
    end

    coverage = coverage | flipdim(coverage, 2); 
    sumcoverage = sumcoverage + flipdim(sumcoverage, 2); 
    save('coverageByFullInjections.mat', 'sumcoverage');

    for v = 1:3
        figure, imagesc(squeeze(sum(coverage, v))>0)
        colormap(gray)
        hold on
        outline = h_getNucleusOutline(squeeze(sum(betteraveragethalamus, v))>0);
        for j = 1:length(outline)
            plot((outline{j}(:,2)), (outline{j}(:,1)), 'R-', 'linewidth',1)
        end
    end

    t2 = zeros(size(coverage));
    t2(:, 176:350, 1:65) = betteraveragethalamus(:, 176:350, :); 
    total = sum(t2(:));
    coverageVolume = sum(t2(:)&coverage(:));
    coveragePercent = coverageVolume/total;   % We have 90.25% coverage


    figure, imshow(sumcoverage(:, :, 10)) %This is the way to make a coverage map like the one we had.
    caxis('auto')

    % I got 218 injections used (either 1s or 0s), and 50 unusable (-1s), 
    % which means nothing is missing since 67x4 = 268
end

%% 9. OK, last but not least, Let calculate NUCLEUS COVERAGE - First, for corticostriatal convergence alone (FIGURE)

% ************************** NOT cleaned up yet ***************************

if figFlag == 9
    % I need to:
    %     1. Get the nucleus volumes 
    %     2. calculate the fraction of the nucleus covered
    %         - by the different confidence levels (pick 1 ...or 3)
    %         - for the 2 atlases (average them?)
    %         - as a new variable? nuclearOrigins_thalCtxConvergence.mat & nuclearOrigins_specialGroups.mat
    %     3. Make a heat map like thalamocortical paper Figure 6e 

    % Loads the nucleus masks as fatlas (fatlas(1)= AD-paxinos, fatlas(32)= fr-paxinos, fatlas(33)= AD-allen, fatlas(64)= fr-allen)
    % fatlas(1).name = 'AD'; 
    % fatlas(1).filename = 'nucleusPAXMask_AD_xyscaled.mat';
    % fatlas(1).volume = 2116;
    % fatlas(1).n2fmask = the full nucleus mask as <250x350x64> logical
    % fatlas(1).smallmask100 = seems to be slightly eroded nuclei, also as <250x350x64> logical
    
    disp('Where are the collected masks?')
    randomMasksDir = uigetdir;
    
    
    load([randomMasksDir, '/std thal w traced nuclei & final adj atlas_2014-03-06.mat']) %Loading the injection site thalamus data from the thalamocortical paper

    %Load the raw thalamostriatal data and the average brain
    load([anaDir, '/inj_thalData.mat']) %Loading the thalamostriatal data from above
    load([randomMasksDir, '/AIBS_100um.mat'])
    ic_submask = AIBS_100um.striatum.ic_submask; % I'll need to apply this to the thalamus data

    %Load the confidence maps of the thalamic origins of thalamostriatal inputs that converge with corticostriatal inputs, also has the corresponding thalamocortical confidence map
    %   *the individual confidence levels before they are summed are in thalamusInj_group_Level10.mat
    load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/thalCtx_StriatalConvergenceOrigins.mat')

    % Load the thalamostriatal cluster input confidence maps
    load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/thalamusInj_specialGroups.mat')

    %Load the red-white-blue colormap
    load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/cmap_blue0_white25_red1.mat')


    %Remove axon tracts and nuclei we're not using
    for p = 1:32
        atlasNucleusNames{p} = fatlas(p).name; 
    end
    nucleiToPlot = atlasNucleusNames(~ismember(atlasNucleusNames,{'fr', 'SPA', 'POL','LG','MH','LH', 'SPFp'}));

    % Remove arreas without their own thalamocortical maps
    projAreas_withThalamocorticalMaps = corticalGroup(~ismember(corticalGroup,{'SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'na', 'SNr', 'SUB_HIPP'}));  % I manually added in sub to get the nucleus coverage then removed again. 
    shortCoverage = coverage(:, :, 64);

    % Get the coverage values for all confidence levels of each group for selected nuclei 
    for g = 1:length(thalCtx_StriatalConvergenceOrigins)
        if sum(ismember(projAreas_withThalamocorticalMaps, injGroup_data(g).cortical_group)) > 0
            for p = 1:32
                 if sum(ismember(nucleiToPlot, fatlas(p).name)) > 0
                    ind = find(strcmp(nucleiToPlot, fatlas(p).name));
                    shortCmap = thalCtx_StriatalConvergenceOrigins(g).mask(:, :, 1:64);
                    shortCoverage = coverage(:, :, 1:64);
                    for cl = 1:6
                        nuclearOrigins_thalCtxConvergence(g).nucleusNames{ind} = fatlas(p).name; 
                        nuclearOrigins_thalCtxConvergence(g).fractionOccupied_Pax(ind, cl) = sum(fatlas(p).n2fmask(:) & (shortCmap(:) >= cl))/sum(fatlas(p).n2fmask(:)&shortCoverage(:));  % I need this to be fraction of jucleus covered... 
                        nuclearOrigins_thalCtxConvergence(g).fractionOccupied_Pax_eroded(ind, cl) = sum(fatlas(p).smallmask110(:) & (shortCmap(:) >= cl))/sum(fatlas(p).smallmask110(:)&shortCoverage(:));
                    end
                 end
            end
            p = 1;
            for a = 33:64
                if sum(ismember(nucleiToPlot, fatlas(a).name)) > 0
                    ind = find(strcmp(nucleiToPlot, fatlas(a).name));
                    shortCmap = thalCtx_StriatalConvergenceOrigins(g).mask(:, :, 1:65);
                    shortCoverage = coverage(:, :, 1:65);
                    for cl = 1:6
        %                 nuclearOrigins_thalCtxConvergence(g).nucleusNames{p} = fatlas(a).name; 
                        nuclearOrigins_thalCtxConvergence(g).fractionOccupied_AIBS(ind, cl) = sum(fatlas(a).n2fmask(:) & (shortCmap(:) >= cl))/sum(fatlas(a).n2fmask(:)&shortCoverage(:));
                        nuclearOrigins_thalCtxConvergence(g).fractionOccupied_AIBS_eroded(ind, cl) = sum(fatlas(a).smallmask110(:) & (shortCmap(:) >= cl))/sum(fatlas(a).smallmask110(:)&shortCoverage(:));
                    end
                    p = p+1;
                end
            end
        end
    end


    % Now make a composite map for the individual confidence levels (AIBS, Pax, and average)
    gg = 1; 
    for g = 1:length(thalCtx_StriatalConvergenceOrigins)
        if sum(ismember(projAreas_withThalamocorticalMaps, injGroup_data(g).cortical_group)) > 0
           nuclearOrigins_compositeMaps.nuclei = nuclearOrigins_thalCtxConvergence(g).nucleusNames;
    %         for p = 1:32
                for cl = 1:6
                    nuclearOrigins_compositeMaps.Pax(cl).coverage(:, gg) = nuclearOrigins_thalCtxConvergence(g).fractionOccupied_Pax_eroded(:, cl); 
                    nuclearOrigins_compositeMaps.AIBS(cl).coverage(:, gg) = nuclearOrigins_thalCtxConvergence(g).fractionOccupied_AIBS_eroded(:, cl); 
                    nuclearOrigins_compositeMaps.average_PaxAIBS(cl).coverage(:, gg) = mean([nuclearOrigins_thalCtxConvergence(g).fractionOccupied_AIBS_eroded(:, cl), nuclearOrigins_thalCtxConvergence(g).fractionOccupied_Pax_eroded(:, cl)], 2); 
                    nuclearOrigins_compositeMaps.groups{gg} = thalCtx_StriatalConvergenceOrigins(g).thalamostriatalGroup; 
                end
    %         end
            nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.coverage(:, gg) = mean([nuclearOrigins_compositeMaps.average_PaxAIBS(1).coverage(:, gg), nuclearOrigins_compositeMaps.average_PaxAIBS(3).coverage(:, gg), nuclearOrigins_compositeMaps.average_PaxAIBS(5).coverage(:, gg)], 2);
            nuclearOrigins_compositeMaps.nuclearGroupOrder = [1,2,3,6,7,14,15,18,19,11,8,21,13,4,5,12,16,22,23,24,25,9,10,20,17]; % for {'AD','AM','AV','CL','CM','IAD','IAM','IMD','LD','LP','MD','PCN','PR','PT','PVT','Pf','Po','RE','RH','RT_short','SMT','VAL','VM','VPL','VPM'}

            gg = gg+1;
        end
    end



    %I need to cluster these by common inputs
    for cl = 1:6
        % Pax nucleus clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_compositeMaps.Pax(cl).coverage,'cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure;
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_compositeMaps.Pax(cl).nucleusOrder = optimleaf;
        close(fig)

        % Pax group clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_compositeMaps.Pax(cl).coverage','cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure; 
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_compositeMaps.Pax(cl).groupOrder = optimleaf; 
        close(fig)

        % AIBS nucleus clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_compositeMaps.AIBS(cl).coverage,'cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure;
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_compositeMaps.AIBS(cl).nucleusOrder = optimleaf;
        close(fig)

        % AIBS group clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_compositeMaps.AIBS(cl).coverage','cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure; 
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_compositeMaps.AIBS(cl).groupOrder = optimleaf; 
        close(fig)

        % Average nucleus clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_compositeMaps.average_PaxAIBS(cl).coverage,'cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure;
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_compositeMaps.average_PaxAIBS(cl).nucleusOrder = optimleaf;
        close(fig)

        % Average group clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_compositeMaps.average_PaxAIBS(cl).coverage','cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure; 
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_compositeMaps.average_PaxAIBS(cl).groupOrder = optimleaf; 
        close(fig)

        % Average nucleus clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.coverage,'cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure;
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder = optimleaf;
        close(fig)

        % Average group clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.coverage','cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure; 
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.groupOrder = optimleaf; 
        close(fig)
    end



    %look at the plots
    o = 1; %Use a constant cluster order. 
    for cl = 1:6
    %     fig = figure;
    %     set(fig, 'Position', [1563 533 352 573])
    %     imagesc(nuclearOrigins_compositeMaps.Pax(cl).coverage(nuclearOrigins_compositeMaps.average_PaxAIBS(o).nucleusOrder, nuclearOrigins_compositeMaps.average_PaxAIBS(o).groupOrder))
    %     title(['Pax nuclear coverage: level ', num2str(cl)])
    % %     axis image
    %     set(gca, 'YTick', 1:length(nuclearOrigins_compositeMaps.nuclei))
    %     set(gca, 'YTickLabel', nuclearOrigins_compositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS(o).nucleusOrder))
    %     set(gca, 'XTick', 1:length(nuclearOrigins_compositeMaps.groups))
    %     set(gca, 'XTickLabel', nuclearOrigins_compositeMaps.groups(nuclearOrigins_compositeMaps.average_PaxAIBS(o).groupOrder))
    %     
    %     fig = figure;
    %     set(fig, 'Position', [1563 533 352 573])
    %     imagesc(nuclearOrigins_compositeMaps.AIBS(cl).coverage(nuclearOrigins_compositeMaps.average_PaxAIBS(o).nucleusOrder, nuclearOrigins_compositeMaps.average_PaxAIBS(o).groupOrder))
    %     title(['AIBS nuclear coverage: level ', num2str(cl)])
    % %     axis image
    %     set(gca, 'YTick', 1:length(nuclearOrigins_compositeMaps.nuclei))
    %     set(gca, 'YTickLabel', nuclearOrigins_compositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS(o).nucleusOrder))
    %     set(gca, 'XTick', 1:length(nuclearOrigins_compositeMaps.groups))
    %     set(gca, 'XTickLabel', nuclearOrigins_compositeMaps.groups(nuclearOrigins_compositeMaps.average_PaxAIBS(o).groupOrder))
    %   
        % I am settled on the average being best
        fig = figure;
        set(fig, 'Position', [1563 533 352 573])
        imagesc(nuclearOrigins_compositeMaps.average_PaxAIBS(cl).coverage(nuclearOrigins_compositeMaps.average_PaxAIBS(o).nucleusOrder, nuclearOrigins_compositeMaps.average_PaxAIBS(o).groupOrder))
        title(['Average nuclear coverage: level ', num2str(cl)])
    %     axis image
        set(gca, 'YTick', 1:length(nuclearOrigins_compositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_compositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS(o).nucleusOrder))
        set(gca, 'XTick', 1:length(nuclearOrigins_compositeMaps.groups))
        set(gca, 'XTickLabel', nuclearOrigins_compositeMaps.groups(nuclearOrigins_compositeMaps.average_PaxAIBS(o).groupOrder))

    end


    %look at just average average  ***I like this one better than nuclear group one
    fig = figure;
    set(fig, 'Position', [1563 533 352 573])
    imagesc(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.coverage(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.groupOrder))
    title(['Average nuclear coverage & Average of Levels 1/3/5'])
    colormap(cmap)
    set(gca, 'YTick', 1:length(nuclearOrigins_compositeMaps.nuclei))
    set(gca, 'YTickLabel', nuclearOrigins_compositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder))
    set(gca, 'XTick', 1:length(nuclearOrigins_compositeMaps.groups))
    set(gca, 'XTickLabel', nuclearOrigins_compositeMaps.groups(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.groupOrder))

    % saveDir = ('/Users/jeaninehunnicutt/Desktop/ThalamostriatalData_processed/Thalamostriatal_testFigures');
    % mkDir = ('/Users/jeaninehunnicutt/Desktop/ThalamostriatalData_processed/Thalamostriatal_testFigures/nuclearCoverage/');
    cd('/Users/jeaninehunnicutt/Desktop/ThalamostriatalData_processed/Thalamostriatal_testFigures/nuclearCoverage');
    
    saveas(fig, 'thalamocorticalConvergence_bySubregion_total_avgAIBSPax_avg135.fig', 'fig');  % This is the big grid of all nuclear convergence
    print(fig, 'thalamocorticalConvergence_bySubregion_total_avgAIBSPax_avg135.eps', '-depsc2');
    
    close(fig)

    %look at just average average *Ordered by nuclear groups
    fig = figure;
    set(fig, 'Position', [1563 533 352 573])
    imagesc(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.coverage(nuclearOrigins_compositeMaps.nuclearGroupOrder, nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.groupOrder))
    title(['Average nuclear coverage & Average of Levels 1/3/5'])
    colormap(cmap)
    set(gca, 'YTick', 1:length(nuclearOrigins_compositeMaps.nuclei))
    set(gca, 'YTickLabel', nuclearOrigins_compositeMaps.nuclei(nuclearOrigins_compositeMaps.nuclearGroupOrder))
    set(gca, 'XTick', 1:length(nuclearOrigins_compositeMaps.groups))
    set(gca, 'XTickLabel', nuclearOrigins_compositeMaps.groups(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.groupOrder))
end


%% 10. Make these coverage plots (heat maps and bar graphs) for the loop stuff (thalamocortical only / thalamostriatal only/ convergent)

% ************************** NOT cleaned up yet ***************************

if figFlag == 10

    saveDir = ('/Users/jeaninehunnicutt/Desktop/ThalamostriatalData_processed/Thalamostriatal_testFigures/');

    % Get the coverage values for all confidence levels of each group for selected nuclei 
    % I want to modify this for do it for thalamocortical only / thalamostriatal only / convergent area
    for g = 1:length(thalCtx_StriatalConvergenceOrigins)
        if sum(ismember(projAreas_withThalamocorticalMaps, injGroup_data(g).cortical_group)) > 0
            ThalStrMap = thalCtx_StriatalConvergenceOrigins(g).mask(:, :, 1:65);
            thalCtxMap = double(thalCtx_StriatalConvergenceOrigins(g).correspondingThalamoCorticalConfidenceMap); 
            TCTS_convergence = ThalStrMap & thalCtxMap; 
            bothMap = thalCtxMap | ThalStrMap; 
            TC_only = thalCtxMap &~ThalStrMap; 
            TS_only = ThalStrMap &~ thalCtxMap; 
            for p = 1:32
                 if sum(ismember(nucleiToPlot, fatlas(p).name)) > 0
                    ind = find(strcmp(nucleiToPlot, fatlas(p).name));
                    shortTC_only = TC_only(:, :, 1:64).*double(thalCtx_StriatalConvergenceOrigins(g).correspondingThalamoCorticalConfidenceMap(:, :, 1:64));
                    shortTS_only = TS_only(:, :, 1:64).*thalCtx_StriatalConvergenceOrigins(g).mask(:, :, 1:64);
                    shortTCTS_convergence = TCTS_convergence(:, :, 1:64).*thalCtx_StriatalConvergenceOrigins(g).mask(:, :, 1:64);
                    shortCoverage = coverage(:, :, 1:64);
                    for cl = 1:6
                        nuclearOrigins_thalCtxConvergence(g).nucleusNames{ind} = fatlas(p).name; 
                        nuclearOrigins_thalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalOnly(ind, cl) = sum(fatlas(p).smallmask110(:) & (shortTC_only(:) >= (cl+2)))/sum(fatlas(p).smallmask110(:)&shortCoverage(:)); %We used thresholds of 3, 5, and 7 for thalamocortical and it has a max of 8 istead of 6, so I am adding 2
                        nuclearOrigins_thalCtxConvergence(g).fractionOccupied_Pax_thalamoStriatalOnly(ind, cl) = sum(fatlas(p).smallmask110(:) & (shortTS_only(:) >= cl))/sum(fatlas(p).smallmask110(:)&shortCoverage(:));
                        nuclearOrigins_thalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalThalamoStriatalOverlap(ind, cl) = sum(fatlas(p).smallmask110(:) & (shortTCTS_convergence(:) >= cl))/sum(fatlas(p).smallmask110(:)&shortCoverage(:));
                    end
                 end
            end
            p = 1;
            for a = 33:64
                if sum(ismember(nucleiToPlot, fatlas(a).name)) > 0
                    ind = find(strcmp(nucleiToPlot, fatlas(a).name));
                    shortTC_only = TC_only(:, :, 1:65).*double(thalCtx_StriatalConvergenceOrigins(g).correspondingThalamoCorticalConfidenceMap(:, :, 1:65));
                    shortTS_only = TS_only(:, :, 1:65).*thalCtx_StriatalConvergenceOrigins(g).mask(:, :, 1:65);
                    shortTCTS_convergence = TCTS_convergence(:, :, 1:65).*thalCtx_StriatalConvergenceOrigins(g).mask(:, :, 1:65);
                    shortCoverage = coverage(:, :, 1:65);
                    for cl = 1:6
                        nuclearOrigins_thalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalOnly(ind, cl) = sum(fatlas(a).smallmask110(:) & (shortTC_only(:) >= (cl+2)))/sum(fatlas(a).smallmask110(:)&shortCoverage(:));
                        nuclearOrigins_thalCtxConvergence(g).fractionOccupied_AIBS_thalamoStriatalOnly(ind, cl) = sum(fatlas(a).smallmask110(:) & (shortTS_only(:) >= cl))/sum(fatlas(a).smallmask110(:)&shortCoverage(:));
                        nuclearOrigins_thalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalThalamoStriatalOverlap(ind, cl) = sum(fatlas(a).smallmask110(:) & (shortTCTS_convergence(:) >= cl))/sum(fatlas(a).smallmask110(:)&shortCoverage(:));
                    end
                    p = p+1;
                end
            end
        end
    end


    % Now make a composite map for the individual confidence levels (AIBS, Pax, and average)
    gg = 1; 
    for g = 1:length(thalCtx_StriatalConvergenceOrigins)
        if sum(ismember(projAreas_withThalamocorticalMaps, injGroup_data(g).cortical_group)) > 0
           nuclearOrigins_compositeMaps.nuclei = nuclearOrigins_thalCtxConvergence(g).nucleusNames;
    %         for p = 1:32
                for cl = 1:6
                    nuclearOrigins_compositeMaps.Pax_TC_TS_both(cl).area(gg).coverage(:, 1) = nuclearOrigins_thalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalOnly(:, cl);
                    nuclearOrigins_compositeMaps.Pax_TC_TS_both(cl).area(gg).coverage(:, 2) = nuclearOrigins_thalCtxConvergence(g).fractionOccupied_Pax_thalamoStriatalOnly(:, cl);
                    nuclearOrigins_compositeMaps.Pax_TC_TS_both(cl).area(gg).coverage(:, 3) = nuclearOrigins_thalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalThalamoStriatalOverlap(:, cl);
                    nuclearOrigins_compositeMaps.Pax_TC_TS_both(cl).all_TC.coverage(:, gg) = nuclearOrigins_thalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalOnly(:, cl);
                    nuclearOrigins_compositeMaps.Pax_TC_TS_both(cl).all_TS.coverage(:, gg) = nuclearOrigins_thalCtxConvergence(g).fractionOccupied_Pax_thalamoStriatalOnly(:, cl);
                    nuclearOrigins_compositeMaps.Pax_TC_TS_both(cl).all_TCTSoverlap.coverage(:, gg) = nuclearOrigins_thalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalThalamoStriatalOverlap(:, cl);

                    nuclearOrigins_compositeMaps.AIBS_TC_TS_both(cl).area(gg).coverage(:, 1) = nuclearOrigins_thalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalOnly(:, cl);
                    nuclearOrigins_compositeMaps.AIBS_TC_TS_both(cl).area(gg).coverage(:, 2) = nuclearOrigins_thalCtxConvergence(g).fractionOccupied_AIBS_thalamoStriatalOnly(:, cl);
                    nuclearOrigins_compositeMaps.AIBS_TC_TS_both(cl).area(gg).coverage(:, 3) = nuclearOrigins_thalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalThalamoStriatalOverlap(:, cl);
                    nuclearOrigins_compositeMaps.AIBS_TC_TS_both(cl).all_TC.coverage(:, gg) = nuclearOrigins_thalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalOnly(:, cl);
                    nuclearOrigins_compositeMaps.AIBS_TC_TS_both(cl).all_TS.coverage(:, gg) = nuclearOrigins_thalCtxConvergence(g).fractionOccupied_AIBS_thalamoStriatalOnly(:, cl);
                    nuclearOrigins_compositeMaps.AIBS_TC_TS_both(cl).all_TCTSoverlap.coverage(:, gg) = nuclearOrigins_thalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalThalamoStriatalOverlap(:, cl);

                    nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both(cl).area(gg).coverage(:, 1) = mean([nuclearOrigins_thalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalOnly(:, cl), nuclearOrigins_thalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalOnly(:, cl)], 2);
                    nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both(cl).area(gg).coverage(:, 2) = mean([nuclearOrigins_thalCtxConvergence(g).fractionOccupied_AIBS_thalamoStriatalOnly(:, cl), nuclearOrigins_thalCtxConvergence(g).fractionOccupied_Pax_thalamoStriatalOnly(:, cl)], 2);
                    nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both(cl).area(gg).coverage(:, 3) = mean([nuclearOrigins_thalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalThalamoStriatalOverlap(:, cl), nuclearOrigins_thalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalThalamoStriatalOverlap(:, cl)], 2);
                    nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both(cl).all_TC.coverage(:, gg) = mean([nuclearOrigins_thalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalOnly(:, cl), nuclearOrigins_thalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalOnly(:, cl)], 2);
                    nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both(cl).all_TS.coverage(:, gg) = mean([nuclearOrigins_thalCtxConvergence(g).fractionOccupied_AIBS_thalamoStriatalOnly(:, cl), nuclearOrigins_thalCtxConvergence(g).fractionOccupied_Pax_thalamoStriatalOnly(:, cl)], 2);
                    nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both(cl).all_TCTSoverlap.coverage(:, gg) = mean([nuclearOrigins_thalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalThalamoStriatalOverlap(:, cl), nuclearOrigins_thalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalThalamoStriatalOverlap(:, cl)], 2);

                end
    %         end
            nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(gg).coverage(:, 1) = mean([nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both(1).area(gg).coverage(:, 1), nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both(3).area(gg).coverage(:, 1), nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both(5).area(gg).coverage(:, 1)], 2);
            nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(gg).coverage(:, 2) = mean([nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both(1).area(gg).coverage(:, 2), nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both(3).area(gg).coverage(:, 2), nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both(5).area(gg).coverage(:, 2)], 2);
            nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(gg).coverage(:, 3) = mean([nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both(1).area(gg).coverage(:, 3), nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both(3).area(gg).coverage(:, 3), nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both(5).area(gg).coverage(:, 3)], 2);
            nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.all_TC.coverage(:, gg) = mean([nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both(1).area(gg).coverage(:, 1), nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both(3).area(gg).coverage(:, 1), nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both(5).area(gg).coverage(:, 1)], 2);
            nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.all_TS.coverage(:, gg) = mean([nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both(1).area(gg).coverage(:, 2), nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both(3).area(gg).coverage(:, 2), nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both(5).area(gg).coverage(:, 2)], 2);
            nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.all_TCTSoverlap.coverage(:, gg) = mean([nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both(1).area(gg).coverage(:, 3), nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both(3).area(gg).coverage(:, 3), nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both(5).area(gg).coverage(:, 3)], 2);

            nuclearOrigins_compositeMaps.nuclearGroupOrder = [1,2,3,6,7,14,15,18,19,11,8,21,13,4,5,12,16,22,23,24,25,9,10,20,17]; % for {'AD','AM','AV','CL','CM','IAD','IAM','IMD','LD','LP','MD','PCN','PR','PT','PVT','Pf','Po','RE','RH','RT_short','SMT','VAL','VM','VPL','VPM'}
            gg = gg+1;
        end
    end

    %Images of the thalamocortical only, thalamostriatal only, and thalamic origin overlap
    for g = 1:length(nuclearOrigins_compositeMaps.groups)
        %Just overlap white
        fig = figure;
        set(fig, 'Position', [1795 210 128 896])
        oneColumn = nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(g).coverage(:, 3);
        imagesc(oneColumn(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :))
        axis image
        title([nuclearOrigins_compositeMaps.groups(g), ': Overlap'])
        caxis([0 1])
        colormap(cmap_white)
        set(gca, 'YTick', 1:length(nuclearOrigins_compositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_compositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder))
        set(gca, 'XTick', 1)
        set(gca, 'XTickLabel', {'TCTSoverlap'});
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_Overlap_',nuclearOrigins_compositeMaps.groups{g}, '.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_Overlap_',nuclearOrigins_compositeMaps.groups{g}, '.eps'], '-depsc2');
        close(fig)

        %Just TS magenta
        fig = figure;
        set(fig, 'Position', [1795 210 128 896])
        oneColumn = nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(g).coverage(:, 2); 
        imagesc(oneColumn(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :))
        title([nuclearOrigins_compositeMaps.groups(g), ': Thalamostriatal'])
        axis image
        caxis([0 1])
        colormap(cmap_magenta)
        set(gca, 'YTick', 1:length(nuclearOrigins_compositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_compositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder))
        set(gca, 'XTick', 1)
        set(gca, 'XTickLabel', {'TS'});
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_TS_',nuclearOrigins_compositeMaps.groups{g}, '.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_TS_',nuclearOrigins_compositeMaps.groups{g}, '.eps'], '-depsc2');
        close(fig)

        %Just TC cyan
        fig = figure;
        set(fig, 'Position', [1795 210 128 896])
        oneColumn = nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(g).coverage(:, 1);
        imagesc(oneColumn(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :))
        title([nuclearOrigins_compositeMaps.groups(g), ': Thalamocortical'])
        axis image
        caxis([0 1])
        colormap(cmap_cyan)
        set(gca, 'YTick', 1:length(nuclearOrigins_compositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_compositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder))
        set(gca, 'XTick', 1)
        set(gca, 'XTickLabel', {'TC'});
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_TC_',nuclearOrigins_compositeMaps.groups{g}, '.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_TC_',nuclearOrigins_compositeMaps.groups{g}, '.eps'], '-depsc2');
        close(fig)

        %all 3 white
        fig = figure;
        set(fig, 'Position', [1753 210 167 896])
        imagesc(nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(g).coverage(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :))
        title([nuclearOrigins_compositeMaps.groups(g), ': thalamocortical, thalamostriatal, & dual projection origins: average nuclear coverage & Average of Levels 1/3/5'])
        axis image
        caxis([0 1])
        colormap(cmap)
        set(gca, 'YTick', 1:length(nuclearOrigins_compositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_compositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder))
        set(gca, 'XTick', 1:3)
        set(gca, 'XTickLabel', {'TC', 'TS', 'TCTSoverlap'});
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_all_',nuclearOrigins_compositeMaps.groups{g}, '.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_all_',nuclearOrigins_compositeMaps.groups{g}, '.eps'], '-depsc2');
        close(fig)
    end

    % ***** Adding in another of the plot above for corticothalamic data *****
    % (this data was created at the bottom of jh_consolidatingAIBS_forGephi.m and originally from GetDensityDataFromWeb.py)
    % I put the data in injGroup_data.mat inder the field injGroup_data(g).nuclearProjections(n) : where n are the 25 nuclei we're looking at: IMD,MD,RH,CM,PR,SMT,PF,LP,PCN,CL,IAM,PVT,PT,RE,IAD,AM,AD,LD,PO,VAL,VM,VPM,AV,RT,VPL
    corticalGroup = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'SS', 'Vis', 'SUB_HIPP', 'Amyg', 'SNr', 'na'};
    projAreas_toKeep = corticalGroup(~ismember(corticalGroup,{'SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'na', 'SNr'}));  % I manually added in sub to get the nucleus coverage then removed again. 

    for g = 1:length(injGroup_data)
        if sum(ismember(projAreas_toKeep, injGroup_data(g).cortical_group)) > 0
            %Generate the max values for the projections
            for n = 1:length(injGroup_data(g).nuclearProjections)
                oneColumn(n) = max(injGroup_data(g).nuclearProjections(n).projDensity); 
            end
            %Plot max density of Corticothalamic proj to each nucleus in green
            fig = figure;
            set(fig, 'Position', [1795 210 128 896])
            imagesc(oneColumn)
            axis image
            title([injGroup_data(g).cortical_group, ': CT'])
            caxis([0 0.6])
            colormap(cmap_green)
            set(gca, 'YTick', 1:length(nuclearOrigins_compositeMaps.nuclei))
            set(gca, 'YTickLabel', nuclearOrigins_compositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder))
            set(gca, 'XTick', 1)
            set(gca, 'XTickLabel', {'CT'});
            set(fig,'PaperPositionMode','auto')
            saveas(fig, [saveDir, 'nuclearCoverage/CT_Overlap_',injGroup_data(g).cortical_group, '.fig'], 'fig');
            print(fig, [saveDir, 'nuclearCoverage/CT_Overlap_',injGroup_data(g).cortical_group, '.eps'], '-depsc2');
            close(fig)
        end
    end



    % now a horozontal stacked bar plot
    for g = 14 %:length(nuclearOrigins_compositeMaps.groups)
        fig = figure;
        set(fig, 'Position', [1715 267 205 839])
    %     level0 = nuclearOrigins_compositeMaps.average_PaxAIBS(6).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g);
        level1 = nuclearOrigins_compositeMaps.average_PaxAIBS(1).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g) - nuclearOrigins_compositeMaps.average_PaxAIBS(3).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g);
        level3 = nuclearOrigins_compositeMaps.average_PaxAIBS(3).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g) - nuclearOrigins_compositeMaps.average_PaxAIBS(5).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g);
        level5 = nuclearOrigins_compositeMaps.average_PaxAIBS(5).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g); % - nuclearOrigins_compositeMaps.average_PaxAIBS(6).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g);

        barh([level5, level3 level1], 'stacked')
        hold on
        plot(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g), 1:length(nuclearOrigins_compositeMaps.nuclei), 'c-')

        title([nuclearOrigins_compositeMaps.groups(g), ': thalamocortical, thalamostriatal, & dual projection origins: average nuclear coverage & Average of Levels 1/3/5'])
        colormap(cmap_barLevels)
        set(gca, 'YTick', 1:length(nuclearOrigins_compositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_compositeMaps.nuclei(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2)))
    %     set(gca, 'XTick', 1:3)
        legend({'5', '3', '1'});
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/nuclearCoverageLevels123_BAR_',nuclearOrigins_compositeMaps.groups{g}, '.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/nuclearCoverageLevels123_BAR_',nuclearOrigins_compositeMaps.groups{g}, '.eps'], '-depsc2');
        close(fig)
    end
end



%% 11. Make these coverage plots (heat maps and bar graphs) for the inputs to striatal clusters

% ************************** NOT cleaned up yet ***************************

if figFlag == 11

    saveDir = ('/Users/jeaninehunnicutt/Desktop/ThalamostriatalData_processed/Thalamostriatal_testFigures/');

    % Load the thalamostriatal cluster input confidence maps
    load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/thalamusInj_specialGroups.mat')

    %Update: 6/21/15

    load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/std thal w traced nuclei & final adj atlas_2014-03-06.mat')
    load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/specialStriatalGroups.mat')
    load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/coverageByFullInjections.mat')
    load('nuclearOrigins_thalCtxConvergence.mat')
    load('nuclearOrigins_compositeMaps.mat')

    % thalamusInj_specialGroups(g).cluster(c).cmap = group; %the data to access

    %Remove axon tracts and nuclei we're not using
    for p = 1:32
        atlasNucleusNames{p} = fatlas(p).name; 
    end
    nucleiToPlot = atlasNucleusNames(~ismember(atlasNucleusNames,{'fr', 'SPA', 'POL','LG','MH','LH', 'SPFp'}));


    % Get the coverage values for all confidence levels of each group for selected nuclei 
    for g = 1:length(thalamusInj_specialGroups)%1:length(thalamusInj_specialGroups) % Loop through all cortical groups
        mkdir([saveDir, 'nuclearCoverage/', num2str(length(specialStriatalGroups{g})), 'clusters'])
        for c = 1:length(thalamusInj_specialGroups(g).cluster) %number of dendrogram clusters
            for p = 1:32 %Number of thalamic nuclei
                 if sum(ismember(nucleiToPlot, fatlas(p).name)) > 0
                    ind = find(strcmp(nucleiToPlot, fatlas(p).name));
                    shortCmap = thalamusInj_specialGroups(g).cluster(c).cmap(:, :, 1:64);
                    shortCoverage = coverage(:, :, 1:64);
                    for cl = 1:8
                        nuclearOrigins_thalToClusters(g).cluster(c).nucleusNames{ind} = fatlas(p).name; 
                        nuclearOrigins_thalToClusters(g).cluster(c).fractionOccupied_Pax(ind, cl) = sum(fatlas(p).n2fmask(:) & (shortCmap(:) >= cl))/sum(fatlas(p).n2fmask(:)&shortCoverage(:));  % I need this to be fraction of jucleus covered... 
                        nuclearOrigins_thalToClusters(g).cluster(c).fractionOccupied_Pax_eroded(ind, cl) = sum(fatlas(p).smallmask110(:) & (shortCmap(:) >= cl))/sum(fatlas(p).smallmask110(:)&shortCoverage(:));
                    end
                 end
            end
            p = 1;
            for a = 33:64
                if sum(ismember(nucleiToPlot, fatlas(a).name)) > 0
                    ind = find(strcmp(nucleiToPlot, fatlas(a).name));
                    shortCmap = thalamusInj_specialGroups(g).cluster(c).cmap(:, :, 1:65);
                    shortCoverage = coverage(:, :, 1:65);
                    for cl = 1:8
    %                   nuclearOrigins_thalToClusters(g).cluster(c).nucleusNames{p} = fatlas(a).name; 
                        nuclearOrigins_thalToClusters(g).cluster(c).fractionOccupied_AIBS(ind, cl) = sum(fatlas(a).n2fmask(:) & (shortCmap(:) >= cl))/sum(fatlas(a).n2fmask(:)&shortCoverage(:));
                        nuclearOrigins_thalToClusters(g).cluster(c).fractionOccupied_AIBS_eroded(ind, cl) = sum(fatlas(a).smallmask110(:) & (shortCmap(:) >= cl))/sum(fatlas(a).smallmask110(:)&shortCoverage(:));
                    end
                    p = p+1;
                end
            end
        end
    end


    % Now make a composite map for the individual confidence levels (AIBS, Pax, and average)
    for g = 1:length(thalamusInj_specialGroups) % Loop through all cortical groups
    %     mkdir([saveDir, 'nuclearCoverage/', num2str(length(specialStriatalGroups{g})), 'clusters'])
        for c = 1:length(thalamusInj_specialGroups(g).cluster)
           nuclearOrigins_thalToClusters_compositeMaps(g).nuclei = nuclearOrigins_thalCtxConvergence(g).nucleusNames;
                for cl = 1:8
                    nuclearOrigins_thalToClusters_compositeMaps(g).Pax(cl).coverage(:, c) = nuclearOrigins_thalToClusters(g).cluster(c).fractionOccupied_Pax_eroded(:, cl); 
                    nuclearOrigins_thalToClusters_compositeMaps(g).AIBS(cl).coverage(:, c) = nuclearOrigins_thalToClusters(g).cluster(c).fractionOccupied_AIBS_eroded(:, cl); 
                    nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS(cl).coverage(:, c) = mean([nuclearOrigins_thalToClusters(g).cluster(c).fractionOccupied_AIBS_eroded(:, cl), nuclearOrigins_thalToClusters(g).cluster(c).fractionOccupied_Pax_eroded(:, cl)], 2); 
                    nuclearOrigins_thalToClusters_compositeMaps(g).groups{c} = (['Cluster ', num2str(c)]); 
                end
            nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS_averageOfLevels147.coverage(:, c) = mean([nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS(1).coverage(:, c), nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS(4).coverage(:, c), nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS(7).coverage(:, c)], 2);

            nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS_averageOfLevels257.coverage(:, c) = mean([nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS(2).coverage(:, c), nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS(5).coverage(:, c), nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS(7).coverage(:, c)], 2); %UPDATE: 6/21/15
            nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS_averageOfLevels357.coverage(:, c) = mean([nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS(3).coverage(:, c), nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS(5).coverage(:, c), nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS(7).coverage(:, c)], 2); %UPDATE: 6/21/15

            nuclearOrigins_thalToClusters_compositeMaps(g).nuclearGroupOrder = [1,2,3,6,7,14,15,18,19,11,8,21,13,4,5,12,16,22,23,24,25,9,10,20,17]; % for {'AD','AM','AV','CL','CM','IAD','IAM','IMD','LD','LP','MD','PCN','PR','PT','PVT','Pf','Po','RE','RH','RT_short','SMT','VAL','VM','VPL','VPM'}
        end
    end



    %I need to cluster these by common inputs ...nm
    for g = 1:length(thalamusInj_specialGroups)
        % Average nucleus clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS_averageOfLevels147.coverage,'cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure;
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS_averageOfLevels147.nucleusOrder = optimleaf;
        close(fig)

        % Average group clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS_averageOfLevels147.coverage','cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure; 
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS_averageOfLevels147.groupOrder = optimleaf; 
        close(fig)
    end


    %look at the plots
    o = 1; %Use a constant cluster order. 
    g = 1; 
    for cl = 1:8
    %     fig = figure;
    %     set(fig, 'Position', [1563 533 352 573])
    %     imagesc(nuclearOrigins_compositeMaps.Pax(cl).coverage(nuclearOrigins_compositeMaps.average_PaxAIBS(o).nucleusOrder, nuclearOrigins_compositeMaps.average_PaxAIBS(o).groupOrder))
    %     title(['Pax nuclear coverage: level ', num2str(cl)])
    % %     axis image
    %     set(gca, 'YTick', 1:length(nuclearOrigins_compositeMaps.nuclei))
    %     set(gca, 'YTickLabel', nuclearOrigins_compositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS(o).nucleusOrder))
    %     set(gca, 'XTick', 1:length(nuclearOrigins_compositeMaps.groups))
    %     set(gca, 'XTickLabel', nuclearOrigins_compositeMaps.groups(nuclearOrigins_compositeMaps.average_PaxAIBS(o).groupOrder))
    %     
    %     fig = figure;
    %     set(fig, 'Position', [1563 533 352 573])
    %     imagesc(nuclearOrigins_compositeMaps.AIBS(cl).coverage(nuclearOrigins_compositeMaps.average_PaxAIBS(o).nucleusOrder, nuclearOrigins_compositeMaps.average_PaxAIBS(o).groupOrder))
    %     title(['AIBS nuclear coverage: level ', num2str(cl)])
    % %     axis image
    %     set(gca, 'YTick', 1:length(nuclearOrigins_compositeMaps.nuclei))
    %     set(gca, 'YTickLabel', nuclearOrigins_compositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS(o).nucleusOrder))
    %     set(gca, 'XTick', 1:length(nuclearOrigins_compositeMaps.groups))
    %     set(gca, 'XTickLabel', nuclearOrigins_compositeMaps.groups(nuclearOrigins_compositeMaps.average_PaxAIBS(o).groupOrder))
    %   
        % I am settled on the average being best
        fig = figure;
        set(fig, 'Position', [1563 533 352 573])
        imagesc(nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS(cl).coverage(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :))
        title(['Average nuclear coverage: ', num2str(length(thalamusInj_specialGroups(g).cluster)), ' clusters'])
    %     axis image
    %     colormap(cmap)
        set(gca, 'YTick', 1:length(nuclearOrigins_thalToClusters_compositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_thalToClusters_compositeMaps(g).nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder))
        set(gca, 'XTick', 1:length(nuclearOrigins_thalToClusters_compositeMaps.groups))
        set(gca, 'XTickLabel', nuclearOrigins_thalToClusters_compositeMaps(g).groups(:))
    end

    % save images of the nuclear origins of cluster groups
    for g = 1:length(thalamusInj_specialGroups)
        fig = figure;
        set(fig, 'Position', [1491 534 424 572])
        imagesc(nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS_averageOfLevels147.coverage(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :))
        title(['Average (1/4/7) nuclear coverage: ', num2str(length(thalamusInj_specialGroups(g).cluster)), ' clusters'])
        %     axis image
        colormap(cmap)
        set(gca, 'YTick', 1:length(nuclearOrigins_thalToClusters_compositeMaps(g).nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_thalToClusters_compositeMaps(g).nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder))
        set(gca, 'XTick', 1:length(nuclearOrigins_thalToClusters_compositeMaps(g).groups))
        set(gca, 'XTickLabel', nuclearOrigins_thalToClusters_compositeMaps(g).groups(:))
        axis image
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/clusters/nuclearCoverageLevels147_',num2str(length(thalamusInj_specialGroups(g).cluster)), ' clusters.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/clusters/nuclearCoverageLevels147_',num2str(length(thalamusInj_specialGroups(g).cluster)), ' clusters.eps'], '-depsc2');
        close(fig)
    end

    %Images of the thalamocortical only, thalamostriatal only, and thalamic origin overlap
    for g = 1:length(nuclearOrigins_compositeMaps.groups)
        %Just overlap white
        fig = figure;
        set(fig, 'Position', [1795 210 128 896])
        oneColumn = nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(g).coverage(:, 3);
        imagesc(oneColumn(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :))
        axis image
        title([nuclearOrigins_compositeMaps.groups(g), ': Overlap'])
        colormap(cmap_white)
        set(gca, 'YTick', 1:length(nuclearOrigins_compositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_compositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder))
        set(gca, 'XTick', 1)
        set(gca, 'XTickLabel', {'TCTSoverlap'});
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_Overlap_',nuclearOrigins_compositeMaps.groups{g}, '.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_Overlap_',nuclearOrigins_compositeMaps.groups{g}, '.eps'], '-depsc2');
        close(fig)

        %Just TS magenta
        fig = figure;
        set(fig, 'Position', [1795 210 128 896])
        oneColumn = nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(g).coverage(:, 2); 
        imagesc(oneColumn(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :))
        title([nuclearOrigins_compositeMaps.groups(g), ': Thalamostriatal'])
        axis image
        colormap(cmap_magenta)
        set(gca, 'YTick', 1:length(nuclearOrigins_compositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_compositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder))
        set(gca, 'XTick', 1)
        set(gca, 'XTickLabel', {'TS'});
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_TS_',nuclearOrigins_compositeMaps.groups{g}, '.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_TS_',nuclearOrigins_compositeMaps.groups{g}, '.eps'], '-depsc2');
        close(fig)

        %Just TC cyan
        fig = figure;
        set(fig, 'Position', [1795 210 128 896])
        oneColumn = nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(g).coverage(:, 1);
        imagesc(oneColumn(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :))
        title([nuclearOrigins_compositeMaps.groups(g), ': Thalamocortical'])
        axis image
        colormap(cmap_cyan)
        set(gca, 'YTick', 1:length(nuclearOrigins_compositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_compositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder))
        set(gca, 'XTick', 1)
        set(gca, 'XTickLabel', {'TC'});
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_TC_',nuclearOrigins_compositeMaps.groups{g}, '.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_TC_',nuclearOrigins_compositeMaps.groups{g}, '.eps'], '-depsc2');
        close(fig)

        %all 3 white
        fig = figure;
        set(fig, 'Position', [1753 210 167 896])
        imagesc(nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(g).coverage(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :))
        title([nuclearOrigins_compositeMaps.groups(g), ': thalamocortical, thalamostriatal, & dual projection origins: average nuclear coverage & Average of Levels 1/3/5'])
        axis image
        colormap(cmap)
        set(gca, 'YTick', 1:length(nuclearOrigins_compositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_compositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder))
        set(gca, 'XTick', 1:3)
        set(gca, 'XTickLabel', {'TC', 'TS', 'TCTSoverlap'});
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_all_',nuclearOrigins_compositeMaps.groups{g}, '.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_all_',nuclearOrigins_compositeMaps.groups{g}, '.eps'], '-depsc2');
        close(fig)
    end

    % now a horozontal stacked bar plot
    for g = 1:length(nuclearOrigins_thalToClusters_compositeMaps)
        for c = 1:length(thalamusInj_specialGroups(g).cluster)
            fig = figure;
            set(fig, 'Position', [1715 267 205 839])
        %     level0 = nuclearOrigins_compositeMaps.average_PaxAIBS(6).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g);
            level1 = nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS(1).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c) - nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS(4).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c);
            level3 = nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS(4).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c) - nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS(7).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c);
            level5 = nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS(7).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c); % - nuclearOrigins_compositeMaps.average_PaxAIBS(6).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g);

            barh([level5, level3 level1], 'stacked')
            hold on
            plot(nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS_averageOfLevels147.coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c), 1:length(nuclearOrigins_thalToClusters_compositeMaps(g).nuclei), 'c-')

            title(['Average (1/4/7) nuclear coverage: Cluster ',num2str(c), ' of ', num2str(length(thalamusInj_specialGroups(g).cluster))]) 
            colormap(cmap_barLevels)
            set(gca, 'XLim', [0 1])
            set(gca, 'YTick', 1:length(nuclearOrigins_thalToClusters_compositeMaps(g).nuclei))
            set(gca, 'YTickLabel', nuclearOrigins_thalToClusters_compositeMaps(g).nuclei(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2)))
        %     set(gca, 'XTick', 1:3)
            legend({'7', '4', '1'});
            set(fig,'PaperPositionMode','auto')
            saveas(fig, [saveDir, 'nuclearCoverage/clusters/nuclearCoverageLevels147_BAR_cluster',num2str(c), 'of', num2str(length(thalamusInj_specialGroups(g).cluster)), '.fig'], 'fig');
            print(fig, [saveDir, 'nuclearCoverage/clusters/nuclearCoverageLevels147_BAR_cluster',num2str(c), 'of', num2str(length(thalamusInj_specialGroups(g).cluster)), '.eps'], '-depsc2');
            close(fig)
        end
    end

    % trying 2/5/7 & 3/5/7, 1/4/7 was too inclusive: for horozontal stacked bar plot
    for g = 1:length(nuclearOrigins_thalToClusters_compositeMaps)
        for c = 1:length(thalamusInj_specialGroups(g).cluster)

            fig = figure;
            set(fig, 'Position', [1715 267 205 839])
        %     level0 = nuclearOrigins_compositeMaps.average_PaxAIBS(6).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g);
            level1 = nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS(2).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c) - nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS(5).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c);
            level3 = nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS(5).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c) - nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS(7).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c);
            level5 = nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS(7).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c); % - nuclearOrigins_compositeMaps.average_PaxAIBS(6).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g);

            barh([level5, level3 level1], 'stacked')
            hold on
            plot(nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS_averageOfLevels257.coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c), 1:length(nuclearOrigins_thalToClusters_compositeMaps(g).nuclei), 'c-')

            title(['Average (2/5/7) nuclear coverage: Cluster ',num2str(c), ' of ', num2str(length(thalamusInj_specialGroups(g).cluster))]) 
            colormap(cmap_barLevels)
            set(gca, 'XLim', [0 1])
            set(gca, 'YTick', 1:length(nuclearOrigins_thalToClusters_compositeMaps(g).nuclei))
            set(gca, 'YTickLabel', nuclearOrigins_thalToClusters_compositeMaps(g).nuclei(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2)))
        %     set(gca, 'XTick', 1:3)
            legend({'7', '5', '2'});
            set(fig,'PaperPositionMode','auto')
            saveas(fig, [saveDir, 'nuclearCoverage/clusters_2015_06_21/nuclearCoverageLevels257_BAR_cluster',num2str(c), 'of', num2str(length(thalamusInj_specialGroups(g).cluster)), '.fig'], 'fig');
            print(fig, [saveDir, 'nuclearCoverage/clusters_2015_06_21/nuclearCoverageLevels257_BAR_cluster',num2str(c), 'of', num2str(length(thalamusInj_specialGroups(g).cluster)), '.eps'], '-depsc2');
            close(fig)


            fig = figure;
            set(fig, 'Position', [1715 267 205 839])
        %     level0 = nuclearOrigins_compositeMaps.average_PaxAIBS(6).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g);
            level1 = nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS(3).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c) - nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS(5).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c);
            level3 = nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS(5).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c) - nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS(7).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c);
            level5 = nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS(7).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c); % - nuclearOrigins_compositeMaps.average_PaxAIBS(6).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g);

            barh([level5, level3 level1], 'stacked')
            hold on
            plot(nuclearOrigins_thalToClusters_compositeMaps(g).average_PaxAIBS_averageOfLevels357.coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c), 1:length(nuclearOrigins_thalToClusters_compositeMaps(g).nuclei), 'c-')

            title(['Average (3/5/7) nuclear coverage: Cluster ',num2str(c), ' of ', num2str(length(thalamusInj_specialGroups(g).cluster))]) 
            colormap(cmap_barLevels)
            set(gca, 'XLim', [0 1])
            set(gca, 'YTick', 1:length(nuclearOrigins_thalToClusters_compositeMaps(g).nuclei))
            set(gca, 'YTickLabel', nuclearOrigins_thalToClusters_compositeMaps(g).nuclei(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2)))
        %     set(gca, 'XTick', 1:3)
            legend({'7', '5', '3'});
            set(fig,'PaperPositionMode','auto')
            saveas(fig, [saveDir, 'nuclearCoverage/clusters_2015_06_21/nuclearCoverageLevels357_BAR_cluster',num2str(c), 'of', num2str(length(thalamusInj_specialGroups(g).cluster)), '.fig'], 'fig');
            print(fig, [saveDir, 'nuclearCoverage/clusters_2015_06_21/nuclearCoverageLevels357_BAR_cluster',num2str(c), 'of', num2str(length(thalamusInj_specialGroups(g).cluster)), '.eps'], '-depsc2');
            close(fig)

        end
    end



    save('nuclearOrigins_thalToClusters_compositeMaps_20150624.mat', 'nuclearOrigins_thalToClusters_compositeMaps', '-v7.3')
    save('nuclearOrigins_thalToClusters_20150624.mat', 'nuclearOrigins_thalToClusters', '-v7.3')
end


%% 12. Make these coverage plots (heat maps and bar graphs) for the the specialGroups2 (allo/meso/neo and convergence levels)

% ************************** NOT cleaned up yet ***************************

if figFlag == 12

    saveDir = ('/Users/jeaninehunnicutt/Desktop/ThalamostriatalData_processed/Thalamostriatal_testFigures/');

    % Load the thalamostriatal cluster input confidence maps
    load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/thalamusInj_specialGroups2.mat')
    load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/specialStriatalGroups2.mat')

    %to get the average thalamus & fatlas information
    load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/std thal w traced nuclei & final adj atlas_2014-03-06.mat')


    %Remove axon tracts and nuclei we're not using
    for p = 1:32
        atlasNucleusNames{p} = fatlas(p).name; 
    end
    nucleiToPlot = atlasNucleusNames(~ismember(atlasNucleusNames,{'fr', 'SPA', 'POL','LG','MH','LH', 'SPFp'}));


    % Get the coverage values for all confidence levels of each group for selected nuclei 
    for g = 1:length(thalamusInj_specialGroups2) % Loop through all cortical groups
        mkdir([saveDir, 'nuclearCoverage/specialGroups2/', num2str(length(specialStriatalGroups2{g})), 'clusters'])
        for c = 1:length(thalamusInj_specialGroups2(g).cluster)
            for p = 1:32
                 if sum(ismember(nucleiToPlot, fatlas(p).name)) > 0
                    ind = find(strcmp(nucleiToPlot, fatlas(p).name));
                    shortCmap = thalamusInj_specialGroups2(g).cluster(c).cmap(:, :, 1:64);
                    shortCoverage = coverage(:, :, 1:64);
                    for cl = 1:8
                        nuclearOrigins_thalToSpecialGroups2(g).cluster(c).nucleusNames{ind} = fatlas(p).name; 
                        nuclearOrigins_thalToSpecialGroups2(g).cluster(c).fractionOccupied_Pax(ind, cl) = sum(fatlas(p).n2fmask(:) & (shortCmap(:) >= cl))/sum(fatlas(p).n2fmask(:)&shortCoverage(:));  % I need this to be fraction of jucleus covered... 
                        nuclearOrigins_thalToSpecialGroups2(g).cluster(c).fractionOccupied_Pax_eroded(ind, cl) = sum(fatlas(p).smallmask110(:) & (shortCmap(:) >= cl))/sum(fatlas(p).smallmask110(:)&shortCoverage(:));
                    end
                 end
            end
            p = 1;
            for a = 33:64
                if sum(ismember(nucleiToPlot, fatlas(a).name)) > 0
                    ind = find(strcmp(nucleiToPlot, fatlas(a).name));
                    shortCmap = thalamusInj_specialGroups2(g).cluster(c).cmap(:, :, 1:65);
                    shortCoverage = coverage(:, :, 1:65);
                    for cl = 1:8
    %                   nuclearOrigins_thalToSpecialGroups2(g).cluster(c).nucleusNames{p} = fatlas(a).name; 
                        nuclearOrigins_thalToSpecialGroups2(g).cluster(c).fractionOccupied_AIBS(ind, cl) = sum(fatlas(a).n2fmask(:) & (shortCmap(:) >= cl))/sum(fatlas(a).n2fmask(:)&shortCoverage(:));
                        nuclearOrigins_thalToSpecialGroups2(g).cluster(c).fractionOccupied_AIBS_eroded(ind, cl) = sum(fatlas(a).smallmask110(:) & (shortCmap(:) >= cl))/sum(fatlas(a).smallmask110(:)&shortCoverage(:));
                    end
                    p = p+1;
                end
            end
        end
    end


    % Now make a composite map for the individual confidence levels (AIBS, Pax, and average)
    for g = 1:length(thalamusInj_specialGroups2) % Loop through all cortical groups
    %     mkdir([saveDir, 'nuclearCoverage/', num2str(length(specialStriatalGroups2{g})), 'clusters'])
        for c = 1:length(thalamusInj_specialGroups2(g).cluster)
           nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).nuclei = nuclearOrigins_thalCtxConvergence(g).nucleusNames;
                for cl = 1:8
                    nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).Pax(cl).coverage(:, c) = nuclearOrigins_thalToSpecialGroups2(g).cluster(c).fractionOccupied_Pax_eroded(:, cl); 
                    nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).AIBS(cl).coverage(:, c) = nuclearOrigins_thalToSpecialGroups2(g).cluster(c).fractionOccupied_AIBS_eroded(:, cl); 
                    nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS(cl).coverage(:, c) = mean([nuclearOrigins_thalToSpecialGroups2(g).cluster(c).fractionOccupied_AIBS_eroded(:, cl), nuclearOrigins_thalToSpecialGroups2(g).cluster(c).fractionOccupied_Pax_eroded(:, cl)], 2); 
                    nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).groups{c} = (['Cluster ', num2str(c)]); 
                end
            nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS_averageOfLevels147.coverage(:, c) = mean([nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS(1).coverage(:, c), nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS(4).coverage(:, c), nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS(7).coverage(:, c)], 2);

            % Update:6/21/15
            nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS_averageOfLevels257.coverage(:, c) = mean([nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS(2).coverage(:, c), nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS(5).coverage(:, c), nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS(7).coverage(:, c)], 2);
            nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS_averageOfLevels357.coverage(:, c) = mean([nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS(3).coverage(:, c), nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS(5).coverage(:, c), nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS(7).coverage(:, c)], 2);

            nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).nuclearGroupOrder = [1,2,3,6,7,14,15,18,19,11,8,21,13,4,5,12,16,22,23,24,25,9,10,20,17]; % for {'AD','AM','AV','CL','CM','IAD','IAM','IMD','LD','LP','MD','PCN','PR','PT','PVT','Pf','Po','RE','RH','RT_short','SMT','VAL','VM','VPL','VPM'}
        end
    end



    %I need to cluster these by common inputs ...nm
    for g = 1:length(thalamusInj_specialGroups2)
        % Average nucleus clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS_averageOfLevels147.coverage,'cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure;
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS_averageOfLevels147.nucleusOrder = optimleaf;
        close(fig)

        % Average group clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS_averageOfLevels147.coverage','cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure; 
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS_averageOfLevels147.groupOrder = optimleaf; 
        close(fig)
    end


    %look at the plots
    o = 1; %Use a constant cluster order. 
    g = 1; 
    for cl = 1:8
    %     fig = figure;
    %     set(fig, 'Position', [1563 533 352 573])
    %     imagesc(nuclearOrigins_compositeMaps.Pax(cl).coverage(nuclearOrigins_compositeMaps.average_PaxAIBS(o).nucleusOrder, nuclearOrigins_compositeMaps.average_PaxAIBS(o).groupOrder))
    %     title(['Pax nuclear coverage: level ', num2str(cl)])
    % %     axis image
    %     set(gca, 'YTick', 1:length(nuclearOrigins_compositeMaps.nuclei))
    %     set(gca, 'YTickLabel', nuclearOrigins_compositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS(o).nucleusOrder))
    %     set(gca, 'XTick', 1:length(nuclearOrigins_compositeMaps.groups))
    %     set(gca, 'XTickLabel', nuclearOrigins_compositeMaps.groups(nuclearOrigins_compositeMaps.average_PaxAIBS(o).groupOrder))
    %     
    %     fig = figure;
    %     set(fig, 'Position', [1563 533 352 573])
    %     imagesc(nuclearOrigins_compositeMaps.AIBS(cl).coverage(nuclearOrigins_compositeMaps.average_PaxAIBS(o).nucleusOrder, nuclearOrigins_compositeMaps.average_PaxAIBS(o).groupOrder))
    %     title(['AIBS nuclear coverage: level ', num2str(cl)])
    % %     axis image
    %     set(gca, 'YTick', 1:length(nuclearOrigins_compositeMaps.nuclei))
    %     set(gca, 'YTickLabel', nuclearOrigins_compositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS(o).nucleusOrder))
    %     set(gca, 'XTick', 1:length(nuclearOrigins_compositeMaps.groups))
    %     set(gca, 'XTickLabel', nuclearOrigins_compositeMaps.groups(nuclearOrigins_compositeMaps.average_PaxAIBS(o).groupOrder))
    %   
        % I am settled on the average being best
        fig = figure;
        set(fig, 'Position', [1563 533 352 573])
        imagesc(nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS(cl).coverage(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :))
        title(['Average nuclear coverage: ', num2str(length(thalamusInj_specialGroups2(g).cluster)), ' clusters'])
    %     axis image
    %     colormap(cmap)
        set(gca, 'YTick', 1:length(nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder))
        set(gca, 'XTick', 1:length(nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).groups))
        set(gca, 'XTickLabel', nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).groups(:))
    end

    % save images of the nuclear origins of cluster groups
    for g = 1:length(thalamusInj_specialGroups2)
        fig = figure;
        set(fig, 'Position', [1491 534 424 572])
        imagesc(nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS_averageOfLevels147.coverage(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :))
        title(['Average (1/4/7) nuclear coverage: ', num2str(length(thalamusInj_specialGroups2(g).cluster)), ' clusters'])
        %     axis image
    %     colormap(gray)
        colormap(cmap)
        set(gca, 'YTick', 1:length(nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder))
        set(gca, 'XTick', 1:length(nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).groups))
        set(gca, 'XTickLabel', nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).groups(:))
        axis image
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'specialGroups2/nuclearCoverage/nuclearCoverageLevels147_',num2str(length(thalamusInj_specialGroups2(g).cluster)), ' clusters.fig'], 'fig');
        print(fig, [saveDir, 'specialGroups2/nuclearCoverage/nuclearCoverageLevels147_',num2str(length(thalamusInj_specialGroups2(g).cluster)), ' clusters.eps'], '-depsc2');
        close(fig)
    end

    % Dont need for this (Images of the thalamocortical only, thalamostriatal only, and thalamic origin overlap)
    for g = 1:length(nuclearOrigins_compositeMaps.groups)
        %Just overlap white
        fig = figure;
        set(fig, 'Position', [1795 210 128 896])
        oneColumn = nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(g).coverage(:, 3);
        imagesc(oneColumn(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :))
        axis image
        title([nuclearOrigins_compositeMaps.groups(g), ': Overlap'])
        colormap(cmap_white)
        set(gca, 'YTick', 1:length(nuclearOrigins_compositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_compositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder))
        set(gca, 'XTick', 1)
        set(gca, 'XTickLabel', {'TCTSoverlap'});
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/specialGroups2/TS_TC_TSTCoverlap_Overlap_',nuclearOrigins_compositeMaps.groups{g}, '.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/specialGroups2/TS_TC_TSTCoverlap_Overlap_',nuclearOrigins_compositeMaps.groups{g}, '.eps'], '-depsc2');
        close(fig)

        %Just TS magenta
        fig = figure;
        set(fig, 'Position', [1795 210 128 896])
        oneColumn = nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(g).coverage(:, 2); 
        imagesc(oneColumn(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :))
        title([nuclearOrigins_compositeMaps.groups(g), ': Thalamostriatal'])
        axis image
        colormap(cmap_magenta)
        set(gca, 'YTick', 1:length(nuclearOrigins_compositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_compositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder))
        set(gca, 'XTick', 1)
        set(gca, 'XTickLabel', {'TS'});
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/specialGroups2/TS_TC_TSTCoverlap_TS_',nuclearOrigins_compositeMaps.groups{g}, '.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/specialGroups2/TS_TC_TSTCoverlap_TS_',nuclearOrigins_compositeMaps.groups{g}, '.eps'], '-depsc2');
        close(fig)

        %Just TC cyan
        fig = figure;
        set(fig, 'Position', [1795 210 128 896])
        oneColumn = nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(g).coverage(:, 1);
        imagesc(oneColumn(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :))
        title([nuclearOrigins_compositeMaps.groups(g), ': Thalamocortical'])
        axis image
        colormap(cmap_cyan)
        set(gca, 'YTick', 1:length(nuclearOrigins_compositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_compositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder))
        set(gca, 'XTick', 1)
        set(gca, 'XTickLabel', {'TC'});
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/specialGroups2/TS_TC_TSTCoverlap_TC_',nuclearOrigins_compositeMaps.groups{g}, '.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/specialGroups2/TS_TC_TSTCoverlap_TC_',nuclearOrigins_compositeMaps.groups{g}, '.eps'], '-depsc2');
        close(fig)

        %all 3 white
        fig = figure;
        set(fig, 'Position', [1753 210 167 896])
        imagesc(nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(g).coverage(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :))
        title([nuclearOrigins_compositeMaps.groups(g), ': thalamocortical, thalamostriatal, & dual projection origins: average nuclear coverage & Average of Levels 1/3/5'])
        axis image
        colormap(cmap)
        set(gca, 'YTick', 1:length(nuclearOrigins_compositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_compositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder))
        set(gca, 'XTick', 1:3)
        set(gca, 'XTickLabel', {'TC', 'TS', 'TCTSoverlap'});
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/specialGroups2/TS_TC_TSTCoverlap_all_',nuclearOrigins_compositeMaps.groups{g}, '.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/specialGroups2/TS_TC_TSTCoverlap_all_',nuclearOrigins_compositeMaps.groups{g}, '.eps'], '-depsc2');
        close(fig)
    end

    % now a horozontal stacked bar plot
    for g = 1:length(nuclearOrigins_thalToSpecialGroups2_compositeMaps)
        for c = 1:length(thalamusInj_specialGroups2(g).cluster)
            fig = figure;
            set(fig, 'Position', [1715 267 205 839])
        %     level0 = nuclearOrigins_compositeMaps.average_PaxAIBS(6).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g);
            level1 = nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS(1).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c) - nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS(4).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c);
            level3 = nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS(4).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c) - nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS(7).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c);
            level5 = nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS(7).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c); % - nuclearOrigins_compositeMaps.average_PaxAIBS(6).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g);

            barh([level5, level3 level1], 'stacked')
            hold on
            plot(nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS_averageOfLevels147.coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c), 1:length(nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).nuclei), 'c-')

            title(['Average (1/4/7) nuclear coverage: Cluster ',num2str(c), ' of ', num2str(length(thalamusInj_specialGroups2(g).cluster))]) 
            colormap(cmap_barLevels)
            set(gca, 'XLim', [0 1])
            set(gca, 'YTick', 1:length(nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).nuclei))
            set(gca, 'YTickLabel', nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).nuclei(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2)))
        %     set(gca, 'XTick', 1:3)
            legend({'7', '4', '1'});
            set(fig,'PaperPositionMode','auto')
            saveas(fig, [saveDir, 'specialGroups2/nuclearCoverage/nuclearCoverageLevels147_BAR_Group', num2str(g),'_cluster',num2str(c), '.fig'], 'fig');
            print(fig, [saveDir, 'specialGroups2/nuclearCoverage/nuclearCoverageLevels147_BAR_Group', num2str(g),'_cluster',num2str(c), '.eps'], '-depsc2');
            close(fig)
        end
    end

    % trying 2/5/7 & 3/5/7, 1/4/7 was too inclusive: for horozontal stacked bar plot
    for g = 1:length(nuclearOrigins_thalToSpecialGroups2_compositeMaps)
        for c = 1:length(thalamusInj_specialGroups2(g).cluster)

            fig = figure;
            set(fig, 'Position', [1715 267 205 839])
        %     level0 = nuclearOrigins_compositeMaps.average_PaxAIBS(6).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g);
            level1 = nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS(2).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c) - nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS(5).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c);
            level3 = nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS(5).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c) - nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS(7).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c);
            level5 = nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS(7).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c); % - nuclearOrigins_compositeMaps.average_PaxAIBS(6).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g);

            barh([level5, level3 level1], 'stacked')
            hold on
            plot(nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS_averageOfLevels257.coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c), 1:length(nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).nuclei), 'c-')

            title(['Average (2/5/7) nuclear coverage: Cluster ',num2str(c), ' of ', num2str(length(thalamusInj_specialGroups2(g).cluster))]) 
            colormap(cmap_barLevels)
            set(gca, 'XLim', [0 1])
            set(gca, 'YTick', 1:length(nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).nuclei))
            set(gca, 'YTickLabel', nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).nuclei(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2)))
        %     set(gca, 'XTick', 1:3)
            legend({'7', '5', '2'});
            set(fig,'PaperPositionMode','auto')
            saveas(fig, [saveDir, 'specialGroups2/nuclearCoverage/clusters_2015_06_21/nuclearCoverageLevels257_BAR_Group', num2str(g),'_cluster',num2str(c), '.fig'], 'fig');
            print(fig, [saveDir, 'specialGroups2/nuclearCoverage/clusters_2015_06_21/nuclearCoverageLevels257_BAR_Group', num2str(g),'_cluster',num2str(c), '.eps'], '-depsc2');
            close(fig)


            fig = figure;
            set(fig, 'Position', [1715 267 205 839])
        %     level0 = nuclearOrigins_compositeMaps.average_PaxAIBS(6).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g);
            level1 = nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS(3).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c) - nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS(5).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c);
            level3 = nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS(5).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c) - nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS(7).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c);
            level5 = nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS(7).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c); % - nuclearOrigins_compositeMaps.average_PaxAIBS(6).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g);

            barh([level5, level3 level1], 'stacked')
            hold on
            plot(nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).average_PaxAIBS_averageOfLevels357.coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), c), 1:length(nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).nuclei), 'c-')

            title(['Average (3/5/7) nuclear coverage: Cluster ',num2str(c), ' of ', num2str(length(thalamusInj_specialGroups2(g).cluster))]) 
            colormap(cmap_barLevels)
            set(gca, 'XLim', [0 1])
            set(gca, 'YTick', 1:length(nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).nuclei))
            set(gca, 'YTickLabel', nuclearOrigins_thalToSpecialGroups2_compositeMaps(g).nuclei(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2)))
        %     set(gca, 'XTick', 1:3)
            legend({'7', '5', '3'});
            set(fig,'PaperPositionMode','auto')
            saveas(fig, [saveDir, 'specialGroups2/nuclearCoverage/clusters_2015_06_21/nuclearCoverageLevels357_BAR_Group', num2str(g),'_cluster',num2str(c), '.fig'], 'fig');
            print(fig, [saveDir, 'specialGroups2/nuclearCoverage/clusters_2015_06_21/nuclearCoverageLevels357_BAR_Group', num2str(g),'_cluster',num2str(c), '.eps'], '-depsc2');
            close(fig)

        end
    end
end

%% 13. Create a comparison SLICE IMAGE of the thalamic origin of convergence with corticostriatal data and the thalamocortical origins For CLUSTERS (FIGURE)

if figFlag == 13
    saveDir = ([anaDir, '/ThalamostriatalData_processed/Thalamostriatal_testFigures/new_clusters']);

    %Load the thalamocortical confidence map data:   confidenceMap is a <1x25 cell> with int8 matrices of the final confidence maps & targerRegions with is a <25x1 cell with the region names
    targetRegions = {'AI';'Amyg';'Aud';'FRA';'IL';'Ins';'LO';'M1';'M2';'MO';'NAc';'Piri';'PrL';'Pt';'RS';'Rhi';'Sens';'Str';'Tem';'VO';'Vis';'dACC';'eDM';'vACC';'vM1'}; 
    load([randomMasksDir, '/confidenceMap_2014-03-06.mat']); % was : '/Users/jeaninehunnicutt/Desktop/Mao Lab/Matlab /Anatomy_Analysis/relevant data/confidenceMap_2014-03-06.mat'

    %Load the thalamostriatal convergence origin maps
    corticalGroup = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'SS', 'Vis', 'SUB_HIPP', 'Amyg', 'SNr', 'na'};
    load([anaDir, '/thalCtx_StriatalConvergenceOrigins.mat']);

%     % Set the correspondance between those 2 datasets
%     for i = 1:length(corticalGroup)
%         corticalGroupNames(i).thalamostriatalName = corticalGroup(i);
%     end
%     corticalGroupNames(1).corticostriatalHomologue = {'vACC', 'dACC'};
%     corticalGroupNames(2).corticostriatalHomologue = {'AI', 'Ins'};
%     corticalGroupNames(3).corticostriatalHomologue = {'Aud'};
%     corticalGroupNames(4).corticostriatalHomologue = {'Rhi', 'Tem'};
%     corticalGroupNames(5).corticostriatalHomologue = {'FRA'};
%     corticalGroupNames(6).corticostriatalHomologue = {'IL'};
%     corticalGroupNames(7).corticostriatalHomologue = {'M1', 'M2'};
%     corticalGroupNames(8).corticostriatalHomologue = {'LO', 'VO'};
%     corticalGroupNames(9).corticostriatalHomologue = {'MO', 'PrL'};
%     corticalGroupNames(10).corticostriatalHomologue = {'Pt'};
%     corticalGroupNames(11).corticostriatalHomologue = {'RS'};
%     corticalGroupNames(18).corticostriatalHomologue = {'Sens'};
%     corticalGroupNames(19).corticostriatalHomologue = {'Vis'};
%     corticalGroupNames(21).corticostriatalHomologue = {'Amyg'};
% 
%     % Add together some confidence maps that were grouped areas in the corticostratal data.. 
%     projAreas_withThalamocorticalMaps = corticalGroup(~ismember(corticalGroup,{'SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'na', 'SNr',  'SUB_HIPP'}));
%     for g = 1:length(corticalGroupNames)
%         if sum(ismember(projAreas_withThalamocorticalMaps, injGroup_data(g).cortical_group)) > 0
%             ind = find(ismember(targetRegions, corticalGroupNames(g).corticostriatalHomologue) == 1); % Find the maps to sum
%             if length(ind) == 1
%                 thalCtx_StriatalConvergenceOrigins(g).correspondingThalamoCorticalConfidenceMap = confidenceMap{ind};
%             elseif length(ind) == 2
%                 thalCtx_StriatalConvergenceOrigins(g).correspondingThalamoCorticalConfidenceMap = bsxfun(@max, confidenceMap{ind(1)}, confidenceMap{ind(2)});
%             end
% 
%         end
%     end
% 
%     % Add in the names to the variable 
%     for g = 1:length(corticalGroupNames)
%         if sum(ismember(projAreas_withThalamocorticalMaps, injGroup_data(g).cortical_group)) > 0
%             thalCtx_StriatalConvergenceOrigins(g).thalamostriatalGroup = injGroup_data(g).cortical_group;
%             thalCtx_StriatalConvergenceOrigins(g).thalamocorticalHomologue = corticalGroupNames(g).corticostriatalHomologue;
%         end
%     end         

    thalCtx_ClusterConvergenceOrigins(1).domainHomolog = {'ventral'};
    thalCtx_ClusterConvergenceOrigins(2).domainHomolog = {'posterior'};
    thalCtx_ClusterConvergenceOrigins(3).domainHomolog = {'dorsolateral'};
    thalCtx_ClusterConvergenceOrigins(4).domainHomolog = {'dorsomedial'};
    
    thalCtx_ClusterConvergenceOrigins(1).primaryCtxConvergence = {'AI_GU_VISC', 'IL', 'PL_MO', 'SUB_HIPP'};
    thalCtx_ClusterConvergenceOrigins(2).primaryCtxConvergence = {'AUD', 'ECT_PERI_TE', 'Vis'};
    thalCtx_ClusterConvergenceOrigins(3).primaryCtxConvergence = {'AI_GU_VISC', 'FRA', 'MOp', 'SS'};
    thalCtx_ClusterConvergenceOrigins(4).primaryCtxConvergence = {'ACA', 'ORBl', 'PL_MO', 'PTL', 'RSP', 'Vis'};
    
    % Get the confidence maps for all cortical groups that primarily target each cluster 
    projAreas_withThalamocorticalMaps = corticalGroup(~ismember(corticalGroup,{'SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'na', 'SNr',  'SUB_HIPP'}));
    for g = 1:length(thalCtx_StriatalConvergenceOrigins)
        temp_masks(g).TSmask = thalCtx_StriatalConvergenceOrigins(g).mask;
        temp_masks(g).TCmask = thalCtx_StriatalConvergenceOrigins(g).correspondingThalamoCorticalConfidenceMap;
        temp_masks(g).subregion = thalCtx_StriatalConvergenceOrigins(g).thalamostriatalGroup;
    end
        
    % TS: Add together the confidence maps for all cortical groups that primarily target each cluster
        % Cluster 1
        thalCtx_ClusterConvergenceOrigins(1).mask = bsxfun(@max, temp_masks(2).TSmask, temp_masks(6).TSmask); % no Sub TC mask...
            thalCtx_ClusterConvergenceOrigins(1).mask = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(1).mask, temp_masks(9).TSmask); % This is stupid (can only do 2 at a time) but it's not worth finding a better way for this one little thing
        % Cluster 2
        thalCtx_ClusterConvergenceOrigins(2).mask = bsxfun(@max, temp_masks(3).TSmask, temp_masks(4).TSmask);
            thalCtx_ClusterConvergenceOrigins(2).mask = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(2).mask, temp_masks(19).TSmask);
        % Cluster 3
        thalCtx_ClusterConvergenceOrigins(3).mask = bsxfun(@max, temp_masks(2).TSmask, temp_masks(5).TSmask); 
            thalCtx_ClusterConvergenceOrigins(3).mask = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(3).mask, temp_masks(7).TSmask); 
                thalCtx_ClusterConvergenceOrigins(3).mask = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(3).mask, temp_masks(18).TSmask); 
        % Cluster 4
        thalCtx_ClusterConvergenceOrigins(4).mask = bsxfun(@max, temp_masks(1).TSmask, temp_masks(8).TSmask); 
            thalCtx_ClusterConvergenceOrigins(4).mask = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(4).mask, temp_masks(9).TSmask); 
                thalCtx_ClusterConvergenceOrigins(4).mask = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(4).mask, temp_masks(10).TSmask); 
                    thalCtx_ClusterConvergenceOrigins(4).mask = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(4).mask, temp_masks(11).TSmask); 
                        thalCtx_ClusterConvergenceOrigins(4).mask = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(4).mask, temp_masks(19).TSmask); 
       % TS: Same as above, but With Amygdala... 
            % Cluster 1
        thalCtx_ClusterConvergenceOrigins(1).mask_withAmyg = bsxfun(@max, temp_masks(2).TSmask, temp_masks(6).TSmask); % no Sub TC mask...
            thalCtx_ClusterConvergenceOrigins(1).mask_withAmyg = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(1).mask_withAmyg, temp_masks(9).TSmask); % This is stupid (can only do 2 at a time) but it's not worth finding a better way for this one little thing
                thalCtx_ClusterConvergenceOrigins(1).mask_withAmyg = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(1).mask_withAmyg, temp_masks(21).TSmask);
        % Cluster 2
        thalCtx_ClusterConvergenceOrigins(2).mask_withAmyg = bsxfun(@max, temp_masks(3).TSmask, temp_masks(4).TSmask);
            thalCtx_ClusterConvergenceOrigins(2).mask_withAmyg = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(2).mask_withAmyg, temp_masks(19).TSmask);
                thalCtx_ClusterConvergenceOrigins(2).mask_withAmyg = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(2).mask_withAmyg, temp_masks(21).TSmask);
        % Cluster 3
        thalCtx_ClusterConvergenceOrigins(3).mask_withAmyg = bsxfun(@max, temp_masks(2).TSmask, temp_masks(5).TSmask); 
            thalCtx_ClusterConvergenceOrigins(3).mask_withAmyg = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(3).mask_withAmyg, temp_masks(7).TSmask); 
                thalCtx_ClusterConvergenceOrigins(3).mask_withAmyg = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(3).mask_withAmyg, temp_masks(18).TSmask);  
                    thalCtx_ClusterConvergenceOrigins(3).mask_withAmyg = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(3).mask_withAmyg, temp_masks(21).TSmask);
        % Cluster 4
        thalCtx_ClusterConvergenceOrigins(4).mask_withAmyg = bsxfun(@max, temp_masks(1).TSmask, temp_masks(8).TSmask); 
            thalCtx_ClusterConvergenceOrigins(4).mask_withAmyg = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(4).mask_withAmyg, temp_masks(9).TSmask); 
                thalCtx_ClusterConvergenceOrigins(4).mask_withAmyg = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(4).mask_withAmyg, temp_masks(10).TSmask); 
                    thalCtx_ClusterConvergenceOrigins(4).mask_withAmyg = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(4).mask_withAmyg, temp_masks(11).TSmask); 
                        thalCtx_ClusterConvergenceOrigins(4).mask_withAmyg = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(4).mask_withAmyg, temp_masks(19).TSmask); 
                            thalCtx_ClusterConvergenceOrigins(4).mask_withAmyg = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(4).mask_withAmyg, temp_masks(21).TSmask); 
    
    
    % TC: Add together the confidence maps for all cortical groups that primarily target each cluster
        % Cluster 1
        thalCtx_ClusterConvergenceOrigins(1).correspondingThalamoCorticalConfidenceMap = bsxfun(@max, temp_masks(2).TCmask, temp_masks(6).TCmask); % no Sub TC mask...
            thalCtx_ClusterConvergenceOrigins(1).correspondingThalamoCorticalConfidenceMap = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(1).correspondingThalamoCorticalConfidenceMap, temp_masks(9).TCmask); % This is stupid (can only do 2 at a time) but it's not worth finding a better way for this one little thing
        % Cluster 2
        thalCtx_ClusterConvergenceOrigins(2).correspondingThalamoCorticalConfidenceMap = bsxfun(@max, temp_masks(3).TCmask, temp_masks(4).TCmask);
            thalCtx_ClusterConvergenceOrigins(2).correspondingThalamoCorticalConfidenceMap = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(2).correspondingThalamoCorticalConfidenceMap, temp_masks(19).TCmask);
        % Cluster 3
        thalCtx_ClusterConvergenceOrigins(3).correspondingThalamoCorticalConfidenceMap = bsxfun(@max, temp_masks(2).TCmask, temp_masks(5).TCmask); 
            thalCtx_ClusterConvergenceOrigins(3).correspondingThalamoCorticalConfidenceMap = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(3).correspondingThalamoCorticalConfidenceMap, temp_masks(7).TCmask); 
                thalCtx_ClusterConvergenceOrigins(3).correspondingThalamoCorticalConfidenceMap = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(3).correspondingThalamoCorticalConfidenceMap, temp_masks(18).TCmask); 
        % Cluster 4
        thalCtx_ClusterConvergenceOrigins(4).correspondingThalamoCorticalConfidenceMap = bsxfun(@max, temp_masks(1).TCmask, temp_masks(8).TCmask); 
            thalCtx_ClusterConvergenceOrigins(4).correspondingThalamoCorticalConfidenceMap = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(4).correspondingThalamoCorticalConfidenceMap, temp_masks(9).TCmask); 
                thalCtx_ClusterConvergenceOrigins(4).correspondingThalamoCorticalConfidenceMap = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(4).correspondingThalamoCorticalConfidenceMap, temp_masks(10).TCmask); 
                    thalCtx_ClusterConvergenceOrigins(4).correspondingThalamoCorticalConfidenceMap = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(4).correspondingThalamoCorticalConfidenceMap, temp_masks(11).TCmask); 
                        thalCtx_ClusterConvergenceOrigins(4).correspondingThalamoCorticalConfidenceMap = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(4).correspondingThalamoCorticalConfidenceMap, temp_masks(19).TCmask); 
       % TC: Same as above, but With Amygdala... 
            % Cluster 1
        thalCtx_ClusterConvergenceOrigins(1).correspondingThalamoCorticalConfidenceMap_withAmyg = bsxfun(@max, temp_masks(2).TCmask, temp_masks(6).TCmask); % no Sub TC mask...
            thalCtx_ClusterConvergenceOrigins(1).correspondingThalamoCorticalConfidenceMap_withAmyg = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(1).correspondingThalamoCorticalConfidenceMap_withAmyg, temp_masks(9).TCmask); % This is stupid (can only do 2 at a time) but it's not worth finding a better way for this one little thing
                thalCtx_ClusterConvergenceOrigins(1).correspondingThalamoCorticalConfidenceMap_withAmyg = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(1).correspondingThalamoCorticalConfidenceMap_withAmyg, temp_masks(21).TCmask);
        % Cluster 2
        thalCtx_ClusterConvergenceOrigins(2).correspondingThalamoCorticalConfidenceMap_withAmyg = bsxfun(@max, temp_masks(3).TCmask, temp_masks(4).TCmask);
            thalCtx_ClusterConvergenceOrigins(2).correspondingThalamoCorticalConfidenceMap_withAmyg = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(2).correspondingThalamoCorticalConfidenceMap_withAmyg, temp_masks(19).TCmask);
                thalCtx_ClusterConvergenceOrigins(2).correspondingThalamoCorticalConfidenceMap_withAmyg = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(2).correspondingThalamoCorticalConfidenceMap_withAmyg, temp_masks(21).TCmask);
        % Cluster 3
        thalCtx_ClusterConvergenceOrigins(3).correspondingThalamoCorticalConfidenceMap_withAmyg = bsxfun(@max, temp_masks(2).TCmask, temp_masks(5).TCmask); 
            thalCtx_ClusterConvergenceOrigins(3).correspondingThalamoCorticalConfidenceMap_withAmyg = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(3).correspondingThalamoCorticalConfidenceMap_withAmyg, temp_masks(7).TCmask); 
                thalCtx_ClusterConvergenceOrigins(3).correspondingThalamoCorticalConfidenceMap_withAmyg = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(3).correspondingThalamoCorticalConfidenceMap_withAmyg, temp_masks(18).TCmask);  
                    thalCtx_ClusterConvergenceOrigins(3).correspondingThalamoCorticalConfidenceMap_withAmyg = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(3).correspondingThalamoCorticalConfidenceMap_withAmyg, temp_masks(21).TCmask);
        % Cluster 4
        thalCtx_ClusterConvergenceOrigins(4).correspondingThalamoCorticalConfidenceMap_withAmyg = bsxfun(@max, temp_masks(1).TCmask, temp_masks(8).TCmask); 
            thalCtx_ClusterConvergenceOrigins(4).correspondingThalamoCorticalConfidenceMap_withAmyg = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(4).correspondingThalamoCorticalConfidenceMap_withAmyg, temp_masks(9).TCmask); 
                thalCtx_ClusterConvergenceOrigins(4).correspondingThalamoCorticalConfidenceMap_withAmyg = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(4).correspondingThalamoCorticalConfidenceMap_withAmyg, temp_masks(10).TCmask); 
                    thalCtx_ClusterConvergenceOrigins(4).correspondingThalamoCorticalConfidenceMap_withAmyg = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(4).correspondingThalamoCorticalConfidenceMap_withAmyg, temp_masks(11).TCmask); 
                        thalCtx_ClusterConvergenceOrigins(4).correspondingThalamoCorticalConfidenceMap_withAmyg = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(4).correspondingThalamoCorticalConfidenceMap_withAmyg, temp_masks(19).TCmask); 
                            thalCtx_ClusterConvergenceOrigins(4).correspondingThalamoCorticalConfidenceMap_withAmyg = bsxfun(@max, thalCtx_ClusterConvergenceOrigins(4).correspondingThalamoCorticalConfidenceMap_withAmyg, temp_masks(21).TCmask); 
    
    
    
    % Make the composite images and save them
    for g = 1:4 % Loop through the 4 clusters       %length(corticalGroupNames) % Loop through all cortical groups
        mkdir([saveDir, '/thalamo_corticostriatalOriginOverlap/', num2str(g)]) %for thal images
        mkdir([saveDir, '/thalamo_corticostriatalOriginOverlap/', num2str(g), '/backupConvergenceMask'])
        % Making arrays condusive to turning into rgb images
        ThalStrMap = thalCtx_ClusterConvergenceOrigins(g).mask(:, :, 1:65)./max(thalCtx_ClusterConvergenceOrigins(g).mask(:));  %normalizing them all to a max of 1
        thalCtxMap = double(thalCtx_ClusterConvergenceOrigins(g).correspondingThalamoCorticalConfidenceMap)./double(max(thalCtx_ClusterConvergenceOrigins(g).correspondingThalamoCorticalConfidenceMap(:))); 
        TCTS_convergence = ThalStrMap & thalCtxMap; 
        bothMap = thalCtxMap | ThalStrMap; 
        TC_only = thalCtxMap &~ThalStrMap; 
        TS_only = ThalStrMap &~ thalCtxMap; 

        for k = 1:size(TCTS_convergence, 3)
            % #WINNER I think, or at least it's the best I can figure out to look at convergence, i need to sleep -I can fill in the convergence outline in illustrator if needed
            rgb_test(:, :, 1) = ThalStrMap(:, :, k)*256.*(betteraveragethalamus(:, :, k)); % Also limiting the image to the size of the model striatum
            rgb_test(:, :, 2) = thalCtxMap(:, :, k)*256.*(betteraveragethalamus(:, :, k)); 
            rgb_test(:, :, 3) = ThalStrMap(:, :, k)*256+thalCtxMap(:, :, k)*256.*(betteraveragethalamus(:, :, k)); %Makes them cyan and magenta
            rgb_test = uint8(rgb_test);

            fig = figure; 
            set(fig, 'Position', [1570 790 350 250])

            imshow(rgb_test);
            hold on
            outline = h_getNucleusOutline(TCTS_convergence(:, :, k));
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1)), 'c-', 'linewidth',1);
            end
            outline = h_getNucleusOutline(betteraveragethalamus(:, :, k));
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1)), 'r-', 'linewidth',1.2);
            end

            if saveFlag == 1
                saveas(fig, [saveDir, '/thalamo_corticostriatalOriginOverlap/', num2str(g), '/thalCtxOriginOverlap_', num2str(g), '_section', num2str(k), '.fig'], 'fig');
                print(fig, [saveDir, '/thalamo_corticostriatalOriginOverlap/', num2str(g), '/thalCtxOriginOverlap_', num2str(g), '_section', num2str(k), '.eps'], '-depsc2');
            end
            close(fig)

            % Sometimes the outline thing fails when there are lots of  little bits so I'm saving that mask too to fix errors... 
            fig2 = figure; 
            set(fig2, 'Position', [1570 790 350 250])
            imshow(TCTS_convergence(:, :, k));

            if saveFlag == 1
                saveas(fig2, [saveDir, '/thalamo_corticostriatalOriginOverlap/', num2str(g), '/backupConvergenceMask/maskOnly_thalCtxOriginOverlap_', num2str(g), '_section', num2str(k), '.fig'], 'fig');
                print(fig2, [saveDir, '/thalamo_corticostriatalOriginOverlap/', num2str(g), '/backupConvergenceMask/maskOnly_thalCtxOriginOverlap_', num2str(g), '_section', num2str(k), '.eps'], '-depsc2');
            end
            close(fig2)


            
        end
    end
   

    %TESTIGN FIGURES
    figure, imagesc(squeeze(sum(thalCtxMap, 1)))
    title('Thalamocortical Confidence Map: AI')
    figure, imagesc(squeeze(sum(ThalStrMap, 1)))
    title('Thalamostriatal convergence Map: AI')
    figure, imagesc(squeeze(sum(TCTS_convergence, 1)))
    title('Thalamostriatal-Thalamocotrical Origin Convergence Map: AI')

    figure, imshow(thalCtxMap(:, :, 17), 'InitialMagnification', 500)
    caxis('auto')
    title('Thalamocortical Confidence Map: AI')
    figure, imshow(ThalStrMap(:, :, 17), 'InitialMagnification', 500)
    caxis('auto')
    title('Thalamostriatal convergence Map: AI')
    figure, imshow(TCTS_convergence(:, :, 17), 'InitialMagnification', 500)
    caxis('auto')
    title('Thalamostriatal-Thalamocotrical Origin Convergence Map: AI')

    %this one is terrible, but gets the point across
    rgb_test2 = [];
    rgb_test2(:, :, 1) = uint8(TC_only(:, :, 17)).*256; 
    rgb_test2(:, :, 2) = uint8(TS_only(:, :, 17)).*256; 
    rgb_test2(:, :, 3) = uint8(TCTS_convergence(:, :, 17)).*256; 
    figure, imshow(rgb_test2)

    % this one isn't bad but the thalamocortical confidence map is a mess without gradataion
    rgb_test2 = [];
    rgb_test2(:, :, 1) = uint8(ThalStrMap(:, :, 17)>0).*256; 
    rgb_test2(:, :, 2) = uint8(thalCtxMap(:, :, 17)>0).*256; 
    rgb_test2(:, :, 3) = uint8(bothMap(:, :, 17)>0).*256; 
    figure, imshow(rgb_test2)
    
    if saveFlag == 1
        cd(anaDir); 
        save('thalCtx_ClusterConvergenceOrigins.mat', 'thalCtx_ClusterConvergenceOrigins', '-v7.3') % because this was updated in here too
    end
end


%% 14. Create the nuclear overlap data for CLUSTERS and make the nucleus localized T-S overview figure.  (FIGURE)

if figFlag == 14
    
    saveDir = ([anaDir, '/ThalamostriatalData_processed/Thalamostriatal_testFigures/new_clusters']);

        
    disp('Where are the collected masks?')
    randomMasksDir = uigetdir;
    
    
    load([randomMasksDir, '/std thal w traced nuclei & final adj atlas_2014-03-06.mat']) %Loading the injection site thalamus data from the thalamocortical paper

    %Load the raw thalamostriatal data and the average brain
    load([anaDir, '/inj_thalData.mat']) %Loading the thalamostriatal data from above
    load([randomMasksDir, '/AIBS_100um.mat'])
    ic_submask = AIBS_100um.striatum.ic_submask; % I'll need to apply this to the thalamus data

    %Load the confidence maps of the thalamic origins of thalamostriatal inputs that converge with corticostriatal inputs, also has the corresponding thalamocortical confidence map
    %   *the individual confidence levels before they are summed are in thalamusInj_group_Level10.mat
    load([anaDir, '/thalCtx_ClusterConvergenceOrigins.mat'])

    % Load the thalamostriatal cluster input confidence maps
    load([anaDir, '/thalamusInj_specialGroups.mat'])

    %Load the red-white-blue colormap
    load([randomMasksDir, '/color_maps/cmap_blue0_white25_red1.mat'])
    
    %Load the thalamus coverage mask
    load([randomMasksDir, '/coverageByFullInjections.mat'])
    coverage = logical(sumcoverage);


    %Remove axon tracts and nuclei we're not using
    for p = 1:32
        atlasNucleusNames{p} = fatlas(p).name; 
    end
    nucleiToPlot = atlasNucleusNames(~ismember(atlasNucleusNames,{'fr', 'SPA', 'POL','LG','MH','LH', 'SPFp'}));

    % Remove arreas without their own thalamocortical maps
    projAreas_withThalamocorticalMaps = corticalGroup(~ismember(corticalGroup,{'SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'na', 'SNr', 'SUB_HIPP'}));  % I manually added in sub to get the nucleus coverage then removed again. 
    shortCoverage = coverage(:, :, 64);

    % Get the coverage values for all confidence levels of each group for selected nuclei 
    for g = 1:length(thalCtx_ClusterConvergenceOrigins)
%         if sum(ismember(projAreas_withThalamocorticalMaps, injGroup_data(g).cortical_group)) > 0
            for p = 1:32
                 if sum(ismember(nucleiToPlot, fatlas(p).name)) > 0
                    ind = find(strcmp(nucleiToPlot, fatlas(p).name));
                    shortCmap = thalCtx_ClusterConvergenceOrigins(g).mask(:, :, 1:64);
                    shortCoverage = coverage(:, :, 1:64);
                    for cl = 1:6
                        nuclearOrigins_clusterThalCtxConvergence(g).nucleusNames{ind} = fatlas(p).name; 
                        nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax(ind, cl) = sum(fatlas(p).n2fmask(:) & (shortCmap(:) >= cl))/sum(fatlas(p).n2fmask(:)&shortCoverage(:));  % I need this to be fraction of jucleus covered... 
                        nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_eroded(ind, cl) = sum(fatlas(p).smallmask110(:) & (shortCmap(:) >= cl))/sum(fatlas(p).smallmask110(:)&shortCoverage(:));
                    end
                 end
            end
            p = 1;
            for a = 33:64
                if sum(ismember(nucleiToPlot, fatlas(a).name)) > 0
                    ind = find(strcmp(nucleiToPlot, fatlas(a).name));
                    shortCmap = thalCtx_ClusterConvergenceOrigins(g).mask(:, :, 1:65);
                    shortCoverage = coverage(:, :, 1:65);
                    for cl = 1:6
        %                 nuclearOrigins_clusterThalCtxConvergence(g).nucleusNames{p} = fatlas(a).name; 
                        nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS(ind, cl) = sum(fatlas(a).n2fmask(:) & (shortCmap(:) >= cl))/sum(fatlas(a).n2fmask(:)&shortCoverage(:));
                        nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_eroded(ind, cl) = sum(fatlas(a).smallmask110(:) & (shortCmap(:) >= cl))/sum(fatlas(a).smallmask110(:)&shortCoverage(:));
                    end
                    p = p+1;
                end
            end
%         end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Left off here 10-4-16
    % Now make a composite map for the individual confidence levels (AIBS, Pax, and average)
    gg = 1; 
    for g = 1:length(thalCtx_ClusterConvergenceOrigins)
%         if sum(ismember(projAreas_withThalamocorticalMaps, injGroup_data(g).cortical_group)) > 0
           nuclearOrigins_clusterCompositeMaps.nuclei = nuclearOrigins_clusterThalCtxConvergence(g).nucleusNames;
    %         for p = 1:32
                for cl = 1:6
                    nuclearOrigins_clusterCompositeMaps.Pax(cl).coverage(:, gg) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_eroded(:, cl); 
                    nuclearOrigins_clusterCompositeMaps.AIBS(cl).coverage(:, gg) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_eroded(:, cl); 
                    nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(cl).coverage(:, gg) = mean([nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_eroded(:, cl), nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_eroded(:, cl)], 2); 
                    nuclearOrigins_clusterCompositeMaps.groups{gg} = thalCtx_ClusterConvergenceOrigins(g).domainHomolog{1};  % ConvergenceOrigins(g).thalamostriatalGroup
                end
    %         end
            nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_averageOfLevels135.coverage(:, gg) = mean([nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(1).coverage(:, gg), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(3).coverage(:, gg), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(5).coverage(:, gg)], 2);
            nuclearOrigins_clusterCompositeMaps.nuclearGroupOrder = [1,2,3,6,7,14,15,18,19,11,8,21,13,4,5,12,16,22,23,24,25,9,10,20,17]; % for {'AD','AM','AV','CL','CM','IAD','IAM','IMD','LD','LP','MD','PCN','PR','PT','PVT','Pf','Po','RE','RH','RT_short','SMT','VAL','VM','VPL','VPM'}

            gg = gg+1;
%         end
    end



    %I need to cluster these by common inputs
    for cl = 1:6
        % Pax nucleus clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_clusterCompositeMaps.Pax(cl).coverage,'cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure;
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_clusterCompositeMaps.Pax(cl).nucleusOrder = optimleaf;
        close(fig)

        % Pax group clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_clusterCompositeMaps.Pax(cl).coverage','cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure; 
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_clusterCompositeMaps.Pax(cl).groupOrder = optimleaf; 
        close(fig)

        % AIBS nucleus clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_clusterCompositeMaps.AIBS(cl).coverage,'cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure;
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_clusterCompositeMaps.AIBS(cl).nucleusOrder = optimleaf;
        close(fig)

        % AIBS group clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_clusterCompositeMaps.AIBS(cl).coverage','cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure; 
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_clusterCompositeMaps.AIBS(cl).groupOrder = optimleaf; 
        close(fig)

        % Average nucleus clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(cl).coverage,'cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure;
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(cl).nucleusOrder = optimleaf;
        close(fig)

        % Average group clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(cl).coverage','cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure; 
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(cl).groupOrder = optimleaf; 
        close(fig)

        % Average nucleus clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_averageOfLevels135.coverage,'cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure;
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder = optimleaf;
        close(fig)

        % Average group clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_averageOfLevels135.coverage','cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure; 
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_averageOfLevels135.groupOrder = optimleaf; 
        close(fig)
    end



    %look at the plots
    o = 1; %Use a constant cluster order. 
    for cl = 1:6
    %     fig = figure;
    %     set(fig, 'Position', [1563 533 352 573])
    %     imagesc(nuclearOrigins_clusterCompositeMaps.Pax(cl).coverage(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(o).nucleusOrder, nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(o).groupOrder))
    %     title(['Pax nuclear coverage: level ', num2str(cl)])
    % %     axis image
    %     set(gca, 'YTick', 1:length(nuclearOrigins_clusterCompositeMaps.nuclei))
    %     set(gca, 'YTickLabel', nuclearOrigins_clusterCompositeMaps.nuclei(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(o).nucleusOrder))
    %     set(gca, 'XTick', 1:length(nuclearOrigins_clusterCompositeMaps.groups))
    %     set(gca, 'XTickLabel', nuclearOrigins_clusterCompositeMaps.groups(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(o).groupOrder))
    %     
    %     fig = figure;
    %     set(fig, 'Position', [1563 533 352 573])
    %     imagesc(nuclearOrigins_clusterCompositeMaps.AIBS(cl).coverage(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(o).nucleusOrder, nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(o).groupOrder))
    %     title(['AIBS nuclear coverage: level ', num2str(cl)])
    % %     axis image
    %     set(gca, 'YTick', 1:length(nuclearOrigins_clusterCompositeMaps.nuclei))
    %     set(gca, 'YTickLabel', nuclearOrigins_clusterCompositeMaps.nuclei(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(o).nucleusOrder))
    %     set(gca, 'XTick', 1:length(nuclearOrigins_clusterCompositeMaps.groups))
    %     set(gca, 'XTickLabel', nuclearOrigins_clusterCompositeMaps.groups(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(o).groupOrder))
    %   
        % I am settled on the average being best
        fig = figure;
        set(fig, 'Position', [1563 533 352 573])
        imagesc(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(cl).coverage(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(o).nucleusOrder, nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(o).groupOrder))
        title(['Average nuclear coverage: level ', num2str(cl)])
    %     axis image
        set(gca, 'YTick', 1:length(nuclearOrigins_clusterCompositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_clusterCompositeMaps.nuclei(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(o).nucleusOrder))
        set(gca, 'XTick', 1:length(nuclearOrigins_clusterCompositeMaps.groups))
        set(gca, 'XTickLabel', nuclearOrigins_clusterCompositeMaps.groups(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(o).groupOrder))

    end

    
    %look at just average average  ***I like this one better than nuclear group one (FIGURE)
    fig = figure;
    set(fig, 'Position', [1563 533 352 573])
    imagesc(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_averageOfLevels135.coverage(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_averageOfLevels135.groupOrder))  %Using the .nucleusOrder from the subregion clustering for figure consistency 10/4/16
    title(['Average nuclear coverage & Average of Levels 1/3/5'])
    colormap(cmap)
    set(gca, 'YTick', 1:length(nuclearOrigins_compositeMaps.nuclei))  % Using the .nucleusOrder from the subregion clustering for figure consistency 10/4/16
    set(gca, 'YTickLabel', nuclearOrigins_compositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder))  % Using the .nucleusOrder from the subregion clustering for figure consistency 10/4/16
    set(gca, 'XTick', 1:length(nuclearOrigins_clusterCompositeMaps.groups))
    set(gca, 'XTickLabel', nuclearOrigins_clusterCompositeMaps.groups(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_averageOfLevels135.groupOrder))

    % saveDir = ('/Users/jeaninehunnicutt/Desktop/ThalamostriatalData_processed/Thalamostriatal_testFigures');
    % mkDir = ('/Users/jeaninehunnicutt/Desktop/ThalamostriatalData_processed/Thalamostriatal_testFigures/nuclearCoverage/');
%     cd('/Users/jeaninehunnicutt/Desktop/ThalamostriatalData_processed/Thalamostriatal_testFigures/nuclearCoverage');
    
    saveas(fig, [saveDir, 'thalamocorticalConvergence_bySubregion_total_avgAIBSPax_avg135.fig'], 'fig');  % This is the big grid of all nuclear convergence
    print(fig, [saveDir, 'thalamocorticalConvergence_bySubregion_total_avgAIBSPax_avg135.eps'], '-depsc2');
    
    close(fig)

    %look at just average average *Ordered by nuclear groups
    fig = figure;
    set(fig, 'Position', [1563 533 352 573])
    imagesc(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_averageOfLevels135.coverage(nuclearOrigins_clusterCompositeMaps.nuclearGroupOrder, nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_averageOfLevels135.groupOrder))
    title(['Average nuclear coverage & Average of Levels 1/3/5'])
    colormap(cmap)
    set(gca, 'YTick', 1:length(nuclearOrigins_clusterCompositeMaps.nuclei))
    set(gca, 'YTickLabel', nuclearOrigins_clusterCompositeMaps.nuclei(nuclearOrigins_clusterCompositeMaps.nuclearGroupOrder))
    set(gca, 'XTick', 1:length(nuclearOrigins_clusterCompositeMaps.groups))
    set(gca, 'XTickLabel', nuclearOrigins_clusterCompositeMaps.groups(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_averageOfLevels135.groupOrder))

    if saveFlag == 1   
        save([saveDir, '/nuclearOrigins_clusterCompositeMaps2.mat'], 'nuclearOrigins_clusterCompositeMaps');
        save([saveDir, 'nuclearOrigins_compositeMaps2.mat'], 'nuclearOrigins_compositeMaps');

        save([saveDir, '/nuclearOrigins_clusterThalCtxConvergence2.mat'], 'nuclearOrigins_clusterThalCtxConvergence');
        save([saveDir, '/nuclearOrigins_thalCtxConvergence2.mat'], 'nuclearOrigins_thalCtxConvergence');

        save([saveDir, '/thalCtx_ClusterConvergenceOrigins2.mat'], 'thalCtx_ClusterConvergenceOrigins');
        save([saveDir, '/thalCtx_StriatalConvergenceOrigins2.mat'], 'thalCtx_StriatalConvergenceOrigins');
    end

end




%% 15. Make these coverage plots (heat maps and bar graphs) for the loop stuff to CLUSTERS (thalamocortical only / thalamostriatal only/ convergent) (FIGURE)

% ************************** NOT cleaned up yet ***************************


if figFlag == 15
    
    %Load the white/green/cyan/magenta colormaps
    load([randomMasksDir, '/color_maps/cmap_white.mat'])
    load([randomMasksDir, '/color_maps/cmap_green.mat'])
    load([randomMasksDir, '/color_maps/cmap_cyan.mat'])
    load([randomMasksDir, '/color_maps/cmap_magenta.mat'])

    saveDir = ([anaDir, '/ThalamostriatalData_processed/Thalamostriatal_testFigures/new_clusters/']);
    
    % Load injGroup_data to get TC info
    load([anaDir, '/injGroup_data.mat']);
    
    
    % Get the coverage values for all confidence levels of each group for selected nuclei 
    % I want to modify this for do it for thalamocortical only / thalamostriatal only / convergent area
    for g = 1:4  %length(thalCtx_StriatalConvergenceOrigins)
        ThalStrMap = thalCtx_ClusterConvergenceOrigins(g).mask(:, :, 1:65);
        thalCtxMap = double(thalCtx_ClusterConvergenceOrigins(g).correspondingThalamoCorticalConfidenceMap); 
        TCTS_convergence = ThalStrMap & thalCtxMap; 
        bothMap = thalCtxMap | ThalStrMap; 
        TC_only = thalCtxMap &~ ThalStrMap; 
        TS_only = ThalStrMap &~ thalCtxMap; 
        for p = 1:32
             if sum(ismember(nucleiToPlot, fatlas(p).name)) > 0
                ind = find(strcmp(nucleiToPlot, fatlas(p).name));
                shortTC_only = TC_only(:, :, 1:64).*double(thalCtx_ClusterConvergenceOrigins(g).correspondingThalamoCorticalConfidenceMap(:, :, 1:64));
                shortTS_only = TS_only(:, :, 1:64).*thalCtx_ClusterConvergenceOrigins(g).mask(:, :, 1:64);
                shortTCTS_convergence = TCTS_convergence(:, :, 1:64).*thalCtx_ClusterConvergenceOrigins(g).mask(:, :, 1:64);
                shortCoverage = coverage(:, :, 1:64);
                for cl = 1:6
                    nuclearOrigins_clusterThalCtxConvergence(g).nucleusNames{ind} = fatlas(p).name; 
                    nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalOnly(ind, cl) = sum(fatlas(p).smallmask110(:) & (shortTC_only(:) >= (cl+2)) & shortCoverage(:))/sum(fatlas(p).smallmask110(:)&shortCoverage(:)); %We used thresholds of 3, 5, and 7 for thalamocortical and it has a max of 8 istead of 6, so I am adding 2
                    nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoStriatalOnly(ind, cl) = sum(fatlas(p).smallmask110(:) & (shortTS_only(:) >= cl) & shortCoverage(:))/sum(fatlas(p).smallmask110(:)&shortCoverage(:));
                    nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalThalamoStriatalOverlap(ind, cl) = sum(fatlas(p).smallmask110(:) & (shortTCTS_convergence(:) >= cl) & shortCoverage(:))/sum(fatlas(p).smallmask110(:)&shortCoverage(:));
                end
             end
        end
        p = 1;
        for a = 33:64
            if sum(ismember(nucleiToPlot, fatlas(a).name)) > 0
                ind = find(strcmp(nucleiToPlot, fatlas(a).name));
                shortTC_only = TC_only(:, :, 1:65).*double(thalCtx_ClusterConvergenceOrigins(g).correspondingThalamoCorticalConfidenceMap(:, :, 1:65));
                shortTS_only = TS_only(:, :, 1:65).*thalCtx_ClusterConvergenceOrigins(g).mask(:, :, 1:65);
                shortTCTS_convergence = TCTS_convergence(:, :, 1:65).*thalCtx_ClusterConvergenceOrigins(g).mask(:, :, 1:65);
                shortCoverage = coverage(:, :, 1:65);
                for cl = 1:6
                    nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalOnly(ind, cl) = sum(fatlas(a).smallmask110(:) & (shortTC_only(:) >= (cl+2)) & shortCoverage(:))/sum(fatlas(a).smallmask110(:)&shortCoverage(:));
                    nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoStriatalOnly(ind, cl) = sum(fatlas(a).smallmask110(:) & (shortTS_only(:) >= cl) & shortCoverage(:))/sum(fatlas(a).smallmask110(:)&shortCoverage(:));
                    nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalThalamoStriatalOverlap(ind, cl) = sum(fatlas(a).smallmask110(:) & (shortTCTS_convergence(:) >= cl) & shortCoverage(:))/sum(fatlas(a).smallmask110(:)&shortCoverage(:));
                end
                p = p+1;
            end
        end
    end
    
        
    % Now make a composite map for the individual confidence levels (AIBS, Pax, and average)
    gg = 1; 
    for g = 1:4  %length(thalCtx_StriatalConvergenceOrigins)
%         if sum(ismember(projAreas_withThalamocorticalMaps, injGroup_data(g).cortical_group)) > 0
           nuclearOrigins_clusterCompositeMaps.nuclei = nuclearOrigins_clusterThalCtxConvergence(g).nucleusNames;
    %         for p = 1:32
                for cl = 1:6
                    nuclearOrigins_clusterCompositeMaps.Pax_TC_TS_both(cl).area(gg).coverage(:, 1) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalOnly(:, cl);
                    nuclearOrigins_clusterCompositeMaps.Pax_TC_TS_both(cl).area(gg).coverage(:, 2) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoStriatalOnly(:, cl);
                    nuclearOrigins_clusterCompositeMaps.Pax_TC_TS_both(cl).area(gg).coverage(:, 3) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalThalamoStriatalOverlap(:, cl);
                    nuclearOrigins_clusterCompositeMaps.Pax_TC_TS_both(cl).all_TC.coverage(:, gg) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalOnly(:, cl);
                    nuclearOrigins_clusterCompositeMaps.Pax_TC_TS_both(cl).all_TS.coverage(:, gg) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoStriatalOnly(:, cl);
                    nuclearOrigins_clusterCompositeMaps.Pax_TC_TS_both(cl).all_TCTSoverlap.coverage(:, gg) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalThalamoStriatalOverlap(:, cl);

                    nuclearOrigins_clusterCompositeMaps.AIBS_TC_TS_both(cl).area(gg).coverage(:, 1) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalOnly(:, cl);
                    nuclearOrigins_clusterCompositeMaps.AIBS_TC_TS_both(cl).area(gg).coverage(:, 2) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoStriatalOnly(:, cl);
                    nuclearOrigins_clusterCompositeMaps.AIBS_TC_TS_both(cl).area(gg).coverage(:, 3) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalThalamoStriatalOverlap(:, cl);
                    nuclearOrigins_clusterCompositeMaps.AIBS_TC_TS_both(cl).all_TC.coverage(:, gg) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalOnly(:, cl);
                    nuclearOrigins_clusterCompositeMaps.AIBS_TC_TS_both(cl).all_TS.coverage(:, gg) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoStriatalOnly(:, cl);
                    nuclearOrigins_clusterCompositeMaps.AIBS_TC_TS_both(cl).all_TCTSoverlap.coverage(:, gg) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalThalamoStriatalOverlap(:, cl);

                    nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(cl).area(gg).coverage(:, 1) = mean([nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalOnly(:, cl), nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalOnly(:, cl)], 2);
                    nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(cl).area(gg).coverage(:, 2) = mean([nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoStriatalOnly(:, cl), nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoStriatalOnly(:, cl)], 2);
                    nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(cl).area(gg).coverage(:, 3) = mean([nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalThalamoStriatalOverlap(:, cl), nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalThalamoStriatalOverlap(:, cl)], 2);
                    nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(cl).all_TC.coverage(:, gg) = mean([nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalOnly(:, cl), nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalOnly(:, cl)], 2);
                    nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(cl).all_TS.coverage(:, gg) = mean([nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoStriatalOnly(:, cl), nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoStriatalOnly(:, cl)], 2);
                    nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(cl).all_TCTSoverlap.coverage(:, gg) = mean([nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalThalamoStriatalOverlap(:, cl), nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalThalamoStriatalOverlap(:, cl)], 2);

                end
    %         end
            nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(gg).coverage(:, 1) = mean([nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(1).area(gg).coverage(:, 1), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(3).area(gg).coverage(:, 1), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(5).area(gg).coverage(:, 1)], 2);
            nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(gg).coverage(:, 2) = mean([nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(1).area(gg).coverage(:, 2), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(3).area(gg).coverage(:, 2), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(5).area(gg).coverage(:, 2)], 2);
            nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(gg).coverage(:, 3) = mean([nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(1).area(gg).coverage(:, 3), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(3).area(gg).coverage(:, 3), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(5).area(gg).coverage(:, 3)], 2);
            nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.all_TC.coverage(:, gg) = mean([nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(1).area(gg).coverage(:, 1), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(3).area(gg).coverage(:, 1), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(5).area(gg).coverage(:, 1)], 2);
            nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.all_TS.coverage(:, gg) = mean([nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(1).area(gg).coverage(:, 2), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(3).area(gg).coverage(:, 2), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(5).area(gg).coverage(:, 2)], 2);
            nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.all_TCTSoverlap.coverage(:, gg) = mean([nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(1).area(gg).coverage(:, 3), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(3).area(gg).coverage(:, 3), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(5).area(gg).coverage(:, 3)], 2);

            nuclearOrigins_clusterCompositeMaps.nuclearGroupOrder = [1,2,3,6,7,14,15,18,19,11,8,21,13,4,5,12,16,22,23,24,25,9,10,20,17]; % for {'AD','AM','AV','CL','CM','IAD','IAM','IMD','LD','LP','MD','PCN','PR','PT','PVT','Pf','Po','RE','RH','RT_short','SMT','VAL','VM','VPL','VPM'}
            gg = gg+1;
%         end
    end
    
    %%%%%%% Something really wrong with this... using the sum of TC-TS-Overlap and TC-only instead
    % Add TC_full to the above analysis: a field to quantify the coverage of nuclei from thal-cortical areas grouped by the clusters they project to (this is different than TC_only which is the fraction of nuclei that project to ONLY cortical areas and DON'T converge in the striatum) 
    %     for g = 1:4  %length(thalCtx_StriatalConvergenceOrigins)
%         thalCtxMap = logical(thalCtx_ClusterConvergenceOrigins(g).correspondingThalamoCorticalConfidenceMap); 
%         for p = 1:32
%              if sum(ismember(nucleiToPlot, fatlas(p).name)) > 0
%                 ind = find(strcmp(nucleiToPlot, fatlas(p).name));
%                 shortTC_full = thalCtxMap(:, :, 1:64).*double(thalCtx_ClusterConvergenceOrigins(g).correspondingThalamoCorticalConfidenceMap(:, :, 1:64));
%                 shortCoverage = coverage(:, :, 1:64);
%                 for cl = 1:6
%                     nuclearOrigins_clusterThalCtxConvergence(g).nucleusNames{ind} = fatlas(p).name; 
%                     nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalFull(ind, cl) = sum(fatlas(p).smallmask110(:) & (shortTC_full(:) >= (cl+2)) & shortCoverage(:)) / sum(fatlas(p).smallmask110(:) & shortCoverage(:)); %We used thresholds of 3, 5, and 7 for thalamocortical and it has a max of 8 istead of 6, so I am adding 2
%                 end
%              end
%         end
%         p = 1;
%         for a = 33:64
%             if sum(ismember(nucleiToPlot, fatlas(a).name)) > 0
%                 ind = find(strcmp(nucleiToPlot, fatlas(a).name));
%                 shortTC_full = thalCtxMap(:, :, 1:65).*double(thalCtx_ClusterConvergenceOrigins(g).correspondingThalamoCorticalConfidenceMap(:, :, 1:65));
%                 shortCoverage = coverage(:, :, 1:65);
%                 for cl = 1:6
%                     nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalFull(ind, cl) = sum(fatlas(a).smallmask110(:) & (shortTC_full(:) >= (cl+2)) & shortCoverage(:)) / sum(fatlas(a).smallmask110(:) & shortCoverage(:));
%                 end
%                 p = p+1;
%             end
%         end
%     end
%     gg = 1; 
%     for g = 1:4  %length(thalCtx_StriatalConvergenceOrigins)
%         nuclearOrigins_clusterCompositeMaps.nuclei = nuclearOrigins_clusterThalCtxConvergence(g).nucleusNames;
%         for cl = 1:6
%             nuclearOrigins_clusterCompositeMaps.Pax_TC_TS_both(cl).area(gg).coverage(:, 4) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalFull(:, cl);
%             nuclearOrigins_clusterCompositeMaps.AIBS_TC_TS_both(cl).area(gg).coverage(:, 4) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalFull(:, cl);
%             nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(cl).area(gg).coverage(:, 4) = mean([nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalFull(:, cl), nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalOnly(:, cl)], 2);
%         end
%         nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(gg).coverage(:, 4) = mean([nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(1).area(gg).coverage(:, 4), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(3).area(gg).coverage(:, 4), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(5).area(gg).coverage(:, 4)], 2);
%         nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.full_TC.coverage(:, gg) = mean([nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(1).area(gg).coverage(:, 4), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(3).area(gg).coverage(:, 4), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(5).area(gg).coverage(:, 4)], 2);
%         gg = gg+1;
%     end
    

    %Images of the thalamocortical only, thalamostriatal only, and thalamic origin overlap (FIGURE)
    for g = 1:length(nuclearOrigins_clusterCompositeMaps.groups)
        %Just overlap white
        fig = figure;
        set(fig, 'Position', [1795 210 128 896])
        oneColumn = nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(g).coverage(:, 3); 
        imagesc(oneColumn(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :)) % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16
        axis image
        title([nuclearOrigins_clusterCompositeMaps.groups(g), ': Overlap'])
        caxis([0 1])
        colormap(cmap_white)
        set(gca, 'YTick', 1:length(nuclearOrigins_clusterCompositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_clusterCompositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder)) % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16
        set(gca, 'XTick', 1)
        set(gca, 'XTickLabel', {'TCTSoverlap'});
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_Overlap_cluster_',num2str(g), '.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_Overlap_cluster_',num2str(g), '.eps'], '-depsc2');
        close(fig)

        %Just TS magenta
        fig = figure;
        set(fig, 'Position', [1795 210 128 896])
        oneColumn = nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(g).coverage(:, 2); 
        imagesc(oneColumn(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :)) % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16
        title([nuclearOrigins_clusterCompositeMaps.groups(g), ': Thalamostriatal'])
        axis image
        caxis([0 1])
        colormap(cmap_magenta)
        set(gca, 'YTick', 1:length(nuclearOrigins_clusterCompositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_clusterCompositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder)) % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16
        set(gca, 'XTick', 1)
        set(gca, 'XTickLabel', {'TS'});
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_TS_cluster_',num2str(g), '.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_TS_cluster_',num2str(g), '.eps'], '-depsc2');
        close(fig)

        %Just TC cyan
        fig = figure;
        set(fig, 'Position', [1795 210 128 896])
        oneColumn = nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(g).coverage(:, 1);
        imagesc(oneColumn(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :)) % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16
        title([nuclearOrigins_clusterCompositeMaps.groups(g), ': Thalamocortical'])
        axis image
        caxis([0 1])
        colormap(cmap_cyan)
        set(gca, 'YTick', 1:length(nuclearOrigins_clusterCompositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_clusterCompositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder)) % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16
        set(gca, 'XTick', 1)
        set(gca, 'XTickLabel', {'TC'});
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_TC_cluster_',num2str(g), '.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_TC_cluster_',num2str(g), '.eps'], '-depsc2');
        close(fig)

        %all 3 white
        fig = figure;
        set(fig, 'Position', [1753 210 167 896])
        imagesc(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(g).coverage(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :)) % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16
        title([nuclearOrigins_clusterCompositeMaps.groups(g), ': thalamocortical, thalamostriatal, & dual projection origins: average nuclear coverage & Average of Levels 1/3/5'])
        axis image
        caxis([0 1])
        colormap(cmap)
        set(gca, 'YTick', 1:length(nuclearOrigins_clusterCompositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_clusterCompositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder)) % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16
        set(gca, 'XTick', 1:3)
        set(gca, 'XTickLabel', {'TC', 'TS', 'TCTSoverlap'});
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_all_cluster_',num2str(g), '.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_all_cluster_',num2str(g), '.eps'], '-depsc2');
        close(fig)
        
        %TC Full white
        fig = figure;
        set(fig, 'Position', [1795 210 128 896])
        oneColumn = (nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(g).coverage(:, 1) + nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(g).coverage(:, 3)); % sum of TC-TS-Overlap and TC-only to get all TC data. 
        imagesc(oneColumn(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :)) % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16
        title([nuclearOrigins_clusterCompositeMaps.groups(g), ': Thalamocortical'])
        axis image
        caxis([0 1])
        colormap(cmap_white)
        set(gca, 'YTick', 1:length(nuclearOrigins_clusterCompositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_clusterCompositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder)) % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16
        set(gca, 'XTick', 1)
        set(gca, 'XTickLabel', {'TC'});
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_TCfull_cluster_',num2str(g), '.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_TCfull_cluster_',num2str(g), '.eps'], '-depsc2');
        close(fig)
    end
   

    % ***** Adding in another of the plot above for corticothalamic data *****
    % (this data was created at the bottom of jh_consolidatingAIBS_forGephi.m and originally from GetDensityDataFromWeb.py)
    % I put the data in injGroup_data.mat inder the field injGroup_data(g).nuclearProjections(n) : where n are the 25 nuclei we're looking at: IMD,MD,RH,CM,PR,SMT,PF,LP,PCN,CL,IAM,PVT,PT,RE,IAD,AM,AD,LD,PO,VAL,VM,VPM,AV,RT,VPL
    corticalGroup = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'SS', 'Vis', 'SUB_HIPP', 'Amyg', 'SNr', 'na'};
    projAreas_toKeep = corticalGroup(~ismember(corticalGroup,{'SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'na', 'SNr'}));  % I manually added in sub to get the nucleus coverage then removed again. 

    
    thalCtx_ClusterConvergenceOrigins(1).domainHomolog = {'ventral'};
    thalCtx_ClusterConvergenceOrigins(2).domainHomolog = {'posterior'};
    thalCtx_ClusterConvergenceOrigins(3).domainHomolog = {'dorsolateral'};
    thalCtx_ClusterConvergenceOrigins(4).domainHomolog = {'dorsomedial'};
    
    thalCtx_ClusterConvergenceOrigins(1).primaryCtxConvergence = {'AI_GU_VISC', 'IL', 'PL_MO', 'SUB_HIPP'};
    thalCtx_ClusterConvergenceOrigins(2).primaryCtxConvergence = {'AUD', 'ECT_PERI_TE', 'Vis'};
    thalCtx_ClusterConvergenceOrigins(3).primaryCtxConvergence = {'AI_GU_VISC', 'FRA', 'MOp', 'SS'};
    thalCtx_ClusterConvergenceOrigins(4).primaryCtxConvergence = {'ACA', 'ORBl', 'PL_MO', 'PTL', 'RSP', 'Vis'};
    
    for c = 1:4
        for n = 1:length(injGroup_data(g).nuclearProjections) %Generate the max values for the projections
            maxCT_toNucleus = 0;
            for g = 1: length(injGroup_data)
                if sum(ismember(thalCtx_ClusterConvergenceOrigins(c).primaryCtxConvergence, injGroup_data(g).cortical_group)) > 0
                    
                    maxCT_toNucleus = max(maxCT_toNucleus, max(injGroup_data(g).nuclearProjections(n).projDensity));
                    
                end
            end
            oneColumn(n) = maxCT_toNucleus; 
        end
%         %Generate the max values for the projections
%         for n = 1:length(injGroup_data(g).nuclearProjections)
%             oneColumn(n) = max(injGroup_data(g).nuclearProjections(n).projDensity); 
%         end
        %Plot max density of Corticothalamic proj to each nucleus in green
        fig = figure;
        set(fig, 'Position', [1795 210 128 896])
        imagesc(oneColumn) % Already in the cortically clustered order (should start with IMD)
        axis image
        title([thalCtx_ClusterConvergenceOrigins(c).domainHomolog, ': CT'])
        caxis([0 0.6])
        colormap(cmap_green)
        set(gca, 'YTick', 1:length(nuclearOrigins_clusterCompositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_clusterCompositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder)) % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16
        set(gca, 'XTick', 1)
        set(gca, 'XTickLabel', {'CT'});
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/CT_Overlap_cluster_',num2str(c), '.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/CT_Overlap_cluster_',num2str(c), '.eps'], '-depsc2');
        close(fig)
    end



    % SKIPPED THIS FOR CLUSTERS (FOR NOW): now a horozontal stacked bar plot
    for g = 14 %:length(nuclearOrigins_clusterCompositeMaps.groups)
        fig = figure;
        set(fig, 'Position', [1715 267 205 839])
    %     level0 =
    %     nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(6).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g); % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16
        level1 = nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(1).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g) - nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(3).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g);
        level3 = nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(3).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g) - nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(5).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g);
        level5 = nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(5).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g); % - nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(6).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g);

        barh([level5, level3 level1], 'stacked')
        hold on
        plot(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_averageOfLevels135.coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g), 1:length(nuclearOrigins_clusterCompositeMaps.nuclei), 'c-') % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16

        title([nuclearOrigins_clusterCompositeMaps.groups(g), ': thalamocortical, thalamostriatal, & dual projection origins: average nuclear coverage & Average of Levels 1/3/5'])
        colormap(cmap_barLevels)
        set(gca, 'YTick', 1:length(nuclearOrigins_clusterCompositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_clusterCompositeMaps.nuclei(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2))) % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16
    %     set(gca, 'XTick', 1:3)
        legend({'5', '3', '1'});
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/nuclearCoverageLevels123_BAR_cluster_',num2str(g), '.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/nuclearCoverageLevels123_BAR_cluster_',num2str(g), '.eps'], '-depsc2');
        close(fig)
    end
end


%% 16. (Redo of 13: UPDATE 10/18/16) : Use the thalamostriatal confidence map to clusters only (not all area of the primary inputs to the clusters, like above) to make the composite images and save them
   

%         % Checking that the confidence maps are properly aligned since betteraveragethalamus is 65 slices but thalamusInj_specialGroups(3).cluster(g).cmap is 70...
%         group = thalamusInj_specialGroups(3).cluster(g).cmap; % Special groups 3 is for 4 clusters, as found in thalamusInj_specialGroups(3).name
%         ThalStrMap = thalCtx_ClusterConvergenceOrigins(g).mask(:, :, 1:65)./max(thalCtx_ClusterConvergenceOrigins(g).mask(:));  %normalizing them all to a max of 1
%
%         for i = 1:10:60
%             fig = figure; 
%             set(fig, 'Position', [1570 790 350 250])
%             imagesc(thalamusInj_specialGroups(3).cluster(4).cmap(:, :, i));
%             hold on
%             text(10,10,['Cluster ONLY - Section: ', num2str(i)],'Color','r');
%             outline = h_getNucleusOutline(betteraveragethalamus(:, :, i));
%             for j = 1:length(outline)
%                 plot((outline{j}(:,2)), (outline{j}(:,1)), 'w-', 'linewidth', 1.2);
%             end
%             hold off
%             
%             fig2 = figure; 
%             set(fig2, 'Position', [1570 790 350 250])
%             imagesc(ThalStrMap(:, :, i));
%             hold on
%             text(10,10,['Ctx Field - Section: ', num2str(i)],'Color','r');
%             outline = h_getNucleusOutline(betteraveragethalamus(:, :, i));
%             for j = 1:length(outline)
%                 plot((outline{j}(:,2)), (outline{j}(:,1)), 'w-', 'linewidth', 1.2);
%             end
%             hold off
%         end


if figFlag == 16
    saveDir = ([anaDir, '/ThalamostriatalData_processed/Thalamostriatal_testFigures/new_clusters2']);

    % Load the thalamostriatal cluster input confidence maps
    load([anaDir, '/thalamusInj_specialGroups.mat'])

    % The clusters are ordered differently in this file
    TSclusters(1).cmap = thalamusInj_specialGroups(3).cluster(4).cmap; % Special groups 3 is for 4 clusters, as found in thalamusInj_specialGroups(3).name, and clusters are ordered 1:Posterior, 2:Dorsomedial, 3:Dorsolateral, 4:Ventral
    TSclusters(2).cmap = thalamusInj_specialGroups(3).cluster(1).cmap; % Special groups 3 is for 4 clusters, as found in thalamusInj_specialGroups(3).name, and clusters are ordered 1:Posterior, 2:Dorsomedial, 3:Dorsolateral, 4:Ventral
    TSclusters(3).cmap = thalamusInj_specialGroups(3).cluster(3).cmap; % Special groups 3 is for 4 clusters, as found in thalamusInj_specialGroups(3).name, and clusters are ordered 1:Posterior, 2:Dorsomedial, 3:Dorsolateral, 4:Ventral
    TSclusters(4).cmap = thalamusInj_specialGroups(3).cluster(2).cmap; % Special groups 3 is for 4 clusters, as found in thalamusInj_specialGroups(3).name, and clusters are ordered 1:Posterior, 2:Dorsomedial, 3:Dorsolateral, 4:Ventral
    TSclusters(1).name = 'ventral';
    TSclusters(2).name = 'posterior';
    TSclusters(3).name = 'dorsolateral';
    TSclusters(4).name = 'dorsomedial';
    
    for g = 1:4 % Loop through the 4 clusters       %length(corticalGroupNames) % Loop through all cortical groups
        mkdir([saveDir, '/thalamo_corticostriatalOriginOverlap/', num2str(g)]) %for thal images
        mkdir([saveDir, '/thalamo_corticostriatalOriginOverlap/', num2str(g), '/backupConvergenceMask'])

        % Making arrays condusive to turning into rgb images
            % *** Different ThalStrMap than last time *** 
        ThalStrMap = TSclusters(g).cmap(:, :, 1:65)./max(TSclusters(g).cmap(:));  %normalizing them all to a max of 1
        thalCtxMap = double(thalCtx_ClusterConvergenceOrigins(g).correspondingThalamoCorticalConfidenceMap)./double(max(thalCtx_ClusterConvergenceOrigins(g).correspondingThalamoCorticalConfidenceMap(:))); 
        TCTS_convergence = ThalStrMap & thalCtxMap; 
        bothMap = thalCtxMap | ThalStrMap; 
        TC_only = thalCtxMap &~ThalStrMap; 
        TS_only = ThalStrMap &~ thalCtxMap; 
        
        for k = 1:size(TCTS_convergence, 3)
            % #WINNER I think, or at least it's the best I can figure out to look at convergence, i need to sleep -I can fill in the convergence outline in illustrator if needed
            rgb_test(:, :, 1) = ThalStrMap(:, :, k)*256.*(betteraveragethalamus(:, :, k)); % Also limiting the image to the size of the model striatum
            rgb_test(:, :, 2) = thalCtxMap(:, :, k)*256.*(betteraveragethalamus(:, :, k)); 
            rgb_test(:, :, 3) = ThalStrMap(:, :, k)*256+thalCtxMap(:, :, k)*256.*(betteraveragethalamus(:, :, k)); %Makes them cyan and magenta
            rgb_test = uint8(rgb_test);

            fig = figure; 
            set(fig, 'Position', [1570 790 350 250])

            imshow(rgb_test);
%             text(50,50,[thalCtx_ClusterConvergenceOrigins(g).domainHomolog],'Color','r');
            hold on
            outline = h_getNucleusOutline(TCTS_convergence(:, :, k));
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1)), 'c-', 'linewidth',1);
            end
            outline = h_getNucleusOutline(betteraveragethalamus(:, :, k));
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1)), 'r-', 'linewidth',1.2);
            end

            if saveFlag == 1
                saveas(fig, [saveDir, '/thalamo_corticostriatalOriginOverlap/', num2str(g), '/thalCtxOriginOverlap_', thalCtx_ClusterConvergenceOrigins(g).domainHomolog{1}, '_section', num2str(k), '.fig'], 'fig');
                print(fig, [saveDir, '/thalamo_corticostriatalOriginOverlap/', num2str(g), '/thalCtxOriginOverlap_', thalCtx_ClusterConvergenceOrigins(g).domainHomolog{1}, '_section', num2str(k), '.eps'], '-depsc2');
            end
            close(fig)

            % Sometimes the outline thing fails when there are lots of  little bits so I'm saving that mask too to fix errors... 
            fig2 = figure; 
            set(fig2, 'Position', [1570 790 350 250])
            imshow(TCTS_convergence(:, :, k));

            if saveFlag == 1
                saveas(fig2, [saveDir, '/thalamo_corticostriatalOriginOverlap/', num2str(g), '/backupConvergenceMask/maskOnly_thalCtxOriginOverlap_', thalCtx_ClusterConvergenceOrigins(g).domainHomolog{1}, '_section', num2str(k), '.fig'], 'fig');
                print(fig2, [saveDir, '/thalamo_corticostriatalOriginOverlap/', num2str(g), '/backupConvergenceMask/maskOnly_thalCtxOriginOverlap_', thalCtx_ClusterConvergenceOrigins(g).domainHomolog{1}, '_section', num2str(k), '.eps'], '-depsc2');
            end
            close(fig2)


        end
    end

end


%% 17. (Redo of 14: UPDATE 10/18/16) Create the nuclear overlap data for CLUSTERS and make the nucleus localized T-S overview figure.  (FIGURE)
%         : Use the thalamostriatal confidence map to clusters only (not all area of the primary inputs to the clusters, like above) 

if figFlag == 17
    
    saveDir = ([anaDir, '/ThalamostriatalData_processed/Thalamostriatal_testFigures/new_clusters2']);

        
    disp('Where are the collected masks?')
    randomMasksDir = uigetdir;
    
    
    load([randomMasksDir, '/std thal w traced nuclei & final adj atlas_2014-03-06.mat']) %Loading the injection site thalamus data from the thalamocortical paper

    %Load the raw thalamostriatal data and the average brain
%     load([anaDir, '/inj_thalData.mat']) %Loading the thalamostriatal data from above
    load([randomMasksDir, '/AIBS_100um.mat'])
    ic_submask = AIBS_100um.striatum.ic_submask; % I'll need to apply this to the thalamus data

    %Load the confidence maps of the thalamic origins of thalamostriatal inputs that converge with corticostriatal inputs, also has the corresponding thalamocortical confidence map
    %   *the individual confidence levels before they are summed are in thalamusInj_group_Level10.mat
    load([anaDir, '/thalCtx_ClusterConvergenceOrigins.mat'])

    % Load the thalamostriatal cluster input confidence maps
    load([anaDir, '/thalamusInj_specialGroups.mat'])

    %Load the red-white-blue colormap
    load([randomMasksDir, '/color_maps/cmap_blue0_white25_red1.mat'])
    
    %Load the thalamus coverage mask
    load([randomMasksDir, '/coverageByFullInjections.mat'])
    coverage = logical(sumcoverage);


    %Remove axon tracts and nuclei we're not using
    for p = 1:32
        atlasNucleusNames{p} = fatlas(p).name; 
    end
    nucleiToPlot = atlasNucleusNames(~ismember(atlasNucleusNames,{'fr', 'SPA', 'POL','LG','MH','LH', 'SPFp'}));

    % Remove arreas without their own thalamocortical maps
    projAreas_withThalamocorticalMaps = corticalGroup(~ismember(corticalGroup,{'SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'na', 'SNr', 'SUB_HIPP'}));  % I manually added in sub to get the nucleus coverage then removed again. 
    shortCoverage = coverage(:, :, 64);

    
%     group = thalamusInj_specialGroups(3).cluster(g).cmap; % Special groups 3 is for 4 clusters, as found in thalamusInj_specialGroups(3).name, and clusters are ordered 1:Posterior, 2:Dorsomedial, 3:Dorsolateral, 4:Ventral
%     TSclusters(g).cmap; %  Ordered 1:Ventral, 2:Posterior, 3:Dorsolateral,  4:Dorsomedial
%     ThalStrMap = thalCtx_ClusterConvergenceOrigins(g).mask(:, :, 1:65);  %  Ordered 1:Ventral, 2:Posterior, 3:Dorsolateral,  4:Dorsomedial

    
    % Get the coverage values for all confidence levels of each group for selected nuclei 
    for g = 1:length(TSclusters)
%         if sum(ismember(projAreas_withThalamocorticalMaps, injGroup_data(g).cortical_group)) > 0
            for p = 1:32
                 if sum(ismember(nucleiToPlot, fatlas(p).name)) > 0
                    ind = find(strcmp(nucleiToPlot, fatlas(p).name));
                    shortCmap = TSclusters(g).cmap(:, :, 1:64);
                    shortCoverage = coverage(:, :, 1:64);
                    for cl = 1:6
                        nuclearOrigins_clusterThalCtxConvergence(g).nucleusNames{ind} = fatlas(p).name; 
                        nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax(ind, cl) = sum(fatlas(p).n2fmask(:) & (shortCmap(:) >= cl))/sum(fatlas(p).n2fmask(:)&shortCoverage(:));  % I need this to be fraction of jucleus covered... 
                        nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_eroded(ind, cl) = sum(fatlas(p).smallmask110(:) & (shortCmap(:) >= cl))/sum(fatlas(p).smallmask110(:)&shortCoverage(:));
                    end
                 end
            end
            p = 1;
            for a = 33:64
                if sum(ismember(nucleiToPlot, fatlas(a).name)) > 0
                    ind = find(strcmp(nucleiToPlot, fatlas(a).name));
                    shortCmap = TSclusters(g).cmap(:, :, 1:65);
                    shortCoverage = coverage(:, :, 1:65);
                    for cl = 1:6
        %                 nuclearOrigins_clusterThalCtxConvergence(g).nucleusNames{p} = fatlas(a).name; 
                        nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS(ind, cl) = sum(fatlas(a).n2fmask(:) & (shortCmap(:) >= cl))/sum(fatlas(a).n2fmask(:)&shortCoverage(:));
                        nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_eroded(ind, cl) = sum(fatlas(a).smallmask110(:) & (shortCmap(:) >= cl))/sum(fatlas(a).smallmask110(:)&shortCoverage(:));
                    end
                    p = p+1;
                end
            end
%         end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Left off here 10-4-16
    % Now make a composite map for the individual confidence levels (AIBS, Pax, and average)
    gg = 1; 
    for g = 1:length(TSclusters)
%         if sum(ismember(projAreas_withThalamocorticalMaps, injGroup_data(g).cortical_group)) > 0
           nuclearOrigins_clusterCompositeMaps.nuclei = nuclearOrigins_clusterThalCtxConvergence(g).nucleusNames;
    %         for p = 1:32
                for cl = 1:6
                    nuclearOrigins_clusterCompositeMaps.Pax(cl).coverage(:, gg) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_eroded(:, cl); 
                    nuclearOrigins_clusterCompositeMaps.AIBS(cl).coverage(:, gg) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_eroded(:, cl); 
                    nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(cl).coverage(:, gg) = mean([nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_eroded(:, cl), nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_eroded(:, cl)], 2); 
                    nuclearOrigins_clusterCompositeMaps.groups{gg} = thalCtx_ClusterConvergenceOrigins(g).domainHomolog{1};  % ConvergenceOrigins(g).thalamostriatalGroup
                end
    %         end
            nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_averageOfLevels135.coverage(:, gg) = mean([nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(1).coverage(:, gg), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(3).coverage(:, gg), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(5).coverage(:, gg)], 2);
            nuclearOrigins_clusterCompositeMaps.nuclearGroupOrder = [1,2,3,6,7,14,15,18,19,11,8,21,13,4,5,12,16,22,23,24,25,9,10,20,17]; % for {'AD','AM','AV','CL','CM','IAD','IAM','IMD','LD','LP','MD','PCN','PR','PT','PVT','Pf','Po','RE','RH','RT_short','SMT','VAL','VM','VPL','VPM'}

            gg = gg+1;
%         end
    end



    %I need to cluster these by common inputs
    for cl = 1:6
        % Pax nucleus clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_clusterCompositeMaps.Pax(cl).coverage,'cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure;
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_clusterCompositeMaps.Pax(cl).nucleusOrder = optimleaf;
        close(fig)

        % Pax group clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_clusterCompositeMaps.Pax(cl).coverage','cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure; 
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_clusterCompositeMaps.Pax(cl).groupOrder = optimleaf; 
        close(fig)

        % AIBS nucleus clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_clusterCompositeMaps.AIBS(cl).coverage,'cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure;
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_clusterCompositeMaps.AIBS(cl).nucleusOrder = optimleaf;
        close(fig)

        % AIBS group clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_clusterCompositeMaps.AIBS(cl).coverage','cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure; 
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_clusterCompositeMaps.AIBS(cl).groupOrder = optimleaf; 
        close(fig)

        % Average nucleus clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(cl).coverage,'cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure;
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(cl).nucleusOrder = optimleaf;
        close(fig)

        % Average group clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(cl).coverage','cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure; 
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(cl).groupOrder = optimleaf; 
        close(fig)

        % Average nucleus clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_averageOfLevels135.coverage,'cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure;
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder = optimleaf;
        close(fig)

        % Average group clustering
        convergence_PairwiseDistance = pdist(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_averageOfLevels135.coverage','cityblock');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        fig = figure; 
        optimleaf = optimalleaforder(convergence_clustering, convergence_PairwiseDistance);
        dendrogram(convergence_clustering, 'reorder', optimleaf);
        nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_averageOfLevels135.groupOrder = optimleaf; 
        close(fig)
    end



    %look at the plots
    o = 1; %Use a constant cluster order. 
    for cl = 1:6
    %     fig = figure;
    %     set(fig, 'Position', [1563 533 352 573])
    %     imagesc(nuclearOrigins_clusterCompositeMaps.Pax(cl).coverage(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(o).nucleusOrder, nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(o).groupOrder))
    %     title(['Pax nuclear coverage: level ', num2str(cl)])
    % %     axis image
    %     set(gca, 'YTick', 1:length(nuclearOrigins_clusterCompositeMaps.nuclei))
    %     set(gca, 'YTickLabel', nuclearOrigins_clusterCompositeMaps.nuclei(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(o).nucleusOrder))
    %     set(gca, 'XTick', 1:length(nuclearOrigins_clusterCompositeMaps.groups))
    %     set(gca, 'XTickLabel', nuclearOrigins_clusterCompositeMaps.groups(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(o).groupOrder))
    %     
    %     fig = figure;
    %     set(fig, 'Position', [1563 533 352 573])
    %     imagesc(nuclearOrigins_clusterCompositeMaps.AIBS(cl).coverage(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(o).nucleusOrder, nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(o).groupOrder))
    %     title(['AIBS nuclear coverage: level ', num2str(cl)])
    % %     axis image
    %     set(gca, 'YTick', 1:length(nuclearOrigins_clusterCompositeMaps.nuclei))
    %     set(gca, 'YTickLabel', nuclearOrigins_clusterCompositeMaps.nuclei(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(o).nucleusOrder))
    %     set(gca, 'XTick', 1:length(nuclearOrigins_clusterCompositeMaps.groups))
    %     set(gca, 'XTickLabel', nuclearOrigins_clusterCompositeMaps.groups(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(o).groupOrder))
    %   
        % I am settled on the average being best
        fig = figure;
        set(fig, 'Position', [1563 533 352 573])
        imagesc(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(cl).coverage(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(o).nucleusOrder, nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(o).groupOrder))
        title(['Average nuclear coverage: level ', num2str(cl)])
    %     axis image
        set(gca, 'YTick', 1:length(nuclearOrigins_clusterCompositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_clusterCompositeMaps.nuclei(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(o).nucleusOrder))
        set(gca, 'XTick', 1:length(nuclearOrigins_clusterCompositeMaps.groups))
        set(gca, 'XTickLabel', nuclearOrigins_clusterCompositeMaps.groups(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(o).groupOrder))

    end

    
    %look at just average average  ***I like this one better than nuclear group one (FIGURE)
    fig = figure;
    set(fig, 'Position', [1563 533 352 573])
    imagesc(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_averageOfLevels135.coverage(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_averageOfLevels135.groupOrder))  %Using the .nucleusOrder from the subregion clustering for figure consistency 10/4/16
    title(['Average nuclear coverage & Average of Levels 1/3/5'])
    colormap(cmap)
    set(gca, 'YTick', 1:length(nuclearOrigins_compositeMaps.nuclei))  % Using the .nucleusOrder from the subregion clustering for figure consistency 10/4/16
    set(gca, 'YTickLabel', nuclearOrigins_compositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder))  % Using the .nucleusOrder from the subregion clustering for figure consistency 10/4/16
    set(gca, 'XTick', 1:length(nuclearOrigins_clusterCompositeMaps.groups))
    set(gca, 'XTickLabel', nuclearOrigins_clusterCompositeMaps.groups(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_averageOfLevels135.groupOrder))

    % saveDir = ('/Users/jeaninehunnicutt/Desktop/ThalamostriatalData_processed/Thalamostriatal_testFigures');
    % mkDir = ('/Users/jeaninehunnicutt/Desktop/ThalamostriatalData_processed/Thalamostriatal_testFigures/nuclearCoverage/');
%     cd('/Users/jeaninehunnicutt/Desktop/ThalamostriatalData_processed/Thalamostriatal_testFigures/nuclearCoverage');
    
    saveas(fig, [saveDir, 'thalamocorticalConvergence_bySubregion_total_avgAIBSPax_avg135.fig'], 'fig');  % This is the big grid of all nuclear convergence
    print(fig, [saveDir, 'thalamocorticalConvergence_bySubregion_total_avgAIBSPax_avg135.eps'], '-depsc2');
    
    close(fig)

    %look at just average average *Ordered by nuclear groups
    fig = figure;
    set(fig, 'Position', [1563 533 352 573])
    imagesc(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_averageOfLevels135.coverage(nuclearOrigins_clusterCompositeMaps.nuclearGroupOrder, nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_averageOfLevels135.groupOrder))
    title(['Average nuclear coverage & Average of Levels 1/3/5'])
    colormap(cmap)
    set(gca, 'YTick', 1:length(nuclearOrigins_clusterCompositeMaps.nuclei))
    set(gca, 'YTickLabel', nuclearOrigins_clusterCompositeMaps.nuclei(nuclearOrigins_clusterCompositeMaps.nuclearGroupOrder))
    set(gca, 'XTick', 1:length(nuclearOrigins_clusterCompositeMaps.groups))
    set(gca, 'XTickLabel', nuclearOrigins_clusterCompositeMaps.groups(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_averageOfLevels135.groupOrder))

    if saveFlag == 1   
        save([saveDir, '/nuclearOrigins_clusterCompositeMaps2.mat'], 'nuclearOrigins_clusterCompositeMaps');
        save([saveDir, 'nuclearOrigins_compositeMaps2.mat'], 'nuclearOrigins_compositeMaps');

        save([saveDir, '/nuclearOrigins_clusterThalCtxConvergence2.mat'], 'nuclearOrigins_clusterThalCtxConvergence');
        save([saveDir, '/nuclearOrigins_thalCtxConvergence2.mat'], 'nuclearOrigins_thalCtxConvergence');

        save([saveDir, '/thalCtx_ClusterConvergenceOrigins2.mat'], 'thalCtx_ClusterConvergenceOrigins');
        save([saveDir, '/thalCtx_StriatalConvergenceOrigins2.mat'], 'thalCtx_StriatalConvergenceOrigins');
    end

end


%% 17. (Redo of 15: UPDATE 10/18/16) Make these coverage plots (heat maps and bar graphs) for the loop stuff to CLUSTERS (thalamocortical only / thalamostriatal only/ convergent) (FIGURE)
%         : Use the thalamostriatal confidence map to clusters only (not all area of the primary inputs to the clusters, like above) 

% ************************** NOT cleaned up yet ***************************


if figFlag == 17
    
    %Load the white/green/cyan/magenta colormaps
    load([randomMasksDir, '/color_maps/cmap_white.mat'])
    load([randomMasksDir, '/color_maps/cmap_green.mat'])
    load([randomMasksDir, '/color_maps/cmap_cyan.mat'])
    load([randomMasksDir, '/color_maps/cmap_magenta.mat'])

    saveDir = ([anaDir, '/ThalamostriatalData_processed/Thalamostriatal_testFigures/new_clusters2/']);
    
    % Load injGroup_data to get TC info
    load([anaDir, '/injGroup_data.mat']);
    
    
    % Get the coverage values for all confidence levels of each group for selected nuclei 
    % I want to modify this for do it for thalamocortical only / thalamostriatal only / convergent area
    for g = 1:4  %length(thalCtx_StriatalConvergenceOrigins)
        ThalStrMap = TSclusters(g).cmap(:, :, 1:65);
        thalCtxMap = double(thalCtx_ClusterConvergenceOrigins(g).correspondingThalamoCorticalConfidenceMap); 
        TCTS_convergence = ThalStrMap & thalCtxMap; 
        bothMap = thalCtxMap | ThalStrMap; 
        TC_only = thalCtxMap &~ ThalStrMap; 
        TS_only = ThalStrMap &~ thalCtxMap; 
        for p = 1:32
             if sum(ismember(nucleiToPlot, fatlas(p).name)) > 0
                ind = find(strcmp(nucleiToPlot, fatlas(p).name));
                shortTC_only = TC_only(:, :, 1:64).*double(thalCtx_ClusterConvergenceOrigins(g).correspondingThalamoCorticalConfidenceMap(:, :, 1:64));
                shortTS_only = TS_only(:, :, 1:64).*TSclusters(g).cmap(:, :, 1:64);
                shortTCTS_convergence = TCTS_convergence(:, :, 1:64).*TSclusters(g).cmap(:, :, 1:64);
                shortCoverage = coverage(:, :, 1:64);
                for cl = 1:6
                    nuclearOrigins_clusterThalCtxConvergence(g).nucleusNames{ind} = fatlas(p).name; 
                    nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalOnly(ind, cl) = sum(fatlas(p).smallmask110(:) & (shortTC_only(:) >= (cl+2)) & shortCoverage(:))/sum(fatlas(p).smallmask110(:)&shortCoverage(:)); %We used thresholds of 3, 5, and 7 for thalamocortical and it has a max of 8 istead of 6, so I am adding 2
                    nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoStriatalOnly(ind, cl) = sum(fatlas(p).smallmask110(:) & (shortTS_only(:) >= cl) & shortCoverage(:))/sum(fatlas(p).smallmask110(:)&shortCoverage(:));
                    nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalThalamoStriatalOverlap(ind, cl) = sum(fatlas(p).smallmask110(:) & (shortTCTS_convergence(:) >= cl) & shortCoverage(:))/sum(fatlas(p).smallmask110(:)&shortCoverage(:));
                end
             end
        end
        p = 1;
        for a = 33:64
            if sum(ismember(nucleiToPlot, fatlas(a).name)) > 0
                ind = find(strcmp(nucleiToPlot, fatlas(a).name));
                shortTC_only = TC_only(:, :, 1:65).*double(thalCtx_ClusterConvergenceOrigins(g).correspondingThalamoCorticalConfidenceMap(:, :, 1:65));
                shortTS_only = TS_only(:, :, 1:65).*TSclusters(g).cmap(:, :, 1:65);
                shortTCTS_convergence = TCTS_convergence(:, :, 1:65).*TSclusters(g).cmap(:, :, 1:65);
                shortCoverage = coverage(:, :, 1:65);
                for cl = 1:6
                    nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalOnly(ind, cl) = sum(fatlas(a).smallmask110(:) & (shortTC_only(:) >= (cl+2)) & shortCoverage(:))/sum(fatlas(a).smallmask110(:)&shortCoverage(:));
                    nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoStriatalOnly(ind, cl) = sum(fatlas(a).smallmask110(:) & (shortTS_only(:) >= cl) & shortCoverage(:))/sum(fatlas(a).smallmask110(:)&shortCoverage(:));
                    nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalThalamoStriatalOverlap(ind, cl) = sum(fatlas(a).smallmask110(:) & (shortTCTS_convergence(:) >= cl) & shortCoverage(:))/sum(fatlas(a).smallmask110(:)&shortCoverage(:));
                end
                p = p+1;
            end
        end
    end
    
        
    % Now make a composite map for the individual confidence levels (AIBS, Pax, and average)
    gg = 1; 
    for g = 1:4  %length(thalCtx_StriatalConvergenceOrigins)
%         if sum(ismember(projAreas_withThalamocorticalMaps, injGroup_data(g).cortical_group)) > 0
           nuclearOrigins_clusterCompositeMaps.nuclei = nuclearOrigins_clusterThalCtxConvergence(g).nucleusNames;
    %         for p = 1:32
                for cl = 1:6
                    nuclearOrigins_clusterCompositeMaps.Pax_TC_TS_both(cl).area(gg).coverage(:, 1) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalOnly(:, cl);
                    nuclearOrigins_clusterCompositeMaps.Pax_TC_TS_both(cl).area(gg).coverage(:, 2) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoStriatalOnly(:, cl);
                    nuclearOrigins_clusterCompositeMaps.Pax_TC_TS_both(cl).area(gg).coverage(:, 3) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalThalamoStriatalOverlap(:, cl);
                    nuclearOrigins_clusterCompositeMaps.Pax_TC_TS_both(cl).all_TC.coverage(:, gg) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalOnly(:, cl);
                    nuclearOrigins_clusterCompositeMaps.Pax_TC_TS_both(cl).all_TS.coverage(:, gg) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoStriatalOnly(:, cl);
                    nuclearOrigins_clusterCompositeMaps.Pax_TC_TS_both(cl).all_TCTSoverlap.coverage(:, gg) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalThalamoStriatalOverlap(:, cl);

                    nuclearOrigins_clusterCompositeMaps.AIBS_TC_TS_both(cl).area(gg).coverage(:, 1) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalOnly(:, cl);
                    nuclearOrigins_clusterCompositeMaps.AIBS_TC_TS_both(cl).area(gg).coverage(:, 2) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoStriatalOnly(:, cl);
                    nuclearOrigins_clusterCompositeMaps.AIBS_TC_TS_both(cl).area(gg).coverage(:, 3) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalThalamoStriatalOverlap(:, cl);
                    nuclearOrigins_clusterCompositeMaps.AIBS_TC_TS_both(cl).all_TC.coverage(:, gg) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalOnly(:, cl);
                    nuclearOrigins_clusterCompositeMaps.AIBS_TC_TS_both(cl).all_TS.coverage(:, gg) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoStriatalOnly(:, cl);
                    nuclearOrigins_clusterCompositeMaps.AIBS_TC_TS_both(cl).all_TCTSoverlap.coverage(:, gg) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalThalamoStriatalOverlap(:, cl);

                    nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(cl).area(gg).coverage(:, 1) = mean([nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalOnly(:, cl), nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalOnly(:, cl)], 2);
                    nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(cl).area(gg).coverage(:, 2) = mean([nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoStriatalOnly(:, cl), nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoStriatalOnly(:, cl)], 2);
                    nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(cl).area(gg).coverage(:, 3) = mean([nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalThalamoStriatalOverlap(:, cl), nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalThalamoStriatalOverlap(:, cl)], 2);
                    nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(cl).all_TC.coverage(:, gg) = mean([nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalOnly(:, cl), nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalOnly(:, cl)], 2);
                    nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(cl).all_TS.coverage(:, gg) = mean([nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoStriatalOnly(:, cl), nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoStriatalOnly(:, cl)], 2);
                    nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(cl).all_TCTSoverlap.coverage(:, gg) = mean([nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalThalamoStriatalOverlap(:, cl), nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalThalamoStriatalOverlap(:, cl)], 2);

                end
    %         end
            nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(gg).coverage(:, 1) = mean([nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(1).area(gg).coverage(:, 1), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(3).area(gg).coverage(:, 1), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(5).area(gg).coverage(:, 1)], 2);
            nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(gg).coverage(:, 2) = mean([nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(1).area(gg).coverage(:, 2), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(3).area(gg).coverage(:, 2), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(5).area(gg).coverage(:, 2)], 2);
            nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(gg).coverage(:, 3) = mean([nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(1).area(gg).coverage(:, 3), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(3).area(gg).coverage(:, 3), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(5).area(gg).coverage(:, 3)], 2);
            nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.all_TC.coverage(:, gg) = mean([nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(1).area(gg).coverage(:, 1), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(3).area(gg).coverage(:, 1), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(5).area(gg).coverage(:, 1)], 2);
            nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.all_TS.coverage(:, gg) = mean([nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(1).area(gg).coverage(:, 2), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(3).area(gg).coverage(:, 2), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(5).area(gg).coverage(:, 2)], 2);
            nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.all_TCTSoverlap.coverage(:, gg) = mean([nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(1).area(gg).coverage(:, 3), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(3).area(gg).coverage(:, 3), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(5).area(gg).coverage(:, 3)], 2);

            nuclearOrigins_clusterCompositeMaps.nuclearGroupOrder = [1,2,3,6,7,14,15,18,19,11,8,21,13,4,5,12,16,22,23,24,25,9,10,20,17]; % for {'AD','AM','AV','CL','CM','IAD','IAM','IMD','LD','LP','MD','PCN','PR','PT','PVT','Pf','Po','RE','RH','RT_short','SMT','VAL','VM','VPL','VPM'}
            gg = gg+1;
%         end
    end
    
    %%%%%%% Something really wrong with this... using the sum of TC-TS-Overlap and TC-only instead
    % Add TC_full to the above analysis: a field to quantify the coverage of nuclei from thal-cortical areas grouped by the clusters they project to (this is different than TC_only which is the fraction of nuclei that project to ONLY cortical areas and DON'T converge in the striatum) 
    %     for g = 1:4  %length(thalCtx_StriatalConvergenceOrigins)
%         thalCtxMap = logical(thalCtx_ClusterConvergenceOrigins(g).correspondingThalamoCorticalConfidenceMap); 
%         for p = 1:32
%              if sum(ismember(nucleiToPlot, fatlas(p).name)) > 0
%                 ind = find(strcmp(nucleiToPlot, fatlas(p).name));
%                 shortTC_full = thalCtxMap(:, :, 1:64).*double(thalCtx_ClusterConvergenceOrigins(g).correspondingThalamoCorticalConfidenceMap(:, :, 1:64));
%                 shortCoverage = coverage(:, :, 1:64);
%                 for cl = 1:6
%                     nuclearOrigins_clusterThalCtxConvergence(g).nucleusNames{ind} = fatlas(p).name; 
%                     nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalFull(ind, cl) = sum(fatlas(p).smallmask110(:) & (shortTC_full(:) >= (cl+2)) & shortCoverage(:)) / sum(fatlas(p).smallmask110(:) & shortCoverage(:)); %We used thresholds of 3, 5, and 7 for thalamocortical and it has a max of 8 istead of 6, so I am adding 2
%                 end
%              end
%         end
%         p = 1;
%         for a = 33:64
%             if sum(ismember(nucleiToPlot, fatlas(a).name)) > 0
%                 ind = find(strcmp(nucleiToPlot, fatlas(a).name));
%                 shortTC_full = thalCtxMap(:, :, 1:65).*double(thalCtx_ClusterConvergenceOrigins(g).correspondingThalamoCorticalConfidenceMap(:, :, 1:65));
%                 shortCoverage = coverage(:, :, 1:65);
%                 for cl = 1:6
%                     nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalFull(ind, cl) = sum(fatlas(a).smallmask110(:) & (shortTC_full(:) >= (cl+2)) & shortCoverage(:)) / sum(fatlas(a).smallmask110(:) & shortCoverage(:));
%                 end
%                 p = p+1;
%             end
%         end
%     end
%     gg = 1; 
%     for g = 1:4  %length(thalCtx_StriatalConvergenceOrigins)
%         nuclearOrigins_clusterCompositeMaps.nuclei = nuclearOrigins_clusterThalCtxConvergence(g).nucleusNames;
%         for cl = 1:6
%             nuclearOrigins_clusterCompositeMaps.Pax_TC_TS_both(cl).area(gg).coverage(:, 4) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalFull(:, cl);
%             nuclearOrigins_clusterCompositeMaps.AIBS_TC_TS_both(cl).area(gg).coverage(:, 4) = nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalFull(:, cl);
%             nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(cl).area(gg).coverage(:, 4) = mean([nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_AIBS_thalamoCorticalFull(:, cl), nuclearOrigins_clusterThalCtxConvergence(g).fractionOccupied_Pax_thalamoCorticalOnly(:, cl)], 2);
%         end
%         nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(gg).coverage(:, 4) = mean([nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(1).area(gg).coverage(:, 4), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(3).area(gg).coverage(:, 4), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(5).area(gg).coverage(:, 4)], 2);
%         nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.full_TC.coverage(:, gg) = mean([nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(1).area(gg).coverage(:, 4), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(3).area(gg).coverage(:, 4), nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both(5).area(gg).coverage(:, 4)], 2);
%         gg = gg+1;
%     end
    

    %Images of the thalamocortical only, thalamostriatal only, and thalamic origin overlap (FIGURE)
    for g = 1:length(nuclearOrigins_clusterCompositeMaps.groups)
        %Just overlap white
        fig = figure;
        set(fig, 'Position', [1795 210 128 896])
        oneColumn = nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(g).coverage(:, 3); 
        imagesc(oneColumn(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :)) % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16
        axis image
        title([nuclearOrigins_clusterCompositeMaps.groups(g), ': Overlap'])
        caxis([0 1])
        colormap(cmap_white)
        set(gca, 'YTick', 1:length(nuclearOrigins_clusterCompositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_clusterCompositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder)) % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16
        set(gca, 'XTick', 1)
        set(gca, 'XTickLabel', {'TCTSoverlap'});
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_Overlap_cluster_',num2str(g), '.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_Overlap_cluster_',num2str(g), '.eps'], '-depsc2');
        close(fig)

        %Just TS magenta
        fig = figure;
        set(fig, 'Position', [1795 210 128 896])
        oneColumn = nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(g).coverage(:, 2); 
        imagesc(oneColumn(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :)) % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16
        title([nuclearOrigins_clusterCompositeMaps.groups(g), ': Thalamostriatal'])
        axis image
        caxis([0 1])
        colormap(cmap_magenta)
        set(gca, 'YTick', 1:length(nuclearOrigins_clusterCompositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_clusterCompositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder)) % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16
        set(gca, 'XTick', 1)
        set(gca, 'XTickLabel', {'TS'});
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_TS_cluster_',num2str(g), '.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_TS_cluster_',num2str(g), '.eps'], '-depsc2');
        close(fig)

        %Just TC cyan
        fig = figure;
        set(fig, 'Position', [1795 210 128 896])
        oneColumn = nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(g).coverage(:, 1);
        imagesc(oneColumn(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :)) % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16
        title([nuclearOrigins_clusterCompositeMaps.groups(g), ': Thalamocortical'])
        axis image
        caxis([0 1])
        colormap(cmap_cyan)
        set(gca, 'YTick', 1:length(nuclearOrigins_clusterCompositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_clusterCompositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder)) % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16
        set(gca, 'XTick', 1)
        set(gca, 'XTickLabel', {'TC'});
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_TC_cluster_',num2str(g), '.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_TC_cluster_',num2str(g), '.eps'], '-depsc2');
        close(fig)

        %all 3 white
        fig = figure;
        set(fig, 'Position', [1753 210 167 896])
        imagesc(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(g).coverage(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :)) % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16
        title([nuclearOrigins_clusterCompositeMaps.groups(g), ': thalamocortical, thalamostriatal, & dual projection origins: average nuclear coverage & Average of Levels 1/3/5'])
        axis image
        caxis([0 1])
        colormap(cmap)
        set(gca, 'YTick', 1:length(nuclearOrigins_clusterCompositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_clusterCompositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder)) % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16
        set(gca, 'XTick', 1:3)
        set(gca, 'XTickLabel', {'TC', 'TS', 'TCTSoverlap'});
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_all_cluster_',num2str(g), '.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_all_cluster_',num2str(g), '.eps'], '-depsc2');
        close(fig)
        
        %TC Full white
        fig = figure;
        set(fig, 'Position', [1795 210 128 896])
        oneColumn = (nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(g).coverage(:, 1) + nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.area(g).coverage(:, 3)); % sum of TC-TS-Overlap and TC-only to get all TC data. 
        imagesc(oneColumn(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :)) % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16
        title([nuclearOrigins_clusterCompositeMaps.groups(g), ': Thalamocortical'])
        axis image
        caxis([0 1])
        colormap(cmap_white)
        set(gca, 'YTick', 1:length(nuclearOrigins_clusterCompositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_clusterCompositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder)) % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16
        set(gca, 'XTick', 1)
        set(gca, 'XTickLabel', {'TC'});
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_TCfull_cluster_',num2str(g), '.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/TS_TC_TSTCoverlap_TCfull_cluster_',num2str(g), '.eps'], '-depsc2');
        close(fig)
    end
   

    % ***** Adding in another of the plot above for corticothalamic data *****
    % (this data was created at the bottom of jh_consolidatingAIBS_forGephi.m and originally from GetDensityDataFromWeb.py)
    % I put the data in injGroup_data.mat inder the field injGroup_data(g).nuclearProjections(n) : where n are the 25 nuclei we're looking at: IMD,MD,RH,CM,PR,SMT,PF,LP,PCN,CL,IAM,PVT,PT,RE,IAD,AM,AD,LD,PO,VAL,VM,VPM,AV,RT,VPL
    corticalGroup = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'SS', 'Vis', 'SUB_HIPP', 'Amyg', 'SNr', 'na'};
    projAreas_toKeep = corticalGroup(~ismember(corticalGroup,{'SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'na', 'SNr'}));  % I manually added in sub to get the nucleus coverage then removed again. 

    
    thalCtx_ClusterConvergenceOrigins(1).domainHomolog = {'ventral'};
    thalCtx_ClusterConvergenceOrigins(2).domainHomolog = {'posterior'};
    thalCtx_ClusterConvergenceOrigins(3).domainHomolog = {'dorsolateral'};
    thalCtx_ClusterConvergenceOrigins(4).domainHomolog = {'dorsomedial'};
    
    thalCtx_ClusterConvergenceOrigins(1).primaryCtxConvergence = {'AI_GU_VISC', 'IL', 'PL_MO', 'SUB_HIPP'};
    thalCtx_ClusterConvergenceOrigins(2).primaryCtxConvergence = {'AUD', 'ECT_PERI_TE', 'Vis'};
    thalCtx_ClusterConvergenceOrigins(3).primaryCtxConvergence = {'AI_GU_VISC', 'FRA', 'MOp', 'SS'};
    thalCtx_ClusterConvergenceOrigins(4).primaryCtxConvergence = {'ACA', 'ORBl', 'PL_MO', 'PTL', 'RSP', 'Vis'};
    
    for c = 1:4
        for n = 1:length(injGroup_data(g).nuclearProjections) %Generate the max values for the projections
            maxCT_toNucleus = 0;
            for g = 1: length(injGroup_data)
                if sum(ismember(thalCtx_ClusterConvergenceOrigins(c).primaryCtxConvergence, injGroup_data(g).cortical_group)) > 0
                    
                    maxCT_toNucleus = max(maxCT_toNucleus, max(injGroup_data(g).nuclearProjections(n).projDensity));
                    
                end
            end
            oneColumn(n) = maxCT_toNucleus; 
        end
%         %Generate the max values for the projections
%         for n = 1:length(injGroup_data(g).nuclearProjections)
%             oneColumn(n) = max(injGroup_data(g).nuclearProjections(n).projDensity); 
%         end
        %Plot max density of Corticothalamic proj to each nucleus in green
        fig = figure;
        set(fig, 'Position', [1795 210 128 896])
        imagesc(oneColumn) % Already in the cortically clustered order (should start with IMD)
        axis image
        title([thalCtx_ClusterConvergenceOrigins(c).domainHomolog, ': CT'])
        caxis([0 0.6])
        colormap(cmap_green)
        set(gca, 'YTick', 1:length(nuclearOrigins_clusterCompositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_clusterCompositeMaps.nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder)) % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16
        set(gca, 'XTick', 1)
        set(gca, 'XTickLabel', {'CT'});
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/CT_Overlap_cluster_',num2str(c), '.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/CT_Overlap_cluster_',num2str(c), '.eps'], '-depsc2');
        close(fig)
    end



    % SKIPPED THIS FOR CLUSTERS (FOR NOW): now a horozontal stacked bar plot
    for g = 14 %:length(nuclearOrigins_clusterCompositeMaps.groups)
        fig = figure;
        set(fig, 'Position', [1715 267 205 839])
    %     level0 =
    %     nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(6).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g); % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16
        level1 = nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(1).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g) - nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(3).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g);
        level3 = nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(3).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g) - nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(5).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g);
        level5 = nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(5).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g); % - nuclearOrigins_clusterCompositeMaps.average_PaxAIBS(6).coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g);

        barh([level5, level3 level1], 'stacked')
        hold on
        plot(nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_averageOfLevels135.coverage(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2), g), 1:length(nuclearOrigins_clusterCompositeMaps.nuclei), 'c-') % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16

        title([nuclearOrigins_clusterCompositeMaps.groups(g), ': thalamocortical, thalamostriatal, & dual projection origins: average nuclear coverage & Average of Levels 1/3/5'])
        colormap(cmap_barLevels)
        set(gca, 'YTick', 1:length(nuclearOrigins_clusterCompositeMaps.nuclei))
        set(gca, 'YTickLabel', nuclearOrigins_clusterCompositeMaps.nuclei(flipdim(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, 2))) % Using the .nucleusOrder from the subregion clustering (nuclearOrigins_compositeMaps) for figure consistency 10/4/16
    %     set(gca, 'XTick', 1:3)
        legend({'5', '3', '1'});
        set(fig,'PaperPositionMode','auto')
        saveas(fig, [saveDir, 'nuclearCoverage/nuclearCoverageLevels123_BAR_cluster_',num2str(g), '.fig'], 'fig');
        print(fig, [saveDir, 'nuclearCoverage/nuclearCoverageLevels123_BAR_cluster_',num2str(g), '.eps'], '-depsc2');
        close(fig)
    end
end



