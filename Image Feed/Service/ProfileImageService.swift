import Foundation

final class ProfileImageService {
    
    // MARK: - Public Props
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    // MARK: - Private Props
    private let urlSession = URLSession.shared
    private var task: URLSessionTask? 
    private let storage = OAuth2TokenStorage()
    private let decoder = SnakeCaseJSONDecoder()
    private(set) var avatarURL: String?
    private enum AuthServiceError: Error {
        case invalidRequest
    }

    // MARK: - Public Methods
    func fetchImageURL(with username: String, completion: @escaping (Result<String, any Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        guard let request = makeProfileResultRequest(username: username) else {
            print("Error - Invalid request: Failed to create request")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else {
                print("Error - Self is unavailable")
                preconditionFailure("self is unavailable")
            }
            switch result {
            case .success(let userResult):
                guard let imageURL = userResult.profileImage.large else {
                    print("Error - Invalid response: Missing image URL")
                    preconditionFailure("cant get image URL")
                }
                self.avatarURL = imageURL
                completion(.success(imageURL))
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": imageURL]
                )
            case .failure(let error):
                print("Error - Network request failed: \(error)")
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    func makeProfileResultRequest(username: String) -> URLRequest? {
        guard let url = URL(string: Constants.unsplashGetProfileImageURLString + username) else {
            assertionFailure("Cant make URL")
            return nil
        }
        
        guard let token = storage.token else {
            assertionFailure("No token")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
