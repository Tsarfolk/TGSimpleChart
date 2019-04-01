import Foundation

class Logger {
    enum LogType {
        case info
        case debug
        case error
    }
    
    func log(type: LogType, message: Any, file: String = #file, line: Int = #line, function: String = #function) {
        var firstSign: String = ""
        switch type {
        case .debug:
            firstSign = "💚"
        case .error:
            firstSign = "❤️"
        case .info:
            firstSign = "💙"
        }
        
        DispatchQueue.main.async {
            print("\(function):\(line) \(firstSign): \(message)")
        }
    }
}
