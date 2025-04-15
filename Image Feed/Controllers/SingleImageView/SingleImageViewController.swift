import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    // MARK: - Public Props
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image = image else { return }
            imageView.image = image
            imageView.frame = CGRect(origin: .zero, size: image.size)
            updateMinZoomScaleForSize(view.bounds.size)
            hideLoadingView()
        }
    }
    
    // MARK: - Private Props
    private lazy var imageView = UIImageView()
    private var backButton: UIButton?
    private lazy var scrollView = UIScrollView()
    private var shareButton: UIButton?
    
    private lazy var loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "YP Black")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var loadingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "fullscreen_loading_icon")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        setSingleImageScreen()
        showLoadingView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if image != nil {
            updateMinZoomScaleForSize(view.bounds.size)
        }
    }
    
    // MARK: - Public Methods
    func loadImage(from url: URL) {
        showLoadingView()
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder"),
            options: [.transition(.fade(0.2))]
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                self.image = value.image
            case .failure(_):
                self.hideLoadingView()
                self.showAlert()
            }
        }
    }
    
    // MARK: - Private Methods
    @objc private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapShareButton(_ sender: Any) {
        guard let image = image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    private func setSingleImageScreen() {
        setImageView()
        setScrollView()
        setLoadingView()
        setBackButton()
        setShareButton()
    }
    
    private func setImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setScrollView() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 3.0
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        imageView.frame = scrollView.bounds
    }
    
    private func setBackButton() {
        guard let buttonImage = UIImage(named: "backward_icon") else {
            preconditionFailure("backward_icon button image doesn't exist")
        }
        let backButton = UIButton.systemButton(
            with: buttonImage,
            target: self,
            action: #selector(didTapBackButton)
        )
        backButton.tintColor = .white
        backButton.accessibilityIdentifier = "nav back button white"
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            backButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 8)
        ])
        self.backButton = backButton
    }
    
    private func setShareButton() {
        guard let buttonImage = UIImage(named: "sharing_icon") else {
            preconditionFailure("sharing_icon image doesn't exist")
        }
        let shareButton = UIButton(type: .custom)
        shareButton.setImage(buttonImage, for: .normal)
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(shareButton)
        
        NSLayoutConstraint.activate([
            shareButton.widthAnchor.constraint(equalToConstant: 50),
            shareButton.heightAnchor.constraint(equalToConstant: 50),
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -17)
        ])
        self.shareButton = shareButton
    }
    
    private func showAlert() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { preconditionFailure("weak self error") }
            let alertModel = AlertModel(
                title: "Ошибка",
                message: "Что-то пошло не так(",
                buttonText: "OK"
            ) { [weak self] in
                guard let self else { preconditionFailure("weak self error") }
                self.dismiss(animated: true, completion: nil)
            }
            AlertPresenter.showAlert(model: alertModel, vc: self)
        }
    }
    
    private func updateMinZoomScaleForSize(_ size: CGSize) {
        guard let image = image else { return }
        
        let visibleRectSize = size
        let imageSize = image.size
        
        let widthScale = visibleRectSize.width / imageSize.width
        let heightScale = visibleRectSize.height / imageSize.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = max(minScale * 3, 3.0)
        scrollView.zoomScale = minScale
        
        rescaleAndCenterImageInScrollView()
    }
    
    private func rescaleAndCenterImageInScrollView() {
        guard let image = image else { return }
        
        let imageSize = image.size
        let scaledSize = CGSize(
            width: imageSize.width * scrollView.zoomScale,
            height: imageSize.height * scrollView.zoomScale
        )
        scrollView.contentSize = scaledSize
        
        let xOffset = max(0, (scaledSize.width - scrollView.bounds.width) / 2)
        let yOffset = max(0, (scaledSize.height - scrollView.bounds.height) / 2)
        scrollView.contentOffset = CGPoint(x: xOffset, y: yOffset)
    }
    
    private func setLoadingView() {
        view.addSubview(loadingView)
        loadingView.addSubview(loadingImageView)
        
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            loadingImageView.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            loadingImageView.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor),
            loadingImageView.widthAnchor.constraint(equalToConstant: 100),
            loadingImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func showLoadingView() {
        loadingView.isHidden = false
        UIBlockingProgressHUD.show()
        if let backButton = backButton {
            view.bringSubviewToFront(backButton)
        }
    }
    
    private func hideLoadingView() {
        loadingView.isHidden = true
        UIBlockingProgressHUD.dismiss()
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        rescaleAndCenterImageInScrollView()
    }
}
