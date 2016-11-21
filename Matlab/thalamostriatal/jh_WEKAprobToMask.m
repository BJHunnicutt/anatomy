load str/strdata.mat
maskColor= input('Is the color of the injection masked RED (1) or GREEN (2)?'); %type 1 or 2
if maskColor == 1
   maskNameColor = 'red'
else
   maskNameColor = 'green'
end

probUsed = input('What probability threshold do you want to use (0-1)?');
probUsedNum = num2str(probUsed*100);
numSec = (strnd-strstrt+1);


% % wekaProbFiles = dir(['str/WEKAoutput/', '*', 'probabilit','*', maskNameColor, '*']);
% % save('str/WEKAoutput/wekaProbFiles.mat','wekaProbFiles');

% % NumChnl = max(size(wekaFiles));
% 
% % for n = 1: NumChnl
    if maskColor == 1
        wekaProbMaskRed = false(2500,3500,numSec);
        wekaPMRCropped = false((lastR-firstR+1), (lastC-firstC+1), numSec);
        for k = 1:(strnd-strstrt+1);
            imgName = ['probabilities_maskedStr_', maskNameColor, '_', num2str(k+strstrt-1), '.tif'];
            imagek = imread(['str/WEKAoutput/',imgName]);
            mynewmask = imagek >= probUsed;
            filledimg = imfill(mynewmask, 'holes');
            wekaPMRCropped(:,:,k)= filledimg;
            wekaProbMaskRed(firstR:lastR, firstC:lastC, k) = wekaPMRCropped(:,:,k);
        end
        save(['str/wekaProbMaskRed','_Threshold',probUsedNum,'.mat'],'wekaProbMaskRed');
        display('red Saved');
    elseif maskColor == 2
        wekaProbMaskGreen = false(2500,3500,numSec);
        wekaPMGCropped = false((lastR-firstR+1), (lastC-firstC+1), numSec);
        for k = 1:(strnd-strstrt+1);
            imgName = ['probabilities_maskedStr_', maskNameColor, '_', num2str(k+strstrt-1), '.tif'];
            imagek = imread(['str/WEKAoutput/',imgName]);
            mynewmask = imagek >= probUsed;
            filledimg = imfill(mynewmask, 'holes');
            wekaPMGCropped(:,:,k)= filledimg;
            wekaProbMaskGreen(firstR:lastR, firstC:lastC, k) = wekaPMGCropped(:,:,k);
        end
        save(['str/wekaProbMaskGreen','_Threshold',probUsedNum,'.mat'],'wekaProbMaskGreen');
        display('green Saved');
    end
        
% % end
display('WEKA Probability Mask Complete!')