//
//  CommentTableViewCell.swift
//  RumorDemo
//
//  Created by Tech Alchemy
//

import UIKit

class CommentTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        userImageView.contentMode = .scaleAspectFit
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        userImageView.image = nil
        userNameLabel.text = nil
        messageLabel.text = nil
    }

    func configure(comment: Comment) {
        userNameLabel.text = comment.owner.fullName
        userImageView.kf.setImage(with: URL(string: comment.owner.picture))
        messageLabel.text = comment.message
    }
}
