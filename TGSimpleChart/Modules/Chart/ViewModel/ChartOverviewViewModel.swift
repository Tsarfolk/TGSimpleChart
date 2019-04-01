import Foundation

class ChartOverviewViewModel {
    var style: TGColorStyleProtocol { return styleController.style }
    private let styleController: TGStyleController
    private let viewWidth: Double
    private let repository: ChartRepository
    private var interval: ChartIntervalModel { return repository.interval }
    
    var graphicScrollingIsActive: ((Bool) -> Void)?
    
    // ViewModel <-- UI
    var xActiveBoundChanged: (() -> Void)?
    let chartViewModel: ChartViewModel
    var currentFocusWindowWidth: Double { return viewXActiveBound.upperBound - viewXActiveBound.lowerBound }
    
    private(set) var viewXActiveBound: Range<Double> {
        didSet {
            xActiveBoundChanged?()
        }
    }
    
    // scale from basis size of focus window [1, +]
    // width of the focus window with scale = 1
    private var basisFocusWindowWidth: Double { return repository.basicBoundWidth }
    private var scale: Double { return currentFocusWindowWidth / basisFocusWindowWidth }
    
    // draggin properties
    private var previousOffsetX: Double?
    private var pullingType: ChartPullControllerType?
    private var distanceToLeftBound: Double = 0.0
    private var distanceToRightBound: Double { return currentFocusWindowWidth - distanceToLeftBound }
    private var isDragging: Bool { return previousOffsetX != nil }
    
    init(repository: ChartRepository,
         viewWidth: Double,
         chartViewModel: ChartViewModel,
         styleController: TGStyleController) {
        self.viewWidth = viewWidth
        self.styleController = styleController
        self.repository = repository
        self.chartViewModel = chartViewModel
        self.viewXActiveBound = viewWidth - repository.basicBoundWidth..<viewWidth
        updateActiveBounds(by: viewXActiveBound, pullingType: .center)
    }
    
    func beginMove(at offsetX: Double, with type: ChartPullControllerType) {
        previousOffsetX = offsetX
        pullingType = type
        distanceToLeftBound = offsetX - viewXActiveBound.lowerBound
        graphicScrollingIsActive?(true)
    }
    
    // TODO: fix calculation
    func move(by offsetX: Double) {
        guard let previousOffsetX = previousOffsetX, let pullingType = pullingType else { return }
        let diff = offsetX - previousOffsetX
        
        switch pullingType {
        case .left:
            let lowerBound = viewXActiveBound.lowerBound + diff
            guard viewXActiveBound.upperBound - lowerBound >= basisFocusWindowWidth else { return }
            updateActiveBounds(by: lowerBound..<viewXActiveBound.upperBound, pullingType: pullingType)
        case .right:
            let upperBound = viewXActiveBound.upperBound + diff
            guard upperBound - viewXActiveBound.lowerBound >= basisFocusWindowWidth else { return }
            updateActiveBounds(by: viewXActiveBound.lowerBound..<upperBound, pullingType: pullingType)
        case .center:
            let lowerBound = viewXActiveBound.lowerBound + diff
            let upperBound = viewXActiveBound.upperBound + diff
            guard upperBound - lowerBound >= basisFocusWindowWidth - 0.1 else { return }
            updateActiveBounds(by: lowerBound..<upperBound, pullingType: pullingType)
        }
        self.previousOffsetX = offsetX
        distanceToLeftBound = offsetX - viewXActiveBound.lowerBound
    }
    
    func moveEnded() {
        previousOffsetX = nil
        graphicScrollingIsActive?(false)
    }
    
    private func updateActiveBounds(by coordinates: Range<Double>, pullingType: ChartPullControllerType) {
        let leftBound = max(0, coordinates.lowerBound)
        let rightBound = min(viewWidth, coordinates.upperBound)
        var actualCoordinates = leftBound..<rightBound
        switch pullingType {
        case .center:
            let length = viewXActiveBound.upperBound - viewXActiveBound.lowerBound
            if leftBound + length <= viewWidth {
                actualCoordinates = leftBound..<leftBound + length
            } else {
                actualCoordinates = rightBound - length..<rightBound
            }
        default:
            break
        }
        let lowerBound = Double(repository.minX + actualCoordinates.lowerBound / viewWidth * repository.xRange)
        let upperBound = Double(repository.minX + actualCoordinates.upperBound / viewWidth * repository.xRange)
        self.viewXActiveBound = actualCoordinates
        switch pullingType {
        case .left:
            repository.moveLeftBound(lowerBound)
        case .right:
            repository.moveRightBound(upperBound)
        case .center:
            repository.movePosition(leftBound: lowerBound, rightBound: upperBound)
        }
    }
}
