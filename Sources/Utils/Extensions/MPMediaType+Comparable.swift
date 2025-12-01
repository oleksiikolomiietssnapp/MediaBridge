import Foundation
import MediaPlayer

extension MPMediaType: @retroactive Comparable {
    public static func < (lhs: MPMediaType, rhs: MPMediaType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
