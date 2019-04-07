import Foundation

class ChartXAxisValuesViewModel {
    private let calendar = Calendar.current
    private let model: ChartModel
    private let repository: ChartRepository
    private let viewWidth: Double
    private let daySeconds: TimeInterval = 60 * 60 * 24
    private var interval: ChartIntervalModel { return repository.interval }
    var style: TGColorStyleProtocol { return styleController.style }
    private let styleController: TGStyleController
    
    private var anchorDate: Date?
    
    var itemsUpdated: (() -> Void)?
    private(set) var items: [DateItem] = [] {
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
    private var lastDateIndex: Int = 0
    
    struct DateItem {
        let position: Double
        let date: Date
        let alpha: Double
        
        var title: String = ""
    }
    
    init(model: ChartModel,
         viewWidth: Double,
         styleController: TGStyleController,
         repository: ChartRepository) {
        self.repository = repository
        self.viewWidth = viewWidth
        self.model = model
        self.styleController = styleController
        
        calculateDates()
        setupBindings()
        updateDateItemsAlternative2()
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
    }
    
    private func setupBindings() {
        interval.subscribeOnBoundsChange { [weak self] (_) in
            guard let sSelf = self else { return }
            
            sSelf.updateDateItemsAlternative2()
        }
    }
    
    private let baseNumberOfPoints: Double = 5
    
    private func updateDateItemsAlternative2() {
        let numberOfCurrentPoints = Double(interval.rightIndex - interval.leftIndex)
        let scale = log2(max(numberOfCurrentPoints, baseNumberOfPoints) / baseNumberOfPoints)
        let intStep = Int(pow(2, scale))
        let alpha: Double = 1
        
        let leftBound = interval.leftXBound
        let rightBound = interval.rightXBound
        let range = rightBound - leftBound
        let modOffset: Int = 0
        
        var direction: Int = 1
        while !(leftBound...rightBound~=dates[lastDateIndex].timeIntervalSince1970) {
            if dates[lastDateIndex].timeIntervalSince1970 < leftBound {
                lastDateIndex += 1
                direction = 1
            } else {
                lastDateIndex -= 1
                direction = -1
            }
        }
        
        let lastValidIndex: Int = lastDateIndex
        while lastDateIndex % intStep != modOffset {
            lastDateIndex += direction
        }
        
        if !(0..<dates.count~=lastDateIndex) {
            lastDateIndex = lastValidIndex
            return
        }
        
        var items: [DateItem] = []
        
        for i in [1, -1] {
            let offset = intStep * -i
            var index = lastDateIndex
            let bound = i == 1 ? leftBound - daySeconds * 4 : rightBound
            while (dates[index].timeIntervalSince1970 - bound) * Double(i) >= 0 {
                let date = dates[index]
                let position = ((date.timeIntervalSince1970 - leftBound) / range - 0.5) * viewWidth
                let item = ChartXAxisValuesViewModel.DateItem(position: position,
                                                              date: date,
                                                              alpha: alpha,
                                                              title: dateFormatter.string(from: date))
                items.append(item)
                index += offset
                if !(0..<dates.count~=index) {
                    break
                }
            }
        }
        
        self.items = items.sorted { $0.date < $1.date }
    }

    // pow & alpha
    private func powOf2(number: Double) -> Int {
        var current: Double = 1
        var counter: Int = 0
        while current <= number {
            current *= 2
            counter += 1
        }
        
        return counter
    }
}

