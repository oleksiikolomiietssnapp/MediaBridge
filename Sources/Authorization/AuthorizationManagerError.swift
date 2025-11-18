import Foundation

public enum AuthorizationManagerError: Error, LocalizedError {
    case unauthorized(String)

    public var errorDescription: String? {
        switch self {
        case .unauthorized(let message):
            "Unauthorized with status: \(message)"
        }
    }
}
