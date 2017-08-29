//
//  MainVC.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 7/12/15.
//  Copyright (c) 2015 Alexey Smirnov. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


let optionsSavedNotification  = "OPTIONS_SAVED"
let viewTypeChangedNotification = "viewTypeChanged"
let needReloadFavoritesNotification = "needReloadFavorites"

let languages = ["en", "ru", "zh_cn", "zh_hk"]

class MainVC: UITabBarController, UITabBarControllerDelegate, UIViewControllerAnimatedTransitioning {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(MainVC.reload), name: NSNotification.Name(rawValue: optionsSavedNotification), object: nil)

        reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PreviewManager.showingPreview = false
    }

    func reload() {
        if let controllers = viewControllers  {
            (controllers[0] as! UINavigationController).title = Translate.s("Catalogue")
            (controllers[1] as! UINavigationController).title = Translate.s("Favorites")
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }

    func findIndex<S: Sequence>(_ sequence: S, predicate: (S.Iterator.Element) -> Bool) -> Int? {
        for (index, element) in sequence.enumerated() {
            if predicate(element) {
                return index
            }
        }
        return nil
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let DampingConstant:CGFloat     = 1.0
        let InitialVelocity:CGFloat     = 0.2
        let PaddingBetweenViews:CGFloat = 0
        
        let inView = transitionContext.containerView
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let fromView = fromVC?.view
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let toView = toVC?.view
        
        let indexFrom = findIndex(viewControllers as! [UINavigationController]) { $0.restorationIdentifier == fromVC?.restorationIdentifier }
        let indexTo = findIndex(viewControllers as! [UINavigationController]) { $0.restorationIdentifier == toVC?.restorationIdentifier }

        let centerRect =  transitionContext.finalFrame(for: toVC!)
        let leftRect   = centerRect.offsetBy(dx: -(centerRect.width+PaddingBetweenViews), dy: 0);
        let rightRect  = centerRect.offsetBy(dx: centerRect.width+PaddingBetweenViews, dy: 0);

        if (indexTo > indexFrom) {
            toView!.frame = rightRect;
            inView.addSubview(toView!)

            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                delay: TimeInterval(0),
                usingSpringWithDamping: DampingConstant,
                initialSpringVelocity: InitialVelocity,
                options: UIViewAnimationOptions(rawValue: 0),
                animations: { fromView!.frame = leftRect; toView!.frame = centerRect },
                completion: { (value:Bool) in transitionContext.completeTransition(true) } )
                    
        } else {
            toView!.frame = leftRect;
            inView.addSubview(toView!)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                delay: TimeInterval(0),
                usingSpringWithDamping: DampingConstant,
                initialSpringVelocity: -InitialVelocity,
                options: UIViewAnimationOptions(rawValue: 0),
                animations: { fromView!.frame = rightRect; toView!.frame = centerRect },
                completion: { (value:Bool) in transitionContext.completeTransition(true) } )
            
        }

    }
        
    
}
