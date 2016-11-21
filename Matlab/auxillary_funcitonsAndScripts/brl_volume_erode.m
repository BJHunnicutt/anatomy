function out = brl_volume_erode(inmask, radius)


% radius is a 3-component array with radii for [row, column, slice]
% directions, ASSUMES EQUAL ROW AND COLUMN radii


%CRITICALLY, for the thalamus data, slice dimension of voxels is bigger
%than row,column.  this means that 150um radius is 3 slices in z, but closer to 5 pixels in row,column so
%merging the 3 eroded masks via AND will work just fine.  

strel1 = strel('disk', radius(1),0);
mask1 = imerode(inmask,strel1 );


strel2 = strel('disk', radius(3),0);

for i = 1:size(inmask,1)
    
    islice = squeeze(inmask(i,:,:));
    mask2(i,:,:) = imerode(islice, strel2);
end
for i = 1:size(inmask,2)
    
    islice = squeeze(inmask(:,i,:));
    mask3(:,i,:) = imerode(islice, strel2);
end

out = mask1 & mask