function c = h_imagesc(varargin)

c = imagesc(varargin{:});
axis image;
set(gca, 'unit','normalized','position',[0 0 1 1], 'YTickLabel', '', 'YTick',[],'XTickLabel', '', 'XTick',[]);
colormap(gray);