//
//  AddPostViewController.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 20/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit
import Photos

class AddPostViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var images: [UIImage] = []
    var assets: [PHAsset] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
        // Do any additional setup after loading the view.
    }
    
    func initialize() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                let fetchOptions = PHFetchOptions()
                let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                self.assets = allPhotos.objects(at: IndexSet(0..<allPhotos.count)).sorted(by: {
                    return $0.creationDate! > $1.creationDate!
                })
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
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
    
    func getAssetHighRes(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        option.version = .original
        manager.requestImage(for: asset, targetSize: CGSize(width: 5000, height: 5000), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
}

extension AddPostViewController: UICollectionViewDataSource {
    func getAsset(from indexPath: IndexPath) -> PHAsset {
        return assets[indexPath.row - 1]
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CameraCell", for: indexPath)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CameraRollCell", for: indexPath) as! AssetCollectionViewCell
            cell.assetImage.image = getAssetThumbnail(asset: getAsset(from: indexPath))
            return cell
        }
    }
}

extension AddPostViewController: UICollectionViewDelegateFlowLayout {
    func handleCellSelect(for cell: UICollectionViewCell?) {
        guard let cell = cell else { return }
        if let cell = cell as? AssetCollectionViewCell {
            cell.isSelected = !cell.isSelected
        } else {
            //tap on camera
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleCellSelect(for: collectionView.cellForItem(at: indexPath))
    }
    
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        handleCellSelect(for: collectionView.cellForItem(at: indexPath))
//    }
    
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

