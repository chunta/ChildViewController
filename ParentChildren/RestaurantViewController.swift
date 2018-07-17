//
//  ViewController.swift
//  ParentChildren
//
//  Created by nmi on 2018/7/17.
//  Copyright © 2018 nmi. All rights reserved.
//

import UIKit

fileprivate let kChildViewPadding:CGFloat = 16.0

class PrivateAnimatedTransition : NSObject, UIViewControllerAnimatedTransitioning {
    
    // return how many seconds the transition animation will take
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    // animate a change from one viewcontroller to another
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //TODO: Perform the animation
        let container = transitionContext.containerView
        let fromViewCtl:UIViewController! = transitionContext.viewController(forKey: .from)
        let toViewCtl:UIViewController! = transitionContext.viewController(forKey: .to)
        
        //let offScreenRight = CGAffineTransform(translationX: container.frame.width, y: 0)
        //let offScreenLeft = CGAffineTransform(translationX: -container.frame.width, y: 0)
        
        let goRight:Bool = transitionContext.initialFrame(for: toViewCtl).origin.x < transitionContext.finalFrame(for: toViewCtl).origin.x
        var travelDistance:CGFloat = transitionContext.containerView.bounds.size.width + kChildViewPadding
        if (goRight==false)
        {
            travelDistance = travelDistance * -1
        }
        let travel:CGAffineTransform = CGAffineTransform(translationX:travelDistance, y: 0)
        
    }
}



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

