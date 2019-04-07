import UIKit

class ChartLabelCell: UICollectionViewCell, Stylable {
    internal var styleActions: [() -> Void] = []
    
    private lazy var colorRectangleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 3
        view.backgroundColor = UIColor(hex: viewModel?.colorHex ?? "#FFFFFF")
        return view
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = viewModel?.title
        styleActions.append { [weak self] in
            guard let sSelf = self else { return }
            label.textColor = sSelf.viewModel?.style.chartLabelText
        }
        
        return label
    }()
    
    private lazy var separatorLineView: UIView = {
        let view = UIView()
        styleActions.append { [weak self] in
            guard let sSelf = self else { return }
            view.backgroundColor = sSelf.viewModel?.style.contentSeparator
        }
        return view
    }()
    private let checkMarkImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    var leftOffsetSeparatorConstraint: NSLayoutConstraint?
    
    private let checkMarkImage = UIImage(named: "icons8-checkmark-filled-50")?.withRenderingMode(.alwaysTemplate)
    
    private weak var viewModel: ChartLabelViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
     
        setViews()
        
        styleActions.append { [weak self] in
            guard let sSelf = self else { return }
            sSelf.checkMarkImageView.tintColor = sSelf.viewModel?.style.checkMarkColor
            sSelf.backgroundColor = sSelf.viewModel?.style.contentBackground
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(viewModel: ChartLabelViewModel) {
        self.viewModel = viewModel
        self.viewModel?.updateSelectedState = { [weak self] in
            guard let sSelf = self else { return }
            
            sSelf.updateUISelectedState()
        }
        
        updateUISelectedState()
        leftOffsetSeparatorConstraint?.constant = viewModel.isSeparatorEdgeToEdge ? 0 : 45
        colorRectangleView.backgroundColor = UIColor(hex: viewModel.colorHex)
        titleLabel.text = viewModel.title
        
        applyTheme()
    }
    
    private func setViews() {
        contentView.addSubviews([colorRectangleView, titleLabel, separatorLineView, checkMarkImageView])
        
        // colorRectangleView
        NSLayoutConstraint.activate([
            colorRectangleView.heightAnchor.constraint(equalToConstant: 12),
            colorRectangleView.widthAnchor.constraint(equalToConstant: 12),
            colorRectangleView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16.6),
            colorRectangleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
        
        // titleLabel
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: colorRectangleView.rightAnchor, constant: 16.6),
            titleLabel.centerYAnchor.constraint(equalTo: colorRectangleView.centerYAnchor)
            ])
        
        
        let separatorLineViewLeftConstraint = separatorLineView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0)
        leftOffsetSeparatorConstraint = separatorLineViewLeftConstraint
        NSLayoutConstraint.activate([
            separatorLineViewLeftConstraint,
            separatorLineView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            separatorLineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorLineView.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        
        // checkmark
        checkMarkImageView.image = checkMarkImage
        NSLayoutConstraint.activate([
            checkMarkImageView.heightAnchor.constraint(equalToConstant: 10),
            checkMarkImageView.widthAnchor.constraint(equalToConstant: 12),
            checkMarkImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16.6),
            checkMarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellDidTouch))
        addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func cellDidTouch() {
        viewModel?.didTouch()
    }
    
    private func updateUISelectedState() {
        UIView.animate(withDuration: 0.3) {
            self.checkMarkImageView.alpha = self.viewModel?.isSelected == true ? 1 : 0
        }
    }
}
