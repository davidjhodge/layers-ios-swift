//
//  SelectImageViewController.swift
//  Layers
//
//  Created by David Hodge on 10/16/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit
import NHAlignmentFlowLayout

protocol SelectImageDelegate {
    func imageSelected(_ image: UIImage)
}

class SelectImageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var images: Array<URL>?
    
    var selectImageDelegate: SelectImageDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Which picture is it?"
        
        collectionView.backgroundColor = Color.BackgroundGrayColor
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        // Flow Layout
        let customLayout = NHAlignmentFlowLayout()
        customLayout.scrollDirection = .vertical
        customLayout.alignment = .topLeftAligned
        customLayout.minimumLineSpacing = 8.0
        customLayout.minimumInteritemSpacing = 8.0
        customLayout.sectionInset = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        collectionView.collectionViewLayout = customLayout
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Collection View Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let images = images
        {
            return images.count + 1
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextCollectionViewCell", for: indexPath) as! TextCollectionViewCell
            
            cell.backgroundColor = .white
            
            cell.layer.cornerRadius = 4.0
            
            cell.textLabel.attributedText = NSAttributedString(string: "Select the photo that matches the product.", attributes: [NSForegroundColorAttributeName:Color.DarkTextColor, NSFontAttributeName:Font.PrimaryFontLight(size: 12.0), NSKernAttributeName:1.0])
            
            return cell
        }
        else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
            
            if let imageUrl = images?[safe: indexPath.row - 1]
            {
                cell.imageView.sd_setImage(with: imageUrl, completed: { (image, error, cacheType, imageUrl) -> Void in
                    
                    if image != nil && cacheType != .memory
                    {
                        cell.imageView.alpha = 0.0
                        
                        UIView.animate(withDuration: 0.3, animations: {
                            cell.imageView.alpha = 1.0
                        })
                    }
                })
            }
            
            return cell
        }
    }
    
    
    // MARK: Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let selectedCell = collectionView.cellForItem(at: indexPath) as? ImageCell
        {
            if let selectedImage = selectedCell.imageView.image
            {
                selectImageDelegate?.imageSelected(selectedImage)
                
                let _ = navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: Collection View Delegate Flow Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let flowLayout: UICollectionViewFlowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        let width: CGFloat = (collectionView.bounds.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right)
        
        if indexPath.row == 0
        {
            return CGSize(width: width, height: 48.0)
        }
        else
        {
            return CGSize(width: (collectionView.bounds.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing) / 2, height: 164.0)
        }
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
