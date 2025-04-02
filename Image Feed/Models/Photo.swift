import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date? 
    let welcomeDescription: String?
    let thumbImageURL: String
    let regularImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

extension Photo {
    init?(from photoResult: PhotoResult) {
        let dateFormatter = ISO8601DateFormatter()
        
        if let createdAtString = photoResult.createdAt,
           let createdAt = dateFormatter.date(from: createdAtString) {
            self.createdAt = createdAt
        } else {
            self.createdAt = nil
        }
        
        guard photoResult.width > 0, photoResult.height > 0 else {
            return nil
        }
        
        self.id = photoResult.id
        self.size = CGSize(width: photoResult.width, height: photoResult.height)
        self.welcomeDescription = photoResult.description
        self.thumbImageURL = photoResult.thumbImageURL
        self.regularImageURL = photoResult.regularImageURL
        self.largeImageURL = photoResult.largeImageURL
        self.isLiked = photoResult.isLiked
    }
}
