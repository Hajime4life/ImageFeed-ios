import Foundation

final class ImagesListService {
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var isLoading = false
    private let storage = OAuth2TokenStorage()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // Метод для загрузки следующей страницы
    func fetchPhotosNextPage() {
        guard !isLoading else { return } // Если загрузка уже идет - выходим
        

        let nextPage = (lastLoadedPage ?? 0) + 1
        isLoading = true
        
        guard let token = storage.token else {
            assertionFailure("No token found")
            isLoading = false
            return
        }
        
        let urlString = "\(Constants.unsplashGetPhotosResultsURLString)?page=\(nextPage)&per_page=10&client_id=\(Constants.accessKey)"
        guard let url = URL(string: urlString) else {
            print("Некорректный url")
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            defer { self.isLoading = false }
            
            if let error = error {
                print(error)
                return
            }
            
            guard let data = data else {
                print("Пустая дата")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .iso8601
                
                let photoResults = try decoder.decode([PhotoResult].self, from: data)
                let newPhotos = photoResults.compactMap { Photo(from: $0) }
                
                // Обновляем массив photos
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    
                    // Отправляем нотификацию
                    NotificationCenter.default.post(name: Self.didChangeNotification, object: nil)
                }
            } catch {
                print("Не удалось декодировать, \(error)")
            }
        }
        
        task.resume()
    }
}
