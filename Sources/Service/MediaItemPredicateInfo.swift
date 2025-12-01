import Foundation
import MediaPlayer

public enum MediaItemPredicateInfo: Sendable {
    case persistentID(UInt64)
    case mediaType(MPMediaType)
    case title(String)
    case albumTitle(String)
    case albumID(UInt64)
    case artist(String)
    case artistID(UInt64)
    case albumArtist(String)
    case albumArtistID(String)
    case genre(String)
    case genreID(UInt64)
    case composer(String)
    case composerID(UInt64)

    public func predicate(
        using comparisonType: MPMediaPredicateComparison = .equalTo
    ) -> MPMediaPropertyPredicate {
        MPMediaPropertyPredicate(
            value: value,
            forProperty: property,
            comparisonType: comparisonType
        )
    }

    public var description: String {
        "\(property)) with value `\(String(describing: value))`"
    }

    private var property: String {
        switch self {
        case .persistentID: MPMediaItemPropertyPersistentID
        case .mediaType: MPMediaItemPropertyMediaType
        case .title: MPMediaItemPropertyTitle

        case .albumTitle: MPMediaItemPropertyAlbumTitle
        case .albumID: MPMediaItemPropertyArtistPersistentID

        case .artist: MPMediaItemPropertyArtist
        case .artistID: MPMediaItemPropertyArtistPersistentID

        case .albumArtist: MPMediaItemPropertyAlbumArtist
        case .albumArtistID: MPMediaItemPropertyAlbumArtistPersistentID

        case .genre: MPMediaItemPropertyGenre
        case .genreID: MPMediaItemPropertyGenrePersistentID

        case .composer: MPMediaItemPropertyComposer
        case .composerID: MPMediaItemPropertyComposerPersistentID
        }
    }

    private var value: Any? {
        switch self {
        case .persistentID(let id): id
        case .mediaType(let type): type.rawValue
        case .title(let title): title

        case .albumTitle(let albumTitle): albumTitle
        case .albumID(let albumId): albumId

        case .artist(let artist): artist
        case .artistID(let artistId): artistId

        case .albumArtist(let albumArtist): albumArtist
        case .albumArtistID(let albumArtistId): albumArtistId

        case .genre(let genre): genre
        case .genreID(let genreId): genreId

        case .composer(let composer): composer
        case .composerID(let composerId): composerId
        }
    }

    private var predicateComparisonType: MPMediaPredicateComparison {
        switch self {
        case .persistentID, .title, .albumTitle, .albumArtist, .genre, .composer, .artist, .albumID, .artistID, .albumArtistID, .genreID,
            .composerID:
            .contains
        case .mediaType:
            .equalTo
        }
    }

}
