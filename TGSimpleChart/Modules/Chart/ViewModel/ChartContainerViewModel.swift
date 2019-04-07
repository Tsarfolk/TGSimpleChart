import Foundation

class ChartContainerViewModel {
    let contentViewModel: ChartContentViewModel
    let yGridViewModel: ChartYGridViewModel
    let xAxisViewModel: ChartXAxisValuesViewModel
    let overviewViewModel: ChartOverviewViewModel
    var style: TGColorStyleProtocol { return styleController.style }
    private let styleController: TGStyleController
    
    static let leftInset: Double = 16
    
    init(contentViewModel: ChartContentViewModel,
         yGridViewModel: ChartYGridViewModel,
         xAxisViewModel: ChartXAxisValuesViewModel,
         overviewViewModel: ChartOverviewViewModel,
         styleController: TGStyleController) {
        self.contentViewModel = contentViewModel
        self.yGridViewModel = yGridViewModel
        self.xAxisViewModel = xAxisViewModel
        self.overviewViewModel = overviewViewModel
        self.styleController = styleController
    }
}
