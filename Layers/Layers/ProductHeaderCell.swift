//
//  ProductHeaderCell.swift
//  Layers
//
//  Created by David Hodge on 4/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

protocol PaginatedImageViewDelegate
{
    func showPhotoFullscreen(imageView: UIImageView, photos: Array<NSURL>, selectedIndex: Int)
}

class ProductHeaderCell: UITableViewCell, UIScrollViewDelegate
{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var largePriceLabel: UILabel!
    @IBOutlet weak var smallPriceLabel: UILabel!
    
    @IBOutlet weak var ctaButton: UIButton!
    
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
        
//        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapPhoto(_:)))
//        tapRecognizer.cancelsTouchesInView = false
//        tapRecognizer.numberOfTapsRequired = 1
//        tapRecognizer.enabled = true
//        tapRecognizer.cancelsTouchesInView = false
//        scrollView.addGestureRecognizer(tapRecognizer)
        
        scrollView.delegate = self

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // If view changes and must layout again, reset image view layout
        layoutImageViews(false)
    }
    
    func setImageElements(elements: Array<NSURL>)
    {
        productImages = elements
        
        layoutImageViews(true)
    }
    
    private func layoutImageViews(shouldRedraw:Bool)
    {
        if scrollView == nil
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
                    
                    imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapPhoto(_:))))
                    
                    // Set Image
                    imageView.sd_setImageWithURL(imageUrl, placeholderImage: nil, options: SDWebImageOptions.ProgressiveDownload, completed: { (image, error, cacheType, url) -> Void in
                    
//                    imageView.sd_setImageWithURL(imageUrl, placeholderImage: nil, completed: { (image, error, cacheType, url) -> Void in
                        
//                        if image != nil && cacheType != .Memory
//                        {
//                            imageView.alpha = 0.0
//                            
//                            UIView.animateWithDuration(0.3, animations: {
//                                imageView.alpha = 1.0
//                            })
//                        }
                    })
                    
                    scrollView.addSubview(imageView)
                    self.imageViews.append(imageView)
                }
            }

        }
        
        // Layout image view
        for (index, imageView) in imageViews.enumerate()
        {
            // Creates image view offset based on index in array
            imageView.frame = CGRectMake(CGFloat(index) * scrollView.bounds.size.width, 0, scrollView.bounds.size.width, scrollView.bounds.size.height)
        }
        
        // Set content size based on number of images
        scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width * (CGFloat(imageViews.count)), scrollView.bounds.size.height - 1)

        updatePageControl()
    }
    
    // MARK : Scroll View Delegate
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
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
            let pageNumber = round(self.scrollView.contentOffset.x / self.scrollView.bounds.size.width)
            
            pageControl.currentPage = Int(pageNumber)
            
            // If only 1 page, hide page control
            pageControl.hidden = pageControl.numberOfPages == 1 ? true : false
        }
    }
    
    // MARK: Expand Photo
    func tapPhoto(recognizer: UITapGestureRecognizer)
    {
        if recognizer.state == .Ended
        {
            for (index, imageView) in imageViews.enumerate()
            {
                // Detect which photo we're at based on the scroll view offset
                if CGRectContainsPoint(imageView.bounds, recognizer.locationInView(imageView))
                {
                    if let productImages = productImages
                    {
                        var images = Array<NSURL>()
                        
                        for image in productImages
                        {
                            images.append(image)
                        }
                        
                        // Old and New arrays match
                        if images.count == productImages.count
                        {
                            delegate?.showPhotoFullscreen(imageView, photos: images, selectedIndex: index)
                        }
                    }
                }
            }
        }
    }
}