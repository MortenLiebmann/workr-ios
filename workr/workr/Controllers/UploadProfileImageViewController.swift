//
//  UploadProfileImageViewController.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 05/09/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit

class UploadProfileImageViewController: UIViewController, AppDataDelegate {
    @IBOutlet weak var imagePickerController: ImagePickerController!
    
    @IBAction func uploadDidTap(_ sender: Any) {
        upload()
    }

    @IBAction func cancelDidTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerController.pickerDelegate = self
        imagePickerController.reloadPicker()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func upload() {
        guard let image = imagePickerController.getImages()?.first else { return }
        guard let user = user else { return }
        
        appData.uploadResourceImage(userId: user.ID, image: image).done { (image) in
            self.performSegue(withIdentifier: "unwind", sender: self)
            }.catch { (error) in
                self.navigationController?.popViewController(animated: true)
        }
    }
}

extension UploadProfileImageViewController: ImagePickerControllerDelegate {
    func imagePickerController(_ picker: ImagePickerController, didOpen imagePicker: UIImagePickerController) {
        self.present(imagePicker, animated: true, completion: nil)
    }
}
