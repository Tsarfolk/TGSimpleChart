import UIKit

protocol Stylable {
    var styleActions: [() -> Void] { get }
}

extension Stylable {
    func applyTheme() {
        styleActions.forEach { $0() }
    }
}

