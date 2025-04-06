import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    private lazy var imageCellView = UIImageView()
    private lazy var dateLabel = UILabel()
    private lazy var gradientView = UIView()
    private lazy var likeButton = UIButton(type: .custom)
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU") 
        return formatter
    }()
    
    weak var delegate: ImagesListCellDelegate?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setCellUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageCellView.kf.cancelDownloadTask()
        imageCellView.image = nil
        dateLabel.text = nil
        likeButton.setImage(nil, for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradientLayer = gradientView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = gradientView.bounds
        }
    }
    
    func configure(with photo: Photo) {
        
            dateLabel.text = photo.createdAt != nil ? dateFormatter.string(from: photo.createdAt!) : "Дата неизвестна"
            setIsLiked(photo.isLiked)
        
        guard let url = URL(string: photo.regularImageURL) else {
            print("Error - incorrect image URL: \(photo.regularImageURL)")
            return
        }
        
        imageCellView.kf.indicatorType = .activity
        imageCellView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder"),
            options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage,
                .scaleFactor(UIScreen.main.scale)
            ]
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                break
            case .failure(let error):
                print("Error - failed to load image to cell: \(error)")
            }
        }
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        likeButton.setImage(likeImage, for: .normal)
    }
    
    private func setCellUI() {
        backgroundColor = #colorLiteral(red: 0.1001180634, green: 0.1101232544, blue: 0.1355511546, alpha: 1)
        contentView.backgroundColor = .clear
        setImageCellView()
        setDateLabel()
        setLikeButton()
    }
    
    private func setImageCellView() {
        imageCellView.translatesAutoresizingMaskIntoConstraints = false
        imageCellView.contentMode = .scaleAspectFill
        imageCellView.clipsToBounds = true
        imageCellView.layer.cornerRadius = 16
        imageCellView.backgroundColor = #colorLiteral(red: 0.1001180634, green: 0.1101232544, blue: 0.1355511546, alpha: 1)
        contentView.addSubview(imageCellView)
        
        NSLayoutConstraint.activate([
            imageCellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            imageCellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imageCellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            imageCellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }

    private func setDateLabel() {
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textColor = .white
        dateLabel.font = .systemFont(ofSize: 13)
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    
    private func setLikeButton() {
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.addTarget(self, action: #selector(likeButtonClicked), for: .touchUpInside)
        contentView.addSubview(likeButton)
        
        NSLayoutConstraint.activate([
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 44),
            likeButton.trailingAnchor.constraint(equalTo: imageCellView.trailingAnchor, constant: -8),
            likeButton.topAnchor.constraint(equalTo: imageCellView.topAnchor, constant: 8)
        ])
    }
    
    @objc private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
}

// MARK: - ImagesListCellDelegate
protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
