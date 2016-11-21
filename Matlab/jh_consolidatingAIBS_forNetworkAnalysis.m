function jh_consolidatingAIBS_forNetworkAnalysis(figFlag, saveFlag)
% [vargout] = JH_CONSOLIDATINGAIBS_FORNETWORKANALYSIS(figFlag, saveFlag) 
% 
% INPUT: figFlag (1 ...) 
%             1. Import edge and node data (output of GetDensityDataFromWeb.py)
%             2. Add corticothalamic data from AIBS API to injGroup_data
%             3. Get the data as edges (source-target-density) (BY INJECTION)
%             4. Get the data as edges (source-target-density) (BY SUBREGION) *******
%             5. 
%         saveFlag (0 or 1) do you want to save all the outputs from this 
% 
% OUTPUT: 
% 
% PURPOSE: 
% 
% DEPENDENCIES: 
% 

% Load initial datasets / setting up directories %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Where is the analyzed corticostriatal data folder (jh_consolidatingAIBSdatasets.m output)?')
% likely here: '/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed4'
anaDir= uigetdir('/', 'Where is the analyzed corticostriatal data folder?');
cd(anaDir)

load([anaDir, '/injGroup_data.mat']) 


%% 1. Import edge and node data (output of GetDensityDataFromWeb.py)

