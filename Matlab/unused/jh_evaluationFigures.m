% Random Figures that are not in the paper as of yet:

1.  Originally from jh_consolidatingAIBSdatasets:

%% This will plot the ipsilateral and contralateral summed coronal, sagital and longitudinal view of each threshold (for an overview of the data)

% The striatum and whole brain colapsed to 2 dimensions
b1 = squeeze(sum(averageTemplate100um, 1))>500;
s1 = squeeze(sum((rotatedData.striatum3d.L.mask+rotatedData.striatum3d.R.mask), 1))>0.5;
b2 = squeeze(sum(averageTemplate100um, 2))>500;
s2 = squeeze(sum((rotatedData.striatum3d.L.mask+rotatedData.striatum3d.R.mask), 2))>0.5; 
b3 = squeeze(sum(averageTemplate100um, 3))>500;
s3 = squeeze(sum((rotatedData.striatum3d.L.mask+rotatedData.striatum3d.R.mask), 3))>0.5; 
%Outlines of Striatum & brain
so1 = h_getNucleusOutline(s1(:, :));
so2 = h_getNucleusOutline(s2(:, :));
so3 = h_getNucleusOutline(s3(:, :));
bo1 = h_getNucleusOutline(b1(:, :));
bo2 = h_getNucleusOutline(b2(:, :));
bo3 = h_getNucleusOutline(b3(:, :));

% set(gca,'YDir','reverse');

targetDir='/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/analyzed3';
cd(targetDir)

