function jh_corticostriatalFigures(figFlag, saveFlag)
% [vargout] = JH_CORTICOSTRIATALFIGURES(figFlag, saveFlag) 
% 
% INPUTS: figFlag (1 to 10) indicating which figure you would like to generate
%           (See 'FIGURE SECTIONS' below)
%         saveFlag (0 or 1) do you want to save all the outputs from this (including tiffs)
%           (Using saveFlag == 2 to just save a test section)
% OUTPUT: Select Figures
% 
% PURPOSE: This will take the output from jh_consolidatingAIBSdatasets.m and generate a bunch of figures. 
% 
% DEPENDENCIES: 
%     /auxillary_funcitonsAndScripts/h_getNucleusOutline.m
% 
%
% FIGURE SECTIONS: **(+)'s are currently in a paper or thesis figure, (-)'s are not**
% 1. (-): Corticostriatal maximum intensity projections (for overview/evaluation)
% 2. (+): Generate coronal slices through the brain for all cortical subregions
% 3. (-): The outline of the diffuse projection volume for each cortical area
% 4. (-): All injection site outlines for each cortical region on the template brain
% 5. (+): Generate coronal slices through the brain for different types of cortex: allo-meso-neo 
% 6. (+): Generate coronal slices for injections grouped in the A-P and M-L axes
% 7. (+): Generate coronal slices for Hot-Spot corticostriatal convergence figure
% 8. (+): Generate histograms for the A-P, D-V, M-L distribution the projection fields of cortical groups 
%         ** 8+ - 8+++ => more histograms for Allo-Meso-Neo / A-P & M-L / Hot-Spot projections
% 9. (+): Generate one clustered convergence plot for all corticostriatal convergence
% 10.(-): Generate one clustered convergence plot for allo-meso-neo



% Load initial datasets %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Where is the data folder (python output)?')
% likely here: '/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/data3'
targetDir= uigetdir('/', 'Where is the data folder (python output)?'); % MATLAB 2016 stopped showing the window titles so its hard to know what to look for, so I added console display above.
cd(targetDir)

cd ../analyzed4
anaDir = cd; 
% Random Manual masks that need to be collected for this to work:
disp('Where are the collected masks?')
randomMasksDir = uigetdir(targetDir, 'Where are the collected masks?');
% strmask_ic_submask.mat
% averageTemplate100um_rotated.mat
% averageTemplate100umACA_rotated.mat
% AIBS_100um.mat

%Some things to load first if I'm not going to redo it all:
load([anaDir, '/data_pImport.mat']) % Import variable from jh_pImport2matlab.m: data  %% Just used to get fNames then deleted
load([randomMasksDir, '/averageTemplate100umACA_rotated.mat']) % Import averageTemplate100umACA_rotated
load([randomMasksDir, '/averageTemplate100um_rotated.mat']) % Import variable from jh_pImport2matlab.m: averageTemplate100um_rotated
load([randomMasksDir, '/strmask_ic_submask.mat']) %I made a mask that removes the internal capsule
load([randomMasksDir, '/AIBS_100um.mat'])  %this was made later, but can replace a lot of missing things if needed
ic_submask = submask;

% Data generated in jh_consolidatingAIBSdatasets.m
load([anaDir, '/injGroup_data.mat']) 
load([anaDir, '/inj_data.mat'])
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Remove me!!!  
% load([anaDir, '/injGroup_data_noSubmask.mat']) 
% load([anaDir, '/inj_data_noSubmask.mat'])
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Remove me!!!


% Load a single rotatedData.mat dataset initially to access some descripting metadata
EID = injGroup_data(1).expID(1);
cd([targetDir, '/', num2str(EID)])
load('rotatedData.mat');

%
group = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'SS', 'Vis', 'SUB_HIPP', 'Amyg', 'SNr', 'na'};
fNames=fields(data);
clear data

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Remove me!!! (For a supplementary figure about bundle subtraction) 
% cd(anaDir)
% mkdir([anaDir, '/noSubmask/'])
% pwd
% cd([anaDir, '/noSubmask/'])
% pwd
% anaDir = cd; 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Remove me!!!


