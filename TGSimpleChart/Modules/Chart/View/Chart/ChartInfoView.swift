import UIKit

class ChartInfoView: UIView, Stylable {
    private(set) var styleActions: [() -> Void] = []
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = TGFonts.medium(ofSize: 14)
        label.textColor = self.viewModel.style.chartLabelText
        label.textAlignment = .right
        return label
    }()
    private lazy var yearLabel: UILabel = {
        let label = UILabel()
        label.font = TGFonts.medium(ofSize: 14)
        label.textColor = self.viewModel.style.chartLabelText
        label.textAlignment = .right
        return label
    }()
    private var labels: [UILabel] = []
    private var heightCont: NSLayoutConstraint?
    private let viewModel: ChartInfoViewModel
    init(viewModel: ChartInfoViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        setViews()
        udpateUIFromVM()
        setupBindings()
        layer.cornerRadius = 3
        
        styleActions.append {
            self.backgroundColor = viewModel.style.chartOverviewFocusChartWindow
        }
        applyTheme()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBindings() {
        viewModel.modelUpdated = { [weak self] in
            guard let sSelf = self else { return }
            
            sSelf.udpateUIFromVM()
        }
    }
    
    private func udpateUIFromVM() {
        yearLabel.text = viewModel.yearStrign
        dateLabel.text = viewModel.dateString
        
        if labels.count == viewModel.valueStrings.count {
            zip(labels, viewModel.valueStrings).forEach { (label, value) in
                let (title, hex) = value
                label.text = title
                label.textColor = UIColor(hex: hex)
            }
        } else {
            var previousConstraint = topAnchor
            var offset: CGFloat = 12.5

            labels.forEach { $0.removeFromSuperview() }
            labels.removeAll()
            
            viewModel.valueStrings.forEach { (value) in
                let (title, hex) = value
                let label = UILabel()
                label.text = title
                label.textColor = UIColor(hex: hex)
                label.font = TGFonts.medium(ofSize: 14)
                addSubviews([label])
                labels.append(label)
                
                NSLayoutConstraint.activate([
                    label.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
                    label.topAnchor.constraint(equalTo: previousConstraint, constant: offset)
                    ])
                
                previousConstraint = label.bottomAnchor
                offset = 8.5
            }
        }
        
        heightCont?.constant = 12.5 + 10.5 + CGFloat(max(2, viewModel.valueStrings.count)) * 12.5 + CGFloat(max(2, viewModel.valueStrings.count - 1) * 17)
    }
    
    private func setViews() {
        let cont = heightAnchor.constraint(equalToConstant: CGFloat(max(2, viewModel.valueStrings.count)) * 18)
        heightCont = cont
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 140),
            cont
            ])
        
        addSubviews([dateLabel, yearLabel])
        
        NSLayoutConstraint.activate([
            dateLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            dateLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8.5)
            ])
        
        NSLayoutConstraint.activate([
            yearLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            yearLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 7.3)
            ])
    }
}
