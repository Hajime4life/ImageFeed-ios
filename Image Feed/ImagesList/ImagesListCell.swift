import Foundation
import UIKit

final class ImagesListCell: UITableViewCell {
    @IBOutlet var imageCellView: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var gradientView: UIImageView!
    
    static let reuseIdentifier = "ImagesListCell"

    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        
        guard let image = UIImage(named: "\(indexPath.row)") else { return }
        
        cell.imageCellView.image = image
        cell.dateLabel.text = dateFormatter.string(from: Date())
        let isLiked = indexPath.row % 2 == 0
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.likeButton.setTitle("", for: .normal)
        cell.likeButton.setImage(likeImage, for: .normal)
        
        gradientView.layer.masksToBounds = true
        gradientView.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        let gradientViewLayer = CAGradientLayer()
        gradientViewLayer.colors = [#colorLiteral(red: 0.101058431, green: 0.1060451791, blue: 0.1357983351, alpha: 0).cgColor, #colorLiteral(red: 0.101058431, green: 0.1060451791, blue: 0.1357983351, alpha: 0.2).cgColor]
        gradientViewLayer.frame = gradientView.bounds
        gradientView.layer.addSublayer(gradientViewLayer)
    }
    
}
