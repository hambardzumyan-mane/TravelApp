//
//  LoadingView.swift
//  TravelApp
//
//  Created by Mane Hambardzumyan on 9/18/16.
//  Copyright © 2016 Mane. All rights reserved.
//

import UIKit

class LoadingView: UIView {

    private var containerView: UIView?
    private var loadingView: UIView?
    private var activityIndicator: UIActivityIndicatorView?
    
    func show(parentView : UIView) {
        
        self.frame = parentView.frame
        self.center = parentView.center
        self.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
        
        let loadingView = UIView()
        loadingView.frame = CGRectMake(0, 0, 80, 80)
        loadingView.center = parentView.center
        loadingView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        activityIndicator.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.WhiteLarge
        activityIndicator.center = CGPointMake(loadingView.frame.size.width / 2,
                                               loadingView.frame.size.height / 2);
        
        loadingView.addSubview(activityIndicator)
        self.addSubview(loadingView)
        parentView.addSubview(self)
        activityIndicator.startAnimating()
        
        self.loadingView = loadingView
        self.activityIndicator = activityIndicator
    }

    func update(frame: CGRect) {
        self.frame = frame
        self.loadingView?.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)
    }
    
    func hide() {
        self.activityIndicator?.stopAnimating()
        self.activityIndicator?.removeFromSuperview()
        self.loadingView?.removeFromSuperview()
        self.removeFromSuperview()
    }
}
