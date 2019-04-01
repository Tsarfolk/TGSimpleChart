import UIKit

class ChartView: UIView {
    private lazy var lineWidth: CGFloat = { return CGFloat(viewModel.lineWidth) }()
    private var models: [UIChartModel] { return viewModel.presenterModels }
    
    private var chartLayers: [CAShapeLayer] = []
    private var circleShapeLayers: [CAShapeLayer] = []
    
    private let viewModel: ChartViewModel
    init(viewModel: ChartViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        setupBindings()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBindings() {
        viewModel.modelsUpdated = { [weak self] in
            guard let sSelf = self else { return }
            
            sSelf.setNeedsDisplay()
        }
        
        viewModel.animateVisibility = { [weak self] index, startTransform, endTransform, startAlpha, endAlpha in
            guard let sSelf = self else { return }
            
            sSelf.chartLayers[index].transform = CATransform3DMakeScale(1, CGFloat(startAlpha), 1)
            sSelf.chartLayers[index].opacity = Float(startAlpha)
            if startAlpha < 1 {
                sSelf.chartLayers[index].path = sSelf.path(from: sSelf.models[index].displayedPoints).cgPath
            }
            
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.4)
            
            sSelf.chartLayers[index].transform = CATransform3DMakeScale(1, CGFloat(endAlpha), 1)
            sSelf.chartLayers[index].opacity = Float(endAlpha)
            
            CATransaction.commit()
            
            for i in 0..<sSelf.models.count where i != index && sSelf.models[i].isSelected {
                let bezierPath = sSelf.path(from: sSelf.models[i].displayedPoints)
                let basicAnimation = CABasicAnimation(keyPath: "path")
                basicAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
                basicAnimation.duration = 0.3
                basicAnimation.fromValue = sSelf.chartLayers[i].path
                basicAnimation.toValue = bezierPath.cgPath
                sSelf.chartLayers[i].add(basicAnimation, forKey: "path")
                sSelf.chartLayers[i].path = bezierPath.cgPath
            }
        }
        
        viewModel.drawPoints = { [weak self] points in
            guard let sSelf = self else { return }
            
            sSelf.circleShapeLayers.forEach { $0.removeFromSuperlayer() }
            
            for i in 0..<points.count {
                let point = points[i]
                let model = sSelf.models[i]
                let bezierPath = UIBezierPath(ovalIn: CGRect(x: point.x, y: point.y, width: 5, height: 5))
                let circleSL = CAShapeLayer()
                circleSL.path = bezierPath.cgPath
                circleSL.strokeColor = model.color.cgColor
                circleSL.fillColor = sSelf.viewModel.style.contentBackground.cgColor
                
                sSelf.layer.addSublayer(circleSL)
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        // add more clear mechanic for updates (like to look for diff and then update) / can be implemeneted in VM
        let shouldCreateNew = chartLayers.isEmpty
        
        for i in (0..<models.count) {
            let model = models[i]
            if shouldCreateNew {
                let shapeLayer = CAShapeLayer()
                chartLayers.append(shapeLayer)
                layer.addSublayer(shapeLayer)
            }
            
            draw(for: model, for: chartLayers[i])
            model.modelUpdated = { [weak self] in
                guard let sSelf = self else { return }
                sSelf.draw(for: model, for: sSelf.chartLayers[i])
            }
        }
    }
    
    private func draw(for model: UIChartModel, for shapeLayer: CAShapeLayer) {
        let points = model.displayedPoints
        
        let bezierPath = path(from: points)
        
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.lineWidth = lineWidth
        shapeLayer.strokeColor = model.color.cgColor
        shapeLayer.opacity = model.isSelected ? 1 : 0
        
        shapeLayer.fillColor = nil
    }
    
    private func path(from points: [CGPoint]) -> UIBezierPath {
        let bezierPath = UIBezierPath()
        
        bezierPath.removeAllPoints()
        bezierPath.move(to: points.first ?? .zero)
        points
            .dropFirst()
            .forEach { (point) in
                bezierPath.addLine(to: point)
        }
        
        return bezierPath
    }
}
