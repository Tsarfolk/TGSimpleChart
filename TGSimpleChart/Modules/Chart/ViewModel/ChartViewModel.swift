import Foundation

class ChartViewModel {
    private let repository: ChartRepository
    private var interval: ChartIntervalModel { return repository.interval }
    private let scaleController: ValueScaleController
    
    var modelsUpdated: (() -> Void)?
    var animateVisibility: ((Int, Double, Double, Double, Double) -> Void)?
    var drawPoints: (([Point<Double, Double>]) -> Void)?
    let presenterModels: [UIChartModel]
    let lineWidth: Double
    
    private let styleController: TGStyleController
    var style: TGColorStyleProtocol { return styleController.style }
    
    init(repository: ChartRepository, presenterModels: [UIChartModel], scaleController: ValueScaleController, lineWidth: Double, styleController: TGStyleController) {
        self.lineWidth = lineWidth
        self.repository = repository
        self.presenterModels = presenterModels
        self.scaleController = scaleController
        self.styleController = styleController
        
        setupBinding()
    }
    
    func drawCircles(_ points: [Point<Double, Double>]) {
        drawPoints?(points)
    }
    
    private func setupBinding() {
        interval.subscribeOnBoundsChange { [weak self] (_) in
            guard let sSelf = self else { return }
            
            sSelf.modelsUpdated?()
        }
        
        scaleController.subscribeOnExtremumChange { [weak self] (direction, bounds, index, isVisible) in
            guard let sSelf = self else { return }
            
            let finalTransform: Double = direction > 0 ? 1.5 : 0.2
            var startTransform: Double = 0.0
            var endTransform: Double = 0.0
            var startAlpha: Double = 0.0
            var endAlpha: Double = 0.0
            
            if isVisible {
                startTransform = finalTransform
                endTransform = 1
                startAlpha = 0
                endAlpha = 1
            } else {
                startTransform = 1
                endTransform = finalTransform
                startAlpha = 1
                endAlpha = 0
            }
            
            sSelf.animateVisibility?(index, startTransform, endTransform, startAlpha, endAlpha)
        }
    }
}
