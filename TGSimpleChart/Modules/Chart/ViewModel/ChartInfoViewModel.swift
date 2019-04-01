import Foundation

class ChartInfoViewModel {
    var valueStrings: [(String, String)] = []
    var dateString: String = ""
    var yearStrign: String = ""
    private let styleController: TGStyleController
    var style: TGColorStyleProtocol { return styleController.style }
    
    var modelUpdated: (() -> Void)?
    
    func updateModel() {
        modelUpdated?()
    }
    
    init(styleController: TGStyleController) {
        self.styleController = styleController
    }
}
