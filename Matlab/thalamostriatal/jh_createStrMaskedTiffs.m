%%%% This is made to create tiffs cropped to the maximum size of all
%%%% striatums, and separate the channels (plus merge if wanted -bottom)


load masteralign.mat;
load str/strmask.mat;
load str/strdata.mat;
mkdir str/maskedTiffs/green/training
mkdir str/maskedTiffs/red/training
% mkdir str/maskedTiffs/RGB/training     %%%%% Only if you want RGB %%%%%%%
mkdir str/WEKAoutput

        %maskedStr_tiff= zeros(2500,3500,length(strmask(2, 2, :)),'uint16');

acol = squeeze(sum(sum(strmask,1),3));  %This sums all of the columns in all slices
firstC = find(acol>0, 1,'first');       %This gives the first column with a value (meaning a pixel that is masked)
lastC = find(acol>0, 1,'last');         %This gives the first column with a value

brow = squeeze(sum(sum(strmask,2),3));  %This sums all rows in all slices
firstR = find(brow>0, 1,'first');       %This gives the first row with a value
lastR = find(brow>0, 1,'last');         %This gives the last row with a value
save('str/strdata','firstC','lastC','firstR','lastR','-append'); %This saves the values the tiffs will be cropped at
                                                                 %***** '-append' is important so that you dont overwrite any other variables


for c = 1:2
    if c == 1
       chnl = 'red'
        for k= strstrt:strnd
            img = imread(['tiffs/',masteralign(k).name]); %makes the image an array of values
            img2 = img(:,:,c);
            img2Crop = img2(firstR:lastR, firstC:lastC, :); %This crops the tiffs to the maximum size of any mask 

            mask = uint16(strmask(:,:,k-strstrt+1));
            maskCrop = mask(firstR:lastR, firstC:lastC, :); %This crops the masks to the maximum size of any mask 

            ImgK = maskCrop.*img2Crop;  % the mask times the tiff converted with imread
            imwrite(ImgK, ['str/maskedTiffs/red/maskedStr','_', chnl,'_',num2str(k),'.tif']);
            % display ('.')
        end
    else chnl = 'green'
        for k= strstrt:strnd
            img = imread(['tiffs/',masteralign(k).name]); %makes the image an array of values
            img2 = img(:,:,c);
            img2Crop = img2(firstR:lastR, firstC:lastC, :); %This crops the tiffs to the maximum size of any mask 

            mask = uint16(strmask(:,:,k-strstrt+1));
            maskCrop = mask(firstR:lastR, firstC:lastC, :); %This crops the masks to the maximum size of any mask 

            ImgK = maskCrop.*img2Crop;  % the mask times the tiff converted with imread
            imwrite(ImgK, ['str/maskedTiffs/green/maskedStr','_', chnl,'_',num2str(k),'.tif']);
            % display ('.')
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% The rest is to create another set of tiffs in full color %%%%%%%%%%%%

%  for k= strstrt:strnd
%     img = imread(['tiffs/',masteralign(k).name]); %makes the image an array of values
%     img2 = img(:,:,:);
%     img2Crop = img2(firstR:lastR, firstC:lastC, :); %This crops the tiffs to the maximum size of any mask 
% 
%     mask = uint16(strmask(:,:,k-strstrt+1));
%     maskCrop = mask(firstR:lastR, firstC:lastC, :); %This crops the masks to the maximum size of any mask 
%     for allcolors = 1:3
%         ImgK(:, :, allcolors) = maskCrop.*img2Crop(:, :, allcolors);  % the mask times the tiff converted with imread
%     end
%     imwrite(ImgK, ['str/maskedTiffs/RGB/maskedStr','_', 'RGB','_',num2str(k),'.tif']);
% end


