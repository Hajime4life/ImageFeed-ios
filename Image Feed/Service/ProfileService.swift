import Foundation

final class ProfileService {
    
    // MARK: - Public Props
    static let shared = ProfileService()
    
    // MARK: - Private Props
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    private let storage = OAuth2TokenStorage()
    private(set) var profile: Profile?
    
    private enum AuthServiceError: Error {
        case invalidRequest
        case invalidResponse
    }
    
    private enum ProfileServiceConstants {
        static let unsplashGetProfileResultsURLString = "https://api.unsplash.com/me"
    }
    
    // MARK: - Public Methods
    func fetchProfile(with token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        // Проверяем, что запрос с таким же токеном уже не выполняется
        guard lastToken != token else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        // Отменяем предыдущий запрос, если он существует
        task?.cancel()
        lastToken = token
        
        guard let request = makeProfileResultRequest(with: token) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self else {
                    preconditionFailure("self is unavailable")
                }
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(AuthServiceError.invalidResponse))
                    return
                }
                
                do {
                    let profileResult = try JSONDecoder().decode(ProfileResult.self, from: data)
                    let profile = Profile(from: profileResult)
                    self.profile = profile
                    completion(.success(profile))
                } catch {
                    print("ProfileService Error - \(error)")
                    completion(.failure(error))
                }
                
                self.task = nil
                self.lastToken = nil
            }
        }
        
        self.task = task
        task.resume()
    }
    
    // MARK: - Private Methods
    private func makeProfileResultRequest(with token: String) -> URLRequest? {
        guard let url = URL(string: ProfileServiceConstants.unsplashGetProfileResultsURLString) else {
            assertionFailure("Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
