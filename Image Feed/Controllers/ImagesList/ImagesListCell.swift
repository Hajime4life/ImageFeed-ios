import UIKit


final class ImagesListCell: UITableViewCell {
    // MARK: - Public Props
    static let reuseIdentifier = "ImagesListCell"
    // MARK: - Private Props
    private lazy var imageCellView = UIImageView()
    private lazy var dateLabel = UILabel()
    private lazy var gradientView = UIView()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Overrides Methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setCellUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: "\(indexPath.row)") else { return }
        imageCellView.image = image
        dateLabel.text = dateFormatter.string(from: Date())
    }
    
    // MARK: - Private Methods
    private func setCellUI() {
        setImageCellView()
        setDateLabel()
        setGradient()
    }
    
    private func setImageCellView() {
        self.contentView.addSubview(self.imageCellView)
        self.imageCellView.contentMode = .scaleAspectFill
        self.imageCellView.layer.cornerRadius = 16
        self.imageCellView.layer.masksToBounds = true
        self.contentView.backgroundColor = #colorLiteral(red: 0.1001180634, green: 0.1101232544, blue: 0.1355511546, alpha: 1)
        self.backgroundColor = #colorLiteral(red: 0.1001180634, green: 0.1101232544, blue: 0.1355511546, alpha: 1)
        self.selectionStyle = .none
        self.imageCellView.translatesAutoresizingMaskIntoConstraints = false
        self.imageCellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4).isActive = true
        self.imageCellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        self.imageCellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        self.imageCellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4).isActive = true
    }
    
    private func setDateLabel() {
        self.contentView.addSubview(self.dateLabel)
        self.dateLabel.textColor = .white
        self.dateLabel.font = .systemFont(ofSize: 13)
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dateLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 24).isActive = true
        self.dateLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -12).isActive = true
    }
    
    private func setGradient() {
        self.contentView.addSubview(self.gradientView)
        self.gradientView.layer.masksToBounds = true
        self.gradientView.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        self.gradientView.layer.cornerRadius = 16
        self.gradientView.translatesAutoresizingMaskIntoConstraints = false
        self.gradientView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16).isActive = true
        self.gradientView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16).isActive = true
        self.gradientView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -4).isActive = true
        self.gradientView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        self.gradientView.layoutIfNeeded()
        let gradientViewLayer = CAGradientLayer()
        gradientViewLayer.colors = [#colorLiteral(red: 0.101058431, green: 0.1060451791, blue: 0.1357983351, alpha: 0).cgColor, #colorLiteral(red: 0.101058431, green: 0.1060451791, blue: 0.1357983351, alpha: 0.200000003).cgColor]
        gradientViewLayer.frame = self.gradientView.bounds
        if self.gradientView.layer.sublayers?.count == nil  {
            self.gradientView.layer.addSublayer(gradientViewLayer)
        }
    }
}

