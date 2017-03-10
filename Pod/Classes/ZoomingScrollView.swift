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
public protocol ZoomContentViewProtocol : NSObjectProtocol {
    var frame:CGRect { get set }
    var bounds:CGRect { get set }
    
    var zoomContentView:UIView { get }
    var zoomContentImageSize:CGSize { get }
    
    func setupZoomContentView()
}

open class ZoomContentView : UIImageView, ZoomContentViewProtocol {
    
    public var zoomContentView:UIView {
        return self
    }
    
    public var zoomContentImageSize:CGSize {
        return image?.size ?? .zero
    }
    
    public func setupZoomContentView() {
        self.contentMode = .scaleAspectFit
        self.backgroundColor = .clear
    }
}

open class ZoomingScrollView : UIScrollView, UIScrollViewDelegate {
    public var singleTapEvent:ZoomingEventBlock?
    public var doubleTapEvent:ZoomingEventBlock?
    public var pinchTapEvent :ZoomingEventBlock?
    
    public var zoomMaxScale:CGFloat = 3.0
    public var targetView:ZoomContentViewProtocol {
        didSet {
            self.addSubview(self.targetView.zoomContentView)
            self.setupViews()
        }
    }
    
    public init(frame: CGRect, targetView:ZoomContentViewProtocol? = ZoomContentView()) {
        self.targetView = targetView!
        self.targetView.setupZoomContentView()
        
        super.init(frame: frame)
        
        self.addSubview(self.targetView.zoomContentView)
        self.setupViews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.targetView = ZoomContentView()
        self.targetView.setupZoomContentView()
        
        super.init(coder: aDecoder)
        
        self.addSubview(self.targetView.zoomContentView)
        self.setupViews()
    }
    
    private func setupViews() {
        self.delegate = self
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator   = false
        self.backgroundColor = .clear
        
        self.decelerationRate = UIScrollViewDecelerationRateFast
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func layoutZoomingSubviews() {
        let boundsSize:CGSize = self.bounds.size
        var imageViewFrame:CGRect = self.targetView.frame
        
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
        
        self.targetView.frame = imageViewFrame
    }
    
    
    open func createtargetView() -> UIView! {
        let imageView = UIImageView.init()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        return imageView
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        layoutZoomingSubviews()
    }
    
    public var isZoomed:Bool {
        return self.zoomScale != self.minimumZoomScale
    }
    
    open func cleanUp() {
        self.targetView.frame = .zero
        self.contentSize = .zero
    }
    
    open func prepareAfterCompleted() {
        guard targetView.zoomContentImageSize != .zero else { return }
        
        self.contentSize = targetView.zoomContentImageSize
        
        var frame = self.targetView.frame
        frame.size = targetView.zoomContentImageSize
        
        self.targetView.frame = frame
        self.setMaxMinZoomScalesForCurrentBounds()
    }
    
    open func setMaxMinZoomScalesForCurrentBounds() {
        guard targetView.zoomContentImageSize != .zero else { return }
        
        let boundsSize = self.bounds.size
        let imageSize = self.targetView.bounds.size
        
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
        layoutZoomingSubviews()
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.targetView.zoomContentView
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        guard let pinchBlock = pinchTapEvent else { return }
        pinchBlock()
    }
    
    // MARK: - touch event
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
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
        
        let touchPoint = touch.location(in: self.targetView.zoomContentView)
        
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

