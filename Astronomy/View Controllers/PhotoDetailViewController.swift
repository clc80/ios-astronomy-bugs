//
//  PhotoDetailViewController.swift
//  Astronomy
//
//  Created by Andrew R Madsen on 9/9/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos

class PhotoDetailViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    @IBAction func save(_ sender: Any) {
        guard let image = imageView.image else { return }
        
        // Do we have permission to access the photo library?
        // We don't know?
        let photosPermissionStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photosPermissionStatus {
        case .authorized:
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }, completionHandler: { (success, error) in
                if let error = error {
                    NSLog("Error saving photo: \(error)")
                    return
                }
            })
            
        case .denied:
            break
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                switch status {
                    
                    // We do. They just gave us permission.
                case .authorized:
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                    }, completionHandler: { (success, error) in
                        if let error = error {
                            NSLog("Error saving photo: \(error)")
                            return
                        }
                    })
                    
                    // We don't They just rejected the request
                case .denied:
                    break
                    
                    // This shoul not happen
                case .notDetermined:
                    break
                    
                    // They have parental controls or something
                case .restricted:
                    break
                }
            }
            
        case .restricted:
            break
            
        }
    }
    
    // MARK: - Private
    
    private func updateViews() {
        guard let photo = photo, isViewLoaded else { return }
        do {
            let data = try Data(contentsOf: photo.imageURL)
            imageView.image = UIImage(data: data)
            let dateString = dateFormatter.string(from: photo.earthDate)
            detailLabel.text = "Taken by \(photo.camera.roverId) on \(dateString) (Sol \(photo.sol))"
            cameraLabel.text = photo.camera.fullName
        } catch {
            NSLog("Error setting up views on detail view controller: \(error)")
        }
    }
    
    // MARK: - Properties
    
    var photo: MarsPhotoReference? {
        didSet {
            updateViews()
        }
    }
    
    lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df
    }()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var cameraLabel: UILabel!
    
}
