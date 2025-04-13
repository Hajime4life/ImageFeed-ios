import Foundation

final class ImagesListPresenter: ImagesListPresenterProtocol {
    // MARK: - Public Props
    weak var view: ImagesListViewControllerProtocol?
    
    // MARK: - Private Props
    private let imagesListService: ImagesListServiceProtocol
    var photos: [Photo] {
        imagesListService.photos
    }
    
    // MARK: - Init
    init(imagesListService: ImagesListServiceProtocol = ImagesListService(authConfig: .standard)) {
        self.imagesListService = imagesListService
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        fetchPhotosNextPage()
    }
    
    func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        imagesListService.changeLike(photoId: photoId, isLike: isLike) { [weak self] result in
            guard let self = self else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Self is nil"])))
                return
            }
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                self.view?.showAlert(for: error)
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Methods
    @objc private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
