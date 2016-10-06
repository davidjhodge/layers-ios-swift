//
//  ProductPostCell.swift
//  Layers
//
//  Created by David Hodge on 9/11/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit
import SDWebImage

//protocol ProductPostCellDelegate {
//    
//    func viewProduct
//}

class ProductPostCell: UICollectionViewCell, UIScrollViewDelegate {
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    
    @IBOutlet weak var userFullNameLabel: UILabel!
    
    @IBOutlet weak var timestampLabel: UILabel!
    
    @IBOutlet weak var userCaptionLabel: UILabel!
    
    @IBOutlet weak var photoScrollView: UIScrollView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var productNameLabel: UILabel!
    
    @IBOutlet weak var engagementSeperator: UIView!
    
    @IBOutlet weak var viewButton: UIButton!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet weak var shareButton: UIButton!
    
    var imageViews: Array<AnimatedImageView> = Array<AnimatedImageView>()
    
    var delegate: PaginatedImageViewDelegate?
    
    var productImages: Array<URL>?
    
    override var frame: CGRect
        {
        // If frame changes, relayout image views
        didSet {
            layoutImageViews(false)
        }
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        photoScrollView.delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // If view changes and must layout again, reset image view layout
        layoutImageViews(false)
        
        layer.cornerRadius = 4.0
        
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.bounds.size.width * 0.5
        profilePictureImageView.clipsToBounds = true
    }
    
    func setImageElements(_ elements: Array<URL>)
    {
        productImages = elements
        
        layoutImageViews(true)
    }
    
    fileprivate func layoutImageViews(_ shouldRedraw:Bool)
    {
        if photoScrollView == nil
        {
            return
        }
        
        if shouldRedraw
        {
            // Remove existing image views
            // From Screen
            for imageView in imageViews
            {
                imageView.image = nil
                imageView.removeFromSuperview()
            }
            
            // Explicitly clear from memory
            self.imageViews.removeAll(keepingCapacity: false)
            
            // New Image Views
            if let images = productImages
            {
                for imageUrl in images
                {
                    let imageView = AnimatedImageView()
                    imageView.clipsToBounds = true
                    imageView.contentMode = UIViewContentMode.scaleAspectFit
                    imageView.isUserInteractionEnabled = true
                    
                    // Set Image
                    imageView.sd_setImage(with: imageUrl, placeholderImage: nil, options: SDWebImageOptions.highPriority, completed: { (image, error, cacheType, url) -> Void in
                        
                        if error != nil
                        {
                            if let placeholderImage = UIImage(named: "image-placeholder")
                            {
                                imageView.contentMode = .center
                                
                                imageView.image = placeholderImage
                            }
                        }
                        else
                        {
                            imageView.contentMode = .scaleAspectFit
                        }
                    })
                    
                    photoScrollView.addSubview(imageView)
                    self.imageViews.append(imageView)
                }
            }
            
        }
        
        // Layout image view
        for (index, imageView) in imageViews.enumerated()
        {
            // Creates image view offset based on index in array
            imageView.frame = CGRect(x: CGFloat(index) * photoScrollView.bounds.size.width, y: 0, width: photoScrollView.bounds.size.width, height: photoScrollView.bounds.size.height)
        }
        
        // Set content size based on number of images
        photoScrollView.contentSize = CGSize(width: photoScrollView.bounds.size.width * (CGFloat(imageViews.count)), height: photoScrollView.bounds.size.height - 1)
        
        updatePageControl()
    }
    
    // MARK : Scroll View Delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updatePageControl()
    }
    
    func updatePageControl()
    {
        if let images = productImages
        {
            pageControl.numberOfPages = images.count
            
            // Calculate which page is in view
            let pageNumber = round(self.photoScrollView.contentOffset.x / self.photoScrollView.bounds.size.width)
            
            pageControl.currentPage = Int(pageNumber)
            
            // If only 1 page, hide page control
            pageControl.isHidden = pageControl.numberOfPages == 1 ? true : false
        }
    }
}
