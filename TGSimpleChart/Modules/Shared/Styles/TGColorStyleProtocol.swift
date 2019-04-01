import UIKit

protocol TGColorStyleProtocol {
    var viewControllerBackground: UIColor { get }
    var contentBackground: UIColor { get }
    var contentSeparator: UIColor { get }
    var chartLabelText: UIColor { get }
    var changeStyleButtonTitle: UIColor { get }
    var chartOverviewBlurBackground: UIColor { get }
    var chartOverviewPullControllerBackground: UIColor { get }
    var chartOverviewFocusChartWindow: UIColor { get }
    var chartValueTitle: UIColor { get }
    var chartXLine: UIColor { get }
    var chartXValueLine: UIColor { get }
    var chartIndicatorLine: UIColor { get }
    var chartIndicatorInfoBackground: UIColor { get }
    var chartYGridLineBackground: UIColor { get }
    var chartPanelTitle: UIColor { get }
    var navigationBarBackground: UIColor { get }
    var navigationBarTitle: UIColor { get }
    var navigationShadowColor: UIColor { get }
    var statusBarAppearance: UIStatusBarStyle { get }
}

extension TGColorStyleProtocol {
    var checkMarkColor: UIColor { return .trueBlue }
    var chartOverviewFrameFocusArrow: UIColor { return .white }
}

struct TGColorDayStyle: TGColorStyleProtocol {
    var viewControllerBackground: UIColor { return .athensGray }
    
    var contentBackground: UIColor { return .romance }
    
    var contentSeparator: UIColor { return .lavenderGray }
    
    var chartLabelText: UIColor { return .black }
    
    var changeStyleButtonTitle: UIColor { return .trueBlue }
    
    var chartOverviewBlurBackground: UIColor { return .blackSqueeze }
    
    var chartOverviewPullControllerBackground: UIColor { return .mischka }
    
    var chartOverviewFocusChartWindow: UIColor { return .romance }
    
    var chartValueTitle: UIColor { return .manatee }
    
    var chartXLine: UIColor { return .zircon }
    
    var chartXValueLine: UIColor { return .concrete }
    
    var chartIndicatorLine: UIColor { return .geyser }
    
    var chartIndicatorInfoBackground: UIColor { return .antiFlashWhite }
    
    var chartPanelTitle: UIColor { return .dolphin }
    
    var navigationBarBackground: UIColor { return .white }
    
    var navigationBarTitle: UIColor { return .black }
    
    var navigationShadowColor: UIColor { return .bombay }
    
    var statusBarAppearance: UIStatusBarStyle { return .default }
    
    var chartYGridLineBackground: UIColor { return .concrete }
}

struct TGColorNightStyle: TGColorStyleProtocol {
    var viewControllerBackground: UIColor { return .blackPearl }
    
    var contentBackground: UIColor { return .midnight }
    
    var contentSeparator: UIColor { return .mirage }
    
    var chartLabelText: UIColor { return .romance }
    
    var changeStyleButtonTitle: UIColor { return .dodgerBlue }
    
    var chartOverviewBlurBackground: UIColor { return .tangaroa }
    
    var chartOverviewPullControllerBackground: UIColor { return .pickledBluewood }
    
    var chartOverviewFocusChartWindow: UIColor { return .midnight }
    
    var chartValueTitle: UIColor { return .nevada }
    
    var chartXLine: UIColor { return .mirage }
    
    var chartXValueLine: UIColor { return .mirage }
    
    var chartIndicatorLine: UIColor { return .mirage }
    
    var chartIndicatorInfoBackground: UIColor { return .midnightExpress }
    
    var chartPanelTitle: UIColor { return .darkElectricBlue }
    
    var navigationBarBackground: UIColor { return .midnight }
    
    var navigationBarTitle: UIColor { return .romance }
    
    var navigationShadowColor: UIColor { return .mirage }
    
    var statusBarAppearance: UIStatusBarStyle { return .lightContent }
    
    var chartYGridLineBackground: UIColor { return .blackPearl }
}
