import Foundation

class ChartRepository {
    private static let basicWidthPercentage = 0.1
    
    let interval: ChartIntervalModel
    private let chartModels: [BLChartModel]
    private let graphicScaleController: ValueScaleController
    var overviewModels: [UIChartModel] { return chartModels.map { $0.overviewUIModel } }
    var graphicModels: [UIChartModel] { return chartModels.map { $0.graphicUIModel } }
    
    private var viewWidth: Double
    var minX: Double { return interval.minX }
    var maxX: Double { return interval.maxX }
    lazy var xRange: Double = { return maxX - minX }()
    var basicBoundWidth: Double
    
    var minY: Double { return Double(chartModels.filter { $0.isSelected }.min { $0.minY < $1.minY }?.minY ?? 0) }
    var maxY: Double { return Double(chartModels.filter { $0.isSelected }.max { $0.maxY < $1.maxY }?.maxY ?? 0) }
    
    var selectedStateChanged: (((Int, Bool)) -> Void)?
    
    init(chartModel: ChartModel,
         viewWidth: Double,
         overviewHeight: Double,
         graphicHeight: Double,
         graphicScaleController: ValueScaleController) {
        var interval: ChartIntervalModel
        let xPoints = chartModel.x.values.map { Double($0) }
        
        let pointsMinX = xPoints.first!
        let pointsMaxX = xPoints.last!
        let xRange = pointsMaxX - pointsMinX
        let rBound = pointsMaxX
        let lBound = rBound - (1 - ChartRepository.basicWidthPercentage) * xRange
        
        basicBoundWidth = viewWidth * ChartRepository.basicWidthPercentage
        interval = ChartIntervalModel(xPoints: xPoints,
                                      leftBound: lBound,
                                      rightBound: rBound)
        chartModels = chartModel.charts
            .map { (chartItemData) in
            return BLChartModel(xPoints: xPoints,
                                chartData: chartItemData,
                                inteval: interval,
                                viewWidth: viewWidth,
                                overviewHeight: overviewHeight,
                                graphicHeight: graphicHeight)
        }
        self.viewWidth = viewWidth
        self.interval = interval
        self.graphicScaleController = graphicScaleController
        
        setupBindings()
    }
    
    func changeSelectedState(at index: Int) {
        chartModels[index].changeSelectedState()
        let isSelected = chartModels[index].isSelected
        graphicScaleController.reviewExremumChangeOnVisibilityChange(index: index, isVisibled: isSelected)
    }
    
    private func setupBindings() {
        graphicScaleController.extremumBoundChanged = { [weak self] range in
            guard let sSelf = self else { return }
            sSelf.graphicModels.forEach({ (uiModel) in
                uiModel.updateExtremums(min: range.lowerBound, max: range.upperBound)
            })
        }
        for i in 0..<chartModels.count {
            let model = chartModels[i]
            let minY = Double(chartModels.filter { $0.isSelected }.min { $0.globalMinY < $1.globalMinY }?.globalMinY ?? 0)
            let maxY = Double(chartModels.filter { $0.isSelected }.max { $0.globalMaxY < $1.globalMaxY }?.globalMaxY ?? 0)
            overviewModels[i].updateExtremums(min: minY, max: maxY, shouldRedraw: false)
            graphicModels[i].updateExtremums(min: self.minY, max: self.maxY, shouldRedraw: false)
            overviewModels[i].updateDisplayPointsWithDefaultMultiplier()
            graphicModels[i].updateDisplayPointsWithDefaultMultiplier()
            
            model.selectedStateChanged = { [weak self] isSelected in
                guard let sSelf = self else { return }
                sSelf.selectedStateChanged?((i, isSelected))
                
                let minY = Double(sSelf.chartModels.filter { $0.isSelected }.min { $0.globalMinY < $1.globalMinY }?.globalMinY ?? 0)
                let maxY = Double(sSelf.chartModels.filter { $0.isSelected }.max { $0.globalMaxY < $1.globalMaxY }?.globalMaxY ?? 0)
                
                for j in 0..<sSelf.graphicModels.count {
                    sSelf.graphicModels[j].updateExtremums(min: sSelf.minY, max: sSelf.maxY, shouldRedraw: false)
                    sSelf.overviewModels[j].updateExtremums(min: minY, max: maxY, shouldRedraw: false)
                    sSelf.graphicModels[j].updateDisplayPointsWithDefaultMultiplier()
                    sSelf.overviewModels[j].updateDisplayPointsWithDefaultMultiplier()
                }
            }
        }
    }
    
    func moveLeftBound(_ value: Double) {
        interval.changeLeftBound(leftXBound: value)
        graphicScaleController.reviewExtremums()
    }
    
    func moveRightBound(_ value: Double) {
        interval.changeRightBound(rightXBound: value)
        graphicScaleController.reviewExtremums()
    }
    
    func movePosition(leftBound: Double, rightBound: Double) {
        interval.changeBounds(leftXBound: leftBound, rightXBound: rightBound)
        graphicScaleController.reviewExtremums()
    }
}
