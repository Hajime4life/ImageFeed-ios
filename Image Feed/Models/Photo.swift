// Вот что у меня сейчас в итоге есть:

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}


struct UrlsResult: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct PhotoResult: Codable {
    let id: String
    let createdAt: String?
    let description: String?
    let urls: UrlsResult
    let likedByUser: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case description
        case urls
        case likedByUser = "liked_by_user"
    }
    
    var thumbImageURL: String {
        return urls.thumb
    }
    
    var largeImageURL: String {
        return urls.full
    }
    
    var isLiked: Bool {
        return likedByUser
    }
}

extension Photo {
    init?(from photoResult: PhotoResult) {
        let dateFormatter = ISO8601DateFormatter()
        guard let createdAt = dateFormatter.date(from: photoResult.createdAt ?? "") else {
            return nil
        }
        
        self.id = photoResult.id
        self.size = CGSize(width: 0, height: 0)
        self.createdAt = createdAt
        self.welcomeDescription = photoResult.description
        self.thumbImageURL = photoResult.thumbImageURL
        self.largeImageURL = photoResult.largeImageURL
        self.isLiked = photoResult.isLiked
    }
}

// // Декодируем фото, возвращаем массив фотографий
//func decodePhotos(from jsonData: Data) -> [Photo]? {
//    let decoder = JSONDecoder()
//    decoder.keyDecodingStrategy = .convertFromSnakeCase
//    decoder.dateDecodingStrategy = .iso8601
//    
//    do {
//        let photoResults = try decoder.decode([PhotoResult].self, from: jsonData)
//        let photos = photoResults.compactMap { Photo(from: $0) }
//        return photos
//    } catch {
//        print("Failed to decode JSON: \(error)")
//        return nil
//    }
//}

