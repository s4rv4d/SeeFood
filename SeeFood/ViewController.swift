//
//  ViewController.swift
//  SeeFood
//
//  Created by Sarvad shetty on 1/5/18.
//  Copyright © 2018 Sarvad shetty. All rights reserved.
//

import UIKit
import Vision
import CoreML
import Photos

class ViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        checkPermission()
    }
    
    
    
    
  @objc  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = userPickedImage
            guard let ciimage = CIImage(image: userPickedImage) else{
                fatalError("could'nt convert to CIImage")
            }
            detect(image: ciimage)
        }
        
                imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    func detect(image:CIImage){
//        do{
//        let model =  try VNCoreMLModel(for: Inceptionv3().model)
//        }
//        catch{
//            print(error)
//        }
        guard let model =  try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("loadin coreML model failed")
        }
        //we are using try? cause we r more focussed on succes and failure then on why it failed and in try? it automatically gets unwrapped
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let result = request.results as? [VNClassificationObservation],let top = result.first else{
                fatalError("error getting result")
            }
            

         
            if top.identifier.contains("hotdog"){
                DispatchQueue.main.async {
                    self.navigationItem.title = "Hotdog!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.green
                    self.navigationController?.navigationBar.isTranslucent = false
                    
                    
                }
            }else{
                DispatchQueue.main.async {
                    self.navigationItem.title = "Not Hotdog!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.red
                    self.navigationController?.navigationBar.isTranslucent = false
                    
                }
            }
            
        }
        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
            try handler.perform([request])
        }
        catch{
            print(error)
        }
    }
    

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
    }
    
}

