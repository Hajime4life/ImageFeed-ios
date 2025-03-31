import Foundation

enum Constants {
    static let accessKey = "RFR4QAr3pBOFn-ZmRg0EUPSPi-poE-YE2eRdrejWtrM"
    static let secretKey = "YDEbifXoGRayRLTYOad0-GClQX2-5HycpfzLLBVyt0s"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL: URL = defaultBaseURLgetter
    static private var defaultBaseURLgetter: URL {
        guard let url = URL(string: "https://api.unsplash.com") else {preconditionFailure("Unable to construct unsplashUrl")}
        return url
    }
    static let unsplashGetProfileImageURLString = "https://api.unsplash.com/users/"
    static let unsplashGetProfileResultsURLString = "https://api.unsplash.com/me"
    static let unsplashGetPhotosResultsURLString = "https://api.unsplash.com/photos"
    
}
