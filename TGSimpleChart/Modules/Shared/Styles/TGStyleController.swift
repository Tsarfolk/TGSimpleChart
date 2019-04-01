import Foundation

class TGStyleController {
    enum Mode: Int {
        case day = 1
        case night
    }
    
    private(set) var mode: Mode = .day {
        didSet {
            switch mode {
            case .day:
                style = TGColorDayStyle()
            case .night:
                style = TGColorNightStyle()
            }
            
            styleChanged?()
        }
    }
    private(set) var style: TGColorStyleProtocol = TGColorDayStyle()
//    private(set) var style: TGColorStyleProtocol = TGColorNightStyle()
    
    var styleChanged: (() -> Void)?
    
    func toggleMode() {
        switch mode {
        case .day:
            mode = .night
        case .night:
            mode = .day
        }
    }
}
