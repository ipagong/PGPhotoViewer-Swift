//
//  ViewController.swift
//  PGPhotoSample
//
//  Created by ipagong on 2017. 3. 2..
//  Copyright © 2017년 ipagong. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PGPagingScrollViewDelegate, PGPagingScrollViewDataSource {

    private let pagingControl:PGPagingScrollView = PGPagingScrollView()
    private let samplePhotos = [UIImage(named: "github1"),
                                UIImage(named: "github2"),
                                UIImage(named: "github3"),
                                UIImage(named: "github4"),
                                UIImage(named: "github5"),
                                UIImage(named: "github6"),
                                UIImage(named: "github7"),
                                UIImage(named: "github8"),
                                UIImage(named: "github9")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        pagingControl.frame = self.view.bounds
        pagingControl.delegate   = self
        pagingControl.dataSource = self
        pagingControl.backgroundColor = UIColor.red
        self.view.addSubview(pagingControl)
        pagingControl.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func pagingScrollView(_ pagingScrollView:PGPagingScrollView, willChangedCurrentPage currentPageIndex:NSInteger) {
        print("current page will be changed to \(currentPageIndex).")
    }
    
    func pagingScrollView(_ pagingScrollView:PGPagingScrollView, didChangedCurrentPage currentPageIndex:NSInteger) {
        print("current page did changed to \(currentPageIndex).")
    }
    
    func pagingScrollView(_ pagingScrollView:PGPagingScrollView, layoutSubview view:UIView) {
        print("paging control call layoutsubviews.")
    }

    func pagingScrollView(_ pagingScrollView:PGPagingScrollView, recycledView view:UIView?, viewForIndex index:NSInteger) -> UIView {
        guard view == nil else { return view! }
        
        let zoomingView = PGZoomingScrollView(frame: self.view.bounds)
        zoomingView.backgroundColor = UIColor.blue
        zoomingView.singleTapEvent = {
            print("single tapped...")
        }
        
        zoomingView.doubleTapEvent = {
            print("double tapped...")
        }
        
        zoomingView.pinchTapEvent = {
            print("pinched...")
        }
        
        return zoomingView
    }
    
    func pagingScrollView(_ pagingScrollView:PGPagingScrollView, prepareShowPageView view:UIView, viewForIndex index:NSInteger) {
        guard let zoomingView = view as? PGZoomingScrollView else { return }
        
        // maybe you use it image that downloaded async from somewhere like some cdn.
        zoomingView.imageView.image = samplePhotos[index]
        
        // just call this methods after set image for resizing.
        zoomingView.prepareAfterCompleted()
        zoomingView.setMaxMinZoomScalesForCurrentBounds()
    }
    
    func startIndexOfPageWith(pagingScrollView:PGPagingScrollView) -> NSInteger {
        return 0
    }
    
    func numberOfPageWith(pagingScrollView:PGPagingScrollView) -> NSInteger {
        return samplePhotos.count
    }
}

 
