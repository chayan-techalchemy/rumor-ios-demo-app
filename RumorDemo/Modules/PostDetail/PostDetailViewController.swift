//
//  PostDetailViewController.swift
//  RumorDemo
//
//  Created by Tech Alchemy
//

import UIKit

protocol PostDetailDisplayLogic: AnyObject {
    func refreshPost(_ post: Post)
    func refreshComments(_ comments: [Comment])
    func hideLoader()
}

protocol PostDetailDelegate: AnyObject {
    func didUpdatePost(_ post: Post)
}

class PostDetailViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var commentTextView: UITextView!
    @IBOutlet private weak var sendButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var loaderView: UIActivityIndicatorView!
    @IBOutlet private weak var messageViewBottomConstraint: NSLayoutConstraint!

    var viewModel: (PostDetailBusinessLogic & PostDetailDataPassing)?
    weak var delegate: PostDetailDelegate?
    private var post: Post!
    private var comments: [Comment] = []

    private let commentPlaceholderText = "Add a comment..."
    // Text view bottom spacing without padding (10.0)
    private let textViewBottomSpacing: CGFloat = 42

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.fetchPostAndComments()
        setUpUI()
    }

    // MARK: - Actions
    @IBAction private func sendButtonTapped() {
        viewModel?.addNewComment(message: commentTextView.text)
        commentTextView.text = ""
    }

    // MARK: - Methods
    private func setUpUI() {
        sendButton.isEnabled = false
        sendButton.alpha = 0.5
        commentTextView.layer.borderColor = UIColor.lightGray.cgColor
        commentTextView.layer.borderWidth = 0.5
        commentTextView.layer.cornerRadius = 5.0
        commentTextView.delegate = self
        commentTextView.text = commentPlaceholderText
        commentTextView.textColor = UIColor.lightGray
        commentTextView.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
        loaderView.startAnimating()

        tableView.register(PostTableViewCell.nib, forCellReuseIdentifier: PostTableViewCell.reuseIdentifier)
        tableView.register(CommentTableViewCell.nib, forCellReuseIdentifier: CommentTableViewCell.reuseIdentifier)
        tableView.register(NoDataTableViewCell.nib, forCellReuseIdentifier: NoDataTableViewCell.reuseIdentifier)

        tableView.dataSource = self
        tableView.estimatedRowHeight = 100

        NotificationCenter.default.addObserver(self,
               selector: #selector(self.keyboardWasShown(notification:)),
               name: UIResponder.keyboardWillShowNotification,
               object: nil)
        NotificationCenter.default.addObserver(self,
               selector: #selector(self.keyboardWillHide(notification:)),
               name: UIResponder.keyboardWillHideNotification,
               object: nil)
    }

    @objc func tapDone(sender: Any) {
        self.view.endEditing(true)
    }

    @objc func keyboardWasShown(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.messageViewBottomConstraint.constant = keyboardHeight - self.textViewBottomSpacing
            })
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.messageViewBottomConstraint.constant = 0
        })
    }
}

// MARK: - TableView Data Source
extension PostDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        post == nil ? 0 : 1 + (comments.isEmpty ? 1 : comments.count)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.reuseIdentifier, for: indexPath) as! PostTableViewCell
            cell.delegate = self
            cell.configure(post: post)
            return cell
        } else if comments.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: NoDataTableViewCell.reuseIdentifier, for: indexPath) as! NoDataTableViewCell
            cell.selectionStyle = .none
            return cell
         } else {
             let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.reuseIdentifier, for: indexPath) as! CommentTableViewCell
                cell.configure(comment: comments[indexPath.row - 1])
                return cell
        }
    }
}

// MARK: - TextView Delegate
extension PostDetailViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = commentPlaceholderText
            textView.textColor = UIColor.lightGray
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty || textView.text.count < 2 || textView.text.count > 500 {
            sendButton.isEnabled = false
            sendButton.alpha = 0.5
        } else {
            sendButton.isEnabled = true
            sendButton.alpha = 1
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = AppConstants.buttonTintColor
        }
    }
}

// MARK: - Post Detail Display Logic
extension PostDetailViewController: PostDetailDisplayLogic {
    func refreshComments(_ comments: [Comment]) {
        self.comments = comments
        commentTextView.resignFirstResponder()
        DispatchQueue.main.async {
            self.loaderView.stopAnimating()
            self.loaderView.isHidden = true
            self.tableView.reloadData()
        }
    }

    func refreshPost(_ post: Post) {
        self.post = post
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        delegate?.didUpdatePost(post)
    }

    func hideLoader() {
        DispatchQueue.main.async {
            self.loaderView.stopAnimating()
            self.loaderView.isHidden = true
        }
    }
}

// MARK: - Post Cell Delegate
extension PostDetailViewController: PostCellDelegate {
    func didTapLike(postId: String) {
        viewModel?.didLikePost()
    }

    func didTapComment(postId: String) {
        commentTextView.becomeFirstResponder()
    }
}
