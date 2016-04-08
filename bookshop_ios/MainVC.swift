//
//  MainVC.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 7/12/15.
//  Copyright (c) 2015 Alexey Smirnov. All rights reserved.
//

import UIKit

var optionsSavedNotification  = "OPTIONS_SAVED"
let languages = ["en", "ru", "zh_cn", "zh_hk"]

class MainVC: UITabBarController, UITabBarControllerDelegate, UIViewControllerAnimatedTransitioning {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload", name: optionsSavedNotification, object: nil)

        reload()
    }

    func reload() {
        if let controllers = viewControllers  {
            (controllers[0] as! UINavigationController).title = Translate.s("Catalogue")
            (controllers[1] as! UINavigationController).title = Translate.s("My books")
        }
    }
    
    func tabBarController(tabBarController: UITabBarController, animationControllerForTransitionFromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 1
    }

    func findIndex<S: SequenceType>(sequence: S, predicate: (S.Generator.Element) -> Bool) -> Int? {
        for (index, element) in sequence.enumerate() {
            if predicate(element) {
                return index
            }
        }
        return nil
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let DampingConstant:CGFloat     = 1.0
        let InitialVelocity:CGFloat     = 0.2
        let PaddingBetweenViews:CGFloat = 0
        
        let inView = transitionContext.containerView()
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let fromView = fromVC?.view
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let toView = toVC?.view
        
        let indexFrom = findIndex(viewControllers as! [UINavigationController]) { $0.restorationIdentifier == fromVC?.restorationIdentifier }
        let indexTo = findIndex(viewControllers as! [UINavigationController]) { $0.restorationIdentifier == toVC?.restorationIdentifier }

        let centerRect =  transitionContext.finalFrameForViewController(toVC!)
        let leftRect   = CGRectOffset(centerRect, -(CGRectGetWidth(centerRect)+PaddingBetweenViews), 0);
        let rightRect  = CGRectOffset(centerRect, CGRectGetWidth(centerRect)+PaddingBetweenViews, 0);

        if (indexTo > indexFrom) {
            toView!.frame = rightRect;
            inView!.addSubview(toView!)

            UIView.animateWithDuration(transitionDuration(transitionContext),
                delay: NSTimeInterval(0),
                usingSpringWithDamping: DampingConstant,
                initialSpringVelocity: InitialVelocity,
                options: UIViewAnimationOptions(rawValue: 0),
                animations: { fromView!.frame = leftRect; toView!.frame = centerRect },
                completion: { (value:Bool) in transitionContext.completeTransition(true) } )
                    
        } else {
            toView!.frame = leftRect;
            inView!.addSubview(toView!)
            
            UIView.animateWithDuration(transitionDuration(transitionContext),
                delay: NSTimeInterval(0),
                usingSpringWithDamping: DampingConstant,
                initialSpringVelocity: -InitialVelocity,
                options: UIViewAnimationOptions(rawValue: 0),
                animations: { fromView!.frame = rightRect; toView!.frame = centerRect },
                completion: { (value:Bool) in transitionContext.completeTransition(true) } )
            
        }

    }
        
    
}