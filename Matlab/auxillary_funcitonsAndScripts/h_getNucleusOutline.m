function outline = h_getNucleusOutline(nucleusMask)

labeledBW = bwlabel(nucleusMask);

if sum(labeledBW(:))>0
    for i = 1:max(labeledBW(:))
        BW = labeledBW == i;
        [row, col] = find(BW, 1);
        try
            outline{i} = bwtraceboundary(BW, [row, col], 'E');
        catch
            outline{i} = bwtraceboundary(BW, [row, col], 'W');
        end
    end
else
    outline = {};
end

