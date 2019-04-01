import UIKit

extension UIColor {
    func as1ptImage() -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: 0.5, height: 0.5))
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        setFill()
        ctx.fill(CGRect(x: 0, y: 0, width: 0.5, height: 0.5))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
