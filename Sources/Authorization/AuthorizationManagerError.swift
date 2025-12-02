import Foundation

/// Errors that can occur during music library authorization.
///
/// These errors are thrown when authorization requests fail or are denied.
/// All cases conform to `LocalizedError` for user-friendly error messages.
public enum AuthorizationManagerError: Error, LocalizedError {
    /// The user denied access to the music library or authorization failed.
    ///
    /// The associated value contains the authorization status description
    /// for debugging purposes (e.g., "denied", "restricted", "notDetermined").
    ///
    /// ## Example
    /// ```swift
    /// do {
    ///     try await authManager.authorize()
    /// } catch AuthorizationManagerError.unauthorized(let status) {
    ///     print("Authorization failed with status: \(status)")
    /// }
    /// ```
    case unauthorized(String)

    /// A human-readable description of the error suitable for displaying to users.
    ///
    /// Returns a localized error message that can be shown in the UI.
    public var errorDescription: String? {
        switch self {
        case .unauthorized(let message):
            "Unauthorized with status: \(message)"
        }
    }
}

extension AuthorizationManagerError: Equatable {
    public static func == (lhs: AuthorizationManagerError, rhs: AuthorizationManagerError) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }
}
