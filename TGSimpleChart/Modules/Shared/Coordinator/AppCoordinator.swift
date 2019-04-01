import UIKit

class AppCoordinator {
    private let styleController = TGStyleController()
    
    private let window: UIWindow
    init(window: UIWindow) {
        self.window = window
    }
    
    func presentRootScreen() {
        let viewModel = ChartPanelViewModel(styleController: styleController)
        let controller = ChartPanelViewController(viewModel: viewModel)
        let navigation = UINavigationController(rootViewController: controller)
        window.rootViewController = navigation
        window.makeKeyAndVisible()
    }
}
