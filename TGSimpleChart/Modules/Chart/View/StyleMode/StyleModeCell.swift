import UIKit

class StyleModeCell: UICollectionViewCell, Stylable {
    internal var styleActions: [() -> Void] = []
    
    private weak var viewModel: StyleModeViewModel?
    private var style: TGColorStyleProtocol? { return viewModel?.style }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = TGFonts.regular(ofSize: 18)
        label.textAlignment = .center
        styleActions.append { [weak self] in
            guard let sSelf = self else { return }
            label.textColor = sSelf.viewModel?.style.chartPanelTitle
        }
        return label
    }()
    private let topSeparatorView = UIView()
    private let bottomSeparatorView = UIView()
    private let touchAreaView = UIView()
    
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
    
    func configure(viewModel: StyleModeViewModel) {
        self.viewModel = viewModel
        if viewModel.shouldAddTitleStyleAction {
            styleActions.append { [weak self] in
                guard let sSelf = self else { return }
                
                sSelf.titleLabel.text = sSelf.viewModel?.title
                sSelf.titleLabel.textColor = sSelf.style?.changeStyleButtonTitle
            }
        }
        applyTheme()
    }
    
    private func setViews() {
        contentView.addSubviews([titleLabel, topSeparatorView, bottomSeparatorView])
        
        [topSeparatorView, bottomSeparatorView].forEach { (view) in
            styleActions.append({ [weak self] in
                guard let sSelf = self else { return }
                view.backgroundColor = sSelf.style?.contentSeparator
            })
        }
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
        NSLayoutConstraint.activate([
            topSeparatorView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            topSeparatorView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            topSeparatorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topSeparatorView.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        NSLayoutConstraint.activate([
            bottomSeparatorView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            bottomSeparatorView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            bottomSeparatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomSeparatorView.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellDidTouch)))
    }
    
    @objc
    private func cellDidTouch() {
        viewModel?.toggleStyleController()
    }
}
