import UIKit

/*
 TODO:
 1. Map UNIX -> date
 2. Progressive date: scale -> [Title, Visibility] (1..<n). So that I can stop scale and dates will stay blured. Strictly defined state
 3.
 
 Make fixed step to reduce number of redrawings
 The question of scaling graphic is still open (when different time interval is picked)
 
 */

class ChartPanelViewController: UIViewController, Stylable {
    internal var styleActions: [() -> Void] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private var dataSource: [Int: [ChartPanelListItemType]] { return viewModel.dataSource }
    private var style: TGColorStyleProtocol { return viewModel.style }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return style.statusBarAppearance }
    
    private let viewModel: ChartPanelViewModel
    init(viewModel: ChartPanelViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Statistics"
        
        setViewStyle()
        setViews()
        setupBindings()
        
        viewModel.parseChartData(width: Double(view.frame.width))
    }
    
    private func setViewStyle() {
        navigationController?.navigationBar.isTranslucent = false
        
        styleActions.append { [weak self] in
            guard let sSelf = self else { return }
            sSelf.view.backgroundColor = sSelf.style.viewControllerBackground
            sSelf.collectionView.backgroundColor = sSelf.style.viewControllerBackground
            sSelf.navigationController?.navigationBar.barTintColor = sSelf.style.navigationBarBackground
            sSelf.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: sSelf.style.navigationBarTitle]
            sSelf.navigationController?.navigationBar.shadowImage = sSelf.style.navigationShadowColor.as1ptImage()
            sSelf.setNeedsStatusBarAppearanceUpdate()
        }
        applyTheme()
    }
    
    private func setupBindings() {
        viewModel.chartDataUpdated = { [weak self] in
            guard let sSelf = self else { return }
            
            sSelf.collectionView.reloadData()
        }
        
        viewModel.styleChanged = { [weak self] in
            guard let sSelf = self else { return }
            
            sSelf.applyThemeForStylable(view: sSelf.view)
            sSelf.applyTheme()
        }
        
        viewModel.disableScrollingCallback = { [weak self] isScrollEnabled in
            guard let sSelf = self else { return }
            sSelf.collectionView.isScrollEnabled = isScrollEnabled
        }
    }
    
    func applyThemeForStylable(view: UIView) {
        let subviews = view.subviews
        
        for view in subviews {
            if let stylable = view as? Stylable {
                stylable.applyTheme()
            }
            
            applyThemeForStylable(view: view)
        }
    }
    
    private func setViews() {
        view.addSubviews([collectionView])
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellType: ChartPanelTitleCell.self)
        collectionView.register(cellType: ChartContainerViewCell.self)
        collectionView.register(cellType: ChartLabelCell.self)
        collectionView.register(cellType: StyleModeCell.self)
        collectionView.register(cellType: ChartPanelEmtyCell.self)
        collectionView.contentInset = UIEdgeInsets(top: 35, left: 0, bottom: 100, right: 0)
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
    
    private func getItem(for indexPath: IndexPath) -> ChartPanelListItemType {
        let index = indexPath.row
        let section = indexPath.section
        
        guard let items = dataSource[section] else { fatalError() }
        return items[index]
    }
}

extension ChartPanelViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewSize = collectionView.frame.size
        let item = getItem(for: indexPath)
        switch item {
        case .title:
            return CGSize(width: collectionViewSize.width, height: 30)
        case .chart:
            return CGSize(width: collectionViewSize.width, height: 373)
        case .label:
            return CGSize(width: collectionViewSize.width, height: 50)
        case .styleMode:
            return CGSize(width: collectionViewSize.width, height: 46)
        case .emptyCell(let height):
            return CGSize(width: collectionViewSize.width, height: CGFloat(height))
        }
    }
}

extension ChartPanelViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource[section]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = getItem(for: indexPath)
        switch item {
        case .title(let viewModel):
            let cell: ChartPanelTitleCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configure(viewModel: viewModel)
            return cell
        case .chart(let viewModel):
            let cell: ChartContainerViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configure(viewModel: viewModel)
            return cell
        case .label(let viewModel):
            let cell: ChartLabelCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configure(viewModel: viewModel)
            return cell
        case .styleMode(let viewModel):
            let cell: StyleModeCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configure(viewModel: viewModel)
            return cell
        case .emptyCell:
            let cell: ChartPanelEmtyCell = collectionView.dequeueReusableCell(for: indexPath)
            return cell
        }
    }
}
