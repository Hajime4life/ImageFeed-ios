import Foundation

final class ImagesListService {
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var isLoading = false
    private var currentTask: URLSessionTask? // Добавляем свойство для отслеживания текущей задачи
    private let storage = OAuth2TokenStorage()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    func fetchPhotosNextPage() {
        // Проверяем, что нет активной загрузки и текущей задачи
        guard !isLoading, currentTask == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        isLoading = true
        
        guard let token = storage.token else {
            assertionFailure("No token found")
            isLoading = false
            return
        }
        
        let urlString = "\(Constants.unsplashGetPhotosResultsURLString)?page=\(nextPage)&per_page=10&client_id=\(Constants.accessKey)"
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            defer {
                self.isLoading = false
                self.currentTask = nil
            }
            
            if let error = error {
                print("Ошибка загрузки: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .iso8601
                
                let photoResults = try decoder.decode([PhotoResult].self, from: data)
                
                let newPhotos = photoResults.compactMap { Photo(from: $0) }
                
                DispatchQueue.main.async {
                    // Фильтруем уникальные фотографии
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
                print("Ошибка декодирования: \(error.localizedDescription)")
            }
        }
        
        currentTask = task
        task.resume()
    }
}
