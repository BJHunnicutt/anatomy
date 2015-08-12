function [rotatedData, data] = jh_pImport2matlab2(dataDir, saveFlag)
%
% INPUTS:   dataDir: data filepath (THE LOCATION OF THE DATA OUTPUT FROM jh_export2matlab4.py)
%                    dataDir is also the place that the data folders & tiffs will be saved
%           saveFlag: 1 or 0: do you want to save all the outputs from this (including tiffs)
% 
% 
% OUTPUTS:  rotatedData: experimental projection matrices aligned to the average template brain and rorated coronally
%           data:  the original pImport data (mostly kept for filenames later
% 
% 
% PURPOSE:
% Import the AIBS corticostriatal data generated by ?jh_export2matlab4.py?, 
% puts it in a matrix, rotates it to be coronal, masks the density data to my model striatum, & 
% creates a data folder with tiffs for each experiment 
% (Also some commented accessory code to look at the data at the end


%% Import all experiments from the designated directory into matlab
% This takes in the data that is generated by running jh_export2matlab4 -4/20/15
%
% Important note to self... This was a learning experience. In the future forget that "eval"
% exists, making variable names variables is a terrible way to program.


% targetDir='/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/data3';
targetDir = dataDir;
cd(targetDir)

cd ..
metaDir = ([cd, '/meta3']);
mkdir(metaDir);
movefile([targetDir, '/inj_metadata*'], metaDir) % Need to move the metadata files to /meta3


cd(targetDir)

d=dir; % d(1:3)=[];
a = 1;
for j = 1:length(d)
    if d(j).name(1) == 'v'
        d2(a)=d(j);
        a = a+1;
    end
end
d = d2';

for w = 1:2; 
% IMPORTANT!!!! This is really stupid, but this has to be run twice to deal with weird injection issues 
% (the first time voxPos will get fixed, but voxDen will be wrong if there was a problem with the injection, the second time they will be fixed)
    for i_file=1:length(d)

    %     d(i_file).name;
        load(d(i_file).name);
        EID=d(i_file).name(9:17);

        eval(['data.e',num2str(EID),'.area=d(i_file).name(19:end-4);']);

        if exist('voxPosL')
            eval(['data.e',num2str(EID),'.L.voxPos=voxPosL;']);
            clear voxPosL
        elseif exist('voxPosR')
            eval(['data.e',num2str(EID),'.R.voxPos=voxPosR;']);
            clear voxPosR
        elseif exist('voxDenL')
            eval(['data.e',num2str(EID),'.L.voxDen=voxDenL'';']); 
            clear voxDenL    
    %     elseif exist('voxDen2') % TEMP
    %         eval(['data.e',num2str(EID),'.test.voxDen=voxDen2'';']); 
    %         clear voxDen2   
        elseif exist('voxDenR')
            eval(['data.e',num2str(EID),'.R.voxDen=voxDenR'';']); 
            clear voxDenR  
        elseif exist('voxPosInj') %Updata 4/22/15

            % There is something weird with a bunch of injection sites, where
            % random voxel locations will be jiberish... the corresponding density value is always super low (<0.0004)
            % I am doing the following to remove those values. 
            indexZeros = false(size(voxPosInj, 1), 1);  
            for k = 1:size(voxPosInj, 1)
                if voxPosInj(k, 1) == 0 || voxPosInj(k, 2) == 0 ||voxPosInj(k, 3) == 0
                    indexZeros(k, 1) = 1;
                end
            end
            if sum(indexZeros) > 0
                newVoxPosInj = [];
                for k = 1:size(voxPosInj, 1)
                    if indexZeros(k) ~= 1
                        newVoxPosInj = cat(1, newVoxPosInj, voxPosInj(k, :));
                    end
                end
                 display([num2str(EID), ' had an injection site mask with zeros...'])
                 display(['           *It is now ', num2str(size(newVoxPosInj, 1)), ' voxels, the full length was ', num2str(length(indexZeros))])
                eval(['data.e',num2str(EID),'.Inj.truncatedMask = 1;']);
                eval(['data.e',num2str(EID),'.Inj.previousLength = ', num2str(size(voxPosInj, 1)), ';']);
                eval(['data.e',num2str(EID),'.Inj.indexZeros = indexZeros;']);
                eval(['data.e',num2str(EID),'.Inj.voxPos = newVoxPosInj;']);
            else
                eval(['data.e',num2str(EID),'.Inj.truncatedMask = 0;']); 
                eval(['data.e',num2str(EID),'.Inj.voxPos=voxPosInj;']);
            end           
            clear voxPosInj newVoxPosInj indexZeros

        elseif exist('voxDenInj') %Updata 4/22/15
            % This will remove the density values that correspond to the voxel locations in voxPosInj with zeros
            eval(['data.e',num2str(EID),'.Inj.voxDen=voxDenInj;']); 
            thisIsRidiculous = 'previousLength';

            if eval(['isfield(data.e',num2str(EID),'.Inj, thisIsRidiculous);']) 
                eval(['indexZeros = data.e',num2str(EID),'.Inj.indexZeros;']); 
                if sum(indexZeros) > 0
                    newVoxDenInj = [];
                    for k = 1:length(voxDenInj)
                        if indexZeros(k) ~= 1
                            newVoxDenInj = cat(2, newVoxDenInj, voxDenInj(k));
                        end
                    end
                    eval(['data.e',num2str(EID),'.Inj.voxDen=newVoxDenInj;']);
                else
                    eval(['data.e',num2str(EID),'.Inj.voxDen=voxDenInj'';']); 
                end
            end
            clear voxDenInj newVoxDenInj indexZeros

        elseif exist('voxDenAll') %Updata 4/20/15
            eval(['data.e',num2str(EID),'.All=voxDenAll;']); 
            clear voxDenAll  
        end
    end
end

clear d2 i_file a j thisIsRidiculous

if saveFlag == 1
    cd ..
    mkdir([cd, '/analyzed4'])
    save('analyzed4/data_pImport.mat', 'data')
end



%% Putting the data into matrices, updated from above to remove that translation... %Updata 4/20/15

%convert each of the experiments into a 3d structure
fNames=fields(data);

for i_exp=1:length(fNames)
    
    eval(['tempData=data.',fNames{i_exp},';'])
    

    injection3dDensities = zeros(size(tempData.All));
    injection3dMask = zeros(size(tempData.All));
    
    for i_hemi=1:2   %have voxel positions and densities, convert into 3d matrix
        striatum3dDensities = zeros(size(tempData.All));
        striatum3dMask = zeros(size(tempData.All));
        
        if i_hemi==1    
            voxPosNorm = double(tempData.L.voxPos); %Getting the left striatum mask and densities into a matrix
            voxDen = tempData.L.voxDen;
            for i_vox = 1:length(voxDen)
                striatum3dDensities(voxPosNorm(i_vox,1),voxPosNorm(i_vox,2),voxPosNorm(i_vox,3)) = voxDen(i_vox);
                striatum3dMask(voxPosNorm(i_vox,1),voxPosNorm(i_vox,2),voxPosNorm(i_vox,3)) = 1;
                
            end
        elseif i_hemi==2
            voxPosNorm=double(tempData.R.voxPos); %Getting the right striatum mask and densities into a matrix
            voxDen=tempData.R.voxDen;
            for i_vox=1:length(voxDen)
                striatum3dDensities(voxPosNorm(i_vox,1),voxPosNorm(i_vox,2),voxPosNorm(i_vox,3)) = voxDen(i_vox);
                striatum3dMask(voxPosNorm(i_vox,1),voxPosNorm(i_vox,2),voxPosNorm(i_vox,3)) = 1;
            end
        end
        
        voxPosInj = double(tempData.Inj.voxPos); %Getting the injection site mask and densities into a matrix
        voxDenInj = tempData.Inj.voxDen;
        for i_voxInj=1:length(voxDenInj)
            injection3dDensities(voxPosInj(i_voxInj,1),voxPosInj(i_voxInj,2),voxPosInj(i_voxInj,3)) = voxDen(i_voxInj);
            injection3dMask(voxPosInj(i_voxInj,1),voxPosInj(i_voxInj,2),voxPosInj(i_voxInj,3)) = 1;
        end

        if i_hemi==1
            data2.striatum3d(i_exp).L.densities = striatum3dDensities; 
            data2.striatum3d(i_exp).L.mask = striatum3dMask;
        elseif i_hemi==2
            data2.striatum3d(i_exp).R.densities = striatum3dDensities;
            data2.striatum3d(i_exp).R.mask = striatum3dMask;
        end    
    end
    data2.injection3d(i_exp).densities = injection3dDensities;
    data2.injection3d(i_exp).mask = injection3dMask;
    
    data2.area{i_exp} = tempData.area;
    data2.expID(i_exp) = fNames(i_exp);
    data2.fullDensityMap(i_exp).densities = double(tempData.All); %Also savign the full brain densities into a matrix
    
    
    %%%%% The densities and masks are one pixel off in all dimensions from the averageTemplate100um and the full density map...
    % data2: 
    %     column 1 = dorsal
    %     row 1 = anterior
    %     section 1 = left
    % data3:
    %     column 1 = left
    %     row 1 = dorsal
    %     section 1 = anterior
    % 
    % So I'm removing column 1, row 1, and section 1 does the same thing to both masks:
    % ****** I am VERY CONFIDENT (I checked at least 15 times) that this next step gets all the data is aligned to itself.
    %        I am pretty sure that the relationship between sections in my data is 1 off of what you see on the AIBS Composite Projection Viewer. 
    %        My Section 58 is there section 57
    data2.striatum3d(i_exp).L.densities(2:end, 2:end, 2:end) = data2.striatum3d(i_exp).L.densities(1:end-1, 1:end-1, 1:end-1);
    data2.striatum3d(i_exp).L.mask(2:end, 2:end, 2:end) = data2.striatum3d(i_exp).L.mask(1:end-1, 1:end-1, 1:end-1);
    data2.striatum3d(i_exp).R.densities(2:end, 2:end, 2:end) = data2.striatum3d(i_exp).R.densities(1:end-1, 1:end-1, 1:end-1);
    data2.striatum3d(i_exp).R.mask(2:end, 2:end, 2:end) = data2.striatum3d(i_exp).R.mask(1:end-1, 1:end-1, 1:end-1);
    data2.injection3d(i_exp).densities(2:end, 2:end, 2:end) = data2.injection3d(i_exp).densities(1:end-1, 1:end-1, 1:end-1);     %%%not sure if the injection sites need it too... try and see. 
    data2.injection3d(i_exp).mask(2:end, 2:end, 2:end) = data2.injection3d(i_exp).mask(1:end-1, 1:end-1, 1:end-1);  
 
end




%% This was done at the very end before, but I like quickly skimming coronal sections so I'm doing it now Update 4/20/15
% this will rotate the matrices so the coordinates are equivalent to coronal sections 
% Rotating the matrix by 90degrees so that z traverses the anterior-posterior axis


fNames=fields(data);


% targetDir='/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/avgTemplate100micron'; 
targetDirATB = uigetdir(targetDir, 'Where is the avgTemplate100micron.mhd file?');  % I want to import the average template brain and have it aligned
cd(targetDirATB)
mhd = read_mhd2('avgTemplate100micron.mhd');
data2.averageTemplate100um = mhd.data;

% data2.averageTemplate100um(1:end-1, 1:end-1, 1:end-1) = data2.averageTemplate100um(2:end, 2:end, 2:end); 


for i_exp = 1:length(fNames)
    
    
    matrixToRotate{1} = data2.striatum3d(i_exp).L.densities; 
    matrixToRotate{2} = data2.striatum3d(i_exp).L.mask;
    matrixToRotate{3} = data2.striatum3d(i_exp).R.densities;
    matrixToRotate{4} = data2.striatum3d(i_exp).R.mask;
    matrixToRotate{5} = data2.injection3d(i_exp).densities;
    matrixToRotate{6} = data2.injection3d(i_exp).mask;
    matrixToRotate{7} = data2.fullDensityMap(i_exp).densities;
    matrixToRotate{8} = data2.averageTemplate100um;
    
    
    for k = 1:length(matrixToRotate)
        %Rotate each confidence map matrix so that z is the A-P axis
        X = matrixToRotate{k}; 
        s = size(X); % size vector
        v = [2, 3, 1]; %makes z slices coronal
        Y = reshape( X(:,:), s);
        Y = permute( Y, v );
        matrixToRotate{k} = Y;
    end
    
    data3.striatum3d(i_exp).L.densities = matrixToRotate{1}; 
    data3.striatum3d(i_exp).L.mask = matrixToRotate{2};
    data3.striatum3d(i_exp).R.densities = matrixToRotate{3};
    data3.striatum3d(i_exp).R.mask = matrixToRotate{4};
    data3.injection3d(i_exp).densities = matrixToRotate{5};
    data3.injection3d(i_exp).mask = matrixToRotate{6};
    data3.fullDensityMap(i_exp).densities = matrixToRotate{7};
    data3.averageTemplate100um = matrixToRotate{8};
    
    data3.area{i_exp} = data2.area{i_exp};
    data3.expID(i_exp) = data2.expID(i_exp);
    
end


% % The averageTemplate100um is one pixel off in all dimensions. Fixing it here:  ***Decided to move the masks instead before rotation. 
% % The way it was rotated means:
% % 
% % data2: 
% %     column 1 = dorsal
% %     row 1 = anterior
% %     section 1 = left
% % data3:
% %     column 1 = left
% %     row 1 = dorsal
% %     section 1 = anterior
% % 
% % So removing column 1, row 1, and section 1 does the same thing to both masks:

% data3.averageTemplate100um(1:end-1, 1:end-1, 1:end-1) = data3.averageTemplate100um(2:end, 2:end, 2:end);
% data2.averageTemplate100um(1:end-1, 1:end-1, 1:end-1) = data2.averageTemplate100um(2:end, 2:end, 2:end); 



%% Creating another dataset that uses my trace of the striatum instead of theirs              *******ADDED 4/28/15*******
%       *I traced the striatum for the 25um masks, so first it has to be downsampled
%   1. Load the mask
%   2. Downsample to 100um voxels
%   3. Put in a full mask (instead of start to stop of striatum
%   4. Make sure it is in exactly the same coordinate system as the AI data
%   5. mask the fullDensityMap with my tracing


targetDirStr = uigetdir(targetDir, 'Where is the strmask_25um.mat file?'); 
load([targetDirStr, '/strmask_25um.mat'])
% load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/averageTemplate25micron/str/strmask_25um.mat') %Loads as strmask and is 320x456x176 with 25um voxels
% load('/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/2015_04_22_testData/data3_2015_04_28.mat') %loads the data from above steps
strmask_25um = double(strmask);

[x, y, z]= meshgrid(1:456, 1:320, 1:176);
[xi, yi, zi] = meshgrid(1:4:456, 1:4:320, 1:4:176); %100x100x100um voxels

downsampledStrMask = round(interp3(x, y,z, strmask_25um, xi, yi, zi));  % added 'round' here to put data back to initial space.  

fullMask = false(size(data3.averageTemplate100um));

fullMask(1:80, 1:114, 35:78) = downsampledStrMask;

data3.ourStriatumMask = fullMask;


% Look through the average brain with my striatum mask and the AI striatum mask...
% for k = 35:50
%     figure, imshow(data3.averageTemplate100um(:, :, k)/500, 'Border','tight','InitialMagnification', 600)
%     outline = h_getNucleusOutline(test(:, :, k));
%     hold on
%     for j = 1:length(outline)
%     plot((outline{j}(:,2)), (outline{j}(:,1)), 'r-', 'linewidth',1)
%     end
%     strMask_AI = data3.striatum3d(1).L.mask+data3.striatum3d(1).R.mask;
%     outline = h_getNucleusOutline(strMask_AI(:, :, k+1));
%     hold on
%     for j = 1:length(outline)
%     plot((outline{j}(:,2)), (outline{j}(:,1)), 'b-', 'linewidth',1)
%     end
% end

%% Make a folder for of each brain number & Populate it with tiff images of the projections/injections:  
%     -tiffs/
%     -meta (add the stuff that would be in strdata to this, like str strt, projection.L.start & stop etc.)
%     -submask

% targetDir='/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/data3';
cd(targetDir)
fNames=fields(data);

averageTemplate100um = data3.averageTemplate100um;
averageTemplate100um_original = data2.averageTemplate100um;

if saveFlag == 1
    cd ..
	mkdir([cd, '/analyzed4/averageBrain100um'])
    save('analyzed4/averageBrain100um/averageTemplate100um_rotated.mat', 'averageTemplate100um')
    save('analyzed4/averageBrain100um/averageTemplate100um_original.mat', 'averageTemplate100um_original')
end

fullMask = data3.ourStriatumMask; %This has only existed since 4/28/15


for i = 1:length(fNames)
    rotatedData = [];
    originalData = [];
    EID=fNames{i}(2:end);
    bilateral = [];
    
    leftmask = false(size(fullMask(:, :, 1)));
    leftmask(:, 1:58) = 1;
    rightmask = false(size(fullMask(:, :, 1)));
    rightmask(:, 57:end) = 1;
    for p = 1:size(fullMask, 3)
        bilateral = data3.fullDensityMap(i).densities(:, :, p).*fullMask(:, :, p); 
        
        rotatedData.striatum3d.L.densities(:, :, p) = bilateral.*leftmask;
        rotatedData.striatum3d.R.densities(:, :, p) = bilateral.*rightmask;
        rotatedData.striatum3d.L.mask(:, :, p) = fullMask(:, :, p).*leftmask; 
        rotatedData.striatum3d.R.mask(:, :, p) = fullMask(:, :, p).*rightmask;
        rotatedData.striatum3d.Full.densities(:, :, p) = bilateral;
        rotatedData.striatum3d.Full.mask = fullMask(:, :, p); 
    end
    
    
%%%%% Re-running all of this code to recreate tiffs, and I dont want to override changes that have been made to injMeta.mat, so I am not doing this this time
%     mkdir(EID)
%     injMeta = load(['/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/meta3/inj_metadata_', EID, '.mat']);  
%     injMeta = injMeta.a; %meta is saved as a, and meta = load([/Users...) gives meta.a.everythingelse
%     injMeta.striatum.strstrt = 35;
%     injMeta.striatum.strnd = 78;
%     injMeta.striatum.thalstrt = 56;
%     injMeta.striatum.thalnd = 84;
%     injMeta.striatum.ccmerge = 44;
%     injMeta.striatum.ccsplit = 81;
%     injMeta.striatum.ccmerge = 44;
%     injMeta.striatum.acasplit = 56;
%     
% %     %Putting a copy or the original metadata I got in here
%     copyfile(['/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/meta3/inj_metadata_', EID, '.mat'], ['/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/data3/',EID, '/'])
%     
    rotatedData.fullDensityMap = data3.fullDensityMap(i);
    rotatedData.injection3d = data3.injection3d(i);
    rotatedData.striatum3d_AI = data3.striatum3d(i);
    rotatedData.area = data3.area{i};
    rotatedData.expID = data3.expID{i}(2:end);
    
    originalData.fullDensityMap = data2.fullDensityMap(i);
    originalData.injection3d = data2.injection3d(i);
    originalData.striatum3d_AI = data2.striatum3d(i);
    originalData.area = data2.area{i};
    originalData.expID = data2.expID{i}(2:end);
    
    if saveFlag == 1
        save([EID, '/rotatedData.mat'], 'rotatedData')
        save([EID, '/originalData.mat'], 'originalData')
    %     save([EID, '/injMeta.mat'], 'injMeta')

        mkdir([EID, '/tiffs/'])
        for k = 1:size(rotatedData.striatum3d.R.densities, 3)
            for c = 1:3
                avgImg(:, :, c) = data3.averageTemplate100um(:, :, k)/500;
            end
            avgImg(:, :, 2) = avgImg(:, :, 2)+(logical((rotatedData.striatum3d.R.densities(:, :, k)>.005)+(rotatedData.striatum3d.L.densities(:, :, k)>0.005))*10);
            avgImg(:, :, 2) = avgImg(:, :, 2)+(data3.injection3d(i).mask(:, :, k)>.05)*10;
            avgImg(:, :, 1) = avgImg(:, :, 1)+(data3.fullDensityMap(i).densities(:, :, k)>.005)*50;
    %          avgImg(:, :, 1) = avgImg(:, :, 1)+ logical((data3.striatum3d(i).L.mask(:, :, k))*5+(data3.striatum3d(i).R.mask(:, :, k))*5);

            maskR = rotatedData.striatum3d.R.densities(:, :, k)>.005;
            maskL = rotatedData.striatum3d.L.densities(:, :, k)>.005;
            maskI = data3.injection3d(i).mask(:, :, k)>.05;
            maskS = (data3.striatum3d(i).L.mask(:, :, k)>.05)+(data3.striatum3d(i).R.mask(:, :, k)>.05);


            fig = figure;
            imshow(avgImg,'Border','tight','InitialMagnification', 200); %Both the border an magnification things are necessary to avoid a sea of white.

            %Outline of right
            outline = h_getNucleusOutline(maskR(:, :));
            hold on
            for j = 1:length(outline)
            plot((outline{j}(:,2)), (outline{j}(:,1)), 'g-', 'linewidth',1)
            end
            %Outline of left
            outline = h_getNucleusOutline(maskL(:, :));
            hold on
            for j = 1:length(outline)
            plot((outline{j}(:,2)), (outline{j}(:,1)), 'g-', 'linewidth',1)
            end
            %Outline of Injection
            outline = h_getNucleusOutline(maskI(:, :));
            hold on
            for j = 1:length(outline)
            plot((outline{j}(:,2)), (outline{j}(:,1)), 'k-', 'linewidth',1)
            end
    %         %Outline of Striatum
    %         outline = h_getNucleusOutline(maskS(:, :));
    %         hold on
    %         for j = 1:length(outline)
    %         plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'r-', 'linewidth',1)
    %         end
    %         

            print(fig, '-dtiff', [EID, '/tiffs/',EID, '_', num2str(k), '.tif']);
            close(fig)
        end
    end
end

% BELOW ARE TEST SCRIPTS TO MOVE FILES AND LOOK AT THE DATA (Useful, but shouldn't be run as one large script)
% % 
% % %% Move just the tiffs for katrina
% % fNames=fields(data);
% % currentFolder = pwd;
% % 
% % for i = 1:25%length(fNames)
% %     
% %     EID=fNames{i}(2:end);
% %     cd([currentFolder, '/', EID])
% %     
% %     % Copy all the files in the tiffs folders... 
% %     copyfile(['tiffs/', EID, '*'],['/Volumes/WD05/AIBSdata/',EID, '/tiffs/'])
% %     copyfile('rotatedData.mat',['/Volumes/WD05/AIBSdata/',EID, '/rotatedData.mat'])
% %     copyfile('originalData.mat',['/Volumes/WD05/AIBSdata/',EID, '/originalData.mat'])
% %     
% % end
% % 
% % 
% % 
% % %% This was a test to look at a seciton of the average brain with the injeciton site, projection, and striatum mask
% % % Beautiful
% % 
% % 
% % s = 55;
% % k = 1;
% % 
% % figure, imshow(data3.averageTemplate100um(:, :, s))
% % caxis('auto')
% % outline = h_getNucleusOutline(data3.injection3d(k).mask(:, :, s));
% % hold on
% % for j = 1:length(outline)
% % plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'r-', 'linewidth',1)
% % end
% % outline = h_getNucleusOutline(data3.striatum3d(k).R.densities(:, :, s));
% % for j = 1:length(outline)
% % plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'b-', 'linewidth',1)
% % end
% % outline = h_getNucleusOutline(data3.striatum3d(k).R.mask(:, :, s));
% % for j = 1:length(outline)
% % plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'g-', 'linewidth',1)
% % end
% % 
% % 
% % %Testing ways to look... 
% % test = squeeze(sum(data3.striatum3d(2).R.densities, 3));;
% % figure, imshow(test)
% % hold on
% % imshow(data3.averageTemplate100um(:, 1:57, 50)/500)
% % caxis('auto')
% % 
% % maxmask = sum(data3.striatum3d(2).R.mask, 3);
% % outline = h_getNucleusOutline(maxmask);
% % hold on
% % for j = 1:length(outline)
% % plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'r-', 'linewidth',1)
% % end
% % 
% % outline = h_getNucleusOutline(data3.striatum3d(2).L.mask(:,:,50));
% % hold on
% % for j = 1:length(outline)
% % plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'g-', 'linewidth',1)
% % end
% % 
% % outline = h_getNucleusOutline(data3.striatum3d(2).R.mask(:,:,50));
% % hold on
% % for j = 1:length(outline)
% % plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'g-', 'linewidth',1)
% % end
% % 
% % outline = h_getNucleusOutline(data3.striatum3d(2).R.densities(:,:,50));
% % hold on
% % for j = 1:length(outline)
% % plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'b-', 'linewidth',1)
% % end
% % 
% % 
% % % Max Projections from all angles!
% % 
% % %LATERAL
% % img = squeeze(sum(data3.striatum3d(2).R.densities, 2));
% % figure, imshow(img*2)
% % hold on
% % maxmask = squeeze(sum(data3.striatum3d(2).R.mask, 2));
% % outline = h_getNucleusOutline(maxmask);
% % hold on
% % for j = 1:length(outline)
% % plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'r-', 'linewidth',1)
% % end
% % maxmask = squeeze(sum(data3.averageTemplate100um, 2))>500;;
% % outline = h_getNucleusOutline(maxmask);
% % hold on
% % for j = 1:length(outline)
% % plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'g-', 'linewidth',1)
% % end
% % 
% % %ANTERIOR
% % img = squeeze(sum(data3.striatum3d(2).R.densities, 3));
% % figure, imshow(img*2)
% % hold on
% % maxmask = squeeze(sum(data3.striatum3d(2).R.mask, 3));
% % outline = h_getNucleusOutline(maxmask);
% % hold on
% % for j = 1:length(outline)
% % plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'r-', 'linewidth',1)
% % end
% % maxmask = squeeze(sum(data3.averageTemplate100um, 3))>500;;
% % outline = h_getNucleusOutline(maxmask);
% % hold on
% % for j = 1:length(outline)
% % plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'g-', 'linewidth',1)
% % end
% % 
% % %DORSAL
% % img = squeeze(sum(data3.striatum3d(2).R.densities, 1));
% % figure, imshow(img*2)
% % hold on
% % maxmask = squeeze(sum(data3.striatum3d(2).R.mask, 1));
% % outline = h_getNucleusOutline(maxmask);
% % hold on
% % for j = 1:length(outline)
% % plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'r-', 'linewidth',1)
% % end
% % maxmask = squeeze(sum(data3.averageTemplate100um, 1))>500;;
% % outline = h_getNucleusOutline(maxmask);
% % hold on
% % for j = 1:length(outline)
% % plot((outline{j}(:,2)), (outline{j}(:,1))+0.5, 'g-', 'linewidth',1)
% % end
% % 
% % 
% % 
% % % I also tried creating my own map, and It ends up giving me traveling
% % % axons that I didnt see in the original map. 
% % % newD = data2.fullDensityMap.densities.*data2.striatum3d(i_exp).L.mask;  
% %  