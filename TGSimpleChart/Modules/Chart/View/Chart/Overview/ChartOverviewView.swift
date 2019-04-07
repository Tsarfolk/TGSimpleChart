import UIKit

class ChartOverviewView: UIView, Stylable {
    internal var styleActions: [() -> Void] = []
    
    private let focusOverlayVerticalInsets: CGFloat = 3.5
    private let focusOvalViewHorizontalWidth: CGFloat = 10.6
    
    private lazy var chartFocusView = UIView()
    //    private let leftControllerView:
    
    //    1. focusView
    private let focusOvalView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 3
        return view
    }()
    //    2. backgroundView
    private let backgroundView = UIView()
    //    3.
    private let focusChartWindowView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()
    private let leftFocusBlurView = UIView()
    private let rightFocusBlurView = UIView()
    //    4. ChartView
    private lazy var chartView = ChartView(viewModel: viewModel.chartViewModel)
    //  5. chart blures
    private let leftBlurView = UIView()
    private let rightBlurView = UIView()
    //    6.
    private lazy var focusFrameView = ChartPullControllersView(horizontalBorderWidth: self.focusOvalViewHorizontalWidth, style: self.style)
    private var leftConstraint: NSLayoutConstraint?
    private var widthConstraint: NSLayoutConstraint?
    
    
    private var style: TGColorStyleProtocol { return viewModel.style }
    private let viewModel: ChartOverviewViewModel
    init(viewModel: ChartOverviewViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        styleActions.append { [weak self] in
            guard let sSelf = self else { return }
            
            let style = sSelf.style
            
            sSelf.focusOvalView.backgroundColor = style.chartOverviewPullControllerBackground
            sSelf.backgroundView.backgroundColor = style.chartOverviewBlurBackground
            sSelf.focusChartWindowView.backgroundColor = style.chartOverviewFocusChartWindow
            sSelf.leftFocusBlurView.backgroundColor = style.chartOverviewPullControllerBackground
            sSelf.rightFocusBlurView.backgroundColor = style.chartOverviewPullControllerBackground
            sSelf.leftBlurView.backgroundColor = style.chartOverviewBlurBackground.withAlphaComponent(0.5)
            sSelf.rightBlurView.backgroundColor = style.chartOverviewBlurBackground.withAlphaComponent(0.5)
        }
        
        setViews()
        applyTheme()
        updateFocusViewPosition()
        setupBindings()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setViews() {
        addSubviews([
            focusOvalView,
            backgroundView
            ])
        
        let leftConstraint = focusOvalView.leftAnchor.constraint(equalTo: leftAnchor)
        let widthConstraint = focusOvalView.widthAnchor.constraint(equalToConstant: CGFloat(viewModel.currentFocusWindowWidth))
        self.leftConstraint = leftConstraint
        self.widthConstraint = widthConstraint
        NSLayoutConstraint.activate([
            leftConstraint,
            widthConstraint,
            focusOvalView.topAnchor.constraint(equalTo: topAnchor, constant: -focusOverlayVerticalInsets),
            focusOvalView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: focusOverlayVerticalInsets)
            ])
        
        NSLayoutConstraint.activate([
            backgroundView.leftAnchor.constraint(equalTo: leftAnchor),
            backgroundView.rightAnchor.constraint(equalTo: rightAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        
        addSubviews([focusChartWindowView])
        
        NSLayoutConstraint.activate([
            focusChartWindowView.centerXAnchor.constraint(equalTo: focusOvalView.centerXAnchor),
            focusChartWindowView.centerYAnchor.constraint(equalTo: focusOvalView.centerYAnchor),
            focusChartWindowView.widthAnchor.constraint(equalTo: focusOvalView.widthAnchor, constant: -focusOvalViewHorizontalWidth * 2),
            focusChartWindowView.heightAnchor.constraint(equalTo: focusOvalView.heightAnchor, constant: -2 * 2)
            ])
        
        addSubviews([
            leftFocusBlurView, rightFocusBlurView,
            chartView,
            leftBlurView, rightBlurView,
            focusFrameView
            ])
        
        NSLayoutConstraint.activate([
            leftFocusBlurView.leftAnchor.constraint(equalTo: focusOvalView.leftAnchor),
            leftFocusBlurView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            leftFocusBlurView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            leftFocusBlurView.widthAnchor.constraint(equalToConstant: focusOvalViewHorizontalWidth)
            ])
        
        NSLayoutConstraint.activate([
            rightFocusBlurView.rightAnchor.constraint(equalTo: focusOvalView.rightAnchor),
            rightFocusBlurView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            rightFocusBlurView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            rightFocusBlurView.widthAnchor.constraint(equalToConstant: focusOvalViewHorizontalWidth)
            ])

        NSLayoutConstraint.activate([
            chartView.leftAnchor.constraint(equalTo: backgroundView.leftAnchor),
            chartView.rightAnchor.constraint(equalTo: backgroundView.rightAnchor),
            chartView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            chartView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor)
            ])
        
        NSLayoutConstraint.activate([
            leftBlurView.leftAnchor.constraint(equalTo: backgroundView.leftAnchor),
            leftBlurView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            leftBlurView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            leftBlurView.rightAnchor.constraint(equalTo: focusOvalView.leftAnchor)
            ])

        NSLayoutConstraint.activate([
            rightBlurView.rightAnchor.constraint(equalTo: backgroundView.rightAnchor),
            rightBlurView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            rightBlurView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
            rightBlurView.leftAnchor.constraint(equalTo: focusOvalView.rightAnchor)
            ])
        
        focusFrameView.delegate = self
        NSLayoutConstraint.activate([
            focusFrameView.leftAnchor.constraint(equalTo: focusOvalView.leftAnchor),
            focusFrameView.rightAnchor.constraint(equalTo: focusOvalView.rightAnchor),
            focusFrameView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            focusFrameView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor)
            ])
    }
    
    private func setupBindings() {
        viewModel.xActiveBoundChanged = { [weak self] in
            guard let sSelf = self else { return }
            
            sSelf.updateFocusViewPosition()
        }
    }
    
    private func updateFocusViewPosition() {
        let lowerBound = viewModel.viewXActiveBound.lowerBound
        let upperBound = viewModel.viewXActiveBound.upperBound
        widthConstraint?.constant = CGFloat(upperBound - lowerBound)
        leftConstraint?.constant = CGFloat(lowerBound)
    }
}

extension ChartOverviewView: ChartPullControllersViewDelegate {
    func touchesBegan(by touch: UITouch, for pullType: ChartPullControllerType) {
        let location = touch.location(in: backgroundView)
        viewModel.beginMove(at: Double(location.x), with: pullType)
    }
    
    func touchesMoved(by touch: UITouch) {
        let location = touch.location(in: backgroundView)
        viewModel.move(by: Double(location.x))
    }
    
    func touchesEnded() {
        viewModel.moveEnded()
    }
}
