function varargout = jh_createFinalProjMasks_fixaddMaskMistake(brains)

% JH_CREATEFINALPROJMASKS will create the final projection masks (i.e. the mask that 
% defines where in the striatum that red and green projections are located).
% 
% INPUT: a 
%
% This is cleaning up the redProjectionMask and greenProjectionMask
% created with jh_createFinalProjMasks. I accidently added the addMask
% after i limited the projection mask to the size of strmask


currentFolder = pwd;
% % brains = [076001, 076002, 076003, 076004, 076005, 076006, 076007, 076008, 076009, 076010];
 %[076001, 076002, 076003, 076004, 076005, 076006, 076007, 076008, 076009, 076010, 076012, 076013, 076014, 076015, 076016, 076018, 076019, 076020, 076024, 076025, 076027, 076028, 076029];

% % % Final list of brains we're using (68):
brains = [060536, 075019, 075032, 075034, 075036, 075074, 075075, 075077, 075078, 075083, 075086, 075106, 075107, 075108, 075109, 075110, 075111, 075112, 075115, 075117, 075118, 075120, 075121, 075122, 075123, 075124, 075126, 075127, 075128, 075129, 075130, 075131, 075132, 075133, 075087, 075912, 075914, 075915, 075916, 075917, 075918, 075919, 075920, 075924, 075925, 076001, 076002, 076003, 076004, 076005, 076006, 076007, 076008, 076009, 076010, 076012, 076013, 076014, 076015, 076016, 076018, 076019, 076020, 076024, 076025, 076027, 076028, 076029];

 
 
for i = 1:length(brains)
    b = brains(i);
    cd([currentFolder, '/', num2str(brains(i), '%06i')])
    load masteralign2
    load strdata.mat
    load strmask.mat
    
    
    
    % Load the red and green projection masks that need fixed
    if isfield(WEKA.threshold, 'greenHigh');   % loading the probability masks
        load greenProjectionMask.mat
        greenProjectionMask = logical(greenProjectionMask.*strmask); 
        save('greenProjectionMask.mat','greenProjectionMask')
    else
        probStatusGreen = 0;
    end
    if isfield(WEKA.threshold, 'redHigh');   % loading the probability masks
        load redProjectionMask.mat
        redProjectionMask = logical(redProjectionMask.*strmask); 
        save('redProjectionMask.mat','redProjectionMask')
    else
        probStatusRed = 0;
    end
    
    display(['Finished brain ', num2str(brains(i))])
    clearvars -except i currentFolder brains
end


