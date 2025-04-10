import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    
    private init() {}
    
    var token: String? {
        get {
            let token: String? = KeychainWrapper.standard.string(forKey: Keys.token.rawValue)
            return token
        }
        set {
            if let token = newValue {
                let isSuccess = KeychainWrapper.standard.set(token, forKey: Keys.token.rawValue)
                guard isSuccess else { preconditionFailure("Token not saved") }
            } else {
                clearToken()
            }
        }
    }
    
    func clearToken() {
        KeychainWrapper.standard.removeObject(forKey: Keys.token.rawValue)
    }
    
    private enum Keys: String {
        case token = "Auth token"
    }
}
