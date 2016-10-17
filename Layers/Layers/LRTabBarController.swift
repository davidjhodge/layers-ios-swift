//
//  LRTabBarController.swift
//  Layers
//
//  Created by David Hodge on 10/15/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit
import ImagePicker

class LRTabBarController: UITabBarController, UITabBarControllerDelegate, ImagePickerDelegate {

    var uploadNavController: UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if viewController is UploadBaseViewController
        {
            let imagePickerController = ImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.imageLimit = 1
            imagePickerController.doneButtonTitle = "Next"
            
            uploadNavController = UINavigationController(rootViewController: imagePickerController)
            
            if let nav = uploadNavController
            {
                nav.isNavigationBarHidden = true
                
                present(nav, animated: true, completion: nil)
            }
        }
        
        return true
    }
    
    // MARK: ImagePickerDelegate
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("Wrapper")
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        let uploadStoryboard = UIStoryboard(name: "Upload", bundle: Bundle.main)
        
        if let tagItemVc = uploadStoryboard.instantiateViewController(withIdentifier: "TagItemsViewController") as? TagItemsViewController
        {
            uploadNavController?.setNavigationBarHidden(false, animated: true)
            
            uploadNavController?.pushViewController(tagItemVc, animated: true)
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        print("Cancel")
    }
    
}
