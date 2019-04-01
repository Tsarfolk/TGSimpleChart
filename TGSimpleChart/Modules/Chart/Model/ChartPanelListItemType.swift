import Foundation

enum ChartPanelListItemType {
    case title(viewModel: ChartPanelTitleViewModel)
    case chart(viewModel: ChartContainerViewModel)
    case label(viewModel: ChartLabelViewModel)
    case styleMode(viewModel: StyleModeViewModel)
    case emptyCell(height: Double)
}
