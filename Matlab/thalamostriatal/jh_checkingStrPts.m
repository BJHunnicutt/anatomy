targetDir='/Volumes/WD03/DATA';
cd(targetDir)
d=dir; 

a = 1;
for j = 1:length(d)
    if d(j).name(1) == '0'
        d2(a)=d(j);
        a = a+1;
    end
end
d = d2';


for b = 1:length(d)
    cd([targetDir, '/', d(b).name]);
    if exist('str/strPts.mat')
        load str/strPts.mat
        load str/strmask.mat

        %First you have to turn it into a 4-d array
        test = [];
        for i = 1:size(strmask, 3)
            test(:, :, 1, i) = strmask(:, :, i);
        end

        % s = size(strmask, 3);
%         fig = figure;
        montage(test, 'Size', [10 9]);

        hold on

        for i = 1:size(strmask, 3)
            x = []; x2 = []; y = []; y2 = []; xL = []; x2L = []; yL = []; y2L = []; p = []; p2 = [];
            if sum(i == 1:10) > 0;
                x = strPts(i).strPtsR(:,1);
                y = strPts(i).strPtsR(:,2);
                plot(x+(size(strmask, 2)*(i-1)), y, 'ro', 'MarkerSize', 10); 
                p = polyfit(y, x, 1);
                y2 = [0.5 size(strmask,1)+.5];
                x2 = polyval(p, y2);
                plot(x2+(size(strmask, 2))*(i-1), y2, 'r:', 'linewidth', 2);

                xL = strPts(i).strPtsL(:,1);
                yL = strPts(i).strPtsL(:,2);
                plot(xL+(size(strmask, 2)*(i-1)), yL, 'go', 'MarkerSize', 10); 
                p2 = polyfit(y, x, 1);
                y2L = [0.5 size(strmask,1)+.5];
                x2L = polyval(p2, y2L);
                plot(x2L+(size(strmask, 2))*(i-1), y2L, 'g:', 'linewidth', 2);
            elseif sum(i == 11:20) > 0;
                x = strPts(i).strPtsR(:,1);
                y = strPts(i).strPtsR(:,2);
                plot(x+(size(strmask, 2)*(i-11)), y+(size(strmask, 1)), 'ro', 'MarkerSize', 10); 
                p = polyfit(y, x, 1);
                y2 = [0.5 size(strmask,1)+.5];
                x2 = polyval(p, y2);
                plot(x2+(size(strmask, 2))*(i-11), y2+(size(strmask, 1)), 'r:', 'linewidth', 2);

                xL = strPts(i).strPtsL(:,1);
                yL = strPts(i).strPtsL(:,2);
                hold on, plot(xL+(size(strmask, 2)*(i-11)), yL+(size(strmask, 1)), 'go', 'MarkerSize', 10); 
                p2 = polyfit(y, x, 1);
                y2L = [0.5 size(strmask,1)+.5];
                x2L = polyval(p2, y2L);
                plot(x2L+(size(strmask, 2))*(i-11), y2L+(size(strmask, 1)), 'g:', 'linewidth', 2);

            elseif sum(i == 21:30) > 0;
                x = strPts(i).strPtsR(:,1);
                y = strPts(i).strPtsR(:,2);
                plot(x+(size(strmask, 2)*(i-21)), y+(size(strmask, 1))*2, 'ro', 'MarkerSize', 10); 
                p = polyfit(y, x, 1);
                y2 = [0.5 size(strmask,1)+.5];
                x2 = polyval(p, y2);
                plot(x2+(size(strmask, 2))*(i-21), y2+(size(strmask, 1))*2, 'r:', 'linewidth', 2);

                xL = strPts(i).strPtsL(:,1);
                yL = strPts(i).strPtsL(:,2);
                plot(xL+(size(strmask, 2)*(i-21)), yL+(size(strmask, 1))*2, 'go', 'MarkerSize', 10); 
                p2 = polyfit(y, x, 1);
                y2L = [0.5 size(strmask,1)+.5];
                x2L = polyval(p2, y2L);
                plot(x2L+(size(strmask, 2))*(i-21), y2L+(size(strmask, 1))*2, 'g:', 'linewidth', 2);
            elseif sum(i == 31:40) > 0;
                x = strPts(i).strPtsR(:,1);
                y = strPts(i).strPtsR(:,2);
                plot(x+(size(strmask, 2)*(i-31)), y+(size(strmask, 1))*3, 'ro', 'MarkerSize', 10); 
                p = polyfit(y, x, 1);
                y2 = [0.5 size(strmask,1)+.5];
                x2 = polyval(p, y2);
                plot(x2+(size(strmask, 2))*(i-31), y2+(size(strmask, 1))*3, 'r:', 'linewidth', 2);

                xL = strPts(i).strPtsL(:,1);
                yL = strPts(i).strPtsL(:,2);
                plot(xL+(size(strmask, 2)*(i-31)), yL+(size(strmask, 1))*3, 'go', 'MarkerSize', 10); 
                p2 = polyfit(y, x, 1);
                y2L = [0.5 size(strmask,1)+.5];
                x2L = polyval(p2, y2L);
                plot(x2L+(size(strmask, 2))*(i-31), y2L+(size(strmask, 1))*3, 'g:', 'linewidth', 2);
            elseif sum(i == 41:50) > 0;
                x = strPts(i).strPtsR(:,1);
                y = strPts(i).strPtsR(:,2);
                plot(x+(size(strmask, 2)*(i-41)), y+(size(strmask, 1))*4, 'ro', 'MarkerSize', 10); 
                p = polyfit(y, x, 1);
                y2 = [0.5 size(strmask,1)+.5];
                x2 = polyval(p, y2);
                plot(x2+(size(strmask, 2))*(i-41), y2+(size(strmask, 1))*4, 'r:', 'linewidth', 2);

                xL = strPts(i).strPtsL(:,1);
                yL = strPts(i).strPtsL(:,2);
                plot(xL+(size(strmask, 2)*(i-41)), yL+(size(strmask, 1))*4, 'go', 'MarkerSize', 10); 
                p2 = polyfit(y, x, 1);
                y2L = [0.5 size(strmask,1)+.5];
                x2L = polyval(p2, y2L);
                plot(x2L+(size(strmask, 2))*(i-41), y2L+(size(strmask, 1))*4, 'g:', 'linewidth', 2);
            elseif sum(i == 51:60) > 0;
                x = strPts(i).strPtsR(:,1);
                y = strPts(i).strPtsR(:,2);
                plot(x+(size(strmask, 2)*(i-51)), y+(size(strmask, 1))*5, 'ro', 'MarkerSize', 10); 
                p = polyfit(y, x, 1);
                y2 = [0.5 size(strmask,1)+.5];
                x2 = polyval(p, y2);
                plot(x2+(size(strmask, 2))*(i-51), y2+(size(strmask, 1))*5, 'r:', 'linewidth', 2);

                xL = strPts(i).strPtsL(:,1);
                yL = strPts(i).strPtsL(:,2);
                plot(xL+(size(strmask, 2)*(i-51)), yL+(size(strmask, 1))*5, 'go', 'MarkerSize', 10); 
                p2 = polyfit(y, x, 1);
                y2L = [0.5 size(strmask,1)+.5];
                x2L = polyval(p2, y2L);
                plot(x2L+(size(strmask, 2))*(i-51), y2L+(size(strmask, 1))*5, 'g:', 'linewidth', 2);
            elseif sum(i == 61:70) > 0;
                x = strPts(i).strPtsR(:,1);
                y = strPts(i).strPtsR(:,2);
                plot(x+(size(strmask, 2)*(i-61)), y+(size(strmask, 1))*6, 'ro', 'MarkerSize', 10); 
                p = polyfit(y, x, 1);
                y2 = [0.5 size(strmask,1)+.5];
                x2 = polyval(p, y2);
                plot(x2+(size(strmask, 2))*(i-61), y2+(size(strmask, 1))*6, 'r:', 'linewidth', 2);

                xL = strPts(i).strPtsL(:,1);
                yL = strPts(i).strPtsL(:,2);
                plot(xL+(size(strmask, 2)*(i-61)), yL+(size(strmask, 1))*6, 'go', 'MarkerSize', 10); 
                p2 = polyfit(y, x, 1);
                y2L = [0.5 size(strmask,1)+.5];
                x2L = polyval(p2, y2L);
                plot(x2L+(size(strmask, 2))*(i-61), y2L+(size(strmask, 1))*6, 'g:', 'linewidth', 2);
            elseif sum(i == 71:80) > 0;
                x = strPts(i).strPtsR(:,1);
                y = strPts(i).strPtsR(:,2);
                plot(x+(size(strmask, 2)*(i-71)), y+(size(strmask, 1))*7, 'ro', 'MarkerSize', 10); 
                p = polyfit(y, x, 1);
                y2 = [0.5 size(strmask,1)+.5];
                x2 = polyval(p, y2);
                plot(x2+(size(strmask, 2))*(i-71), y2+(size(strmask, 1))*7, 'r:', 'linewidth', 2);

                xL = strPts(i).strPtsL(:,1);
                yL = strPts(i).strPtsL(:,2);
                plot(xL+(size(strmask, 2)*(i-71)), yL+(size(strmask, 1))*7, 'go', 'MarkerSize', 10); 
                p2 = polyfit(y, x, 1);
                y2L = [0.5 size(strmask,1)+.5];
                x2L = polyval(p2, y2L);
                plot(x2L+(size(strmask, 2))*(i-71), y2L+(size(strmask, 1))*7, 'g:', 'linewidth', 2);
            elseif sum(i == 81:90) > 0;
                x = strPts(i).strPtsR(:,1);
                y = strPts(i).strPtsR(:,2);
                plot(x+(size(strmask, 2)*(i-81)), y+(size(strmask, 1))*8, 'ro', 'MarkerSize', 10); 
                p = polyfit(y, x, 1);
                y2 = [0.5 size(strmask,1)+.5];
                x2 = polyval(p, y2);
                plot(x2+(size(strmask, 2))*(i-81), y2+(size(strmask, 1))*8, 'r:', 'linewidth', 2);

                xL = strPts(i).strPtsL(:,1);
                yL = strPts(i).strPtsL(:,2);
                plot(xL+(size(strmask, 2)*(i-81)), yL+(size(strmask, 1))*8, 'go', 'MarkerSize', 10); 
                p2 = polyfit(y, x, 1);
                y2L = [0.5 size(strmask,1)+.5];
                x2L = polyval(p2, y2L);
                plot(x2L+(size(strmask, 2))*(i-81), y2L+(size(strmask, 1))*8, 'g:', 'linewidth', 2);
            elseif sum(i == 91:100) > 0;
                x = strPts(i).strPtsR(:,1);
                y = strPts(i).strPtsR(:,2);
                plot(x+(size(strmask, 2)*(i-91)), y+(size(strmask, 1))*9, 'ro', 'MarkerSize', 10); 
                p = polyfit(y, x, 1);
                y2 = [0.5 size(strmask,1)+.5];
                x2 = polyval(p, y2);
                plot(x2+(size(strmask, 2))*(i-91), y2+(size(strmask, 1))*9, 'r:', 'linewidth', 2);

                xL = strPts(i).strPtsL(:,1);
                yL = strPts(i).strPtsL(:,2);
                plot(xL+(size(strmask, 2)*(i-91)), yL+(size(strmask, 1))*9, 'go', 'MarkerSize', 10); 
                p2 = polyfit(y, x, 1);
                y2L = [0.5 size(strmask,1)+.5];
                x2L = polyval(p2, y2L);
                plot(x2L+(size(strmask, 2))*(i-91), y2L+(size(strmask, 1))*9, 'g:', 'linewidth', 2);

            end
        end

%         saveas(gcf, ['/Users/jeaninehunnicutt/Desktop/montageOfStrPts/', num2str(d(b).name), '_strPtsMontage.fig'], 'fig', '-v7.3');
%         print(gcf, ['/Users/jeaninehunnicutt/Desktop/montageOfStrPts/', num2str(d(b).name), '_strPtsMontage.eps'], '-depsc2');
       saveas(gcf, ['/Users/jeaninehunnicutt/Desktop/montageOfStrPts/', num2str(d(b).name), '_strPtsMontage.tiff'], 'tiff');
       close(gcf)
    end
end