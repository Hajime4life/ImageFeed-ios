import Foundation
import SwiftKeychainWrapper

// MARK: - ImageListServiceProtocol
protocol ImagesListServiceProtocol {
    var photos: [Photo] { get }
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void)
}

final class ImagesListService: ImagesListServiceProtocol {
    
    // MARK: - Private Props
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var isLoading = false
    private var currentTask: URLSessionTask?
    private let storage = OAuth2TokenStorage.shared
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    private let authConfig: AuthConfiguration
    
    // MARK: - Public Props
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // MARK: - Private Init's
    public init(authConfig: AuthConfiguration = .standard) {
        self.authConfig = authConfig
    }
    
    // MARK: - Public Methods
    func fetchPhotosNextPage() {
        guard !isLoading, currentTask == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        isLoading = true
        
        guard let token = storage.token else {
            assertionFailure("No token found")
            isLoading = false
            return
        }
        
        let urlString = "\(authConfig.unsplashGetPhotosResultsURLString)?page=\(nextPage)&per_page=10"
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            defer {
                self.isLoading = false
                self.currentTask = nil
            }
            
            if let error = error {
                print("Error - download: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                let photoResults = try self.jsonDecoder.decode([PhotoResult].self, from: data)
                
                let newPhotos = photoResults.compactMap { Photo(from: $0) }
                
                DispatchQueue.main.async {
                    let uniquePhotos = newPhotos.filter { newPhoto in
                        !self.photos.contains { $0.id == newPhoto.id }
                    }
                    
                    self.photos.append(contentsOf: uniquePhotos)
                    self.lastLoadedPage = nextPage
                    
                    NotificationCenter.default.post(
                        name: Self.didChangeNotification,
                        object: nil
                    )
                }
            } catch {
                print("Error - decode failed: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("JSON: \(jsonString)")
                }
                return
            }
        }
        
        currentTask = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !isLoading, currentTask == nil else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Request already in progress"])))
            return
        }
        
        guard let token = storage.token else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No token found"])))
            return
        }
        
        let urlString = "\(authConfig.unsplashGetPhotosResultsURLString)/\(photoId)/like"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            defer {
                self.isLoading = false
                self.currentTask = nil
            }
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                }
                return
            }
            
            DispatchQueue.main.async {
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        regularImageURL: photo.regularImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: isLike
                    )
                    self.photos[index] = newPhoto
                    completion(.success(()))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Photo not found"])))
                }
            }
        }
        
        currentTask = task
        task.resume()
    }
}
