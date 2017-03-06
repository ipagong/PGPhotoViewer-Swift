//
//  ZoomingScrollView.swift
//  PGPhotoSample
//
//  Created by ipagong on 2017. 3. 2..
//  Copyright © 2017년 ipagong. All rights reserved.
//

public typealias ZoomingEventBlock = (Void) -> (Void)

import UIKit

@objc
public class ZoomingScrollView: UIScrollView, UIScrollViewDelegate {
    
    public var singleTapEvent:ZoomingEventBlock?
    public var doubleTapEvent:ZoomingEventBlock?
    public var pinchTapEvent :ZoomingEventBlock?
    
    public var zoomMaxScale:CGFloat = 3.0
    
    public var imageView:UIImageView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        self.imageView = createImageView()
        self.addSubview(self.imageView!)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
        self.imageView = createImageView()
        self.addSubview(self.imageView!)
    }
    
    private func setupViews() {
        self.delegate = self
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator   = false
        self.bounces = false
        self.backgroundColor = .clear
        
        self.decelerationRate = UIScrollViewDecelerationRateFast
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    public func createImageView() -> UIImageView! {
        let imageView = UIImageView.init()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        return imageView
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    
        let boundsSize:CGSize = self.bounds.size
        var imageViewFrame:CGRect = self.imageView.frame
    
        // Horizontally
        if (imageViewFrame.size.width < boundsSize.width) {
            imageViewFrame.origin.x = floor((boundsSize.width - imageViewFrame.size.width) / 2.0)
        } else {
            imageViewFrame.origin.x = 0
        }
    
        // Vertically
        if (imageViewFrame.size.height < boundsSize.height) {
            imageViewFrame.origin.y = floor((boundsSize.height - imageViewFrame.size.height) / 2.0)
        } else {
            imageViewFrame.origin.y = 0
        }
    
        self.imageView.frame = imageViewFrame
    }
    
    public var isZoomed:Bool {
        return self.zoomScale != self.minimumZoomScale
    }
    
    public func cleanUp() {
        self.imageView!.frame = .zero
        self.contentSize = .zero
    }
    
    public func prepareAfterCompleted() {
        guard let image = self.imageView.image else { return }
        
        self.contentSize = image.size
        
        var frame = self.imageView.frame
        frame.size = image.size
        
        self.imageView.frame = frame
        self.setMaxMinZoomScalesForCurrentBounds()
    }
    
    public func setMaxMinZoomScalesForCurrentBounds() {
        guard let image = self.imageView.image else { return }
        guard __CGSizeEqualToSize(image.size, CGSize.zero) == false else { return }
        
        let boundsSize = self.bounds.size
        let imageSize = self.imageView.bounds.size
        
        // calculate min/max zoomscale
        let xScale = boundsSize.width  / imageSize.width    // the scale needed to perfectly fit the image width-wise
        let yScale = boundsSize.height / imageSize.height   // the scale needed to perfectly fit the image height-wise
        let minScale = min(xScale, yScale)                  // use minimum of these to allow the image to become fully visible
        
        let maxScale = zoomMaxScale * minScale
        
        guard minScale != .infinity else { return }
        guard maxScale != .infinity else { return }
        
        self.maximumZoomScale = maxScale
        self.minimumZoomScale = minScale
        self.zoomScale = minScale
    }
    
    // MARK: - uiscrollview delegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        layoutSubviews()
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        guard let pinchBlock = pinchTapEvent else { return }
        pinchBlock()
    }
    
    // MARK: - touch event
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let touch = touches.first else { return }
        
        let tapCount = touch.tapCount
        
        switch (tapCount) {
        case 1:
            self.handleSingleTap(touch)
        case 2:
            self.handleDoubleTap(touch)
        default:
            break
        }
    }
    
    private func handleSingleTap(_ touch:UITouch) {
        guard let singleBlock = self.singleTapEvent else { return }
        singleBlock()
    }
    
    private func handleDoubleTap(_ touch:UITouch) {
        
        let touchPoint = touch.location(in: self.imageView)
        
        // Zoom
        if (self.zoomScale >= self.maximumZoomScale) {
            // Zoom out
            self.setZoomScale(self.minimumZoomScale, animated: true)
        } else {
            self.zoom(to: CGRect(x: touchPoint.x, y: touchPoint.y, width: 0, height: 0), animated: true)
        }
        
        guard let dobuleTapEvent = self.doubleTapEvent else { return }
        dobuleTapEvent()
    }
}

