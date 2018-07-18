//
//  ViewController.swift
//  ParentChildren
//
//  Created by nmi on 2018/7/17.
//  Copyright © 2018 nmi. All rights reserved.
//

import UIKit

fileprivate let kChildViewPadding:CGFloat = 16.0
fileprivate let kDamping:CGFloat = 0.75;
fileprivate let kInitialSpringVelocity:CGFloat = 0.5;

class PrivateTransitionContext : NSObject, UIViewControllerContextTransitioning
{
    private var privateViewCtls:Dictionary<String, UIViewController>!
    private var privateAppearingFromRect:CGRect = CGRect.zero
    private var privateAppearingToRect:CGRect = CGRect.zero
    private var privateDisappearingFromRect:CGRect = CGRect.zero
    private var privateDisappearingToRect:CGRect = CGRect.zero
    
    var containerView: UIView
    
    var isAnimated: Bool = false
    
    var isInteractive: Bool = false
    
    var transitionWasCancelled: Bool = true
    
    var presentationStyle: UIModalPresentationStyle = .custom
    
    var targetTransform: CGAffineTransform = CGAffineTransform.identity
    
    var completeBlock: ((Bool)->Void)?
    
    init(fromViewController:UIViewController, toViewController:UIViewController, goingRight:Bool) {
        
        self.presentationStyle = .custom
        self.containerView = fromViewController.view.superview!
        self.containerView.accessibilityIdentifier = "my containerView"
        self.privateViewCtls = [UITransitionContextViewControllerKey.from.rawValue:fromViewController, UITransitionContextViewControllerKey.to.rawValue:toViewController]
        
        let travelDistance:CGFloat = (goingRight ? -self.containerView.bounds.size.width : self.containerView.bounds.size.width);
        self.privateDisappearingFromRect = self.containerView.bounds
        self.privateAppearingToRect = self.containerView.bounds
        self.privateDisappearingToRect = self.containerView.bounds.offsetBy(dx: travelDistance, dy: 0)
        self.privateAppearingFromRect = self.containerView.bounds.offsetBy(dx: -travelDistance, dy: 0)
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
        if (self.completeBlock != nil)
        {
            self.completeBlock!(didComplete)
        }
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

        let container = transitionContext.containerView
        let fromViewCtl:UIViewController! = transitionContext.viewController(forKey: .from)
        let toViewCtl:UIViewController! = transitionContext.viewController(forKey: .to)
        let goRight:Bool = transitionContext.initialFrame(for: toViewCtl).origin.x < transitionContext.finalFrame(for: toViewCtl).origin.x
        var travelDistance:CGFloat = transitionContext.containerView.bounds.size.width + kChildViewPadding
        if (goRight==false)
        {
            travelDistance = travelDistance * -1
        }
        let travel:CGAffineTransform = CGAffineTransform(translationX:travelDistance, y: 0)
        container.addSubview(toViewCtl.view)
        toViewCtl.view.transform = travel.inverted()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: kDamping, initialSpringVelocity: kInitialSpringVelocity, options: .curveEaseOut, animations: {
            fromViewCtl.view.transform = travel
            toViewCtl.view.transform = CGAffineTransform.identity
        }) { (complete:Bool) in
            fromViewCtl.view.transform = CGAffineTransform.identity
            transitionContext .completeTransition(true)
        }
    }
}

class RestaurantViewController: UIViewController, UIViewControllerTransitioningDelegate
{
    @IBOutlet var containerView:UIView!
    
    var privateContainerView:UIView!
    
    var curVctl:UIViewController!
    
    var animtransition:PrivateAnimatedTransition!
    
    lazy var mapViewController:MapViewController = {
        let viewController:MapViewController = MapViewController(nibName: "MapViewController", bundle: nil)
        viewController.view.tag = 0
        return viewController
    }()
    
    lazy var videoViewController:VideoViewController = {
        let viewController:VideoViewController = VideoViewController(nibName: "VideoViewController", bundle: nil)
        viewController.view.tag = 1
        return viewController
    }()
    
    lazy var weatherViewController:WeatherViewController = {
        let viewController:WeatherViewController = WeatherViewController(nibName: "WeatherViewController", bundle: nil)
        viewController.view.tag = 2
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let mapView:UIView = mapViewController.view
        addChildViewController(mapViewController)
        containerView.addSubview(mapView)
        mapViewController.didMove(toParentViewController: self)
        curVctl = mapViewController
        privateContainerView = containerView
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
            self.transitionToVctl(vctl)
        }
    }
    
    func transitionToVctl(_ toVctl:UIViewController)
    {
        let toView:UIView = toVctl.view
        toView.translatesAutoresizingMaskIntoConstraints = false
        toView.frame = self.privateContainerView.bounds
        self.addChildViewController(toVctl)
        let toindex:Int = toVctl.view.tag
        let frindex:Int = curVctl.view.tag
        let transitionContext:PrivateTransitionContext = PrivateTransitionContext.init(fromViewController:curVctl, toViewController:toVctl, goingRight:toindex>frindex)
        transitionContext.isAnimated = true
        transitionContext.isInteractive = false
        transitionContext.completeBlock = { (complete:Bool)-> Void in
            /*
            Called just before the view controller is added or removed from a container view controller.
            If you are implementing your own container view controller,
            it must call the willMove(toParentViewController:) method of the child view controller before calling the removeFromParentViewController() method,
            passing in a parent value of nil.
            */
            self.curVctl.willMove(toParentViewController: nil)
            self.curVctl.view.removeFromSuperview()
            self.curVctl.removeFromParentViewController()
            
            toVctl.didMove(toParentViewController: self)
            self.curVctl = toVctl
        }
        
        let animator:PrivateAnimatedTransition = PrivateAnimatedTransition.init()
        animator.animateTransition(using: transitionContext)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return PrivateAnimatedTransition()
    }

}

