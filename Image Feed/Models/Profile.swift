import Foundation

struct Profile {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    var loginName: String {
        "@" + username
    }
    var name: String? {
        if let firstName = firstName, let lastName = lastName {
            return firstName + " " + lastName
        }
        return nil
    }
    
    init(from result: ProfileResult) {
        self.username = result.username
        self.firstName = result.firstName
        self.lastName = result.lastName
        self.bio = result.bio
    }
}
