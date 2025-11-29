import MediaBridge
import MediaPlayer

final class MockMusicLibraryService: MusicLibraryServiceProtocol {
    enum MockError: Error {
        case mock
    }

    init(fetchSongError: MockError? = nil) {
        self.fetchSongError = fetchSongError
    }

    @MainActor
    var fetchSongError: MockError?
    func fetchSongs() async throws(MockError) -> [MPMediaItem] {
        guard let fetchSongError = await fetchSongError else {
            return []
        }
        throw fetchSongError
    }
}

extension MusicLibraryServiceProtocol where Self == MockMusicLibraryService, E == MockMusicLibraryService.MockError {
    static var mock: MockMusicLibraryService {
        MockMusicLibraryService()
    }
}
