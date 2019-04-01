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
    
    var doubleScale: Double { return repository.xScale }
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
        updateDateItemsAlternative()
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
            
            sSelf.updateDateItemsAlternative()
        }
    }
    
    private func updateDateItemsAlternative() {
        let powValue = powOf2(number: doubleScale)
        let addition = repository.minimumNumberOfPoints > 32 ? 1 : 0
        let step = (pow(2, powValue + 2 + addition) as NSNumber).intValue
        let sPowValue = (pow(2.0, powValue - 1) as NSNumber).doubleValue
        let ePowValue = (pow(2.0, powValue) as NSNumber).doubleValue
        let alpha = (ePowValue - doubleScale) / (ePowValue - sPowValue)
    
        let leftBound = interval.leftXBound
        let dayGap = step / 2
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
        while dayGap > 1, lastDateIndex % dayGap != modOffset {
            lastDateIndex += direction
        }
        
        if !(0..<dates.count~=lastDateIndex) {
            lastDateIndex = lastValidIndex
            return
        }
        
        var items: [DateItem] = []
        
        for i in [1, -1] {
            let offset = dayGap * -i
            var index = lastDateIndex
            let bound = i == 1 ? leftBound - daySeconds * 4 : rightBound
            while (dates[index].timeIntervalSince1970 - bound) * Double(i) >= 0 {
                let date = dates[index]
                let alpha = index % step == modOffset ? 1.0 : alpha * alpha
//                print(alpha)
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

