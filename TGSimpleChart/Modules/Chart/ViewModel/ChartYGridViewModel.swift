import Foundation

class ChartYGridViewModel {
    private let repository: ChartRepository
    private let graphicScaleController: ValueScaleController
    private var previousMax: Double
    private var previousMin: Double
    
    var style: TGColorStyleProtocol { return styleController.style }
    let styleController: TGStyleController
    
    enum Direction {
        case top, bottom
        
        var disappearanceOffset: Double {
            switch self {
            case .bottom:
                return 20
            case .top:
                return 400
            }
        }
        
        var appearanceOffset: Double {
            switch self {
            case .top:
                return 20
            case .bottom:
                return 400
            }
        }
    }
    
    var itemsUpdated: (() -> Void)?
    private(set) var items: [String] = [] {
        didSet {
            itemsUpdated?()
        }
    }
    private(set) var direction: Direction? = nil
    
    private var initialRange: ClosedRange<Double>
    
    init(repository: ChartRepository,
         viewHeight: Double,
         styleController: TGStyleController,
         graphicScaleController: ValueScaleController) {
        self.graphicScaleController = graphicScaleController
        self.repository = repository
        self.styleController = styleController
        self.initialRange = repository.minY...repository.maxY
        self.previousMax = repository.maxY
        self.previousMin = repository.minY
        
        updateDataSource(with: initialRange)
        setupBindings()
    }
    
    private func setupBindings() {
        graphicScaleController.goalExtremumChanged = { [weak self] newRange in
            guard let sSelf = self else { return }
            sSelf.updateDataSource(with: newRange)
        }
    }
    
    private func updateDataSource(with range: ClosedRange<Double>) {
        var items: [String] = []
        
        direction = previousMax > range.upperBound ? .top : .bottom
        let minY = range.lowerBound
        let maxY = range.upperBound
        let range = maxY - minY
        
        for i in (0..<5) {
            items.append(formated(doubleValue: minY + 0.2 * Double(i) * range))
        }
        
        previousMax = maxY
        previousMin = minY
        self.items = items
    }
    
    private func formated(doubleValue: Double) -> String {
        let intValue = Int(doubleValue)
        if intValue > 999_999 {
            let firstPart = "\(intValue / 1000_000).\(intValue % 1000_000 / 10000)M"
            return firstPart
        }
        if intValue > 999 {
            let firstPart = "\(intValue / 1000).\(intValue % 1000 / 10)K"
            return firstPart
        } else {
            return "\(intValue)"
        }
    }
}
