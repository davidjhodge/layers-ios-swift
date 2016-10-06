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
    func showPhotoFullscreen(_ imageView: UIImageView, photos: Array<URL>, selectedIndex: Int)
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
        
        // Round corners
        ctaButton.layer.cornerRadius = 4.0
        ctaButton.clipsToBounds = true
        
        layer.cornerRadius = 4.0
    }
    
    func setImageElements(_ elements: Array<URL>)
    {
        productImages = elements
        
        layoutImageViews(true)
    }
    
    fileprivate func layoutImageViews(_ shouldRedraw:Bool)
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
                    
                    imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapPhoto(_:))))
                    
                    // Set Image
                    imageView.sd_setImage(with: imageUrl, completed: { (image, error, cacheType, url) -> Void in
                        
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
                    
                    scrollView.addSubview(imageView)
                    self.imageViews.append(imageView)
                }
            }

        }
        
        // Layout image view
        for (index, imageView) in imageViews.enumerated()
        {
            // Creates image view offset based on index in array
            imageView.frame = CGRect(x: CGFloat(index) * scrollView.bounds.size.width, y: 0, width: scrollView.bounds.size.width, height: scrollView.bounds.size.height)
        }
        
        // Set content size based on number of images
        scrollView.contentSize = CGSize(width: scrollView.bounds.size.width * (CGFloat(imageViews.count)), height: scrollView.bounds.size.height - 1)

        updatePageControl()
    }
    
    // MARK : Scroll View Delegate
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
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
            let pageNumber = round(self.scrollView.contentOffset.x / self.scrollView.bounds.size.width)
            
            pageControl.currentPage = Int(pageNumber)
            
            // If only 1 page, hide page control
            pageControl.isHidden = pageControl.numberOfPages == 1 ? true : false
        }
    }
    
    // MARK: Expand Photo
    func tapPhoto(_ recognizer: UITapGestureRecognizer)
    {
        if recognizer.state == .ended
        {
            for (index, imageView) in imageViews.enumerated()
            {
                // Detect which photo we're at based on the scroll view offset
                if (imageView.bounds).contains(recognizer.location(in: imageView))
                {
                    if let productImages = productImages
                    {
                        var images = Array<URL>()
                        
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
