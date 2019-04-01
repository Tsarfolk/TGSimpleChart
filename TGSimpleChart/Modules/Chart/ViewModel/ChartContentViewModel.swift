import Foundation

class ChartContentViewModel {
    private let repository: ChartRepository
    private let model: ChartModel
    let infoViewModel: ChartInfoViewModel
    private let viewWidth: Double
    private var interval: ChartIntervalModel { return repository.interval }
    
    var style: TGColorStyleProtocol { return styleController.style }
    private let styleController: TGStyleController
    let chartViewModel: ChartViewModel
    
    private var previousOffsetX: Double?
    
    var drawInfoView: ((Double) -> Void)?
    var removeInfoView: (() -> Void)?
    
    private let df: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM d"
        return df
    }()
    private let yearDf: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "YYYY"
        return df
    }()
    
    init(model: ChartModel,
         styleController: TGStyleController,
         repository: ChartRepository,
         chartViewModel: ChartViewModel,
         infoViewModel: ChartInfoViewModel,
         viewWidth: Double) {
        self.model = model
        self.styleController = styleController
        self.repository = repository
        self.chartViewModel = chartViewModel
        self.infoViewModel = infoViewModel
        self.viewWidth = viewWidth
    }
    
    func touchStarted(offsetX: Double) {
        previousOffsetX = offsetX
    }
    
    func touchMoved(offsetX: Double) {
        previousOffsetX = offsetX
        process(by: offsetX)
    }
    
    func touchEnded() {
        previousOffsetX = nil
        removeInfoView?()
    }
    
    private func process(by offset: Double) {
        let part = offset / viewWidth
        let timeInterval = interval.leftXBound + part * (interval.rightXBound - interval.leftXBound)
        let date = Date(timeIntervalSince1970: timeInterval)
        
        let points = chartViewModel.presenterModels
            .map { (model) in
                model.point(by: timeInterval)
        }
        
        chartViewModel.drawCircles(points)
        infoViewModel.valueStrings = zip(points, chartViewModel.presenterModels).map { (String(Int($0.y)), $1.hex) }
        infoViewModel.dateString = df.string(from: date)
        infoViewModel.yearStrign = yearDf.string(from: date)
        infoViewModel.updateModel()
        drawInfoView?(offset)
        infoViewModel.updateModel()
    }
}
