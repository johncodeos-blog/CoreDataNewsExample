import Kingfisher
import UIKit

class NewsCell: UITableViewCell {
    @IBOutlet var bgView: UIView!
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var sourceLabel: UILabel!
    @IBOutlet var arrowImageView: UIImageView!

    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }

    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }

    private func initView() {
        selectionStyle = .none
        backgroundColor = .jcRed
        // Background View
        bgView.backgroundColor = .jcRedDark
        bgView.layer.cornerRadius = 12
        bgView.clipsToBounds = true
        // Thumbnail
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.layer.cornerRadius = 10
        thumbnailImageView.backgroundColor = .jcRed
        // Title
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        // Date
        dateLabel.textColor = .white.withAlphaComponent(0.4)
        dateLabel.font = .systemFont(ofSize: 8, weight: .regular)
        // Author
        sourceLabel.textColor = .white
        sourceLabel.font = .systemFont(ofSize: 8, weight: .regular)
        // Arrow
        arrowImageView.clipsToBounds = true
        arrowImageView.backgroundColor = .clear
        arrowImageView.image = UIImage(named: "arrow")
        arrowImageView.alpha = 0.3
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
    }
}
