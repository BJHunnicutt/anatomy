
% This will take in the meta files and the data2 file that is within the output files from
% jh_pImport2matlab.m and convert them to structs for each experiment (cortStr_data) 
% and for the summed projections from each area and cre line (cortGroup_data)
% **run immediately after jh_pImport2matlab.m because it uses some of it's variables
% **be in the data output directory from python

% to look at this data :
% imagesc(squeeze(sum((inj_data(1).density.ipsilateral), 2))) 
% or 
% imagesc(inj_data(1).density.ipsilateral(:, :, 30))

This makes lots of groups and lots of figures: Individual slices with projection ranges and injection sites etc


% % % Update 5/7/2015 to interface with the updated version of jh_pImport2matlab2.m
% load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/2015_04_22_testData/data3_2015_04_28.mat')
% load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/2015_04_22_testData/data2_2015_04_23.mat')

%Some things to load first if I'm not going to redo it all:
load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/2015_04_22_testData/data_pImport.mat')
load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/averageBrain100um/averageTemplate100umACA_rotated.mat')
load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/strmask_ic_submask.mat') %I made a mask that removes the internal capsule
load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/AIBS_100um.mat')  %this was made later, but can replace a lot of missing things if needed
ic_submask = submask;
load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/injGroup_data.mat')
load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/inj_data.mat')

group = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'SS', 'Vis', 'SUB_HIPP', 'Amyg', 'SNr', 'na'};

targetDir='/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/data3';
cd(targetDir)
fNames=fields(data);
clear data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This part creates a struct of all the relevent corticostriatal data
%
% %% 5/7/15 This is all stuff I have already put in the individual brain folders as injMeta
%           Going to recreate without map data it only to facilitate the later steps
%
% Create a list of all experiments
for i = 1: length(fNames)
    inj_data(i).expID = fNames{i}(2:end);
end


metaDir = '/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/meta3';
cd(metaDir)

for i = 1: length(inj_data)
    expID = num2str(inj_data(i).expID);
    listing = dir(['*', expID, '*']);
    load(listing.name);  % this gives the metadata for each brain as the variable a
    inj_data(i).meta = a; % this places the metadata in the inj_data variable
    
%%%% Commented 5/7/15    
%     inj_data(i).density.ipsilateral = data2.striatum3d(i).R.densities; % the right side is ipsilateral
%     inj_data(i).density.contralateral = data2.striatum3d(i).L.densities;
    
%     t = 0.05; %Threshold to create projection masks
%     inj_data(i).mask_threshold = t;
%     inj_data(i).mask.ipsilateral = data2.striatum3d(i).R.densities > t;
%     inj_data(i).mask.contralateral = data2.striatum3d(i).L.densities > t;
%%%%

    if a.wildtype == 1
        inj_data(i).mouseline = 'wildtype';
    else inj_data(i).mouseline = inj_data(i).meta.transgenic_line;
    end 
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Now I'm going to build the other groupings, starting by adding group flags to the original injection data structs above
% 
% %% 5/7/15 This I am going to turn into a new variable that tells me which
%           injections to group for what, but doesn't contain data 

