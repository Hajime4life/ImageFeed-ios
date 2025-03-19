import Foundation

struct ProfileImage: Codable {
  let small: String?
  let medium: String?
  let large: String?
}

struct UserResult: Decodable {
    let profileImage: ProfileImage
}
