import UIKit

class ChartPanelTitleCell: UICollectionViewCell, Stylable {
    internal var styleActions: [() -> Void] = []
    
    private weak var viewModel: ChartPanelTitleViewModel?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = TGFonts.regular(ofSize: 16)
        label.textAlignment = .left
        styleActions.append { [weak self] in
            guard let sSelf = self else { return }
            label.textColor = sSelf.viewModel?.style.chartPanelTitle
        }
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        styleActions.append { [weak self] in
            guard let sSelf = self else { return }
            sSelf.backgroundColor = sSelf.viewModel?.style.viewControllerBackground
        }
        setViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(viewModel: ChartPanelTitleViewModel) {
        titleLabel.text = viewModel.title
        self.viewModel = viewModel
        applyTheme()
    }
    
    private func setViews() {
        addSubviews([titleLabel])
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 22.5),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
    }
}
