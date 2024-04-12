//
//  FeedViewController.swift
//  RumorDemo
//
//  Created by Tech Alchemy
//

import UIKit
import Combine

protocol FeedDisplayLogic: AnyObject {
    func showFeedData(posts: [Post])
    func hideLoader()
}

class FeedViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var loaderView: UIActivityIndicatorView!
    @IBOutlet private weak var noDataLabel: UILabel!

    private var viewModel: FeedBusinessLogic?
    private var posts: [Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = FeedViewModel(feedDisplayLogic: self)
        viewModel?.fetchPosts()
        setUpUI()
    }

    // MARK: - Actions
    @IBAction private func onClickCreatePostButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "CreatePost", bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController() as? CreatePostViewController else { return }
        vc.delegate = self
        self.present(vc, animated: true)
    }

    // MARK: - Methods
    private func setUpUI() {
        loaderView.startAnimating()
        tableView.register(PostTableViewCell.nib, forCellReuseIdentifier: PostTableViewCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 400
    }
}

// MARK: - TableView DataSource
extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.reuseIdentifier, for: indexPath) as! PostTableViewCell
        cell.delegate = self
        cell.configure(post: posts[indexPath.row])
        return cell
    }
}
// MARK: - TableView Delegate
extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: - Feed Display Logic
extension FeedViewController: FeedDisplayLogic {
    func showFeedData(posts: [Post]) {
        self.posts = posts
        DispatchQueue.main.async {
            self.noDataLabel.isHidden = !posts.isEmpty
            self.loaderView.stopAnimating()
            self.loaderView.isHidden = true
            self.tableView.reloadData()
        }
    }

    func hideLoader() {
        DispatchQueue.main.async {
            self.noDataLabel.isHidden = false
            self.loaderView.stopAnimating()
            self.loaderView.isHidden = true
        }
    }
}

// MARK: - Post Cell Delegate
extension FeedViewController: PostCellDelegate {
    func didTapLike(postId: String) {
        viewModel?.didLikePost(postId: postId)
    }

    func didTapComment(postId: String) {
        guard let post = posts.first(where: { postId == $0.id }) else {
            print("Post not found")
            return
        }
        let storyboard = UIStoryboard(name: "PostDetail", bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController() as? PostDetailViewController else { return }
        vc.viewModel = PostDetailViewModel(postDetailDisplayLogic: vc)
        vc.viewModel?.post = post
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Create Post Delegate
extension FeedViewController: CreatePostDelegate {
    func onCreatePost() {
        viewModel?.fetchPosts()
    }
}

extension FeedViewController: PostDetailDelegate {
    func didUpdatePost(_ post: Post) {
        viewModel?.didUpdatePost(post)
    }
}
