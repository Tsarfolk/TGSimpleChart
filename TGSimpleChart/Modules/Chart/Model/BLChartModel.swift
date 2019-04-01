import Foundation

class BLChartModel {
    private var points: [Point<Double, Int>] = []
    
    let overviewUIModel: UIChartModel
    let graphicUIModel: UIChartModel
    
    private let interval: ChartIntervalModel
    
    var leftIndex: Int { return interval.leftIndex }
    var rightIndex: Int { return interval.rightIndex }
    
    private var leftBound: Double { return interval.leftXBound }
    private var rightBound: Double { return interval.rightXBound }
    
    private(set) var minY: Int
    private(set) var maxY: Int
    
    private(set) var globalMinY: Int
    private(set) var globalMaxY: Int
    
    private(set) var isSelected: Bool = true {
        didSet {
            selectedStateChanged?(isSelected)
        }
    }
    
    private let name: String
    
    var selectedStateChanged: ((Bool) -> Void)?
    
    init(xPoints: [Double],
         chartData: ChartItemData,
         inteval: ChartIntervalModel,
         viewWidth: Double,
         overviewHeight: Double,
         graphicHeight: Double) {
        minY = chartData.values.min() ?? 0
        let maxY = chartData.values.max() ?? 0
        let allPoints = zip(xPoints, chartData.values).map { return Point(x: $0, y: $1) }
        self.interval = inteval
        let overviewInterval = ChartWideIntervalModel(xPoints: xPoints)
        overviewUIModel = UIChartModel(points: allPoints, interval: overviewInterval, color: chartData.color, width: viewWidth, height: overviewHeight, maxY: Double(maxY))
        graphicUIModel = UIChartModel(points: allPoints, interval: interval, color: chartData.color, width: viewWidth, height: graphicHeight, maxY: Double(maxY))
        name = chartData.name
        points = allPoints
        self.maxY = maxY
        self.globalMinY = minY
        self.globalMaxY = maxY
        
        setupBindings()
        graphicUIModel.update(leftBound: leftBound, rightBound: rightBound)
        updateExtremums(oldValue: interval.leftIndex, newValue: interval.rightIndex)
    }
    
    private func setupBindings() {
        interval.subscribeOnIndexChange { [weak self] (type) in
            guard let sSelf = self else { return }
            
            sSelf.updateExtremums(oldValue: sSelf.leftIndex, newValue: sSelf.rightIndex)
            /*
            switch type {
            case .left(let oldValue, let newValue):
                sSelf.updateExtremums(oldValue: leftBound, newValue: rightBound)
            case .right(let oldValue, let newValue):
                sSelf.updateExtremums(oldValue: oldValue, newValue: newValue)
            case .both(let left, let right):
                guard case .left(let oldLValue, let newLValue) = left else { return }
                guard case .right(let oldRValue, let newRValue) = right else { return }
                
                sSelf.updateExtremums(oldValue: oldLValue, newValue: newLValue)
                sSelf.updateExtremums(oldValue: oldRValue, newValue: newRValue)
            }
 */
        }
        
        interval.subscribeOnBoundsChange { [weak self] (type) in
            guard let sSelf = self else { return }
            
            sSelf.graphicUIModel.update(leftBound: sSelf.leftBound, rightBound: sSelf.rightBound)
        }
    }
    
    func changeSelectedState() {
        let newSelectedState = !isSelected
        graphicUIModel.setSelectedState(newSelectedState)
        overviewUIModel.setSelectedState(newSelectedState)
        isSelected = newSelectedState
    }
    
    private func updateExtremums(oldValue: Int, newValue: Int) {
//        let range = oldValue < newValue ? oldValue...newValue : newValue...oldValue
        var newMinY = Int.max
        var newMaxY = Int.min
        points[leftIndex...rightIndex].forEach({ (point) in
            let yValue = point.y
            if newMinY > yValue {
                newMinY = yValue
            }
            if newMaxY < yValue {
                newMaxY = yValue
            }
        })
        
//        logger.log(type: .info, message: (newMinY, newMaxY))
        minY = newMinY
        maxY = newMaxY
    }
}
