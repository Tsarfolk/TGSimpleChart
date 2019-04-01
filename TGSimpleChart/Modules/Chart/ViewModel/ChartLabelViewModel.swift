import Foundation

class ChartLabelViewModel {
    private let data: ChartItemData
    private var isLast: Bool = false
    var style: TGColorStyleProtocol { return styleController.style }
    private let styleController: TGStyleController
    
    var colorHex: String { return data.color }
    var title: String { return data.name }
    var isSeparatorEdgeToEdge: Bool { return isLast }
    private(set) var isSelected: Bool = true {
        didSet {
            updateSelectedState?()
        }
    }
    
    var chartLabelDidChangeState: (() -> Void)?
    var updateSelectedState: (() -> Void)?
    
    init(data: ChartItemData,
         styleController: TGStyleController) {
        self.data = data
        self.styleController = styleController
    }
    
    func setIsLast() {
        isLast = true
    }
    
    func setSelectedState(_ isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    func didTouch() {
        chartLabelDidChangeState?()
    }
}
