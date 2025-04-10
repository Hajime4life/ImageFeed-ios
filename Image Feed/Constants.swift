import Foundation

enum Constants {
    
    // MARK: - Private Props
    static private var defaultBaseURLgetter: URL {
        guard let url = URL(string: "https://api.unsplash.com") else {preconditionFailure("Unable to construct unsplashUrl")}
        return url
    }
    static private let unsplashBaseURLString = "https://api.unsplash.com"

    // MARK: - Public Props
//    static let accessKey = "84rDmewcbI1p1KYaF42hCA9hnbrqHNlNpGLtV38EVtA"
//    static let secretKey = "Jha29y4gzA018p1Qh2ejEuDiBXz3AfVi8bYCy9Y96aQ"
//    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
//    static let accessScope = "public+read_user+write_likes"

/// Старый акк, закончились лимиты
    static let accessKey = "RFR4QAr3pBOFn-ZmRg0EUPSPi-poE-YE2eRdrejWtrM"
    static let secretKey = "YDEbifXoGRayRLTYOad0-GClQX2-5HycpfzLLBVyt0s"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    static let defaultBaseURL: URL = defaultBaseURLgetter

    static let unsplashGetProfileImageURLString = "\(unsplashBaseURLString)/users/"
    static let unsplashGetProfileResultsURLString = "\(unsplashBaseURLString)/me"
    static let unsplashGetPhotosResultsURLString = "\(unsplashBaseURLString)/photos"
    
}
