import UIKit

protocol ChartPullControllersViewDelegate: class {
    func touchesBegan(by touch: UITouch, for pullType: ChartPullControllerType)
    func touchesMoved(by touch: UITouch)
    func touchesEnded()
}

enum ChartPullControllerType {
    case left, right, center
}

// TODO: add arrows
class ChartPullControllersView: UIView, Stylable {
    internal var styleActions: [() -> Void] = []
    
    private let leftView = UIView()
    private let rightView = UIView()
    
    private let style: TGColorStyleProtocol
    private let horizontalBorderWidth: CGFloat
    
    private let leftArrowImageView = UIImageView(image: UIImage(named: "icons8-back-filled-50")?.withRenderingMode(.alwaysTemplate))
    private let rightArrowImageView = UIImageView(image: UIImage(named: "icons8-forward-filled-50")?.withRenderingMode(.alwaysTemplate))
    
    weak var delegate: ChartPullControllersViewDelegate?
    
    init(horizontalBorderWidth: CGFloat, style: TGColorStyleProtocol) {
        self.style = style
        self.horizontalBorderWidth = horizontalBorderWidth
        super.init(frame: .zero)
        
        layer.cornerRadius = 3
        
        setViews()
        applyTheme()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setViews() {
        styleActions.append { [weak self] in
            guard let sSelf = self else { return }
            
            sSelf.leftView.backgroundColor = sSelf.style.chartOverviewPullControllerBackground.withAlphaComponent(0.5)
            sSelf.rightView.backgroundColor = sSelf.style.chartOverviewPullControllerBackground.withAlphaComponent(0.5)
        }
        
        addSubviews([leftView, rightView])
        
        NSLayoutConstraint.activate([
            leftView.leftAnchor.constraint(equalTo: leftAnchor),
            leftView.topAnchor.constraint(equalTo: topAnchor),
            leftView.widthAnchor.constraint(equalToConstant: horizontalBorderWidth),
            leftView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        
        NSLayoutConstraint.activate([
            rightView.topAnchor.constraint(equalTo: topAnchor),
            rightView.rightAnchor.constraint(equalTo: rightAnchor),
            rightView.widthAnchor.constraint(equalToConstant: horizontalBorderWidth),
            rightView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        
        leftView.addSubviews([leftArrowImageView])
        leftArrowImageView.tintColor = style.chartOverviewFrameFocusArrow
        NSLayoutConstraint.activate([
            leftArrowImageView.centerXAnchor.constraint(equalTo: leftView.centerXAnchor),
            leftArrowImageView.centerYAnchor.constraint(equalTo: leftView.centerYAnchor),
            leftArrowImageView.widthAnchor.constraint(equalToConstant: 20),
            leftArrowImageView.heightAnchor.constraint(equalToConstant: 20)
            ])
        
        rightView.addSubviews([rightArrowImageView])
        rightArrowImageView.tintColor = style.chartOverviewFrameFocusArrow
        
        NSLayoutConstraint.activate([
            rightArrowImageView.centerXAnchor.constraint(equalTo: rightView.centerXAnchor),
            rightArrowImageView.centerYAnchor.constraint(equalTo: rightView.centerYAnchor),
            rightArrowImageView.widthAnchor.constraint(equalToConstant: 20),
            rightArrowImageView.heightAnchor.constraint(equalToConstant: 20)
            ])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
            let view = touch.view
            else { return }
        
        switch view {
        case leftView:
            delegate?.touchesBegan(by: touch, for: .left)
        case rightView:
            delegate?.touchesBegan(by: touch, for: .right)
        default:
            delegate?.touchesBegan(by: touch, for: .center)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first
            else { return }
        
        delegate?.touchesMoved(by: touch)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.touchesEnded()
    }
}
