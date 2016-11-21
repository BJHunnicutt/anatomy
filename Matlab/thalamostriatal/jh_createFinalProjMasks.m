function varargout = jh_createFinalProjMasks(brains)

% JH_CREATEFINALPROJMASKS will create the final projection masks (i.e. the mask that 
% defines where in the striatum that red and green projections are located).
% 
% INPUT: a 
%
% It will use the take the probmask and limit it to the strmask, then it will add the 
% addmask, and subtract the colormask. The probmask to use is determined by 
% WEKA.thresholdBySlice.


currentFolder = pwd;
brains = [076005, 076006, 076007, 076008, 076009, 076010];
 %[076001, 076002, 076003, 076004, 076005, 076006, 076007, 076008, 076009, 076010, 076012, 076013, 076014, 076015, 076016, 076018, 076019, 076020, 076024, 076025, 076027, 076028, 076029];

% % % Final list of brains we're using (68):
% % brains = [060536, 075019, 075032, 075034, 075036, 075074, 075075, 075077, 075078, 075083, 075086, 075106, 075107, 075108, 075109, 075110, 075111, 075112, 075115, 075117, 075118, 075120, 075121, 075122, 075123, 075124, 075126, 075127, 075128, 075129, 075130, 075131, 075132, 075133, 075087, 075912, 075914, 075915, 075916, 075917, 075918, 075919, 075920, 075924, 075925, 076001, 076002, 076003, 076004, 076005, 076006, 076007, 076008, 076009, 076010, 076012, 076013, 076014, 076015, 076016, 076018, 076019, 076020, 076024, 076025, 076027, 076028, 076029];

 
 
for i = 1:length(brains)
    b = brains(i);
    cd([currentFolder, '/', num2str(brains(i), '%06i')])
    load masteralign2
    load str/strdata.mat
    load str/strmask.mat
    redProjectionMask = false(size(strmask));
    greenProjectionMask = false(size(strmask));
    
    
    
    % Load the red and green data
    if isfield(WEKA.threshold, 'greenHigh');   % loading the probability masks
        load (['str/wekaProbMaskGreen','_Threshold', num2str(WEKA.threshold.greenHigh,'%02i'), '.mat'], 'wekaProbMaskGreen');
        wekaProbMaskHigh_green = wekaProbMaskGreen; 

        load (['str/wekaProbMaskGreen','_Threshold', num2str(WEKA.threshold.greenLow,'%02i'),'.mat'], 'wekaProbMaskGreen');
        wekaProbMaskLow_green = wekaProbMaskGreen;
        probStatusGreen = 1;   % noting whether or not green projections exist for this brain
        
        load str/green_addmask.mat
        green_addmask = addmask;
        for a = 1:size(green_addmask, 3) %Note: the probability masks had imfill applied to them in jh_WEKAprobtomask.m
            green_addmask(:, :, a) = imfill(green_addmask(:, :, a), 'holes');
        end
        
        load str/green_str_MaskedOutProjections.mat
        green_submask = colormask;
        for s = 1:size(green_submask, 3) 
            green_submask(:, :, s) = imfill(green_submask(:, :, s), 'holes');
        end
        
    else
        probStatusGreen = 0;
    end
    if isfield(WEKA.threshold, 'redHigh');   % loading the probability masks
        load (['str/wekaProbMaskRed','_Threshold', num2str(WEKA.threshold.redHigh,'%02i'), '.mat'], 'wekaProbMaskRed');
        wekaProbMaskHigh_red = wekaProbMaskRed;
        
        load (['str/wekaProbMaskRed','_Threshold', num2str(WEKA.threshold.redLow,'%02i'),'.mat'], 'wekaProbMaskRed');
        wekaProbMaskLow_red = wekaProbMaskRed;
        probStatusRed = 1;   % noting whether or not red projections exist for this brain
        
        load str/red_addmask.mat
        red_addmask = addmask;
        for a = 1:size(red_addmask, 3) %Note: the probability masks had imfill applied to them in jh_WEKAprobtomask.m
            red_addmask(:, :, a) = imfill(red_addmask(:, :, a), 'holes');
        end
        
        load str/red_str_MaskedOutProjections.mat
        red_submask = colormask;
        for s = 1:size(red_submask, 3) 
            red_submask(:, :, s) = imfill(red_submask(:, :, s), 'holes');
        end
    else
        probStatusRed = 0;
    end
    
    % Create the final masks for red
    % Determine if the channel exists
    % Go through each slice and determine if the high or low threshold is used
    % Take the probability mask, remove everything from submask, limit the mask to the borders of the striatum mask, and add everything from addmask
    if isfield(WEKA.threshold, 'redHigh');   % loading the probability masks
        for k = 1:size(strmask, 3)
            if probStatusRed == 1;
                if WEKA.thresholdBySlice.red(k+strstrt-1) == WEKA.threshold.redHigh;
                    redProjectionMask(:, :, k) = logical((wekaProbMaskHigh_red(:, :, k) + red_addmask(:, :, k)).*~red_submask(:, :, k).*strmask(:, :, k)); 
                elseif WEKA.thresholdBySlice.red(k+strstrt-1) == WEKA.threshold.redLow;
                    redProjectionMask(:, :, k) = logical((wekaProbMaskLow_red(:, :, k) + red_addmask(:, :, k)).*~red_submask(:, :, k).*strmask(:, :, k));
                else
                    display(['The red threshold set to use for section ', num2str(k), ' doesnt match either the high or low threshold chosen'])
                end
            end
        end
        save('str/redProjectionMask.mat','redProjectionMask')
    end
    
    %Now create the final masks for green
    if isfield(WEKA.threshold, 'greenHigh');   % loading the probability masks
        for k = 1:size(strmask, 3)
            if probStatusGreen == 1;
                if WEKA.thresholdBySlice.green(k+strstrt-1) == WEKA.threshold.greenHigh;
                    greenProjectionMask(:, :, k) = logical((wekaProbMaskHigh_green(:, :, k) + green_addmask(:, :, k)).*~green_submask(:, :, k).*strmask(:, :, k));
                elseif WEKA.thresholdBySlice.green(k+strstrt-1) == WEKA.threshold.greenLow;
                    greenProjectionMask(:, :, k) = logical((wekaProbMaskLow_green(:, :, k) + green_addmask(:, :, k)).*~green_submask(:, :, k).*strmask(:, :, k));
                else
                    display(['The green threshold set to use for section ', num2str(k), ' doesnt match either the high or low threshold chosen'])
                end
            end
        end
        save('str/greenProjectionMask.mat','greenProjectionMask')
    end
    display(['Finished brain ', num2str(brains(i))])
    clearvars -except i currentFolder brains
end


