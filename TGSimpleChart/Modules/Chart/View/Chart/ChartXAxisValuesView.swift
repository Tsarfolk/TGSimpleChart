import UIKit

class ChartXAxisValuesView: UIView, Stylable {
    internal var styleActions: [() -> Void] = []
    
    private var style: TGColorStyleProtocol { return viewModel.style }
    private var dateLabels: [UILabel] = []
    
    private let viewModel: ChartXAxisValuesViewModel
    init(viewModel: ChartXAxisValuesViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        clipsToBounds = true
        layer.masksToBounds = true
        
        setupBingings()
        resetDateLabels()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBingings() {
        viewModel.itemsUpdated = { [weak self] in
            guard let sSelf = self else { return }
            
            sSelf.resetDateLabels()
        }
    }
    
    private func resetDateLabels() {
        dateLabels.forEach { (label) in
            label.removeFromSuperview()
        }
        dateLabels.removeAll()
        styleActions.removeAll()
        
        viewModel.items
            .forEach { (item) in
                let label = UILabel()
                label.font = TGFonts.light(ofSize: 12.5)
                label.textAlignment = .center
                label.alpha = CGFloat(item.alpha)
                label.text = item.title
                
                styleActions.append { [weak self] in
                    guard let sSelf = self else { return }
                    label.textColor = sSelf.style.chartValueTitle
                }
                addSubviews([label])
                NSLayoutConstraint.activate([
                    label.centerYAnchor.constraint(equalTo: centerYAnchor),
                    label.leftAnchor.constraint(equalTo: centerXAnchor, constant: CGFloat(item.position))
                    ])
                dateLabels.append(label)
        }
        
        applyTheme()
    }
}
