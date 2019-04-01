import Foundation

class ChartPanelViewModel {
    private(set) var dataSource: [Int: [ChartPanelListItemType]] = [:]  {
        didSet {
            chartDataUpdated?()
        }
    }
    
    var chartDataUpdated: (() -> Void)?
    var styleChanged: (() -> Void)?
    var disableScrollingCallback: ((Bool) -> Void)?
    
    var style: TGColorStyleProtocol { return styleController.style }
    
    private let styleController: TGStyleController
    init(styleController: TGStyleController) {
        self.styleController = styleController
        
        setupBindings()
    }
    
    private func setupBindings() {
        styleController.styleChanged = { [weak self] in
            guard let sSelf = self else { return }
            sSelf.styleChanged?()
        }
    }
    
    func parseChartData(width: Double) {
        guard let path = Bundle.main.path(forResource: "chart_data", ofType: "json") else { return }
        do {
            let string = try String(contentsOfFile: path)
            let viewWidth = width - ChartContainerViewModel.leftInset * 2
            guard let data = string.data(using: .utf8),
                let jsonArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] else { return }
            let chartDataSource = jsonArray
                .compactMap { (json) in
                    return ChartModel(json: json)
                }.map { (chartModel) -> [ChartPanelListItemType] in
                    let graphicHeight: Double = 440
                    let overviewHeight: Double = 57
                    let titleViewModel = ChartPanelTitleViewModel(chartModel: chartModel, styleController: styleController)
                    let graphicScaleController = ValueScaleController()
                    let chartLabelViewModels = chartModel.charts
                        .map { ChartLabelViewModel(data: $0, styleController: styleController) }
                    let repository = ChartRepository(chartModel: chartModel,
                                                     viewWidth: viewWidth,
                                                     overviewHeight: overviewHeight,
                                                     graphicHeight: graphicHeight,
                                                     graphicScaleController: graphicScaleController)
                    let overviewChartViewModel = ChartViewModel(repository: repository,
                                                                presenterModels: repository.overviewModels,
                                                                scaleController: graphicScaleController, lineWidth: 1, styleController: styleController)
                    let graphicChartViewModel = ChartViewModel(repository: repository,
                                                               presenterModels: repository.graphicModels,
                                                               scaleController: graphicScaleController, lineWidth: 2, styleController: styleController)
                    graphicScaleController.repository = repository
                    repository.selectedStateChanged = { change in
                        let (index, isSelected) = change
                        chartLabelViewModels[index].setSelectedState(isSelected)
                    }
                    
                    let infoViewModel = ChartInfoViewModel(styleController: styleController)
                    let contentViewModel = ChartContentViewModel(model: chartModel,
                                                                 styleController: styleController,
                                                                 repository: repository,
                                                                 chartViewModel: graphicChartViewModel,
                                                                 infoViewModel: infoViewModel,
                                                                 viewWidth: viewWidth)
                    let yGridViewModel = ChartYGridViewModel(repository: repository,
                                                             viewHeight: graphicHeight,
                                                             styleController: styleController, graphicScaleController: graphicScaleController)
                    let xAxisViewModel = ChartXAxisValuesViewModel(model: chartModel,
                                                                   viewWidth: viewWidth,
                                                                   styleController: styleController,
                                                                   repository: repository)
                    
                    let overviewViewModel = ChartOverviewViewModel(repository: repository,
                                                                   viewWidth: viewWidth,
                                                                   chartViewModel: overviewChartViewModel,
                                                                   styleController: styleController)
                    overviewViewModel.graphicScrollingIsActive = { [weak self] isActive in
                        guard let sSelf = self else { return }
                        sSelf.disableScrollingCallback?(!isActive)
                    }
                    let containerViewModel = ChartContainerViewModel(contentViewModel: contentViewModel,
                                                                     yGridViewModel: yGridViewModel,
                                                                     xAxisViewModel: xAxisViewModel,
                                                                     overviewViewModel: overviewViewModel,
                                                                     styleController: styleController)
                    for i in (0..<chartLabelViewModels.count) {
                        let viewModel = chartLabelViewModels[i]
                        viewModel.chartLabelDidChangeState = {
                            repository.changeSelectedState(at: i)
                        }
                    }
                    chartLabelViewModels.last?.setIsLast()
                    return [
                        .title(viewModel: titleViewModel),
                        .chart(viewModel: containerViewModel),
                        ] + chartLabelViewModels.map { .label(viewModel: $0) } + [.emptyCell(height: 35)]
            }
            
            var dataSource: [Int: [ChartPanelListItemType]] = [:]
            for (index, items) in chartDataSource.enumerated() {
                dataSource[index] = items
            }
            
            let styleModeViewModel = StyleModeViewModel(styleController: styleController)
            dataSource[chartDataSource.count] = [.emptyCell(height: 15), .styleMode(viewModel: styleModeViewModel)]
            self.dataSource = dataSource
        } catch {
            logger.log(type: .error, message: error)
        }
    }
}
