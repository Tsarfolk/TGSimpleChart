import UIKit

class ChartContainerViewCell: UICollectionViewCell, Stylable {
    internal var styleActions: [() -> Void] = []
    
    private var containerView: ChartContainerView?
    
    private weak var viewModel: ChartContainerViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        styleActions.append { [weak self] in
            guard let sSelf = self else { return }
            sSelf.backgroundColor = sSelf.viewModel?.style.contentBackground
        }
        
        setViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(viewModel: ChartContainerViewModel) {
        self.viewModel = viewModel
        // TODO: optimization point
        containerView?.removeFromSuperview()
        containerView = ChartContainerView(viewModel: viewModel)
        setViews()
        applyTheme()
        containerView?.applyTheme()
    }
    
    private func setViews() {
        guard let containerView = containerView else { return }
        contentView.addSubviews([containerView])
        
        NSLayoutConstraint.activate([
            containerView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            ])
    }
}
