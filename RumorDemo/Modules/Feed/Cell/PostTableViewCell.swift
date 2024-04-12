//
//  PostTableViewCell.swift
//  RumorDemo
//
//  Created by Tech Alchemy
//

import UIKit
import Kingfisher

protocol PostCellDelegate: AnyObject {
    func didTapLike(postId: String)
    func didTapComment(postId: String)
}

class PostTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var commentButton: UIButton!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!

    private var postId: String = ""

    weak var delegate: PostCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        userImageView.contentMode = .scaleAspectFit
        postImageView.contentMode = .scaleAspectFill
        likeButton.titleLabel?.numberOfLines = 1
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        userNameLabel.text = nil
        userImageView.image = nil
        postImageView.image = nil
        descriptionLabel.text = nil
        dateLabel.text = nil
    }

    @IBAction private func likeButtonTapped() {
        delegate?.didTapLike(postId: postId)
    }

    @IBAction private func commentButtonTapped() {
        delegate?.didTapComment(postId: postId)
    }

    func configure(post: Post) {
        postId = post.id
        userNameLabel.text = post.owner.fullName
        userImageView.kf.setImage(with: URL(string: post.owner.picture), placeholder: UIImage(named: "profile-placeholder"))
        postImageView.kf.setImage(with: URL(string: post.image), placeholder: UIImage(named: "post-placeholder"))
        likeButton.setTitle("\(post.likes)", for: .normal)
        likeButton.isSelected = post.isLiked ?? false
        descriptionLabel.text = post.text
        let publishDate = post.publishDate.getDateFromString(format: AppConstants.serverDateFormat)
        dateLabel.text = publishDate?.getString(format: AppConstants.postDateFormat)
    }
}
