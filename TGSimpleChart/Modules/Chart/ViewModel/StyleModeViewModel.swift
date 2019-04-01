import Foundation

class StyleModeViewModel {
    var title: String {
        switch styleMode {
        case .day:
            return "Switch to Night Mode"
        case .night:
            return "Switch to Day Mode"
        }
    }
    var style: TGColorStyleProtocol { return styleController.style }
    private var styleMode: TGStyleController.Mode { return styleController.mode }
    
    private let styleController: TGStyleController
    init(styleController: TGStyleController) {
        self.styleController = styleController
    }
    
    var shouldAddTitleStyleAction: Bool = true
    
    func titleActionStileAdded() {
        shouldAddTitleStyleAction = false
    }
    
    func toggleStyleController() {
        styleController.toggleMode()
    }
}
