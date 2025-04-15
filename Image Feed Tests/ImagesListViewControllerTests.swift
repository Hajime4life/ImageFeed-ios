@testable import Image_Feed
import XCTest

// MARK: - ImagesListPresenterSpy
final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    var fetchPhotosNextPageCalled: Bool = false
    var changeLikeCalled: Bool = false
    var photos: [Photo] = []
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
        completion(.success(()))
    }
}

// MARK: - ImagesListViewControllerTests
final class ImagesListViewControllerTests: XCTestCase {
    func testViewControllerCallsFetchPhotosNextPageOnViewDidLoad() {
        // given
        let viewController = ImagesListViewController()
        let presenterSpy = ImagesListPresenterSpy()
        viewController.configure(presenterSpy)
        
        // when
        viewController.viewDidLoad()
        
        // then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
    
    func testViewControllerCallsFetchPhotosNextPageOnWillDisplay() {
        // given
        let viewController = ImagesListViewController()
        let presenterSpy = ImagesListPresenterSpy()
        viewController.configure(presenterSpy)
        viewController.viewDidLoad()
        
        let tableView = UITableView()
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.dataSource = viewController
        tableView.delegate = viewController
        viewController.setTableView(tableView)
        
        let photos = [Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: Date(), welcomeDescription: "", thumbImageURL: "", regularImageURL: "", largeImageURL: "", isLiked: false)]
        presenterSpy.photos = photos
        viewController.setPhotos(photos)
        
        tableView.reloadData()
        presenterSpy.fetchPhotosNextPageCalled = false
        
        // when
        viewController.tableView(tableView, willDisplay: UITableViewCell(), forRowAt: IndexPath(row: 0, section: 0))
        
        // then
        XCTAssertTrue(presenterSpy.fetchPhotosNextPageCalled)
    }
    
    func testViewControllerCallsChangeLike() {
        // given
        let viewController = ImagesListViewController()
        let presenterSpy = ImagesListPresenterSpy()
        viewController.configure(presenterSpy)
        viewController.viewDidLoad()
        
        let tableView = UITableView()
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.dataSource = viewController
        tableView.delegate = viewController
        viewController.setTableView(tableView)
        
        // симулирую photos
        let photos = [Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: Date(), welcomeDescription: "", thumbImageURL: "", regularImageURL: "", largeImageURL: "", isLiked: false)]
        presenterSpy.photos = photos
        viewController.setPhotos(photos)
                tableView.reloadData()
        
        // тут создаю ячейку через таблицу
        let indexPath = IndexPath(row: 0, section: 0)
        guard let cell = tableView.dataSource?.tableView(tableView, cellForRowAt: indexPath) as? ImagesListCell else {
            XCTFail("Failed to dequeue ImagesListCell")
            return
        }
        
        // when
        viewController.imageListCellDidTapLike(cell)
        
        // then
        XCTAssertTrue(presenterSpy.changeLikeCalled)
    }
}
