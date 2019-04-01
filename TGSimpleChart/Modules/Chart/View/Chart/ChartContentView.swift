import UIKit

class ChartContentView: UIView {
    private var style: TGColorStyleProtocol { return viewModel.style }
    
    private lazy var chartView = ChartView(viewModel: viewModel.chartViewModel)
    private var chartInfoView: ChartInfoView?
    private var chartInfoViewLeftConstraint: NSLayoutConstraint?
    
    private let viewModel: ChartContentViewModel
    init(viewModel: ChartContentViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        layer.masksToBounds = true
        clipsToBounds = true
        
        setViews()
        setupBindings()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBindings() {
        viewModel.drawInfoView = { [weak self] offset in
            guard let sSelf = self else { return }
            if sSelf.chartInfoView == nil {
                let view = ChartInfoView(viewModel: sSelf.viewModel.infoViewModel)
                sSelf.chartInfoView = view
                sSelf.addSubviews([view])
                
                let chartInfoViewLeftConstraint = view.leftAnchor.constraint(equalTo: sSelf.leftAnchor, constant: CGFloat(offset - 70))
                sSelf.chartInfoViewLeftConstraint = chartInfoViewLeftConstraint
                NSLayoutConstraint.activate([
                    view.topAnchor.constraint(equalTo: sSelf.topAnchor, constant: 10),
                    chartInfoViewLeftConstraint
                    ])
            } else {
                sSelf.chartInfoViewLeftConstraint?.constant = CGFloat(offset - 70)
            }
        }
        
        viewModel.removeInfoView = { [weak self] in
            guard let sSelf = self else { return }
            sSelf.chartInfoView?.removeFromSuperview()
            sSelf.chartInfoView = nil
            sSelf.chartInfoViewLeftConstraint = nil
        }
    }
    
    private func setViews() {
        addSubviews([chartView])
        
        NSLayoutConstraint.activate([
            chartView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            chartView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            chartView.topAnchor.constraint(equalTo: topAnchor),
            chartView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first
            else { return }
        
        let location = touch.location(in: self)
        viewModel.touchStarted(offsetX: Double(location.x))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        viewModel.touchMoved(offsetX: Double(location.x))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        viewModel.touchEnded()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        viewModel.touchEnded()
    }
}
