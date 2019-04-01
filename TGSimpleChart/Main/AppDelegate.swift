import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private var coordinator: AppCoordinator!
}

extension AppDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Coordinator, window initialization
        let strongWindow = UIWindow(frame: UIScreen.main.bounds)
        self.window = strongWindow
        coordinator = AppCoordinator(window: strongWindow)
        coordinator.presentRootScreen()
        
        return true
    }
}
