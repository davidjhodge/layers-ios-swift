//
//  ProductHeaderCell.swift
//  Layers
//
//  Created by David Hodge on 4/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

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
    @IBOutlet weak var likeButton: UIButton!
    
    var imageViews: Array<UIImageView> = Array<UIImageView>()
    
    override var frame: CGRect
    {
        // If frame changes, relayout image views
        didSet {
            layoutImageViews(false)
        }
    }
    
    var productImages: Array<NSURL>?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.delegate = self
        
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
                    let imageView = UIImageView()
                    imageView.clipsToBounds = true
                    imageView.contentMode = UIViewContentMode.ScaleAspectFit
                    
                    // Set Image
                    imageView.sd_setImageWithURL(imageUrl, completed: { (image, error, cacheType, url) -> Void in
                        
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

        //Set offset to zero
        scrollView.setContentOffset(CGPointZero, animated: false)
        
        updatePageControl()
    }
    
    // MARK : Scroll View Delegate
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
}