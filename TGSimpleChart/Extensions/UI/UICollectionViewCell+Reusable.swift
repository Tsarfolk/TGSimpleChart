import UIKit

extension UICollectionReusableView {
    static var reusableId: String { return String(describing: self.self) }
    
    var reusableIdentifier: String { return type(of: self).reusableId }
}

extension UICollectionView {
    func register<T: UICollectionReusableView>(cellType: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.reusableId)
    }
    
    func dequeueReusableCell<T: UICollectionReusableView>(for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: T.reusableId, for: indexPath) as! T
    }
}
