import Foundation

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    let unsplashGetProfileImageURLString: String
    let unsplashGetProfileResultsURLString: String
    let unsplashGetPhotosResultsURLString: String
    let unsplashGetTokenURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.authURLString = authURLString
        self.defaultBaseURL = defaultBaseURL
        
        let baseURLString = defaultBaseURL.absoluteString
        self.unsplashGetProfileImageURLString = "\(baseURLString)/users/"
        self.unsplashGetProfileResultsURLString = "\(baseURLString)/me"
        self.unsplashGetPhotosResultsURLString = "\(baseURLString)/photos"
        self.unsplashGetTokenURLString = "https://unsplash.com/oauth/token"
    }
    
    static var standard: AuthConfiguration { //haj ya| standard
        return AuthConfiguration(
            accessKey: "84rDmewcbI1p1KYaF42hCA9hnbrqHNlNpGLtV38EVtA",
            secretKey: "Jha29y4gzA018p1Qh2ejEuDiBXz3AfVi8bYCy9Y96aQ",
            redirectURI: "urn:ietf:wg:oauth:2.0:oob",
            accessScope: "public+read_user+write_likes",
            authURLString: "https://unsplash.com/oauth/authorize",
            defaultBaseURL: URL(string: "https://api.unsplash.com")!
        )
    }
    
    /// Новый, пытался обойти лимиты
    static var old: AuthConfiguration { //  ge n  | old
        return AuthConfiguration(
            accessKey: "mhhC-NKG1vJ6VVQRsGc5LqqZ9MBwMESBYORDp4RJ2WM",
            secretKey: "u8ioHFUsQ8HNCjh2C8n64j4vWFClCWcs15U8rjir2sQ",
            redirectURI: "urn:ietf:wg:oauth:2.0:oob",
            accessScope: "public+read_user+write_likes",
            authURLString: "https://unsplash.com/oauth/authorize",
            defaultBaseURL: URL(string: "https://api.unsplash.com")!
        )
    }
    
    /// Новый, пытался обойти лимиты
    static var alternative: AuthConfiguration { // h z | alternative
        return AuthConfiguration(
            accessKey: "RFR4QAr3pBOFn-ZmRg0EUPSPi-poE-YE2eRdrejWtrM",
            secretKey: "YDEbifXoGRayRLTYOad0-GClQX2-5HycpfzLLBVyt0s",
            redirectURI: "urn:ietf:wg:oauth:2.0:oob",
            accessScope: "public+read_user+write_likes",
            authURLString: "https://unsplash.com/oauth/authorize",
            defaultBaseURL: URL(string: "https://api.unsplash.com")!
        )
    }
    
    /// Новый, пытался обойти лимиты
    static var uitests: AuthConfiguration { // ger sys | uitests
        return AuthConfiguration(
            accessKey: "YdbtQiRJidnbScVVeQ0_2DJBTezsKO1nlBOzwGU6Kq0",
            secretKey: "uA56-Y3Y4x8eO-yoRs2jbECaOn4xSqDUqu0BBkEdkOs",
            redirectURI: "urn:ietf:wg:oauth:2.0:oob",
            accessScope: "public+read_user+write_likes",
            authURLString: "https://unsplash.com/oauth/authorize",
            defaultBaseURL: URL(string: "https://api.unsplash.com")!
        )
    }
}
