function reproduce_figures(figureNumbers)
% Redraw selected figures from the precomputed plot data in data/.
%   reproduce_figures()          redraws all figures in this repository.
%   reproduce_figures([27, 28])  redraws the two probability panels.

    byCase = { [1:9, 27, 29], [10:18, 28, 30] };
    available = [1:18, 27:30];
    if nargin == 0
        figureNumbers = available;
    end
    validateattributes(figureNumbers, {'numeric'}, {'vector', 'integer', 'nonempty'});
    if ~all(ismember(figureNumbers, available))
        error('ReproduceFigures:FigureNumber', 'Choose figure numbers from 1–18 and 27–30.');
    end

    root = fileparts(mfilename('fullpath'));
    dataFolder = fullfile(root, 'data');
    plotFolder = fullfile(root, 'reproduced_figures');
    figureNumbers = unique(figureNumbers(:).', 'stable');
    dataFiles = cell(1, 2);
    for iCase = 1:2
        if any(ismember(figureNumbers, byCase{iCase}))
            dataFiles{iCase} = fullfile(dataFolder, sprintf('case%d_plot_data.mat', iCase));
            if ~isfile(dataFiles{iCase})
                error('ReproduceFigures:MissingData', 'Missing plot data file: %s', dataFiles{iCase});
            end
        end
    end
    if ~isfolder(plotFolder)
        mkdir(plotFolder);
    end

    for iCase = 1:2
        if isempty(dataFiles{iCase})
            continue;
        end
        bundle = load(dataFiles{iCase}, 'data');
        data = bundle.data;
        ids = cellfun(@(spec) spec.id, data.figures);
        requested = figureNumbers(ismember(figureNumbers, byCase{iCase}));
        for id = requested
            index = find(ids == id);
            if numel(index) ~= 1
                error('ReproduceFigures:MissingFigure', 'Expected one entry for Figure %02d.', id);
            end
            draw_figure(data.figures{index}, data.paths, plotFolder);
        end
    end
    fprintf('Wrote figures to %s\n', plotFolder);
end

function draw_figure(spec, paths, plotFolder)
    fig = figure('Visible', 'off', 'Color', spec.background, ...
        'Units', 'inches', 'Position', [1, 1, spec.sizeInches]);
    figureCleanup = onCleanup(@() delete(fig));

    axesHandles = gobjects(1, numel(spec.panels));
    twoPanels = numel(spec.panels) == 2;
    if twoPanels
        layout = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
        set(layout.Title, spec.title);
        axesHandles(1) = nexttile(layout, 1);
        axesHandles(2) = nexttile(layout, 2);
    else
        axesHandles(1) = axes(fig);
    end

    handles = cell(size(axesHandles));
    for k = 1:numel(axesHandles)
        handles{k} = draw_panel(axesHandles(k), spec.panels{k}, paths);
    end

    lgd = legend(axesHandles(1), handles{1}(spec.legend.items), ...
        spec.legend.labels, 'AutoUpdate', 'off');
    style = spec.legend.style;
    if twoPanels
        style = rmfield(style, 'Location');
    end
    set(lgd, style);
    if twoPanels
        lgd.Layout.Tile = 'south';
    end
    exportgraphics(fig, fullfile(plotFolder, [spec.name '.png']), ...
        'Resolution', 600, 'ContentType', 'image');
end

function handles = draw_panel(ax, panel, paths)
    items = panel.items;
    handles = gobjects(numel(items), 1);
    hold(ax, 'on');
    set(ax, 'XScale', panel.xScale, 'YScale', panel.yScale, ...
        'XLim', panel.xLim, 'YLim', panel.yLim);

    bars = find(strcmp({items.kind}, 'bar'));
    if ~isempty(bars)
        barItems = items(bars);
        barX = barItems(1).x;
        if ~all(arrayfun(@(item) isequal(item.x, barX), barItems))
            error('ReproduceFigures:BarCoordinates', 'Bar series have different x coordinates.');
        end
        handles(bars) = bar(ax, barX, [barItems.y], barItems(1).style.BarLayout);
    end

    for k = 1:numel(items)
        item = items(k);
        x = item.x;
        y = item.y;
        if item.pathId > 0
            x = paths{item.pathId, 1};
            y = paths{item.pathId, 2};
        end
        switch item.kind
            case 'line'
                handles(k) = line('Parent', ax, 'XData', x, 'YData', y);
            case 'patch'
                handles(k) = patch('Parent', ax, 'XData', x, 'YData', y);
            case 'constantline'
                handles(k) = xline(ax, x);
            case 'text'
                handles(k) = text(ax, 0, 0, '', 'Units', item.style.Units);
            case 'bar'
                % All series are created together to preserve stacking order.
            otherwise
                error('ReproduceFigures:PlotObject', 'Unsupported plot object: %s.', item.kind);
        end
        set(handles(k), item.style);
    end
    set(ax, panel.style);
    set(ax.XLabel, panel.xLabel);
    set(ax.YLabel, panel.yLabel);
    set(ax.Title, panel.title);
end
