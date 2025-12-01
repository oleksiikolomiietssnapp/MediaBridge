import Foundation

extension Bool: @retroactive Comparable {
    public static func < (lhs: Bool, rhs: Bool) -> Bool {
        return lhs ? !rhs : rhs
    }
}
