import UIKit

/*
 supported operations:
 - add chart
 - remove chart
 - set line width
 */

class ChartContainerView: UIView, Stylable {
    internal var styleActions: [() -> Void] = []
    
    private let contentView = UIView()
    private lazy var chartView = ChartContentView(viewModel: self.viewModel.contentViewModel)
    private lazy var xAxisView = ChartXAxisValuesView(viewModel: self.viewModel.xAxisViewModel)
    private lazy var yGridView = ChartYGridView(viewModel: self.viewModel.yGridViewModel)
    private lazy var overviewView = ChartOverviewView(viewModel: self.viewModel.overviewViewModel)
    
    private lazy var horizontalInset: CGFloat = { return CGFloat(ChartContainerViewModel.leftInset) }()
    
    private let viewModel: ChartContainerViewModel
    init(viewModel: ChartContainerViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        setViews()
        
        styleActions.append { [weak self] in
            guard let sSelf = self else { return }
            sSelf.xAxisView.applyTheme()
            sSelf.yGridView.applyTheme()
            sSelf.overviewView.applyTheme()
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBindings() {
        
    }
    
    private func setViews() {
        addSubviews([contentView, overviewView])

        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor, constant: horizontalInset),
            contentView.rightAnchor.constraint(equalTo: rightAnchor, constant: -horizontalInset),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 475)
            ])
        
        overviewView.backgroundColor = .yellow
        NSLayoutConstraint.activate([
            overviewView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            overviewView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            overviewView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -19),
            overviewView.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 9)
            ])
        
        contentView.addSubviews([xAxisView, yGridView, chartView])
        
        NSLayoutConstraint.activate([
            xAxisView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            xAxisView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            xAxisView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            xAxisView.heightAnchor.constraint(equalToConstant: 39)
            ])
        
        NSLayoutConstraint.activate([
            yGridView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            yGridView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            yGridView.topAnchor.constraint(equalTo: contentView.topAnchor),
            yGridView.bottomAnchor.constraint(equalTo: xAxisView.topAnchor)
            ])
        
        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: contentView.topAnchor),
            chartView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            chartView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            chartView.bottomAnchor.constraint(equalTo: xAxisView.topAnchor)
            ])
    }
}