%%%% Commented 5/7/15 to make these directly from the data... 
%
% expIDcell = {100140756;100140949;100141219;100141599;100141796;100142655;100148142;100149109;112162251;112229103;112306316;112595376;112596790;112670853;112936582;113887162;116903968;117298988;120491896;120814821;120875816;121510421;126117554;126908007;139426984;139520203;141602484;142656218;146077302;156394513;156741826;157062358;157556400;157654817;157710335;157711748;158255941;158314278;158435116;159319654;159832064;161458737;166054929;166082128;166083557;166271142;166323186;166323896;166324604;166461899;167794131;168002073;168003640;168163498;168164972;168165712;171276330;176430283;180719293;182467026;182616478;182794184;183461297;183470468;183471174;184167484;184168193;263106036;263242463;263780729;264629246;264630019;264630726;266486371;266487079;266644610;272414403;272735030;272735744;272737914;272821309;278317239;278317945;283019341;283020912;286299886;286300594;286312782;286313491;287494320;287495026;287769286;292373346;292374068;292374777;292476595;292792016;292792724;293471629;294396492;294481346;294482052;294484177;297652799;298324391};
% inj_group = {'FRA', 'RSP', 'VISp', 'VISam', 'VISl', 'SSp', 'RSP', 'AUD', 'SSp-bfd', 'PTL', 'ORBl', 'RSP', 'AI_GU_VISC', 'MOp', 'SSp', 'VISp', 'VISl', 'SSs', 'AUD', 'MOp', 'SSp-bfd', 'VISp', 'ACA', 'SSp-bfd', 'ACA', 'ACA', 'MOp', 'ECT_PERI_TE', 'VISam', 'MOp', 'ORBl', 'ECT_PERI_TE', 'IL', 'SSp', 'FRA', 'PL_MO', 'VISp', 'AUD', 'ORBl', 'ACA', 'RSP', 'ACA', 'RSP', 'MOp', 'ECT_PERI_TE', 'RSP', 'SSp', 'ACA', 'VISp', 'VISl', 'VISl', 'MOp', 'SSp-bfd', 'SSs', 'ORBl', 'PTL', 'SSp-bfd', 'AUD', 'MOp', 'SSp-bfd', 'MOp', 'ECT_PERI_TE', 'ACA', 'ACA', 'ORBl', 'PTL', 'RSP', 'PL_MO', 'FRA', 'VISam', 'SSp', 'VISl', 'ECT_PERI_TE', 'SSp-bfd', 'VISl', 'SSp', 'ECT_PERI_TE', 'SSp-bfd', 'RSP', 'AI_GU_VISC', 'VISp', 'ECT_PERI_TE', 'SSp', 'PL_MO', 'VISp', 'FRA', 'SSp', 'SSp', 'IL', 'IL', 'VISl', 'ORBl', 'RSP', 'MOp', 'PL_MO', 'FRA', 'SSp', 'PTL', 'PL_MO', 'PL_MO', 'VISam', 'VISp', 'RSP', 'SSp', 'VISam'};
%     * this list was updated 9/23/14 to exclude 272822110 because it is the only posterior MOs included and to include 286299886 because it was abberrently excuded previously
%%%%

inj_group = {'FRA';'RSP';'VISp';'VISam';'VISl';'SNr';'SSp';'RSP';'AUD';'SSp-bfd';'PTL';'ORBl';'RSP';'AI_GU_VISC';'MOp';'AUD';'SSp';'Amyg';'VISp';'VISl';'SSs';'AUD';'MOp';'SSp-bfd';'VISp';'SUB_HIPP';'Amyg';'ACA';'SSp-bfd';'SUB_HIPP';'SUB_HIPP';'SUB_HIPP';'ACA';'ACA';'MOp';'ECT_PERI_TE';'VISam';'AUD';'SUB_HIPP';'MOp';'AUD';'ORBl';'ECT_PERI_TE';'SUB_HIPP';'IL';'SSp';'FRA';'PL_MO';'VISp';'AUD';'ORBl';'SNr';'ACA';'RSP';'ACA';'RSP';'MOp';'ECT_PERI_TE';'AI_GU_VISC';'RSP';'SSp';'ACA';'VISp';'VISl';'VISl';'MOp';'SSp-bfd';'SSs';'ORBl';'PTL';'SSp-bfd';'AI_GU_VISC';'SNr';'AUD';'SUB_HIPP';'MOp';'AI_GU_VISC';'AUD';'SUB_HIPP';'Amyg';'SSp-bfd';'MOp';'ECT_PERI_TE';'ACA';'ACA';'ORBl';'PTL';'na';'AI_GU_VISC';'PL_MO';'FRA';'VISam';'SSp';'VISl';'na';'SSp-bfd';'VISl';'SSp';'ECT_PERI_TE';'SSp-bfd';'RSP';'AI_GU_VISC';'VISp';'Amyg';'ECT_PERI_TE';'SSp';'PL_MO';'VISp';'FRA';'SSp';'SSp';'IL';'SUB_HIPP';'SUB_HIPP';'IL';'VISl';'ORBl';'RSP';'MOp';'PL_MO';'FRA';'SUB_HIPP';'SSp';'PTL';'PL_MO';'PL_MO';'VISam';'VISp';'RSP';'AI_GU_VISC';'SSp';'VISam'};
%     *This list is created manually in All_selectInjecitons_Meta.xlsx Group2 it has all the brains in numerical order as 
%      of the data created 4/28/15 but has 'na' in the group names for problem injections
%           ... (In case I ever forget this: I copy the column out of excel,'paste and match style' in Text Edit and find and replace line breaks with ';' )

for g = 1:length(fNames)
    expIDcell{g} = fNames{g}(2:end);
end
expIDcell = expIDcell';

targetDir='/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/data3';

