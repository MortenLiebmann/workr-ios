//
//  AddPostViewController.swift
//  workr
//
//  Created by Morten Liebmann Andersen on 20/08/2018.
//  Copyright © 2018 Morten Liebmann Andersen. All rights reserved.
//

import UIKit
import Photos
import SnapKit
import WSTagsField
import SwiftyJSON
import MapKit

class AddPostViewController: UIViewController {
    @IBOutlet weak var tagTextField: WSTagsField!
    @IBOutlet weak var imageCollectionView: ImagePickerController!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var locationTextField: UITextField!
    
    var mapView: MKMapView!
    
    @IBAction func addPostDidTap(_ sender: Any) {
        addPost(title: titleTextField.text!, description: descriptionTextView.text!)
    }
    
    lazy var tagView: UIView = {
        let newView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        
        newView.backgroundColor = .white
        newView.addSubview(tagCollectionView)
        
        return newView
    }()
    
    lazy var tagCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.height, height: 44), collectionViewLayout: layout)
        collectionView.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: "TagCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        
        return collectionView
        
    }()
    
    let imagePicker = UIImagePickerController()
    var images: [UIImage] = []
    var assets: [PHAsset] = []
    var tags: [Tag] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
        loadData()
    }
    
    func initialize() {
        tagTextField.layoutMargins = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
        tagTextField.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tagTextField.spaceBetweenLines = 5.0
        tagTextField.spaceBetweenTags = 10.0
        tagTextField.font = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.ultraLight)
        tagTextField.tintColor = .darkGray
        
        imageCollectionView.allowsMultipleSelection = true
        imageCollectionView.pickerDelegate = self
        imageCollectionView.reloadPicker()
        
        mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300))
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.revealRegionDetailsWithLongPressOnMap(sender:)))
        mapView.addGestureRecognizer(gesture)
        
        tagTextField.inputFieldAccessoryView = tagView
        tagTextField.placeholder = "Tags"
        
        tagCollectionView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.frame.size.width)
            make.height.equalTo(44)
            make.top.left.right.bottom.equalTo(tagView)
        }
        
        tagTextField.onDidAddTag = {(_,tag) in
            if let index = self.tags.index(where: { (t) -> Bool in
                return t.Name?.lowercased() == tag.text.lowercased()
            }) {
                let indexPath = IndexPath(row: index, section: 0)
                self.tagCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            }
        }
        
        tagTextField.onDidRemoveTag = {(_,tag) in
            if let index = self.tags.index(where: { (t) -> Bool in
                return t.Name?.lowercased() == tag.text.lowercased()
            }) {
                let indexPath = IndexPath(row: index, section: 0)
                self.tagCollectionView.deselectItem(at: indexPath, animated: true)
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func revealRegionDetailsWithLongPressOnMap(sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.began { return }
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        
        let annotation = MapPin(coordinate: locationCoordinate, title: "Temp", subtitle: "Sub")
        mapView.addAnnotation(annotation)
        print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func loadData() {
        appData.getTags().done { (tags) in
            self.tags = tags
            self.tagCollectionView.reloadData()
            }.catch { (error) in
                print(error)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class MapPin : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}

class EmptyTag {
    var Name: String?
    
    init(name: String) {
        self.Name = name
    }
}
extension AddPostViewController {
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    func addPost(title: String, description: String) {
        let tagsToPost = tagTextField.tags.map { (wTag) -> [String: String] in
            return jsonTag(Name: wTag.text).dictionary as! [String: String]
        }
        
        appData.createPost(title: title, description: description, tags: tagsToPost, address: self.locationTextField.text).done { (post) in
            self.uploadImages(postId: post.ID)
            }.catch { (error) in
                print(error)
        }
        
    }
    
    func uploadImages(postId: UUID) {
        guard let images = imageCollectionView.getImages(), images.count > 0 else { return }
        
        appData.uploadImages(postId: postId, images: images).done { (images) in
            self.performSegue(withIdentifier: "unwindToMain", sender: self)
        }
    }
}

extension AddPostViewController: ImagePickerControllerDelegate {
    func imagePickerController(_ picker: ImagePickerController, didOpen imagePicker: UIImagePickerController) {
        self.present(imagePicker, animated: true, completion: nil)
    }
}

extension AddPostViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCollectionViewCell
        
        cell.tagLabel.text = tags[indexPath.row].Name
        
        return cell
    }
}

extension AddPostViewController: UICollectionViewDelegateFlowLayout {
    func handleCellSelect(for cell: UICollectionViewCell?){
        guard let cell = cell else { return }
        if let cell = cell as? TagCollectionViewCell{
            cell.isSelected = !cell.isSelected
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleCellSelect(for: collectionView.cellForItem(at: indexPath))
            let tag = tags[indexPath.row]
            
            if (tagTextField.tags.first { $0.text.lowercased() == tag.Name?.lowercased() }) == nil {
                tagTextField.addTag(tag.Name!)
            }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == self.tagCollectionView {
            let tag = tags[indexPath.row]
            if let wtag = (tagTextField.tags.first{ $0.text.lowercased() == tag.Name?.lowercased()}) {
                tagTextField.removeTag(wtag)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let tag = tags[indexPath.row].Name
            let height = CGFloat(24.0)
            let width = (tag?.width(withConstraintedHeight: height, font: UIFont.systemFont(ofSize: 12)))! + 16
            return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

