//
//  ViewController.swift
//  ParentChildren
//
//  Created by nmi on 2018/7/17.
//  Copyright © 2018 nmi. All rights reserved.
//

import UIKit

fileprivate let kChildViewPadding:CGFloat = 16.0

class PrivateTransitionContext : NSObject, UIViewControllerContextTransitioning
{
    private var privateViewCtls:Dictionary<String, UIViewController>!
    private var privateAppearingFromRect:CGRect = CGRect.zero
    private var privateAppearingToRect:CGRect = CGRect.zero
    private var privateDisappearingFromRect:CGRect = CGRect.zero
    private var privateDisappearingToRect:CGRect = CGRect.zero
    
    var containerView: UIView!
    
    var isAnimated: Bool = false
    
    var isInteractive: Bool = false
    
    var transitionWasCancelled: Bool = true
    
    var presentationStyle: UIModalPresentationStyle = .custom
    
    var targetTransform: CGAffineTransform = CGAffineTransform.identity
    
    init(fromViewController:UIViewController, toViewController:UIViewController, goingRight:Bool) {
        super.init()
        self.presentationStyle = .custom
        self.containerView = fromViewController.view.superview!
        self.privateViewCtls = [UITransitionContextViewKey.from.rawValue:fromViewController, UITransitionContextViewKey.to.rawValue:toViewController]
        
        let travelDistance:CGFloat = (goingRight ? -self.containerView.bounds.size.width : self.containerView.bounds.size.width);
        self.privateDisappearingFromRect = self.privateAppearingToRect = self.containerView.bounds;
        self.privateDisappearingToRect = CGRectOffset (self.containerView.bounds, travelDistance, 0);
        self.privateAppearingFromRect = CGRectOffset (self.containerView.bounds, -travelDistance, 0);
    }
    
    func updateInteractiveTransition(_ percentComplete: CGFloat) {
        
    }
    
    func finishInteractiveTransition() {
        
    }
    
    func cancelInteractiveTransition() {
        
    }
    
    func pauseInteractiveTransition() {
        
    }
    
    func completeTransition(_ didComplete: Bool) {
        
    }
    
    func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        return self.privateViewCtls[key.rawValue]
    }

    func view(forKey key: UITransitionContextViewKey) -> UIView? {
        return self.privateViewCtls[key.rawValue]?.view
    }

    func initialFrame(for vc: UIViewController) -> CGRect {
        if (vc == self.viewController(forKey: UITransitionContextViewControllerKey.from))
        {
            return self.privateDisappearingFromRect;
        } else {
            return self.privateAppearingFromRect;
        }
    }
    
    func finalFrame(for vc: UIViewController) -> CGRect {
        if (vc == self.viewController(forKey: UITransitionContextViewControllerKey.to))
        {
            return self.privateDisappearingToRect;
        } else {
            return self.privateAppearingToRect;
        }
    }
}

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
        
        let goRight:Bool = transitionContext.initialFrame(for: toViewCtl).origin.x < transitionContext.finalFrame(for: toViewCtl).origin.x
        var travelDistance:CGFloat = transitionContext.containerView.bounds.size.width// + kChildViewPadding
        if (goRight==false)
        {
            travelDistance = travelDistance * -1
        }
        let travel:CGAffineTransform = CGAffineTransform(translationX:travelDistance, y: 0)
        container.addSubview(toViewCtl.view)
        toViewCtl.view.alpha = 0
        toViewCtl.view.transform = travel.inverted()
        
        UIView.animate(withDuration: 1, delay: 0, options: .allowUserInteraction, animations: {
           fromViewCtl.view.transform = travel
            fromViewCtl.view.alpha = 0
            toViewCtl.view.transform = CGAffineTransform.identity
            toViewCtl.view.alpha = 1
        }) { (complete:Bool) in
            
        }
    }
}



class RestaurantViewController: UIViewController, UIViewControllerTransitioningDelegate {

    
    @IBOutlet var containerView:UIView!
    var curVctl:UIViewController!
    
    var animtransition:PrivateAnimatedTransition!
    
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
        self.transitionVctl(mapViewController)
    }
    
    @IBAction func onTransitionToVideo() {
        self.transitionVctl(videoViewController)
    }
    
    @IBAction func onTransitionToWeather() {
        self.transitionVctl(weatherViewController)
    }
    
    func transitionVctl(_ vctl:UIViewController)
    {
        if (curVctl != vctl)
        {
            self.transitionToVctl(newvctl: vctl)
        }
    }
    
    func transitionToVctl(newvctl:UIViewController)
    {
        let animator:PrivateAnimatedTransition = PrivateAnimatedTransition.init()
        
        //newvctl.transitioningDelegate = self
        //self.addChildViewController(newvctl)
        
        /*
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
        */
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return PrivateAnimatedTransition()
    }

}