for i = 1: length(inj_data)
    if inj_data(i).expID == num2str(expIDcell{i})
       inj_data(i).cortical_group = inj_group{i};
       
       EID = expIDcell{i};

        cd([targetDir, '/', inj_data(i).expID])
        
        load('injMeta.mat')
        injMeta.group = inj_group{i};
        injMeta.mouseline = inj_data(i).mouseline;
        save([targetDir, '/', inj_data(i).expID, '/injMeta.mat'], 'injMeta')
       
    else i % this will make sure that I am assigning the correct experiments to the correct groups
    end
    clear injMeta
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Then I'll create composite masks for the cortical groups at 3 thresholds.... 

targetDir='/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/data3';
load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/data3/averageBrain100um/averageTemplate100um_rotated.mat')
load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/strmask_ic_submask.mat') %I made a mask that removes the internal capsule
ic_submask = submask;

group = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'SS', 'Vis', 'SUB_HIPP', 'Amyg', 'SNr', 'na'};


% This is settign up the basic metadata for each group
for i = 1:length(group) 
    injGroup_data(i).cortical_group = group{i};
    injGroup_data(i).expIndex = [];
    injGroup_data(i).expID = [];
    for k = 1:length(inj_data)
        if strcmp(inj_data(k).cortical_group, group{i})
            injGroup_data(i).expID =  cat(2, injGroup_data(i).expID, str2num(inj_data(k).expID));
            injGroup_data(i).expIndex = cat(2, injGroup_data(i).expIndex, k);
        end
    end
end

% Here I'm creating a group of all of the Visual and all of the Sensory injections manually 
injGroup_data(18).expID = cat(2, injGroup_data(12).expID, injGroup_data(13).expID, injGroup_data(14).expID);
injGroup_data(18).expIndex = cat(2, injGroup_data(12).expIndex, injGroup_data(13).expIndex, injGroup_data(14).expIndex);
injGroup_data(19).expID = cat(2, injGroup_data(15).expID, injGroup_data(16).expID, injGroup_data(17).expID);
injGroup_data(19).expIndex = cat(2, injGroup_data(15).expIndex, injGroup_data(16).expIndex, injGroup_data(17).expIndex);


% this is creating the composite masks of all the injecitons for each sub-region
t1 = 0.005;
t2 = 0.05;   % for these ones use: rotatedData.striatum3d_AI or some other more restrivtive mask to avoid edge problems
t3 = 0.1;   
t4 = 0.15;
t5 = 0.2;

for i = 1:length(group);
    m1 = false(size(averageTemplate100um)); % initializing the mask
    m1c = false(size(averageTemplate100um));
    m2 = m1; % for all 3 confidence levels of the ipsilateral and contralateral masks
    m3 = m1; 
    m4 = m1;
    m5 = m1;
    m2c = m1c; 
    m3c = m1c; 
    m4c = m1c;
    m5c = m1c;
    for k = 1:length(injGroup_data(i).expIndex);       
        EID = injGroup_data(i).expID(k);

        cd([targetDir, '/', num2str(EID)])

        load('rotatedData.mat')
        load('submask.mat')

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

    % and write the masks into the injGroup_data variable
    injGroup_data(i).thresholds = [t1 t2 t3 t4 t5];
    injGroup_data(i).mask1.ipsilateral = m1;
    injGroup_data(i).mask2.ipsilateral = m2;
    injGroup_data(i).mask3.ipsilateral = m3;
    injGroup_data(i).mask4.ipsilateral = m4;
    injGroup_data(i).mask5.ipsilateral = m5;
    injGroup_data(i).mask1.contralateral = m1c;
    injGroup_data(i).mask2.contralateral = m2c;
    injGroup_data(i).mask3.contralateral = m3c;
    injGroup_data(i).mask4.contralateral = m4c;
    injGroup_data(i).mask5.contralateral = m5c;
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Now create composite masks for the layer specific CRE lines
%     A930038C07Rik-Tg1-Cre = layer 5 
%     Cux2-IRES-Cre = layers 2/3/4
%     Rbp4-Cre_KL100 = layer 5

%%%% 5/7/15 Update: not creating the masks here because there are too many ways to threshold it, need to figure that out first

mouseline = {'wildtype', 'Rbp4-Cre_KL100', 'Cux2-IRES-Cre', 'A930038C07Rik-Tg1-Cre', 'Etv1-CreERT2', 'Gpr26-Cre_KO250', 'Grp-Cre_KH288'}; %L5: Etv1-CreERT2 Gpr26-Cre_KO250  L234:Grp-Cre_KH288
wildtypeIndex = []; layer234Index = []; layer5Index = []; 
wildtypeID = []; layer234ID = []; layer5ID = []; 

