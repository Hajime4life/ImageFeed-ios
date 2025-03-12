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
    

    
    // MARK: - Public Methods
    func fetchProfile(with token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastToken != token else {
            print("ProfileService Error - Invalid request: Duplicate token")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastToken = token
        guard let request = makeProfileResultRequest(with: token) else {
            print("Error - Invalid request: Failed to create request")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self else {
                    print("Error - Self is unavailable")
                    preconditionFailure("self is unavailable")
                }
                
                if let error = error {
                    print("Error - Network request failed: \(error)")
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    print("Error - Invalid response: No data received")
                    completion(.failure(AuthServiceError.invalidResponse))
                    return
                }
                
                do {
                    let profileResult = try JSONDecoder().decode(ProfileResult.self, from: data)
                    let profile = Profile(from: profileResult)
                    self.profile = profile
                    completion(.success(profile))
                } catch {
                    print("Error - Decoding failed: \(error)")
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
        guard let url = URL(string: Constants.unsplashGetProfileResultsURLString) else {
            assertionFailure("Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
