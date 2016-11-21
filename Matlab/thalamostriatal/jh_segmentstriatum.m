
load masteralign
mkdir('str')

if ~exist('str/strdata.mat','file')
    strstrtL= input('what is the str START section number for the LEFT? ');
    strndL= input ('what is the str END section number for the LEFT? ');
    strstrtR= input('what is the str START section number for the RIGHT? ');
    strndR= input ('what is the str END section number for the RIGHT? ');
    strstrt= min([strstrtL, strstrtR]); 
    strnd= max([strndL, strndR]); 
    save('str/strdata','strstrt','strnd','strstrtL','strndL','strstrtR','strndR')
%     strmask(2500,3500,strnd-strstrt+1)= false; 
%     save('str/strmask.mat','strmask')
else
    load ('str/strdata.mat')
end

if exist('str/strmask.mat','file')
    load ('str/strmask.mat')
else
    strmask(2500,3500,strnd-strstrt+1)= false; 
    save('str/strmask.mat','strmask')
    strmask= false(2500,3500,strnd-strstrt+1);
end

k= input('which striatum section do you wish to begin with? ');
if isempty (k)
    k= strstrt;
end

img= imread(['tiffs/',masteralign(k).name]);
im=imshow(img);
imp= get(im,'Parent');
impp= get(imp,'Parent');
h= text(200,300,masteralign(k).name,'Color','White');

while k<=strnd
    img= imread(['tiffs/',masteralign(k).name]);
    set(h, 'String',[masteralign(k).name(1:9),'-',masteralign(k).name(11:end)])

    clrboxx1=2300;              % bottom left is clear
    clrboxx2=2500;
    clrboxy1=1;
    clrboxy2=200;
    img(clrboxx1:clrboxx2,clrboxy1:clrboxy2,1)=2^16;
    text(clrboxy1+50,clrboxx1+100, 'clear','Color','White')
    accboxx1=2300;              % bottom right is accept.
    accboxx2=2500;
    accboxy1=3300;
    accboxy2=3500;
    img(accboxx1:accboxx2,accboxy1:accboxy2,2)=2^16;
    text(accboxy1+50,accboxx1+100, 'accept','Color','Black')
    addboxx1=1;                 % top right is add.
    addboxx2=200;
    addboxy1=3300;
    addboxy2=3500;
    img(addboxx1:addboxx2,addboxy1:addboxy2,3)=2^16;
    text(addboxy1+50,addboxx1+100, 'add','Color','White')
    subboxx1=1;                 % top left is subtract.
    subboxx2=200;
    subboxy1=1;
    subboxy2=200;
    img(subboxx1:subboxx2,subboxy1:subboxy2,1)=2^16;
    text(subboxy1+50,subboxx1+100, 'subtract','Color','White')

    keepup=1;
    illum=4000;
  
    
    bimg= img;
        bimg(:,:,3)= bimg(:,:,3)+ uint16(strmask(:,:,k-strstrt+1))*illum;
        set(im,'CData',bimg*8)   % change this if you are unhappy with the illumination level !!! but also change next line to be lower.
        illum=2000;  % this sets the illumination level of the masked area.. so change it if you don't like it.

roi1= imfreehand(gca);
            roiapi=iptgetapi(roi1);
            roipoints= roiapi.getPosition();
            selection= roipoly(img, roipoints(:,1), roipoints(:,2));
            strmask(:,:,k-strstrt+1)= strmask(:,:,k-strstrt+1)+selection;
            delete(roi1)
    
 
    while keepup==1
        bimg= img;
        bimg(:,:,3)= bimg(:,:,3)+ uint16(strmask(:,:,k-strstrt+1))*illum;
        set(im,'CData',bimg*8)   % change this if you are unhappy with the illumination level !!! but also change next line to be lower.
        illum=2000;  % this sets the illumination level of the masked area.. so change it if you don't like it.
        pt= ginput(1);
        if (pt(2)>clrboxx1 && pt(2)<clrboxx2 && pt(1)>clrboxy1 && pt(1)<clrboxy2)      %clear
            strmask(:,:,k-strstrt+1)= false([2500,3500]);
        elseif (pt(2)>accboxx1 && pt(2)<accboxx2 && pt(1)>accboxy1 && pt(1)<accboxy2)  % accept and next
            k=k+1;
            keepup=0;
        elseif (pt(2)>subboxx1 && pt(2)<subboxx2 && pt(1)>subboxy1 && pt(1)<subboxy2)   % subtract and recycle
            roi1= imfreehand(gca);
            roiapi=iptgetapi(roi1);
            roipoints= roiapi.getPosition();
            selection= roipoly(img, roipoints(:,1), roipoints(:,2));
            strmask(:,:,k-strstrt+1)= strmask(:,:,k-strstrt+1).*~selection;
            delete(roi1)
        elseif (pt(2)>addboxx1 && pt(2)<addboxx2 && pt(1)>addboxy1 && pt(1)<addboxy2)   % add on and recycle
            roi1= imfreehand(gca);
            roiapi=iptgetapi(roi1);
            roipoints= roiapi.getPosition();
            selection= roipoly(img, roipoints(:,1), roipoints(:,2));
            strmask(:,:,k-strstrt+1)= strmask(:,:,k-strstrt+1)+selection;
            delete(roi1)
        end
    end
end
save('str/strmask.mat','strmask')
display('Str Mask Saved!')
close all