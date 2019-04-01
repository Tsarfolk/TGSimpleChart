import Foundation

protocol ChartIntervalIndexProtocol {
    var leftIndex: Int { get }
    var rightIndex: Int { get }
}

class ChartWideIntervalModel: ChartIntervalIndexProtocol {
    let leftIndex: Int
    let rightIndex: Int
    
    init(xPoints: [Double]) {
        self.leftIndex = 0
        self.rightIndex = xPoints.count - 1
    }
}

class ChartIntervalModel: ChartIntervalIndexProtocol {
    let xPoints: [Double]
    
    var leftIndex: Int
    var rightIndex: Int
    
    var leftXBound: Double
    var rightXBound: Double
    
    var minX: Double { return xPoints.first ?? 0 }
    var maxX: Double { return xPoints.last ?? 0 }
    
    private var intSubscribers: [(ChartIntervalModelNotificationType<Int>) -> Void] = []
    private var doubleSubscribers: [(ChartIntervalModelNotificationType<Double>) -> Void] = []
    
    init(xPoints: [Double], leftBound: Double, rightBound: Double) {
        self.xPoints = xPoints
        self.leftXBound = leftBound
        self.rightXBound = rightBound
        
        var minL = 0, maxR = 0
        for i in (0..<xPoints.count) {
            let x = xPoints[i]
            if x <= leftBound {
                minL = i
            }
            if x <= rightBound {
                maxR = i
            }
        }
        
        leftIndex = minL
        rightIndex = maxR
    }
    
    func subscribeOnIndexChange(callback: @escaping (ChartIntervalModelNotificationType<Int>) -> Void) {
        intSubscribers.append { type in
            callback(type)
        }
    }
    
    func subscribeOnBoundsChange(callback: @escaping (ChartIntervalModelNotificationType<Double>) -> Void) {
        doubleSubscribers.append { type in
            callback(type)
        }
    }
    
    func changeLeftBound(leftXBound: Double) {
        setNewBoundAndIndexesWithNotification(newLeftBound: leftXBound, newRightBound: rightXBound)
    }
    
    func changeRightBound(rightXBound: Double) {
        setNewBoundAndIndexesWithNotification(newLeftBound: leftXBound, newRightBound: rightXBound)
    }
    
    func changeBounds(leftXBound: Double, rightXBound: Double) {
        setNewBoundAndIndexesWithNotification(newLeftBound: leftXBound, newRightBound: rightXBound)
    }
    
    private func setNewBoundAndIndexesWithNotification(newLeftBound: Double, newRightBound: Double) {
        let initialLeftIndex = leftIndex
        let initialRightIndex = rightIndex
        let initialLeftBound = leftXBound
        let initialRightBound = rightXBound
        
        setNewBoundAndIndexs(newLeftBound: newLeftBound, newRightBound: newRightBound)
        
        var intNotificationType: ChartIntervalModelNotificationType<Int>?
        var doubleNotificationType: ChartIntervalModelNotificationType<Double>?
        
        if initialLeftIndex != leftIndex && initialRightIndex != rightIndex {
            intNotificationType = .both(left: .left(oldValue: initialLeftIndex, newValue: leftIndex),
                                        right: .right(oldValue: initialRightIndex, newValue: rightIndex))
        } else if initialLeftIndex != leftIndex {
            intNotificationType = .left(oldValue: initialLeftIndex, newValue: leftIndex)
        } else if initialRightIndex != rightIndex {
            intNotificationType = .right(oldValue: initialRightIndex, newValue: rightIndex)
        }
        
        if initialLeftBound != leftXBound && initialRightBound != rightXBound {
            doubleNotificationType = .both(left: .left(oldValue: initialLeftBound, newValue: leftXBound),
                                           right: .right(oldValue: initialRightBound, newValue: rightXBound))
        } else if initialLeftBound != leftXBound {
            doubleNotificationType = .left(oldValue: initialLeftBound, newValue: leftXBound)
        } else if initialRightBound != rightXBound {
            doubleNotificationType = .right(oldValue: initialRightBound, newValue: rightXBound)
        }
        
        if let doubleNotificationType = doubleNotificationType {
            doubleSubscribers.forEach { $0(doubleNotificationType) }
        }
        if let intNotificationType = intNotificationType {
            intSubscribers.forEach { $0(intNotificationType) }
        }
    }
    
    private func setNewBoundAndIndexs(newLeftBound: Double, newRightBound: Double) {
        if newLeftBound != self.leftXBound {
            let addition: Int = newLeftBound > self.leftXBound ? 1 : -1
            let doubleAddition = Double(addition)
            var i: Int = leftIndex
            while 0..<xPoints.count~=i {
                if (xPoints[i] - newLeftBound) * doubleAddition >= 0 {
//                    leftIndex = max(i - 1, 0)
                    leftIndex = i
                    self.leftXBound = newLeftBound
                    break
                }
                i += addition
            }
        }
        
        if newRightBound != self.rightXBound {
            let addition = newRightBound > self.rightXBound ? 1 : -1
            let doubleAddition = Double(addition)
            var i = rightIndex
            while 0..<xPoints.count~=i {
                if (xPoints[i] - newRightBound) * doubleAddition >= 0 {
//                    rightIndex = min(i + 1, xPoints.count - 1) //min(i + 2, xPoints.count - 1)
                    rightIndex = i
                    self.rightXBound = newRightBound
                    break
                }
                i += addition
            }
        }
    }
}

indirect enum ChartIntervalModelNotificationType<T> {
    case left(oldValue: T, newValue: T)
    case right(oldValue: T, newValue: T)
    case both(left: ChartIntervalModelNotificationType, right: ChartIntervalModelNotificationType)
}
