import UIKit

enum TGFonts {
    static func light(ofSize size: CGFloat) -> UIFont { return UIFont.systemFont(ofSize: size, weight: .light) }
    
    static func regular(ofSize size: CGFloat) -> UIFont { return UIFont.systemFont(ofSize: size, weight: .regular) }
    
    static func bold(ofSize size: CGFloat) -> UIFont { return UIFont.systemFont(ofSize: size, weight: .bold) }
    
    static func medium(ofSize size: CGFloat) -> UIFont { return UIFont.systemFont(ofSize: size, weight: .medium) }
}
