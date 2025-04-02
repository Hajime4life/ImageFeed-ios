import Foundation

struct PhotoResult: Codable {
    let id: String
    let createdAt: String?
    let description: String?
    let urls: UrlsResult
    let likedByUser: Bool?
    let width: CGFloat
    let height: CGFloat
    
    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case description
        case urls
        case likedByUser = "liked_by_user"
        case width
        case height
    }
    
    var thumbImageURL: String {
        return urls.thumb
    }
    
    var regularImageURL: String {
        return urls.regular
    }
    
    var largeImageURL: String {
        return urls.full
    }
    
    var isLiked: Bool {
        return likedByUser ?? false
    }
}

struct UrlsResult: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}