for i = 1:length(group);
    ipsi1 = zeros(size(averageTemplate100um)); % initializing the masks for each CRE line everytime this loops to a new cortical area
    contra1 = zeros(size(averageTemplate100um)); 
    ipsi2 = zeros(size(averageTemplate100um)); 
    contra2 = zeros(size(averageTemplate100um));
    ipsi3 = zeros(size(averageTemplate100um)); % initializing the mask
    contra3 = zeros(size(averageTemplate100um));
    
    for k = 1:length(mouseline);
        for j = 1:length(inj_data);
                if k == 1 ;     
                    if strcmp(inj_data(j).mouseline, mouseline{k}) & strcmp(inj_data(j).cortical_group, group{i});
%                         ipsi1 = ipsi1 + inj_data(j).mask.ipsilateral;
%                         contra1 = contra1 + inj_data(j).mask.contralateral;
                        wildtypeIndex = cat(2, wildtypeIndex, j);
                        wildtypeID = cat(2, wildtypeID, str2num(inj_data(j).expID));
                    end
                elseif k == 2 || k == 4 || k == 5 || k == 6
                    if strcmp(inj_data(j).cortical_group, group{i}); %i made a new loop for this because I dont know the order of operations with & and or (|) statements
                        if strcmp(inj_data(j).mouseline, mouseline{k});
%                             ipsi2 = ipsi2 + inj_data(j).mask.ipsilateral;
%                             contra2 = contra2 + inj_data(j).mask.contralateral;
                            layer5Index = cat(2, layer5Index, j);
                            layer5ID = cat(2, layer5ID, str2num(inj_data(j).expID));
                        end
                    end
                elseif k == 3 || k == 7 
                    if strcmp(inj_data(j).cortical_group, group{i});
                        if strcmp(inj_data(j).mouseline, mouseline{k});
%                             ipsi3 = ipsi3 + inj_data(j).mask.ipsilateral;
%                             contra3 = contra3 + inj_data(j).mask.contralateral;
                            layer234Index = cat(2, layer234Index, j);
                            layer234ID = cat(2, layer234ID, str2num(inj_data(j).expID));
                        end
                    end
                end
            end
    end
    injGroup_data(i).wildtypeIndex = wildtypeIndex;
    injGroup_data(i).layer5Index = layer5Index;
    injGroup_data(i).layer234Index = layer234Index;
    injGroup_data(i).wildtypeID = wildtypeID;
    injGroup_data(i).layer5ID = layer5ID;
    injGroup_data(i).layer234ID = layer234ID;
    
%     injGroup_data(i).wildtypemask.ipsilateral = ipsi1 > 0; %making a binary mask that is the sum of all other 5% thresholded masks
%     injGroup_data(i).wildtypemask.contralateral = contra1 > 0;
%     
%     injGroup_data(i).layer5mask.ipsilateral = ipsi2 > 0;
%     injGroup_data(i).layer5mask.contralateral = contra2 >0 ;
%     
%     injGroup_data(i).layer234mask.ipsilateral = ipsi3 > 0;
%     injGroup_data(i).layer234mask.contralateral = contra3 > 0;
end


save('analyzed3/injGroup_data.mat','injGroup_data', '-v7.3') 
save('analyzed3/inj_data.mat', 'inj_data')


%% This will plot the ipsilateral and contralateral summed coronal, sagital and longitudinal view of each threshold (for an overview of the data)

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

targetDir='/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3';
cd(targetDir)

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
    saveas(fig, ['corticalProjections/collapsedThresholds/groupThresholdTest_',injGroup_data(g).cortical_group,'.fig'], 'fig');
    print(fig, ['corticalProjections/collapsedThresholds/groupThresholdTest_',injGroup_data(g).cortical_group,'.eps'], '-depsc2');
    close(fig)
end

%% Then this will create the 3-level images and plot coronal sections through the striatum like the clustering does

confidenceLevels = 3

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


%%%% 5/8/15 This now happens in a previous step
% 
% %Rotate the model matrix my 90degrees so that z traverses the anterior-posterior axis
% X = modelStriatum;
% s = size(X); % size vector
% v = [2, 3, 1]; %[ 2 1 3:ndims(X) ]; % dimension permutation vector
% Y = reshape( X(:,:), s);
% Y = permute( Y, v );
% modelStriatum = Y;
% 
% for i = 1:size(modelStriatum, 3)
%     modelStriatum(:, :, i) = imfill(modelStriatum(:,:, i)); %there are holes from the anterior commisure etc... 
% end

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

%     %Rotate each confidence map matrix so that z is the A-P axis
%     X = cMapInModel2{i}; 
%     s = size(X); % size vector
%     v = [2, 3, 1]; %makes z slices coronal
%     Y = reshape( X(:,:), s);
%     Y = permute( Y, v );
%     cMapInModel2{i} = Y;
end
        
