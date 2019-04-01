import Foundation

class ChartPanelTitleViewModel {
    var title: String = ""
    var style: TGColorStyleProtocol { return styleController.style }
    private let styleController: TGStyleController
    
    init(chartModel: ChartModel, styleController: TGStyleController) {
        self.styleController = styleController
        title = chartModel.charts.map { $0.name }.joined(separator: " | ")
    }
}
