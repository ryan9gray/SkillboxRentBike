//
//  ProfileViewController.swift
//  RentBike
//
//  Created by Evgeny Ivanov on 27.02.2021.
//

import UIKit
import MobileCoreServices

class ProfileViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var avatarXConstraint: NSLayoutConstraint!

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var aboutLabel: UILabel!

    @IBAction func editAvatarTap(_ sender: Any) {
        libOpen()
    }
    @IBAction func camTap(_ sender: Any) {
        сamOpen()
    }
    struct Output {
        var getAvatar: (_ completion: @escaping (Profile?) -> Void) -> Void
        var upload: (UIImage?) -> Void
        //var infoOpen: () -> Void
    }
    var output: Output!

    override func viewDidLoad() {
        super.viewDidLoad()

        avatarXConstraint.constant = view.bounds.width / 2 - 60
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        output.getAvatar { [weak self] profile in
            guard let url = profile?.avatar, let self = self else { return }

            self.imageView.setImageWithSD(from: url)
        }
    }

    func libOpen() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [String(kUTTypeImage), String(kUTTypeMovie)]
        present(picker, animated: true, completion: nil)
    }

    func сamOpen() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        present(picker, animated: true, completion: nil)
    }

    func imageGet(_ image: UIImage) {
        output.upload(image)
        imageView.image = image
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        imageGet(image)
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