% %%%%%%%% now downsample these guys to  150  um voxels... %%%%%%%%%%%%%%%%%%  Not yet... 5/8/15 update
% [x, y, z]= meshgrid(1:49, 1:53, 1:55);
% [xi, yi, zi] = meshgrid(1:1.5:49, 1:1.5:53, 1:1.5:55); %150x150x150um voxels
% 
% % try this out:
% for i=1:numel(cMapInModel2)
%     downsampledProjMask{i} = round(interp3(x, y,z, cMapInModel2{i}, xi, yi, zi));  % added 'round' here to put data back to initial space.  
% end
% 
% smallmodel = interp3(x, y,z, double(modelStriatum(:,:,1:55)), xi, yi, zi);
% smallmodel = smallmodel>brl_find_binary_threshold(smallmodel);
smallmodel = modelStriatum;
downsampledProjMask = cMapInModel2;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

targetDir = ('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/');
cd(targetDir)

% This is plotting sections of the individual groups (FIGURE)
for g = 1:length(corticalGroup) 
    mkdir([targetDir, 'corticalProjections/slices/',injGroup_data(g).cortical_group])
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
      
        saveas(fig, ['corticalProjections/slices/', injGroup_data(g).cortical_group, '/summedCorticalGroup_',injGroup_data(g).cortical_group, '_slice',num2str(i),'.fig'], 'fig');
        print(fig, ['corticalProjections/slices/', injGroup_data(g).cortical_group, '/summedCorticalGroup_', injGroup_data(g).cortical_group, '_slice',num2str(i), '.eps'], '-depsc2');
        close(fig)
    end
end


%% Plot just the outline of the dense projection volume for each cortical area on one image, color coded (FIGURE)

targetDir='/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3';
cd(targetDir)
corticalGroup = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'SS', 'Vis', 'SUB_HIPP', 'Amyg', 'SNr', 'na'};
regionsToUse = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SS', 'Vis', 'SUB_HIPP', 'Amyg'};


mkdir('corticalProjectionsSpecialGroups/diffuseOnly/05_percent/') 
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
    
    saveas(fig, ['corticalProjectionsSpecialGroups/diffuseOnly/05_percent/summedCorticalGroupOutlines_slice',num2str(i),'.fig'], 'fig');
    print(fig, ['corticalProjectionsSpecialGroups/diffuseOnly/05_percent/summedCorticalGroupOutlines_slice',num2str(i),'.eps'], '-depsc2');
    close(fig)
end



%% plot all the injection sites color coded 
% 
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



targetDir='/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/data3';
cd(targetDir)
mkdir('corticalProjections/injections/')
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
targetDir='/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3';
cd(targetDir)
corticalGroup = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'SS', 'Vis', 'SUB_HIPP', 'Amyg', 'SNr', 'na'};


mkdir('corticalProjections/injections/slices/')
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
    
    saveas(fig, ['corticalProjections/injections/slices/summedInjections_slice',num2str(i),'.fig'], 'fig');
    print(fig, ['corticalProjections/injections/slices/summedInjections_slice',num2str(i), '.eps'], '-depsc2');
    close(fig)
end



%% Plot sections for different types of cortex

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

targetDir = ('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/');
cd(targetDir)

% This is plotting sections of the individual groups (FIGURE)
for g = 1:length(ctx) 
    mkdir([targetDir, 'corticalProjectionsSpecialGroups/typesOfCortex/',ctx(g).name])
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
       
      
        saveas(fig, ['corticalProjectionsSpecialGroups/typesOfCortex/',ctx(g).name, '/summedCorticalGroup_',ctx(g).name , '_slice',num2str(i),'.fig'], 'fig');
        print(fig, ['corticalProjectionsSpecialGroups/typesOfCortex/',ctx(g).name, '/summedCorticalGroup_',ctx(g).name , '_slice',num2str(i),'.eps'], '-depsc2');
        close(fig)
    end
end



% This is plotting sections with outlines of each cortical projection in the individual groups (FIGURE)
for g = 1:3
mkdir([targetDir, 'corticalProjectionsSpecialGroups/typesOfCortex_outlines/',ctx(g).name])
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

        saveas(fig, ['corticalProjectionsSpecialGroups/typesOfCortex_outlines/',ctx(cc).name, '/summedCorticalGroup_',ctx(cc).name , '_slice',num2str(i),'.fig'], 'fig');
        print(fig, ['corticalProjectionsSpecialGroups/typesOfCortex_outlines/',ctx(cc).name, '/summedCorticalGroup_',ctx(cc).name , '_slice',num2str(i),'.eps'], '-depsc2');
        close(fig)
    end
