//
//  UploadBaseViewController.swift
//  Layers
//
//  Created by David Hodge on 10/15/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit

class UploadBaseViewController: UIViewController {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        tabBarItem.title = "Upload"
        tabBarItem.image = UIImage(named: "coathanger-add")
        tabBarItem.selectedImage = UIImage(named: "coathanger-add-filled")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
