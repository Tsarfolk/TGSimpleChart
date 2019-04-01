import Foundation

struct ChartModel {
    let charts: [ChartItemData]
    let x: ChartItemData
    
    init?(json: [String: Any]) {
        guard let columns = json["columns"] as? [[Any]],
            let types = json["types"] as? [String: String],
            let colors = json["colors"] as? [String: String],
            let names = json["names"] as? [String: String]
            else { return nil }
        
        var charts: [ChartItemData] = []
        var x: ChartItemData?
        
        columns.forEach { (column) in
            guard let id = column[0] as? String,
                let type = types[id],
                let values = Array(column.dropFirst()) as? [Int]
                else { return }
            
            switch type {
            case "x":
                x = ChartItemData(color: "#FFFFFF", name: "x", values: values.map { $0 / 1000 })
            case "line":
                guard let color = colors[id],
                    let name = names[id] else { return }
                let item = ChartItemData(color: color, name: name, values: values)
                charts.append(item)
            default:
                return
            }
        }
        
        guard let xStrong = x else { return nil }
        
        self.x = xStrong
        self.charts = charts
    }
}