end


% This is plotting sections with outlines of the individual groups on the same slice (FIGURE)
ctx(1).color = [0 0 1]; ctx(2).color = [1 1 0]; ctx(3).color = [1 0 0];

mkdir(['corticalProjectionsSpecialGroups/typesOfCortex_singelOutlines/sum2'])
  
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

    saveas(fig, ['corticalProjectionsSpecialGroups/typesOfCortex_singelOutlines/sum2/summedCorticalGroup_',ctx(cc).name , '_slice',num2str(i),'.fig'], 'fig');
    print(fig, ['corticalProjectionsSpecialGroups/typesOfCortex_singelOutlines/sum2/summedCorticalGroup_',ctx(cc).name , '_slice',num2str(i),'.eps'], '-depsc2');
    close(fig)
end


%% I want to create groups in the A-P and M-L axes and fiew their projection patterns. 
% ***This ended up being heavily manual... only the ones that are in the figure are usable if this is redone

targetDir = '/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/data3';
load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/AIBS_100um.mat')
load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/inj_data.mat')
load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/injGroup_data.mat')
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

targetDir = ('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/');
cd(targetDir)

% This is plotting sections of the individual groups (FIGURE)
for g = 1:length(injLocationGroup_data(1).groups(gg).exp) 
     
%     a = 2; gg = 10; g = 6; %Just remaking A-P group 3 of 10
    
    mkdir([targetDir, 'corticalProjectionsSpecialGroups/', folderName, '/', num2str(gg), 'groups/group',num2str(g)])
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

        saveas(fig, ['corticalProjectionsSpecialGroups/', folderName, '/', num2str(gg), 'groups/group',num2str(g), '/summedCortical_',folderName, '_', 'group', num2str(g), 'of', num2str(gg), '_slice',num2str(i),'.fig'], 'fig');
        print(fig, ['corticalProjectionsSpecialGroups/', folderName, '/', num2str(gg), 'groups/group',num2str(g), '/summedCortical_',folderName, '_', 'group', num2str(g), 'of', num2str(gg), '_slice',num2str(i),'.eps'], '-depsc2');
        close(fig)
    end
end

    end
end


%% Now i want to make the "Hot-Spot" map  (FIGURE)
% Sections through the striatum for either the diffuse or dense sum of allareas
%       *for just cortical and all

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

targetDir = ('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/');
cd(targetDir)

% This is plotting sections of the individual hot spot groups (FIGURE)
for g = 1:length(densityLevel) 
    g = 1; %%% I am just making images iwth the threshold line for diffuse projections
    mkdir([targetDir, 'corticalProjectionsSpecialGroups/HotSpots/cortexAmygandHipp_evenColorscale'])
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
      
        saveas(fig, ['corticalProjectionsSpecialGroups/HotSpots/cortexAmygandHipp_evenColorscale_withThresholdLine/summedConvergence_density',num2str(g), '_slice',num2str(i),'.fig'], 'fig');
        print(fig, ['corticalProjectionsSpecialGroups/HotSpots/cortexAmygandHipp_evenColorscale_withThresholdLine/summedConvergence_density',num2str(g), '_slice',num2str(i), '.eps'], '-depsc2');
        close(fig)
    end
end

% _evenColorscale


