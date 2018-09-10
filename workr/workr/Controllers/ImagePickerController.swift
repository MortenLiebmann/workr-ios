//
//  ImagePickerCollectionView.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 05/09/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit
import Photos

protocol ImagePickerControllerDelegate {
    func imagePickerController(_ picker: ImagePickerController, didOpen imagePicker: UIImagePickerController)
}

class ImagePickerController: UICollectionView {
    var pickerDelegate: ImagePickerControllerDelegate?
    private var assets: [PHAsset] = []
    private var images: [UIImage] = []
    private var imagePicker: UIImagePickerController = UIImagePickerController()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initialize()
    }
    
    private func initialize() {
        self.dataSource = self
        self.delegate = self
        imagePicker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        }
        
        if let layout = self.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
        }
        
        register(AssetCollectionViewCell.self, forCellWithReuseIdentifier: "AssetCell")
        register(CameraCollectionViewCell.self, forCellWithReuseIdentifier: "CameraCell")
    }
    
    func reloadPicker() {
        loadAssets()
    }
    
    private func loadAssets() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                let fetchOptions = PHFetchOptions()
                let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                self.assets = allPhotos.objects(at: IndexSet(0..<allPhotos.count)).sorted(by: {
                    return $0.creationDate! > $1.creationDate!
                })
                DispatchQueue.main.async {
                    self.reloadData()
                }
                
                print("Found \(allPhotos.count) assets")
            case .denied, .restricted:
                print("Not allowed")
            case .notDetermined:
                // Should not see this when requesting
                print("Not determined yet")
            }
        }
    }
    
    private func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        option.version = .original
        manager.requestImage(for: asset, targetSize: CGSize(width: 125, height: 125), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    private func getAssetHighRes(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        option.version = .original
        manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
}

extension ImagePickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            UIImageWriteToSavedPhotosAlbum(pickedImage, nil, nil, nil)
        }
        picker.dismiss(animated: true) {
            self.loadAssets()
            self.reloadData()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
}

extension ImagePickerController {
    func getImages() -> [UIImage]? {
        return self.indexPathsForSelectedItems?.map({ (index) -> UIImage in
            return self.getAssetHighRes(asset: self.getAsset(from: index))
        })
    }
}

extension ImagePickerController: UICollectionViewDataSource {
    func getAsset(from indexPath: IndexPath) -> PHAsset {
        return assets[indexPath.row - 1]
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return assets.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = dequeueReusableCell(withReuseIdentifier: "CameraCell", for: indexPath) as! CameraCollectionViewCell
            return cell
        } else {
            let cell = dequeueReusableCell(withReuseIdentifier: "AssetCell", for: indexPath) as! AssetCollectionViewCell
            let asset = getAsset(from: indexPath)
            cell.assetImage.image = getAssetThumbnail(asset: asset)
            
            return cell
        }
    }
}

extension ImagePickerController: UICollectionViewDelegateFlowLayout {
    func handleCellSelect(for cell: UICollectionViewCell?){
        guard let cell = cell else { return }
        if let cell = cell as? AssetCollectionViewCell {
            cell.isSelected = !cell.isSelected
        } else if ((cell as? CameraCollectionViewCell) != nil) {
            pickerDelegate?.imagePickerController(self, didOpen: imagePicker)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleCellSelect(for: collectionView.cellForItem(at: indexPath))
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size.width / 3
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
