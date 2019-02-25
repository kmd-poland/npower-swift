import Foundation
import UIKit
import Kingfisher

class VisitTableViewCell: UITableViewCell {

    private let avatarImageView: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    private var downloadTask: DownloadTask?
    
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferredFont(forTextStyle: .headline)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    let subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferredFont(forTextStyle: .body)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
         setLayout()
    }
    
    func setAvatarUrl(_ url: String) {
        downloadTask?.cancel()
        if let downloadUrl = URL(string: url) {
            downloadTask = avatarImageView.kf.setImage(with: downloadUrl)
        }
    }
    
    override func prepareForReuse() {
        downloadTask?.cancel()
    }
    private func setLayout(){
        let textStackView = UIStackView()
        textStackView.axis = .vertical
        textStackView.distribution = .equalCentering
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(subtitleLabel)
    
        let containerStackView = UIStackView()
        containerStackView.axis = .horizontal
        containerStackView.alignment = .center
        containerStackView.spacing = 8
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.addArrangedSubview(avatarImageView)
        containerStackView.addArrangedSubview(textStackView)
        contentView.addSubview(containerStackView)
     
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 60.0),
            avatarImageView.heightAnchor.constraint(equalToConstant: 60.0),

            containerStackView.leftAnchor.constraint(equalToSystemSpacingAfter: contentView.readableContentGuide.leftAnchor, multiplier: 1),

            containerStackView.topAnchor.constraint(equalToSystemSpacingBelow: contentView.readableContentGuide.topAnchor, multiplier: 1),

            contentView.readableContentGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: containerStackView.bottomAnchor, multiplier: 1),

            contentView.readableContentGuide.rightAnchor.constraint(equalToSystemSpacingAfter: containerStackView.rightAnchor, multiplier: 1)
            ])
        
        avatarImageView.layer.cornerRadius = 30
        avatarImageView.clipsToBounds = true
    }
}