%% Now I want to make histograms for the A-P, D-V, M-L distribution of all projection fields.  (FIGURE)
%
% I need to (ex: A-P):
%   1. Calculate the % of each section with projection from each region in it
%   2. Calculate the fraction of each projection field within that section
targetDir = ('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/');
cd(targetDir)

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
    
    saveas(fig1, ['distributionPlots/AP/projectionDistribution_Histogram_APaxis_',injGroup_data(g).cortical_group, '.fig'], 'fig');
    print(fig1, ['distributionPlots/AP/projectionDistribution_Histogram_APaxis_',injGroup_data(g).cortical_group, '.eps'], '-depsc2');
    close(fig1)
    
    saveas(fig2, ['distributionPlots/AP/projectionDistribution_normalizedHistogram_APaxis_',injGroup_data(g).cortical_group, '.fig'], 'fig');
    print(fig2, ['distributionPlots/AP/projectionDistribution_normalizedHistogram_APaxis_',injGroup_data(g).cortical_group, '.eps'], '-depsc2');
    close(fig2)
    
    saveas(fig3, ['distributionPlots/AP/projectionDistribution_normalizedLine_APaxis_',injGroup_data(g).cortical_group, '.fig'], 'fig');
    print(fig3, ['distributionPlots/AP/projectionDistribution_normalizedLine_APaxis_',injGroup_data(g).cortical_group, '.eps'], '-depsc2');
    close(fig3)

    
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
    
    saveas(fig1, ['distributionPlots/ML/projectionDistribution_Histogram_MLaxis_',injGroup_data(g).cortical_group, '.fig'], 'fig');
    print(fig1, ['distributionPlots/ML/projectionDistribution_Histogram_MLaxis_',injGroup_data(g).cortical_group, '.eps'], '-depsc2');
    close(fig1)
    
    saveas(fig2, ['distributionPlots/ML/projectionDistribution_normalizedHistogram_MLaxis_',injGroup_data(g).cortical_group, '.fig'], 'fig');
    print(fig2, ['distributionPlots/ML/projectionDistribution_normalizedHistogram_MLaxis_',injGroup_data(g).cortical_group, '.eps'], '-depsc2');
    close(fig2)
    
    saveas(fig3, ['distributionPlots/ML/projectionDistribution_normalizedLine_MLaxis_',injGroup_data(g).cortical_group, '.fig'], 'fig');
    print(fig3, ['distributionPlots/ML/projectionDistribution_normalizedLine_MLaxis_',injGroup_data(g).cortical_group, '.eps'], '-depsc2');
    close(fig3)

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



