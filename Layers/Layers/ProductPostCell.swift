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
    
    var productImages: Array<NSURL>?
    
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
    
    func setImageElements(elements: Array<NSURL>)
    {
        productImages = elements
        
        layoutImageViews(true)
    }
    
    private func layoutImageViews(shouldRedraw:Bool)
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
            self.imageViews.removeAll(keepCapacity: false)
            
            // New Image Views
            if let images = productImages
            {
                for imageUrl in images
                {
                    let imageView = AnimatedImageView()
                    imageView.clipsToBounds = true
                    imageView.contentMode = UIViewContentMode.ScaleAspectFit
                    imageView.userInteractionEnabled = true
                    
                    // Set Image
                    imageView.sd_setImageWithURL(imageUrl, placeholderImage: nil, options: SDWebImageOptions.HighPriority, completed: { (image, error, cacheType, url) -> Void in
                        
                        if error != nil
                        {
                            if let placeholderImage = UIImage(named: "image-placeholder")
                            {
                                imageView.contentMode = .Center
                                
                                imageView.image = placeholderImage
                            }
                        }
                        else
                        {
                            imageView.contentMode = .ScaleAspectFit
                        }
                    })
                    
                    photoScrollView.addSubview(imageView)
                    self.imageViews.append(imageView)
                }
            }
            
        }
        
        // Layout image view
        for (index, imageView) in imageViews.enumerate()
        {
            // Creates image view offset based on index in array
            imageView.frame = CGRectMake(CGFloat(index) * photoScrollView.bounds.size.width, 0, photoScrollView.bounds.size.width, photoScrollView.bounds.size.height)
        }
        
        // Set content size based on number of images
        photoScrollView.contentSize = CGSizeMake(photoScrollView.bounds.size.width * (CGFloat(imageViews.count)), photoScrollView.bounds.size.height - 1)
        
        updatePageControl()
    }
    
    // MARK : Scroll View Delegate
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
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
            pageControl.hidden = pageControl.numberOfPages == 1 ? true : false
        }
    }
}
