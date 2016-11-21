function jh_voxelClustering_striatum(level, numberOfClusters, method, figFlag, saveFlag)
% [vargout] = JH_VOXELCLUSTERING_STRIATUM(levels, numberOfClusters, method, figFlag, saveFlag) 
% 
% INPUTS: levels: (1-4) indicates the confidence levels to use for (clustering *Used 3 for publication)
%             *1 = diffuse
%             *2 = diffuse and dense
%             *3 = diffuse, intermediate, and dense
%             *4 = dense only
%         numberOfClusters: this determines the number of colored clusters (can be an array: [2 3 4 15])
%         method: Enter number(s) of the clustering methods: (*can also be an array to try several at once)
%             (1. 'correlation', 2. 'chebychev', 3. 'cityblock', 4. 'cosine', 5. 'euclidean', 6. 'hamming', 7. 'jaccard', 8. 'minkowski', 9. 'spearman');
%             (* Published with 9. 'spearman') 
%         figFlag (1 or 2) 
%             1. Generate cluster data, (save cluster description figs and clusterMasks_#clusters.mat)
%             2. Quantify input sources of each cluster
%             3. Plot input sources of each cluster
%             4. A couple reordered versions of the plots created in 3
%         saveFlag (0 or 1) do you want to save all the outputs from this 
% 
%         ** To regenerate publication data: jh_voxelClustering_striatum(3, [2 3 4 15], 9, 1)
% 
% OUTPUT: all cluster related data and figures
% 
% PURPOSE: This takes the corticostriatal data and clusters striatal voxels based on cortical input similarity, and then quantifies properties of the resulting clusters
% 
% DEPENDENCIES: 
%     /auxillary_funcitonsAndScripts/h_getNucleusOutline.m
%     /auxillary_funcitonsAndScripts/h_imagesc.m
%     'Image Processing Toolbox' ; 'Statistics and Machine Learning Toolbox'
% 


% Load initial datasets / setting up directories %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Where is the analyzed corticostriatal data folder (jh_consolidatingAIBSdatasets.m output)?')
% likely here: '/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed4'
anaDir= uigetdir('/', 'Where is the analyzed corticostriatal data folder?');
cd(anaDir)

cd ..
if ~exist('clustering/')
    mkdir('clustering/')
end
saveDir = ([cd, '/clustering/']); 


% Random Manual masks that need to be collected for this to work:
disp('Where are the collected masks?')
randomMasksDir = uigetdir('/', 'Where are the collected masks?');
% randomMasksDir = '/Users/jeaninehunnicutt/Desktop/github/anatomy/Matlab/masks'; %%%%%%%%%% change to above after testing %%%%%%%%%%%%%%%%
        
load([randomMasksDir, '/AIBS_100um.mat'])
load([anaDir, '/injGroup_data.mat']) 

%% 1. Generate striatal clusters based on cortical inputs (heavily modified version based of brl_voxelClustering)
% 
  
if figFlag == 1
    for confidenceLevels = level %3  %1:4
        for dm = method %[9] %1:9;
            distanceMethods = {'correlation', 'chebychev', 'cityblock', 'cosine', 'euclidean', 'hamming', 'jaccard', 'minkowski', 'spearman'};
            distanceMethod = distanceMethods{dm};
            for numClusters = numberOfClusters %[11 12 13 14]

                set(0,'RecursionLimit',1000) % When it's creating the dendrogram clusters, it tends to fail if you dont do this 

                tic

                fullModelStriatum = AIBS_100um.striatum.myMask.Full.mask.*~AIBS_100um.striatum.ic_submask;  % Ipsi = (26:68, 62:96,35:78) Contra = (26:68, 20:54 ,35:78)
                corticalGroup = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'SS', 'Vis', 'SUB_HIPP', 'Amyg', 'SNr', 'na'};

                for i = 1:length(corticalGroup)
                    c1 = (injGroup_data(i).mask1.ipsilateral + injGroup_data(i).mask1.contralateral).*~AIBS_100um.striatum.ic_submask;
                    c2 = (injGroup_data(i).mask2.ipsilateral + injGroup_data(i).mask2.contralateral).*~AIBS_100um.striatum.ic_submask;
                    c3 = (injGroup_data(i).mask5.ipsilateral + injGroup_data(i).mask5.contralateral).*~AIBS_100um.striatum.ic_submask;
                    if confidenceLevels == 1;     %This essentially determines the number of confidence levels used for clustering.
                        MapInModel2{i} = double(c1);
                    elseif confidenceLevels == 2;
                        MapInModel2{i} = c1 + c3; 
                    elseif confidenceLevels == 3;
                        MapInModel2{i} = c1 +c2 + c3;
                    elseif confidenceLevels == 4;
                        MapInModel2{i} = double(c3);
                    end

                end

                projFields = corticalGroup';

                % distanceMethod = 'spearman';%'cosine'; %'correlation'*; %'chebychev'; %'minkowski'; %'jaccard'; %'hamming'; %'spearman'*;%'cityblock'; %'euclidean';
                % I either want to use jaccard, spearman or just correlation. 
                %   -Spearman and Correlation look really simmilar

                if ~exist([saveDir, distanceMethod,  'Detailed_Clustering_', num2str(confidenceLevels), 'levels/data']);
                    mkdir([saveDir, distanceMethod,  'Detailed_Clustering_', num2str(confidenceLevels), 'levels/slices']);
                    mkdir([saveDir, distanceMethod,  'Detailed_Clustering_', num2str(confidenceLevels), 'levels/data']);
                end

                if ~exist([saveDir, distanceMethod,  'Detailed_Clustering_', num2str(confidenceLevels), 'levels/analysis/plots']);
                    mkdir([saveDir, distanceMethod,  'Detailed_Clustering_', num2str(confidenceLevels), 'levels/analysis/plots']);
                end

                %%  now crop just  ipsilateral and downsample these guys to  150  um voxels...

        %     % crop the model and projection maps
                modelStriatumIpsi = fullModelStriatum(26:68, 62:96,35:78);    % 43x35x44 from 81x115x133
                modelStriatumContra = fullModelStriatum(26:68, 20:54 ,35:78);
                for i=1:numel(MapInModel2)
                    cMapInModel2{i} = MapInModel2{i}(26:68, 62:96,35:78); 
                end

                [x, y, z]= meshgrid(1:35, 1:43, 1:44);
                [xi, yi, zi] = meshgrid(1:1.5:35, 1:1.5:43, 1:1.5:44); %150x150x150um voxels

                % downsample the projection maps:
                for i=1:numel(cMapInModel2)
                    downsampledCMAP{i} = round(interp3(x, y,z, cMapInModel2{i}, xi, yi, zi));  % added 'round' here to put data back to initial space.  
                end

                % % and the model thalamus rescaled to (150um)^3 voxels
                smallmodel = interp3(x, y,z, double(modelStriatumIpsi(:,:,:)), xi, yi, zi);

                % Matlab may have a hard time running this with smaller voxels than about 100um on a side


                %% Only use "these" areas for clustering...

                projAreasToKeep = find(~ismember(projFields,{'SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'na', 'SNr'})); % i.e. skip this list

    %             allocortex = find(ismember(projFields,ctx(1).regions)); %not using yet, may later 5/10/15
    %             mesocortex = find(ismember(projFields,ctx(2).regions));
    %             neocortex = find(ismember(projFields,ctx(3).regions));

                % nofra = [2 3 5:9 11]
                downsampledCMAP = downsampledCMAP(projAreasToKeep);
                % this allows me to drastically reduce the number of points on which to
                % calculate the pairwise distance. 

                % JH: I dont like this, i want it to keep the whole striatum..%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Test Removal 5/17/15  --> same
                sumDownsampledCMAP = zeros(size(downsampledCMAP{1}));
                for i =1:numel(downsampledCMAP)
                    sumDownsampledCMAP = sumDownsampledCMAP+downsampledCMAP{i};
                end
                keepList = find(sumDownsampledCMAP(:)>0); %HN: this is a list of pixels associated with at leat one confidence map in the model thalamus.
    %             keepList = find(smallmodel(:)>0);
                %%  now perpare to do clustering:


                toCluster=zeros(length(keepList),numel(downsampledCMAP)); %Set up an array where columns are the input regions and rows are voxels -jh
                for i= 1:numel(downsampledCMAP)
                    toCluster(:,i) = downsampledCMAP{i}(keepList)';
                end

                % generate the relevant pairwise distance
                pnames = projFields(projAreasToKeep); 
                % distanceMethod = 'cityblock';   % here I use the cityblock metric, which is appropriate for discretized data. 
                                                % basically, this is acknowledging that the underlying data
                                                % (confidence maps) only know about integer values, not anywhere inbetween

                voxelPairwiseDistance = pdist(toCluster,distanceMethod);
                if sum(find((isnan(voxelPairwiseDistance)))) > 0 
                    display([distanceMethod, ': using ', num2str(confidenceLevels), ' levels & ', num2str(numClusters), ' Clusters had NaNs in voxelPairwiseDistance: SKIPPED'])
                else


                    nucleusPairwiseDistance = pdist(toCluster',distanceMethod);

                    %  with the workspace loaded above, size(a) is  1     1574425 %HN: old data but should be comparable.

                    %  JH: these are really sensitive to N... the average clustering goes from
                    %  normal times (A few seconds) to hanging with voxel size from 100x100x100 to 150x150x150 

                    voxelLinkage = linkage(voxelPairwiseDistance,'average');
                    nucleusLinkage = linkage(nucleusPairwiseDistance,'average');
                    %zzS= linkage(a); % shortest distance, not used anymore


            % 5/10/15 Here I want to quantitatively determine which clustering method to use: *******************************************************************************************************
            %          1. calculate the inconsistency coeficient and save it
            %          2. use cluster to determine the cluster groups based on the inconsistency coefficient
    % %                 distanceMethods = {'correlation', 'chebychev', 'cityblock', 'cosine', 'euclidean', 'hamming', 'jaccard', 'minkowski', 'spearman'};
    % %                 for m = 1:length(distanceMethods)
    % %                     distanceMethod = distanceMethods{m};
    % %                     voxelPairwiseDistance = pdist(toCluster,distanceMethod);
    % %                     voxelLinkage= linkage(voxelPairwiseDistance,'average');
    % %                     
    % %                     clusterCutoff = 10.23;
    % %         %             numClusters = 5;         %*******specified at the top. 
    % %                     
    % %                     cophCoef(m).method = distanceMethod;
    % %                     cophCoef(m).coefficient = cophenet(voxelLinkage, voxelPairwiseDistance);
    % %                     cophCoef(m).inconsistency = inconsistent(voxelLinkage, 100);  %The 500 is the number of levels up it will calculate... I am just trying to put a number higher than the most
    % %         %             cophCoef(m).clusters = cluster(voxelLinkage, 'cutoff', clusterCutoff,'depth', 100);
    % %                     cophCoef(m).clusters = cluster(voxelLinkage, 'maxclust', numClusters);
    % %                     cophCoef(m).clusterCutoff = clusterCutoff;
    % %                     cophCoef(m).clusterNumber =  max(cophCoef(m).clusters(:));
    % %                     colorC = voxelLinkage(end-cophCoef(m).clusterNumber+2,3)-eps;    %this is a weird work around that would require checking, the one i tried had 2 weird NaN values at the end that made it give me 3 clusters instead of 5... 
    % %                     
    % %                     figure, dendrogram(voxelLinkage, 0, 'colorthreshold', colorC)
    % %                     title([distanceMethod, 'cophenetic coef. = ',num2str(cophCoef(m).coefficient)])
    % %                     axis('auto')
    % %                 end
    % %                 
    % %                 dist = pdist(data, 'euclidean');
    % %                 link = linkage(dist, 'complete');
    % %                 clust = cluster(link, 'cutoff', .7);
    % %                 NumCluster = max(clust(:));
    % %                 color = link(end-NumCluster+2,3)-eps;
    % %                 [H,T,perm] = dendrogram(link, 0, 'colorthreshold', color);
    % %                 
    % %                 for m = 1:length(distanceMethods)
    % %                     display([distanceMethods{m},' = ',num2str(cophCoef(m).coefficient),'     Max inconsistency = ',num2str(max(cophCoef(m).inconsistency(:, 4)))])
    % %                 end
            %         
            %         T = cluster(voxelLinkage, 'cutoff', 0.9);
            %%%%%%%%%%%%%%%%%%%  **************************************************************************************************************************************************************************

                    toc
                    % this takes about 6s for the loaded workspace 
                    %
                    cd([saveDir, distanceMethod, 'Detailed_Clustering_', num2str(confidenceLevels), 'levels'])

                    % % Testing
            %         numClusters = 5;
                    clusters = cluster(voxelLinkage, 'maxclust', numClusters);
    %                 T = cluster(voxelLinkage, 'maxclust', numClusters);
                    nc2 = numClusters;

                    badC = 0;
                    goodC = 0;
                    % JH: a lot of times there are groups with only 1 voxel, in which case it wont be colored and wont be counted with numOfClusters = max(colorGrp)
                    % This will keep adding to the cluster number until the sum of clusters with more than 1 voxel = numClusters
                    while goodC < numClusters
                        goodC = 0;
                        for i = 1:max(cluster(voxelLinkage, 'maxclust', nc2))
                            if length(find(clusters == i)) <= 1
                                badC = badC + 1;
                            else
                                goodC = goodC + 1;
                            end
                        end

                        if goodC == numClusters
                            break
                        elseif badC > 0
                            nc2 = nc2+1;
                            clusters = cluster(voxelLinkage, 'maxclust', nc2);
                        end
                    end

                    for n = length(voxelLinkage):-1:1   %I think I got rid of this problem by ending the loop above if NaNs exist, but it doesnt hurt.
                        if ~isnan(voxelLinkage(n, 3))
                            colorC = voxelLinkage(n-nc2+2,3);
                            break
                        end
                    end

                    h_fig = figure;
                    % [h2, dend2a, PERM] = dendrogram(voxelLinkage, 0, 'colorthreshold', 43);%all pixel clustering
                    [h2, dend2a, PERM, colorGrp, cmap, voxelColorIdentity] = h_dendrogram(voxelLinkage, 0, 'colorthreshold', colorC); %voxelClusterThreshold); %all pixel clustering ****!!!! JH- Change the last input number to set the threshold for cluster coloring (based on the y axis in the voxel dendrogram)
                        % PERM is the voxels reordered, dend2a is a list of the unordered voxels (1, 2, 3)
                        % colorGrp is wrong for too many clusters....?
                    xL1 = str2num((get(gca,'XtickLabel'))); % this is the position number in 'toCluster'. xL1 is the same as PERM on above line. (translation: original voxel number in the order assigned by the clustering)  *this is just PERM' ... 
                    voxelColors = sortrows(voxelColorIdentity(:, 2:3));

                    numOfClusters = max(colorGrp)
                    title([distanceMethod, ' voxel dendrogram'])
                    set(gcf, 'position', [1 650 1500 500])

                    if saveFlag == 1
                        saveas(h_fig,['voxelDendrogram_', num2str(numOfClusters), 'clusters.fig'],'fig');
                        print(h_fig, ['voxelDendrogram_', num2str(numOfClusters), 'clusters.eps'], '-depsc2');
                    end

                    close(h_fig)

                    toc


                    fig = figure;
                    [dend1, dend2, PERM2] = dendrogram(voxelLinkage, numOfClusters);  % THIS SETS THE NUMBER OF CLUSTERS %HN: dend1 is a list of handles. dend2 are the leaf node index.
                    cluster10order = str2num((get(gca,'XtickLabel')));

                    if saveFlag == 1
                        saveas(fig,['voxelClusterDendrogram_',num2str(numOfClusters),'clusters.fig'],'fig');
                        print(fig, ['voxelClusterDendrogram_',num2str(numOfClusters),'clusters.eps'], '-depsc2');
                    end
                    close(fig)


                    fig = figure;
                    h3 = dendrogram(nucleusLinkage);%this is the nucleus clustering ....JH- I think this actually means nuclear group clustering, chich translates to cortical input for this analysis 
                    xLT1 = str2num((get(gca,'XtickLabel')));  % the assignments for the cortical clusters
                    set(gca,'XtickLabel', pnames(xLT1));

                    %set(get(gca,'title'), 'string', 'blue trace' )
                    bip(gca)
                    scrsz = get(0, 'ScreenSize');
                    set(gcf, 'Position', [1 scrsz(4)/1 scrsz(3)/1.5 scrsz(4)/4]);
                    set(gcf,'PaperPositionMode','auto')
                    title([distanceMethod, ' brain region dendrogram'])
                    set(gca,'FontSize', 9);

                    if saveFlag == 1
                        saveas(fig,['brainAreaDendrogram_', num2str(numOfClusters), 'clusters.fig'],'fig');
                        print(fig, ['brainAreaDendrogram_', num2str(numOfClusters), 'clusters.eps'], '-depsc2');
                    end
                    close(fig)

                    %note:  there seems to be some problems with the dendrogram associated with
                    %  average linkage   clustering of cityblock pdist data with or without FrA.  if you ask for a limited number of clusters
                    %  (e.g. 40 total clusters), Matlab slogs for a few minutes and then complains
                    %  about recursion limits.  
                    % dendrogram works ok with no limit on cluster number.  maybe this is the
                    % result of using the average linkage


                    %  organize rows and columns of tocluster based on these clusters:
                    %  figure 4 d with y axis inverted
                    fig = figure;
                    h_imagesc(toCluster(xL1, xLT1));%this is the cluster image.
                    title([distanceMethod, ' voxels'])
                    axis normal

                    if saveFlag == 1
                        saveas(fig,'clusteredVoxels.fig','fig');
                        print(fig, 'clusteredVoxels.eps', '-depsc2');
                        print(fig, '-dtiff', 'clusteredVoxels.tif');
                    end
                    close(fig)

                    %%   are these spatially localized?  One way to look at this is just to
                    %   plot different colored symbols for each cluster in 3D.  this plot isn't
                    %   used in the paper

                    % switch from index to subsrcipt:

                    % [cr cc cz] = ind2sub(size(downsampledCMAP{1}),keepList(xL1));

                    %% % may be useful % not useful
                    cmap2 = jet;
                    % close(gcf)
                    %%%%%%  only using the cool colors here 10/3
                    ncolor_range = max(dend2);
                    interpJet=[];
                    interpJet(:,1) = interp1(1:45, cmap2(1:45,1), linspace(1,45,ncolor_range));
                    interpJet(:,2) = interp1(1:45, cmap2(1:45,2), linspace(1,45,ncolor_range));
                    interpJet(:,3) = interp1(1:45, cmap2(1:45,3), linspace(1,45,ncolor_range));


                    %%  yet another idea:  make the clusters () into binary masks, then
                    %  smooth them and eliminate things smaller than a few voxels.  then
                    %  compare these to nuclei.

                    % % % % I am using the one below because using colorGrp for the voxel indices has problems with too many clusters
                    % % % 
                    % % % [cr, cc, cz] = ind2sub(size(downsampledCMAP{1}),keepList(xL1));
                    % % % 
                    % % % pixelInd = colorGrp(xL1);
                    % % % fig = figure;
                    % % % plot(pixelInd);     % This is the plot that shows the group that each voxel in the dendrogram is assigned (this showed me that the 61 clusters was wrong) - JH
                    % % % saveas(fig,'colorGroupNumber.fig','fig');
                    % % % print(fig, 'colorGroupNumber.eps', '-depsc2');
                    % % % 
                    % % % % pixelInd2 = zeros(size(pixelInd));
                    % % % % index = zeros(max(dend2),1);
                    % % % % j = 0;
                    % % % % for i = 1:length(pixelInd);
                    % % % %     if ~ismember(pixelInd(i),index)
                    % % % %         j = j + 1;
                    % % % %         index(j) = pixelInd(i);
                    % % % %     end
                    % % % %     pixelInd2(i) = j;% this is to convert the index to an index corresponding to the cmap below and the same as in the dendrogram.
                    % % % % end
                    % % % 
                    % % % clusterMask=zeros(size(downsampledCMAP{1}));
                    % % % for i= 1:numel(cr)
                    % % %     clusterMask(cr(i), cc(i),cz(i)) = pixelInd(i);%HN: seem like we can get figure 4e out of this.
                    % % % end
                    % % % clusterMask(size(downsampledCMAP{1},1),size(downsampledCMAP{1},2),size(downsampledCMAP{1},3))=0;

                    %%%%%% For lots of clusters (Used to mess up the colors, but that was fixed by creating the voxelColors variable
                    [crX, ccX, czX] = ind2sub(size(downsampledCMAP{1}),keepList(xL1));

                    voxelColors2 = ones(length(xL1), 1);
                    voxelColors2(2:end, 1) = voxelColors(:, 2);
                    voxelColors2(1) = voxelColors2(2);  %This is a terrible way of doing this, but voxelColors has the first voxel truncated for some reason
                    pixelIndX = voxelColors2(xL1);
                    pixelDendrogram = dend2(xL1);

                    %%%%% This gives the real cluster numbers for the original dendrogram and
                    %%%%% the their corresponding color in cmap
                    realDendrogramOrder = unique(pixelDendrogram, 'stable')';   % b/c the order shown in the voxelClusterDendrogram can have rotated nodes!
                    voxelColorsOrdered = voxelColors2(PERM);
                    dendrogramColors = unique(voxelColorsOrdered, 'stable')';
                    realDendrogramOrderColors = [];
                    for i = 1:max(dendrogramColors)
                        if dendrogramColors(i) <= max(dend2);
                            realDendrogramOrderColors = cat(2, realDendrogramOrderColors, dendrogramColors(i));
                        end
                    end


                    fig = figure;
                    plot(pixelDendrogram);

                    if saveFlag == 1
                        saveas(fig,'colorGroupNumber.fig','fig');
                        print(fig, 'colorGroupNumber.eps', '-depsc2');
                    end
                    close(fig)
                    % pixelInd2 = zeros(size(pixelInd));
                    % index = zeros(max(dend2),1);
                    % j = 0;
                    % for i = 1:length(pixelInd);
                    %     if ~ismember(pixelInd(i),index)
                    %         j = j + 1;
                    %         index(j) = pixelInd(i);
                    %     end
                    %     pixelInd2(i) = j;% this is to convert the index to an index corresponding to the cmap below and the same as in the dendrogram.
                    % end

                    clusterMaskX=zeros(size(downsampledCMAP{1}));
                    for i= 1:numel(crX)
                        clusterMaskX(crX(i), ccX(i),czX(i)) = pixelIndX(i);%HN: seem like we can get figure 4e out of this.
                    end
                    clusterMaskX(size(downsampledCMAP{1},1),size(downsampledCMAP{1},2),size(downsampledCMAP{1},3))=0;

                    clusterMask = clusterMaskX;
                    % % % 


                    %  now make separate masks
                    cMask=[];
                    % clustertotal=[]
                    for i = 1:max(clusterMask(:));
                        cMask{i} = clusterMask==i;
                    %     clustertotal(i) = sum(cmask{i}(:));
                    end

                    %HN: the lines below are for outputing slices only. Can be commented out
                    % when not used.

                    clusterMask2 = clusterMask;


                    %% This will create and save binary masks separately for each cluster created
                    clusterMasks = [];
                    for i = 1:numOfClusters;
                        clusterMasks(i).mask =  clusterMask2(:,:,:) == i;
                        clusterMasks(i).clusterNumber = num2str(i);  % This is the way that the clusters correspnd to the cluster mask
                        clusterMasks(i).clusterNumberReal = num2str(realDendrogramOrder(find(realDendrogramOrderColors == i)));  % These are the true assigned cluster numbers, use for labeling
                        clusterMasks(i).clusterColor = num2str(i); % This is true, and a mess
                        clusterMasks(i).totalClusters = numOfClusters;
                        clusterMasks(i).totalClustersAskedFor = nc2;
                        clusterMasks(i).threshold = colorC; % Used to be: voxelClusterThreshold; when i was manually selecting the treshold, but now I am manually selecting the number of clusters...
                        clusterMasks(i).clusteringMethod = distanceMethod;
                    %     clusterMasks(i).clusterOrder = cluster10order; %% This is the way that the clusters correspnd to the cluster mask
                        clusterMasks(i).clusterOrderReal = realDendrogramOrder; % These are the true assigned cluster numbers, use for labeling
                        clusterMasks(i).clusterColor = cmap;
                        clusterMasks(i).clusterColorReal = realDendrogramOrderColors;
                        clusterMasks(i).corticalClusterOrder = xLT1;    % This is the order of the inputs that the clustering is based on (cortical fields)
                        clusterMasks(i).voxelClusterOrder = xL1;        % the value of XL1 is the order of the clustered voxels
                        clusterMasks(i).voxelColorGroup = dend2;   % dend2(XL1(i)) returns the color group associated with the clustered voxels, else colorGroup(i) returns the original unclustered order
                    end

                    if saveFlag == 1
                        save(['data/clusterMasks_', num2str(numOfClusters), 'clusters.mat'],['clusterMasks']);
                    end


                    %% This will create coronal sections through the clusters and save them

                    % % % cmap = cmapDend2;

                    sliceNums = 1:length(smallmodel);
                    for i = sliceNums
                        outline = h_getNucleusOutline(smallmodel(:,:,i));
                    % This just makes the mask withe the outline 
                    %     fig = figure; h_imagesc(smallmodel(:,:,i));hold on
                    %     for j = 1:length(outline)
                    %         plot((outline{j}(:,2)), (outline{j}(:,1)), 'm-', 'linewidth',2);
                    %         %new coordinate is: (x-(1+factor)/2)/factor+1=(x-0.5)/factor+1/2.
                    %     end 
                    %     saveas(fig, ['modelThalamus_slice',num2str(i),'.fig'], 'fig')
                    %     print(fig, ['modelThalamus_slice',num2str(i), '.eps'], '-depsc2');
                    %     close(fig)
                        currentSlice = clusterMask2(:,:,i);
                        colorImg_r = zeros(size(currentSlice));
                        colorImg_g = zeros(size(currentSlice));
                        colorImg_b = zeros(size(currentSlice));
                        for j = 1:max(clusterMask2(:))
                            BW = currentSlice==j;
                            colorImg_r(BW) = cmap(j,1);
                            colorImg_g(BW) = cmap(j,2);
                            colorImg_b(BW) = cmap(j,3);
                        end
                        colorImg = cat(3,colorImg_r,colorImg_g,colorImg_b);
                    %     fig = figure; h_imagesc(clusterMask2(:,:,i),[0,max(clusterMask2(:))]); colormap(cmap3);hold on
                        fig = figure; h_imagesc(colorImg); hold on
                        for j = 1:length(outline)
                            plot((outline{j}(:,2)), (outline{j}(:,1)), 'w-', 'linewidth',2)
                        end



                        if saveFlag == 1
                            saveas(fig, ['slices/pixelGroup_',num2str(numOfClusters), 'clusters_slice',num2str(i),'.fig'], 'fig');
                            print(fig, ['slices/pixelGroup_', num2str(numOfClusters), 'clusters_slice',num2str(i), '.eps'], '-depsc2');
                        end
                        close(fig)

                    end
                end
            end
        end
    end 
end



%% 2. Quanify & Plot the source of the input overlap in the striatal clusters
%

if figFlag == 2
    ic_submask = AIBS_100um.striatum.ic_submask;

    fullModelStriatum = AIBS_100um.striatum.myMask.Full.mask&~ic_submask;  % Ipsi = (26:68, 62:96,35:78) Contra = (26:68, 20:54 ,35:78)

    distanceMethods = {'correlation', 'chebychev', 'cityblock', 'cosine', 'euclidean', 'hamming', 'jaccard', 'minkowski', 'spearman'};
    corticalGroup = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'SS', 'Vis', 'SUB_HIPP', 'Amyg', 'SNr', 'na'};
    projFields = corticalGroup';
    projAreasToKeep = find(~ismember(projFields,{'SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'na', 'SNr'}));


    % crop the model and projection maps
    modelStriatumIpsi = fullModelStriatum(26:68, 62:96,35:78);    % 43x35x44 from 81x115x133
    modelStriatumContra = fullModelStriatum(26:68, 20:54 ,35:78);
    [x, y, z]= meshgrid(1:35, 1:43, 1:44);
    [xi, yi, zi] = meshgrid(1:1.5:35, 1:1.5:43, 1:1.5:44); %150x150x150um voxels
    % % and the model thalamus rescaled to (150um)^3 voxels
    smallmodel = interp3(x, y,z, double(modelStriatumIpsi(:,:,:)), xi, yi, zi);

    %% This generates and saves the variables quantifying inputs to clusters
    for confidenceLevels = level %3  %1:4
        for dm = method %[9] %1:9;
            distanceMethod = distanceMethods{dm};
    %         for numClusters = [2 3 4 5 6 7 8 9 10 15 20]
    %             
            % Load the cluster data
            targetDir=([saveDir, distanceMethod, 'Detailed_Clustering_', num2str(confidenceLevels), 'levels/data']);
            cd(targetDir);
            d=dir; % d(1:3)=[];
            a = 1;
            for j = 1:length(d)     %I'm finding/removing those weird files here
                if length(d(j).name) > 15
                    d2(a)=d(j);
                    a = a+1;
                end
            end
            d = d2';


            for i = 1:length(corticalGroup) % mask1=0.5%, mask2=5%, mask3=10%, mask4=15%, mask5=20% 
                c1 = (injGroup_data(i).mask1.ipsilateral + injGroup_data(i).mask1.contralateral).*~AIBS_100um.striatum.ic_submask;
                c2 = (injGroup_data(i).mask2.ipsilateral + injGroup_data(i).mask2.contralateral).*~AIBS_100um.striatum.ic_submask;
                c3 = (injGroup_data(i).mask5.ipsilateral + injGroup_data(i).mask5.contralateral).*~AIBS_100um.striatum.ic_submask;
                if confidenceLevels == 1;     %This essentially determines the number of confidence levels used for clustering.
                    MapInModel2{i} = double(c1);
                elseif confidenceLevels == 2;
                    MapInModel2{i} = c1 + c3; 
                elseif confidenceLevels == 3;
                    MapInModel2{i} = c1 +c2 + c3;
                elseif confidenceLevels == 4;
                    MapInModel2{i} = double(c3);
                end
            end
            for i=1:numel(MapInModel2)
                cMapInModel2{i} = MapInModel2{i}(26:68, 62:96,35:78); 
            end

            % downsample the projection maps:
            for i=1:numel(cMapInModel2)
                downsampledCMAP{i} = round(interp3(x, y,z, cMapInModel2{i}, xi, yi, zi));  % added 'round' here to put data back to initial space.  
            end

             % Get all the cluster data in the correct orientation and scale
            for p = 1:3; % This is looping through the 3 density thresholds of the grouped cortical areas, accounted for in the clustering with the 'levels' input    
                for k = 1: length(corticalGroup)
                    eval(['maskR_downsampled{k}.mask', num2str(p), ' = downsampledCMAP{k}>=', num2str(p), ';'])
    %                 croppedMask = [];
    %                 eval(['mask', ' = ' , '(injGroup_data(k).mask', num2str(p), '.ipsilateral + injGroup_data(k).mask', num2str(p), '.contralateral).*~ic_submask;']);
    %                 mask = double(mask);
    %                  % THis used to have a rotation step in it, but I dont need to rotate anymore(Rotate each confidence map matrix so that z is the A-P axis)
    %                 croppedMask = mask(26:68, 62:96,35:78); % limit to the max size of the striatum
    %                 
    %                 eval(['maskR{k}.mask', num2str(p), ' = ' , 'croppedMask;']);
    % 
    %                 maskR_downsampled{k}.cortical_group  = injGroup_data(k).cortical_group;
    %                 eval(['maskR_downsampled{k}.mask', num2str(p), ' = ' , 'round(interp3(x, y,z, croppedMask, xi, yi, zi));']); 
                end
            end

    % % % %    %%%THis was a fucking shit show, no idea how, but the masks are slightly off
    % % % %          % Get all the cluster data in the correct orientation and scale
    % % % %         for p = 1:3; % This is looping through the 3 density thresholds of the grouped cortical areas, accounted for in the clustering with the 'levels' input    
    % % % %             for k = 1: length(corticalGroup)
    % % % %                 croppedMask = [];
    % % % %                 eval(['mask', ' = ' , '(injGroup_data(k).mask', num2str(p), '.ipsilateral + injGroup_data(k).mask', num2str(p), '.contralateral).*~ic_submask;']);
    % % % %                 mask = double(mask);
    % % % %                  % THis used to have a rotation step in it, but I dont need to rotate anymore(Rotate each confidence map matrix so that z is the A-P axis)
    % % % %                 croppedMask = mask(26:68, 62:96,35:78); % limit to the max size of the striatum
    % % % %                 
    % % % %                 eval(['maskR{k}.mask', num2str(p), ' = ' , 'croppedMask;']);
    % % % % 
    % % % %                 maskR_downsampled{k}.cortical_group  = injGroup_data(k).cortical_group;
    % % % %                 eval(['maskR_downsampled{k}.mask', num2str(p), ' = ' , 'round(interp3(x, y,z, croppedMask, xi, yi, zi));']); 
    % % % %             end
    % % % %         end


            % Calclulating all the overlap of the clusters with the cotical projection fields
            for s = 1:length(d); % s = 1:5
                corticalGroups_Clusters = [];
                clusterMasks = [];  %this should happen in the next line, but just for good measure
                bar_fieldNames = {};
                bar_clusterNumber = [];
                bar_fieldFraction = [];
                bar_clusterFraction = [];

                load(d(s).name);
                for c = 1:length(clusterMasks);
                    cluster = clusterMasks(c).mask;
                    for i = 1: length(projAreasToKeep);
                        for p = 1:3;
                            eval(['corticalField', ' = ' , 'maskR_downsampled{projAreasToKeep(i)}.mask', num2str(p), ';']);

                            overlapci =  cluster(:, :, :) & corticalField(:,:,:);
                            sumField = sum(corticalField(:));
                            sumCluster = sum(cluster(:));
                            sumOverlap = sum(overlapci(:));
                            striatumVolume = sum(smallmodel(:));
                            voxelSize = 0.150; 

                            clusterFraction  = sumOverlap/sumCluster;   
                            fieldFraction = sumOverlap/sumField;

                            clusterMasks(c).voxelSize_mm = voxelSize;
                            clusterMasks(c).clusterVolume(p) = sumCluster;
                            clusterMasks(c).striatumVolume = striatumVolume;

                            clusterMasks(c).corticalInputOverlap(i).thresholds = injGroup_data(projAreasToKeep(i)).thresholds; 
                            clusterMasks(c).corticalInputOverlap(i).cortical_group = injGroup_data(projAreasToKeep(i)).cortical_group; 
                            clusterMasks(c).corticalInputOverlap(i).group_volume = sumField;
                            clusterMasks(c).corticalInputOverlap(i).fraction_of_cluster_occupied_by_cortical_field(p) = clusterFraction;
                            clusterMasks(c).corticalInputOverlap(i).fraction_of_cortical_field_occupied_by_cluster(p) = fieldFraction;

                            %creating an analagous dataset that is cortical area-centric to make testing out different types of plotting easier
                            corticalGroups_Clusters(i).cortical_group = injGroup_data(projAreasToKeep(i)).cortical_group;
                            corticalGroups_Clusters(i).input_density_thresholds = injGroup_data(projAreasToKeep(i)).thresholds';
                            corticalGroups_Clusters(i).fraction_of_cortical_field_occupied_by_cluster(p,c) = fieldFraction;
                            corticalGroups_Clusters(i).fraction_of_cluster_occupied_by_cortical_field(p,c) = clusterFraction;
                            corticalGroups_Clusters(i).totalClusters = length(clusterMasks);
                            corticalGroups_Clusters(i).group_volume = sumField;
                            corticalGroups_Clusters(i).striatumVolume = striatumVolume; 
                            corticalGroups_Clusters(i).clusterVolume(c) = sumCluster;
                            corticalGroups_Clusters(i).voxelSize_mm = voxelSize;

                            % Matrices for bar plots
                            bar_fieldFraction(i, c, p) = fieldFraction;
                            bar_clusterFraction(i, c, p) = clusterFraction;
                            bar_fieldNames{i} = injGroup_data(projAreasToKeep(i)).cortical_group;

                        end
                    end
                    bar_clusterNumber{c} = num2str(clusterMasks(c).clusterNumber);
                end
                
                if saveFlag == 1
                    %save the variables
                    saveFolder = ([saveDir, distanceMethod, 'Detailed_Clustering_', num2str(confidenceLevels), 'levels/analysis/']);
                    save([saveFolder, 'clusterData_', num2str(length(clusterMasks)), 'clusters.mat'],['clusterMasks']); 
                    save([saveFolder, 'corticalData_', num2str(length(clusterMasks)), 'clusters.mat'],['corticalGroups_Clusters']); 
                    save([saveFolder, 'bar_fieldFraction_', num2str(length(clusterMasks)), '.mat'], ['bar_fieldFraction']);
                    save([saveFolder, 'bar_clusterFraction_', num2str(length(clusterMasks)), '.mat'], ['bar_clusterFraction']);
                    save([saveFolder, 'bar_clusterNumber_', num2str(length(clusterMasks)), '.mat'], ['bar_clusterNumber']);
                    save([saveFolder, 'bar_fieldNames_', num2str(length(clusterMasks)), '.mat'], ['bar_fieldNames']);
                end
            end

        end
    end
end
    % close all
    % clearvars -except confidenceLevels distanceMethods distanceMethod dm t corticalGroups_Clusters corticalGroup projAreasToKeep injGroup_data

%% 3. Creating bar plots of the input distribution to each cluster (and from each cortical area)
%create a loop to go through all the cluster dendrogram thresholds and cortical density thresholds
distanceMethods = {'correlation', 'chebychev', 'cityblock', 'cosine', 'euclidean', 'hamming', 'jaccard', 'minkowski', 'spearman'};

if figFlag == 3
    for dm = method; %[1 9] %1:9;
        distanceMethod = distanceMethods{dm};

        % Load the cluster data
        targetDir=([saveDir, distanceMethod, 'Detailed_Clustering_', num2str(confidenceLevels), 'levels/data']);
        cd(targetDir);
        d=dir; % d(1:3)=[];
        a = 1;
        for j = 1:length(d)     %I'm finding/removing those weird files here
            if length(d(j).name) > 15
                d2(a)=d(j);
                a = a+1;
            end
        end
        d = d2';

        plotdir = ([saveDir, distanceMethod, 'Detailed_Clustering_', num2str(confidenceLevels), 'levels/analysis/']);

        for s = 1:5 %1:length(d); %s = 1:5
            cd(targetDir);
            load(d(s).name);

            cd(plotdir)
            cmapOfClusters = clusterMasks(1).clusterColor(1:length(clusterMasks), :);
            numOfClusters = length(clusterMasks)
            load(['bar_fieldFraction_', num2str(numOfClusters), '.mat'])
            load(['bar_clusterFraction_', num2str(numOfClusters), '.mat'])

            for p = 1:3
                bar_clusterFraction3 = [];
                bar_fieldFraction3 = [];
                bar_clusterFraction3 = bar_clusterFraction(:, :, p);
                bar_fieldFraction3 = bar_fieldFraction(:, :, p);
                saveFolder = ([saveDir, distanceMethod, 'Detailed_Clustering_', num2str(confidenceLevels), 'levels/analysis/plots/']); 

                % for i = 1:length(clusterMasks(1).clusterOrder)  %only need this until i rerun everything and all the clusternumber variables will be strings
                %     clusterMasks(i).clusterNumber = num2str(clusterMasks(i).clusterNumber);
                % end

                fig = figure; 
                h = bar(bar_fieldFraction3(clusterMasks(1).corticalClusterOrder', clusterMasks(1).clusterColorReal), 1); 
                    % these are reordered based on the voxel clustering bar(inputMatrix(rowOrder, columnOrder)) 
                    % The stacked bar graph is kind of useful with this one, just add 'stacked' to the end
                    % the 1 at the end just makes the bar with maximally wide
                legend(h(:), {clusterMasks(clusterMasks(1).clusterColorReal).clusterNumberReal});
                set(gca,'xticklabel', {corticalGroups_Clusters(clusterMasks(1).corticalClusterOrder').cortical_group});
                title(['Fraction of Cortical Area in Cluster: ', distanceMethod, ' clustering - ', 'cluster levels:', num2str(confidenceLevels), ' - cortical thresh:', num2str(p)]);
                ylabel('Fraction of cortical terminal field within cluster');
                xlabel('Cortical areas (reordered)');
                colormap(cmapOfClusters(clusterMasks(1).clusterColorReal, :)) %this will make the bars the same colors as the clusters in the dendrogram and slice figures
                ylim([0 1])
                scrsz = get(0, 'ScreenSize');
                set(gcf, 'Position', [1 scrsz(4)/1 scrsz(3)/1.5 scrsz(4)/3]);
                set(gcf,'PaperPositionMode','auto')

                % and a heat map of the % of the "Fraction of Cortical Area in Cluster" plot
                fig1b = figure;
                imagesc(bar_fieldFraction3(clusterMasks(1).corticalClusterOrder', clusterMasks(1).clusterColorReal));
                caxis([0 1])
                colormap(hot)
                set(gcf, 'Position', [1196 521 742 584])
                axis image
                set(gca, 'YTick', 1:length(corticalGroups_Clusters))
                set(gca, 'YTickLabel', {corticalGroups_Clusters(clusterMasks(1).corticalClusterOrder').cortical_group})
                set(gca, 'XTick', 1:numOfClusters)
                set(gca, 'xTickLabel', clusterMasks(1).clusterOrderReal)
                title(['Fraction of Cortical Area in Cluster: ', distanceMethod, ' clustering - ', 'cluster levels:', num2str(confidenceLevels), ' - cortical thresh:', num2str(p)]);
                ylabel('Cortical subregions')
                xlabel('Clusters')
                set(fig1b,'PaperPositionMode','auto')

                % % Unordered plot:
                % fig3 = figure;
                % h4 = bar(bar_fieldFraction(:, :, 3));  
                % legend(h4(:), bar_clusterNumber);
                % set(gca,'xticklabel', bar_fieldNames);
                % ylabel('UNORDERED: Fraction of cortical terminal field within cluster')
                % colormap(clusterMasks(1).clusterColor(1:(end-1), :)) %or colormap(cmapOfClusters(1:11, :))
                % ylim([0 1])
                % scrsz = get(0, 'ScreenSize');
                % set(gcf, 'Position', [1 scrsz(4)/1 scrsz(3)/1.5 scrsz(4)/3]);
                % set(gcf,'PaperPositionMode','auto')

                if saveFlag == 1
                    saveas(fig,[saveFolder, 'fractionOfCorticalAreaInCluster_', num2str(numOfClusters), 'clusters_level', num2str(p), '.fig'],'fig');
                    print(fig,[saveFolder, 'fractionOfCorticalAreaInCluster_', num2str(numOfClusters), 'clusters_level', num2str(p), '.eps'],'-depsc2');
                end
                close(fig)

                if saveFlag == 1
                    saveas(fig1b,[saveFolder, 'heatMaps/fractionOfCorticalAreaInCluster_HeatMap_', num2str(numOfClusters), 'clusters_level', num2str(p), '.fig'],'fig');
                    print(fig1b,[saveFolder, 'heatMaps/fractionOfCorticalAreaInCluster_HeatMap_', num2str(numOfClusters), 'clusters_level', num2str(p), '.eps'],'-depsc2');
                end
                close(fig1b)

                fig2 = figure;
                h2 = bar(bar_clusterFraction3(clusterMasks(1).corticalClusterOrder', clusterMasks(1).clusterColorReal)', 1);   % xLT1 is the order of the clustered cortical areas
                legend(h2(:), {corticalGroups_Clusters(clusterMasks(1).corticalClusterOrder').cortical_group}); %ordered based on common input via voxel clustering
                set(gca, 'xticklabel', {clusterMasks(clusterMasks(1).clusterColorReal).clusterNumberReal}); 
                title(['Fraction of Cluster Occupied: ', distanceMethod, ' clustering - ', 'cluster levels:', num2str(confidenceLevels), ' - cortical thresh:', num2str(p)]);
                ylabel('Fraction of cluster occupied by cortical terminal field');
                xlabel('Clusters (reordered)');
                ylim([0 1])
                scrsz = get(0, 'ScreenSize');
                set(gcf, 'Position', [1 scrsz(4)/1 scrsz(3)/1.5 scrsz(4)/3]);
                set(gcf,'PaperPositionMode','auto')

                % and a heat map of the % of the "Fraction of Cortical Area in Cluster" plot
                fig2b = figure;
                imagesc(bar_clusterFraction3(clusterMasks(1).corticalClusterOrder, clusterMasks(1).clusterColorReal));
                colormap(hot)
                caxis([0 1])
                set(gcf, 'Position', [1196 521 742 584])
                axis image
                set(gca, 'YTick', 1:length(corticalGroups_Clusters))
                set(gca, 'YTickLabel', {corticalGroups_Clusters(clusterMasks(1).corticalClusterOrder').cortical_group})
                set(gca, 'XTick', 1:numOfClusters)
                set(gca, 'xTickLabel', clusterMasks(1).clusterOrderReal)
                title(['Fraction of Cluster Occupied: ', distanceMethod, ' clustering - ', 'cluster levels:', num2str(confidenceLevels), ' - cortical thresh:', num2str(p)]);
                ylabel('Cortical subregions')
                xlabel('Clusters')
                set(fig2b,'PaperPositionMode','auto')

                % Unordered plot:
                % fig2 = figure;
                % h3 = bar(bar_clusterFraction(:, :, 3)')
                % legend(h3(:), bar_fieldNames)
                % set(gca, 'xticklabel', bar_clusterNumber)
                % ylabel('Fraction of cluster occupied by cortical terminal field')
                % ylim([0 1])
                % scrsz = get(0, 'ScreenSize');
                % set(gcf, 'Position', [1 scrsz(4)/1 scrsz(3)/1.5 scrsz(4)/3]);
                % set(gcf,'PaperPositionMode','auto')

                if saveFlag == 1
                    saveas(fig2, [saveFolder, 'fractionOfClusterOccupied_', num2str(numOfClusters), 'clusters_level', num2str(p), '.fig'], 'fig');
                    print(fig2, [saveFolder, 'fractionOfClusterOccupied_', num2str(numOfClusters), 'clusters_level', num2str(p), '.eps'], '-depsc2');
                end
                close(fig2)
                if saveFlag == 1
                    saveas(fig2b, [saveFolder, 'heatMaps/fractionOfClusterOccupied_HeatMap_', num2str(numOfClusters), 'clusters_level', num2str(p), '.fig'], 'fig');
                    print(fig2b, [saveFolder, 'heatMaps/fractionOfClusterOccupied_HeatMap_', num2str(numOfClusters), 'clusters_level', num2str(p), '.eps'], '-depsc2');
                end
                close(fig2b)
            end
        end
    end
    
end
% % % 
% % % clearvars -except confidenceLevels distanceMethods distanceMethod dm t
% % % 
% % %     end % close threshold loop
% % % end  % close distance method loop


%% 4. New 7/29/15 Bar plot of % of Cluster Occupied, but ordered by cortical area instead of how it is above by cluster 

if figFlag == 4
    % For spearman, 3 Levels, & 4 clusters
    distanceMethod = method; %'spearman';
    confidenceLevels = level; %3;

    % Load the cluster data
    targetDir=([saveDir, distanceMethod, 'Detailed_Clustering_', num2str(confidenceLevels), 'levels/data']);
    plotdir = ([saveDir, distanceMethod, 'Detailed_Clustering_', num2str(confidenceLevels), 'levels/analysis/']);
    load([targetDir, 'clusterMasks_4clusters.mat'])
    load([plotdir, 'corticalData_4clusters.mat'])

    cd(plotdir)
    cmapOfClusters = clusterMasks(1).clusterColor(1:length(clusterMasks), :);
    numOfClusters = length(clusterMasks);
    load(['bar_fieldFraction_', num2str(numOfClusters), '.mat'])
    load(['bar_clusterFraction_', num2str(numOfClusters), '.mat'])

    % for cortical projection fields of 0.5%, 5%, & 20% densities
    for p = 1:3
        bar_clusterFraction3 = [];
        bar_fieldFraction3 = [];
        bar_clusterFraction3 = bar_clusterFraction(:, :, p);
        bar_fieldFraction3 = bar_fieldFraction(:, :, p);
        saveFolder = ([saveDir, distanceMethod, 'Detailed_Clustering_', num2str(confidenceLevels), 'levels/analysis/plots/']); 


        fig2 = figure;
        h2 = bar(bar_clusterFraction3(clusterMasks(1).corticalClusterOrder', clusterMasks(1).clusterColorReal), 1);  
        legend(h2(:), {clusterMasks(clusterMasks(1).clusterColorReal).clusterNumberReal}); 
            % these are reordered based on the voxel clustering bar(inputMatrix(rowOrder, columnOrder)) 
            % The stacked bar graph is kind of useful with this one, just add 'stacked' to the end
            % the 1 at the end just makes the bar with maximally wide
        set(gca, 'xticklabel', {corticalGroups_Clusters(clusterMasks(1).corticalClusterOrder').cortical_group}); 
        title(['Fraction of Cluster Occupied: ', distanceMethod, ' clustering - ', 'cluster levels:', num2str(confidenceLevels), ' - cortical thresh:', num2str(p)]);
        ylabel('Fraction of cluster occupied by cortical terminal field');
        xlabel('Clusters (reordered)');
        colormap(cmapOfClusters(clusterMasks(1).clusterColorReal, :)) %this will make the bars the same colors as the clusters in the dendrogram and slice figures
        ylim([0 1])
        scrsz = get(0, 'ScreenSize');
        set(gcf, 'Position', [1 scrsz(4)/1 scrsz(3)/1.5 scrsz(4)/3]);
        set(gcf,'PaperPositionMode','auto')

        if saveFlag == 1
            % Plot grouped by cortical area on x axis instead of cluster
            saveas(fig2, [saveFolder, 'reordered_fractionOfClusterOccupied_', num2str(numOfClusters), 'clusters_level', num2str(p), '.fig'], 'fig');
            print(fig2, [saveFolder, 'reordered_fractionOfClusterOccupied_', num2str(numOfClusters), 'clusters_level', num2str(p), '.eps'], '-depsc2');
        end
        %     close(fig2)
    end

    % Fraction of Cluster Occupied & Fraction of Cortical Area in Cluster (For the AVERAGE of the 3 projection densities)
    bar_clusterFraction3 = [];
    bar_fieldFraction3 = [];
    bar_clusterFraction3 = mean(bar_clusterFraction, 3);
    bar_fieldFraction3 = mean(bar_fieldFraction, 3);
    saveFolder = ([saveDir, distanceMethod, 'Detailed_Clustering_', num2str(confidenceLevels), 'levels/analysis/plots/']); 

    fig = figure; 
    h = bar(bar_fieldFraction3(clusterMasks(1).corticalClusterOrder', clusterMasks(1).clusterColorReal), 1); 
        % these are reordered based on the voxel clustering bar(inputMatrix(rowOrder, columnOrder)) 
        % The stacked bar graph is kind of useful with this one, just add 'stacked' to the end
        % the 1 at the end just makes the bar with maximally wide
    legend(h(:), {clusterMasks(clusterMasks(1).clusterColorReal).clusterNumberReal});
    set(gca,'xticklabel', {corticalGroups_Clusters(clusterMasks(1).corticalClusterOrder').cortical_group});
    title(['Fraction of Cortical Area in Cluster: ', distanceMethod, ' clustering - ', 'cluster levels:', num2str(confidenceLevels), ' - AVREAGE of thresholds 1,2,&3']);
    ylabel('Fraction of cortical terminal field within cluster');
    xlabel('Cortical areas (reordered)');
    colormap(cmapOfClusters(clusterMasks(1).clusterColorReal, :)) %this will make the bars the same colors as the clusters in the dendrogram and slice figures
    ylim([0 1])
    scrsz = get(0, 'ScreenSize');
    set(gcf, 'Position', [1 scrsz(4)/1 scrsz(3)/1.5 scrsz(4)/3]);
    set(gcf,'PaperPositionMode','auto')

    if saveFlag == 1
        saveas(fig,[saveFolder, 'fractionOfCorticalAreaInCluster_', num2str(numOfClusters), 'clusters_average123.fig'],'fig');
        print(fig,[saveFolder, 'fractionOfCorticalAreaInCluster_', num2str(numOfClusters), 'clusters_average123.eps'],'-depsc2');
    end
    % close(fig)

    fig2 = figure;
    h2 = bar(bar_clusterFraction3(clusterMasks(1).corticalClusterOrder', clusterMasks(1).clusterColorReal), 1);  
    legend(h2(:), {clusterMasks(clusterMasks(1).clusterColorReal).clusterNumberReal}); 
        % these are reordered based on the voxel clustering bar(inputMatrix(rowOrder, columnOrder)) 
        % The stacked bar graph is kind of useful with this one, just add 'stacked' to the end
        % the 1 at the end just makes the bar with maximally wide
    set(gca, 'xticklabel', {corticalGroups_Clusters(clusterMasks(1).corticalClusterOrder').cortical_group}); 
    title(['Fraction of Cluster Occupied: ', distanceMethod, ' clustering - ', 'cluster levels:', num2str(confidenceLevels), ' - AVREAGE of thresholds 1,2,&3']);
    ylabel('Fraction of cluster occupied by cortical terminal field');
    xlabel('Clusters (reordered)');
    colormap(cmapOfClusters(clusterMasks(1).clusterColorReal, :)) %this will make the bars the same colors as the clusters in the dendrogram and slice figures
    ylim([0 1])
    scrsz = get(0, 'ScreenSize');
    set(gcf, 'Position', [1 scrsz(4)/1 scrsz(3)/1.5 scrsz(4)/3]);
    set(gcf,'PaperPositionMode','auto')

    if saveFlag == 1
        saveas(fig2, [saveFolder, 'reordered_fractionOfClusterOccupied_', num2str(numOfClusters), 'clusters_average123.fig'], 'fig');
        print(fig2, [saveFolder, 'reordered_fractionOfClusterOccupied_', num2str(numOfClusters), 'clusters_average123.eps'], '-depsc2');
    end
    %     close(fig2)
end

