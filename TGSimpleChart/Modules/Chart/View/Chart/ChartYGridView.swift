import UIKit

class ChartYGridView: UIView, Stylable {
    internal var styleActions: [() -> Void] = []
    
    private var style: TGColorStyleProtocol { return viewModel.style }
    
    private lazy var zeroView = ChartYGridItemView(string: "0", styleController: viewModel.styleController)
    private var activeViews: [ChartYGridItemView] = []
    private var removingViews: [ChartYGridItemView] = []
    private var activeConstraints: [NSLayoutConstraint] = []
    
    private let viewModel: ChartYGridViewModel
    init(viewModel: ChartYGridViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        layer.masksToBounds = true
        
        setViews()
        updateViews()
        setupBindings()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBindings() {
        viewModel.itemsUpdated = { [weak self] in
            guard let sSelf = self else { return }
            
            sSelf.updateViews()
        }
    }
    
    private func setViews() {
        addSubviews([zeroView])
        
        NSLayoutConstraint.activate([
            zeroView.leftAnchor.constraint(equalTo: leftAnchor),
            zeroView.rightAnchor.constraint(equalTo: rightAnchor),
            zeroView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
    
    private func updateViews() {
        let distance: Double = 26.1
        let initialOffset = CGFloat(viewModel.direction?.appearanceOffset ?? distance)
        
        let removingViews = activeViews
        let removingConstraints = activeConstraints
        activeViews.removeAll()
        styleActions.removeAll()
        
        var lastTopContraint: NSLayoutYAxisAnchor = zeroView.topAnchor
        var newConstraints: [NSLayoutConstraint] = []
        
        viewModel.items
            .map { (string) in
                return ChartYGridItemView(string: string, styleController: viewModel.styleController)
            }
            .forEach { (view) in
                view.alpha = 1
                addSubviews([view])
                activeViews.append(view)
                styleActions.append { view.applyTheme() }
                
                let activationContraint = view.bottomAnchor.constraint(equalTo: lastTopContraint, constant: -initialOffset)
                newConstraints.append(activationContraint)
                
                NSLayoutConstraint.activate([
                    view.leftAnchor.constraint(equalTo: leftAnchor),
                    view.rightAnchor.constraint(equalTo: rightAnchor),
                    activationContraint
                    ])
                
                lastTopContraint = view.topAnchor
        }
        styleActions.append { [weak self] in
            guard let sSelf = self else { return }
            sSelf.zeroView.applyTheme()
        }
        applyTheme()
        
        layoutIfNeeded()
        
        if let direction = viewModel.direction, removingConstraints.count > 0 {
            let value = CGFloat(direction.disappearanceOffset)
            removingConstraints.forEach { (constraint) in
                constraint.constant = -value
            }
            setNeedsLayout()
        }
        
        activeConstraints = newConstraints
        newConstraints.forEach { $0.constant = CGFloat(-distance) }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.layoutIfNeeded()
        }) { (_) in
            removingViews.forEach { $0.removeFromSuperview() }
        }
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
            removingViews.forEach({ (view) in
                view.alpha = 0
            })
            self.activeViews.forEach({ (view) in
                view.alpha = 1
            })
        }) { (_) in
        }
    }
}
