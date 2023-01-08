//
//  StorageService.swift
//  JoinTripper
//
//  Created by Dario Corral on 16/12/2018.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import FirebaseUI

struct StorageService {
    
    //MARK: - Function to load image from camera/library. Firstly, we transform images to Data
    static func uploadImage(_ image: UIImage, at reference: StorageReference, completion: @escaping (URL?) -> Void) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.1) else {
            return completion(nil)
        }
        reference.putData(imageData, metadata: nil) { (metadata, error) in
            guard metadata != nil else {
                print("Error uploading image: \(error.debugDescription)")
                return
            }
            // Metadata contains file metadata such as size, content-type.
            //let size = metadata.size
            // You can also access to download URL after upload.
            reference.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print("Error uploading image: \(error.debugDescription)")
                    return
                }
                completion(downloadURL)
            }
        }
    }
    
    //MARK: - Create a Post from an image
    static func createPost(for image: UIImage) {
        
        guard let firUser = Auth.auth().currentUser else {return}
        
        let imageRef = Storage.storage().reference().child(firUser.uid + ".jpg")
        
        StorageService.uploadImage(image, at: imageRef) { (downloadURL) in
            
            guard let downloadURL  = downloadURL else {
                return
            }
            
            let urlString = downloadURL.absoluteString
            print("image url: \(urlString)")
        }
    }
    
    
    //MARK: - Modify Post from an image
    static func modifyPost(for image: UIImage) {
        
        guard let firUser = Auth.auth().currentUser else {return}
        
        let imageRef = Storage.storage().reference().child(firUser.uid + ".jpg")
        //Delete old photo
        imageRef.delete { error in
            if let error = error {
                print("Error deleting profile image \(error)")
            } else {
                print("Image profile deleted")
            }
        }
        
        StorageService.uploadImage(image, at: imageRef) { (downloadURL) in
            
            guard let downloadURL  = downloadURL else {
                return
            }
            
            let urlString = downloadURL.absoluteString
            print("image url: \(urlString)")
        }
    }
    
    
}

