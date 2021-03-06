function [injGroup_data] = jh_consolidatingAIBSdatasets(saveFlag)
% [injGroup_data] = JH_CONSOLIDATINGAIBSDATASETS(saveFlag) 
% 
% INPUTS: saveFlag (1 or 0 ) saying whether you want to save injGroup_data and inj_data.mat
%                 (saveFlag == 2) will update injMeta.mat in each meta3/EID/ folder -- making separate because I don't want to redo these everytime)
% OUTPUT: injGroup_data cortically grouped corticostriatal projection data 
% 
% PURPOSE: This will take the output from jh_pImport2matlab2.m 
% rotatedData.mat (i.e. experimental projection matrices aligned to the average template brain) 
% injMeta.mat (injection specific metadata) & submask.mat (bundles to subtract)
% for each experiment and group them by common cortical origin
% 

disp('Where is the data folder (python output)?')
% likely here: '/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/data3'
targetDir= uigetdir('/', 'Where is the data folder (python output)?');
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
load([anaDir, '/data_pImport.mat']) % Import variable from jh_pImport2matlab.m: data

load([randomMasksDir, '/averageTemplate100umACA_rotated.mat']) % Import averageTemplate100umACA_rotated
load([randomMasksDir, '/averageTemplate100um_rotated.mat']) % Import variable from jh_pImport2matlab.m: averageTemplate100um_rotated
load([randomMasksDir, '/strmask_ic_submask.mat']) %I made a mask that removes the internal capsule
load([randomMasksDir, '/AIBS_100um.mat'])  %this was made later, but can replace a lot of missing things if needed
ic_submask = submask;

% Data generated below, if I want to reload the old data
% load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/injGroup_data.mat')
% load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3/inj_data.mat')


group = {'ACA','AI_GU_VISC','AUD','ECT_PERI_TE','FRA','IL','MOp','ORBl','PL_MO','PTL','RSP','SSp','SSp-bfd','SSs','VISam','VISl','VISp', 'SS', 'Vis', 'SUB_HIPP', 'Amyg', 'SNr', 'na'};


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

cd ../meta3
metaDir = cd;

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
%           ... (In case I ever forget this: I just copied the column out of excel,'paste and match style' in Text Edit and find and replace line breaks with ';' )

for g = 1:length(fNames)
    expIDcell{g} = fNames{g}(2:end);
end
expIDcell = expIDcell';

% targetDir='/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/data3';

for i = 1: length(inj_data)
    if inj_data(i).expID == num2str(expIDcell{i})
       inj_data(i).cortical_group = inj_group{i};
       
       EID = expIDcell{i};

        cd([targetDir, '/', inj_data(i).expID])
        
        load('injMeta.mat')
        injMeta.group = inj_group{i};
        injMeta.mouseline = inj_data(i).mouseline;
        if saveFlag == 2
            save([targetDir, '/', inj_data(i).expID, '/injMeta.mat'], 'injMeta')
        end
       
    else i % this will make sure that I am assigning the correct experiments to the correct groups
    end
    clear injMeta
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Then I'll create composite masks for the cortical groups at 3 thresholds.... 

% targetDir='/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/data3';
% load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/data3/averageBrain100um/averageTemplate100um_rotated.mat')
% load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/strmask_ic_submask.mat') %I made a mask that removes the internal capsule
% ic_submask = submask;

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

if saveFlag == 1
    save([anaDir, '/injGroup_data.mat'],'injGroup_data', '-v7.3') 
    save([anaDir, '/inj_data.mat'], 'inj_data')
end

%%%%%%%%%%%%%%%% 8/12/15 JH- Moved all the figures and remaining analysis
%%%%%%%%%%%%%%%% to a new function: jh_corticostriatalFigures.m