%% 1. This will plot the ipsilateral and contralateral summed coronal, sagital and longitudinal view of each threshold (for an overview of the data)
% Figure not used, but variables at the begining are used later
if figFlag == 1
    % The striatum and whole brain colapsed to 2 dimensions
    b1 = squeeze(sum(averageTemplate100um, 1))>500;
    s1 = squeeze(sum((rotatedData.striatum3d.L.mask+rotatedData.striatum3d.R.mask), 1))>0.5;
    b2 = squeeze(sum(averageTemplate100um, 2))>500;
    s2 = squeeze(sum((rotatedData.striatum3d.L.mask+rotatedData.striatum3d.R.mask), 2))>0.5; 
    b3 = squeeze(sum(averageTemplate100um, 3))>500;
    s3 = squeeze(sum((rotatedData.striatum3d.L.mask+rotatedData.striatum3d.R.mask), 3))>0.5; 
    %Outlines of Striatum & brain
    so1 = h_getNucleusOutline(s1(:, :));
    so2 = h_getNucleusOutline(s2(:, :));
    so3 = h_getNucleusOutline(s3(:, :));
    bo1 = h_getNucleusOutline(b1(:, :));
    bo2 = h_getNucleusOutline(b2(:, :));
    bo3 = h_getNucleusOutline(b3(:, :));

    % set(gca,'YDir','reverse');

    % targetDir='/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3';
    cd(anaDir)

    for g = 1:length(group)
        fig = figure;
        for i = 1:15
                subplot(5, 3, i)
                if i == 1
                    imagesc(squeeze(sum(injGroup_data(g).mask1.ipsilateral, 1)+sum(injGroup_data(g).mask1.contralateral, 1)))
                    title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(1))])
                    set(fig, 'Position', [0 0 1000 1000])
                    caxis([0 30])
                    ylabel('M-L')
                    xlabel('A-P')
                    hold on
                    for j = 1:length(so1)
                    plot((so1{j}(:,2)), (so1{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    for j = 1:length(bo1)
                    plot((bo1{j}(:,2)), (bo1{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    hold off
                    axis image
                elseif i == 2
                    imagesc(squeeze(sum(injGroup_data(g).mask1.ipsilateral, 2)+sum(injGroup_data(g).mask1.contralateral, 2)))
                    title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(1))])
                    set(fig, 'Position', [0 0 1000 1000])
                    caxis([0 30])
                    ylabel('D-V')
                    xlabel('A-P')
                    hold on
                    for j = 1:length(so2)
                    plot((so2{j}(:,2)), (so2{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    for j = 1:length(bo2)
                    plot((bo2{j}(:,2)), (bo2{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    hold off
                    axis image
                elseif i == 3
                    imagesc(squeeze(sum(injGroup_data(g).mask1.ipsilateral, 3)+sum(injGroup_data(g).mask1.contralateral, 3)))
                    title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(1))])
                    set(fig, 'Position', [0 0 1000 1000])
                    caxis([0 30])
                    ylabel('D-V')
                    xlabel('M-L')
                    hold on
                    for j = 1:length(so3)
                    plot((so3{j}(:,2)), (so3{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    for j = 1:length(bo2)
                    plot((bo3{j}(:,2)), (bo3{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    hold off
                    axis image
                elseif i == 4
                    imagesc(squeeze(sum(injGroup_data(g).mask2.ipsilateral, 1)+sum(injGroup_data(g).mask2.contralateral, 1)))
                    title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(2))])
                    set(fig, 'Position', [0 0 1000 1000])
                    caxis([0 30])
                    ylabel('M-L')
                    xlabel('A-P')
                    hold on
                    for j = 1:length(so1)
                    plot((so1{j}(:,2)), (so1{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    for j = 1:length(bo1)
                    plot((bo1{j}(:,2)), (bo1{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    hold off
                    axis image
                elseif i == 5
                    imagesc(squeeze(sum(injGroup_data(g).mask2.ipsilateral, 2)+sum(injGroup_data(g).mask2.contralateral, 2)))
                    title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(2))])
                    set(fig, 'Position', [0 0 1000 1000])
                    caxis([0 30])
                    ylabel('D-V')
                    xlabel('A-P')
                    hold on
                    for j = 1:length(so2)
                    plot((so2{j}(:,2)), (so2{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    for j = 1:length(bo2)
                    plot((bo2{j}(:,2)), (bo2{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    hold off
                    axis image
                elseif i == 6
                    imagesc(squeeze(sum(injGroup_data(g).mask2.ipsilateral, 3)+sum(injGroup_data(g).mask2.contralateral, 3)))
                    title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(2))])
                    set(fig, 'Position', [0 0 1000 1000])
                    caxis([0 30])
                    ylabel('D-V')
                    xlabel('M-L')
                    hold on
                    for j = 1:length(so3)
                    plot((so3{j}(:,2)), (so3{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    for j = 1:length(bo2)
                    plot((bo3{j}(:,2)), (bo3{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    hold off
                    axis image
                elseif i == 7
                    imagesc(squeeze(sum(injGroup_data(g).mask3.ipsilateral, 1)+sum(injGroup_data(g).mask3.contralateral, 1)))
                    title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(3))])
                    set(fig, 'Position', [0 0 1000 1000])
                    caxis([0 30])
                    ylabel('M-L')
                    xlabel('A-P')
                    hold on
                    for j = 1:length(so1)
                    plot((so1{j}(:,2)), (so1{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    for j = 1:length(bo1)
                    plot((bo1{j}(:,2)), (bo1{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    hold off
                    axis image
                elseif i == 8
                    imagesc(squeeze(sum(injGroup_data(g).mask3.ipsilateral, 2)+sum(injGroup_data(g).mask3.contralateral, 2)))
                    title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(3))])
                    set(fig, 'Position', [0 0 1000 1000])
                    caxis([0 30])
                    ylabel('D-V')
                    xlabel('A-P')
                    hold on
                    for j = 1:length(so2)
                    plot((so2{j}(:,2)), (so2{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    for j = 1:length(bo2)
                    plot((bo2{j}(:,2)), (bo2{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    hold off
                    axis image
                elseif i == 9
                    imagesc(squeeze(sum(injGroup_data(g).mask3.ipsilateral, 3)+sum(injGroup_data(g).mask3.contralateral, 3)))
                    title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(3))])
                    set(fig, 'Position', [0 0 1000 1000])
                    caxis([0 30])
                    ylabel('D-V')
                    xlabel('M-L')
                    hold on
                    for j = 1:length(so3)
                    plot((so3{j}(:,2)), (so3{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    for j = 1:length(bo2)
                    plot((bo3{j}(:,2)), (bo3{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    hold off
                    axis image
                elseif i == 10
                    imagesc(squeeze(sum(injGroup_data(g).mask4.ipsilateral, 1)+sum(injGroup_data(g).mask4.contralateral, 1)))
                    title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(4))])
                    set(fig, 'Position', [0 0 1000 1000])
                    caxis([0 30])
                    ylabel('M-L')
                    xlabel('A-P')
                    hold on
                    for j = 1:length(so1)
                    plot((so1{j}(:,2)), (so1{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    for j = 1:length(bo1)
                    plot((bo1{j}(:,2)), (bo1{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    hold off
                    axis image
                elseif i == 11
                    imagesc(squeeze(sum(injGroup_data(g).mask4.ipsilateral, 2)+sum(injGroup_data(g).mask4.contralateral, 2)))
                    title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(4))])
                    set(fig, 'Position', [0 0 1000 1000])
                    caxis([0 30])
                    ylabel('D-V')
                    xlabel('A-P')
                    hold on
                    for j = 1:length(so2)
                    plot((so2{j}(:,2)), (so2{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    for j = 1:length(bo2)
                    plot((bo2{j}(:,2)), (bo2{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    hold off
                    axis image
                elseif i == 12
                    imagesc(squeeze(sum(injGroup_data(g).mask4.ipsilateral, 3)+sum(injGroup_data(g).mask4.contralateral, 3)))
                    title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(4))])
                    set(fig, 'Position', [0 0 1000 1000])
                    caxis([0 30])
                    ylabel('D-V')
                    xlabel('M-L')
                    hold on
                    for j = 1:length(so3)
                    plot((so3{j}(:,2)), (so3{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    for j = 1:length(bo2)
                    plot((bo3{j}(:,2)), (bo3{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    hold off
                    axis image
                elseif i == 13
                    imagesc(squeeze(sum(injGroup_data(g).mask5.ipsilateral, 1)+sum(injGroup_data(g).mask5.contralateral, 1)))
                    title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(5))])
                    set(fig, 'Position', [0 0 1000 1000])
                    caxis([0 30])
                    ylabel('M-L')
                    xlabel('A-P')
                    hold on
                    for j = 1:length(so1)
                    plot((so1{j}(:,2)), (so1{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    for j = 1:length(bo1)
                    plot((bo1{j}(:,2)), (bo1{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    hold off
                    axis image
                elseif i == 14
                    imagesc(squeeze(sum(injGroup_data(g).mask5.ipsilateral, 2)+sum(injGroup_data(g).mask5.contralateral, 2)))
                    title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(5))])
                    set(fig, 'Position', [0 0 1000 1000])
                    caxis([0 30])
                    ylabel('D-V')
                    xlabel('A-P')
                    hold on
                    for j = 1:length(so2)
                    plot((so2{j}(:,2)), (so2{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    for j = 1:length(bo2)
                    plot((bo2{j}(:,2)), (bo2{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    hold off
                    axis image
                elseif i == 15
                    imagesc(squeeze(sum(injGroup_data(g).mask5.ipsilateral, 3)+sum(injGroup_data(g).mask5.contralateral, 3)))
                    title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(5))])
                    set(fig, 'Position', [0 0 1000 1000])
                    caxis([0 30])
                    ylabel('D-V')
                    xlabel('M-L')
                    hold on
                    for j = 1:length(so3)
                    plot((so3{j}(:,2)), (so3{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    for j = 1:length(bo2)
                    plot((bo3{j}(:,2)), (bo3{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    hold off
                    axis image
                end 
                set(gca, 'FontSize', 6);
        end
        if saveFlag == 1
            saveas(fig, ['corticalProjections/collapsedThresholds/groupThresholdTest_',injGroup_data(g).cortical_group,'.fig'], 'fig');
            print(fig, ['corticalProjections/collapsedThresholds/groupThresholdTest_',injGroup_data(g).cortical_group,'.eps'], '-depsc2');
            close(fig)
        end
    end
    
end

%% 2. Then this will create the 3-level images and plot coronal sections through the striatum like the clustering does (FIGURE: corticostriatal projections)

if figFlag == 2
    confidenceLevels = 3;
    
    % Now waiting until right before clustering to downsample 
    %%%%% Getting, and downsampling the traces ACA mask   **** THis is now saved as AIBS_100um.aca
    % load('/Users/jeaninehunnicutt/Dropbox/anatomy/Striatum/ABA_average_brain/str/acamask_25um.mat') %Loads as strmask and is 320x456x176 with 25um voxels
    % acamask = double(acamask);
    % [x, y, z]= meshgrid(1:456, 1:320, 1:176);
    % [xi, yi, zi] = meshgrid(1:4:456, 1:4:320, 1:4:176); %100x100x100um voxels
    % downsampledACAMask = round(interp3(x, y,z, acamask, xi, yi, zi));  % added 'round' here to put data back to initial space.  
    % averageTemplateACA = false(size(averageTemplate100um));
    % averageTemplateACA(1:80, 1:114, 35:78) = downsampledACAMask;
    %%%%%%%%

    modelStriatum = (rotatedData.striatum3d.L.mask+rotatedData.striatum3d.R.mask).*~ic_submask;
    corticalGroup = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'SS', 'Vis', 'SUB_HIPP', 'Amyg', 'SNr', 'na'};

    % This determines the density threshold used throughout the remaining analysis steps!
    for i = 1:length(corticalGroup) %%%%%%%%%%%%%%%%%%%%%%%%%%%% Change this if you want to view different thresholds (Using 0.5%, 5% and 15% right now) %%%%%%%%%%%%%%%%%%%%%%%
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
    
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % targetDir = ('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/');
    cd(anaDir)

    % This is plotting sections of the individual groups (FIGURE)
    for g = 1:length(corticalGroup) 
        disp(['Done with ', corticalGroup(g), '...'])
        mkdir([anaDir, '/corticalProjections/slices/',injGroup_data(g).cortical_group])
        mkdir([anaDir, '/corticalProjections/data/',injGroup_data(g).cortical_group])
        for i = 35:78 %This is strstrt to strnd     %1:length(smallmodel);

        % This just makes the mask with the outline 
        %     fig = figure; h_imagesc(smallmodel(:,:,i));hold on
        %     for j = 1:length(outline)
        %         plot((outline{j}(:,2)), (outline{j}(:,1)), 'm-', 'linewidth',2);
        %         %new coordinate is: (x-(1+factor)/2)/factor+1=(x-0.5)/factor+1/2.
        %     end 
        %     saveas(fig, ['modelThalamus_slice',num2str(i),'.fig'], 'fig')
        %     print(fig, ['modelThalamus_slice',num2str(i), '.eps'], '-depsc2');
        %     close(fig)
            currentSlice = downsampledProjMask{g}(:,:,i);
            colorImg_r = zeros(size(currentSlice));
            colorImg_g = zeros(size(currentSlice));
            colorImg_b = zeros(size(currentSlice));
    %         cmap = [0 0 1; 0 1 0; 1 0 0];  % Makes the 1:blue, 2:green, and 3:red 
    %         cmap = [0 .25 0; 0 .5 0; 0 1 0];  % Makes a scale of green
            cmap = [.25 .25 .25; .5 .5 .5; 1 1 1];  % makes a grayscale 3 channel image

            for j = 1:max(downsampledProjMask{g}(:))
                BW = currentSlice==j;
                colorImg_r(BW) = cmap(j,1);
                colorImg_g(BW) = cmap(j,2);
                colorImg_b(BW) = cmap(j,3);
            end
            colorImg = cat(3,colorImg_r,colorImg_g,colorImg_b);
        %     fig = figure; h_imagesc(clusterMask2(:,:,i),[0,max(clusterMask2(:))]); colormap(cmap3);hold on
            fig = figure; h_imagesc(colorImg); hold on
            outline = h_getNucleusOutline(smallmodel(:,:,i));
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',1)
            end
            oAIBS = h_getNucleusOutline(logical(imfill(averageTemplate100um(:, :, i)>50, 'holes')));
            for j = 1:length(oAIBS)
                plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1))+0.5, 'w-', 'linewidth',1.25)
            end
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
                saveas(fig, ['corticalProjections/slices/', injGroup_data(g).cortical_group, '/summedCorticalGroup_',injGroup_data(g).cortical_group, '_slice',num2str(i),'.fig'], 'fig');
                print(fig, ['corticalProjections/slices/', injGroup_data(g).cortical_group, '/summedCorticalGroup_', injGroup_data(g).cortical_group, '_slice',num2str(i), '.eps'], '-depsc2');
                close(fig)
            end
%             close(fig)
        end
        
        if saveFlag == 2
        % ** Save .mat and .csv files of  downsampledProjMask{i} and smallmodel -- 2016 update
        %
            %%% Simple example of what I'm doing below
            %      d=reshape(1:2*3*2,[2,3,2]); % Get the matrix
            %      [ir,ic,ip]=ind2sub(size(d),1:numel(d));
            %      r =[ir.',ic.',ip.',d(:)];
            %      Which looks, as a csv, like: 1, 1, 1, 1(new line)2, 1, 1, 2(new line)1, 2, 1, 3(new line)2 2 1 4(new line)1, 3, 1, 5(new line)2, 3, 1, 6(new line)1, 1, 2, 7(new line)2, 1, 2, 8(new line)1, 2, 2, 9(new line)2, 2, 2, 10(new line)1, 3, 2, 11(new line)2, 3, 2, 12
        
%          Format of CSVs: [x_index, y_index, z_index, value] 
%               - where x = Dorsal->Ventral, y = Left->Right, z = Anterior->Posterior
            projMask_mat = downsampledProjMask{g}; % Get just the projection map for each cortical area
            [ir,ic,ip] = ind2sub(size(projMask_mat),1:numel(projMask_mat)); % Get the indices af all voxels
            projMask_csv = [ir.', ic.', ip.', projMask_mat(:)];   % Create a csv with the 3 indices of each voxel and it's value        
            
            csvwrite(['corticalProjections/data/', injGroup_data(g).cortical_group, '/summedCorticalGroup_',injGroup_data(g).cortical_group,'.csv'], projMask_csv) 
            save(['corticalProjections/data/', injGroup_data(g).cortical_group, '/summedCorticalGroup_',injGroup_data(g).cortical_group,'.mat'], 'projMask_mat')
%             dlmwrite(['corticalProjections/data/', injGroup_data(g).cortical_group, '/summedCorticalGroup_',injGroup_data(g).cortical_group,'.txt'], projMask_csv, ',')
            
        end
    end
end


%% 3. Plot just the outline of the diffuse projection volume for each cortical area on one image, color coded (unused FIGURE: playing_corticostraital.ai)
    % Can manually change mask & naming to get dense, etc. 

if figFlag == 3
    % targetDir='/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3';
    cd(anaDir)
    corticalGroup = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'SS', 'Vis', 'SUB_HIPP', 'Amyg', 'SNr', 'na'};
    regionsToUse = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SS', 'Vis', 'SUB_HIPP', 'Amyg'};


    mkdir('/corticalProjectionsSpecialGroups/diffuseOnly/05_percent/') 
    for i = 35:78 %This is strstrt to strnd     %1:length(smallmodel);

        img = zeros(81, 115);
        fig = figure; h_imagesc(img(:, :));
        colormap([0 0 0])
        hold on

        for g = 1:length(corticalGroup)
            if ismember(injGroup_data(g).cortical_group, regionsToUse)

                outline = h_getNucleusOutline(AIBS_100um.striatum.myMask.Full.mask(:,:,i).*~ic_submask(:, :, i));
                for j = 1:length(outline)
                    plot((outline{j}(:,2)), (outline{j}(:,1)), 'w-', 'linewidth',1)
                end
                oAIBS = h_getNucleusOutline(AIBS_100um.brain.mask(:, :, i));
                for j = 1:length(oAIBS)
                    plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1)), 'w-', 'linewidth',1.1)
                end
                oACA = h_getNucleusOutline(AIBS_100um.aca.mask(:,:,i));
                for j = 1:length(oACA)
                    plot((oACA{j}(:,2)), (oACA{j}(:,1)), 'w-', 'linewidth',0.5)
                end

                oProj = h_getNucleusOutline((injGroup_data(g).mask1.ipsilateral(:, :, i)+injGroup_data(g).mask1.contralateral(:, :, i)).*~ic_submask(:, :, i));
                for j = 1:length(oProj)
                    plot((oProj{j}(:,2)), (oProj{j}(:,1)), 'Color', injGroup_data(g).color, 'linewidth',0.5)
                end
            end
        end
        hold off
        
        if saveFlag == 1
            saveas(fig, ['corticalProjectionsSpecialGroups/diffuseOnly/05_percent/summedCorticalGroupOutlines_slice',num2str(i),'.fig'], 'fig');
            print(fig, ['corticalProjectionsSpecialGroups/diffuseOnly/05_percent/summedCorticalGroupOutlines_slice',num2str(i),'.eps'], '-depsc2');
            close(fig)
        end
    end
end


%% 4. plot all the injection sites color coded (unused FIGURE: Corticostriatal_injections.indd)

if figFlag == 4
    % COLORS:
    % S1/2 = lime green     [0.6 1 0]
    % M1 = yellow           [1 1 0]
    % ACC = dark orange     [1 0.4 0]
    % LO/VO = dark purple   [0.4 0 0.6]
    % AI/GI/DI = light blue [0 0.8 1]
    % ECT/Peri = mid blue   [0 0.4 0.6]
    % Aud = dark blue       [0 0.2 0.4]
    % MO/PrL = Maroon       [0.6 0 0]
    % IL = Red              [1 0 0]
    % FrA = light orange    [1 0.8 0]
    % Vis = green           [0.4 0.8 0]
    % PTL = tan             [0.8 0.8 0.6]
    % RS = Brown            [0.6 0.4 0]
    % Sub = dark brown      [0.4 0.2 0]
    % Amyg - light purple    [0.8 0.6 0.8]
    % * saved as injGroupColors and in inhGroupData

    for g = 1:length(injGroup_data)
         injGroup_data(g).color = injGroupColors{2, g};
    end



    % targetDir='/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/data3';
    cd(anaDir)
    mkdir('/corticalProjections/injections/')
    modelStriatum = (rotatedData.striatum3d.L.mask+rotatedData.striatum3d.R.mask).*~ic_submask;


    test = zeros(81, 115, 133);
    for g = 1:length(injGroup_data)
        injGroup_data(g).allInjectionMasks = zeros(81, 115, 133);
        for i = 1:length(injGroup_data(g).expID)
            injGroup_data(g).individualInjectionMasks(i).mask = zeros(81, 115, 133);
            EID = injGroup_data(g).expID(i);
            cd([targetDir, '/', num2str(EID)])
            load rotatedData.mat

            injGroup_data(g).allInjectionMasks = injGroup_data(g).allInjectionMasks + rotatedData.injection3d.mask;
            injGroup_data(g).individualInjectionMasks(i).mask = rotatedData.injection3d.mask;
            test = test + rotatedData.injection3d.mask;

        end
    end



    for g = 1:length(group) %plot each injection group separately
        fig = figure;
        for i = 1:3
                subplot(1, 3, i)
                if i == 1
                    imagesc(squeeze(sum(injGroup_data(g).allInjectionMasks, 1)))
                    title([injGroup_data(g).cortical_group, ' Injection Sites '])
                    set(fig, 'Position', [0 800 1200 300]); caxis([0 30]); ylabel('M-L'); xlabel('A-P'); hold on
                    for j = 1:length(so1)
                    plot((so1{j}(:,2)), (so1{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    for j = 1:length(bo1)
                    plot((bo1{j}(:,2)), (bo1{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    hold off
                    axis image
                elseif i == 2
                    imagesc(squeeze(sum(injGroup_data(g).allInjectionMasks, 2)))
                    title([injGroup_data(g).cortical_group, ' Injection Sites '])
                    set(fig, 'Position', [0 800 1200 300]); caxis([0 30]); ylabel('D-V'); xlabel('A-P'); hold on
                    for j = 1:length(so2)
                    plot((so2{j}(:,2)), (so2{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    for j = 1:length(bo2)
                    plot((bo2{j}(:,2)), (bo2{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    hold off
                    axis image
                elseif i == 3
                    imagesc(squeeze(sum(injGroup_data(g).allInjectionMasks, 3)))
                    title([injGroup_data(g).cortical_group, ' Injection Sites '])
                    set(fig, 'Position', [0 800 1200 300]); caxis([0 30]); ylabel('D-V'); xlabel('M-L'); hold on  % use: get(gcf, 'position') -->to find a position
                    for j = 1:length(so3)
                    plot((so3{j}(:,2)), (so3{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    for j = 1:length(bo2)
                    plot((bo3{j}(:,2)), (bo3{j}(:,1)), 'k-', 'linewidth',1)
                    end
                    hold off
                    axis image
                end
        end
    end


    fig = figure; %plot the sum of all the injections
    for i = 1:3
            subplot(1, 3, i)
            if i == 1
                imagesc(squeeze(sum(test, 1)))
                title([injGroup_data(g).cortical_group, ' Injection Sites '])
                set(fig, 'Position', [0 800 1200 300]); caxis([0 30]); ylabel('M-L'); xlabel('A-P'); hold on
                for j = 1:length(so1)
                plot((so1{j}(:,2)), (so1{j}(:,1)), 'k-', 'linewidth',1)
                end
                for j = 1:length(bo1)
                plot((bo1{j}(:,2)), (bo1{j}(:,1)), 'k-', 'linewidth',1)
                end
                hold off
                axis image
            elseif i == 2
                imagesc(squeeze(sum(test, 2)))
                title([injGroup_data(g).cortical_group, ' Injection Sites '])
                set(fig, 'Position', [0 800 1200 300]); caxis([0 30]); ylabel('D-V'); xlabel('A-P'); hold on
                for j = 1:length(so2)
                plot((so2{j}(:,2)), (so2{j}(:,1)), 'k-', 'linewidth',1)
                end
                for j = 1:length(bo2)
                plot((bo2{j}(:,2)), (bo2{j}(:,1)), 'k-', 'linewidth',1)
                end
                hold off
                axis image
            elseif i == 3
                imagesc(squeeze(sum(test, 3)))
                title([injGroup_data(g).cortical_group, ' Injection Sites '])
                set(fig, 'Position', [0 800 1200 300]); caxis([0 30]); ylabel('D-V'); xlabel('M-L'); hold on  % use: get(gcf, 'position') -->to find a position
                for j = 1:length(so3)
                plot((so3{j}(:,2)), (so3{j}(:,1)), 'k-', 'linewidth',1)
                end
                for j = 1:length(bo2)
                plot((bo3{j}(:,2)), (bo3{j}(:,1)), 'k-', 'linewidth',1)
                end
                hold off
                axis image
            end
    end


    %%%%%%%%% This will plot the color coded outlines of all injections (FIGURE)
    % targetDir='/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3';
    cd(anaDir)
    corticalGroup = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'SS', 'Vis', 'SUB_HIPP', 'Amyg', 'SNr', 'na'};


    mkdir('/corticalProjections/injections/slices/')
    for i = 1:length(smallmodel);

        img = zeros(81, 115);
        fig = figure; h_imagesc(img(:, :));
        colormap([0 0 0])
        hold on

        for g = 1:length(corticalGroup)
            outline = h_getNucleusOutline(modelStriatum(:,:,i));
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',1)
            end
            oAIBS = h_getNucleusOutline(logical(imfill(averageTemplate100um(:, :, i)>50, 'holes')));
            for j = 1:length(oAIBS)
                plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1))+0.5, 'w-', 'linewidth',1.1)
            end
            oACA = h_getNucleusOutline(averageTemplateACA(:,:,i));
            for j = 1:length(oACA)
                plot((oACA{j}(:,2)), (oACA{j}(:,1))+0.5, 'w-', 'linewidth',0.5)
            end
            for w = 1:length(injGroup_data(g).expID)
                oInj = h_getNucleusOutline(injGroup_data(g).individualInjectionMasks(w).mask(:, :, i));
                for j = 1:length(oInj)
                    plot((oInj{j}(:,2)), (oInj{j}(:,1))+0.5, 'Color', injGroup_data(g).color, 'linewidth',0.5)
                end
            end

        end
        hold off
        if saveFlag == 1
            saveas(fig, ['corticalProjections/injections/slices/summedInjections_slice',num2str(i),'.fig'], 'fig');
            print(fig, ['corticalProjections/injections/slices/summedInjections_slice',num2str(i), '.eps'], '-depsc2');
            close(fig)
        end
    end
end


%% 5. Plot sections for different types of cortex: allo-meso-neo (FIGURE for allo-meso-neo in thesis -- at least the 1st of the 3 sets of images)

if figFlag == 5
    corticalGroup = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'SS', 'Vis', 'SUB_HIPP', 'Amyg', 'SNr', 'na'};
    ctx(1).name = 'allocortex'; 
    ctx(1).regions = {'SUB_HIPP', 'Amyg'};
    ctx(2).name = 'mesocortex'; 
    ctx(2).regions = {'ACA','AI_GU_VISC','ECT_PERI_TE','IL','ORBl','PL_MO','RSP'};
    ctx(3).name = 'neocortex'; 
    ctx(3).regions = {'AUD','FRA','MOp','PTL','SS', 'Vis'};

    ctx(1).expID = []; ctx(2).expID = [];ctx(3).expID = [];
    a1 = zeros(81, 115, 133);
    a2 = a1; a3 = a1; m1 = a1; m2 = a1; m3 = a1; n1 = a1; n2 = a1; n3 = a1;
    %%%%%%%%%%%%%%%%%%%%%% Change this if you want to view different thresholds (Using 0.5%, 5% and 15% right now) %%%%%%%%%%%%%%%%%%%%%%%
    for i = 1:length(corticalGroup) 
        if sum(strcmp(corticalGroup(i), allocortex))>0
            a1 = logical(a1 + injGroup_data(i).mask1.ipsilateral + injGroup_data(i).mask1.contralateral);
            a2 = logical(a2 + injGroup_data(i).mask2.ipsilateral + injGroup_data(i).mask2.contralateral);
            a3 = logical(a3 + injGroup_data(i).mask5.ipsilateral + injGroup_data(i).mask5.contralateral);
            ctx(1).expID = cat(2, ctx(1).expID, injGroup_data(i).expID);
        elseif sum(strcmp(corticalGroup(i), mesocortex))>0
            m1 = logical(m1 + injGroup_data(i).mask1.ipsilateral + injGroup_data(i).mask1.contralateral);
            m2 = logical(m2 + injGroup_data(i).mask2.ipsilateral + injGroup_data(i).mask2.contralateral);
            m3 = logical(m3 + injGroup_data(i).mask5.ipsilateral + injGroup_data(i).mask5.contralateral);
            ctx(2).expID = cat(2, ctx(2).expID, injGroup_data(i).expID);
        elseif sum(strcmp(corticalGroup(i), neocortex))>0
            n1 = logical(n1 + injGroup_data(i).mask1.ipsilateral + injGroup_data(i).mask1.contralateral);
            n2 = logical(n2 + injGroup_data(i).mask2.ipsilateral + injGroup_data(i).mask2.contralateral);
            n3 = logical(n3 + injGroup_data(i).mask5.ipsilateral + injGroup_data(i).mask5.contralateral);
            ctx(3).expID = cat(2, ctx(3).expID, injGroup_data(i).expID);
        end
    end

    ctx(1).mask2alone = a2;
    ctx(2).mask2alone = m2;
    ctx(3).mask2alone = n2;
    ctx(1).mask3alone = a3;
    ctx(2).mask3alone = m3;
    ctx(3).mask3alone = n3;

    for c = 1:3           %This essentially determines the number of confidence levels used for clustering.
        if c == 1
            ctx(1).mask1 = a1;
            ctx(2).mask1 = m1;
            ctx(3).mask1 = n1;
        elseif c== 2;
            ctx(1).mask2 = a1 + a2;
            ctx(2).mask2 = m1 + m2;
            ctx(3).mask2 = n1 + n2; 
        elseif c == 3;
            ctx(1).mask3 = a1 + a2 + a3;
            ctx(2).mask3 = m1 + m2 + m3;
            ctx(3).mask3 = n1 + n2 + n3;
        end
    end

    smallmodel = modelStriatum;

    % ****

    % targetDir = ('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/');
    cd(anaDir)

    % This is plotting sections of the individual groups (FIGURE)
    for g = 1:length(ctx) 
        mkdir([anaDir, '/corticalProjectionsSpecialGroups/typesOfCortex/',ctx(g).name])
        for i = 35:78 %This is strstrt to strnd     %1:length(smallmodel);

        % This just makes the mask withe the outline 
        %     fig = figure; h_imagesc(smallmodel(:,:,i));hold on
        %     for j = 1:length(outline)
        %         plot((outline{j}(:,2)), (outline{j}(:,1)), 'm-', 'linewidth',2);
        %         %new coordinate is: (x-(1+factor)/2)/factor+1=(x-0.5)/factor+1/2.
        %     end 
        %     saveas(fig, ['modelThalamus_slice',num2str(i),'.fig'], 'fig')
        %     print(fig, ['modelThalamus_slice',num2str(i), '.eps'], '-depsc2');
        %     close(fig)
            currentSlice = ctx(g).mask3(:,:,i);
            colorImg_r = zeros(size(currentSlice));
            colorImg_g = zeros(size(currentSlice));
            colorImg_b = zeros(size(currentSlice));
    %         cmap = [0 0 1; 0 1 0; 1 0 0]; %Makes the 1:blue, 2:green, and 3:red 
    %         cmap = [0 .25 0; 0 .5 0; 0 1 0]; %Makes a scale of green
            cmap = [.25 .25 .25; .5 .5 .5; 1 1 1]; %makes a grayscale 3 channel image

            for j = 1:max(ctx(g).mask3(:))
                BW = currentSlice==j;
                colorImg_r(BW) = cmap(j,1);
                colorImg_g(BW) = cmap(j,2);
                colorImg_b(BW) = cmap(j,3);
            end
            colorImg = cat(3,colorImg_r,colorImg_g,colorImg_b);
        %     fig = figure; h_imagesc(clusterMask2(:,:,i),[0,max(clusterMask2(:))]); colormap(cmap3);hold on
            fig = figure; h_imagesc(colorImg); hold on
            outline = h_getNucleusOutline(smallmodel(:,:,i));
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',1)
            end
            oAIBS = h_getNucleusOutline(logical(imfill(averageTemplate100um(:, :, i)>50, 'holes')));
            for j = 1:length(oAIBS)
                plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1))+0.5, 'w-', 'linewidth',1.25)
            end
            oACA = h_getNucleusOutline(averageTemplateACA(:,:,i));
            for j = 1:length(oACA)
                plot((oACA{j}(:,2)), (oACA{j}(:,1))+0.5, 'w-', 'linewidth',0.5)
            end
            hold off

            if saveFlag == 1
                saveas(fig, ['corticalProjectionsSpecialGroups/typesOfCortex/',ctx(g).name, '/summedCorticalGroup_',ctx(g).name , '_slice',num2str(i),'.fig'], 'fig');
                print(fig, ['corticalProjectionsSpecialGroups/typesOfCortex/',ctx(g).name, '/summedCorticalGroup_',ctx(g).name , '_slice',num2str(i),'.eps'], '-depsc2');
                close(fig)
            end
        end
    end



    % This is plotting sections with outlines of each cortical projection in the individual groups (FIGURE)
    for g = 1:3
    mkdir([anaDir, '/corticalProjectionsSpecialGroups/typesOfCortex_outlines/',ctx(g).name])
    end
    for cc = 1:length(ctx)
        for i = 35:78 %This is strstrt to strnd     %1:length(smallmodel);

            img = zeros(81, 115);
            fig = figure; h_imagesc(img(:, :));
            colormap([0 0 0])
            hold on

            outline = h_getNucleusOutline(modelStriatum(:,:,i));
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',1)
            end
            oAIBS = h_getNucleusOutline(logical(imfill(averageTemplate100um(:, :, i)>50, 'holes')));
            for j = 1:length(oAIBS)
                plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1))+0.5, 'w-', 'linewidth',1.1)
            end
            oACA = h_getNucleusOutline(averageTemplateACA(:,:,i));
            for j = 1:length(oACA)
                plot((oACA{j}(:,2)), (oACA{j}(:,1))+0.5, 'w-', 'linewidth',0.5)
            end
            for r = 1:length(ctx(cc).regions) 
                for g = 1:length(corticalGroup)
                    if sum(strcmp(corticalGroup(g), ctx(cc).regions))>0
                        oProj = h_getNucleusOutline(injGroup_data(g).mask4.ipsilateral(:, :, i)+injGroup_data(g).mask4.contralateral(:, :, i));
                        for j = 1:length(oProj)
                            plot((oProj{j}(:,2)), (oProj{j}(:,1))+0.5, 'c-', 'linewidth',0.5)
                        end
                    end
                end

            end
            hold off
            
            if saveFlag == 1
                saveas(fig, ['corticalProjectionsSpecialGroups/typesOfCortex_outlines/',ctx(cc).name, '/summedCorticalGroup_',ctx(cc).name , '_slice',num2str(i),'.fig'], 'fig');
                print(fig, ['corticalProjectionsSpecialGroups/typesOfCortex_outlines/',ctx(cc).name, '/summedCorticalGroup_',ctx(cc).name , '_slice',num2str(i),'.eps'], '-depsc2');
                close(fig)
            end
        end
    end


    % This is plotting sections with outlines of the individual groups on the same slice (FIGURE)
    ctx(1).color = [0 0 1]; ctx(2).color = [1 1 0]; ctx(3).color = [1 0 0];

    mkdir(['/corticalProjectionsSpecialGroups/typesOfCortex_singelOutlines/sum2'])

    for i = 35:78 %This is strstrt to strnd     %1:length(smallmodel);

        img = zeros(81, 115);
        fig = figure; h_imagesc(img(:, :));
        colormap([0 0 0])
        hold on


        for cc = 1:length(ctx)  
            outline = h_getNucleusOutline(AIBS_100um.striatum.myMask.Full.mask(:,:,i).*~ic_submask(:,:,i));
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'w-', 'linewidth',1)
            end
            oAIBS = h_getNucleusOutline(AIBS_100um.brain.mask(:, :, i));
            for j = 1:length(oAIBS)
                plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1))+0.5, 'w-', 'linewidth',1.1)
            end
            oACA = h_getNucleusOutline(AIBS_100um.aca.mask(:,:,i));
            for j = 1:length(oACA)
                plot((oACA{j}(:,2)), (oACA{j}(:,1))+0.5, 'w-', 'linewidth',0.5)
            end
            oProj = h_getNucleusOutline(ctx(cc).mask3alone(:, :, i));
            for j = 1:length(oProj)
                plot((oProj{j}(:,2)), (oProj{j}(:,1))+0.5, 'Color', ctx(cc).color, 'linewidth',0.5)
            end 
            oProj2 = h_getNucleusOutline(ctx(cc).mask1(:, :, i));
            for j = 1:length(oProj2)
                plot((oProj2{j}(:,2)), (oProj2{j}(:,1))+0.5, 'Color', ctx(cc).color, 'linewidth',0.5)
            end 
        end
        hold off
        
        if saveFlag == 1
            saveas(fig, ['corticalProjectionsSpecialGroups/typesOfCortex_singelOutlines/sum2/summedCorticalGroup_',ctx(cc).name , '_slice',num2str(i),'.fig'], 'fig');
            print(fig, ['corticalProjectionsSpecialGroups/typesOfCortex_singelOutlines/sum2/summedCorticalGroup_',ctx(cc).name , '_slice',num2str(i),'.eps'], '-depsc2');
            close(fig)
        end
    end
    
    if saveFlag == 1
        save([anaDir, '/injGroups_AlloMesoNeo.mat'],'ctx') 
    end
end

%% 6. I want to create groups in the A-P and M-L axes and view their projection patterns. (FIGURE : ML/AP corticostriatal groups)
% ***This ended up being heavily manual... only the ones that are in the figure are usable if this is redone

if figFlag == 6
    % targetDir = '/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/data3';
    % cd(anaDir)
    % load('AIBS_100um.mat')
    % load('inj_data.mat')
    % load('injGroup_data.mat')
    ic_submask = AIBS_100um.striatum.ic_submask;

    corticalOnly = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'SS', 'Vis'};
    nonCorticalGroups = {'SUB_HIPP', 'Amyg', 'SNr', 'na'};


    % Determine the distribution in A-P and M-L of all injections
    x = []; y = []; z = [];

    injLocationGroup_data(1).expID = {};
    injLocationGroup_data(2).expID = {};
    injLocationGroup_data(1).expRegion = {};
    injLocationGroup_data(2).expRegion = {};

    injLocationGroup_data(1).position = [];
    injLocationGroup_data(2).position = [];

    for i = 1:length(inj_data)
        if sum(ismember(corticalOnly, inj_data(i).cortical_group))
            injLocationGroup_data(1).expID = cat(2, injLocationGroup_data(1).expID, inj_data(i).expID);
            injLocationGroup_data(2).expID = cat(2, injLocationGroup_data(2).expID, inj_data(i).expID);
            injLocationGroup_data(1).expRegion = cat(2, injLocationGroup_data(1).expRegion, inj_data(i).cortical_group);
            injLocationGroup_data(2).expRegion = cat(2, injLocationGroup_data(2).expRegion, inj_data(i).cortical_group);  
            injLocationGroup_data(1).position = cat(2, injLocationGroup_data(1).position, inj_data(i).injectionCentroid(1));  % A-P axis
            injLocationGroup_data(2).position = cat(2, injLocationGroup_data(2).position, inj_data(i).injectionCentroid(3));  % M-L axis
        end
    end

    injLocationGroup_data(1).distribution = 'A-P';
    injLocationGroup_data(1).max = nanmax(injLocationGroup_data(1).position); 
    injLocationGroup_data(1).min = nanmin(injLocationGroup_data(1).position);
    injLocationGroup_data(1).range = injLocationGroup_data(1).max - injLocationGroup_data(1).min;

    injLocationGroup_data(2).distribution = 'M-L';
    injLocationGroup_data(2).max = nanmax(injLocationGroup_data(2).position);
    injLocationGroup_data(2).min = nanmin(injLocationGroup_data(2).position);
    injLocationGroup_data(2).range = injLocationGroup_data(2).max - injLocationGroup_data(2).min;


    % Create a variable number of groups by sudividing those distributions & set up metadata in each group
    numGroups = 3;
    for numGroups = 1:10;
        for i = 1:numGroups
            injLocationGroup_data(1).groups(numGroups).range(i, 1) = injLocationGroup_data(1).min + (injLocationGroup_data(1).range/numGroups*(i-1));
            injLocationGroup_data(1).groups(numGroups).range(i, 2) = (injLocationGroup_data(1).min + (injLocationGroup_data(1).range/numGroups*(i)))-0.0001;
            injLocationGroup_data(2).groups(numGroups).range(i, 1) = injLocationGroup_data(2).min + (injLocationGroup_data(2).range/numGroups*(i-1));
            injLocationGroup_data(2).groups(numGroups).range(i, 2) = (injLocationGroup_data(2).min + (injLocationGroup_data(2).range/numGroups*(i)))-0.0001;


            injLocationGroup_data(1).groups(numGroups).exp(i).expID = {};
            injLocationGroup_data(1).groups(numGroups).exp(i).expRegion ={};
            for e = 1:length(injLocationGroup_data(1).expID)
                if (injLocationGroup_data(1).position(e) >= injLocationGroup_data(1).groups(numGroups).range(i, 1)) && (injLocationGroup_data(1).position(e) <= injLocationGroup_data(1).groups(numGroups).range(i, 2))
                    injLocationGroup_data(1).groups(numGroups).exp(i).expID = cat(2, injLocationGroup_data(1).groups(numGroups).exp(i).expID, injLocationGroup_data(1).expID(e));
                    injLocationGroup_data(1).groups(numGroups).exp(i).expRegion = cat(2, injLocationGroup_data(1).groups(numGroups).exp(i).expRegion, injLocationGroup_data(1).expRegion(e));
                end
            end
            injLocationGroup_data(2).groups(numGroups).exp(i).expID = {};
            injLocationGroup_data(2).groups(numGroups).exp(i).expRegion ={};
            for e = 1:length(injLocationGroup_data(1).expID)
                if (injLocationGroup_data(2).position(e) >= injLocationGroup_data(2).groups(numGroups).range(i, 1)) && (injLocationGroup_data(2).position(e) <= injLocationGroup_data(2).groups(numGroups).range(i, 2))
                    injLocationGroup_data(2).groups(numGroups).exp(i).expID = cat(2, injLocationGroup_data(2).groups(numGroups).exp(i).expID, injLocationGroup_data(2).expID(e));
                    injLocationGroup_data(2).groups(numGroups).exp(i).expRegion = cat(2, injLocationGroup_data(2).groups(numGroups).exp(i).expRegion, injLocationGroup_data(2).expRegion(e));
                end
            end

        end
    end 


    % this is creating the composite masks of all the injecitons for each sub-region
    t1 = 0.005;
    t2 = 0.05;   % for these ones use: rotatedData.striatum3d_AI or some other more restrivtive mask to avoid edge problems
    t3 = 0.1;   
    t4 = 0.15;
    t5 = 0.2;

    for a = 1:2
        for i = 1:length(injLocationGroup_data(a).groups);
            a = 1; i = 10; 
            for k = 1: 6; %length(injLocationGroup_data(a).groups(i).exp)

    %             a = 2; i = 10; k = 6; %Just remaking A-P group 3 of 10

                m1 = false(size(AIBS_100um.striatum.myMask.Full.mask)); % initializing the mask
                m1c = false(size(AIBS_100um.striatum.myMask.Full.mask));
                m2 = m1; % for all 3 confidence levels of the ipsilateral and contralateral masks
                m3 = m1; 
                m4 = m1;
                m5 = m1;
                m2c = m1c; 
                m3c = m1c; 
                m4c = m1c;
                m5c = m1c;
                for e = 1:length(injLocationGroup_data(a).groups(i).exp(k).expID); 
                    injLocationGroup_data(a).groups(i).exp(k).injectionMask(e).mask = [];

                    EID = injLocationGroup_data(a).groups(i).exp(k).expID{e};

                    cd(targetDir)

                    load([EID, '/rotatedData.mat'])
                    load([EID, '/submask.mat'])

                    injLocationGroup_data(a).groups(i).exp(k).injectionMask(e).mask = rotatedData.injection3d.mask; % This makes the variable gigantic, but I dont care enough to fix it
                    injLocationGroup_data(a).groups(i).exp(k).expRegion{e} = rotatedData.area;

                    m1 = m1 + (rotatedData.striatum3d.R.densities.*~submask.*~ic_submask > t1);
                    m2 = m2 + (rotatedData.striatum3d.R.densities.*~submask.*~ic_submask > t2); %I made a mask that removes the internal capsule and cc as it curves ventrally near the front of the striatum
                    m3 = m3 + (rotatedData.striatum3d.R.densities.*~submask.*~ic_submask > t3);
                    m4 = m4 + (rotatedData.striatum3d.R.densities.*~submask.*~ic_submask > t4);
                    m5 = m5 + (rotatedData.striatum3d.R.densities.*~submask.*~ic_submask > t5);
                    m1c = m1c + (rotatedData.striatum3d.L.densities.*~submask.*~ic_submask > t1);
                    m2c = m2c + (rotatedData.striatum3d.L.densities.*~submask.*~ic_submask > t2);
                    m3c = m3c + (rotatedData.striatum3d.L.densities.*~submask.*~ic_submask > t3);
                    m4c = m4c + (rotatedData.striatum3d.L.densities.*~submask.*~ic_submask > t4);
                    m5c = m5c + (rotatedData.striatum3d.L.densities.*~submask.*~ic_submask > t5);
                end
                m1 = m1>0; 
                m2 = m2>0; 
                m3 = m3>0; 
                m4 = m4>0; 
                m5 = m5>0;
                m1c = m1c>0; 
                m2c = m2c>0; 
                m3c = m3c>0;
                m4c = m4c>0; 
                m5c = m5c>0;

                % and write the masks into the injLocationGroup_data variable
                injLocationGroup_data(a).groups(i).exp(k).thresholds = [t1 t2 t3 t4 t5];
                injLocationGroup_data(a).groups(i).exp(k).mask1.ipsilateral = m1;
                injLocationGroup_data(a).groups(i).exp(k).mask2.ipsilateral = m2;
                injLocationGroup_data(a).groups(i).exp(k).mask3.ipsilateral = m3;
                injLocationGroup_data(a).groups(i).exp(k).mask4.ipsilateral = m4;
                injLocationGroup_data(a).groups(i).exp(k).mask5.ipsilateral = m5;
                injLocationGroup_data(a).groups(i).exp(k).mask1.contralateral = m1c;
                injLocationGroup_data(a).groups(i).exp(k).mask2.contralateral = m2c;
                injLocationGroup_data(a).groups(i).exp(k).mask3.contralateral = m3c;
                injLocationGroup_data(a).groups(i).exp(k).mask4.contralateral = m4c;
                injLocationGroup_data(a).groups(i).exp(k).mask5.contralateral = m5c;
            end
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%% Then make and save images of some of these groups.  %%%%%%%%%%%%%%%%%%%%%%%%%%
        %*Note there are a lot of problems with this (like contralateral injections that have ipsilateral masks but contralateral centroids...
        % I hand picked things for the figure. I removed injs 2 and 16 from ML-5 of 10  and inj 10 from AP-3 of 10

    % For A-P
    a = 1;
    folderName = 'AP';
    % For M-L
    a = 2;
    folderName = 'ML';

    folderNames = {'AP','ML'};

    % Number of groups you want to make in that axis:
    gg = 10;  % (in this script k and then g are the variable for group number that it cycles through)


    for a = 1:2
        folderName = folderNames{a};
        for gg = [10]

            % For the number of projection density levels you want the images to have (1 = diffuse, 2 = diffuse + dense, 3 = diffuse + intermediate + dense)
            confidenceLevels = 3;

            for k = 1:length(injLocationGroup_data(1).groups(gg).exp) %%%%%%%%%%%%%%%%%%%%%%%%%%%% Change this if you want to view different thresholds (Using 0.5%, 5% and 15% right now) %%%%%%%%%%%%%%%%%%%%%%%
                c1 = injLocationGroup_data(a).groups(gg).exp(k).mask1.ipsilateral + injLocationGroup_data(a).groups(gg).exp(k).mask1.contralateral;
                c2 = injLocationGroup_data(a).groups(gg).exp(k).mask2.ipsilateral + injLocationGroup_data(a).groups(gg).exp(k).mask2.contralateral;  % Trying a change 5/9/15 was 2
                c3 = injLocationGroup_data(a).groups(gg).exp(k).mask5.ipsilateral + injLocationGroup_data(a).groups(gg).exp(k).mask5.contralateral;  % Trying a change 5/9/15 was 4
                if confidenceLevels == 1;     %This essentially determines the number of confidence levels used for clustering.
                    cMapInModel2{k} = double(c1);
                elseif confidenceLevels == 2;
                    cMapInModel2{k} = c1 + c3; 
                elseif confidenceLevels == 3;
                    cMapInModel2{k} = c1 + c2 + c3;
                end
            end

            downsampledProjMask = cMapInModel2;

            % targetDir = ('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/');
            cd(anaDir)

            % This is plotting sections of the individual groups (FIGURE)
            for g = 1:length(injLocationGroup_data(1).groups(gg).exp) 

            %     a = 2; gg = 10; g = 6; %Just remaking A-P group 3 of 10

                mkdir([anaDir, '/corticalProjectionsSpecialGroups/', folderName, '/', num2str(gg), 'groups/group',num2str(g)])
                for i = 21:104; %This is all of cortex %1:length(smallmodel); %all images %i = 35:78 %This is strstrt to strnd 

                    currentSlice = downsampledProjMask{g}(:,:,i);
                    colorImg_r = zeros(size(currentSlice));
                    colorImg_g = zeros(size(currentSlice));
                    colorImg_b = zeros(size(currentSlice));
            %         cmap = [0 0 1; 0 1 0; 1 0 0]; %Makes the 1:blue, 2:green, and 3:red 
            %         cmap = [0 .25 0; 0 .5 0; 0 1 0]; %Makes a scale of green
                    cmap = [.25 .25 .25; .5 .5 .5; 1 1 1]; %makes a grayscale 3 channel image

                    for j = 1:max(downsampledProjMask{g}(:))
                        BW = currentSlice==j;
                        colorImg_r(BW) = cmap(j,1);
                        colorImg_g(BW) = cmap(j,2);
                        colorImg_b(BW) = cmap(j,3);
                    end
                    colorImg = cat(3,colorImg_r,colorImg_g,colorImg_b);
                %     fig = figure; h_imagesc(clusterMask2(:,:,i),[0,max(clusterMask2(:))]); colormap(cmap3);hold on
                    fig = figure; h_imagesc(colorImg); hold on

                    outline = h_getNucleusOutline(AIBS_100um.striatum.myMask.Full.mask(:,:,i).*~ic_submask(:,:,i));
                    for j = 1:length(outline)
                        plot((outline{j}(:,2)), (outline{j}(:,1)), 'w-', 'linewidth',1)
                    end
                    oAIBS = h_getNucleusOutline(AIBS_100um.brain.mask(:, :, i));
                    for j = 1:length(oAIBS)
                        plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1)), 'w-', 'linewidth',1.1)
                    end
                    oACA = h_getNucleusOutline(AIBS_100um.aca.mask(:,:,i));
                    for j = 1:length(oACA)
                        plot((oACA{j}(:,2)), (oACA{j}(:,1)), 'w-', 'linewidth',0.5)
                    end

            %         for w = 1:length(injLocationGroup_data(a).groups(gg).exp(g).expID)
            % 
            %             oInj = h_getNucleusOutline(injLocationGroup_data(a).groups(gg).exp(g).injectionMask(w).mask(:, :, i));
            %             for j = 1:length(oInj)
            %                 plot((oInj{j}(:,2)), (oInj{j}(:,1))+0.5, 'c-', 'linewidth',0.5)
            %             end
            %         end
                    hold off
                    if saveFlag == 1
                        saveas(fig, ['corticalProjectionsSpecialGroups/', folderName, '/', num2str(gg), 'groups/group',num2str(g), '/summedCortical_',folderName, '_', 'group', num2str(g), 'of', num2str(gg), '_slice',num2str(i),'.fig'], 'fig');
                        print(fig, ['corticalProjectionsSpecialGroups/', folderName, '/', num2str(gg), 'groups/group',num2str(g), '/summedCortical_',folderName, '_', 'group', num2str(g), 'of', num2str(gg), '_slice',num2str(i),'.eps'], '-depsc2');
                        close(fig)
                    end
                end
            end

        end
    end
end

%% 7. Now i want to make the "Hot-Spot" map  (FIGURE)
% Sections through the striatum for either the diffuse or dense sum of allareas
%       *for just cortical and all

if figFlag == 7
    % The projection density you want to sum across (1 = diffuse, 2 = intermediate, 3 = dense)
    level = 3; 

    corticalGroup = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'SS', 'Vis', 'SUB_HIPP', 'Amyg', 'SNr', 'na'};
    allRegions = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP', 'SS', 'Vis', 'SUB_HIPP', 'Amyg'};
    corticalRegions = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP', 'SS', 'Vis'};
    frontalRegions = {'ACA','AI_GU_VISC','FRA','IL','ORBl','PL_MO'};
    frontalRegionsNoAI = {'ACA','FRA','IL','ORBl','PL_MO'};


    % DO THESE STEPS TOGETHER ALWAYS
    for i = 1:3
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


    downsampledProjMask = densityLevel;


    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % targetDir = ('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/');
    cd(anaDir)

    % This is plotting sections of the individual hot spot groups (FIGURE)
    for g = 1:length(densityLevel) 
%         g = 1; %%% I am just making images iwth the threshold line for diffuse projections   %%%%%%%%%%%%%%%%% change me?
        mkdir([anaDir, '/corticalProjectionsSpecialGroups/HotSpots/cortexAmygandHipp_evenColorscale'])
        for i = 35:78 %This is strstrt to strnd     %1:length(smallmodel);

            currentSlice = downsampledProjMask{g}(:,:,i);
    %         colorImg_r = zeros(size(currentSlice));
    %         colorImg_g = zeros(size(currentSlice));
    %         colorImg_b = zeros(size(currentSlice));
    %         cmap = [0 0 1; 0 1 0; 1 0 0]; %Makes the 1:blue, 2:green, and 3:red 
    %         cmap = [0 .25 0; 0 .5 0; 0 1 0]; %Makes a scale of green
    %         cmap = [.25 .25 .25; .5 .5 .5; 1 1 1]; %makes a grayscale 3 channel image
    % 
    %         for j = 1:max(downsampledProjMask{g}(:))
    %             BW = currentSlice==j;
    %             colorImg_r(BW) = cmap(j,1);
    %             colorImg_g(BW) = cmap(j,2);
    %             colorImg_b(BW) = cmap(j,3);
    %         end
    %         colorImg = cat(3,colorImg_r,colorImg_g,colorImg_b);
        %     fig = figure; h_imagesc(clusterMask2(:,:,i),[0,max(clusterMask2(:))]); colormap(cmap3);hold on
            fig = figure; h_imagesc(currentSlice); hold on
    %         caxis([0 max(downsampledProjMask{g}(:))])  %colorscale constant for all densities 
            caxis([0 numAreas]) %colorscale different for each map
            colormap('hot')
            outline = h_getNucleusOutline(AIBS_100um.striatum.myMask.Full.mask(:,:,i).*~ic_submask(:,:,i));
            for j = 1:length(outline)
                plot((outline{j}(:,2)), (outline{j}(:,1)), 'w-', 'linewidth',1)
            end
            oAIBS = h_getNucleusOutline(AIBS_100um.brain.mask(:, :, i));
            for j = 1:length(oAIBS)
                plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1)), 'w-', 'linewidth',1.1)
            end
            oACA = h_getNucleusOutline(AIBS_100um.aca.mask(:,:,i));
            for j = 1:length(oACA)
                plot((oACA{j}(:,2)), (oACA{j}(:,1)), 'w-', 'linewidth',0.5)
            end

            cThreshold = 9; 
            oConvergenceThreshold = h_getNucleusOutline(downsampledProjMask{g}(:,:,i) >= cThreshold);
            for j = 1:length(oConvergenceThreshold)
                plot((oConvergenceThreshold{j}(:,2)), (oConvergenceThreshold{j}(:,1)), 'w--', 'linewidth',0.5)
            end

    %         for w = 1:length(injGroup_data(g).expID)
    %             oInj = h_getNucleusOutline(injGroup_data(g).individualInjectionMasks(w).mask(:, :, i));
    %             for j = 1:length(oInj)
    %                 plot((oInj{j}(:,2)), (oInj{j}(:,1))+0.5, 'Color', injGroup_data(g).color, 'linewidth',0.5)
    %             end
    %         end
            hold off
            if saveFlag == 1
                saveas(fig, ['corticalProjectionsSpecialGroups/HotSpots/cortexAmygandHipp_evenColorscale_withThresholdLine/summedConvergence_density',num2str(g), '_slice',num2str(i),'.fig'], 'fig');
                print(fig, ['corticalProjectionsSpecialGroups/HotSpots/cortexAmygandHipp_evenColorscale_withThresholdLine/summedConvergence_density',num2str(g), '_slice',num2str(i), '.eps'], '-depsc2');
                close(fig)
            end
        end
    end
end
% _evenColorscale


%% 8. Now I want to make histograms for the A-P, D-V, M-L distribution the projection fields of cortical groups.  (FIGURE)
%
% I need to (ex: A-P):
%   1. Calculate the % of each section with projection from each region in it
%   2. Calculate the fraction of each projection field within that section

if figFlag == 8
    % targetDir = ('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/');
    cd(anaDir)

    AIBS = AIBS_100um.striatum.myMask.R.mask.*~AIBS_100um.striatum.ic_submask;

    % Rotate the atlas to a sagittal view to map the M-L projections
    temp = AIBS_100um.striatum.myMask.Full.mask.*~AIBS_100um.striatum.ic_submask; 
    X = temp; % ROTATE
    s = size(X); % size vector
    v = [1, 3, 2]; 
    Y = reshape( X(:,:), s);
    Y = permute( Y, v );
    temp = Y;
    AIBSL = temp;

    % Rotate the atlas to a longitudinal view to map the D-V projections
    temp = AIBS; 
    X = temp; % ROTATE
    s = size(X); % size vector
    v = [2, 3, 1]; 
    Y = reshape( X(:,:), s);
    Y = permute( Y, v );
    temp = Y;
    AIBSD = temp;

    for i = 1:size(AIBSL, 3)
        AIBS_ML(i) = sum(sum(AIBSL(:, :, i)));
    end

    for i = 1:size(AIBSD, 3)
        AIBS_DV(i) = sum(sum(AIBSD(:, :, i)));
    end

    for i = 1:size(AIBS, 3)
        AIBS_AP(i) = sum(sum(AIBS(:, :, i)));
    end

    projAP = zeros(2, length(AIBS_100um.striatum.myMask.R.mask));
    projAPn = zeros(2, length(AIBS_100um.striatum.myMask.R.mask));
    maskNames = {'Striatum volume', 'Diffuse (0.05%)', 'Dense (20%)'};
    NmaskNames = {'Diffuse (0.05%)', 'Dense (20%)'};


    % For Normal group plots:
    for g = 1:length(injGroup_data) % Go through all the groups and plot the projection distributions
    % A-P     
    %%%%% Plot the distribution in the Anterior-Posterior axis %%%%%%%%%%%%
        diffuse = injGroup_data(g).mask1.ipsilateral; 
        dense = injGroup_data(g).mask5.ipsilateral; 
        for i = 1:length(AIBS_100um.striatum.myMask.R.mask)
            projAP(1, i) = sum(sum(diffuse(:, :, i)));
            projAPn(1, i) = projAP(1, i)/AIBS_AP(i);
            projAP(2, i) = sum(sum(dense(:, :, i)));
            projAPn(2, i) = projAP(2, i)/AIBS_AP(i);
            projAP(isnan(projAP)) = 0;
            projAPn(isnan(projAPn)) = 0;
        end
        injGroup_data(g).projectionDistributionAP = projAP;
        injGroup_data(g).projectionDistributionAPnormalized = projAPn;

        % Make a darker shade of the assigned color for each group to make the dense and diffuse colors different
        dColor = injGroup_data(g).color - [.3 .3 .3];
        dColor(dColor(:)<0) = 0;
        injGroup_data(g).color2 = dColor;

        % A-P Bar plot with striatum volume plotted too
        fig1 = figure;
        bar(AIBS_AP(1, :), 'k')
        hold on
        h = bar(projAP(1, :), 'c');
        set(h, 'FaceColor', injGroup_data(g).color);
        h2 = bar(projAP(2, :), 'b');
        set(gca, 'xlim', [34 79])
        set(fig1, 'Position', [1   788   850   318]);
        title([injGroup_data(g).cortical_group, ' projection distribution (A-P)'])
        legend(maskNames)
        set(h, 'FaceColor', injGroup_data(g).color);
        set(h2, 'FaceColor', injGroup_data(g).color2);
        set(fig1,'PaperPositionMode','auto')

        % Normalized Bar Plot (I think these are more informative)
        fig2 = figure;
        h = bar(projAPn(1, :), 'c'); 
        hold on
        h2 = bar(projAPn(2, :), 'b');
        set(gca, 'xlim', [34 79])
        set(fig2, 'Position', [879   788   850   318]);
        title([injGroup_data(g).cortical_group, ' projection distribution (A-P) *NORMALIZED to striatum volume*'])
        legend(NmaskNames)
        set(h, 'FaceColor', injGroup_data(g).color);
        set(h2, 'FaceColor', injGroup_data(g).color2);
        set(fig2,'PaperPositionMode','auto')

        fig3 = figure;
        h = plot(projAPn(1, :)', 'Color', injGroup_data(g).color);
        hold on
        h2 = plot(projAPn(2, :)', 'Color', injGroup_data(g).color2);
        set(gca, 'xlim', [34 79])
        set(fig3, 'Position', [879   395   850   317]);
        set(fig3,'PaperPositionMode','auto')
    %     title([injGroup_data(g).cortical_group, ' projection distribution (A-P) *NORMALIZED to striatum volume*'])
    %     legend(NmaskNames)
        
        if saveFlag == 1
            saveas(fig1, ['distributionPlots/AP/projectionDistribution_Histogram_APaxis_',injGroup_data(g).cortical_group, '.fig'], 'fig');
            print(fig1, ['distributionPlots/AP/projectionDistribution_Histogram_APaxis_',injGroup_data(g).cortical_group, '.eps'], '-depsc2');
            close(fig1)

            saveas(fig2, ['distributionPlots/AP/projectionDistribution_normalizedHistogram_APaxis_',injGroup_data(g).cortical_group, '.fig'], 'fig');
            print(fig2, ['distributionPlots/AP/projectionDistribution_normalizedHistogram_APaxis_',injGroup_data(g).cortical_group, '.eps'], '-depsc2');
            close(fig2)

            saveas(fig3, ['distributionPlots/AP/projectionDistribution_normalizedLine_APaxis_',injGroup_data(g).cortical_group, '.fig'], 'fig');
            print(fig3, ['distributionPlots/AP/projectionDistribution_normalizedLine_APaxis_',injGroup_data(g).cortical_group, '.eps'], '-depsc2');
            close(fig3)
        end

    % M-L    
    %%%%% Plot the distribution in the Medial-Lateral axis %%%%%%%%%%%% (both sides?)
        diffuseML = injGroup_data(g).mask1.ipsilateral + injGroup_data(g).mask1.contralateral; 
        denseML = injGroup_data(g).mask5.ipsilateral + injGroup_data(g).mask5.contralateral; 

        % Rotate the diffuse and dense masks and then sum in the new z
        temp = diffuseML; 
        X = temp; % ROTATE
        s = size(X); % size vector
        v = [1, 3, 2]; 
        Y = reshape( X(:,:), s);
        Y = permute( Y, v );
        temp = Y;
        diffuseL = temp;

        temp = denseML; 
        X = temp; % ROTATE
        s = size(X); % size vector
        v = [1, 3, 2]; 
        Y = reshape( X(:,:), s);
        Y = permute( Y, v );
        temp = Y;
        denseL = temp;

        for i = 1:size(diffuseL, 3)
            projML(1, i) = sum(sum(diffuseL(:, :, i)));
            projMLn(1, i) = projML(1, i)/AIBS_ML(i);
            projML(2, i) = sum(sum(denseL(:, :, i)));
            projMLn(2, i) = projML(2, i)/AIBS_ML(i);
            projML(isnan(projML)) = 0;
            projMLn(isnan(projMLn)) = 0;
        end

        injGroup_data(g).projectionDistributionML = projML;
        injGroup_data(g).projectionDistributionMLnormalized = projMLn;

        % M-L Bar plot with striatum volume plotted too
        fig1 = figure;
        bar(AIBS_ML(1, :), 'k')
        hold on
        h = bar(projML(1, :), 'c');
        set(h, 'FaceColor', injGroup_data(g).color);
        h2 = bar(projML(2, :), 'b');
        set(gca, 'xlim', [61 97]) %%%%%%%I calculated bilateral data, but this is cropping it to ipsilateral only
        set(fig1, 'Position', [1   788   850   318]);
        title([injGroup_data(g).cortical_group, ' projection distribution (M-L)'])
        legend(maskNames)
        set(h, 'FaceColor', injGroup_data(g).color);
        set(h2, 'FaceColor', injGroup_data(g).color2);
        set(fig1,'PaperPositionMode','auto')

        % Normalized Bar Plot (I think these are more informative)
        fig2 = figure;
        h = bar(projMLn(1, :), 'c'); 
        hold on
        h2 = bar(projMLn(2, :), 'b');
        set(gca, 'xlim', [61 97])  %%%%%%%I calculated bilateral data, but this is cropping it to ipsilateral only
        set(fig2, 'Position', [879   788   850   318]);
        title([injGroup_data(g).cortical_group, ' projection distribution (M-L) *NORMALIZED to striatum volume*'])
        legend(NmaskNames)
        set(h, 'FaceColor', injGroup_data(g).color);
        set(h2, 'FaceColor', injGroup_data(g).color2);
        set(fig2,'PaperPositionMode','auto')

        fig3 = figure;
        h = plot(projMLn(1, :)', 'Color', injGroup_data(g).color);
        hold on
        h2 = plot(projMLn(2, :)', 'Color', injGroup_data(g).color2);
        set(gca, 'xlim', [61 97]) %%%%%%%I calculated bilateral data, but this is cropping it to ipsilateral only
        set(fig3, 'Position', [879   395   850   317]);
        set(fig3,'PaperPositionMode','auto')
        title([injGroup_data(g).cortical_group, ' projection distribution (M-L) *NORMALIZED to striatum volume*'])
    %     legend(NmaskNames)

         if saveFlag == 1
            saveas(fig1, ['distributionPlots/ML/projectionDistribution_Histogram_MLaxis_',injGroup_data(g).cortical_group, '.fig'], 'fig');
            print(fig1, ['distributionPlots/ML/projectionDistribution_Histogram_MLaxis_',injGroup_data(g).cortical_group, '.eps'], '-depsc2');
            close(fig1)

            saveas(fig2, ['distributionPlots/ML/projectionDistribution_normalizedHistogram_MLaxis_',injGroup_data(g).cortical_group, '.fig'], 'fig');
            print(fig2, ['distributionPlots/ML/projectionDistribution_normalizedHistogram_MLaxis_',injGroup_data(g).cortical_group, '.eps'], '-depsc2');
            close(fig2)

            saveas(fig3, ['distributionPlots/ML/projectionDistribution_normalizedLine_MLaxis_',injGroup_data(g).cortical_group, '.fig'], 'fig');
            print(fig3, ['distributionPlots/ML/projectionDistribution_normalizedLine_MLaxis_',injGroup_data(g).cortical_group, '.eps'], '-depsc2');
            close(fig3)
         end

    % D-V    
    %%%%% Plot the distribution in the Medial-Lateral axis %%%%%%%%%%%% (both sides?)

        % Rotate the ipsilateral diffuse and dense masks and then sum in the new z
        temp = diffuse; 
        X = temp; % ROTATE
        s = size(X); % size vector
        v = [2, 3, 1]; 
        Y = reshape( X(:,:), s);
        Y = permute( Y, v );
        temp = Y;
        diffuseD = temp;

        temp = dense; 
        X = temp; % ROTATE
        s = size(X); % size vector
        v = [2, 3, 1]; 
        Y = reshape( X(:,:), s);
        Y = permute( Y, v );
        temp = Y;
        denseD = temp;

        for i = 1:size(diffuseD, 3)
            projDV(1, i) = sum(sum(diffuseD(:, :, i)));
            projDVn(1, i) = projDV(1, i)/AIBS_DV(i);
            projDV(2, i) = sum(sum(denseD(:, :, i)));
            projDVn(2, i) = projDV(2, i)/AIBS_DV(i);
            projDV(isnan(projDV)) = 0;
            projDVn(isnan(projDVn)) = 0;
        end

        injGroup_data(g).projectionDistributionDV = projDV;
        injGroup_data(g).projectionDistributionDVnormalized = projDVn;


        % D-V Bar plot with striatum volume plotted too
        fig1 = figure;
        barh(AIBS_DV(1, :), 'k')
        hold on
        h = barh(projDV(1, :), 'c');
        set(h, 'FaceColor', injGroup_data(g).color);
        h2 = barh(projDV(2, :), 'b');
        set(gca, 'ylim', [25 69]) 
        set(gca,'YDir','reverse');
        set(fig1, 'Position', [0   518   335   588]);
        title([injGroup_data(g).cortical_group, ' projection distribution (D-V)'])
        legend(maskNames)
        set(h, 'FaceColor', injGroup_data(g).color);
        set(h2, 'FaceColor', injGroup_data(g).color2);
        set(fig1,'PaperPositionMode','auto')

        % Normalized Bar Plot (I think these are more informative)
        fig2 = figure;
        h = barh(projDVn(1, :), 'c'); 
        hold on
        h2 = barh(projDVn(2, :), 'b');
        set(gca, 'ylim', [25 69])  
        set(gca,'YDir','reverse');
        set(fig2, 'Position', [343   518   334   588]);
        title([injGroup_data(g).cortical_group, ' projection distribution (D-V) *NORMALIZED to striatum volume*'])
        legend(NmaskNames)
        set(h, 'FaceColor', injGroup_data(g).color);
        set(h2, 'FaceColor', injGroup_data(g).color2);
        set(fig2,'PaperPositionMode','auto')

        fig3 = figure;
        h = plot(projDVn(1, :)', (1:length(projDVn)), 'Color', injGroup_data(g).color);
        hold on
        h2 = plot(projDVn(2, :)', (1:length(projDVn)), 'Color', injGroup_data(g).color2);
        set(gca, 'ylim', [25 69]) 
        set(gca,'YDir','reverse');
        set(fig3, 'Position', [683   519   333   587]);
        set(fig3,'PaperPositionMode','auto')
        title([injGroup_data(g).cortical_group, ' projection distribution (D-V) *NORMALIZED to striatum volume*'])
    %     legend(NmaskNames)

        if saveFlag == 1
            saveas(fig1, ['distributionPlots/DV/projectionDistribution_Histogram_DVaxis_',injGroup_data(g).cortical_group, '.fig'], 'fig');
            print(fig1, ['distributionPlots/DV/projectionDistribution_Histogram_DVaxis_',injGroup_data(g).cortical_group, '.eps'], '-depsc2');
            close(fig1)

            saveas(fig2, ['distributionPlots/DV/projectionDistribution_normalizedHistogram_DVaxis_',injGroup_data(g).cortical_group, '.fig'], 'fig');
            print(fig2, ['distributionPlots/DV/projectionDistribution_normalizedHistogram_DVaxis_',injGroup_data(g).cortical_group, '.eps'], '-depsc2');
            close(fig2)

            saveas(fig3, ['distributionPlots/DV/projectionDistribution_normalizedLine_DVaxis_',injGroup_data(g).cortical_group, '.fig'], 'fig');
            print(fig3, ['distributionPlots/DV/projectionDistribution_normalizedLine_DVaxis_',injGroup_data(g).cortical_group, '.eps'], '-depsc2');
            close(fig3)
        end
    end
end


%% 8+. Histograms for the A-P, D-V, M-L distribution the projection fields of ALLO-MESO-NEO.  (FIGURE)

if figFlag == 8  % For Allo-Meso-Neo group plots:
    cd(anaDir)
    load('injGroups_AlloMesoNeo.mat')

    for g = 1:length(ctx) % Go through all the groups and plot the projection distributions
    % A-P     
    %%%%% Plot the distribution in the Anterior-Posterior axis %%%%%%%%%%%%
        diffuse = ctx(g).mask1;
        diffuse(:, 20:54,:) = 0; %ipsilateral only
        dense = ctx(g).mask3alone; 
        dense(:, 20:54,:) = 0;
        for i = 1:length(AIBS_100um.striatum.myMask.R.mask)
            projAP(1, i) = sum(sum(diffuse(:, :, i)));
            projAPn(1, i) = projAP(1, i)/AIBS_AP(i);
            projAP(2, i) = sum(sum(dense(:, :, i)));
            projAPn(2, i) = projAP(2, i)/AIBS_AP(i);
            projAP(isnan(projAP)) = 0;
            projAPn(isnan(projAPn)) = 0;
        end
        ctx(g).projectionDistributionAP = projAP;
        ctx(g).projectionDistributionAPnormalized = projAPn;

        % Make a darker shade of the assigned color for each group to make the dense and diffuse colors different
        dColor = ctx(g).color - [.3 .3 .3];
        dColor(dColor(:)<0) = 0;
        ctx(g).color2 = dColor;

        % A-P Bar plot with striatum volume plotted too
        fig1 = figure;
        bar(AIBS_AP(1, :), 'k')
        hold on
        h = bar(projAP(1, :), 'c');
        set(h, 'FaceColor', ctx(g).color);
        h2 = bar(projAP(2, :), 'b');
        set(gca, 'xlim', [34 79])
        set(fig1, 'Position', [1   788   850   318]);
        title([ctx(g).name, ' projection distribution (A-P)'])
        legend(maskNames)
        set(h, 'FaceColor', ctx(g).color);
        set(h2, 'FaceColor', ctx(g).color2);
        set(fig1,'PaperPositionMode','auto')

        % Normalized Bar Plot (I think these are more informative)
        fig2 = figure;
        h = bar(projAPn(1, :), 'c'); 
        hold on
        h2 = bar(projAPn(2, :), 'b');
        set(gca, 'xlim', [34 79])
        set(fig2, 'Position', [879   788   850   318]);
        title([ctx(g).name, ' projection distribution (A-P) *NORMALIZED to striatum volume*'])
        legend(NmaskNames)
        set(h, 'FaceColor', ctx(g).color);
        set(h2, 'FaceColor', ctx(g).color2);
        set(fig2,'PaperPositionMode','auto')

        fig3 = figure;
        h = plot(projAPn(1, :)', 'Color', ctx(g).color);
        hold on
        h2 = plot(projAPn(2, :)', 'Color', ctx(g).color2);
        set(gca, 'xlim', [34 79])
        set(fig3, 'Position', [879   395   850   317]);
        set(fig3,'PaperPositionMode','auto')
    %     title([ctx(g).name, ' projection distribution (A-P) *NORMALIZED to striatum volume*'])
    %     legend(NmaskNames)

        if saveFlag == 1
            saveas(fig1, ['distributionPlots/AlloMesoNeo/projectionDistribution_Histogram_APaxis_',ctx(g).name, '.fig'], 'fig');
            print(fig1, ['distributionPlots/AlloMesoNeo/projectionDistribution_Histogram_APaxis_',ctx(g).name, '.eps'], '-depsc2');
            close(fig1)

            saveas(fig2, ['distributionPlots/AlloMesoNeo/projectionDistribution_normalizedHistogram_APaxis_',ctx(g).name, '.fig'], 'fig');
            print(fig2, ['distributionPlots/AlloMesoNeo/projectionDistribution_normalizedHistogram_APaxis_',ctx(g).name, '.eps'], '-depsc2');
            close(fig2)

            saveas(fig3, ['distributionPlots/AlloMesoNeo/projectionDistribution_normalizedLine_APaxis_',ctx(g).name, '.fig'], 'fig');
            print(fig3, ['distributionPlots/AlloMesoNeo/projectionDistribution_normalizedLine_APaxis_',ctx(g).name, '.eps'], '-depsc2');
            close(fig3)
        end

    % M-L    
    %%%%% Plot the distribution in the Medial-Lateral axis %%%%%%%%%%%% (both sides?)
        diffuseML = ctx(g).mask1; % both ipsi and contralateral
        denseML = ctx(g).mask3alone; 

        % Rotate the diffuse and dense masks and then sum in the new z
        temp = diffuseML; 
        X = temp; % ROTATE
        s = size(X); % size vector
        v = [1, 3, 2]; 
        Y = reshape( X(:,:), s);
        Y = permute( Y, v );
        temp = Y;
        diffuseL = temp;

        temp = denseML; 
        X = temp; % ROTATE
        s = size(X); % size vector
        v = [1, 3, 2]; 
        Y = reshape( X(:,:), s);
        Y = permute( Y, v );
        temp = Y;
        denseL = temp;

        for i = 1:size(diffuseL, 3)
            projML(1, i) = sum(sum(diffuseL(:, :, i)));
            projMLn(1, i) = projML(1, i)/AIBS_ML(i);
            projML(2, i) = sum(sum(denseL(:, :, i)));
            projMLn(2, i) = projML(2, i)/AIBS_ML(i);
            projML(isnan(projML)) = 0;
            projMLn(isnan(projMLn)) = 0;
        end

        ctx(g).projectionDistributionML = projML;
        ctx(g).projectionDistributionMLnormalized = projMLn;

        % M-L Bar plot with striatum volume plotted too
        fig1 = figure;
        bar(AIBS_ML(1, :), 'k')
        hold on
        h = bar(projML(1, :), 'c');
        set(h, 'FaceColor', ctx(g).color);
        h2 = bar(projML(2, :), 'b');
        set(gca, 'xlim', [61 97]) %%%%%%%I calculated bilateral data, but this is cropping it to ipsilateral only
        set(fig1, 'Position', [1   788   850   318]);
        title([ctx(g).name, ' projection distribution (M-L)'])
        legend(maskNames)
        set(h, 'FaceColor', ctx(g).color);
        set(h2, 'FaceColor', ctx(g).color2);
        set(fig1,'PaperPositionMode','auto')

        % Normalized Bar Plot (I think these are more informative)
        fig2 = figure;
        h = bar(projMLn(1, :), 'c'); 
        hold on
        h2 = bar(projMLn(2, :), 'b');
        set(gca, 'xlim', [61 97])  %%%%%%%I calculated bilateral data, but this is cropping it to ipsilateral only
        set(fig2, 'Position', [879   788   850   318]);
        title([ctx(g).name, ' projection distribution (M-L) *NORMALIZED to striatum volume*'])
        legend(NmaskNames)
        set(h, 'FaceColor', ctx(g).color);
        set(h2, 'FaceColor', ctx(g).color2);
        set(fig2,'PaperPositionMode','auto')

        fig3 = figure;
        h = plot(projMLn(1, :)', 'Color', ctx(g).color);
        hold on
        h2 = plot(projMLn(2, :)', 'Color', ctx(g).color2);
        set(gca, 'xlim', [61 97]) %%%%%%%I calculated bilateral data, but this is cropping it to ipsilateral only
        set(fig3, 'Position', [879   395   850   317]);
        set(fig3,'PaperPositionMode','auto')
        title([ctx(g).name, ' projection distribution (M-L) *NORMALIZED to striatum volume*'])
    %     legend(NmaskNames)

        if saveFlag == 1
            saveas(fig1, ['distributionPlots/AlloMesoNeo/projectionDistribution_Histogram_MLaxis_',ctx(g).name, '.fig'], 'fig');
            print(fig1, ['distributionPlots/AlloMesoNeo/projectionDistribution_Histogram_MLaxis_',ctx(g).name, '.eps'], '-depsc2');
            close(fig1)

            saveas(fig2, ['distributionPlots/AlloMesoNeo/projectionDistribution_normalizedHistogram_MLaxis_',ctx(g).name, '.fig'], 'fig');
            print(fig2, ['distributionPlots/AlloMesoNeo/projectionDistribution_normalizedHistogram_MLaxis_',ctx(g).name, '.eps'], '-depsc2');
            close(fig2)

            saveas(fig3, ['distributionPlots/AlloMesoNeo/projectionDistribution_normalizedLine_MLaxis_',ctx(g).name, '.fig'], 'fig');
            print(fig3, ['distributionPlots/AlloMesoNeo/projectionDistribution_normalizedLine_MLaxis_',ctx(g).name, '.eps'], '-depsc2');
            close(fig3)
        end

    % D-V    
    %%%%% Plot the distribution in the Medial-Lateral axis %%%%%%%%%%%% (both sides?)

        % Rotate the ipsilateral diffuse and dense masks and then sum in the new z
        temp = diffuse; 
        X = temp; % ROTATE
        s = size(X); % size vector
        v = [2, 3, 1]; 
        Y = reshape( X(:,:), s);
        Y = permute( Y, v );
        temp = Y;
        diffuseD = temp;

        temp = dense; 
        X = temp; % ROTATE
        s = size(X); % size vector
        v = [2, 3, 1]; 
        Y = reshape( X(:,:), s);
        Y = permute( Y, v );
        temp = Y;
        denseD = temp;

        for i = 1:size(diffuseD, 3)
            projDV(1, i) = sum(sum(diffuseD(:, :, i)));
            projDVn(1, i) = projDV(1, i)/AIBS_DV(i);
            projDV(2, i) = sum(sum(denseD(:, :, i)));
            projDVn(2, i) = projDV(2, i)/AIBS_DV(i);
            projDV(isnan(projDV)) = 0;
            projDVn(isnan(projDVn)) = 0;
        end

        ctx(g).projectionDistributionDV = projDV;
        ctx(g).projectionDistributionDVnormalized = projDVn;


        % D-V Bar plot with striatum volume plotted too
        fig1 = figure;
        barh(AIBS_DV(1, :), 'k')
        hold on
        h = barh(projDV(1, :), 'c');
        set(h, 'FaceColor', ctx(g).color);
        h2 = barh(projDV(2, :), 'b');
        set(gca, 'ylim', [25 69]) 
        set(gca,'YDir','reverse');
        set(fig1, 'Position', [0   518   335   588]);
        title([ctx(g).name, ' projection distribution (D-V)'])
        legend(maskNames)
        set(h, 'FaceColor', ctx(g).color);
        set(h2, 'FaceColor', ctx(g).color2);
        set(fig1,'PaperPositionMode','auto')

        % Normalized Bar Plot (I think these are more informative)
        fig2 = figure;
        h = barh(projDVn(1, :), 'c'); 
        hold on
        h2 = barh(projDVn(2, :), 'b');
        set(gca, 'ylim', [25 69])  
        set(gca,'YDir','reverse');
        set(fig2, 'Position', [343   518   334   588]);
        title([ctx(g).name, ' projection distribution (D-V) *NORMALIZED to striatum volume*'])
        legend(NmaskNames)
        set(h, 'FaceColor', ctx(g).color);
        set(h2, 'FaceColor', ctx(g).color2);
        set(fig2,'PaperPositionMode','auto')

        fig3 = figure;
        h = plot(projDVn(1, :)', (1:length(projDVn)), 'Color', ctx(g).color);
        hold on
        h2 = plot(projDVn(2, :)', (1:length(projDVn)), 'Color', ctx(g).color2);
        set(gca, 'ylim', [25 69]) 
        set(gca,'YDir','reverse');
        set(fig3, 'Position', [683   519   333   587]);
        set(fig3,'PaperPositionMode','auto')
        title([ctx(g).name, ' projection distribution (D-V) *NORMALIZED to striatum volume*'])
    %     legend(NmaskNames)

         if saveFlag == 1
            saveas(fig1, ['distributionPlots/AlloMesoNeo/projectionDistribution_Histogram_DVaxis_',ctx(g).name, '.fig'], 'fig');
            print(fig1, ['distributionPlots/AlloMesoNeo/projectionDistribution_Histogram_DVaxis_',ctx(g).name, '.eps'], '-depsc2');
            close(fig1)

            saveas(fig2, ['distributionPlots/AlloMesoNeo/projectionDistribution_normalizedHistogram_DVaxis_',ctx(g).name, '.fig'], 'fig');
            print(fig2, ['distributionPlots/AlloMesoNeo/projectionDistribution_normalizedHistogram_DVaxis_',ctx(g).name, '.eps'], '-depsc2');
            close(fig2)

            saveas(fig3, ['distributionPlots/AlloMesoNeo/projectionDistribution_normalizedLine_DVaxis_',ctx(g).name, '.fig'], 'fig');
            print(fig3, ['distributionPlots/AlloMesoNeo/projectionDistribution_normalizedLine_DVaxis_',ctx(g).name, '.eps'], '-depsc2');
            close(fig3)
         end
    end
end
    
%% 8++. Histograms for the A-P, D-V, M-L distribution the projection fields of A-P & M-L group.  (FIGURE)
    % comment if unwanted
if figFlag == 8
    % For A-P & M-L group distribution plots... this won't be confusing...
    folderNames = {'corticalAP','corticalML'};  % (a=1 is AP & a=2 is ML)

    for a = 1:2  % For the M-L(2) cortical groups and the A-P (1) cortical groups
        folderName = folderNames{a};
        for gg = [10];  % (in this script k and then g are the variable for group number that it cycles through)
            for k = 1:length(injLocationGroup_data(a).groups(gg).exp)  % Go through tall the groups and plot the distributions 
                diffuse = injLocationGroup_data(a).groups(gg).exp(k).mask1.ipsilateral;
                dense = injLocationGroup_data(a).groups(gg).exp(k).mask5.ipsilateral;
                diffuseML = injLocationGroup_data(a).groups(gg).exp(k).mask1.ipsilateral + injLocationGroup_data(a).groups(gg).exp(k).mask1.contralateral;
                denseML = injLocationGroup_data(a).groups(gg).exp(k).mask5.ipsilateral + injLocationGroup_data(a).groups(gg).exp(k).mask5.contralateral;
                mkdir(['/corticalProjectionsSpecialGroups/', folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots']);

    % A-P     
    %%%%% Plot the distribution in the Anterior-Posterior axis %%%%%%%%%%%%
                for i = 1:length(AIBS_100um.striatum.myMask.R.mask)
                    projAP(1, i) = sum(sum(diffuse(:, :, i)));
                    projAPn(1, i) = projAP(1, i)/AIBS_AP(i);
                    projAP(2, i) = sum(sum(dense(:, :, i)));
                    projAPn(2, i) = projAP(2, i)/AIBS_AP(i);
                    projAP(isnan(projAP)) = 0;
                    projAPn(isnan(projAPn)) = 0;
                end
                injLocationGroup_data(a).groups(gg).exp(k).projectionDistributionAP = projAP;
                injLocationGroup_data(a).groups(gg).exp(k).projectionDistributionAPnormalized = projAPn;


                % A-P Bar plot with striatum volume plotted too
                fig1 = figure;
                bar(AIBS_AP(1, :), 'k')
                hold on
                h = bar(projAP(1, :), 'c');
                set(h, 'FaceColor', [1 0 0]);
                h2 = bar(projAP(2, :), 'b');
                set(gca, 'xlim', [34 79])
                set(fig1, 'Position', [1   788   850   318]);
                title([folderName,' group ',num2str(k),' of ',num2str(gg), ' Range: ',num2str(injLocationGroup_data(a).groups(gg).range(k, :)), ' :Striatal distribution in A-P'])
                legend(maskNames)
                set(h, 'FaceColor', [1 0 0]);
                set(h2, 'FaceColor', [0.6 0 0]);
                set(fig1,'PaperPositionMode','auto')

                % Normalized Bar Plot (I think these are more informative)
                fig2 = figure;
                h = bar(projAPn(1, :), 'c'); 
                hold on
                h2 = bar(projAPn(2, :), 'b');
                set(gca, 'xlim', [34 79])
                set(fig2, 'Position', [879   788   850   318]);
                title([folderName,' group ',num2str(k),' of ',num2str(gg), ' Range: ',num2str(injLocationGroup_data(a).groups(gg).range(k, :)), ' :Striatal distribution in A-P *NORMALIZED to striatum volume*'])
                legend(NmaskNames)
                set(h, 'FaceColor', [1 0 0]);
                set(h2, 'FaceColor', [0.6 0 0]);
                set(fig2,'PaperPositionMode','auto')

                fig3 = figure;
                h = plot(projAPn(1, :)', 'Color', [1 0 0]);
                hold on
                h2 = plot(projAPn(2, :)', 'Color', [0.6 0 0]);
                set(gca, 'xlim', [34 79])
                set(fig3, 'Position', [879   395   850   317]);
                set(fig3,'PaperPositionMode','auto')
                title([folderName,' group ',num2str(k),' of ',num2str(gg), ' Range: ',num2str(injLocationGroup_data(a).groups(gg).range(k, :)), ' :Striatal distribution in A-P *NORMALIZED to striatum volume*'])
            %     legend(NmaskNames)

                 if saveFlag == 1
                    saveas(fig1, ['corticalProjectionsSpecialGroups/', folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_Histogram_APaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.fig'], 'fig');
                    print(fig1, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_Histogram_APaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.eps'], '-depsc2');
                    close(fig1)

                    saveas(fig2, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_normalizedHistogram_APaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.fig'], 'fig');
                    print(fig2, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_normalizedHistogram_APaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.eps'], '-depsc2');
                    close(fig2)

                    saveas(fig3, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_normalizedLine_APaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.fig'], 'fig');
                    print(fig3, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_normalizedLine_APaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.eps'], '-depsc2');
                    close(fig3)
                 end


    % M-L    
    %%%%% Plot the distribution in the Medial-Lateral axis %%%%%%%%%%%% (both sides?)

                % Rotate the diffuse and dense masks and then sum in the new z
                temp = diffuseML; 
                X = temp; % ROTATE
                s = size(X); % size vector
                v = [1, 3, 2]; 
                Y = reshape( X(:,:), s);
                Y = permute( Y, v );
                temp = Y;
                diffuseL = temp;

                temp = denseML; 
                X = temp; % ROTATE
                s = size(X); % size vector
                v = [1, 3, 2]; 
                Y = reshape( X(:,:), s);
                Y = permute( Y, v );
                temp = Y;
                denseL = temp;

                for i = 1:size(diffuseL, 3)
                    projML(1, i) = sum(sum(diffuseL(:, :, i)));
                    projMLn(1, i) = projML(1, i)/AIBS_ML(i);
                    projML(2, i) = sum(sum(denseL(:, :, i)));
                    projMLn(2, i) = projML(2, i)/AIBS_ML(i);
                    projML(isnan(projML)) = 0;
                    projMLn(isnan(projMLn)) = 0;
                end

                injLocationGroup_data(a).groups(gg).exp(k).projectionDistributionML = projML;
                injLocationGroup_data(a).groups(gg).exp(k).projectionDistributionMLnormalized = projMLn;

                % M-L Bar plot with striatum volume plotted too
                fig1 = figure;
                bar(AIBS_ML(1, :), 'k')
                hold on
                h = bar(projML(1, :), 'c');
                set(h, 'FaceColor', [0.4 0.8 0]);
                h2 = bar(projML(2, :), 'b');
                set(gca, 'xlim', [61 97]) %%%%%%%I calculated bilateral data, but this is cropping it to ipsilateral only
                set(fig1, 'Position', [1   788   850   318]);
                title([folderName,' group ',num2str(k),' of ',num2str(gg), ' Range: ',num2str(injLocationGroup_data(a).groups(gg).range(k, :)), ' :Striatal distribution in M-L'])
                legend(maskNames)
                set(h, 'FaceColor', [0.4 0.8 0]);
                set(h2, 'FaceColor', [0.2 0.4 0]);
                set(fig1,'PaperPositionMode','auto')

                % Normalized Bar Plot (I think these are more informative)
                fig2 = figure;
                h = bar(projMLn(1, :), 'c'); 
                hold on
                h2 = bar(projMLn(2, :), 'b');
                set(gca, 'xlim', [61 97])  %%%%%%%I calculated bilateral data, but this is cropping it to ipsilateral only
                set(fig2, 'Position', [879   788   850   318]);
                title([folderName,' group ',num2str(k),' of ',num2str(gg), ' Range: ',num2str(injLocationGroup_data(a).groups(gg).range(k, :)), ' :Striatal distribution in M-L *NORMALIZED to striatum volume*'])
                legend(NmaskNames)
                set(h, 'FaceColor', [0.4 0.8 0]);
                set(h2, 'FaceColor', [0.2 0.4 0]);
                set(fig2,'PaperPositionMode','auto')

                fig3 = figure;
                h = plot(projMLn(1, :)', 'Color', [0.4 0.8 0]);
                hold on
                h2 = plot(projMLn(2, :)', 'Color', [0.2 0.4 0]);
                set(gca, 'xlim', [61 97]) %%%%%%%I calculated bilateral data, but this is cropping it to ipsilateral only
                set(fig3, 'Position', [879   395   850   317]);
                set(fig3,'PaperPositionMode','auto')
                title([folderName,' group ',num2str(k),' of ',num2str(gg), ' :Striatal distribution in M-L *NORMALIZED to striatum volume*'])
            %     legend(NmaskNames)

                if saveFlag == 1
                    saveas(fig1, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_Histogram_MLaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.fig'], 'fig');
                    print(fig1, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_Histogram_MLaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.eps'], '-depsc2');
                    close(fig1)

                    saveas(fig2, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_normalizedHistogram_MLaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.fig'], 'fig');
                    print(fig2, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_normalizedHistogram_MLaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.eps'], '-depsc2');
                    close(fig2)

                    saveas(fig3, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_normalizedLine_MLaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.fig'], 'fig');
                    print(fig3, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_normalizedLine_MLaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.eps'], '-depsc2');
                    close(fig3)
                end

    % D-V    
    %%%%% Plot the distribution in the Medial-Lateral axis %%%%%%%%%%%% (both sides?)

                % Rotate the ipsilateral diffuse and dense masks and then sum in the new z
                temp = diffuse; 
                X = temp; % ROTATE
                s = size(X); % size vector
                v = [2, 3, 1]; 
                Y = reshape( X(:,:), s);
                Y = permute( Y, v );
                temp = Y;
                diffuseD = temp;

                temp = dense; 
                X = temp; % ROTATE
                s = size(X); % size vector
                v = [2, 3, 1]; 
                Y = reshape( X(:,:), s);
                Y = permute( Y, v );
                temp = Y;
                denseD = temp;

                for i = 1:size(diffuseD, 3)
                    projDV(1, i) = sum(sum(diffuseD(:, :, i)));
                    projDVn(1, i) = projDV(1, i)/AIBS_DV(i);
                    projDV(2, i) = sum(sum(denseD(:, :, i)));
                    projDVn(2, i) = projDV(2, i)/AIBS_DV(i);
                    projDV(isnan(projDV)) = 0;
                    projDVn(isnan(projDVn)) = 0;
                end

                injLocationGroup_data(a).groups(gg).exp(k).projectionDistributionDV = projDV;
                injLocationGroup_data(a).groups(gg).exp(k).projectionDistributionDVnormalized = projDVn;


                % D-V Bar plot with striatum volume plotted too
                fig1 = figure;
                barh(AIBS_DV(1, :), 'k')
                hold on
                h = barh(projDV(1, :), 'c');
                set(h, 'FaceColor', [0.2 0.4 0.8]);
                h2 = barh(projDV(2, :), 'b');
                set(gca, 'ylim', [25 69]) 
                set(gca,'YDir','reverse');
                set(fig1, 'Position', [0   518   335   588]);
                title([folderName,' group ',num2str(k),' of ',num2str(gg), ' :Striatal distribution in D-V'])
                legend(maskNames)
                set(h, 'FaceColor', [0.2 0.4 0.8]);
                set(h2, 'FaceColor', [0 0.2 0.6]);
                set(fig1,'PaperPositionMode','auto')

                % Normalized Bar Plot (I think these are more informative)
                fig2 = figure;
                h = barh(projDVn(1, :), 'c'); 
                hold on
                h2 = barh(projDVn(2, :), 'b');
                set(gca, 'ylim', [25 69])  
                set(gca,'YDir','reverse');
                set(fig2, 'Position', [343   518   334   588]);
                title([folderName,' group ',num2str(k),' of ',num2str(gg), ' :Striatal distribution in D-V *NORMALIZED to striatum volume*'])
                legend(NmaskNames)
                set(h, 'FaceColor', [0.2 0.4 0.8]);
                set(h2, 'FaceColor', [0 0.2 0.6]);
                set(fig2,'PaperPositionMode','auto')

                fig3 = figure;
                h = plot(projDVn(1, :)', (1:length(projDVn)), 'Color', [0.2 0.4 0.8]);
                hold on
                h2 = plot(projDVn(2, :)', (1:length(projDVn)), 'Color', [0 0.2 0.6]);
                set(gca, 'ylim', [25 69]) 
                set(gca,'YDir','reverse');
                set(fig3, 'Position', [683   519   333   587]);
                set(fig3,'PaperPositionMode','auto')
                title([folderName,' group ',num2str(k),' of ',num2str(gg), ' :Striatal distribution in D-V *NORMALIZED to striatum volume*'])
            %     legend(NmaskNames)

                if saveFlag == 1
                    saveas(fig1, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_Histogram_DVaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.fig'], 'fig');
                    print(fig1, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_Histogram_DVaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.eps'], '-depsc2');
                    close(fig1)

                    saveas(fig2, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_normalizedHistogram_DVaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.fig'], 'fig');
                    print(fig2, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_normalizedHistogram_DVaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.eps'], '-depsc2');
                    close(fig2)

                    saveas(fig3, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_normalizedLine_DVaxis_',folderName,'_group',num2str(k),'of',num2str(gg), '.fig'], 'fig');
                    print(fig3, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_normalizedLine_DVaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.eps'], '-depsc2');
                    close(fig3)
                end

            end
        end
    end
end

%% 8+++. Histograms for the A-P, D-V, M-L distribution the projection fields of HOT-SPOT groups.  (FIGURE)

if figFlag == 8
    % For Hot-spot map
    for l = 1:length(densityLevel)
        for f = 1:3; %to go through each figure... 
            for dd = 1:3; %to cycle through the views 
                if dd == 1
                    if f == 1;
                    fig1 = figure;
                    bar(AIBS_AP(1, :), 'k')
                    hold on
                    elseif f == 2
                    fig2 = figure;
                    hold on
                    elseif f == 3
                    fig3 = figure;
                    hold on
                    end
                elseif dd == 2
                    if f == 1
                    fig1 = figure;
                    bar(AIBS_ML(1, :), 'k')
                    hold on
                    elseif f == 2
                    fig2 = figure;
                    hold on
                    elseif f == 3
                    fig3 = figure; 
                    hold on
                    end
                elseif dd == 3
                    if f == 1
                    fig1 = figure;
                    barh(AIBS_DV(1, :), 'k')
                    hold on
                    elseif f == 2
                    fig2 = figure;
                    hold on
                    elseif f == 3
                    fig3 = figure; 
                    hold on
                    end
                end

                for k  = 1:max(densityLevel{1}(:)); % I want to loop through all the levels in the convergenve map.
                    colormap(hot);
                    caxis([0 max(densityLevel{1}(:))]) 
                    map = colormap; 
                    dColor = map(round(length(map)/max(densityLevel{1}(:))*k), :);
                    maskNames{k} = num2str(k);

                    if dd ==1; 
                    % A-P     
                    %%%%% Plot the distribution in the Anterior-Posterior axis %%%%%%%%%%%%
                        converge{k} = densityLevel{l}>= k;
                        converge{k}(:, 20:54,:) = 0; %ipsilateral only
                        diffuse = converge{k};

                        for i = 1:length(AIBS_100um.striatum.myMask.R.mask)
                            projAP(1, i) = sum(sum(diffuse(:, :, i)));
                            projAPn(1, i) = projAP(1, i)/AIBS_AP(i);
                            projAP(isnan(projAP)) = 0;
                            projAPn(isnan(projAPn)) = 0;
                        end

                        if f == 1; 
                            % A-P Bar plot with striatum volume plotted too
                            h = bar(projAP(1, :), 'c');
                            set(h, 'FaceColor', dColor);
                            set(gca, 'xlim', [34 79])
                            set(fig1, 'Position', [1   788   850   318]);
                            title(['Level ', num2str(l), ' projection distribution (A-P)'])
                            legend(maskNames)
                            set(h, 'FaceColor', dColor);
                        elseif f == 2;
                            % Normalized Bar Plot (I think these are more informative)
                            h = bar(projAPn(1, :), 'c');
                            set(gca, 'xlim', [34 79])
                            set(fig2, 'Position', [879   788   850   318]);
                            title(['Level ', num2str(l), ' projection distribution (A-P) *NORMALIZED to striatum volume*'])
    %                         legend(maskNames)
                            set(h, 'FaceColor', dColor);
                        elseif f ==3;
                            h = plot(projAPn(1, :)', 'Color', dColor);
                            set(gca, 'xlim', [34 79])
                            set(fig3, 'Position', [879   395   850   317]);
                            set(fig3,'PaperPositionMode','auto')
                            title(['Level ',num2str(l), ' projection distribution (A-P) *NORMALIZED to striatum volume*'])
                        %     legend(NmaskNames)
                        end

                    elseif dd == 2;
                    % M-L    
                    %%%%% Plot the distribution in the Medial-Lateral axis %%%%%%%%%%%% (both sides?)
                        converge{k} = densityLevel{l}>= k; %both contra- and ipsilateral
                        diffuseML = converge{k};

                        % Rotate the diffuse and dense masks and then sum in the new z
                        temp = diffuseML; 
                        X = temp; % ROTATE
                        s = size(X); % size vector
                        v = [1, 3, 2]; 
                        Y = reshape( X(:,:), s);
                        Y = permute( Y, v );
                        temp = Y;
                        diffuseL = temp;

                        for i = 1:size(diffuseL, 3)
                            projML(1, i) = sum(sum(diffuseL(:, :, i)));
                            projMLn(1, i) = projML(1, i)/AIBS_ML(i);
                            projML(isnan(projML)) = 0;
                            projMLn(isnan(projMLn)) = 0;
                        end

                        if f == 1;
                            % M-L Bar plot with striatum volume plotted too
                            h = bar(projML(1, :), 'c');
                            set(h, 'FaceColor', dColor);
                            set(gca, 'xlim', [61 97]) %%%%%%%I calculated bilateral data, but this is cropping it to ipsilateral only
                            set(fig1, 'Position', [1   788   850   318]);
                            title(['Level ', num2str(l), ' projection distribution (M-L)'])
                            legend(maskNames)
                        elseif f == 2;
                            % Normalized Bar Plot (I think these are more informative)
                            h = bar(projMLn(1, :), 'c'); 
                            hold on
                            set(gca, 'xlim', [61 97])  %%%%%%%I calculated bilateral data, but this is cropping it to ipsilateral only
                            set(fig2, 'Position', [879   788   850   318]);
                            title(['Level ', num2str(l), ' projection distribution (M-L) *NORMALIZED to striatum volume*'])
        %                     legend(NmaskNames)
                            set(h, 'FaceColor', dColor);
                        elseif f == 3;
                            h = plot(projMLn(1, :)', 'Color', dColor);
                            hold on
                            set(gca, 'xlim', [61 97]) %%%%%%%I calculated bilateral data, but this is cropping it to ipsilateral only
                            set(fig3, 'Position', [879   395   850   317]);
                            title(['Level ', num2str(l), ' projection distribution (M-L) *NORMALIZED to striatum volume*'])
                        %     legend(NmaskNames)
                        end

                    elseif dd == 3;
                    % D-V    
                    %%%%% Plot the distribution in the Medial-Lateral axis %%%%%%%%%%%% (both sides?)
                        converge{k} = densityLevel{l}>= k;
                        converge{k}(:, 20:54,:) = 0; %ipsilateral only
                        diffuse = converge{k};

                        % Rotate the ipsilateral diffuse and dense masks and then sum in the new z
                        temp = diffuse; 
                        X = temp; % ROTATE
                        s = size(X); % size vector
                        v = [2, 3, 1]; 
                        Y = reshape( X(:,:), s);
                        Y = permute( Y, v );
                        temp = Y;
                        diffuseD = temp;

                        temp = dense; 
                        X = temp; % ROTATE
                        s = size(X); % size vector
                        v = [2, 3, 1]; 
                        Y = reshape( X(:,:), s);
                        Y = permute( Y, v );
                        temp = Y;
                        denseD = temp;

                        for i = 1:size(diffuseD, 3)
                            projDV(1, i) = sum(sum(diffuseD(:, :, i)));
                            projDVn(1, i) = projDV(1, i)/AIBS_DV(i);
                            projDV(isnan(projDV)) = 0;
                            projDVn(isnan(projDVn)) = 0;
                        end

                        if f == 1;
                            % D-V Bar plot with striatum volume plotted too
                            h = barh(projDV(1, :), 'c');
                            set(h, 'FaceColor', dColor);
                            set(gca, 'ylim', [25 69]) 
                            set(gca,'YDir','reverse');
                            set(fig1, 'Position', [0   518   335   588]);
                            title(['Level ', num2str(l), ' projection distribution (D-V)'])
                            legend(maskNames)
                        elseif f == 2;
                            % Normalized Bar Plot (I think these are more informative)
                            h = barh(projDVn(1, :), 'c'); 
                            hold on
                            set(gca, 'ylim', [25 69])  
                            set(gca,'YDir','reverse');
                            set(fig2, 'Position', [343   518   334   588]);
                            title(['Level ', num2str(l), ' projection distribution (D-V) *NORMALIZED to striatum volume*'])
    %                         legend(NmaskNames)
                            set(h, 'FaceColor', dColor);
                        elseif f == 3;
                            h = plot(projDVn(1, :)', (1:length(projDVn)), 'Color', dColor);
                            hold on
                            set(gca, 'ylim', [25 69]) 
                            set(gca,'YDir','reverse');
                            set(fig3, 'Position', [683   519   333   587]);
                            title(['Level ', num2str(l), ' projection distribution (D-V) *NORMALIZED to striatum volume*'])
                        %     legend(NmaskNames)
                        end

                    end  
                end

                hold off
                
                if saveFlag == 1
                    if dd ==1 
                        if f == 1
                            set(fig1,'PaperPositionMode','auto')
                        saveas(fig1, ['distributionPlots/HotSpot/projectionDistribution_Histogram_APaxis_CortexAmygHipp_level', num2str(l), '_HotSpot.fig'], 'fig');
                        print(fig1, ['distributionPlots/HotSpot/projectionDistribution_Histogram_APaxis_CortexAmygHipp_level', num2str(l), '_HotSpot.eps'], '-depsc2');
                        close(fig1)
                        elseif f ==2 
                            set(fig2,'PaperPositionMode','auto')
                        saveas(fig2, ['distributionPlots/HotSpot/projectionDistribution_normalizedHistogram_APaxis_CortexAmygHipp_level', num2str(l), '_HotSpot.fig'], 'fig');
                        print(fig2, ['distributionPlots/HotSpot/projectionDistribution_normalizedHistogram_APaxis_CortexAmygHipp_level', num2str(l), '_HotSpot.eps'], '-depsc2');
                        close(fig2)
                        elseif f ==3 
                            set(fig3,'PaperPositionMode','auto')
                        saveas(fig3, ['distributionPlots/HotSpot/projectionDistribution_normalizedLine_APaxis_CortexAmygHipp_level', num2str(l), '_HotSpot.fig'], 'fig');
                        print(fig3, ['distributionPlots/HotSpot/projectionDistribution_normalizedLine_APaxis_CortexAmygHipp_level', num2str(l), '_HotSpot.eps'], '-depsc2');
                        close(fig3)
                        end
                    elseif dd ==2
                        if f == 1
                            set(fig1,'PaperPositionMode','auto')
                        saveas(fig1, ['distributionPlots/HotSpot/projectionDistribution_Histogram_MLaxis_CortexAmygHipp_level', num2str(l), '_HotSpot.fig'], 'fig');
                        print(fig1, ['distributionPlots/HotSpot/projectionDistribution_Histogram_MLaxis_CortexAmygHipp_level', num2str(l), '_HotSpot.eps'], '-depsc2');
                        close(fig1)
                        elseif f ==2 
                            set(fig2,'PaperPositionMode','auto')
                        saveas(fig2, ['distributionPlots/HotSpot/projectionDistribution_normalizedHistogram_MLaxis_CortexAmygHipp_level', num2str(l), '_HotSpot.fig'], 'fig');
                        print(fig2, ['distributionPlots/HotSpot/projectionDistribution_normalizedHistogram_MLaxis_CortexAmygHipp_level', num2str(l), '_HotSpot.eps'], '-depsc2');
                        close(fig2)
                        elseif f ==3    
                            set(fig3,'PaperPositionMode','auto')
                        saveas(fig3, ['distributionPlots/HotSpot/projectionDistribution_normalizedLine_MLaxis_CortexAmygHipp_level', num2str(l), '_HotSpot.fig'], 'fig');
                        print(fig3, ['distributionPlots/HotSpot/projectionDistribution_normalizedLine_MLaxis_CortexAmygHipp_level', num2str(l), '_HotSpot.eps'], '-depsc2');
                        close(fig3)
                        end
                    elseif dd == 3
                        if f ==1 
                            set(fig1,'PaperPositionMode','auto')
                        saveas(fig1, ['distributionPlots/HotSpot/projectionDistribution_Histogram_DVaxis_CortexAmygHipp_level', num2str(l), '_HotSpot.fig'], 'fig');
                        print(fig1, ['distributionPlots/HotSpot/projectionDistribution_Histogram_DVaxis_CortexAmygHipp_level', num2str(l), '_HotSpot.eps'], '-depsc2');
                        close(fig1)
                        elseif f ==2 
                            set(fig2,'PaperPositionMode','auto')
                        saveas(fig2, ['distributionPlots/HotSpot/projectionDistribution_normalizedHistogram_DVaxis_CortexAmygHipp_level', num2str(l), '_HotSpot.fig'], 'fig');
                        print(fig2, ['distributionPlots/HotSpot/projectionDistribution_normalizedHistogram_DVaxis_CortexAmygHipp_level', num2str(l), '_HotSpot.eps'], '-depsc2');
                        close(fig2)
                        elseif f ==3 
                            set(fig3,'PaperPositionMode','auto')
                        saveas(fig3, ['distributionPlots/HotSpot/projectionDistribution_normalizedLine_DVaxis_CortexAmygHipp_level', num2str(l), '_HotSpot.fig'], 'fig');
                        print(fig3, ['distributionPlots/HotSpot/projectionDistribution_normalizedLine_DVaxis_CortexAmygHipp_level', num2str(l), '_HotSpot.eps'], '-depsc2');
                        close(fig3)
                        end
                    end
                end
            end
        end
    end
end

%% 9. Now lets make a convergence plot
% This may be more associated with clustering, as I will want them ordered based on input similarity.. 
% Calculate the % of each subregion that is covered byprojections from each other area

% NOTE: need to manually change some *GGconvergence1 things to *GGconvergence3 to get dense proj. plot 
%       JH: 9/20/16 update: Not anymore, generalized the saving.

if figFlag == 9
    % targetDir = ('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/');
    cd(anaDir)
    % load('AIBS_100um.mat')
    % load('injGroup_data.mat')
    ic_submask = AIBS_100um.striatum.ic_submask;
    mkdir('corticalProjectionsSpecialGroups/HotSpots/plots/')

    corticalGroup = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'SS', 'Vis', 'SUB_HIPP', 'Amyg', 'SNr', 'na'};
    regionsToUse = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP', 'SS', 'Vis', 'SUB_HIPP', 'Amyg'};
    cortexOnly = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP', 'SS', 'Vis'};


    strVolume = sum(AIBS_100um.striatum.myMask.R.mask(:).*~ic_submask(:));
    percentGcoveredByGG1 = [];
    percentGcoveredByGG2 = [];
    percentGcoveredByGG3 = [];

    percentSTRcoveredByG_GGconvergence1 = [];
    percentSTRcoveredByG_GGconvergence2 = [];
    percentSTRcoveredByG_GGconvergence3 = [];
    cPlotNames ={};

    for g = 1:length(regionsToUse) 
        ind = find(strcmp(regionsToUse{g}, corticalGroup));
    %    for side = 1:3;  % do it for ipsi/contra/full?
        cPlotNames{g} = injGroup_data(ind).cortical_group;
        totalProjVolume1 = sum(injGroup_data(ind).mask1.ipsilateral(:)&~ic_submask(:));
        totalProjVolume2 = sum(injGroup_data(ind).mask2.ipsilateral(:)&~ic_submask(:));
        totalProjVolume3 = sum(injGroup_data(ind).mask5.ipsilateral(:)&~ic_submask(:));

        for gg = 1:length(regionsToUse) % I will query all subregions (gg) for convergence with each subregion (g)
            ind2 = find(strcmp(regionsToUse{gg}, corticalGroup));
            convergenceVolume1= sum(injGroup_data(ind).mask1.ipsilateral(:)&injGroup_data(ind2).mask1.ipsilateral(:)); %Get the mask corresponding to the intersecting area (i.e. g & gg)
            convergenceVolume2= sum(injGroup_data(ind).mask2.ipsilateral(:)&injGroup_data(ind2).mask2.ipsilateral(:));
            convergenceVolume3= sum(injGroup_data(ind).mask5.ipsilateral(:)&injGroup_data(ind2).mask5.ipsilateral(:));
            
            convergenceVolume4= sum(injGroup_data(ind).mask1.ipsilateral(:)&injGroup_data(ind2).mask5.ipsilateral(:)); % JH: g diffuse & gg dense intersect - 9/20/16 update
            convergenceVolume5= sum(injGroup_data(ind).mask5.ipsilateral(:)&injGroup_data(ind2).mask1.ipsilateral(:)); % JH: gg diffuse & g dense intersect - 9/20/16 update

            percentGcoveredByGG1(g, gg) = convergenceVolume1/totalProjVolume1;   %Rows(g) = percent of that region covered by columns(gg) (i.e % of g diffuse convergent with gg diffuse)
            percentGcoveredByGG2(g, gg) = convergenceVolume2/totalProjVolume2;   % (i.e % of g moderate convergent with gg moderate)
            percentGcoveredByGG3(g, gg) = convergenceVolume3/totalProjVolume3;   % (i.e % of g dense convergent with gg dense)
            
            percentGcoveredByGG4(g, gg) = convergenceVolume4/totalProjVolume1;   % JH: % of g diffuse convergent with gg dense - 9/20/16 update
            percentGcoveredByGG5(g, gg) = convergenceVolume5/totalProjVolume3;   % JH: % of g dense convergent with gg diffuse - 9/20/16 update

            percentSTRcoveredByG_GGconvergence1(g, gg) = convergenceVolume1/strVolume;   %Rows(g) = percent of that region covered by columns(gg)
            percentSTRcoveredByG_GGconvergence2(g, gg) = convergenceVolume2/strVolume;   %Rows(g) = percent of that region covered by columns(gg)
            percentSTRcoveredByG_GGconvergence3(g, gg) = convergenceVolume3/strVolume;   %Rows(g) = percent of that region covered by columns(gg)

    %         if strcmp(regionsToUse{g}, regionsToUse{gg}) % this is so I can use squareform
    %             percentGcoveredByGG1(g, gg) = 0;   
    %             percentGcoveredByGG2(g, gg) = 0;   
    %             percentGcoveredByGG3(g, gg) = 0;   
    % 
    %             percentSTRcoveredByG_GGconvergence1(g, gg) = 0;   
    %             percentSTRcoveredByG_GGconvergence2(g, gg) = 0;   
    %             percentSTRcoveredByG_GGconvergence3(g, gg) = 0;
    %         end

        end
    end

    conv_groups = {percentGcoveredByGG1, percentGcoveredByGG2, percentGcoveredByGG3, percentGcoveredByGG4, percentGcoveredByGG5};
    % convergence_vector = squareform(percentGcoveredByGG1); % not working...
    convergence_vector = pdist(percentGcoveredByGG1);  % JH: 9/20/16 update - This works... but I dont think it matters because I'm not using optimleaf
%     convergence_vector = [0.904990076601452,0.387755763346495,0.738663219065169,1.15307448845321,0.893337229205180,1.13392484899167,0.840936550443780,0.642841822498677,0.839067684267348,0.687449020026732,0.935297059912784,0.372280973943198,0.837520068939149,0.836587396309316,0.858975196479194,0.264842004267807,0.349233021343759,1.09073176236041,0.341648516481001,0.0949646837966724,0.485242933128798,1.58005603581059,1.45331324059137,0.228502805318531,0.745642137359345,0.964396238988081,0.0921702276187304,0.721277013279425,1.06173033822321,1.07176978091360,1.03990740518025,0.797986630914640,0.688602926046743,0.922900322050956,0.782012324707943,0.842374503397022,0.254542222974439,0.986529343792649,0.798631174316651,0.576488496386912,0.886480624740892,0.565575965845559,0.235366934312674,0.267937542487988,1.39015701948636,1.27097068681827,0.403128834051528,0.611868620311056,0.756489680965911,0.199463098617725,1.42004165977880,0.0669052093996364,0.380672705522581,0.793722413529837,1.82750653277839,1.69181789187846,0.250272949559226,0.956119784021090,1.28961838566726,0.423127141803795,1.41315379720687,1.06617033807907,0.703711100292768,1.21737922537702,1.17885284116796,1.25139878498658,1.01356270648727,0.258599230218064,1.02056156409233,0.368902993426877,0.782627267807155,1.80620975390299,1.67002863130008,0.230399395394623,0.936253310185372,1.28135458272880,0.413197812282882,0.451501144498724,1.50937789325442,1.38275697173559,0.206890056160317,0.684061487639470,0.940386946643796,0.0742273644174165,1.25399736026552,1.14373611349588,0.615469755800869,0.587238846595871,0.570090513465365,0.417023671636754,0.310150067440909,1.59185193220875,1.00196897797337,1.21769207948129,1.50188276003995,1.45983666665989,0.861324102922205,1.17164334600067,1.37775791407744,0.738889422414970,1.12144145314528,0.261358449579778,0.921427389792705,0.686428234404729,0.895492712832900];
    
    for i = 1:length(conv_groups)
        percentGcoveredByGG = conv_groups{i};
        convergence_PairwiseDistance = pdist(percentGcoveredByGG,'correlation');
        convergence_clustering = linkage(convergence_PairwiseDistance,'average');
        figure, dendrogram(convergence_clustering);
        optimleaf = optimalleaforder(convergence_clustering, convergence_vector);  
        figure, dendrogram(convergence_clustering, 'reorder', optimleaf);

        % fig = figure;
        % imagesc(percentGcoveredByGG1);
        % caxis([0 1])
        % colormap(hot)
        % set(gcf, 'Position', [6 316 829 790])
        % set(gca, 'YTick', 1:length(regionsToUse))
        % set(gca, 'YTickLabel', cPlotNames)
        % set(gca, 'XTick', 1:length(regionsToUse))
        % set(gca, 'xTickLabel', cPlotNames)
        % title('unclustered')
        % ylabel('Fraction or proections from subregion')
        % xlabel('Convergent with projections from subregion')
        % set(fig,'PaperPositionMode','auto')
        %         saveas(fig, ['corticalProjectionsSpecialGroups/HotSpots/plots/subregionConvergence_level_1.fig'], 'fig');
        %         print(fig, ['corticalProjectionsSpecialGroups/HotSpots/plots/subregionConvergence_level_1.eps'], '-depsc2');
        %         close(fig)

        %%% #winner
        OrderFromCorrelation3levels = [5 7 12 2 8 1 10 11 3 13 4 15 6 14 9];
        fig = figure;
        imagesc(percentGcoveredByGG(OrderFromCorrelation3levels, OrderFromCorrelation3levels));
        caxis([0 1])
        colormap(hot)
        set(gcf, 'Position', [6 316 829 790])
        set(gca, 'YTick', 1:length(regionsToUse))
        set(gca, 'YTickLabel', cPlotNames(OrderFromCorrelation3levels))
        set(gca, 'XTick', 1:length(regionsToUse))
        set(gca, 'xTickLabel', cPlotNames(OrderFromCorrelation3levels))
        title('correlation order')
        ylabel('Fraction or proections from subregion')
        xlabel('Convergent with projections from subregion')
        set(fig,'PaperPositionMode','auto')

        if saveFlag == 1
            saveas(fig, ['corticalProjectionsSpecialGroups/HotSpots/plots/subregionConvergence_OrderByVoxelClustering_level_', num2str(i), '.fig'], 'fig');
            print(fig, ['corticalProjectionsSpecialGroups/HotSpots/plots/subregionConvergence_OrderByVoxelClustering_level_', num2str(i), '.eps'], '-depsc2');
            close(fig)
        end

        % Not used
        fig = figure;
        imagesc(percentGcoveredByGG(optimleaf, optimleaf));
        caxis([0 1])
        colormap(hot)
        set(gcf, 'Position', [6 316 829 790])
        set(gca, 'YTick', 1:length(regionsToUse))
        set(gca, 'YTickLabel', cPlotNames(optimleaf))
        set(gca, 'XTick', 1:length(regionsToUse))
        set(gca, 'xTickLabel', cPlotNames(optimleaf))
        title('optimal leaf order')
        ylabel('Fraction or projections from subregion')
        xlabel('Convergent with projections from subregion')
        set(fig,'PaperPositionMode','auto')

        if saveFlag == 1
            saveas(fig, ['corticalProjectionsSpecialGroups/HotSpots/plots/subregionConvergence_level_', i, '.fig'], 'fig');
            print(fig, ['corticalProjectionsSpecialGroups/HotSpots/plots/subregionConvergence_level_', i, '.eps'], '-depsc2');
            close(fig)
        end
    end
end

%% 10. Make a convergence plot for the Allo-Meso-Neo groups (not used currently)

if figFlag == 10
    % targetDir = ('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/');
    cd(anaDir)
    % load('AIBS_100um.mat')
    load('injGroups_AlloMesoNeo.mat')
    ic_submask = AIBS_100um.striatum.ic_submask;

    strVolume = sum(AIBS_100um.striatum.myMask.R.mask(:).*~ic_submask(:));
    percentGcoveredByGG1 = [];
    percentGcoveredByGG2 = [];
    percentGcoveredByGG3 = [];

    percentSTRcoveredByG_GGconvergence1 = [];
    percentSTRcoveredByG_GGconvergence2 = [];
    percentSTRcoveredByG_GGconvergence3 = [];
    cPlotNames ={};

    for g = 1:length(ctx)
        cPlotNames{g} = ctx(g).name;
        contraMask = ones(size(ctx(g).mask1));
        contraMask(:, 20:54,:) = 0;
        totalProjVolume1 = sum(ctx(g).mask1(:)&contraMask(:)); % the masks are already limited by ic_submask
        totalProjVolume2 = sum(ctx(g).mask2alone(:)&contraMask(:));
        totalProjVolume3 = sum(ctx(g).mask3alone(:)&contraMask(:));

        for gg = 1:length(ctx) % I will query all subregions (gg) for convergence with each subregion (g)
            convergenceVolume1= sum(ctx(g).mask1(:)&ctx(gg).mask1(:)&contraMask(:));
            convergenceVolume2= sum(ctx(g).mask2alone(:)&ctx(gg).mask2alone(:)&contraMask(:));
            convergenceVolume3= sum(ctx(g).mask3alone(:)&ctx(gg).mask3alone(:)&contraMask(:));

            percentGcoveredByGG1(g, gg) = convergenceVolume1/totalProjVolume1;   %Rows(g) = percent of that region covered by columns(gg)
            percentGcoveredByGG2(g, gg) = convergenceVolume2/totalProjVolume2;   %Rows(g) = percent of that region covered by columns(gg)
            percentGcoveredByGG3(g, gg) = convergenceVolume3/totalProjVolume3;   %Rows(g) = percent of that region covered by columns(gg)

            percentSTRcoveredByG_GGconvergence1(g, gg) = convergenceVolume1/strVolume;   %Rows(g) = percent of that region covered by columns(gg)
            percentSTRcoveredByG_GGconvergence2(g, gg) = convergenceVolume2/strVolume;   %Rows(g) = percent of that region covered by columns(gg)
            percentSTRcoveredByG_GGconvergence3(g, gg) = convergenceVolume3/strVolume;   %Rows(g) = percent of that region covered by columns(gg)

    %         if strcmp(ctx(g).name, ctx(gg).name) % this is so I can use squareform
    %             percentGcoveredByGG1(g, gg) = 0;   
    %             percentGcoveredByGG2(g, gg) = 0;   
    %             percentGcoveredByGG3(g, gg) = 0;   
    % 
    %             percentSTRcoveredByG_GGconvergence1(g, gg) = 0;   
    %             percentSTRcoveredByG_GGconvergence2(g, gg) = 0;   
    %             percentSTRcoveredByG_GGconvergence3(g, gg) = 0;
    %         end

        end
    end

    convergence_vector = squareform(percentGcoveredByGG3);
    convergence_PairwiseDistance = pdist(percentGcoveredByGG3,'correlation');
    convergence_clustering = linkage(convergence_PairwiseDistance,'average');
    figure, dendrogram(convergence_clustering);
    optimleaf = optimalleaforder(convergence_clustering, convergence_vector);
    figure, dendrogram(convergence_clustering, 'reorder', optimleaf);

    fig = figure;
    imagesc(percentGcoveredByGG1(optimleaf, optimleaf));
    caxis([0 1])
    colormap(hot)
    set(gcf, 'Position', [6 316 829 790])
    set(gca, 'YTick', 1:length(cPlotNames))
    set(gca, 'YTickLabel', cPlotNames(optimleaf))
    set(gca, 'XTick', 1:length(cPlotNames))
    set(gca, 'xTickLabel', cPlotNames(optimleaf))
    title('optimal leaf order')
    ylabel('Fraction or proections from subregion')
    xlabel('Convergent with projections from subregion')
    set(fig,'PaperPositionMode','auto')

    if saveFlag == 1
        saveas(fig, ['corticalProjectionsSpecialGroups/typesOfCortex/plots/subregionConvergence_level_1.fig'], 'fig');
        print(fig, ['corticalProjectionsSpecialGroups/typesOfCortex/plots/subregionConvergence_level_1.eps'], '-depsc2');
        close(fig)
    end

    fig = figure;
    imagesc(percentGcoveredByGG2(optimleaf, optimleaf));
    caxis([0 1])
    colormap(hot)
    set(gcf, 'Position', [6 316 829 790])
    set(gca, 'YTick', 1:length(cPlotNames))
    set(gca, 'YTickLabel', cPlotNames(optimleaf))
    set(gca, 'XTick', 1:length(cPlotNames))
    set(gca, 'xTickLabel', cPlotNames(optimleaf))
    title('optimal leaf order')
    ylabel('Fraction or proections from subregion')
    xlabel('Convergent with projections from subregion')
    set(fig,'PaperPositionMode','auto')

    if saveFlag == 1
        saveas(fig, ['corticalProjectionsSpecialGroups/typesOfCortex/plots/subregionConvergence_level_2.fig'], 'fig');
        print(fig, ['corticalProjectionsSpecialGroups/typesOfCortex/plots/subregionConvergence_level_2.eps'], '-depsc2');
        close(fig)
    end

    fig = figure;
    imagesc(percentGcoveredByGG3(optimleaf, optimleaf));
    caxis([0 1])
    colormap(hot)
    set(gcf, 'Position', [6 316 829 790])
    set(gca, 'YTick', 1:length(cPlotNames))
    set(gca, 'YTickLabel', cPlotNames(optimleaf))
    set(gca, 'XTick', 1:length(cPlotNames))
    set(gca, 'xTickLabel', cPlotNames(optimleaf))
    title('optimal leaf order')
    ylabel('Fraction or proections from subregion')
    xlabel('Convergent with projections from subregion')
    set(fig,'PaperPositionMode','auto')

    if saveFlag == 1
        saveas(fig, ['corticalProjectionsSpecialGroups/typesOfCortex/plots/subregionConvergence_level_3.fig'], 'fig');
        print(fig, ['corticalProjectionsSpecialGroups/typesOfCortex/plots/subregionConvergence_level_3.eps'], '-depsc2');
        close(fig)
    end
end

% EX of the plot idea:
% X=rand(10);
%   imagesc(X);
%   colormap(jet);    % instead of 'jet' try 'gray', 'bone', 'spring',...
%                     % >>help colormap for more color options.
%   set(gca,'XTickLabel',{''})  % to remove x tick labels
%   set(gca,'YTickLabel',{''})  % to remove y tick labels
%   set(gca,'XTick',[])         % to remove x ticks
%   set(gca,'YTick',[])         % to remove y ticks

%% For lab meeting Journal club
%%%% Trying to make a quick figure for mPFC (PrL/MO (9) + ACC (1)) / Parietal (10) / VO/LO (8) convergence

% % 
% % mPFC1 = logical(injGroup_data(9).mask1.ipsilateral + injGroup_data(9).mask1.contralateral +  injGroup_data(1).mask1.ipsilateral + injGroup_data(1).mask1.contralateral);
% % mPFC2 = logical(injGroup_data(9).mask4.ipsilateral + injGroup_data(9).mask4.contralateral + injGroup_data(1).mask4.ipsilateral + injGroup_data(1).mask4.contralateral); 
% % 
% % OFC1 = logical(injGroup_data(8).mask1.ipsilateral + injGroup_data(8).mask1.contralateral);
% % OFC2 = logical(injGroup_data(8).mask4.ipsilateral + injGroup_data(8).mask4.contralateral);
% % 
% % PTL1 = logical(injGroup_data(10).mask1.ipsilateral + injGroup_data(10).mask1.contralateral);
% % PTL2 = logical(injGroup_data(10).mask4.ipsilateral + injGroup_data(10).mask4.contralateral);
% %                 
% %                 
% % PFCvOFC1 = mPFC1 & OFC1; 
% % PFCvOFC2 = mPFC2 & OFC2; 
% % 
% % PFCvPTL1 = mPFC1 & PTL1;
% % PFCvPTL2 = mPFC2 & PTL2;
% % 
% % OFC1vPTL1 = OFC1 & PTL1;
% % OFC1vPTL2 = OFC2 & PTL2;
% % 
% % PFCvOFC1vPTL1 = mPFC1 & OFC1 & PTL1; 
% % PFCvOFC1vPTL2 = mPFC2 & OFC2 & PTL2;
% % 
% % conv = {'PFCvOFC1'; 'PFCvOFC2'; 'PFCvPTL1';'PFCvPTL2';'OFC1vPTL1';'OFC1vPTL2';'PFCvOFC1vPTL1';'PFCvOFC1vPTL2'};
% % for i = 1:length(conv)
% %     convGroup(i).name = conv{i};
% % end
% % convGroup(1).group = mPFC1 & OFC1;
% % convGroup(2).group = mPFC2 & OFC2; 
% % convGroup(3).group = mPFC1 & PTL1;
% % convGroup(4).group = mPFC2 & PTL2;
% % convGroup(5).group = OFC1 & PTL1;
% % convGroup(6).group = OFC2 & PTL2;
% % convGroup(7).group = mPFC1 & OFC1 & PTL1; 
% % convGroup(8).group = mPFC2 & OFC2 & PTL2;
% % 
% % 
% % for b = 1:length(conv)
% %     currentGroup = conv{b};
% %     for i = 35:3:78 %This is strstrt to strnd     %1:length(smallmodel);
% %         
% % %         currentSlice(:, :, 1) = convGroup(1).group(:,:,i);
% % %         currentSlice(:, :, 2) = convGroup(3).group(:,:,i);
% % %         currentSlice(:, :, 3) = convGroup(5).group(:,:,i);
% %         currentSlice = convGroup(1).group(:,:,i);
% %         
% %         fig = figure; h_imagesc(currentSlice); hold on
% %         outline = h_getNucleusOutline(smallmodel(:,:,i));
% %         for j = 1:length(outline)
% %             plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'c-', 'linewidth',1)
% %         end
% %         oAIBS = h_getNucleusOutline(logical(imfill(averageTemplate100um(:, :, i)>50, 'holes')));
% %         for j = 1:length(oAIBS)
% %             plot((oAIBS{j}(:,2)), (oAIBS{j}(:,1))+0.5, 'w-', 'linewidth',1.25)
% %         end
% %         oACA = h_getNucleusOutline(averageTemplateACA(:,:,i));
% %         for j = 1:length(oACA)
% %             plot((oACA{j}(:,2)), (oACA{j}(:,1))+0.5, 'c-', 'linewidth',0.5)
% %         end
% %         hold off
% %         
% % 
% % %         saveas(fig, ['corticalProjections/slices/', injGroup_data(g).cortical_group, '/summedCorticalGroup_',injGroup_data(g).cortical_group, '_slice',num2str(i),'.fig'], 'fig');
% % %         print(fig, ['corticalProjections/slices/', injGroup_data(g).cortical_group, '/summedCorticalGroup_', injGroup_data(g).cortical_group, '_slice',num2str(i), '.eps'], '-depsc2');
% % %         close(fig)
% %     end
% % % end