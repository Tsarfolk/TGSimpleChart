import Foundation

class ValueScaleController {
    private let numberOfNecessaryTics: Double = 20
    private let ticDuration: TimeInterval = 0.01
    private var numberOfUTics: Double = 20
    private var numberOfLTics: Double = 20
    
    private var minY: Double = 0.0
    private var maxY: Double = 0.0
    private var goalMinY: Double = 0.0
    private var goalMaxY: Double = 0.0
    private var possibleRange: Double { return (maxY - minY) * 0.05 }
    private var possibleGoalRange: Double { return (goalMaxY - goalMinY) * 0.05 }
    private var possibleGoalMinCoridor: ClosedRange<Double> { return goalMinY - possibleGoalRange...goalMinY + possibleGoalRange }
    private var possibleGoalMaxCoridor: ClosedRange<Double> { return goalMaxY - possibleGoalRange...goalMaxY + possibleGoalRange }
    private var possibleMinCoridor: ClosedRange<Double> { return minY - possibleRange...minY + possibleRange }
    private var possibleMaxCoridor: ClosedRange<Double> { return maxY - possibleRange...maxY + possibleRange }
    
    var extremumBoundChanged: ((ClosedRange<Double>) -> Void)?
    var goalExtremumChanged: ((ClosedRange<Double>) -> Void)?
    var extremumChangedByVisibilityChangeCallback: ((Int, ClosedRange<Double>, Int, Bool) -> Void)?
    private var extremumCallBacks: [(Int, ClosedRange<Double>, Int, Bool) -> Void] = []
    
    private var lTimer: Timer?
    private var uTimer: Timer?
    
    weak var repository: ChartRepository? {
        didSet {
            minY = repository?.minY ?? 0
            maxY = repository?.maxY ?? 0
            goalMinY = minY
            goalMaxY = maxY
        }
    }
    
    init() {}
    
    func reviewExtremums() {
        let newMinY = repository?.minY ?? 0
        let newMaxY = repository?.maxY ?? 0
        
        if !(possibleMaxCoridor~=newMaxY) {
            uTimer?.invalidate()
            numberOfUTics = numberOfNecessaryTics
            let addition = (newMaxY - maxY) / numberOfUTics
            uTimer = Timer.scheduledTimer(timeInterval: ticDuration, target: self, selector: #selector(uTimerTic(_:)), userInfo: addition, repeats: true)
            uTimer?.fire()
        }
        
        if !(possibleMinCoridor~=newMinY) {
            lTimer?.invalidate()
            numberOfLTics = numberOfNecessaryTics
            let addition = (newMinY - minY) / numberOfLTics
            lTimer = Timer.scheduledTimer(timeInterval: ticDuration, target: self, selector: #selector(lTimerTic(_:)), userInfo: addition, repeats: true)
            lTimer?.fire()
        }
        
        notifyGoalExtremumChangedIfNeeded(newMaxY: newMaxY, newMinY: newMinY)
    }
    
    func subscribeOnExtremumChange(callBack: @escaping (Int, ClosedRange<Double>, Int, Bool) -> Void) {
        extremumCallBacks.append(callBack)
    }
    
    private func notifyExtremumChanged(direction: Int, range: ClosedRange<Double>, index: Int, isVisible: Bool) {
        extremumCallBacks.forEach { $0(direction, range, index, isVisible) }
    }
    
    func reviewExremumChangeOnVisibilityChange(index: Int, isVisibled: Bool) {
        let newMinY = repository?.minY ?? 0
        let newMaxY = repository?.maxY ?? 0
        
        var direction: Int = 1
        if maxY > newMaxY {
            direction = 1
        } else if maxY < newMaxY {
            direction = -1
        } else if minY > newMinY {
            direction = 1
        } else if minY < newMinY {
            direction = -1
        } else {
            direction = 1
        }
        if !(possibleMaxCoridor~=newMaxY) || !(possibleMinCoridor~=newMinY) {
            notifyExtremumChanged(direction: direction, range: newMinY...newMaxY, index: index, isVisible: isVisibled)
            minY = newMinY
            maxY = newMaxY
            goalMinY = newMinY
            goalMaxY = newMaxY
            goalExtremumChanged?(goalMinY...goalMaxY)
        } else {
            notifyExtremumChanged(direction: direction, range: newMinY...newMaxY, index: index, isVisible: isVisibled)
        }
    }
    
    @objc
    private func lTimerTic(_ timer: Timer) {
        guard let value = timer.userInfo as? Double, numberOfLTics > 0 else {
            goalMinY = minY
            lTimer?.invalidate()
            return
        }
        minY += value
        numberOfLTics -= 1
        extremumBoundChanged?(minY...maxY)
    }
    
    @objc
    private func uTimerTic(_ timer: Timer) {
        guard let value = timer.userInfo as? Double, numberOfUTics > 0 else {
            goalMaxY = maxY
            uTimer?.invalidate()
            return
        }
        
        maxY += value
        numberOfUTics -= 1
        extremumBoundChanged?(minY...maxY)
    }
    
    private func notifyGoalExtremumChangedIfNeeded(newMaxY: Double, newMinY: Double) {
        var goalChanged: Bool = false
        if !(possibleGoalMinCoridor~=newMinY) {
            goalMinY = newMinY
            goalChanged = true
        }
        
        if !(possibleGoalMaxCoridor~=newMaxY) {
            goalMaxY = newMaxY
            goalChanged = true
        }
        
        if goalChanged {
            goalExtremumChanged?(goalMinY...goalMaxY)
        }
    }
}
