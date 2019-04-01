import UIKit

class UIChartModel {
    private var allPoints: [Point<Double, Double>] = []
    var displayedPoints: [CGPoint] = []
    
    private var leftIndex: Int { return interval.leftIndex }
    private var rightIndex: Int { return interval.rightIndex }
    private var leftBound: Double
    private var rightBound: Double
    
    var modelUpdated: (() -> Void)?
    let color: UIColor
    let hex: String
    
    private(set) var isSelected: Bool = true
    
    private let width: Double
    private let height: Double
    
    private var maxY: Double
    private var minY: Double = 0
    
    private let interval: ChartIntervalIndexProtocol
    init(points: [Point<Double, Int>],
         interval: ChartIntervalIndexProtocol,
         color: String,
         width: Double,
         height: Double,
         maxY: Double) {
        self.interval = interval
        self.color = UIColor(hex: color)
        self.hex = color
        self.width = width
        self.height = height
        self.maxY = maxY
        let minX = points.first?.x ?? 0
        let maxX = points.last?.x ?? 0
        let range = maxX - minX
        self.allPoints = points.map { Point(x: $0.x, y: Double($0.y)) }
        self.displayedPoints = allPoints.map { (point) in
            CGPoint(x: (point.x - minX) / range * width, y: (1 - point.y / maxY) * height)
        }
        
        self.leftBound = minX
        self.rightBound = maxX
        
        updateDisplayPointsWithDefaultMultiplier()
    }
    
    func setSelectedState(_ isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    func updateExtremums(min: Double, max: Double, shouldRedraw: Bool = true) {
        self.minY = min
        self.maxY = max
        
        if shouldRedraw {
            updateDisplayedPoints()
        }
    }
    
    func update(leftBound: Double, rightBound: Double) {
        self.leftBound = leftBound
        self.rightBound = rightBound
        
        updateDisplayedPoints()
    }
    
    private func updateDisplayedPoints() {
        // may be recalculation neccessary
        updateDisplayPointsWithDefaultMultiplier()
        
        modelUpdated?()
    }
    
    func updateDisplayPointsWithDefaultMultiplier() {
        updateDisplayPoints(with: 1.25)
    }
    
    func point(by timeInterval: Double) -> Point<Double, Double> {
        var index = 0
        
        while index < allPoints.count {
            let point = allPoints[index]
            if point.x >= timeInterval {
                break
            }
            index += 1
        }
        let leftIndex = max(index - 1, 0)
        let rightIndex = min(index, allPoints.count)
        
        let lPoint = allPoints[leftIndex]
        let rPoint = allPoints[rightIndex]
        let part = (rPoint.x - timeInterval) / (rPoint.x - lPoint.x)
        let yVal = rPoint.y * (1 - part) + lPoint.y * part
        let xVal = timeInterval
        
        return Point(x: xVal, y: yVal)
    }
    
    func getStretchedValues(by multiplier: Double) -> [CGPoint] {
        let slice = Array(allPoints[leftIndex...rightIndex])
        let xMin = leftBound
        let xMax = rightBound
        let range = xMax - xMin
        let diff = maxY - minY
        
        return slice.map { (point) -> CGPoint in
            return CGPoint(x: (point.x - xMin) / range * width, y: (0.1 + (maxY - point.y) / (diff * multiplier)) * height)
        }
    }
    
    func updateDisplayPoints(with multiplier: Double) {
        let slice = Array(allPoints[max(leftIndex - 1, 0)...min(rightIndex + 1, allPoints.count - 1)])
        let xMin = leftBound
        let xMax = rightBound
        let range = xMax - xMin
        let diff = maxY - minY
        
        displayedPoints = slice.map { (point) -> CGPoint in
            return CGPoint(x: (point.x - xMin) / range * width, y: (0.1 + (maxY - point.y) / (diff * multiplier)) * height)
        }
    }
}
