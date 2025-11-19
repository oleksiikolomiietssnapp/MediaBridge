import Foundation
import OSLog

let log: Logger = Logger()

final class Logger: Sendable {
    func debug(_ message: StaticString, args: any CVarArg...) {
        os_log(message, log: OSLog.default, type: .debug, args)
    }

    func error(_ message: StaticString, args: any CVarArg...) {
        os_log(message, log: OSLog.default, type: .error, args)
    }

    func error(_ error: Error) {
        os_log("%@", log: OSLog.default, type: .error, error.localizedDescription)
    }

    func info(_ message: StaticString, args: any CVarArg...) {
        os_log(message, log: OSLog.default, type: .info, args)
    }

    func warning(_ message: StaticString, args: any CVarArg...) {
        os_log(message, log: OSLog.default, type: .fault, args)
    }
}
