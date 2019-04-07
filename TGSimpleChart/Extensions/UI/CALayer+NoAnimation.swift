import UIKit

extension CALayer {
    class func perform(withDuration duration: Double, actions: () -> Void) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        actions()
        CATransaction.commit()
    }
}
