% It expects masteralign to have file names. Best to run after
% genmasteralign3. 
% Each section image appears, User must select the midpoints. to place on
% the midline of each 2500x3500 image. 
% next step is masteralign_execute

% ** This is modified by Jeannie to make more rotation points to be used
%    for striatum rotation alignment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
if exist('str/strdata.mat','file')
load str/strdata.mat
end
load masteralign
start= input ('which section would you like to START? '); %%%%%%%%%%%%% These are optional. If you just press return they will default to thalstrt and thalnd. 
finish= input('At which section would you like to END? '); 
if isempty(start)
    start= strstrt; 
end
if isempty(finish)
    finish= strnd; 
end
for k= start:finish
    img= imread(['tiffs/',masteralign(k).name]);
    imshow(img*6)
    stx= 870;
    sty= 800;
    xlim([stx stx+1750])
    ylim([sty sty+1500])
    text(stx+100,sty+100,num2str(k), 'Color','Red')
    pts= ginput(2);
    masteralign(k).strPts= pts;
end
save('masteralign','masteralign')
close all