% For Allo-Meso-Neo group plots:
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
    
    saveas(fig1, ['distributionPlots/AlloMesoNeo/projectionDistribution_Histogram_APaxis_',ctx(g).name, '.fig'], 'fig');
    print(fig1, ['distributionPlots/AlloMesoNeo/projectionDistribution_Histogram_APaxis_',ctx(g).name, '.eps'], '-depsc2');
    close(fig1)
    
    saveas(fig2, ['distributionPlots/AlloMesoNeo/projectionDistribution_normalizedHistogram_APaxis_',ctx(g).name, '.fig'], 'fig');
    print(fig2, ['distributionPlots/AlloMesoNeo/projectionDistribution_normalizedHistogram_APaxis_',ctx(g).name, '.eps'], '-depsc2');
    close(fig2)
    
    saveas(fig3, ['distributionPlots/AlloMesoNeo/projectionDistribution_normalizedLine_APaxis_',ctx(g).name, '.fig'], 'fig');
    print(fig3, ['distributionPlots/AlloMesoNeo/projectionDistribution_normalizedLine_APaxis_',ctx(g).name, '.eps'], '-depsc2');
    close(fig3)

    
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
    
    saveas(fig1, ['distributionPlots/AlloMesoNeo/projectionDistribution_Histogram_MLaxis_',ctx(g).name, '.fig'], 'fig');
    print(fig1, ['distributionPlots/AlloMesoNeo/projectionDistribution_Histogram_MLaxis_',ctx(g).name, '.eps'], '-depsc2');
    close(fig1)
    
    saveas(fig2, ['distributionPlots/AlloMesoNeo/projectionDistribution_normalizedHistogram_MLaxis_',ctx(g).name, '.fig'], 'fig');
    print(fig2, ['distributionPlots/AlloMesoNeo/projectionDistribution_normalizedHistogram_MLaxis_',ctx(g).name, '.eps'], '-depsc2');
    close(fig2)
    
    saveas(fig3, ['distributionPlots/AlloMesoNeo/projectionDistribution_normalizedLine_MLaxis_',ctx(g).name, '.fig'], 'fig');
    print(fig3, ['distributionPlots/AlloMesoNeo/projectionDistribution_normalizedLine_MLaxis_',ctx(g).name, '.eps'], '-depsc2');
    close(fig3)

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
            mkdir(['corticalProjectionsSpecialGroups/', folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots']);
            
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

            saveas(fig1, ['corticalProjectionsSpecialGroups/', folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_Histogram_APaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.fig'], 'fig');
            print(fig1, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_Histogram_APaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.eps'], '-depsc2');
            close(fig1)

            saveas(fig2, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_normalizedHistogram_APaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.fig'], 'fig');
            print(fig2, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_normalizedHistogram_APaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.eps'], '-depsc2');
            close(fig2)

            saveas(fig3, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_normalizedLine_APaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.fig'], 'fig');
            print(fig3, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_normalizedLine_APaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.eps'], '-depsc2');
            close(fig3)


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

            saveas(fig1, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_Histogram_MLaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.fig'], 'fig');
            print(fig1, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_Histogram_MLaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.eps'], '-depsc2');
            close(fig1)

            saveas(fig2, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_normalizedHistogram_MLaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.fig'], 'fig');
            print(fig2, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_normalizedHistogram_MLaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.eps'], '-depsc2');
            close(fig2)

            saveas(fig3, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_normalizedLine_MLaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.fig'], 'fig');
            print(fig3, ['corticalProjectionsSpecialGroups/',folderName(9:end), '/', num2str(gg), 'groups/group',num2str(k), '/distributionPlots/projectionDistribution_normalizedLine_MLaxis_',folderName,'_group',num2str(k),'of',num2str(gg),'.eps'], '-depsc2');
            close(fig3)

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


%% Now lets make a convergence plot
% This is may be more associated with clustering, as I will want them ordered based on input similarity.. 
% Calculate the % of each subregion that is covered byprojections from each other area

targetDir = ('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/');
cd(targetDir)
load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/AIBS_100um.mat')
load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/injGroup_data.mat')
ic_submask = AIBS_100um.striatum.ic_submask;

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
        convergenceVolume1= sum(injGroup_data(ind).mask1.ipsilateral(:)&injGroup_data(ind2).mask1.ipsilateral(:));
        convergenceVolume2= sum(injGroup_data(ind).mask2.ipsilateral(:)&injGroup_data(ind2).mask2.ipsilateral(:));
        convergenceVolume3= sum(injGroup_data(ind).mask5.ipsilateral(:)&injGroup_data(ind2).mask5.ipsilateral(:));
        
        percentGcoveredByGG1(g, gg) = convergenceVolume1/totalProjVolume1;   %Rows(g) = percent of that region covered by columns(gg)
        percentGcoveredByGG2(g, gg) = convergenceVolume2/totalProjVolume2;   %Rows(g) = percent of that region covered by columns(gg)
        percentGcoveredByGG3(g, gg) = convergenceVolume3/totalProjVolume3;   %Rows(g) = percent of that region covered by columns(gg)

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

% convergence_vector = squareform(percentGcoveredByGG1);
convergence_PairwiseDistance = pdist(percentGcoveredByGG1,'correlation');
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
imagesc(percentGcoveredByGG1(OrderFromCorrelation3levels, OrderFromCorrelation3levels));
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

saveas(fig, ['corticalProjectionsSpecialGroups/HotSpots/plots/subregionConvergence_OrderByVoxelClustering_level_1.fig'], 'fig');
print(fig, ['corticalProjectionsSpecialGroups/HotSpots/plots/subregionConvergence_OrderByVoxelClustering_level_1.eps'], '-depsc2');
close(fig)


fig = figure;
imagesc(percentGcoveredByGG1(optimleaf, optimleaf));
caxis([0 1])
colormap(hot)
set(gcf, 'Position', [6 316 829 790])
set(gca, 'YTick', 1:length(regionsToUse))
set(gca, 'YTickLabel', cPlotNames(optimleaf))
set(gca, 'XTick', 1:length(regionsToUse))
set(gca, 'xTickLabel', cPlotNames(optimleaf))
title('optimal leaf order')
ylabel('Fraction or proections from subregion')
xlabel('Convergent with projections from subregion')
set(fig,'PaperPositionMode','auto')

saveas(fig, ['corticalProjectionsSpecialGroups/HotSpots/plots/subregionConvergence_level_1.fig'], 'fig');
print(fig, ['corticalProjectionsSpecialGroups/HotSpots/plots/subregionConvergence_level_1.eps'], '-depsc2');
close(fig)


%% Make a convergence plot for the Allo-Meso-Neo groups

targetDir = ('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/');
cd(targetDir)
load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/AIBS_100um.mat')
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

saveas(fig, ['corticalProjectionsSpecialGroups/typesOfCortex/plots/subregionConvergence_level_1.fig'], 'fig');
print(fig, ['corticalProjectionsSpecialGroups/typesOfCortex/plots/subregionConvergence_level_1.eps'], '-depsc2');
close(fig)

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

saveas(fig, ['corticalProjectionsSpecialGroups/typesOfCortex/plots/subregionConvergence_level_2.fig'], 'fig');
print(fig, ['corticalProjectionsSpecialGroups/typesOfCortex/plots/subregionConvergence_level_2.eps'], '-depsc2');
close(fig)

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

saveas(fig, ['corticalProjectionsSpecialGroups/typesOfCortex/plots/subregionConvergence_level_3.fig'], 'fig');
print(fig, ['corticalProjectionsSpecialGroups/typesOfCortex/plots/subregionConvergence_level_3.eps'], '-depsc2');
close(fig)

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
