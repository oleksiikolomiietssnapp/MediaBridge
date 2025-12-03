import MediaPlayer

@testable import MediaBridge

class MockMediaQueryWithTwoItems: MediaQueryProtocol {
    var items: [MPMediaItem]?
    var groupingType: MPMediaGrouping

    required init(filterPredicates: Set<MPMediaPredicate>? = nil) {
        items = [.mock, .mock]
        groupingType = .title
    }
}

class MockMediaQueryWithNoItems: MediaQueryProtocol {
    var items: [MPMediaItem]?
    var groupingType: MPMediaGrouping

    required init(filterPredicates: Set<MPMediaPredicate>? = nil) {
        items = []
        groupingType = .title
    }
}

class MockMediaQueryWithNilItems: MediaQueryProtocol {
    var items: [MPMediaItem]?
    var groupingType: MPMediaGrouping

    required init(filterPredicates: Set<MPMediaPredicate>? = nil) {
        items = nil
        groupingType = .title
    }
}
