import Foundation

class ChartXAxisValuesViewModel {
    private let calendar = Calendar.current
    private lazy var baseNumberOfPoints: Double = { return Double(3.5) }()
    private let model: ChartModel
    private let repository: ChartRepository
    private let viewWidth: Double
    private let daySeconds: TimeInterval = 60 * 60 * 24
    private var interval: ChartIntervalModel { return repository.interval }
    var style: TGColorStyleProtocol { return styleController.style }
    private let styleController: TGStyleController
    
    
    var itemsUpdated: (() -> Void)?
    private(set) var items: [XDateItem] = [] {
        didSet {
            itemsUpdated?()
        }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    private var dates: [Date] = []
    private var lastDateIndex: Int
    
    init(model: ChartModel,
         viewWidth: Double,
         styleController: TGStyleController,
         repository: ChartRepository) {
        self.repository = repository
        self.viewWidth = viewWidth
        self.model = model
        self.styleController = styleController
        self.lastDateIndex = model.x.values.count - 1
        
        calculateDates()
        setupBindings()
    }
    
    private func calculateDates() {
        var intervalIndex = interval.minX
        
        var dates: [Date] = []
        while intervalIndex <= interval.maxX {
            let newDate = Date(timeIntervalSince1970: intervalIndex)
            if calendar.component(.day, from: newDate) != calendar.component(.day, from: dates.last ?? Date()) {
                dates.append(newDate)
            }
            intervalIndex += daySeconds
        }
        
        self.dates = dates
        self.items = dates.map { (date) -> XDateItem in
            return XDateItem(date: date, df: dateFormatter, viewWidth: viewWidth)
        }
    }
    
    private func setupBindings() {
        interval.subscribeOnBoundsChange { [weak self] (_) in
            guard let sSelf = self else { return }
            
            sSelf.updateDateItemsAlternative(isInitial: false)
        }
    }
    
    func updateDateItemsAlternative(isInitial: Bool) {
        let leftIndex = isInitial ? 0 : min(interval.leftIndex - 30, 0)
        let rightIndex = isInitial ? items.count - 1: max(interval.rightIndex + 30, items.count - 1)
        let numberOfCurrentPoints = Double(interval.rightIndex - interval.leftIndex)
        let scale = log2(max(numberOfCurrentPoints, baseNumberOfPoints) / baseNumberOfPoints)
        let intStep = Int(pow(2, Double(Int(scale))))
        
        print(numberOfCurrentPoints, baseNumberOfPoints, scale, intStep)
        let leftBound = interval.leftXBound
        let rightBound = interval.rightXBound
        let range = rightBound - leftBound
        
        for i in leftIndex...rightIndex where 0..<items.count~=i {
            let item = items[i]
            let date = item.date
            let position = ((date.timeIntervalSince1970 - leftBound) / range) * viewWidth
            item.updateState(position: position, shouldBeVisible: i % intStep == 0)
        }
        
        itemsUpdated?()
    }
}

