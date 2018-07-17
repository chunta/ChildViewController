//
//  ViewController.swift
//  ParentChildren
//
//  Created by nmi on 2018/7/17.
//  Copyright © 2018 nmi. All rights reserved.
//

import UIKit

class RestaurantViewController: UIViewController {

    @IBOutlet var containerView:UIView!
    
    var curVctl:UIViewController!
    lazy var mapViewController:MapViewController = {
        let viewController:MapViewController = MapViewController(nibName: "MapViewController", bundle: nil)
        return viewController
    }()
    
    lazy var videoViewController:VideoViewController = {
        let viewController:VideoViewController = VideoViewController(nibName: "VideoViewController", bundle: nil)
        return viewController
    }()
    
    lazy var weatherViewController:WeatherViewController = {
        let viewController:WeatherViewController = WeatherViewController(nibName: "WeatherViewController", bundle: nil)
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let mapView:UIView = mapViewController.view
        addChildViewController(mapViewController)
        containerView.addSubview(mapView)
        mapViewController.didMove(toParentViewController: self)
        
        curVctl = mapViewController
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func onTransitionToMap() {
        if (curVctl != mapViewController)
        {
            self.transitionToVctl(newvctl: mapViewController)
        }
    }
    
    @IBAction func onTransitionToVideo() {
        if (curVctl != videoViewController)
        {
            self.transitionToVctl(newvctl: videoViewController)
        }
    }
    
    @IBAction func onTransitionToWeather() {
        if (curVctl != weatherViewController)
        {
            self.transitionToVctl(newvctl: weatherViewController)
        }
    }
    
    func transitionToVctl(newvctl:UIViewController)
    {
        self.addChildViewController(newvctl)
        self.transition(from: curVctl, to: newvctl, duration: 0.5, options:.transitionCrossDissolve, animations: {
  
        }) { (complete:Bool) in
            if (complete)
            {
                newvctl.didMove(toParentViewController: self)
                self.curVctl.willMove(toParentViewController: nil)
                self.curVctl.removeFromParentViewController()
                self.curVctl = newvctl
            }
        }
    }

}

