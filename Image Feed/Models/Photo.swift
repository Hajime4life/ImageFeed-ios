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
        if let createdAtString = photoResult.createdAt {
            let isoFormatter = ISO8601DateFormatter()
            let customFormatter = DateFormatter()
            customFormatter.dateFormat = "yyyy-MM-dd" // на всякий случай
            
            if let date = isoFormatter.date(from: createdAtString) {
                self.createdAt = date
            } else if let date = customFormatter.date(from: createdAtString) {
                self.createdAt = date
            } else {
                print("Не удалось распарсить дату: \(createdAtString)")
                self.createdAt = nil
            }
        } else {
            print("Дата отсутствует в ответе API: \(photoResult.id)")
            self.createdAt = nil
        }
        
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
