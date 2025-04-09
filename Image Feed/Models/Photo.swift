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
        self.createdAt = DateParser.parseDate(from: photoResult.createdAt)
        
        guard photoResult.width > 0, photoResult.height > 0 else {
            return nil
        }
        
        self.id = photoResult.id
        self.size = CGSize(width: photoResult.width, height: photoResult.height)
        self.welcomeDescription = photoResult.description
        self.thumbImageURL = photoResult.urls.thumb
        self.regularImageURL = photoResult.urls.regular
        self.largeImageURL = photoResult.urls.full
        self.isLiked = photoResult.likedByUser ?? false
    }
}
