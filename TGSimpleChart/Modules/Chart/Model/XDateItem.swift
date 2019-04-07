import Foundation

class XDateItem {
    private let viewWidth: Double
    
    private(set) var position: Double = 0.0 {
        didSet {
            guard oldValue != position else { return }
            shouldChangePosition?(position)
        }
    }
    private(set) var alpha: Double = 1.0 {
        didSet {
            guard oldValue != alpha else { return }
            shouldAnimateAlpha?(alpha)
        }
    }
    
    var shouldAnimateAlpha: ((Double) -> Void)?
    var shouldChangePosition: ((Double) -> Void)?
    
    var shouldBeVisible: Bool {
        return position >= -15.0 && position <= viewWidth
    }
    
    let date: Date
    let title: String
    
    init(date: Date, df: DateFormatter, viewWidth: Double) {
        self.date = date
        self.title = df.string(from: date)
        self.viewWidth = viewWidth
    }
    
    func updateState(position: Double, shouldBeVisible: Bool) {
        self.position = position
        if shouldBeVisible {
            alpha = 1
        } else {
            alpha = 0
        }
    }
}