for g = 1:length(group)
    fig = figure;
    for i = 1:15
            subplot(5, 3, i)
            if i == 1
                imagesc(squeeze(sum(injGroup_data(g).mask1.ipsilateral, 1)+sum(injGroup_data(g).mask1.contralateral, 1)))
                title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(1))])
                set(fig, 'Position', [0 0 1000 1000])
                caxis([0 30])
                ylabel('M-L')
                xlabel('A-P')
                hold on
                for j = 1:length(so1)
                plot((so1{j}(:,2)), (so1{j}(:,1)), 'k-', 'linewidth',1)
                end
                for j = 1:length(bo1)
                plot((bo1{j}(:,2)), (bo1{j}(:,1)), 'k-', 'linewidth',1)
                end
                hold off
                axis image
            elseif i == 2
                imagesc(squeeze(sum(injGroup_data(g).mask1.ipsilateral, 2)+sum(injGroup_data(g).mask1.contralateral, 2)))
                title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(1))])
                set(fig, 'Position', [0 0 1000 1000])
                caxis([0 30])
                ylabel('D-V')
                xlabel('A-P')
                hold on
                for j = 1:length(so2)
                plot((so2{j}(:,2)), (so2{j}(:,1)), 'k-', 'linewidth',1)
                end
                for j = 1:length(bo2)
                plot((bo2{j}(:,2)), (bo2{j}(:,1)), 'k-', 'linewidth',1)
                end
                hold off
                axis image
            elseif i == 3
                imagesc(squeeze(sum(injGroup_data(g).mask1.ipsilateral, 3)+sum(injGroup_data(g).mask1.contralateral, 3)))
                title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(1))])
                set(fig, 'Position', [0 0 1000 1000])
                caxis([0 30])
                ylabel('D-V')
                xlabel('M-L')
                hold on
                for j = 1:length(so3)
                plot((so3{j}(:,2)), (so3{j}(:,1)), 'k-', 'linewidth',1)
                end
                for j = 1:length(bo2)
                plot((bo3{j}(:,2)), (bo3{j}(:,1)), 'k-', 'linewidth',1)
                end
                hold off
                axis image
            elseif i == 4
                imagesc(squeeze(sum(injGroup_data(g).mask2.ipsilateral, 1)+sum(injGroup_data(g).mask2.contralateral, 1)))
                title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(2))])
                set(fig, 'Position', [0 0 1000 1000])
                caxis([0 30])
                ylabel('M-L')
                xlabel('A-P')
                hold on
                for j = 1:length(so1)
                plot((so1{j}(:,2)), (so1{j}(:,1)), 'k-', 'linewidth',1)
                end
                for j = 1:length(bo1)
                plot((bo1{j}(:,2)), (bo1{j}(:,1)), 'k-', 'linewidth',1)
                end
                hold off
                axis image
            elseif i == 5
                imagesc(squeeze(sum(injGroup_data(g).mask2.ipsilateral, 2)+sum(injGroup_data(g).mask2.contralateral, 2)))
                title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(2))])
                set(fig, 'Position', [0 0 1000 1000])
                caxis([0 30])
                ylabel('D-V')
                xlabel('A-P')
                hold on
                for j = 1:length(so2)
                plot((so2{j}(:,2)), (so2{j}(:,1)), 'k-', 'linewidth',1)
                end
                for j = 1:length(bo2)
                plot((bo2{j}(:,2)), (bo2{j}(:,1)), 'k-', 'linewidth',1)
                end
                hold off
                axis image
            elseif i == 6
                imagesc(squeeze(sum(injGroup_data(g).mask2.ipsilateral, 3)+sum(injGroup_data(g).mask2.contralateral, 3)))
                title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(2))])
                set(fig, 'Position', [0 0 1000 1000])
                caxis([0 30])
                ylabel('D-V')
                xlabel('M-L')
                hold on
                for j = 1:length(so3)
                plot((so3{j}(:,2)), (so3{j}(:,1)), 'k-', 'linewidth',1)
                end
                for j = 1:length(bo2)
                plot((bo3{j}(:,2)), (bo3{j}(:,1)), 'k-', 'linewidth',1)
                end
                hold off
                axis image
            elseif i == 7
                imagesc(squeeze(sum(injGroup_data(g).mask3.ipsilateral, 1)+sum(injGroup_data(g).mask3.contralateral, 1)))
                title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(3))])
                set(fig, 'Position', [0 0 1000 1000])
                caxis([0 30])
                ylabel('M-L')
                xlabel('A-P')
                hold on
                for j = 1:length(so1)
                plot((so1{j}(:,2)), (so1{j}(:,1)), 'k-', 'linewidth',1)
                end
                for j = 1:length(bo1)
                plot((bo1{j}(:,2)), (bo1{j}(:,1)), 'k-', 'linewidth',1)
                end
                hold off
                axis image
            elseif i == 8
                imagesc(squeeze(sum(injGroup_data(g).mask3.ipsilateral, 2)+sum(injGroup_data(g).mask3.contralateral, 2)))
                title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(3))])
                set(fig, 'Position', [0 0 1000 1000])
                caxis([0 30])
                ylabel('D-V')
                xlabel('A-P')
                hold on
                for j = 1:length(so2)
                plot((so2{j}(:,2)), (so2{j}(:,1)), 'k-', 'linewidth',1)
                end
                for j = 1:length(bo2)
                plot((bo2{j}(:,2)), (bo2{j}(:,1)), 'k-', 'linewidth',1)
                end
                hold off
                axis image
            elseif i == 9
                imagesc(squeeze(sum(injGroup_data(g).mask3.ipsilateral, 3)+sum(injGroup_data(g).mask3.contralateral, 3)))
                title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(3))])
                set(fig, 'Position', [0 0 1000 1000])
                caxis([0 30])
                ylabel('D-V')
                xlabel('M-L')
                hold on
                for j = 1:length(so3)
                plot((so3{j}(:,2)), (so3{j}(:,1)), 'k-', 'linewidth',1)
                end
                for j = 1:length(bo2)
                plot((bo3{j}(:,2)), (bo3{j}(:,1)), 'k-', 'linewidth',1)
                end
                hold off
                axis image
            elseif i == 10
                imagesc(squeeze(sum(injGroup_data(g).mask4.ipsilateral, 1)+sum(injGroup_data(g).mask4.contralateral, 1)))
                title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(4))])
                set(fig, 'Position', [0 0 1000 1000])
                caxis([0 30])
                ylabel('M-L')
                xlabel('A-P')
                hold on
                for j = 1:length(so1)
                plot((so1{j}(:,2)), (so1{j}(:,1)), 'k-', 'linewidth',1)
                end
                for j = 1:length(bo1)
                plot((bo1{j}(:,2)), (bo1{j}(:,1)), 'k-', 'linewidth',1)
                end
                hold off
                axis image
            elseif i == 11
                imagesc(squeeze(sum(injGroup_data(g).mask4.ipsilateral, 2)+sum(injGroup_data(g).mask4.contralateral, 2)))
                title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(4))])
                set(fig, 'Position', [0 0 1000 1000])
                caxis([0 30])
                ylabel('D-V')
                xlabel('A-P')
                hold on
                for j = 1:length(so2)
                plot((so2{j}(:,2)), (so2{j}(:,1)), 'k-', 'linewidth',1)
                end
                for j = 1:length(bo2)
                plot((bo2{j}(:,2)), (bo2{j}(:,1)), 'k-', 'linewidth',1)
                end
                hold off
                axis image
            elseif i == 12
                imagesc(squeeze(sum(injGroup_data(g).mask4.ipsilateral, 3)+sum(injGroup_data(g).mask4.contralateral, 3)))
                title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(4))])
                set(fig, 'Position', [0 0 1000 1000])
                caxis([0 30])
                ylabel('D-V')
                xlabel('M-L')
                hold on
                for j = 1:length(so3)
                plot((so3{j}(:,2)), (so3{j}(:,1)), 'k-', 'linewidth',1)
                end
                for j = 1:length(bo2)
                plot((bo3{j}(:,2)), (bo3{j}(:,1)), 'k-', 'linewidth',1)
                end
                hold off
                axis image
            elseif i == 13
                imagesc(squeeze(sum(injGroup_data(g).mask5.ipsilateral, 1)+sum(injGroup_data(g).mask5.contralateral, 1)))
                title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(5))])
                set(fig, 'Position', [0 0 1000 1000])
                caxis([0 30])
                ylabel('M-L')
                xlabel('A-P')
                hold on
                for j = 1:length(so1)
                plot((so1{j}(:,2)), (so1{j}(:,1)), 'k-', 'linewidth',1)
                end
                for j = 1:length(bo1)
                plot((bo1{j}(:,2)), (bo1{j}(:,1)), 'k-', 'linewidth',1)
                end
                hold off
                axis image
            elseif i == 14
                imagesc(squeeze(sum(injGroup_data(g).mask5.ipsilateral, 2)+sum(injGroup_data(g).mask5.contralateral, 2)))
                title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(5))])
                set(fig, 'Position', [0 0 1000 1000])
                caxis([0 30])
                ylabel('D-V')
                xlabel('A-P')
                hold on
                for j = 1:length(so2)
                plot((so2{j}(:,2)), (so2{j}(:,1)), 'k-', 'linewidth',1)
                end
                for j = 1:length(bo2)
                plot((bo2{j}(:,2)), (bo2{j}(:,1)), 'k-', 'linewidth',1)
                end
                hold off
                axis image
            elseif i == 15
                imagesc(squeeze(sum(injGroup_data(g).mask5.ipsilateral, 3)+sum(injGroup_data(g).mask5.contralateral, 3)))
                title([injGroup_data(g).cortical_group, ' Threshold = ', num2str(injGroup_data(g).thresholds(5))])
                set(fig, 'Position', [0 0 1000 1000])
                caxis([0 30])
                ylabel('D-V')
                xlabel('M-L')
                hold on
                for j = 1:length(so3)
                plot((so3{j}(:,2)), (so3{j}(:,1)), 'k-', 'linewidth',1)
                end
                for j = 1:length(bo2)
                plot((bo3{j}(:,2)), (bo3{j}(:,1)), 'k-', 'linewidth',1)
                end
                hold off
                axis image
            end 
            set(gca, 'FontSize', 6);
    end
    saveas(fig, ['corticalProjections/collapsedThresholds/groupThresholdTest_',injGroup_data(g).cortical_group,'.fig'], 'fig');
    print(fig, ['corticalProjections/collapsedThresholds/groupThresholdTest_',injGroup_data(g).cortical_group,'.eps'], '-depsc2');
    close(fig)
end



%%