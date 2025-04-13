import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    // MARK: - Private Props
    private var tableView: UITableView?
    private var presenter: ImagesListPresenterProtocol!
    private var photos: [Photo] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        presenter.viewDidLoad()
    }
    
    // MARK: - Public Methods
    func configure(_ presenter: ImagesListPresenterProtocol) {
        var mutablePresenter = presenter
        self.presenter = mutablePresenter
        mutablePresenter.view = self
    }
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        let oldCount = photos.count
        photos = (presenter as! ImagesListPresenter).photos
        let newCount = photos.count
        
        if oldCount != newCount {
            tableView?.performBatchUpdates({
                let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                tableView?.insertRows(at: indexPaths, with: .automatic)
            }, completion: nil)
        } else {
            tableView?.reloadData()
        }
    }
    
    func showAlert(for error: Error) {
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
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
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
        cell.delegate = self
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
            presenter.fetchPhotosNextPage()
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

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView?.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        presenter.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            switch result {
            case .success:
                self.photos = (self.presenter as! ImagesListPresenter).photos
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
            case .failure:
                break // в презентере
            }
        }
    }
}