if figFlag == 1
    % I imported the edges file as a "numeric matrix" (set the variable name to edgesformatted): 
    uiopen('/Users/jeaninehunnicutt/Desktop/github/anatomy/Python/DensityDataFromAPI/edges_2016_ipsi_sorted.csv',1) % as Numeric Matrix
    edgesformatted = edges2016ipsisorted;
    %       *rows: all injection-target pairs
    %       *column 1: Source	
    %       *column 2: Target	
    %       *column 3: Weight (density in target)
    %       *column 3: Weight (volume in target)

    % I imported the nodes file as a cell array (then >> nodes = nodetest): 
    uiopen('/Users/jeaninehunnicutt/Desktop/github/anatomy/Python/DensityDataFromAPI/nodes_formatted.csv',1) % as Cell Array
    nodes = nodesformatted;
    %       *the rows are injections/regions
    %       *column 1 = expID 
    %       *column 2 = area Name (Label)
    %       *column 3 = inj Volume
    %       *column 4 = x (A-P)
    %       *column 5 = y (D-V)
    %       *column 6 = z (M-L)
    %       *column 7 = tag (0 = injection, 1 = brain region)
    %       *column 8 = structure ID
    %       *column 9 = group number (my grouping number for subregion divisions, for example: ACAv and ACAd are both 3)


    % Add subregion abbreviations to injGroup_data
    corticalGroup = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'SS', 'Vis', 'SUB_HIPP', 'Amyg', 'SNr', 'na'};

    injGroup_data(1).subregions = {'ACA','ACAd','ACAv'};

    injGroup_data(9).subregions = {'PL','ORBm'};

    injGroup_data(18).subregions = {'SS','SSp','SSp-n','SSp-bfd','SSp-ll','SSp-m','SSp-ul','SSp-tr','SSp-tr6a','SSp-tr6b','SSp-un','SSs'};

    injGroup_data(2).subregions = {'GU','VISC','AI','AId','AIp','AIv'};

    injGroup_data(7).subregions = {'MO','MOp'};

    injGroup_data(5).subregions = {'MOs','FRP'};

    injGroup_data(3).subregions = {'AUD','AUDd','AUDp','AUDpo','AUDv'};

    injGroup_data(19).subregions = {'VIS','VISal','VISam','VISl','VISp','VISp4','VISpl','VISpm'};

    injGroup_data(6).subregions = {'ILA'};

    injGroup_data(8).subregions = {'ORB','ORBl','ORBvl'};

    injGroup_data(11).subregions = {'RSP','RSPagl','RSPd','RSPv'};

    injGroup_data(10).subregions = {'PTLp'};

    injGroup_data(4).subregions = {'TEa','PERI','ECT'};

    injGroup_data(20).subregions = {'SUB','SUBd','SUBv', 'PRE', 'POST', 'PAR','ENTl', 'ENTm', 'CA1', 'CA2', 'CA3'}; 

    injGroup_data(21).subregions = {'BLA', 'BLAa', 'BLAp', 'BLAv','BMA','BMAa', 'BMAp','LA' };


    % Add subregion ID to injGroup_data
    injGroup_data(1).subregionID = [];

    for i = 133:length(nodes)
        for s = 1:length(injGroup_data)
            if sum(strcmp(nodes(i, 2), injGroup_data(s).subregions)) >0
                injGroup_data(s).subregionID = cat(2, injGroup_data(s).subregionID, nodes(i, 1));
            end
        end
    end

    % ???
    % for i = 1:length(inj_data)
    %     for d = 1:length(edgesformatted)
    %         if edgesformatted(d, 1) == str2num(inj_data(i).expID)
    %             inj_data(i).projectionTarget = cat(2, inj_data(i).projectionTarget, edgesformatted(d, 2));
    %             inj_data(i).projectionDensity = cat(2, inj_data(i).projectionTarget, edgesformatted(d, 3));
    %             for g = 1:length(injGroup_data)
    %                 if strcmp(injGroup_data(g).cortical_group, inj_data(i).cortical_group)
    %                     injGroup_data(g).projections(
    %                 end
    %             end
    %             
    %     end
    %     end
    % end

    % Add the location center of all injections grouped for each subregion to injGroup_data & inj_data
    injGroup_data(g).injectionCentroid = [];
    injGroup_data(g).groupCentroid = [];

    load([anaDir, '/inj_data.mat'])

    for i = 1:length(inj_data)
        for d = 1:length(nodes)
            if cell2mat(nodes(d, 1)) == str2num(inj_data(i).expID)
                inj_data(i).injectionCentroid = cell2mat(nodes(d, 4:6));
                inj_data(i).injectionVolume = cell2mat(nodes(d, 3));
                for g = 1:length(injGroup_data)
                    if strcmp(injGroup_data(g).cortical_group, inj_data(i).cortical_group)
                        injGroup_data(g).injectionCentroid = cat(1, injGroup_data(g).injectionCentroid, cell2mat(nodes(d, 4:6)));
                    end
                end
            else
                for g = 1:length(injGroup_data);
                    for k = 1:length(injGroup_data(g).subregionID)
                        if cell2mat(nodes(d, 1)) == cell2mat(injGroup_data(g).subregionID(k))
                            injGroup_data(g).groupCentroid(k, :) = cell2mat(nodes(d, 4:6));  %This is making a list of the centroids of each subregionID associated with each subregion Group (ACA has 2 centroids: ACAd & ACAv, AI_GU_VISC has 5, etc... ) 
                        end
                    end
                end
            end

        end
    end


    % I want to put a field in 
    % injGroup_data(g).projecitons.ACA(one for each area)(n, 1) = injection ID (one for each in injGroup_data(g).expID )
    % injGroup_data(g).projecitons.ACA(n, 2) = density
    % *this is saying that injGroup_data(g) projects to ACA via these specific injections

    %initialize the fields
    for g = 1:length(injGroup_data); 
        injGroup_data(g).projections = [];
        for gg = 1:length(injGroup_data)
            injGroup_data(g).projections(gg).projectionTargetGroup = []; 
            injGroup_data(g).projections(gg).density = [];
            injGroup_data(g).projections(gg).densitySource = [];
            injGroup_data(g).projections(gg).densityTargetsALL = [];
            injGroup_data(g).projections(gg).densityTarget= [];
            injGroup_data(g).projections(gg).projectionOrigin= []; %1 = the injection is in this region / 0 = it's not
        end
    end


    % This works perfectly for accumulating all the associated projection data
    for g = 1:length(injGroup_data); % Go throuh all the cortical subregions
        for e = 1:length(injGroup_data(g).expID) % Go through the injection IDs for experiments included in that subregion
            for d = 1:length(edgesformatted) % Go through every row of the edge connection data (density in one area from an injection in another)
                if edgesformatted(d, 1) == injGroup_data(g).expID(e) % if a row in the edge data == one of the injection IDs for this brain region
                    for gg = 1:length(injGroup_data) % go through subregions again and... 
                        for wowow = 1:length(injGroup_data(gg).subregionID) % % go through the  subregion IDs associated with each subregion so... 

                            if edgesformatted(d, 2) == cell2mat(injGroup_data(gg).subregionID(wowow)) % I can check if the edge that came from this subregion sends projections to a subregion I care about
                                injGroup_data(g).projections(gg).projectionTargetGroup = injGroup_data(gg).cortical_group; % Cortical projection Target name

                                % If the injection is in the projecting region it is given 2 projection values, one with and without the injection volume
                                % So I'm making both density values the minimum of the 2 (presumably the value that doesnt include the injeciton site
                                if edgesformatted(d, 2) == edgesformatted(d+1, 2) %trying to deal with the fact that any tiny bit of an injection in a region will make it have 2 rows in the edge list
                                    dens = min([edgesformatted(d, 3), edgesformatted(d-1, 3)]);
                                elseif edgesformatted(d, 2) == edgesformatted(d-1, 2) % because the high value that includes the injection can come first or second in the set
                                else
                                    dens = edgesformatted(d, 3);
                                end


                                injGroup_data(g).projections(gg).density = cat(2, injGroup_data(g).projections(gg).density, dens); % Cortical projection Target density

                                injGroup_data(g).projections(gg).densitySource = cat(1, injGroup_data(g).projections(gg).densitySource, edgesformatted(d, 1)); % JH update
                                injGroup_data(g).projections(gg).densityTargetsALL = cat(1, injGroup_data(g).projections(gg).densityTargetsALL, edgesformatted(d, 2));
                                injGroup_data(g).projections(gg).densityTarget = unique(injGroup_data(g).projections(gg).densityTargetsALL);  % Moved to avoid repeating unnecessarily 

                                % projectionOrigin of 1 = projection region is primary injection location / 2 = projection region may have some of the injection in it / 0 = injection & projection region wholely separate
                                % I'd rather keep the detailed data, and set it equal to 1 later if I dont need it
                                if ismember(edgesformatted(d, 2), cell2mat(injGroup_data(g).subregionID)); % if looking at the projections to the area
                                    injGroup_data(g).projections(gg).projectionOrigin = 1;  
                                elseif edgesformatted(d, 2) == edgesformatted(d-1, 2) %trying to deal with the fact that any tiny bit of an injection in a region will make it have 2 rows in the edge list
                                    injGroup_data(g).projections(gg).projectionOrigin = 2; 
                                else
                                    injGroup_data(g).projections(gg).projectionOrigin = 0;
                                end
                            end
                        end

                    end
                end
            end
        end  
    end

    % % To get the average or max projection from one region to another:
    % avgProj = mean(injGroup_data(g).projections(gg).density);
    % maxProj = mean(injGroup_data(g).projections(gg).density);

    if saveFlag == 1
        save([anaDir, '/injGroup_data.mat'],'injGroup_data', '-v7.3') 
        save([anaDir, '/inj_data.mat'], 'inj_data')
    end
end

%%%%%% THis used to be initializing things
% for g = 1:length(injGroup_data);
%     for gg = 1:length(injGroup_data)
%         injGroup_data(g).projections(gg).projectionTargetGroup = injGroup_data(gg).cortical_group;
% %         for fuckthis = 1:length(injGroup_data(g).projections(gg).densityTarget)
%              injGroup_data(g).projections(gg).density = [];
% %             injGroup_data(g).projections(gg).density(fuckthis, 1).test = 0;
% %         end
%     end
% end
% 
% injGroup_data(g).projections(gg).density(wowow, 1).test = cat(2, injGroup_data(g).projections(gg).density(wowow, 1).test, edgesformatted(d, 3));
%                             injGroup_data(g).projections(gg).densityTarget(wowow) = injGroup_data(gg).subregionID(wowow);



        
%% 2. Adding corticothalamic data from AIBS API to injGroup_data
% WOrks like a charm, I had to reimport the gephi data in python and
% something had changed on the website, so it was a bit of a mess, but once
% I got it working it was pretty quick. (GetDensityDataFromWeb.py) -import as a matrix   (edges_May2015_AddNuclei_ipsi.csv)

if figFlag == 2
    uiopen('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/geph_forThesis/edges_May2015_AddNuclei_ipsi.csv',1) % as Numeric Matrix
    edges_nuclei = edgesMay2015AddNucleiipsi;
    
    thalamicNuclei = {'IMD','MD','RH','CM','PR','SM','Pf','LP','PCN','CL','IAM','PVT','PT','RE','IAD','AM','AD','LD','Po','VAL','VM','VPM','AV','RT','VPL'};
    thalamicNuclei_AIBS_structureID = [59,362,189,599,1077,366,930,218,907,575,1120,149,15,181,1113,127,64,155,1020,629,685,733,255,262,718];

    for g = 1:length(injGroup_data)
        for n = 1:length(thalamicNuclei)
        injGroup_data(g).nuclearProjections(n).name = thalamicNuclei{n};
        injGroup_data(g).nuclearProjections(n).AIBS_structureID = thalamicNuclei_AIBS_structureID(n);
        end
    end

    for g = 1:length(injGroup_data)
        for e = 1:length(injGroup_data(g).expID)
            for k = 1: length(edges_nuclei)
                if edges_nuclei(k, 1) == injGroup_data(g).expID(e)
                    for n = 1:length(thalamicNuclei)
                        if edges_nuclei(k, 2) == injGroup_data(g).nuclearProjections(n).AIBS_structureID
                            injGroup_data(g).nuclearProjections(n).projDensity(e) = edges_nuclei(k, 3);
                            injGroup_data(g).nuclearProjections(n).projVolume(e) = edges_nuclei(k, 4);
                        end
                    end
                end
            end
        end
    end
    
    if saveFlag == 1
        save([anaDir, '/injGroup_data.mat'],'injGroup_data', '-v7.3') 
    end
end


%% 3. Get the data as edges (source-target-density) (BY INJECTION)
% Edges: (in Matlab)
%   Columns: 
%     1. injection id  	injGroup_data(g).expID(k)
%     2. structure id	injGroup_data(g).areaID(a)
%     3. density: (injection --> target structure)	
%   Rows: 
%    -Injection --> 
%      *Cortical subregions
%      *Striatal clusters (start with 4)
%      *Thalamic Nuclei
% Nodes: (Manual)
%   Columns: 
%     1. Id	
%     2. Label	
%     3. Area (subregion)
%     4. Volume	
%     5. x (A-P)	
%     6. y (D-V)	** invert (multiply by -1)
%     7. z (M-L)	
%     8. tag (Cortex, Thalamus, Striatum ...but a #)
%     9. Structure ID	
%     10. Group
%     *11. Injection ID (*The interactive output doesn't show the ID or Label

if figFlag == 3
    corticalGroup = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'SS', 'Vis', 'SUB_HIPP', 'Amyg', 'SNr', 'na'};
    projAreasToKeep = find(~ismember(corticalGroup,{'SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'na', 'SNr'}));

    % I need a grouped subregion specific number
    injGroup_data(1).areaID = 10001; injGroup_data(9).areaID = 10009; injGroup_data(18).areaID = 10018; injGroup_data(2).areaID = 10002; injGroup_data(7).areaID = 10007;
    injGroup_data(5).areaID = 10005; injGroup_data(3).areaID = 10003; injGroup_data(19).areaID = 10019; injGroup_data(6).areaID = 10006; injGroup_data(8).areaID = 10008;
    injGroup_data(11).areaID = 10011; injGroup_data(10).areaID = 10010; injGroup_data(4).areaID = 10004; injGroup_data(20).areaID = 10020; injGroup_data(21).areaID = 10021;


    edges = [];

    % Edges for Cortex --> Cortex
        for g = 1:length(projAreasToKeep)
            for k = 1:length(injGroup_data(projAreasToKeep(g)).expID)
                for a = 1:length(projAreasToKeep)
                    edge(1,1) = injGroup_data(projAreasToKeep(g)).expID(k);
                    edge(1,2) = injGroup_data(projAreasToKeep(a)).areaID;
                    if isempty(injGroup_data(projAreasToKeep(g)).projections(projAreasToKeep(a)).density(k)); % There are a bunch of empty arrays if there are no projections)
                        edge(1,3) = 0;
                    else
                        edge(1,3) = injGroup_data(projAreasToKeep(g)).projections(projAreasToKeep(a)).density(k);
                    end
                    edges = cat(1, edges, edge);
                end
            end
        end %Perfect

    % Edges for Cortex --> Striatal Clusters (This needs to be redone to be by injection...) 
        % For spearman, 3 Levels, & 4 clusters
        distanceMethod = 'spearman'; confidenceLevels = 3;
        % Load the cluster data
        targetDir=(['/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/clustering4/', distanceMethod, 'Detailed_Clustering_', num2str(confidenceLevels), 'levels/data']);
        cd(targetDir);
        load('clusterMasks_4clusters.mat')
        plotdir = (['/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/clustering4/', distanceMethod, 'Detailed_Clustering_', num2str(confidenceLevels), 'levels/analysis/']);
        cd(plotdir)
        load('corticalData_4clusters.mat')
        cmapOfClusters = clusterMasks(1).clusterColor(1:length(clusterMasks), :);
        numOfClusters = length(clusterMasks);
        load(['bar_fieldFraction_', num2str(numOfClusters), '.mat'])
        load(['bar_clusterFraction_', num2str(numOfClusters), '.mat'])

        %Need to code my area values
        for a = 1:length(corticalGroups_Clusters)
            for g = 1:length(injGroup_data)
                if strcmp(corticalGroups_Clusters(a).cortical_group, injGroup_data(g).cortical_group)
                    corticalGroups_Clusters(a).areaID = injGroup_data(g).areaID;
                end
            end
        end

        for c = 1:length(clusterMasks)
            for a = 1:length(corticalGroups_Clusters)
                edge(1,1) = corticalGroups_Clusters(a).areaID;
                edge(1,2) = c;
                edge(1,3) = mean(corticalGroups_Clusters(a).fraction_of_cluster_occupied_by_cortical_field(:, c));
                edges = cat(1, edges, edge);
            end
        end


    % Edges for Cortex --> Thalamus

    % Edges for Thalamus --> Cortex

    % Edges for Thalamus --> Striatal Clusters

    % Edges for Basal Ganglia --> Thalamus??? (Probably not)
end



%% 4. Get the data in Gephi format 
% Edges: (in Matlab)
%   Columns: 
%     1. injection id  	injGroup_data(g).expID(k)
%     2. structure id	injGroup_data(g).areaID(a)
%     3. mean density in target	
%     4. max density in target 
%   
% Nodes:
%   

if figFlag == 4
%     load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/injGroup_data.mat')

    corticalGroup = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'SS', 'Vis', 'SUB_HIPP', 'Amyg', 'SNr', 'na'};
    projAreasToKeep = find(~ismember(corticalGroup,{'SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'na', 'SNr'}));

    % I need a grouped subregion specific number
    injGroup_data(1).areaID = 10001; injGroup_data(9).areaID = 10009; injGroup_data(18).areaID = 10018; injGroup_data(2).areaID = 10002; injGroup_data(7).areaID = 10007;
    injGroup_data(5).areaID = 10005; injGroup_data(3).areaID = 10003; injGroup_data(19).areaID = 10019; injGroup_data(6).areaID = 10006; injGroup_data(8).areaID = 10008;
    injGroup_data(11).areaID = 10011; injGroup_data(10).areaID = 10010; injGroup_data(4).areaID = 10004; injGroup_data(20).areaID = 10020; injGroup_data(21).areaID = 10021;


    edges = [];

    % Edges for Cortex --> Cortex (by subregion)
        for g = 1:length(projAreasToKeep)
            for a = 1:length(projAreasToKeep)
                edge(1,1) = injGroup_data(projAreasToKeep(g)).areaID;
                edge(1,2) = injGroup_data(projAreasToKeep(a)).areaID;
                if isempty(max(injGroup_data(projAreasToKeep(g)).projections(projAreasToKeep(a)).density)); % There are a bunch of empty arrays if there are no projections)
                    edge(1,3) = 0;
                elseif g == a % Setting the self-projections equal to 1 here. 
                    edge(1,3) = 1;
                else
                    edge(1,3) = max(injGroup_data(projAreasToKeep(g)).projections(projAreasToKeep(a)).density);  % *********** Maybe change this later: Currently looking at the maximum projeciton density ***********
                end
                edges = cat(1, edges, edge);
            end
        end 

    % Edges for Cortex --> Striatal Clusters
        % For spearman, 3 Levels, & 4 clusters
        distanceMethod = 'spearman'; confidenceLevels = 3;
        % Load the cluster data
        targetDir=(['/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/clustering4/', distanceMethod, 'Detailed_Clustering_', num2str(confidenceLevels), 'levels/data']);
        cd(targetDir);
        load('clusterMasks_4clusters.mat')
        plotdir = (['/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/clustering4/', distanceMethod, 'Detailed_Clustering_', num2str(confidenceLevels), 'levels/analysis/']);
        cd(plotdir)
        load('corticalData_4clusters.mat')
        cmapOfClusters = clusterMasks(1).clusterColor(1:length(clusterMasks), :);
        numOfClusters = length(clusterMasks);
        load(['bar_fieldFraction_', num2str(numOfClusters), '.mat'])
        load(['bar_clusterFraction_', num2str(numOfClusters), '.mat'])

        % Need to code my area values
        for a = 1:length(corticalGroups_Clusters)
            for g = 1:length(injGroup_data)
                if strcmp(corticalGroups_Clusters(a).cortical_group, injGroup_data(g).cortical_group)
                    corticalGroups_Clusters(a).areaID = injGroup_data(g).areaID;
                end
            end
        end

        for c = 1:length(clusterMasks)
            for a = 1:length(corticalGroups_Clusters)
                edge(1,1) = corticalGroups_Clusters(a).areaID;
                edge(1,2) = c;
                edge(1,3) = mean(corticalGroups_Clusters(a).fraction_of_cluster_occupied_by_cortical_field(:, c)); %***Maybe change this later: Currently looking at the average projeciton coverage rows: 1=0.05%, 2=5%, 3=20%
                edges = cat(1, edges, edge);
            end
        end

    % Edges for Thalamus --> Striatal Clusters
        load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/nuclearOrigins_thalToClusters_compositeMaps_20150624.mat')  % Created in jh_consolidatingThalamusData.m Figs 9 - 10
        load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/nuclearOrigins_compositeMaps.mat')

        % This is an array of the fraction of the nuclei projecting to each cluster of the 4 cluster set (where rows = nuclei and columns = clusters)
        nuclearCoverage = nuclearOrigins_thalToClusters_compositeMaps(3).average_PaxAIBS_averageOfLevels357.coverage(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :); %Just loading the nuclear data for 4 clusters
        nucleiForClusters.names = nuclearOrigins_thalToClusters_compositeMaps(3).nuclei(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder);
    %     nuclearCoverage = nuclearOrigins_thalToClusters_compositeMaps(3).average_PaxAIBS_averageOfLevels357.coverage; %Just loading the nuclear data for 4 clusters
    %     nucleiForClusters.names = nuclearOrigins_thalToClusters_compositeMaps(3).nuclei;
        
        % Set nucleus IDs
        for n = 1:length(nucleiForClusters.names)
            nucleiForClusters.nucleusID(n) = 100+n;
        end
        % Add thalamostriatal (to clusters) to edges
        for c = 1:length(clusterMasks)
            for n = 1:length(nucleiForClusters.names)
                edge(1,1) = nucleiForClusters.nucleusID(n);
                edge(1,2) = c;
                edge(1,3) = nuclearCoverage(n, c);
                edges = cat(1, edges, edge);
            end
        end


    % Edges for Cortex --> Thalamus
        %Generate the max values for the projections
        for g = 1:length(projAreasToKeep)
            for n = 1:length(injGroup_data(projAreasToKeep(g)).nuclearProjections)
                corticothalamic(n) = max(injGroup_data(projAreasToKeep(g)).nuclearProjections(n).projDensity); 

                edge(1,1) = injGroup_data(projAreasToKeep(g)).areaID;
                edge(1,2) = nucleiForClusters.nucleusID(n);
                edge(1,3) = corticothalamic(n);
                edges = cat(1, edges, edge);
            end
        end %great

    % Edges for Thalamus --> Cortex (by subregion)  ** (Did this wrong the first time... used TC-only not TC-only and TCTSoverlapping areas)
        TConly = nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.all_TC.coverage(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :); %reordering: AD, AM, AV... to: IMD, MD, RH... ;
        TCTSOverlap = nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.all_TCTSoverlap.coverage(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :); %reordering: AD, AM, AV... to: IMD, MD, RH... ;
        allTCdata =  TConly + TCTSOverlap; 
    
        for g = 1:length(nuclearOrigins_compositeMaps.groups)  %loop through the cortical groups in the TC data (different than what I'm going to use)
%             allTCdata = nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.all_TC.coverage(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :); %reordering: AD, AM, AV... to: IMD, MD, RH... ;
            for n = 1:length(nucleiForClusters.names)   %loop through the nuclei
                for a = 1:length(corticalGroups_Clusters)    %Loop through the cortical groups that are used above

                    if strcmp(corticalGroups_Clusters(a).cortical_group, nuclearOrigins_compositeMaps.groups(g))
                        areaID = corticalGroups_Clusters(a).areaID;

                        edge(1,1) = nucleiForClusters.nucleusID(n);
                        edge(1,2) = areaID;
                        edge(1,3) = allTCdata(n, g);
                        edges = cat(1, edges, edge);
                    end
                end
            end
        end %done finally   ...not quite!
        
        
        
    % Edges for Thalamus --> Striatum (subregion fields)    ** (Did this wrong the first time... used TC-only not TC-only and TCTSoverlapping areas)
        TSonly = nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.all_TS.coverage(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :); %reordering: AD, AM, AV... to: IMD, MD, RH... ;
        TCTSOverlap = nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.all_TCTSoverlap.coverage(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :); %reordering: AD, AM, AV... to: IMD, MD, RH... ;
        allTSdata =  TSonly + TCTSOverlap;
        
        for g = 1:length(nuclearOrigins_compositeMaps.groups)  %loop through the cortical groups in the TC data (different than what I'm going to use)
%             allTSdata = nuclearOrigins_compositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.all_TS.coverage(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :); %reordering: AD, AM, AV... to: IMD, MD, RH... ;
            for n = 1:length(nucleiForClusters.names)   %loop through the nuclei
                for a = 1:length(corticalGroups_Clusters)    %Loop through the cortical groups that are used above

                    if strcmp(corticalGroups_Clusters(a).cortical_group, nuclearOrigins_compositeMaps.groups(g))
                        areaID = corticalGroups_Clusters(a).areaID;

                        edge(1,1) = nucleiForClusters.nucleusID(n);
                        edge(1,2) = areaID-9000;
                        edge(1,3) = allTSdata(n, g);
                        edges = cat(1, edges, edge);
                    end
                end
            end
        end
        
    
    
    % Edges for Cortex --> Striatum (subregion fields) *fraction of the primary striatal projection FIELD OCCUPIED by each other cortical input 
                    
        % First get this data... 
            corticalAreas = {'ACA';'AI_GU_VISC';'AUD';'ECT_PERI_TE';'FRA';'IL';'MOp';'ORBl';'PL_MO';'PTL';'RSP';'SS';'Vis';'SUB_HIPP';'Amyg'}; % same as corticalGroups_Clusters(:).cortical_group


            ctxFields = {};
            CS_SC_edgeData = {};
            for g = 1:length(corticalAreas) 
                load([anaDir, '/corticalProjections/data/', corticalAreas{g}, '/summedCorticalGroup_',corticalAreas{g},'.mat']);

                CS_SC_edgeData{g}.name = corticalAreas{g};
                CS_SC_edgeData{g}.summedMask = projMask_mat;
            end

            for g = 1:length(corticalAreas) 
                for gg = 1:length(corticalAreas)
                    for d = 1:3 % looping through projeciton densities 1=diffuse(0.5%) 2=moderate(5%) 3=dense(20%)
                        densityMaskProj = CS_SC_edgeData{g}.summedMask(:,:,:) >= d;
                        densityMaskTarget = CS_SC_edgeData{gg}.summedMask(:,:,:) >= d;

                        CS_SC_edgeData{g}.overlap(gg, 1).name =  corticalAreas{gg};
                        CS_SC_edgeData{g}.overlap(gg, 1).density{d} = densityMaskProj & densityMaskTarget;

                        sumProj = sum(densityMaskProj(:));
                        sumTarget = sum(densityMaskTarget(:));
                        sumOverlap = sum(CS_SC_edgeData{g}.overlap(gg, 1).density{d}(:));
        %                 striatumVolume = sum(smallmodel(:));
        %                 voxelSize = 0.150; 

                        CS_SC_edgeData{g}.overlap(gg, 1).fractionOfPrimaryFieldOccupied(d) = sumOverlap/sumProj;   
                        CS_SC_edgeData{g}.overlap(gg, 1).fractionOfSecondaryProjinPrimaryField(d) = sumOverlap/sumTarget;
                    end
                end
            end

        % ...Then get the edges 
        
        for d = 1:4 %loop through the overlap of different projection densities
        	for g_p = 1:length(corticalAreas)  %loop through the cortical groups for primary projection (g) --> defines striatal target and strID
            	for g_s = 1:length(corticalAreas)  %loop through the cortical groups for secondary projection (gg)  --> defines cortical source and areaID
                    if d == 4 
                        CSedge = mean(CS_SC_edgeData{g_p}.overlap(g_s).fractionOfPrimaryFieldOccupied);
                    else
                        CSedge = CS_SC_edgeData{g_p}.overlap(g_s).fractionOfPrimaryFieldOccupied(d);
                    end

                    if d == 1
                        strID = corticalGroups_Clusters(g_p).areaID - 9000;
                    elseif d == 2
                        strID = corticalGroups_Clusters(g_p).areaID - 8000;
                    elseif d == 3
                        strID = corticalGroups_Clusters(g_p).areaID - 7000;
                    elseif d == 4
                        strID = corticalGroups_Clusters(g_p).areaID - 6000;
                    end

                    areaID = corticalGroups_Clusters(g_s).areaID;

                    edge(1,1) = areaID;
                    edge(1,2) = strID;
                    edge(1,3) = CSedge;
                    edges = cat(1, edges, edge);
                end
            end
        end
        
    
    % Edges for Striatum --> Cortex (subregion fields) *fraction of each PROJ FIELD IN each other cortical field 
        for d = 1:4 %loop through the overlap of different projection densities
        	for g_p = 1:length(corticalAreas)  %loop through the cortical groups for primary projection (g) --> defines striatal target and strID
            	for g_s = 1:length(corticalAreas)  %loop through the cortical groups for secondary projection (gg)  --> defines cortical source and areaID
                    if d == 4 
                        SCedge = mean(CS_SC_edgeData{g_p}.overlap(g_s).fractionOfSecondaryProjinPrimaryField);
                    else
                        SCedge = CS_SC_edgeData{g_p}.overlap(g_s).fractionOfSecondaryProjinPrimaryField(d);
                    end

                    if d == 1
                        strID = corticalGroups_Clusters(g_p).areaID - 9000;
                    elseif d == 2
                        strID = corticalGroups_Clusters(g_p).areaID - 8000;
                    elseif d == 3
                        strID = corticalGroups_Clusters(g_p).areaID - 7000;
                    elseif d == 4
                        strID = corticalGroups_Clusters(g_p).areaID - 6000;
                    end

                    areaID = corticalGroups_Clusters(g_s).areaID;

                    edge(1,1) = strID;
                    edge(1,2) = areaID;
                    edge(1,3) = SCedge;
                    edges = cat(1, edges, edge);
                end
            end
        end   % OMG, Actually done this time. 
        
        
        % ... jk, not done.
       
    % Edges for Thalamus --> Cortex (clusters) *for grouped cortical areas that form the primary targets to each striatal cluster 
       TConly = nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.all_TC.coverage(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :); %reordering: AD, AM, AV... to: IMD, MD, RH... ;
       TCTSOverlap = nuclearOrigins_clusterCompositeMaps.average_PaxAIBS_TC_TS_both_averageOfLevels135.all_TCTSoverlap.coverage(nuclearOrigins_compositeMaps.average_PaxAIBS_averageOfLevels135.nucleusOrder, :); %reordering: AD, AM, AV... to: IMD, MD, RH... ;
       allTC =  TConly + TCTSOverlap; 
       for c = 1:length(nuclearOrigins_clusterCompositeMaps.groups) 
             % To correspond appropriately to the other edges
            if c == 1   
                cluster = 14;
            elseif c == 2 
                cluster = 11;
            elseif c == 3 
                cluster = 13;
            elseif c == 4 
                cluster = 12;
            end
            
            for n = 1:length(nucleiForClusters.names)
                edge(1,1) = nucleiForClusters.nucleusID(n);
                edge(1,2) = cluster;
                edge(1,3) = allTC(n, c);
                edges = cat(1, edges, edge);
            end
       end

        
      % Edges for Cortex --> Thalamus (clusters) *for grouped cortical areas that form the primary targets to each striatal cluster 
        
         for c = 1:4
            for n = 1:length(injGroup_data(g).nuclearProjections) %Generate the max values for the projections
                maxCT_toNucleus = 0;
                for g = 1: length(injGroup_data)
                    if sum(ismember(thalCtx_ClusterConvergenceOrigins(c).primaryCtxConvergence, injGroup_data(g).cortical_group)) > 0

                        maxCT_toNucleus = max(maxCT_toNucleus, max(injGroup_data(g).nuclearProjections(n).projDensity));

                    end
                end
                
                % To correspond appropriately to the other edges
                if c == 1   
                    cluster = 14;
                elseif c == 2 
                    cluster = 11;
                elseif c == 3 
                    cluster = 13;
                elseif c == 4 
                    cluster = 12;
                end
                    
                edge(1,1) = cluster;
                edge(1,2) = nucleiForClusters.nucleusID(n);
                edge(1,3) = maxCT_toNucleus;
                edges = cat(1, edges, edge);
            end 
         end
         
       % Edges for Striatum (clusters) --> Thalamus * Rough and as inclusive as possible, based on the literature   
             ST = [ 1	107	0.5 ;
                    1	120	0.5 ;
                    1	121	0.5 ;
                    2	102	0.5 ;
                    2	107	0.5 ;
                    2	120	0.5 ;
                    2	121	0.5 ;
                    3	107	0.5 ;
                    3	120	0.5 ;
                    3	121	0.5 ;
                    4	102	0.5 ;
                    4	121	0.5 ];
              edges = cat(1, edges, ST);



        
    if saveFlag == 1
        csvwrite('/Users/jeaninehunnicutt/Desktop/github/anatomy/Python/DensityDataFromAPI/edges_all_final2.csv', edges) 
    end
    
    
    
    
    % Nodes - did some manually because it was easier
    nodes = {};
    nodes{1, 1} = 'Id'; nodes{1, 2} = 'Label'; nodes{1, 3} = 'Area'; nodes{1, 4} = 'Volume'; nodes{1, 5} = 'x (A-P)'; nodes{1, 6} = 'y (D-V)'; nodes{1, 7} = 'z (M-L)'; nodes{1, 8} = 'tag'; nodes{1, 9} = 'Group'; 
    row = {};

    % Cortex
    for g = 1:length(projAreasToKeep)
        row{1, 1} = injGroup_data(projAreasToKeep(g)).areaID;
        row{1, 2} = injGroup_data(projAreasToKeep(g)).cortical_group;
        row{1, 3} = injGroup_data(projAreasToKeep(g)).cortical_group;
        row{1, 4} = 0.05;
            xyz = mean(injGroup_data(projAreasToKeep(g)).groupCentroid, 1);
        row{1, 5} = xyz(1);
        row{1, 6} = abs(xyz(2));
        row{1, 7} = xyz(3);
        row{1, 8} = 1;
        row{1, 9} = 0;
    %     subIDs(g, :) = cell2mat(injGroup_data(projAreasToKeep(g)).subregionID);
        nodes = cat(1, nodes, row);
%         nodes(:, 5) = cat(1, nodes, xyz(:, 1));
    end

    % Thalamus
    for n = 1:length(nucleiForClusters.names)
        row{1, 1} = nucleiForClusters.nucleusID(n);
        row{1, 2} = nucleiForClusters.names(n);
        row{1, 3} = nucleiForClusters.names(n);
        row{1, 4} = 0.05;
            
        row{1, 5} = 1;
        row{1, 6} = 1;
        row{1, 7} = 1;
        row{1, 8} = 3;
        row{1, 9} = 2;
    %     subIDs(g, :) = cell2mat(injGroup_data(projAreasToKeep(g)).subregionID);
        nodes = cat(1, nodes, row);
%         nodes(:, 5) = cat(1, nodes, xyz(:, 1));
    end
%     
%     if saveFlag == 1
%         csvwrite('/Users/jeaninehunnicutt/Desktop/github/anatomy/Python/DensityDataFromAPI/nodes_all2.csv', nodes) 
%     end

    % Striatal Clusters
end
    