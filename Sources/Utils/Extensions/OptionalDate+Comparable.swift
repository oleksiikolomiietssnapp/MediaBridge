import Foundation

extension Optional: @retroactive Comparable where Wrapped == Date {
    public static func < (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
        guard let lhs = lhs, let rhs = rhs else {
            return false
        }

        return lhs < rhs
    }
}
