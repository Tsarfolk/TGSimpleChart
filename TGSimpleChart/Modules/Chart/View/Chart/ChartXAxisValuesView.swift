import UIKit

class ChartXAxisValuesView: UIView, Stylable {
    internal var styleActions: [() -> Void] = []
    
    private var style: TGColorStyleProtocol { return viewModel.style }
    
    private var textLayers: [CATextLayer] = []
    
    private let viewModel: ChartXAxisValuesViewModel
    init(viewModel: ChartXAxisValuesViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        clipsToBounds = true
        layer.masksToBounds = true
        
        initTextLayers()
        viewModel.updateDateItemsAlternative(isInitial: true)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initTextLayers() {
        textLayers = viewModel.items
            .map { (item) -> CATextLayer in
                let layer = CATextLayer()
                let font = TGFonts.light(ofSize: 12.5)
                layer.font = font
                layer.fontSize = font.pointSize
                layer.alignmentMode = .center
                layer.string = item.title
                layer.contentsScale = UIScreen.main.scale
                layer.frame = CGRect(origin: CGPoint(x: 0, y: 6.5),
                                     size: item.title.size(font: font))
                
                let changeOpacityAnimatedClosure: ((Double) -> Void) = { alpha in
                    let animation = CABasicAnimation(keyPath: "opacity")
                    animation.fromValue = layer.opacity
                    animation.toValue = Float(alpha)
                    animation.duration = 0.2
                    layer.add(animation, forKey: "opacityChange")
                    layer.opacity = Float(alpha)
                }
                
                let changePositionClosure: ((Double) -> Void) = { position in
                    CALayer.perform(withDuration: 0.0, actions: {
                        layer.position.x = CGFloat(position)
                    })
                }
                
                item.shouldAnimateAlpha = changeOpacityAnimatedClosure
                item.shouldChangePosition = changePositionClosure
                
                changeOpacityAnimatedClosure(item.alpha)
                changePositionClosure(item.position)
                
                self.layer.addSublayer(layer)
                
                return layer
        }
        
        styleActions.append { [weak self] in
            guard let sSelf = self else { return }
            sSelf.textLayers.forEach({ (layer) in
                layer.foregroundColor = sSelf.style.chartValueTitle.cgColor
            })
        }
        
        applyTheme()
    }
}
