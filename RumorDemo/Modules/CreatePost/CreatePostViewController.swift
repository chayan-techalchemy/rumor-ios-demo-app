//
//  CreatePostViewController.swift
//  RumorDemo
//
//  Created by Tech Alchemy
//

import UIKit
import Photos
import PhotosUI

protocol CreatePostDisplayLogic: AnyObject {
    func didCreatePost()
}

protocol CreatePostDelegate: AnyObject {
    func onCreatePost()
}

class CreatePostViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var descriptionTextField: UITextView!
    @IBOutlet private weak var createButton: UIButton!
    @IBOutlet private weak var createButtonBottomConstraint: NSLayoutConstraint!

    weak var delegate: CreatePostDelegate?
    private var viewModel: CreatePostBusinessLogic?
    private let textViewPlaceholder = "Write a caption..."

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = CreatePostViewModel(createPostDisplayLogic: self)
        setUpUI()
    }

    // MARK: - Actions
    @IBAction private func onClickCreateButton(_ sender: Any) {
        viewModel?.createPost(description: descriptionTextField.text)
    }

    // MARK: - Methods
    private func setUpUI() {
        createButton.isEnabled = false
        createButton.alpha = 0.5
        createButton.layer.cornerRadius = 10
        descriptionTextField.delegate = self
        descriptionTextField.text = textViewPlaceholder
        descriptionTextField.textColor = UIColor.lightGray
        descriptionTextField.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
        postImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickPostImage(_:))))

        NotificationCenter.default.addObserver(self,
               selector: #selector(self.keyboardWasShown(notification:)),
               name: UIResponder.keyboardWillShowNotification,
               object: nil)

        NotificationCenter.default.addObserver(self,
               selector: #selector(self.keyboardWillHide(notification:)),
               name: UIResponder.keyboardWillHideNotification,
               object: nil)
    }

    @objc private func tapDone(sender: Any) {
        self.view.endEditing(true)
    }

    @objc private func keyboardWasShown(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.view.frame.origin.y = -keyboardHeight
            })
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.frame.origin.y = 0
        })
    }

    @objc private func onClickPostImage(_ sender: AnyObject) {
        var phPickerConfig = PHPickerConfiguration(photoLibrary: .shared())
        phPickerConfig.selectionLimit = 1
        phPickerConfig.filter = PHPickerFilter.any(of: [.images, .livePhotos])

        let phPickerVC = PHPickerViewController(configuration: phPickerConfig)
        phPickerVC.delegate = self
        present(phPickerVC, animated: true)
    }
}

// MARK: - TextView Delegate
extension CreatePostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = AppConstants.buttonTintColor
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty || textView.text.count < 6 || textView.text.count > 50 {
            createButton.isEnabled = false
            createButton.alpha = 0.5
        } else {
            createButton.isEnabled = true
            createButton.alpha = 1
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = textViewPlaceholder
            textView.textColor = UIColor.lightGray
        }
    }
}

// MARK: - ImagePicker Delegate
extension CreatePostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: .none)
        guard let itemProvider = results.first?.itemProvider else { return }
        itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
            guard let image = reading as? UIImage, error == nil else { return }
            DispatchQueue.main.async {
                self.postImageView.contentMode = .scaleAspectFill
                self.postImageView.image = image
            }
            // This can be used to find the path of the selected image in case we upload it, but for this demo we have added some static image urls
//                result.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.image") { [weak self] url, _ in
//                }
        }
    }
}

// MARK: - Create Post Display Logic
extension CreatePostViewController: CreatePostDisplayLogic {
    func didCreatePost() {
        self.dismiss(animated: true) {
            self.delegate?.onCreatePost()
        }
    }
}
