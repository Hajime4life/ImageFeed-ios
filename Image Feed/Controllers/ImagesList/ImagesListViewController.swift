import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
   
    // MARK: - Private Props
    private var tableView: UITableView?
    private let imagesListService = ImagesListService()
    private var photos: [Photo] = []
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        
        imagesListService.fetchPhotosNextPage()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private Methods
    private func setTableView() {
        view.backgroundColor = #colorLiteral(red: 0.1001180634, green: 0.1101232544, blue: 0.1355511546, alpha: 1)
        let tableView = UITableView()
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.backgroundColor = #colorLiteral(red: 0.1001180634, green: 0.1101232544, blue: 0.1355511546, alpha: 1)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        self.tableView = tableView
    }
    
    @objc private func updateTableViewAnimated() {
        let oldCount = photos.count
        photos = imagesListService.photos
        let newCount = photos.count
        
        if oldCount != newCount {
            tableView?.performBatchUpdates({
                let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                tableView?.insertRows(at: indexPaths, with: .automatic)
            }, completion: nil)
        }
    }
    
    private func handleLikeButtonTapped(for photo: Photo, at indexPath: IndexPath) {
        let newLikeState = !photo.isLiked
        imagesListService.changeLike(photoId: photo.id, isLike: newLikeState) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                if let cell = self.tableView?.cellForRow(at: indexPath) as? ImagesListCell {
                    cell.configure(with: self.photos[indexPath.row])
                }
            case .failure(let error):
                print("Ошибка изменения лайка: \(error.localizedDescription)")
                self.showAlert(for: error)
            }
        }
    }
    
    private func showAlert(for error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let alertModel = AlertModel(
                title: "Ошибка",
                message: "Не удалось изменить лайк: \(error.localizedDescription)",
                buttonText: "OK"
            ) { }
            AlertPresenter.showAlert(model: alertModel, vc: self)
        }
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        let photo = photos[indexPath.row]
        cell.configure(with: photo)
        cell.onLikeButtonTapped = { [weak self] in
            guard let self = self else { return }
            self.handleLikeButtonTapped(for: photo, at: indexPath)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        
        guard photo.size.width > 0 else {
            return 200
        }
        
        let scale = imageViewWidth / photo.size.width
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        let singleImageViewController = SingleImageViewController()
        
        guard let url = URL(string: photo.largeImageURL) else { return }
        
        singleImageViewController.modalPresentationStyle = .fullScreen
        present(singleImageViewController, animated: true) {
            singleImageViewController.loadImage(from: url)
        }
    }
}
