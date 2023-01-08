//
//  MCPhotoHelper.swift
//  JoinTripper
//
//  Created by Dario Corral on 16/12/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit
import Toucan



class MCPhotoHelper: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //MARK: - Propierties
    
    var completionHandler: ((UIImage) -> Void)?
    
    //MARK: - Helper methods
    
    //This function present ImagePickerController for the next function presentActionSheet
    func presentImagePickerController(with sourceType: UIImagePickerController.SourceType, from viewController: UIViewController) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        
        //In order to save photos, we need to inlude:
        imagePickerController.delegate = self
        
        viewController.present(imagePickerController, animated: true)
    }
    
    func presentActionSheet(from viewController: UIViewController){
        
        //Initialize UIAlertController
        let alertController = UIAlertController(title:nil, message: "Where do you want to get your picture from?", preferredStyle: .actionSheet)
        
        //Check if current device has a camera available
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let capturePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { [unowned self] action in
                self.presentImagePickerController(with: .camera, from: viewController)
            })
            
            alertController.addAction(capturePhotoAction)
        }
        
        //Check if current device has a photo library available
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let uploadAction = UIAlertAction(title: "Upload from Library", style: .default, handler: { [unowned self] action in
                self.presentImagePickerController(with: .photoLibrary, from: viewController)
            })
            
            alertController.addAction(uploadAction)
        }
        
        //Add a cancel action (look at style: .cancel)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        viewController.present(alertController, animated: true)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage]  as? UIImage {
            
            let matchangeColor = ColorHex.hexStringToUIColor(hex: "#526CA0")
            guard let selectImageResize = Toucan(image: selectedImage).resize(CGSize(width: 500, height: 500), fitMode: Toucan.Resize.FitMode.crop).image,
                let selectedImageRound = Toucan(image: selectImageResize).maskWithEllipse(borderWidth: 3, borderColor: matchangeColor).image else {
                    completionHandler?(selectedImage)
                    return
            }
            
            completionHandler?(selectedImageRound)
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}

